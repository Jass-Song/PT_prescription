'use strict';
// generate-seed-sql.js
// seed_techniques.json → seed.sql (Supabase techniques 테이블 INSERT)
// 생성 대상 컬럼: schema.sql 기준 (id는 uuid_generate_v4() 자동 생성)

const fs   = require('fs');
const path = require('path');

// ── 헬퍼 함수 ──────────────────────────────────────────────────

/** 단순 문자열 SQL 이스케이프 (작은따옴표 이중화) */
function escStr(val) {
  if (val === null || val === undefined) return 'NULL';
  return `'${String(val).replace(/'/g, "''")}'`;
}

/** TEXT[] 배열 변환 */
function escArr(arr) {
  if (!arr || !Array.isArray(arr) || arr.length === 0) return "'{}'";
  const items = arr.map(s => `"${String(s).replace(/"/g, '""')}"`).join(',');
  return `'{${items}}'`;
}

/** JSONB 변환 */
function escJson(obj) {
  if (obj === null || obj === undefined) return 'NULL';
  return `'${JSON.stringify(obj).replace(/'/g, "''")}'::jsonb`;
}

/** Boolean */
function escBool(val) {
  return val ? 'true' : 'false';
}

// ── 데이터 로드 ────────────────────────────────────────────────

const jsonPath = path.join(__dirname, 'seed_techniques.json');
const raw      = fs.readFileSync(jsonPath, 'utf8');
const parsed   = JSON.parse(raw);

// 배열 직접이거나 { techniques: [...] } 래핑 둘 다 대응
const techniques = Array.isArray(parsed) ? parsed : (parsed.techniques || []);

if (techniques.length === 0) {
  console.error('오류: 테크닉 데이터가 없습니다.');
  process.exit(1);
}

// ── SQL 생성 ───────────────────────────────────────────────────

const header = `-- ============================================================
-- KMO 도수치료 테크닉 Seed Data
-- 원본: seed_techniques.json
-- 생성일: ${new Date().toISOString()}
-- 총 ${techniques.length}개 테크닉
-- 대상 테이블: techniques (schema.sql 기준)
-- 주의: id 컬럼은 uuid_generate_v4() 자동 생성
-- ============================================================

-- 기존 데이터 초기화 (technique_stats 등 cascade 포함)
TRUNCATE TABLE techniques RESTART IDENTITY CASCADE;

`;

const rows = techniques.map((t, idx) => {
  // JSON 필드 → DB 컬럼 매핑
  // id (JSON 문자열 식별자) → abbreviation 에 반영하거나 별도 보존
  // JSON에 abbreviation 필드가 있으면 그것을 우선, 없으면 JSON id 사용
  const abbreviation = t.abbreviation || t.id || null;

  // subcategory: JSON에 없으므로 category로 유추
  // category_a → Maitland / category_b → Mulligan
  let subcategory = null;
  if (t.category === 'category_a_joint_mobilization') {
    subcategory = 'Maitland';
  } else if (t.category === 'category_b_mulligan') {
    subcategory = 'Mulligan';
  }

  // body_region: JSON의 body_region 필드 사용 (enum 값과 일치해야 함)
  const bodyRegion = t.body_region || null;

  // contraindication_tags: JSON의 contraindication_tags 배열
  const contraindTags = t.contraindication_tags || [];

  // recommendation_weight: 초기값 0.7 고정 (운영 중 자동 산출)
  const recWeight = 0.7;

  return `-- [${idx + 1}/${techniques.length}] ${t.name_ko} (${t.id})
INSERT INTO techniques (
  name_ko,
  name_en,
  abbreviation,
  category,
  subcategory,
  body_region,
  body_segment,
  is_bilateral,
  description,
  technique_steps,
  patient_position,
  therapist_position,
  contact_point,
  direction,
  purpose_tags,
  target_tags,
  symptom_tags,
  contraindication_tags,
  evidence_level,
  key_references,
  clinical_notes,
  absolute_contraindications,
  relative_contraindications,
  is_active,
  is_published
) VALUES (
  ${escStr(t.name_ko)},
  ${escStr(t.name_en)},
  ${escStr(abbreviation)},
  ${escStr(t.category)}::technique_category,
  ${escStr(subcategory)},
  ${escStr(bodyRegion)}::body_region,
  ${escStr(t.body_segment)},
  false,
  ${escStr(t.description)},
  ${escJson(t.technique_steps)},
  ${escStr(t.patient_position)},
  ${escStr(t.therapist_position)},
  ${escStr(t.contact_point)},
  ${escStr(t.direction)},
  ${escArr(t.purpose_tags)},
  ${escArr(t.target_tags)},
  ${escArr(t.symptom_tags)},
  ${escArr(contraindTags)},
  ${escStr(t.evidence_level)}::evidence_level,
  ${escJson(t.key_references)},
  ${escStr(t.clinical_notes)},
  ${escStr(t.absolute_contraindications)},
  ${escStr(t.relative_contraindications)},
  ${escBool(t.is_active !== false)},
  ${escBool(t.is_published === true)}
);
`;
}).join('\n');

const footer = `
-- ============================================================
-- technique_stats 초기 레코드 생성 (모든 테크닉에 대해)
-- recommendation_weight 초기값 0.7
-- ============================================================
INSERT INTO technique_stats (technique_id, recommendation_weight)
SELECT id, 0.7 FROM techniques
ON CONFLICT (technique_id) DO NOTHING;

-- ============================================================
-- END OF SEED
-- ============================================================
`;

const sql = header + rows + footer;

// ── 파일 저장 ──────────────────────────────────────────────────

const outPath = path.join(__dirname, 'seed.sql');
fs.writeFileSync(outPath, sql, 'utf8');

const lineCount = sql.split('\n').length;
console.log(`seed.sql 생성 완료`);
console.log(`  - 테크닉 수: ${techniques.length}개`);
console.log(`  - 총 줄 수: ${lineCount}줄`);
console.log(`  - 파일 경로: ${outPath}`);
