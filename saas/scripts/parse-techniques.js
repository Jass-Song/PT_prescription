#!/usr/bin/env node
// ============================================================
// parse-techniques.js
// K-Movement Optimism — MD 파일 → SQL INSERT 자동 생성기
//
// 사용법:
//   node "pt-prescription/saas/scripts/parse-techniques.js" \
//     --input "research/soft-tissue" \
//     --category "category_e_soft_tissue" \
//     --migration-number "002" \
//     --output "pt-prescription/saas/migrations/"
// ============================================================

'use strict';

const fs   = require('fs');
const path = require('path');

// ─────────────────────────────────────────────────────────────
// CLI 인수 파싱
// ─────────────────────────────────────────────────────────────
function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i++) {
    if (argv[i].startsWith('--')) {
      const key = argv[i].slice(2);
      args[key] = argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[++i] : true;
    }
  }
  return args;
}

const args = parseArgs(process.argv);
const INPUT_DIR      = args['input']            || 'research/soft-tissue';
const CATEGORY_KEY   = args['category']         || 'category_e_soft_tissue';
const MIGRATION_NUM  = args['migration-number'] || '002';
const OUTPUT_DIR     = args['output']           || 'pt-prescription/saas/migrations/';
// --subcategory "MFR,IASTM" 형태로 필터링 가능 (미지정 시 전체 포함)
const SUBCATEGORY_FILTER = args['subcategory']
  ? args['subcategory'].split(',').map(s => s.trim())
  : null;

// ─────────────────────────────────────────────────────────────
// body_region ENUM 매핑
// ─────────────────────────────────────────────────────────────
const BODY_REGION_MAP = {
  'cervical':             'cervical',
  'cervical / shoulder':  'cervical',
  'thoracic':             'thoracic',
  'shoulder':             'shoulder',
  'forearm':              'wrist_hand',
  'wrist':                'wrist_hand',
  'lumbar':               'lumbar',
  'hip':                  'hip',
  'thigh-hamstring':      'hip',
  'thigh-quadriceps':     'knee',
  'thigh-it-band':        'knee',
  'calf':                 'ankle_foot',
  'foot':                 'ankle_foot',
  'ankle':                'ankle_foot',
  'sacroiliac':           'sacroiliac',
  'elbow':                'elbow',
  'wrist_hand':           'wrist_hand',
  'knee':                 'knee',
  'ankle_foot':           'ankle_foot',
  'temporomandibular':    'temporomandibular',
  'rib':                  'rib',
  'full_spine':           'full_spine',
};

function resolveBodyRegion(rawValue) {
  if (!rawValue) return null;
  const lower = rawValue.toLowerCase().trim();
  // 정확 매핑 먼저
  if (BODY_REGION_MAP[lower]) return BODY_REGION_MAP[lower];
  // includes 검색
  for (const [key, val] of Object.entries(BODY_REGION_MAP)) {
    if (lower.includes(key)) return val;
  }
  return null;
}

// ─────────────────────────────────────────────────────────────
// MD 파싱 헬퍼
// ─────────────────────────────────────────────────────────────

/** 섹션 1 표에서 특정 항목 값 추출 */
function extractTableValue(content, key) {
  // | 한국어 이름 | 목 뒤쪽 근막 이완 |
  const regex = new RegExp(`\\|\\s*${key}\\s*\\|\\s*([^|\\n]+)`, 'i');
  const match = content.match(regex);
  return match ? match[1].trim() : null;
}

/** [x] 체크된 태그만 추출 */
function extractCheckedTags(content, sectionHeader) {
  // 섹션 헤더 이후 구간에서 [x] 라인 파싱
  const sectionRegex = new RegExp(`###\\s*${sectionHeader}[\\s\\S]*?(?=###|##|$)`, 'i');
  const sectionMatch = content.match(sectionRegex);
  if (!sectionMatch) return [];

  const block = sectionMatch[0];
  const tags = [];
  const lineRegex = /- \[x\]\s+(\S+)\s+/gi;
  let m;
  while ((m = lineRegex.exec(block)) !== null) {
    const tag = m[1].replace(/—.*/, '').trim();
    if (tag && !tag.startsWith('-')) tags.push(tag);
  }
  return tags;
}

