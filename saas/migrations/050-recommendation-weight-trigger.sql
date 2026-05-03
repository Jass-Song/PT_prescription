-- Migration 050: technique_stats 보강 + recommendation_weight 자동 갱신 트리거 (C-4)
-- ============================================================
-- 배경:
--   schema.sql 마스터에 정의된 fn_refresh_technique_stats() 함수와
--   trg_refresh_stats_on_rating 트리거가 production Supabase 에 미적용.
--   Notion 5/2 데일리 리포트에서 "컬럼 있음, 자동 갱신 트리거 없음" 으로 확인.
--   본 마이그레이션은 트리거 함수와 트리거를 새로 등록하고 technique_stats
--   테이블에 누락 컬럼이 있으면 채운다.
--
-- 가중치 공식:
--   recommendation_weight =
--       (avg_star_rating / 5)               × 0.20  -- 별점
--     + (avg_indication_accuracy / 5)       × 0.30  -- 적응증 정확도
--     + (MIN(recent_30d_uses, 20) / 20)     × 0.20  -- 최근 30일 활성도 (별도 트리거)
--     + ((excellent + good 비율))           × 0.30  -- 효과 분류
--   범위 0.0000 - 1.0000.
--
-- 의존: migration 049 (ratings.outcome, indication_accuracy, was_ai_recommended)
-- 멱등: ADD COLUMN IF NOT EXISTS, CREATE OR REPLACE FUNCTION,
--        DROP TRIGGER IF EXISTS — 재실행 안전.
-- ============================================================

