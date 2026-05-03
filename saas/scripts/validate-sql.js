#!/usr/bin/env node
// ============================================================
// validate-sql.js
// K-Movement Optimism — SQL 파일 스키마 정합성 검증기
//
// 사용법:
//   node "pt-prescription/saas/scripts/validate-sql.js" \
//     "pt-prescription/saas/migrations/002-soft-tissue-techniques.sql"
// ============================================================

'use strict';

const fs   = require('fs');
const path = require('path');

// ─────────────────────────────────────────────────────────────
// 스키마 기반 하드코딩 — schema.sql 기준
// ─────────────────────────────────────────────────────────────
const VALID_TECHNIQUE_COLUMNS = new Set([
  'id', 'name_ko', 'name_en', 'abbreviation', 'category', 'category_id', 'subcategory',
  'body_region', 'body_segment', 'is_bilateral',
  'description', 'technique_steps', 'patient_position', 'therapist_position',
  'contact_point', 'direction',
  'purpose_tags', 'target_tags', 'symptom_tags', 'contraindication_tags',
  'evidence_level', 'key_references', 'clinical_notes',
  'absolute_contraindications', 'relative_contraindications',
  'is_active', 'is_published', 'created_by', 'created_at', 'updated_at',
]);

const VALID_BODY_REGIONS = new Set([
  'cervical', 'thoracic', 'lumbar', 'sacroiliac', 'shoulder', 'elbow',
  'wrist_hand', 'hip', 'knee', 'ankle_foot', 'temporomandibular', 'rib', 'full_spine',
]);

const VALID_EVIDENCE_LEVELS = new Set([
  'level_1a', 'level_1b', 'level_2a', 'level_2b',
  'level_3', 'level_4', 'level_5', 'insufficient',
]);

const VALID_TECHNIQUE_CATEGORIES = new Set([
  'category_a_joint_mobilization',
  'category_b_mulligan',
  'category_e_soft_tissue',
  // 향후 추가 카테고리도 여기에 등록
]);

// NOT NULL 필수 컬럼 (INSERT 시 반드시 존재해야 함)
const NOT_NULL_COLUMNS = ['name_ko', 'name_en', 'category', 'body_region'];

// 스키마에 존재하지 않는 컬럼 — 과거 버전에서 잘못 사용된 것들
const KNOWN_INVALID_COLUMNS = new Set([
  'maitland_grade',
  'recommendation_weight',
  'session_duration_min',
  'sets',
  'reps',
  'good_response',
  'caution_response',
  'stop_criteria',
  'common_mistakes',
  'description_ko',
]);

// ─────────────────────────────────────────────────────────────
// INSERT 블록 파서
// SQL 파일에서 techniques 테이블의 INSERT 문들을 추출
// ─────────────────────────────────────────────────────────────
function extractTechniqueInserts(sql) {
  const inserts = [];
  // INSERT INTO techniques ( ... ) VALUES ( ... ) 패턴
  const insertRegex = /INSERT INTO techniques\s*\(([\s\S]*?)\)\s*VALUES\s*\(([\s\S]*?)\)\s*(?:ON CONFLICT[\s\S]*?;|;)/gi;
  let m;
  while ((m = insertRegex.exec(sql)) !== null) {
    inserts.push({
      columnsRaw: m[1],
      valuesRaw:  m[2],
      fullMatch:  m[0],
    });
  }
  return inserts;
}

/** 컬럼 목록 문자열 → 배열 */
function parseColumns(columnsRaw) {
  return columnsRaw
    .split(',')
    .map(c => c.trim().replace(/\s+/g, ''))
    .filter(Boolean);
}

/** VALUES 문자열에서 각 값을 순서대로 추출 (단순 파싱, SQL 함수 포함) */
function parseValues(valuesRaw) {
  // 괄호 depth를 트래킹하면서 콤마 분리
  const values = [];
  let depth = 0;
  let current = '';
  let inString = false;
  let stringChar = '';

  for (let i = 0; i < valuesRaw.length; i++) {
    const ch = valuesRaw[i];
    const prev = i > 0 ? valuesRaw[i - 1] : '';

    if (inString) {
      current += ch;
      if (ch === stringChar && prev !== '\\') {
        inString = false;
      }
      continue;
    }

    if (ch === "'" || ch === '"') {
      inString = true;
      stringChar = ch;
      current += ch;
      continue;
    }

    if (ch === '(' || ch === '[') { depth++; current += ch; continue; }
    if (ch === ')' || ch === ']') { depth--; current += ch; continue; }

    if (ch === ',' && depth === 0) {
      values.push(current.trim());
      current = '';
      continue;
    }

    current += ch;
  }
  if (current.trim()) values.push(current.trim());
  return values;
}

