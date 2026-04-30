#!/usr/bin/env node
// ============================================================
// parse-technique-template.js
// K-Movement Optimism — TECHNIQUE-TEMPLATE.md → SQL 자동 생성기
//
// 사용법:
//   node parse-technique-template.js <template-file.md> [migration-prefix]
//   예: node parse-technique-template.js ../techniques_research/tech-B-001-cervical-snag.md 005
//
// 출력 (migrations/ 폴더에 자동 생성):
//   NNN-[약어]-setup.sql      — 신규 technique_tags INSERT
//   NNN-[약어]-technique.sql  — techniques INSERT/UPSERT
// ============================================================

'use strict';

const fs   = require('fs');
const path = require('path');

// ─────────────────────────────────────────────────────────────
// 알려진 카테고리 enum (경고 판단용)
// ─────────────────────────────────────────────────────────────
const KNOWN_CATEGORIES = new Set([
  'category_joint_mobilization',
  'category_mulligan',
  'category_iastm',
  'category_mfr',
  'category_exercise01',
  'category_d_neural',
  // 레거시 키도 허용
  'category_a_joint_mobilization',
  'category_b_mulligan',
  'category_c_manipulation',
  'category_e_soft_tissue',
  'category_f_therapeutic_exercise',
]);

// body_region ENUM 유효값
const VALID_BODY_REGIONS = new Set([
  'cervical', 'thoracic', 'lumbar', 'sacroiliac', 'shoulder',
  'elbow', 'wrist_hand', 'hip', 'knee', 'ankle_foot',
  'temporomandibular', 'rib', 'full_spine',
]);

// body_region 정규화 맵 (템플릿에서 자유롭게 쓰는 값 → enum 값)
const BODY_REGION_MAP = {
  'cervical':          'cervical',
  'thoracic':          'thoracic',
  'lumbar':            'lumbar',
  'sacroiliac':        'sacroiliac',
  'shoulder':          'shoulder',
  'elbow':             'elbow',
  'wrist':             'wrist_hand',
  'wrist_hand':        'wrist_hand',
  'wrist/hand':        'wrist_hand',
  'hip':               'hip',
  'knee':              'knee',
  'ankle':             'ankle_foot',
  'ankle_foot':        'ankle_foot',
  'ankle/foot':        'ankle_foot',
  'foot':              'ankle_foot',
  'temporomandibular': 'temporomandibular',
  'tmj':               'temporomandibular',
  'rib':               'rib',
  'full_spine':        'full_spine',
};

// evidence_level ENUM 유효값
const VALID_EVIDENCE_LEVELS = new Set([
  'level_1a', 'level_1b', 'level_2a', 'level_2b',
  'level_3', 'level_4', 'level_5', 'insufficient',
]);

// ─────────────────────────────────────────────────────────────
// CLI 인수 파싱
// ─────────────────────────────────────────────────────────────
const [,, inputFile, migrationPrefix] = process.argv;

if (!inputFile) {
  console.error('[ERROR] 사용법: node parse-technique-template.js <template-file.md> [migration-prefix]');
  console.error('        예:    node parse-technique-template.js ../techniques_research/tech-B-001-cervical-snag.md 005');
  process.exit(1);
}

const inputAbs   = path.resolve(inputFile);
const outputDir  = path.resolve(path.join(path.dirname(inputAbs), '..', 'migrations'));
const migNum     = String(migrationPrefix || 'NNN').padStart(3, '0');

// ─────────────────────────────────────────────────────────────
// SQL 이스케이프 유틸리티
// ─────────────────────────────────────────────────────────────

/** 단일 SQL 문자열 이스케이프 (NULL 처리 포함) */
function sqlStr(val) {
  if (val === null || val === undefined || String(val).trim() === '') return 'NULL';
  return `'${String(val).replace(/'/g, "''")}'`;
}

/** TEXT[] 배열 → SQL ARRAY[...] 리터럴 */
function sqlArray(arr) {
  if (!arr || arr.length === 0) return "'{}'";
  const escaped = arr.map(v => `'${String(v).replace(/'/g, "''")}'`);
  return `ARRAY[${escaped.join(', ')}]::text[]`;
}

