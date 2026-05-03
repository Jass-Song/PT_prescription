-- Migration 049c: ratings 테이블에 feedback.js 가 보내는 누락 컬럼 6개 추가
-- ============================================================
-- 발견 경위:
--   PR #31 + #34 머지 후 production 에서 별점 저장 시 PostgREST 가
--   "Could not find the 'acuity' column of 'ratings' in the schema cache"
--   400 에러 반환 → /api/feedback 502 응답.
--
-- 원인 분석:
--   production 의 ratings 테이블이 migration 041 정의 (region/acuity/symptom/
--   technique_label/category_key/notes 포함) 가 아니라, schema.sql 정의 (위 6개
--   컬럼 부재) 와 일치. PR #30 머지 시점에 schema.sql 이 적용됐거나 migration 041
--   이 production 에 안 깔린 채로 운영돼 왔던 것으로 추정.
--
-- 해결:
--   feedback.js (api/feedback.js) 가 보내는 13개 필드 중 빠진 6개를 ADD COLUMN.
--   schema.sql 의 patient_profile / clinical_context / application_notes /
--   response_notes 등은 미래 확장용으로 유지하고, MVP 운영용 단순 필드를 보강.
--
-- 의존: ratings 테이블 존재 (당연히)
-- 멱등: ADD COLUMN IF NOT EXISTS — 이미 있는 컬럼 무영향, 재실행 안전.
-- ============================================================

ALTER TABLE ratings
  ADD COLUMN IF NOT EXISTS technique_label TEXT,
  ADD COLUMN IF NOT EXISTS category_key    TEXT,
  ADD COLUMN IF NOT EXISTS region          TEXT,
  ADD COLUMN IF NOT EXISTS acuity          TEXT,
  ADD COLUMN IF NOT EXISTS symptom         TEXT,
  ADD COLUMN IF NOT EXISTS notes           TEXT;

COMMENT ON COLUMN ratings.technique_label IS
  'feedback.js fallback 표기 (techniques 행 없는 Anatomy Trains·LLM 의역 케이스용 + 분석 슬라이스용 denorm)';
COMMENT ON COLUMN ratings.region IS
  'denormalized 환자 부위 (분석용: 부위별 평점 분포)';
COMMENT ON COLUMN ratings.acuity IS
  'denormalized 시기 — 급성/아급성/만성';
COMMENT ON COLUMN ratings.symptom IS
  'denormalized 증상 — 움직임 통증/안정 통증/방사통';

-- PostgREST 스키마 캐시 즉시 새로고침 (안 하면 재시도까지 약 60초 캐시 만료 대기)
NOTIFY pgrst, 'reload schema';

-- 검증 쿼리 (실행 후 6행 모두 추가됐는지 확인)
-- SELECT column_name FROM information_schema.columns
-- WHERE table_schema='public' AND table_name='ratings'
--   AND column_name IN ('technique_label','category_key','region','acuity','symptom','notes')
-- ORDER BY column_name;
-- 기대: 6행