/** 값 문자열에서 실제 텍스트 추출 (NULL, 문자열 리터럴, ARRAY, CAST 등) */
function extractRawValue(valStr) {
  const s = valStr.trim();
  if (s.toUpperCase() === 'NULL') return null;
  // 'value'::type → value
  const castMatch = s.match(/^'([\s\S]*)'::[\w_]+$/);
  if (castMatch) return castMatch[1].replace(/''/g, "'");
  // 단순 문자열
  const strMatch = s.match(/^'([\s\S]*)'$/);
  if (strMatch) return strMatch[1].replace(/''/g, "'");
  // ARRAY[...]
  if (s.startsWith('ARRAY[')) return s;
  // true/false
  if (s === 'true' || s === 'false') return s;
  // 숫자
  if (/^-?\d+(\.\d+)?$/.test(s)) return s;
  // (SELECT ...) 서브쿼리
  if (s.startsWith('(SELECT')) return s;
  return s;
}

/** ARRAY[...] 문자열에서 값 목록 추출 */
function extractArrayValues(arrayStr) {
  const m = arrayStr.match(/^ARRAY\[([\s\S]*)\]$/);
  if (!m) return [];
  return m[1].split(',').map(v => v.trim().replace(/^'|'$/g, ''));
}

// ─────────────────────────────────────────────────────────────
// 검증 함수들
// ─────────────────────────────────────────────────────────────

function validateColumns(columns, index) {
  const errors = [];
  const warnings = [];
  for (const col of columns) {
    if (KNOWN_INVALID_COLUMNS.has(col)) {
      errors.push(`컬럼 '${col}' — 스키마에 없음 (과거 버전 잔존 컬럼)`);
    } else if (!VALID_TECHNIQUE_COLUMNS.has(col)) {
      errors.push(`컬럼 '${col}' — 스키마에 존재하지 않는 컬럼`);
    }
  }
  return { errors, warnings };
}

function validateNotNull(columns, valueMap) {
  const errors = [];
  for (const col of NOT_NULL_COLUMNS) {
    if (!columns.includes(col)) {
      errors.push(`NOT NULL 컬럼 '${col}' — INSERT 컬럼 목록에 없음`);
      continue;
    }
    const val = valueMap[col];
    if (val === null || val === 'NULL' || val === undefined || val === '') {
      errors.push(`NOT NULL 컬럼 '${col}' — 값이 NULL`);
    }
  }
  return errors;
}

function validateEnums(columns, valueMap) {
  const errors = [];

  // body_region
  if (columns.includes('body_region')) {
    const val = valueMap['body_region'];
    if (val && val !== 'NULL') {
      // 'cervical'::body_region 또는 'cervical' 형태 처리
      const clean = val.replace(/::body_region/i, '').replace(/^'|'$/g, '').trim();
      if (clean !== 'NULL' && !VALID_BODY_REGIONS.has(clean)) {
        errors.push(`body_region '${clean}' — 유효하지 않은 ENUM 값`);
      }
    }
  }

  // evidence_level
  if (columns.includes('evidence_level')) {
    const val = valueMap['evidence_level'];
    if (val && val !== 'NULL') {
      const clean = val.replace(/::evidence_level/i, '').replace(/^'|'$/g, '').trim();
      if (clean !== 'NULL' && !VALID_EVIDENCE_LEVELS.has(clean)) {
        errors.push(`evidence_level '${clean}' — 유효하지 않은 ENUM 값`);
      }
    }
  }

  // category
  if (columns.includes('category')) {
    const val = valueMap['category'];
    if (val && val !== 'NULL') {
      const clean = val.replace(/::technique_category/i, '').replace(/^'|'$/g, '').trim();
      if (clean !== 'NULL' && !VALID_TECHNIQUE_CATEGORIES.has(clean)) {
        errors.push(`category '${clean}' — 유효하지 않은 ENUM 값 (VALID_TECHNIQUE_CATEGORIES에 없음)`);
      }
    }
  }

  return errors;
}

function validateJsonb(columns, valueMap) {
  const errors = [];
  if (columns.includes('technique_steps')) {
    const val = valueMap['technique_steps'];
    if (val && val !== 'NULL') {
      // '...'::jsonb 형태에서 JSON 추출
      const jsonMatch = val.match(/^'([\s\S]*)'::jsonb$/i);
      if (jsonMatch) {
        try {
          const parsed = JSON.parse(jsonMatch[1].replace(/''/g, "'"));
          if (!Array.isArray(parsed)) {
            errors.push(`technique_steps — JSON이 배열이 아님`);
          } else {
            for (let i = 0; i < parsed.length; i++) {
              if (typeof parsed[i].step === 'undefined') {
                errors.push(`technique_steps[${i}] — 'step' 키 없음`);
              }
              if (typeof parsed[i].instruction === 'undefined') {
                errors.push(`technique_steps[${i}] — 'instruction' 키 없음`);
              }
            }
          }
        } catch (e) {
          errors.push(`technique_steps — JSON 파싱 실패: ${e.message}`);
        }
      }
    }
  }
  return errors;
}

// ─────────────────────────────────────────────────────────────
// technique_categories 테이블 INSERT 컬럼 검증
// ─────────────────────────────────────────────────────────────
const VALID_CATEGORY_COLUMNS = new Set([
  'id', 'category_key', 'name_ko', 'name_en', 'subtitle_ko', 'subtitle_en',
  'basic_principles', 'sort_order', 'is_active', 'created_at', 'updated_at',
]);