/** 섹션 4 "단계별 시술" 번호 목록 → JSONB 배열 */
function extractTechniqueSteps(content) {
  // "단계별 시술:" 이후 번호 목록 파싱
  const sectionMatch = content.match(/\*\*단계별 시술[^*]*\*\*[:\s]*([\s\S]*?)(?=\*\*1회 세션|##\s|$)/i)
    || content.match(/\*단계별 시술[^*]*\*[:\s]*([\s\S]*?)(?=\*\*1회 세션|##\s|$)/i);
  if (!sectionMatch) return [];

  const block = sectionMatch[1];
  const steps = [];
  // 1. **(준비 단계):** ... 또는 1. ...
  const stepRegex = /^\d+\.\s+(?:\*\*[^*]+\*\*:?\s*)?(.+)$/gm;
  let m;
  while ((m = stepRegex.exec(block)) !== null) {
    const instruction = m[1]
      .replace(/\*\*/g, '')
      .replace(/\*/g, '')
      .trim();
    if (instruction) {
      steps.push({ step: steps.length + 1, instruction });
    }
  }
  return steps;
}

/** 준비 단계에서 자세/접촉/방향 정보 파싱 */
function extractPreparationField(content, fieldLabel) {
  // "- 환자 자세:" 패턴
  const regex = new RegExp(`-\\s*${fieldLabel}[:\\s]+([^\\n-]+)`, 'i');
  const match = content.match(regex);
  return match ? match[1].trim() : null;
}

/** 섹션 5 임상 결과 섹션에서 특정 소제목 텍스트 추출 */
function extractClinicalSection(content, headerKey) {
  const regex = new RegExp(`###\\s*${headerKey}[^\\n]*\\n([\\s\\S]*?)(?=###|##|$)`, 'i');
  const match = content.match(regex);
  if (!match) return null;
  return match[1]
    .replace(/\|[^\n]*\n/g, '') // 표 제거
    .replace(/\|-+\|[^\n]*\n/g, '')
    .replace(/^\s*[-*]\s*/gm, '')
    .replace(/\*\*/g, '')
    .split('\n')
    .map(l => l.trim())
    .filter(Boolean)
    .join(' | ');
}

/** 핵심 임상 팁, 좋은 반응, 흔한 실수를 합쳐서 clinical_notes 생성 */
function buildClinicalNotes(content) {
  const tips  = extractClinicalSection(content, '핵심 임상 팁');
  const good  = extractClinicalSection(content, '좋은 반응');
  const mistakes = extractClinicalSection(content, '흔한 실수');

  const parts = [];
  if (tips)     parts.push(`핵심 팁: ${tips}`);
  if (good)     parts.push(`좋은 반응: ${good}`);
  if (mistakes) parts.push(`흔한 실수: ${mistakes}`);
  return parts.join(' || ') || null;
}

/** 절대/상대 금기 텍스트 추출 */
function extractContraindications(content, type) {
  // "절대 금기:" 또는 "상대 금기:" 이후 텍스트
  const regex = new RegExp(`\\*\\*${type}[^*]*\\*\\*[:\\s]*([\\s\\S]*?)(?=\\*\\*|###|##|$)`, 'i');
  const match = content.match(regex);
  if (!match) return null;

  const block = match[1];
  // 체크박스 라인에서 레이블 추출
  const items = [];
  const lineRegex = /- \[[x ]\]\s+(?:\w+)\s+—\s+([^\n]+)/gi;
  let m;
  while ((m = lineRegex.exec(block)) !== null) {
    items.push(m[1].trim());
  }
  // 기타 텍스트 항목
  const etcMatch = block.match(/기타[^:]*:\s*([^\n]+)/i);
  if (etcMatch) items.push(etcMatch[1].trim());

  return items.length > 0 ? items.join(', ') : null;
}

// ─────────────────────────────────────────────────────────────
// SQL 이스케이프
// ─────────────────────────────────────────────────────────────
function sqlStr(val) {
  if (val === null || val === undefined) return 'NULL';
  return `'${String(val).replace(/'/g, "''")}'`;
}

function sqlArray(arr) {
  if (!arr || arr.length === 0) return "'{}'";
  const items = arr.map(v => v.replace(/'/g, "''"));
  return `ARRAY[${items.map(v => `'${v}'`).join(', ')}]`;
}

function sqlJsonb(obj) {
  if (!obj || (Array.isArray(obj) && obj.length === 0)) return 'NULL';
  return `'${JSON.stringify(obj).replace(/'/g, "''")}'::jsonb`;
}

// ─────────────────────────────────────────────────────────────
// MD → 레코드 객체 변환
// ─────────────────────────────────────────────────────────────
function parseMdFile(filePath, subcategory) {
  const content = fs.readFileSync(filePath, 'utf-8');

  const nameKo       = extractTableValue(content, '한국어 이름');
  const nameEn       = extractTableValue(content, '영문 이름');
  const abbreviation = extractTableValue(content, '약어');
  const rawRegion    = extractTableValue(content, '해당 부위');
  const bodySegment  = extractTableValue(content, '세부 분절');
  const rawEvidence  = extractTableValue(content, '근거 수준 \\(evidence_level\\)')
                    || extractTableValue(content, '근거 수준');

  const bodyRegion = resolveBodyRegion(rawRegion);

  // evidence_level: "level_4" 형식으로 추출
  let evidenceLevel = 'level_5';
  if (rawEvidence) {
    const evMatch = rawEvidence.match(/level_\w+|insufficient/i);
    if (evMatch) evidenceLevel = evMatch[0].toLowerCase();
  }

  // 태그
  const purposeTags         = extractCheckedTags(content, '2-1\\. 치료 목적 태그.*');
  const targetTagsRaw       = extractCheckedTags(content, '2-2\\. 대상 환자 태그.*');
  const symptomTagsRaw      = extractCheckedTags(content, '2-3\\. 증상 태그.*');
  const contraindicationTags = extractCheckedTags(content, '2-4\\. 금기증 태그.*');

  // hypomobile은 스키마에 없는 태그 — 제거
  const targetTags  = targetTagsRaw.filter(t => !['hypomobile'].includes(t));
  const symptomTags = symptomTagsRaw.filter(t => !['movement_pain', 'radicular_pain', 'rest_pain'].includes(t)
    ? true
    : ['movement_pain'].includes(t)  // movement_pain은 허용 (스키마 외이지만 TEXT[] 자유 값)
  );

  // technique_steps
  const steps = extractTechniqueSteps(content);

  // 준비 단계 필드
  const patientPosition   = extractPreparationField(content, '환자 자세');
  const therapistPosition = extractPreparationField(content, '치료사 자세');
  const contactPoint      = extractPreparationField(content, '접촉 부위.*\\(치료사\\)')
                          || extractPreparationField(content, '접촉 부위');
  const direction         = extractPreparationField(content, '힘 방향');

  // clinical_notes
  const clinicalNotes = buildClinicalNotes(content);

  // 금기 텍스트
  const absoluteContra = extractContraindications(content, '절대 금기');
  const relativeContra = extractContraindications(content, '상대 금기');

  return {
    nameKo,
    nameEn,
    abbreviation,
    bodyRegion,
    bodySegment,
    subcategory,
    purposeTags,
    targetTags,
    symptomTags,
    contraindicationTags,
    evidenceLevel,
    steps,
    patientPosition,
    therapistPosition,
    contactPoint,
    direction,
    clinicalNotes,
    absoluteContra,
    relativeContra,
    filePath,
  };
}

// ─────────────────────────────────────────────────────────────
// 레코드 → SQL INSERT 문
// ─────────────────────────────────────────────────────────────
function recordToSql(rec, categoryKey) {
  const stepsJsonb = rec.steps.length > 0 ? sqlJsonb(rec.steps) : 'NULL';

  return `INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = ${sqlStr(categoryKey)}),
  ${sqlStr(rec.subcategory)},
  ${sqlStr(rec.nameKo)}, ${sqlStr(rec.nameEn)}, ${sqlStr(rec.abbreviation)},
  ${rec.bodyRegion ? sqlStr(rec.bodyRegion) : 'NULL'}::body_region, ${sqlStr(rec.bodySegment)},
  ${sqlStr(rec.patientPosition)}, ${sqlStr(rec.therapistPosition)},
  ${sqlStr(rec.contactPoint)}, ${sqlStr(rec.direction)},
  ${stepsJsonb},
  ${sqlArray(rec.purposeTags)}, ${sqlArray(rec.targetTags)},
  ${sqlArray(rec.symptomTags)}, ${sqlArray(rec.contraindicationTags)},
  ${sqlStr(rec.evidenceLevel)}::evidence_level,
  ${sqlStr(rec.clinicalNotes)},
  ${sqlStr(rec.absoluteContra)}, ${sqlStr(rec.relativeContra)},
  true, true
)
ON CONFLICT (abbreviation) DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();`;
}

// ─────────────────────────────────────────────────────────────
// 카테고리 INSERT SQL
// ─────────────────────────────────────────────────────────────
function buildCategoryInsert(categoryKey) {
  return `INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active)
VALUES (
  ${sqlStr(categoryKey)},
  '연부조직 기법',
  'Soft Tissue Techniques',
  'MFR / IASTM 기반 접근법',
  '[
    {"icon":"🤲","title_ko":"부드럽고 지속적인 압력","desc_ko":"강한 힘이 아닌 부드럽고 지속적인 압력으로 근막과 연부조직을 이완합니다. 탄성 끝(elastic barrier)을 찾아 조직이 반응할 때까지 기다립니다."},
    {"icon":"⏱️","title_ko":"충분한 시간 투자","desc_ko":"근막 이완은 최소 90초~2분 이상 기다려야 시작됩니다. 빠르게 움직이면 조직이 반응할 시간이 없습니다."},
    {"icon":"🔍","title_ko":"이완 신호 인식","desc_ko":"치료사 손 아래에서 조직이 따뜻해지거나 부드러워지는 느낌이 이완 반응의 신호입니다."},
    {"icon":"🛠️","title_ko":"IASTM 도구 각도와 방향","desc_ko":"30~45° 각도로 피부에 대고 일정한 속도로 쓸어내립니다. 반드시 오일을 바른 후 시행합니다."},
    {"icon":"🚫","title_ko":"절대 금기 준수","desc_ko":"골절, DVT, 악성 종양, 개방성 상처에는 절대 시행하지 않습니다. 경추 기법 시 VBI 위험 사전 확인 필수."}
  ]'::jsonb,
  3,
  true
)
ON CONFLICT (category_key) DO NOTHING;`;
}

// ─────────────────────────────────────────────────────────────
// 파일 탐색: input 디렉토리에서 techniques/ 하위 MD 파일 수집
// subcategory는 부모 폴더명 (MFR, IASTM 등)
// ─────────────────────────────────────────────────────────────
function collectMdFiles(inputDir) {
  const results = [];
  const inputAbs = path.resolve(inputDir);

  if (!fs.existsSync(inputAbs)) {
    console.error(`[ERROR] 입력 디렉토리가 없습니다: ${inputAbs}`);
    process.exit(1);
  }

  let topDirs = fs.readdirSync(inputAbs, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .map(d => d.name);

  // --subcategory 필터 적용
  if (SUBCATEGORY_FILTER) {
    topDirs = topDirs.filter(d => SUBCATEGORY_FILTER.includes(d));
    console.log(`   서브카테고리 필터: ${SUBCATEGORY_FILTER.join(', ')} → ${topDirs.length}개 디렉토리`);
  }

  for (const subcat of topDirs) {
    const techDir = path.join(inputAbs, subcat, 'techniques');
    if (!fs.existsSync(techDir)) continue;

    const files = fs.readdirSync(techDir)
      .filter(f => f.endsWith('.md'))
      .map(f => ({ filePath: path.join(techDir, f), subcategory: subcat }));

    results.push(...files);
  }

  return results;
}

// ─────────────────────────────────────────────────────────────
// 파싱 결과 유효성 기본 검사 (경고만 출력)
// ─────────────────────────────────────────────────────────────
function warnIfInvalid(rec) {
  const warnings = [];
  if (!rec.nameKo)     warnings.push('name_ko 없음');
  if (!rec.nameEn)     warnings.push('name_en 없음');
  if (!rec.bodyRegion) warnings.push(`body_region 매핑 실패 (원본: 파일 내 "해당 부위" 값 확인 필요)`);
  if (rec.steps.length === 0) warnings.push('technique_steps 파싱 실패 (0 단계)');
  if (warnings.length > 0) {
    console.warn(`  [WARN] ${path.basename(rec.filePath)}: ${warnings.join(', ')}`);
  }
}

// ─────────────────────────────────────────────────────────────
// 메인
// ─────────────────────────────────────────────────────────────
function main() {
  console.log(`\n🔍 parse-techniques.js 시작`);
  console.log(`   입력: ${INPUT_DIR}`);
  console.log(`   카테고리: ${CATEGORY_KEY}`);
  console.log(`   마이그레이션 번호: ${MIGRATION_NUM}`);
  console.log(`   출력: ${OUTPUT_DIR}\n`);

  const files = collectMdFiles(INPUT_DIR);
  if (files.length === 0) {
    console.error('[ERROR] techniques/ 폴더에서 MD 파일을 찾지 못했습니다.');
    process.exit(1);
  }

  console.log(`📂 발견된 MD 파일: ${files.length}개`);

  const records = [];
  const bySubcat = {};

  for (const { filePath, subcategory } of files) {
    process.stdout.write(`  파싱 중: ${path.basename(filePath)} [${subcategory}]... `);
    try {
      const rec = parseMdFile(filePath, subcategory);
      warnIfInvalid(rec);
      records.push(rec);
      bySubcat[subcategory] = (bySubcat[subcategory] || 0) + 1;
      console.log('OK');
    } catch (err) {
      console.log(`실패 — ${err.message}`);
    }
  }

  // SQL 생성
  const now = new Date().toISOString().slice(0, 10);
  const migrationNumPadded = String(MIGRATION_NUM).padStart(3, '0');
  const outputFile = path.resolve(path.join(OUTPUT_DIR, `${migrationNumPadded}-soft-tissue-techniques.sql`));

  // 소계 문자열
  const subcatSummary = Object.entries(bySubcat).map(([k, v]) => `${k} ${v}개`).join(', ');

  const lines = [];

  // 헤더
  lines.push(`-- ============================================================`);
  lines.push(`-- K-Movement Optimism — Migration ${migrationNumPadded}`);
  lines.push(`-- 연부조직 기법 (${subcatSummary}) ${records.length}개`);
  lines.push(`-- 자동 생성: parse-techniques.js`);
  lines.push(`-- 생성일: ${now}`);
  lines.push(`-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql`);
  lines.push(`-- ============================================================`);
  lines.push('');

  // STEP 1: ENUM 확장
  lines.push(`-- STEP 1: ENUM 확장`);
  lines.push(`ALTER TYPE technique_category ADD VALUE IF NOT EXISTS '${CATEGORY_KEY}';`);
  lines.push('');

  // STEP 2: 카테고리
  lines.push(`-- STEP 2: 카테고리 INSERT (이미 있으면 스킵)`);
  lines.push(buildCategoryInsert(CATEGORY_KEY));
  lines.push('');

  // STEP 3: 테크닉 INSERT — subcategory 별로 묶어서 출력
  lines.push(`-- STEP 3: 테크닉 INSERT (${records.length}개)`);
  lines.push('');

  const subcats = [...new Set(records.map(r => r.subcategory))];
  for (const sub of subcats) {
    const group = records.filter(r => r.subcategory === sub);
    lines.push(`-- ────────────────────────────────`);
    lines.push(`-- ${sub} 기법 ${group.length}개`);
    lines.push(`-- ────────────────────────────────`);
    lines.push('');
    for (let i = 0; i < group.length; i++) {
      const rec = group[i];
      lines.push(`-- ${sub}-${String(i + 1).padStart(2, '0')}: ${rec.nameKo || path.basename(rec.filePath)}`);
      lines.push(recordToSql(rec, CATEGORY_KEY));
      lines.push('');
    }
  }

  // 출력 디렉토리 생성
  fs.mkdirSync(path.dirname(outputFile), { recursive: true });
  fs.writeFileSync(outputFile, lines.join('\n'), 'utf-8');

  console.log(`\n✅ SQL 생성 완료`);
  console.log(`   출력 파일: ${outputFile}`);
  console.log(`   총 레코드: ${records.length}개 (${subcatSummary})`);
  console.log(`\n다음 단계: node "pt-prescription/saas/scripts/validate-sql.js" "${outputFile}"`);
}

main();
