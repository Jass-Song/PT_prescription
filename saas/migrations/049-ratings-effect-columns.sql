-- Migration 049: ratings 효과 평가 컬럼 추가 (C-3 DB 절반)
-- ============================================================
-- 배경:
--   migration 041 의 ratings 테이블은 star_rating 만 보유.
--   schema.sql 마스터에는 outcome / indication_accuracy / was_ai_recommended
--   컬럼이 정의돼 있고, C-4 의 fn_refresh_technique_stats 트리거 함수가 이들을
--   참조한다. 본 마이그레이션은 production ratings 테이블을 schema.sql 의 핵심
--   필드로 업그레이드해 C-3 효과 평가 UI 와 C-4 가중치 계산을 가능하게 한다.
--
-- 의존: migration 041 (ratings 테이블 자체)
-- 후속: migration 050 (트리거 함수가 본 컬럼들을 참조)
-- 멱등: 모든 DDL 이 IF NOT EXISTS / DO block 패턴 — 재실행 안전.
-- ============================================================

-- 1. rating_outcome ENUM (PostgreSQL CREATE TYPE 은 IF NOT EXISTS 미지원 → DO block)
DO $$ BEGIN
  CREATE TYPE rating_outcome AS ENUM (
    'excellent',    -- 매우 효과적
    'good',         -- 효과적
    'moderate',     -- 보통
    'poor',         -- 효과 미미
    'no_effect',    -- 효과 없음
    'adverse'       -- 부작용 발생
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 2. ratings 테이블에 효과 평가 컬럼 추가
ALTER TABLE ratings
  ADD COLUMN IF NOT EXISTS outcome             rating_outcome,
  ADD COLUMN IF NOT EXISTS indication_accuracy SMALLINT
    CHECK (indication_accuracy IS NULL OR indication_accuracy BETWEEN 1 AND 5),
  ADD COLUMN IF NOT EXISTS was_ai_recommended  BOOLEAN DEFAULT false;

COMMENT ON COLUMN ratings.outcome IS
  '효과 분류 ENUM. C-3 UI 에서 사용자가 선택. NULL 허용 (기존 데이터 호환).';
COMMENT ON COLUMN ratings.indication_accuracy IS
  '적응증 적합도 1-5. AI 추천 품질 피드백 핵심. NULL 허용 (기존 데이터 호환).';
COMMENT ON COLUMN ratings.was_ai_recommended IS
  'AI 추천으로 사용했는지 여부. C-4 가중치 계산 시 ai_recommended_count 집계.';

-- 3. 검증 쿼리 (실행 후 SELECT 로 확인)
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'ratings'
-- ORDER BY ordinal_position;