/** 객체/배열 → SQL JSONB 리터럴 */
function sqlJsonb(obj) {
  if (!obj || (Array.isArray(obj) && obj.length === 0)) return 'NULL';
  if (typeof obj === 'object' && Object.keys(obj).length === 0) return 'NULL';
  return `'${JSON.stringify(obj).replace(/'/g, "''")}'::jsonb`;
}

// ─────────────────────────────────────────────────────────────
// 파싱 헬퍼 함수
// ─────────────────────────────────────────────────────────────

/**
 * 섹션 1 테이블에서 특정 필드 값 추출
 * | **field_key** (설명) | 값 |  또는  | field_key | 값 |  형식
 */
function extractTableField(content, fieldKey) {
  // 볼드 + 괄호 패턴: | **abbreviation** (약어 코드) | 값 |
  const boldPattern = new RegExp(
    `\\|\\s*\\*\\*${fieldKey}\\*\\*[^|]*\\|\\s*([^|\\n]+)`,
    'i'
  );
  const boldMatch = content.match(boldPattern);
  if (boldMatch) return boldMatch[1].trim();

  // 일반 패턴: | fieldKey | 값 |
  const plainPattern = new RegExp(`\\|\\s*${fieldKey}\\s*\\|\\s*([^|\\n]+)`, 'i');
  const plainMatch = content.match(plainPattern);
  if (plainMatch) return plainMatch[1].trim();

  return null;
}

/**
 * 섹션 1 테이블에서 category 값 추출 (백틱 내 값)
 * 예: `category_b_mulligan` 또는 여러 옵션 중 채워진 값
 */
