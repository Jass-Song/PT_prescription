-- ============================================================
-- Migration 018 — 중복 기법·빈 카테고리 정리 (비활성화)
-- K-Movement Optimism / PT 처방 도우미
-- 생성일: 2026-04-27
-- 작성자: sw-db-architect
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- 목적:
--   아래 4가지 중복/불필요 항목을 is_active = false로 비활성화.
--   데이터는 삭제하지 않으며 히스토리를 보존한다.
--
--   [1] category_exercise01 — MDT (맥켄지 요추)
--         신버전: category_mdt 의 abbreviation='MDT-Lumbar'로 대체됨
--
--   [2] category_exercise01 — Cervical MDT (경추 맥켄지)
--         신버전: category_mdt 의 abbreviation='CervMDT'로 대체됨
--
--   [3] category_exercise01 — PNE (통증 신경과학 교육)
--         신버전: category_pne 의 abbreviation='PNE-Combined'로 대체됨
--
--   [4] category_d_neural — NM (신경 가동술 — 좌골신경, 구버전 abbreviation)
--         신버전: abbreviation='NM-Sciatic' 으로 대체됨
--
--   [5] technique_categories — category_f_therapeutic_exercise
--         기법 0건인 빈 카테고리 비활성화
--
-- ⚠️  재활성화 방법 (필요 시):
--     UPDATE techniques SET is_active = true, updated_at = NOW()
--     WHERE category = '<카테고리>' AND abbreviation = '<abbreviation>';
-- ============================================================

BEGIN;

-- ============================================================
-- [1] category_exercise01 — MDT (맥켄지 요추) 비활성화
-- ============================================================
-- 확인용 SELECT (실행 전 상태 점검):
-- SELECT id, name_ko, abbreviation, category, is_active
-- FROM techniques
-- WHERE category = 'category_exercise01' AND abbreviation = 'MDT';

UPDATE techniques
SET is_active  = false,
    updated_at = NOW()
WHERE category     = 'category_exercise01'
  AND abbreviation = 'MDT';

-- 확인용 SELECT (실행 후 결과 검증):
-- SELECT id, name_ko, abbreviation, is_active, updated_at
-- FROM techniques
-- WHERE category = 'category_exercise01' AND abbreviation = 'MDT';
-- 기대값: is_active = false

-- ============================================================
-- [2] category_exercise01 — Cervical MDT (경추 맥켄지) 비활성화
-- ============================================================
-- 확인용 SELECT (실행 전 상태 점검):
-- SELECT id, name_ko, abbreviation, category, is_active
-- FROM techniques
-- WHERE category = 'category_exercise01' AND abbreviation = 'Cervical MDT';

UPDATE techniques
SET is_active  = false,
    updated_at = NOW()
WHERE category     = 'category_exercise01'
  AND abbreviation = 'Cervical MDT';

-- 확인용 SELECT (실행 후 결과 검증):
-- SELECT id, name_ko, abbreviation, is_active, updated_at
-- FROM techniques
-- WHERE category = 'category_exercise01' AND abbreviation = 'Cervical MDT';
-- 기대값: is_active = false

-- ============================================================
-- [3] category_exercise01 — PNE (통증 신경과학 교육) 비활성화
-- ============================================================
-- 확인용 SELECT (실행 전 상태 점검):
-- SELECT id, name_ko, abbreviation, category, is_active
-- FROM techniques
-- WHERE category = 'category_exercise01' AND abbreviation = 'PNE';

UPDATE techniques
SET is_active  = false,
    updated_at = NOW()
WHERE category     = 'category_exercise01'
  AND abbreviation = 'PNE';

-- 확인용 SELECT (실행 후 결과 검증):
-- SELECT id, name_ko, abbreviation, is_active, updated_at
-- FROM techniques
-- WHERE category = 'category_exercise01' AND abbreviation = 'PNE';
-- 기대값: is_active = false

-- ============================================================
-- [4] category_d_neural — NM (좌골신경 가동술 구버전) 비활성화
-- ============================================================
-- 확인용 SELECT (실행 전 상태 점검):
-- SELECT id, name_ko, abbreviation, category, is_active
-- FROM techniques
-- WHERE category = 'category_d_neural' AND abbreviation = 'NM';

UPDATE techniques
SET is_active  = false,
    updated_at = NOW()
WHERE category     = 'category_d_neural'
  AND abbreviation = 'NM';

-- 확인용 SELECT (실행 후 결과 검증):
-- SELECT id, name_ko, abbreviation, is_active, updated_at
-- FROM techniques
-- WHERE category = 'category_d_neural' AND abbreviation IN ('NM', 'NM-Sciatic');
-- 기대값: NM → is_active = false / NM-Sciatic → is_active = true (변경 없음)

-- ============================================================
-- [5] technique_categories — category_f_therapeutic_exercise 비활성화
--     기법 0건인 빈 카테고리
-- ============================================================
-- 확인용 SELECT (실행 전 상태 점검):
-- SELECT category_key, name_ko, is_active
-- FROM technique_categories
-- WHERE category_key = 'category_f_therapeutic_exercise';

UPDATE technique_categories
SET is_active  = false,
    updated_at = NOW()
WHERE category_key = 'category_f_therapeutic_exercise';

-- 확인용 SELECT (실행 후 결과 검증):
-- SELECT category_key, name_ko, is_active, updated_at
-- FROM technique_categories
-- WHERE category_key = 'category_f_therapeutic_exercise';
-- 기대값: is_active = false

-- ============================================================
-- 전체 검증 쿼리 (모든 UPDATE 완료 후 아래 주석 해제하여 확인)
-- ============================================================
-- SELECT category, abbreviation, name_ko, is_active
-- FROM techniques
-- WHERE (category = 'category_exercise01' AND abbreviation IN ('MDT', 'Cervical MDT', 'PNE'))
--    OR (category = 'category_d_neural'   AND abbreviation = 'NM')
-- ORDER BY category, abbreviation;
--
-- 기대값 (4행):
--   category_d_neural    | NM           | ... | false
--   category_exercise01  | Cervical MDT | ... | false
--   category_exercise01  | MDT          | ... | false
--   category_exercise01  | PNE          | ... | false
--
-- category_exercise01 잔여 기법 (영향 없음 확인):
-- SELECT abbreviation, name_ko, is_active
-- FROM techniques
-- WHERE category = 'category_exercise01'
-- ORDER BY abbreviation;
-- 기대값: MCE, DCFT, CPR, CSE, McGill Big 3, GA 는 is_active = true 유지

COMMIT;