function validateCategoryInserts(sql) {
  const errors = [];
  const insertRegex = /INSERT INTO technique_categories\s*\(([\s\S]*?)\)\s*VALUES\s*/gi;
  let m;
  while ((m = insertRegex.exec(sql)) !== null) {
    const cols = parseColumns(m[1]);
    for (const col of cols) {
      if (!VALID_CATEGORY_COLUMNS.has(col)) {
        errors.push(`technique_categories 컬럼 '${col}' — 스키마에 없음`);
      }
    }
  }
  return errors;
}

// ─────────────────────────────────────────────────────────────
// 메인 검증 로직
// ─────────────────────────────────────────────────────────────
function validate(sqlFilePath) {
  const absPath = path.resolve(sqlFilePath);

  if (!fs.existsSync(absPath)) {
    console.error(`[ERROR] 파일이 없습니다: ${absPath}`);
    process.exit(1);
  }

  const sql = fs.readFileSync(absPath, 'utf-8');
  const fileName = path.basename(absPath);

  console.log(`\n🔍 validate-sql: ${fileName}\n`);

  let totalErrors   = 0;
  let totalWarnings = 0;

  // ── technique_categories 검증
  const catErrors = validateCategoryInserts(sql);
  if (catErrors.length > 0) {
    console.log('technique_categories 컬럼 검증:');
    for (const e of catErrors) {
      console.log(`  ❌ ${e}`);
      totalErrors++;
    }
    console.log('');
  } else {
    console.log('technique_categories 컬럼 검증:');
    console.log('  ✅ 모든 컬럼 스키마 일치');
    console.log('');
  }

  // ── techniques INSERT 블록 파싱
  const inserts = extractTechniqueInserts(sql);
  if (inserts.length === 0) {
    console.log('⚠️  techniques INSERT 문을 찾지 못했습니다.');
    return;
  }

  console.log(`techniques INSERT ${inserts.length}개 검증\n`);

  const blockErrors   = [];
  const blockWarnings = [];

  for (let idx = 0; idx < inserts.length; idx++) {
    const ins = inserts[idx];
    const columns = parseColumns(ins.columnsRaw);
    const rawValues = parseValues(ins.valuesRaw);

    // 컬럼-값 매핑
    const valueMap = {};
    for (let i = 0; i < columns.length; i++) {
      const rawVal = rawValues[i] !== undefined ? rawValues[i] : null;
      valueMap[columns[i]] = rawVal ? extractRawValue(rawVal) : null;
    }

    const label = valueMap['name_ko'] || `INSERT #${idx + 1}`;
    const perErrors = [];

    // 1. 컬럼 존재 확인
    const colResult = validateColumns(columns, idx);
    perErrors.push(...colResult.errors);

    // 2. NOT NULL 확인
    perErrors.push(...validateNotNull(columns, valueMap));

    // 3. ENUM 확인
    perErrors.push(...validateEnums(columns, valueMap));

    // 4. JSONB 확인
    perErrors.push(...validateJsonb(columns, valueMap));

    if (perErrors.length > 0) {
      blockErrors.push({ label, errors: perErrors });
      totalErrors += perErrors.length;
    } else {
      blockWarnings.push({ label, ok: true });
    }
  }

  // ── 결과 출력
  // 오류 있는 블록
  if (blockErrors.length > 0) {
    console.log('❌ 오류 발견:');
    for (const b of blockErrors) {
      console.log(`\n  [${b.label}]`);
      for (const e of b.errors) {
        console.log(`    ❌ ${e}`);
      }
    }
    console.log('');
  }

  // 정상 블록 요약
  const okCount = inserts.length - blockErrors.length;
  if (okCount > 0) {
    console.log(`✅ 정상: ${okCount}개 블록 — 스키마 일치`);
  }

  // ── 최종 요약
  console.log('\n' + '─'.repeat(50));
  if (totalErrors === 0) {
    console.log(`✅ 검증 통과 — 오류 0개 (총 ${inserts.length}개 INSERT)`);
    console.log('   Supabase SQL Editor에서 바로 실행 가능합니다.');
  } else {
    console.log(`❌ 요약: 오류 ${totalErrors}개 발견 → 실행 전 수정 필요`);
    console.log('   parse-techniques.js 수정 후 재생성하세요.');
  }
  console.log('');

  // exit code
  process.exit(totalErrors > 0 ? 1 : 0);
}

// ─────────────────────────────────────────────────────────────
// 실행
// ─────────────────────────────────────────────────────────────
const target = process.argv[2];
if (!target) {
  console.error('사용법: node validate-sql.js <sql파일경로>');
  console.error('예시: node "pt-prescription/saas/scripts/validate-sql.js" "pt-prescription/saas/migrations/002-soft-tissue-techniques.sql"');
  process.exit(1);
}

validate(target);