function extractCategory(content) {
  // 섹션 1에서 category 행 찾기
  const catPattern = /\|\s*\*\*category\*\*[^|]*\|\s*([^|\n]+)/i;
  const match = content.match(catPattern);
  if (!match) return null;

  const raw = match[1].trim();

  // 백틱으로 감싼 값 추출 (첫 번째 백틱 값)
  const backtickMatch = raw.match(/`([^`]+)`/);
  if (backtickMatch) return backtickMatch[1].trim();

  // 백틱 없으면 그대로
  return raw || null;
}

/**
 * body_region 정규화
 */
function resolveBodyRegion(raw) {
  if (!raw) return null;
  const lower = raw.toLowerCase().trim();
  // 정확 매핑
  if (BODY_REGION_MAP[lower]) return BODY_REGION_MAP[lower];
  // 부분 매핑
  for (const [key, val] of Object.entries(BODY_REGION_MAP)) {
    if (lower.includes(key)) return val;
  }
  // ENUM 직접 일치
  if (VALID_BODY_REGIONS.has(lower)) return lower;
  return null;
}

/**
 * symptom_tags / target_tags 추출 (쉼표 구분 → 배열)
 */
function extractTagList(content, fieldKey) {
  const raw = extractTableField(content, fieldKey);
  if (!raw) return [];
  return raw
    .split(',')
    .map(t => t.trim())
    .filter(t => t && t !== '-' && !t.startsWith('예:'));
}

/**
 * 섹션 2 (description_ko) 텍스트 추출
 * 코드블록 제외, 섹션 전체 텍스트
 */
function extractSection2(content) {
  const match = content.match(/##\s*2\.\s*description_ko[^\n]*\n([\s\S]*?)(?=\n##\s*3\.)/i);
  if (!match) return null;

  return match[1]
    .replace(/```[\s\S]*?```/g, '')          // 코드블록 제거
    .replace(/^>\s*.*/gm, '')                // blockquote 지침 제거
    .replace(/^---+\s*$/gm, '')              // 수평선 제거
    .replace(/\*\*/g, '')
    .trim()
    .split('\n')
    .map(l => l.trim())
    .filter(Boolean)
    .join(' ') || null;
}

/**
 * 섹션 3 (clinical_rationale) 텍스트 추출
 */
function extractSection3(content) {
  const match = content.match(/##\s*3\.\s*clinical_rationale[^\n]*\n([\s\S]*?)(?=\n##\s*4\.)/i);
  if (!match) return null;

  return match[1]
    .replace(/```[\s\S]*?```/g, '')
    .replace(/^>\s*.*/gm, '')
    .replace(/^---+\s*$/gm, '')              // 수평선 제거
    .replace(/\*\*/g, '')
    .trim()
    .split('\n')
    .map(l => l.trim())
    .filter(Boolean)
    .join(' ') || null;
}

/**
 * 섹션 4-1 코드블록 (patient_position)
 */
function extractCodeBlock(content, sectionPattern) {
  const sectionMatch = content.match(sectionPattern);
  if (!sectionMatch) return null;

  const afterSection = content.slice(sectionMatch.index + sectionMatch[0].length);
  const codeMatch = afterSection.match(/```[^\n]*\n([\s\S]*?)```/);
  if (!codeMatch) return null;

  return codeMatch[1].trim() || null;
}

/**
 * 섹션 4-3 번호 목록 → procedure_steps JSONB 배열
 * [{step: 1, text: "..."}, ...]
 */
function extractProcedureSteps(content) {
  const sectionMatch = content.match(/###\s*4-3\.[^\n]*\n([\s\S]*?)(?=\n##\s*5\.|\n###\s*(?!4-))/i);
  if (!sectionMatch) return [];

  const block = sectionMatch[1];
  const steps = [];

  // "1. **(단계명)** 내용" 또는 "1. 내용" 패턴
  const stepRegex = /^\d+\.\s+(?:\*\*[^*]+\*\*\s*)?(.+)$/gm;
  let m;
  while ((m = stepRegex.exec(block)) !== null) {
    const text = m[1]
      .replace(/\*\*/g, '')
      .replace(/\*/g, '')
      .trim();
    if (text && text.length > 2) {
      steps.push({ step: steps.length + 1, text });
    }
  }
  return steps;
}

/**
 * 섹션 5 체크된 적응증 [x] 항목 → TEXT[]
 */
function extractIndications(content) {
  const match = content.match(/##\s*5\.\s*indications[^\n]*\n([\s\S]*?)(?=\n##\s*6\.)/i);
  if (!match) return [];

  const block = match[1];
  const items = [];

  // - [x] 텍스트 패턴
  const checkRegex = /- \[x\]\s+(.+)/gi;
  let m;
  while ((m = checkRegex.exec(block)) !== null) {
    const text = m[1]
      .replace(/—.*/, '')       // 대시 이후 주석 제거
      .replace(/\*\*/g, '')
      .trim();
    if (text) items.push(text);
  }
  return items;
}

/**
 * 섹션 6 절대 금기 테이블 첫 번째 컬럼 → TEXT[]
 */
function extractContraindications(content) {
  const match = content.match(/##\s*6\.\s*contraindications[^\n]*\n([\s\S]*?)(?=\n##\s*7\.)/i);
  if (!match) return [];

  return extractTableFirstColumn(match[1]);
}

/**
 * 섹션 7 상대적 금기 테이블 첫 번째 컬럼 → TEXT[]
 */
function extractRelativeContraindications(content) {
  const match = content.match(/##\s*7\.\s*relative_contraindications[^\n]*\n([\s\S]*?)(?=\n##\s*8\.)/i);
  if (!match) return [];

  return extractTableFirstColumn(match[1]);
}

/**
 * 마크다운 테이블에서 첫 번째 데이터 컬럼 추출 (헤더·구분선 제외)
 */
function extractTableFirstColumn(block) {
  const items = [];
  const lines = block.split('\n');
  for (const line of lines) {
    if (!line.includes('|')) continue;
    if (/^\s*\|[-\s|]+\|\s*$/.test(line)) continue;   // 구분선
    const cols = line.split('|').map(c => c.trim()).filter(Boolean);
    if (cols.length === 0) continue;
    const val = cols[0]
      .replace(/\*\*/g, '')
      .replace(/\[.+?\]/, '')   // 헤더 텍스트 [필드명] 제거
      .trim();
    // 헤더 행 제외
    if (!val || val.toLowerCase().includes('금기') || val.toLowerCase() === '항목' || val.toLowerCase().includes('상대적 금기')) continue;
    items.push(val);
  }
  return items;
}

/**
 * 섹션 8 evidence_level 추출
 */
function extractEvidenceLevel(content) {
  const match = content.match(/##\s*8\.\s*evidence_level[^\n]*\n([\s\S]*?)(?=\n##\s*9\.)/i);
  if (!match) return 'level_5';

  const block = match[1];

  // DB 코드 행에서 백틱 값 추출
  const dbCodeMatch = block.match(/DB\s*코드[^|]*\|[^|]*`(level_\w+|insufficient)`/i);
  if (dbCodeMatch) {
    const val = dbCodeMatch[1].toLowerCase();
    if (VALID_EVIDENCE_LEVELS.has(val)) return val;
  }

  // evidence_level 행에서 직접 추출
  const evMatch = block.match(/\*\*evidence_level\*\*[^|]*\|[^|]*`([^`]+)`/i);
  if (evMatch) {
    const val = evMatch[1].toLowerCase();
    if (VALID_EVIDENCE_LEVELS.has(val)) return val;
  }

  return 'level_5';
}

