-- ============================================================
-- Migration 045 — applicable_muscles 1차 백필 (Starter)
-- 배경: 044에서 컬럼 추가 후 가시 가능한 기법들에 한해 단일 근육 정보 1차 백필.
-- 범위: 경추 28개(디버그 응답 기준) + 마이그레이션 038 신규 기법 11개.
-- 미포함: 그 외 region(요추/어깨/무릎/엉덩/발목)의 muscle-targeted 기법 ~200개.
-- 후속: sw-clinical-translator가 카테고리×region별 다부위 enrichment 진행.
-- 안전성: 모든 UPDATE는 abbreviation 매칭 — 미존재 시 0 row affected (no-op).
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 경추 (cervical) — Muscle-targeted 기법
-- ────────────────────────────────────────────────────────────

-- Trigger Point
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"상부 승모근","muscle_en":"upper trapezius"}]'::jsonb
  WHERE abbreviation = 'UT-TrP';
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"후두하 근육군","muscle_en":"suboccipital muscles"}]'::jsonb
  WHERE abbreviation = 'SubOcc-TrP';
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"마름근","muscle_en":"rhomboids"}]'::jsonb
  WHERE abbreviation = 'RH-TrP';
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"흉쇄유돌근","muscle_en":"sternocleidomastoid"}]'::jsonb
  WHERE abbreviation = 'SCM-TrP';

-- ART (능동적 이완)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"두판상근","muscle_en":"splenius capitis"},{"muscle_ko":"경판상근","muscle_en":"splenius cervicis"}]'::jsonb
  WHERE abbreviation = 'ART-Splenius';
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"사각근","muscle_en":"scalenes"}]'::jsonb
  WHERE abbreviation = 'ART-Scalenes';

-- MFR (근막 이완)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"사각근","muscle_en":"scalenes"}]'::jsonb
  WHERE abbreviation = 'MFR-Scalenes';
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"견갑거근","muscle_en":"levator scapulae"}]'::jsonb
  WHERE abbreviation = 'MFR-LevScap';
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"후두하 근육군","muscle_en":"suboccipital muscles"}]'::jsonb
  WHERE abbreviation = 'Suboccipital MFR';
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"승모근","muscle_en":"trapezius"},{"muscle_ko":"두판상근","muscle_en":"splenius capitis"},{"muscle_ko":"척추기립근","muscle_en":"erector spinae"}]'::jsonb
  WHERE abbreviation = 'Neck Posterior MFR';
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"흉추 척추기립근","muscle_en":"thoracic erector spinae"},{"muscle_ko":"승모근","muscle_en":"trapezius"}]'::jsonb
  WHERE abbreviation = 'Thoracic MFR';

-- CTM (결합조직 마사지)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"후두하 근육군","muscle_en":"suboccipital muscles"}]'::jsonb
  WHERE abbreviation = 'CTM-NO';

-- SCS (Counterstrain — 압통점, 근육 다중 가능)
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"후두하 근육군","muscle_en":"suboccipital muscles"},{"muscle_ko":"승모근","muscle_en":"trapezius"}]'::jsonb
  WHERE abbreviation = 'CP SCS';
UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"흉쇄유돌근","muscle_en":"sternocleidomastoid"},{"muscle_ko":"사각근","muscle_en":"scalenes"}]'::jsonb
  WHERE abbreviation = 'CA SCS';

-- ────────────────────────────────────────────────────────────
-- 마이그레이션 038 신규 기법 — PNE 4 + 경추 관절가동 4 + Mulligan 3
-- 모두 비-근육 표적 (교육/관절/Mulligan) → 빈 배열 유지
-- ────────────────────────────────────────────────────────────
-- 명시: PNE/Maitland/Mulligan은 근육 표적이 아니므로 applicable_muscles = []
-- (column DEFAULT '[]' 이므로 별도 UPDATE 불필요, 주석으로 의도 기록)

-- ────────────────────────────────────────────────────────────
-- 후속 백필 가이드 (sw-clinical-translator)
-- ────────────────────────────────────────────────────────────
-- 1. region별 muscle-targeted 카테고리: ART, MFR, CTM, deep_friction, trigger_point
-- 2. 각 행에 단일 근육이 아닌 임상적으로 관련된 다부위까지 포함
--    예: LumbART-ES → [{척추세움근}, {장요근(연관)}, {요방형근(연관)}]
-- 3. 비-근육 카테고리는 빈 배열 유지: joint_mobilization, mulligan, mdt, scs(분절적), pne, d_neural
--    (단, SCS는 압통점 기반이라 근육 정보 추가 가능)
--
-- 검증 쿼리:
--   SELECT category, body_region,
--          COUNT(*) AS total,
--          SUM(CASE WHEN applicable_muscles = '[]'::jsonb THEN 1 ELSE 0 END) AS empty
--   FROM techniques
--   WHERE category IN ('category_art','category_mfr','category_ctm','category_trigger_point','category_deep_friction')
--   GROUP BY category, body_region
--   ORDER BY empty DESC;
