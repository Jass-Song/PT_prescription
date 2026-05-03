-- ============================================================
-- Migration 004b — 카테고리 테이블 재구조화
-- K-Movement Optimism — Category Hierarchy Restructure
-- 생성일: 2026-04-25
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- ⚠️  실행 순서 필수:
--     1단계: 004a-restructure-enum.sql 먼저 실행 (ENUM 확장 커밋)
--     2단계: 이 파일 실행 (카테고리 테이블 재구조화)
-- ============================================================

-- ============================================================
-- STEP 1: technique_categories에 parent_key 컬럼 추가
-- ============================================================

ALTER TABLE technique_categories
  ADD COLUMN IF NOT EXISTS parent_key TEXT REFERENCES technique_categories(category_key);

-- ============================================================
-- STEP 2: 상위 그룹(parent) 4개 INSERT
-- UI 메뉴 구조용 — techniques에 직접 연결되지 않음
-- ============================================================

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active)
VALUES
  ('group_joint_mobilization', '관절가동술',     'Joint Mobilization',         '수기치료 관절 접근법',             '[]'::jsonb, 1, true),
  ('group_soft_tissue',        '연부조직 가동술', 'Soft Tissue Mobilization',   'IASTM · MFR 기반 접근법',          '[]'::jsonb, 2, true),
  ('group_exercise',           '운동처방',        'Exercise Prescription',      '근거기반 운동치료 프로토콜',         '[]'::jsonb, 3, true),
  ('group_neural',             '신경가동술',      'Neural Mobilization',        '신경조직 슬라이더·텐셔너 기법',     '[]'::jsonb, 4, true)
ON CONFLICT (category_key) DO NOTHING;

-- ============================================================
-- STEP 3: 기존 카테고리 category_key 업데이트 + parent_key 설정
-- 주의: techniques.category_id는 UUID FK이므로 key 변경 영향 없음
--       parent_key TEXT FK는 위 group INSERT 완료 후 설정 가능
-- ============================================================

-- category_a_joint_mobilization → category_joint_mobilization
UPDATE technique_categories
SET category_key  = 'category_joint_mobilization',
    name_ko       = '관절가동술',
    name_en       = 'Joint Mobilization — Maitland',
    subtitle_ko   = 'Maitland Concept 기반 관절가동술',
    parent_key    = 'group_joint_mobilization',
    sort_order    = 1,
    updated_at    = NOW()
WHERE category_key = 'category_a_joint_mobilization';

-- category_b_mulligan → category_mulligan
UPDATE technique_categories
SET category_key  = 'category_mulligan',
    name_ko       = 'Mulligan Concept',
    name_en       = 'Mulligan Concept',
    subtitle_ko   = 'MWM / SNAG / NAG 기반 접근법',
    parent_key    = 'group_joint_mobilization',
    sort_order    = 2,
    updated_at    = NOW()
WHERE category_key = 'category_b_mulligan';

-- category_e_soft_tissue → category_iastm (기존 행 재활용)
UPDATE technique_categories
SET category_key  = 'category_iastm',
    name_ko       = 'IASTM',
    name_en       = 'IASTM — Instrument-Assisted Soft Tissue Mobilization',
    subtitle_ko   = '도구 이용 연부조직 가동술',
    parent_key    = 'group_soft_tissue',
    sort_order    = 1,
    updated_at    = NOW()
WHERE category_key = 'category_e_soft_tissue';

-- ============================================================
-- STEP 4: MFR 신규 카테고리 INSERT
-- category_e_soft_tissue를 category_iastm으로 변경했으므로
-- MFR은 별도 신규 행으로 생성
-- ============================================================

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_mfr',
  'MFR',
  'MFR — Myofascial Release',
  '근막 이완 기법',
  '[
    {"icon":"🤲","title_ko":"부드럽고 지속적인 압력","desc_ko":"강한 힘이 아닌 부드럽고 지속적인 압력으로 근막과 연부조직을 이완합니다. 탄성 끝(elastic barrier)을 찾아 조직이 반응할 때까지 기다립니다."},
    {"icon":"⏱️","title_ko":"충분한 시간 투자","desc_ko":"근막 이완은 최소 90초~2분 이상 기다려야 시작됩니다. 빠르게 움직이면 조직이 반응할 시간이 없습니다."},
    {"icon":"🔍","title_ko":"이완 신호 인식","desc_ko":"치료사 손 아래에서 조직이 따뜻해지거나 부드러워지는 느낌이 이완 반응의 신호입니다."},
    {"icon":"🔄","title_ko":"양방향 탐색","desc_ko":"한 방향 이완 후 반대 방향으로도 시도하여 조직 가동성을 최대화합니다."},
    {"icon":"🚫","title_ko":"절대 금기 준수","desc_ko":"골절, DVT, 악성 종양, 개방성 상처에는 절대 시행하지 않습니다."}
  ]'::jsonb,
  2,
  true,
  'group_soft_tissue'
)
ON CONFLICT (category_key) DO NOTHING;

-- ============================================================
-- STEP 5: 003에서 추가된 카테고리들 parent_key 설정
-- category_c_exercise 또는 category_exercise01 존재 시 적용
-- category_d_neural은 003에서 생성됨
-- ============================================================

UPDATE technique_categories
SET parent_key = 'group_exercise',
    updated_at = NOW()
WHERE category_key IN ('category_c_exercise', 'category_exercise01');

UPDATE technique_categories
SET parent_key = 'group_neural',
    updated_at = NOW()
WHERE category_key = 'category_d_neural';