/**
 * 섹션 9 key_references 테이블 → JSONB 배열
 * [{pmid, title, year, journal, type, finding}]
 */
function extractKeyReferences(content) {
  const match = content.match(/##\s*9\.\s*key_references[^\n]*\n([\s\S]*?)(?=\n##\s*10\.)/i);
  if (!match) return [];

  const block = match[1];
  const refs = [];
  const lines = block.split('\n');

  for (const line of lines) {
    if (!line.includes('|')) continue;
    if (/^\s*\|[-\s|]+\|\s*$/.test(line)) continue;

    const cols = line.split('|').map(c => c.trim()).filter(Boolean);
    if (cols.length < 2) continue;

    const pmid = cols[0].replace(/\*\*/g, '').trim();
    // 헤더·안내 행 제외
    if (!pmid || pmid.toUpperCase() === 'PMID' || pmid.startsWith('>') || pmid.startsWith('저자')) continue;
    // 예시 주석 행 제외 (PMID가 숫자가 아닌 경우)
    if (!/^\d+$/.test(pmid)) continue;

    refs.push({
      pmid:    pmid,
      title:   (cols[1] || '').replace(/\*\*/g, '').trim(),
      year:    parseInt(cols[2], 10) || null,
      journal: (cols[3] || '').trim(),
      type:    (cols[4] || '').trim(),
      finding: (cols[5] || '').trim(),
    });
  }
  return refs;
}

/**
 * 섹션 10 번호 목록 (clinical_tips) → TEXT[]
 */
function extractClinicalTips(content) {
  const match = content.match(/##\s*10\.\s*clinical_tips[^\n]*\n([\s\S]*?)(?=\n##\s*11\.)/i);
  if (!match) return [];

  const block = match[1];
  const items = [];

  const tipRegex = /^\d+\.\s+(?:\*\*[^*]+\*\*\s*[—-]?\s*)?(.+)$/gm;
  let m;
  while ((m = tipRegex.exec(block)) !== null) {
    const text = m[1].replace(/\*\*/g, '').trim();
    if (text && text.length > 2) items.push(text);
  }
  return items;
}

/**
 * 섹션 11 테이블 (common_mistakes) → JSONB 배열
 * [{mistake, reason, correction}]
 */
function extractCommonMistakes(content) {
  const match = content.match(/##\s*11\.\s*common_mistakes[^\n]*\n([\s\S]*?)(?=\n##\s*12\.|\n---\s*$|$)/i);
  if (!match) return [];

  const block = match[1];
  const mistakes = [];
  const lines = block.split('\n');

  for (const line of lines) {
    if (!line.includes('|')) continue;
    if (/^\s*\|[-\s|]+\|\s*$/.test(line)) continue;

    const cols = line.split('|').map(c => c.trim()).filter(Boolean);
    if (cols.length < 3) continue;

    const mistake = cols[0].replace(/\*\*/g, '').trim();
    if (!mistake || mistake.toLowerCase() === '흔한 실수' || mistake === '항목') continue;

    mistakes.push({
      mistake:    mistake,
      reason:     (cols[1] || '').replace(/\*\*/g, '').trim(),
      correction: (cols[2] || '').replace(/\*\*/g, '').trim(),
    });
  }
  return mistakes;
}

// ─────────────────────────────────────────────────────────────
// 메인 파싱 함수
// ─────────────────────────────────────────────────────────────
function parseTemplate(filePath) {
  if (!fs.existsSync(filePath)) {
    console.error(`[ERROR] 파일을 찾을 수 없습니다: ${filePath}`);
    process.exit(1);
  }

  const content = fs.readFileSync(filePath, 'utf-8');

  // ── 섹션 1: 기본 식별 정보 ──
  const nameKo       = extractTableField(content, 'name_ko');
  const nameEn       = extractTableField(content, 'name_en');
  const abbreviation = extractTableField(content, 'abbreviation');
  const category     = extractCategory(content);
  const subcategory  = extractTableField(content, 'subcategory');
  const rawRegion    = extractTableField(content, 'body_region') || extractTableField(content, '해당 부위');
  const bodyRegion   = resolveBodyRegion(rawRegion);
  const isPublished  = (() => {
    const raw = extractTableField(content, 'is_published');
    if (!raw) return false;
    return raw.toLowerCase() === 'true';
  })();

  const symptomTags = extractTagList(content, 'symptom_tags');
  const targetTags  = extractTagList(content, 'target_tags');

  // ── 섹션 2~3: 설명 + 근거 ──
  const descriptionKo    = extractSection2(content);
  const clinicalRationale = extractSection3(content);

  // ── 섹션 4: 시술 방법 ──
  const patientPosition   = extractCodeBlock(content, /###\s*4-1\.[^\n]*/i);
  const therapistPosition = extractCodeBlock(content, /###\s*4-2\.[^\n]*/i);
  const procedureSteps    = extractProcedureSteps(content);

  // ── 섹션 5~7: 적응증 + 금기 ──
  const indications             = extractIndications(content);
  const contraindications       = extractContraindications(content);
  const relativeContraindications = extractRelativeContraindications(content);

  // ── 섹션 8~9: 근거 ──
  const evidenceLevel  = extractEvidenceLevel(content);
  const keyReferences  = extractKeyReferences(content);

  // ── 섹션 10~11: 임상 팁 + 실수 ──
  const clinicalTips   = extractClinicalTips(content);
  const commonMistakes = extractCommonMistakes(content);

  return {
    nameKo, nameEn, abbreviation,
    category, subcategory,
    bodyRegion,
    isPublished,
    symptomTags, targetTags,
    descriptionKo, clinicalRationale,
    patientPosition, therapistPosition, procedureSteps,
    indications,
    contraindications, relativeContraindications,
    evidenceLevel, keyReferences,
    clinicalTips, commonMistakes,
  };
}

// ─────────────────────────────────────────────────────────────
// 유효성 검증
// ─────────────────────────────────────────────────────────────
function validate(rec) {
  const errors   = [];
  const warnings = [];

  if (!rec.abbreviation) errors.push('abbreviation 없음 — 필수 필드 (ON CONFLICT 기준)');
  if (!rec.nameKo)        errors.push('name_ko 없음 — 필수 필드');
  if (!rec.nameEn)        errors.push('name_en 없음 — 필수 필드');

  if (!rec.bodyRegion)    warnings.push(`body_region 매핑 실패 (원본: "${rec.bodyRegion}") — NULL로 저장됨`);
  if (!rec.category)      warnings.push('category 없음 — NULL로 저장됨');
  else if (!KNOWN_CATEGORIES.has(rec.category)) {
    warnings.push(`category "${rec.category}" 가 알려진 enum 목록에 없음 — DB INSERT 시 오류 가능`);
  }

  if (rec.procedureSteps.length === 0) warnings.push('procedure_steps 0개 파싱됨');
  if (rec.symptomTags.length === 0)    warnings.push('symptom_tags 비어있음');
  if (rec.targetTags.length === 0)     warnings.push('target_tags 비어있음');
  if (!rec.descriptionKo)             warnings.push('description_ko(섹션 2) 없음');

  return { errors, warnings };
}

// ─────────────────────────────────────────────────────────────
// 신규 태그 감지 (기존 마스터에 없는 것 → setup SQL에 포함)
// ─────────────────────────────────────────────────────────────

// 스키마 seed에 있는 기존 태그 키
const EXISTING_SYMPTOM_TAGS = new Set([
  'lbp_nonspecific', 'radiculopathy', 'cervicogenic_ha', 'frozen_shoulder',
  'rotator_cuff', 'lateral_epicondylalgia', 'knee_oa', 'ankle_sprain',
  'patellofemoral', 'disc_herniation',
  // 003 마이그레이션 추가분
  'movement_pain', 'centralization_phenomenon', 'recurrent_lbp',
  'movement_control_deficit', 'chronic_lbp', 'fear_avoidance', 'kinesiophobia',
  'pain_catastrophizing', 'central_sensitization', 'disability_high',
  'rest_pain', 'sciatic_pain', 'neural_tension', 'neck_pain', 'neck_pain_chronic',
  'cervical_derangement', 'whiplash', 'cervical_spondylosis',
]);

const EXISTING_TARGET_TAGS = new Set([
  'acute', 'subacute', 'chronic', 'post_surgical', 'athlete', 'elderly', 'hypermobile',
]);

function detectNewTags(rec) {
  const newSymptom = rec.symptomTags.filter(t => !EXISTING_SYMPTOM_TAGS.has(t));
  const newTarget  = rec.targetTags.filter(t => !EXISTING_TARGET_TAGS.has(t));
  return { newSymptom, newTarget };
}

// ─────────────────────────────────────────────────────────────
// SQL 생성
// ─────────────────────────────────────────────────────────────

/** 약어에서 파일명용 slug 생성 */
function abbrevToSlug(abbrev) {
  return abbrev.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

/** setup SQL 생성 (신규 태그 INSERT) */
function buildSetupSql(rec, newTags, migNum) {
  const { newSymptom, newTarget } = newTags;
  const now = new Date().toISOString().slice(0, 10);
  const slug = abbrevToSlug(rec.abbreviation);

  const lines = [];
  lines.push(`-- ============================================================`);
  lines.push(`-- K-Movement Optimism — Migration ${migNum}`);
  lines.push(`-- ${rec.nameKo} (${rec.abbreviation}) — 신규 태그 설정`);
  lines.push(`-- 자동 생성: parse-technique-template.js`);
  lines.push(`-- 생성일: ${now}`);
  lines.push(`-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql`);
  lines.push(`-- ============================================================`);
  lines.push(`-- ⚠️  실행 순서: 이 파일 먼저 → ${migNum}-${slug}-technique.sql`);
  lines.push(`-- ============================================================`);
  lines.push('');

  if (newSymptom.length === 0 && newTarget.length === 0) {
    lines.push(`-- 신규 태그 없음 (기존 마스터 태그만 사용)`);
    lines.push(`-- 이 파일은 실행하지 않아도 되나, 순서 확인용으로 보존`);
    lines.push('');
    lines.push(`SELECT 'setup: no new tags required' AS status;`);
  } else {
    lines.push(`-- STEP 1: 신규 technique_tags INSERT`);
    lines.push(`INSERT INTO technique_tags (tag_type, tag_key, label_ko, label_en, sort_order)`);
    lines.push(`VALUES`);

    const allNew = [
      ...newSymptom.map(k => ({ type: 'symptom', key: k })),
      ...newTarget.map(k  => ({ type: 'target',  key: k })),
    ];

    const valueLines = allNew.map((t, i) => {
      const comma = i < allNew.length - 1 ? ',' : '';
      // 라벨은 key를 snake_case → 한글/영어 간단 변환 (실제 운영 시 수동 수정 권장)
      const labelEn = t.key.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
      const labelKo = `[${t.key}]`;  // 작성자가 직접 채워넣어야 함
      return `  ('${t.type}', '${t.key}', '${labelKo}', '${labelEn}', 99)${comma}`;
    });

    lines.push(...valueLines);
    lines.push(`ON CONFLICT (tag_type, tag_key) DO NOTHING;`);
    lines.push('');
    lines.push(`-- ⚠️  위 태그의 label_ko / label_en 값을 실제 한국어 표시명으로 수정 후 실행하세요.`);
  }

  lines.push('');
  return lines.join('\n');
}

/** technique INSERT SQL 생성 */
function buildTechniqueSql(rec, migNum) {
  const now  = new Date().toISOString().slice(0, 10);
  const slug = abbrevToSlug(rec.abbreviation);

  // clinical_notes 조합: rationale + tips + mistakes 요약
  const clinicalNotesParts = [];
  if (rec.clinicalRationale) clinicalNotesParts.push(`기전: ${rec.clinicalRationale}`);
  if (rec.clinicalTips.length > 0) {
    clinicalNotesParts.push(`임상 팁: ${rec.clinicalTips.join(' | ')}`);
  }
  if (rec.commonMistakes.length > 0) {
    const mistakesSummary = rec.commonMistakes.map(m => m.mistake).join(', ');
    clinicalNotesParts.push(`흔한 실수: ${mistakesSummary}`);
  }
  const clinicalNotes = clinicalNotesParts.join('\n\n') || null;

  // absolute_contraindications: 텍스트 형식 (TEXT, 배열 아님)
  const absContra = rec.contraindications.length > 0
    ? rec.contraindications.join(', ')
    : null;
  const relContra = rec.relativeContraindications.length > 0
    ? rec.relativeContraindications.join(', ')
    : null;

  // key_references JSONB
  const keyRefsJsonb = rec.keyReferences.length > 0 ? sqlJsonb(rec.keyReferences) : 'NULL';

  // technique_steps JSONB
  const stepsJsonb = rec.procedureSteps.length > 0 ? sqlJsonb(rec.procedureSteps) : 'NULL';

  const lines = [];
  lines.push(`-- ============================================================`);
  lines.push(`-- K-Movement Optimism — Migration ${migNum}`);
  lines.push(`-- ${rec.nameKo} (${rec.abbreviation}) — 테크닉 INSERT`);
  lines.push(`-- 자동 생성: parse-technique-template.js`);
  lines.push(`-- 생성일: ${now}`);
  lines.push(`-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql`);
  lines.push(`-- ============================================================`);
  lines.push(`-- ⚠️  실행 순서: ${migNum}-${slug}-setup.sql 먼저 실행 후 이 파일 실행`);
  lines.push(`-- ============================================================`);
  lines.push('');
  lines.push(`INSERT INTO techniques (`);
  lines.push(`  name_ko, name_en, abbreviation,`);
  lines.push(`  category,`);
  lines.push(`  category_id,`);
  lines.push(`  subcategory,`);
  lines.push(`  body_region,`);
  lines.push(`  description,`);
  lines.push(`  patient_position,`);
  lines.push(`  therapist_position,`);
  lines.push(`  technique_steps,`);
  lines.push(`  symptom_tags,`);
  lines.push(`  target_tags,`);
  lines.push(`  evidence_level,`);
  lines.push(`  key_references,`);
  lines.push(`  clinical_notes,`);
  lines.push(`  absolute_contraindications,`);
  lines.push(`  relative_contraindications,`);
  lines.push(`  is_published,`);
  lines.push(`  is_active`);
  lines.push(`) VALUES (`);
  lines.push(`  ${sqlStr(rec.nameKo)},`);
  lines.push(`  ${sqlStr(rec.nameEn)},`);
  lines.push(`  ${sqlStr(rec.abbreviation)},`);
  lines.push(`  ${rec.category ? sqlStr(rec.category) + '::technique_category' : 'NULL'},`);
  lines.push(`  (SELECT id FROM technique_categories WHERE category_key = ${sqlStr(rec.category)}),`);
  lines.push(`  ${sqlStr(rec.subcategory)},`);
  lines.push(`  ${rec.bodyRegion ? sqlStr(rec.bodyRegion) + '::body_region' : 'NULL'},`);
  lines.push(`  ${sqlStr(rec.descriptionKo)},`);
  lines.push(`  ${sqlStr(rec.patientPosition)},`);
  lines.push(`  ${sqlStr(rec.therapistPosition)},`);
  lines.push(`  ${stepsJsonb},`);
  lines.push(`  ${sqlArray(rec.symptomTags)},`);
  lines.push(`  ${sqlArray(rec.targetTags)},`);
  lines.push(`  ${sqlStr(rec.evidenceLevel)}::evidence_level,`);
  lines.push(`  ${keyRefsJsonb},`);
  lines.push(`  ${sqlStr(clinicalNotes)},`);
  lines.push(`  ${sqlStr(absContra)},`);
  lines.push(`  ${sqlStr(relContra)},`);
  lines.push(`  ${rec.isPublished},`);
  lines.push(`  true`);
  lines.push(`)`);
  lines.push(`ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET`);
  lines.push(`  name_ko                    = EXCLUDED.name_ko,`);
  lines.push(`  name_en                    = EXCLUDED.name_en,`);
  lines.push(`  category                   = EXCLUDED.category,`);
  lines.push(`  category_id                = EXCLUDED.category_id,`);
  lines.push(`  subcategory                = EXCLUDED.subcategory,`);
  lines.push(`  body_region                = EXCLUDED.body_region,`);
  lines.push(`  description                = EXCLUDED.description,`);
  lines.push(`  patient_position           = EXCLUDED.patient_position,`);
  lines.push(`  therapist_position         = EXCLUDED.therapist_position,`);
  lines.push(`  technique_steps            = EXCLUDED.technique_steps,`);
  lines.push(`  symptom_tags               = EXCLUDED.symptom_tags,`);
  lines.push(`  target_tags                = EXCLUDED.target_tags,`);
  lines.push(`  evidence_level             = EXCLUDED.evidence_level,`);
  lines.push(`  key_references             = EXCLUDED.key_references,`);
  lines.push(`  clinical_notes             = EXCLUDED.clinical_notes,`);
  lines.push(`  absolute_contraindications = EXCLUDED.absolute_contraindications,`);
  lines.push(`  relative_contraindications = EXCLUDED.relative_contraindications,`);
  lines.push(`  is_published               = EXCLUDED.is_published,`);
  lines.push(`  updated_at                 = NOW();`);
  lines.push('');

  return lines.join('\n');
}

// ─────────────────────────────────────────────────────────────
// 메인 실행
// ─────────────────────────────────────────────────────────────
function main() {
  console.log('\nparse-technique-template.js 시작');
  console.log(`  입력 파일: ${inputAbs}`);
  console.log(`  마이그레이션 번호: ${migNum}`);
  console.log(`  출력 폴더: ${outputDir}\n`);

  // 1. 파싱
  process.stdout.write('파싱 중... ');
  const rec = parseTemplate(inputAbs);
  console.log('완료\n');

  // 2. 유효성 검증
  const { errors, warnings } = validate(rec);

  if (warnings.length > 0) {
    warnings.forEach(w => console.warn(`  [WARN] ${w}`));
  }
  if (errors.length > 0) {
    errors.forEach(e => console.error(`  [ERROR] ${e}`));
    console.error('\n중단: 필수 필드 오류로 SQL을 생성할 수 없습니다.');
    process.exit(1);
  }

  // 3. 신규 태그 감지
  const newTags = detectNewTags(rec);
  if (newTags.newSymptom.length > 0) {
    console.log(`  신규 symptom 태그: ${newTags.newSymptom.join(', ')}`);
  }
  if (newTags.newTarget.length > 0) {
    console.log(`  신규 target 태그: ${newTags.newTarget.join(', ')}`);
  }

  // 4. 출력 파일명 결정
  const slug      = abbrevToSlug(rec.abbreviation);
  const setupFile = path.join(outputDir, `${migNum}-${slug}-setup.sql`);
  const techFile  = path.join(outputDir, `${migNum}-${slug}-technique.sql`);

  // 5. SQL 생성
  const setupSql = buildSetupSql(rec, newTags, migNum);
  const techSql  = buildTechniqueSql(rec, migNum);

  // 6. 파일 쓰기
  fs.mkdirSync(outputDir, { recursive: true });
  fs.writeFileSync(setupFile, setupSql, 'utf-8');
  fs.writeFileSync(techFile,  techSql,  'utf-8');

  // 7. 결과 요약
  console.log('\nSQL 생성 완료');
  console.log(`  [1] ${setupFile}`);
  console.log(`  [2] ${techFile}`);
  console.log('');
  console.log('파싱 결과 요약:');
  console.log(`  name_ko:         ${rec.nameKo || '(없음)'}`);
  console.log(`  name_en:         ${rec.nameEn || '(없음)'}`);
  console.log(`  abbreviation:    ${rec.abbreviation || '(없음)'}`);
  console.log(`  category:        ${rec.category || '(없음)'}`);
  console.log(`  body_region:     ${rec.bodyRegion || '(없음)'}`);
  console.log(`  symptom_tags:    [${rec.symptomTags.join(', ')}]`);
  console.log(`  target_tags:     [${rec.targetTags.join(', ')}]`);
  console.log(`  evidence_level:  ${rec.evidenceLevel}`);
  console.log(`  procedure_steps: ${rec.procedureSteps.length}개`);
  console.log(`  key_references:  ${rec.keyReferences.length}개`);
  console.log(`  clinical_tips:   ${rec.clinicalTips.length}개`);
  console.log(`  common_mistakes: ${rec.commonMistakes.length}개`);
  console.log('');
  console.log('Supabase 실행 순서:');
  console.log(`  1. ${path.basename(setupFile)}`);
  console.log(`  2. ${path.basename(techFile)}`);
  console.log('  3. /sync-technique-relations 실행 (technique_indications 연결)');
}

main();
