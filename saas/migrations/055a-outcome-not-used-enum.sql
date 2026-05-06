-- ============================================================
-- 055a — outcome rating_outcome ENUM 'not_used' 값 추가
-- ============================================================
-- PostgreSQL 제약: ALTER TYPE ADD VALUE 결과는 같은 트랜잭션에서 사용 불가.
-- 반드시 commit 후 별도 트랜잭션에서 'not_used' 참조 가능.
-- 본 파일은 ENUM 변경 단독 — 055b 적용 전에 반드시 먼저 실행.
--
-- 운영 절차 (production):
--   1) 본 파일 (055a) 단독 실행 → commit 확인.
--   2) 새 쿼리 창에서 055b 실행.
--   3) 새 쿼리 창에서 verify-055.sql 실행.
--
--   같은 트랜잭션·같은 쿼리 창에서 055a + 055b 함께 실행 시 PG 55P04
--   `unsafe use of new enum value` 에러 발생. 반드시 분리.
--
-- 멱등:
--   - ALTER TYPE ADD VALUE IF NOT EXISTS — PG 12+ 멱등 (재실행 안전).
--
-- 의존:
--   - migration 054 (단일 신호 모델, rating_outcome 6 값 정의 완료).
-- ============================================================


-- ----------------------------------------------------------------
-- 1. rating_outcome ENUM 에 'not_used' 추가 (멱등)
-- ----------------------------------------------------------------
-- DO 블록 + EXCEPTION duplicate_object 가드는 PG 일부 버전 호환성 보강.
-- PG 12+ 에서는 IF NOT EXISTS 단독으로 충분하나, 안전 차원.

DO $$ BEGIN
  ALTER TYPE rating_outcome ADD VALUE IF NOT EXISTS 'not_used';
EXCEPTION WHEN duplicate_object THEN null; END $$;

COMMENT ON TYPE rating_outcome IS
  '055 단일 신호 모델 (7 분류): excellent / good / moderate / poor / no_effect / adverse / not_used. not_used 는 PT 가 추천을 받았으나 미시술. weight 산식에서 effectiveness 분모/분자 제외 (영향 0). 활성도 카운트에는 포함.';


-- ----------------------------------------------------------------
-- 2. 검증 — 7 값 확인 (정보성 NOTICE)
-- ----------------------------------------------------------------
-- 본 검증은 같은 세션에서 실행 가능 (pg_enum 메타조회는 새 값 비교가
-- 아니라 카운트만 보므로 55P04 미발생).

DO $$
DECLARE
  v_count INT;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM pg_enum
  WHERE enumtypid = 'rating_outcome'::regtype;
  RAISE NOTICE 'rating_outcome enum value count: % (기대: 7)', v_count;
END $$;