-- 1. technique_stats 누락 컬럼 채우기 (production 에 일부만 있을 가능성 대비)
ALTER TABLE technique_stats
  ADD COLUMN IF NOT EXISTS total_ratings           INT     DEFAULT 0,
  ADD COLUMN IF NOT EXISTS avg_star_rating         NUMERIC(3,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS excellent_count         INT     DEFAULT 0,
  ADD COLUMN IF NOT EXISTS good_count              INT     DEFAULT 0,
  ADD COLUMN IF NOT EXISTS moderate_count          INT     DEFAULT 0,
  ADD COLUMN IF NOT EXISTS poor_count              INT     DEFAULT 0,
  ADD COLUMN IF NOT EXISTS no_effect_count         INT     DEFAULT 0,
  ADD COLUMN IF NOT EXISTS adverse_count           INT     DEFAULT 0,
  ADD COLUMN IF NOT EXISTS ai_recommended_count    INT     DEFAULT 0,
  ADD COLUMN IF NOT EXISTS avg_indication_accuracy NUMERIC(3,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS recent_30d_avg_rating   NUMERIC(3,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS updated_at              TIMESTAMPTZ DEFAULT NOW();

-- 2. recommendation_weight 갱신 함수
--    ratings 의 INSERT/UPDATE/DELETE 마다 해당 technique_id 의 통계를 재집계.
--    UPSERT 패턴: 행이 없으면 생성, 있으면 갱신.
CREATE OR REPLACE FUNCTION fn_refresh_technique_stats()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_tech_id UUID;
BEGIN
  -- INSERT/UPDATE: NEW.technique_id, DELETE: OLD.technique_id
  v_tech_id := COALESCE(NEW.technique_id, OLD.technique_id);

  -- ratings 가 technique_id NULL 인 케이스 (Anatomy Trains/LLM 의역) 는 스킵
  IF v_tech_id IS NULL THEN
    RETURN NULL;
  END IF;

  INSERT INTO technique_stats (
    technique_id,
    total_ratings,
    avg_star_rating,
    excellent_count,
    good_count,
    moderate_count,
    poor_count,
    no_effect_count,
    adverse_count,
    ai_recommended_count,
    avg_indication_accuracy,
    recent_30d_avg_rating,
    recommendation_weight,
    updated_at
  )
  SELECT
    v_tech_id,
    COUNT(*),
    ROUND(AVG(star_rating), 2),
    COUNT(*) FILTER (WHERE outcome = 'excellent'),
    COUNT(*) FILTER (WHERE outcome = 'good'),
    COUNT(*) FILTER (WHERE outcome = 'moderate'),
    COUNT(*) FILTER (WHERE outcome = 'poor'),
    COUNT(*) FILTER (WHERE outcome = 'no_effect'),
    COUNT(*) FILTER (WHERE outcome = 'adverse'),
    COUNT(*) FILTER (WHERE was_ai_recommended = true),
    ROUND(AVG(indication_accuracy) FILTER (WHERE indication_accuracy IS NOT NULL), 2),
    ROUND(AVG(star_rating) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 2),
    -- 가중치: 별점(20) + 적응증 정확도(30, NULL → 디폴트 3) + 최근 30일 활성도(20) + 효과 분류(30)
    ROUND(
      LEAST(1.0, GREATEST(0.0,
        (AVG(star_rating) / 5.0 * 0.20) +
        (COALESCE(AVG(indication_accuracy) FILTER (WHERE indication_accuracy IS NOT NULL), 3) / 5.0 * 0.30) +
        (LEAST(COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 20) / 20.0 * 0.20) +
        ((COUNT(*) FILTER (WHERE outcome IN ('excellent','good'))::FLOAT / NULLIF(COUNT(*), 0)) * 0.30)
      ))::NUMERIC,
    4),
    NOW()
  FROM ratings
  WHERE technique_id = v_tech_id
  ON CONFLICT (technique_id) DO UPDATE SET
    total_ratings           = EXCLUDED.total_ratings,
    avg_star_rating         = EXCLUDED.avg_star_rating,
    excellent_count         = EXCLUDED.excellent_count,
    good_count              = EXCLUDED.good_count,
    moderate_count          = EXCLUDED.moderate_count,
    poor_count              = EXCLUDED.poor_count,
    no_effect_count         = EXCLUDED.no_effect_count,
    adverse_count           = EXCLUDED.adverse_count,
    ai_recommended_count    = EXCLUDED.ai_recommended_count,
    avg_indication_accuracy = EXCLUDED.avg_indication_accuracy,
    recent_30d_avg_rating   = EXCLUDED.recent_30d_avg_rating,
    recommendation_weight   = EXCLUDED.recommendation_weight,
    updated_at              = NOW();

  RETURN NULL;
END;
$$;

-- 3. 트리거 등록 (재실행 안전)
DROP TRIGGER IF EXISTS trg_refresh_stats_on_rating ON ratings;
CREATE TRIGGER trg_refresh_stats_on_rating
  AFTER INSERT OR UPDATE OR DELETE ON ratings
  FOR EACH ROW EXECUTE FUNCTION fn_refresh_technique_stats();

COMMENT ON FUNCTION fn_refresh_technique_stats() IS
  'ratings INSERT/UPDATE/DELETE 시 technique_stats 행을 UPSERT. 가중치 4 컴포넌트(별점 20% / 적응증 30% / 30일 활성 20% / 효과 분류 30%) 합성.';
COMMENT ON TRIGGER trg_refresh_stats_on_rating ON ratings IS
  'C-4: recommendation_weight 자동 갱신. migration 050 에서 등록.';

-- 4. 기존 ratings 데이터 백필
--    트리거는 신규 INSERT/UPDATE/DELETE 부터 발화 → 기존 ratings 의 통계는 별도 1회 계산 필요.
--    트리거 함수 본체와 동일한 SELECT 를 사용해 기법별 통계 직접 UPSERT.
INSERT INTO technique_stats (
  technique_id, total_ratings, avg_star_rating,
  excellent_count, good_count, moderate_count, poor_count, no_effect_count, adverse_count,
  ai_recommended_count, avg_indication_accuracy, recent_30d_avg_rating,
  recommendation_weight, updated_at
)
SELECT
  technique_id,
  COUNT(*),
  ROUND(AVG(star_rating), 2),
  COUNT(*) FILTER (WHERE outcome = 'excellent'),
  COUNT(*) FILTER (WHERE outcome = 'good'),
  COUNT(*) FILTER (WHERE outcome = 'moderate'),
  COUNT(*) FILTER (WHERE outcome = 'poor'),
  COUNT(*) FILTER (WHERE outcome = 'no_effect'),
  COUNT(*) FILTER (WHERE outcome = 'adverse'),
  COUNT(*) FILTER (WHERE was_ai_recommended = true),
  ROUND(AVG(indication_accuracy) FILTER (WHERE indication_accuracy IS NOT NULL), 2),
  ROUND(AVG(star_rating) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 2),
  ROUND(
    LEAST(1.0, GREATEST(0.0,
      (AVG(star_rating) / 5.0 * 0.20) +
      (COALESCE(AVG(indication_accuracy) FILTER (WHERE indication_accuracy IS NOT NULL), 3) / 5.0 * 0.30) +
      (LEAST(COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 20) / 20.0 * 0.20) +
      ((COUNT(*) FILTER (WHERE outcome IN ('excellent','good'))::FLOAT / NULLIF(COUNT(*), 0)) * 0.30)
    ))::NUMERIC,
  4),
  NOW()
FROM ratings
WHERE technique_id IS NOT NULL
GROUP BY technique_id
ON CONFLICT (technique_id) DO UPDATE SET
  total_ratings           = EXCLUDED.total_ratings,
  avg_star_rating         = EXCLUDED.avg_star_rating,
  excellent_count         = EXCLUDED.excellent_count,
  good_count              = EXCLUDED.good_count,
  moderate_count          = EXCLUDED.moderate_count,
  poor_count              = EXCLUDED.poor_count,
  no_effect_count         = EXCLUDED.no_effect_count,
  adverse_count           = EXCLUDED.adverse_count,
  ai_recommended_count    = EXCLUDED.ai_recommended_count,
  avg_indication_accuracy = EXCLUDED.avg_indication_accuracy,
  recent_30d_avg_rating   = EXCLUDED.recent_30d_avg_rating,
  recommendation_weight   = EXCLUDED.recommendation_weight,
  updated_at              = NOW();

-- 5. 검증 쿼리
-- SELECT proname FROM pg_proc WHERE proname = 'fn_refresh_technique_stats';
-- SELECT trigger_name, event_manipulation FROM information_schema.triggers
-- WHERE event_object_table = 'ratings';
