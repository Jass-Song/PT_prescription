-- Migration 054: 단일 신호 모델 — outcome 단일화 + 가중치 70/20/10 재배분
-- ============================================================
-- 배경 (대표님 결정 2026-05-06):
--   임상 현장에서 "정확성(indication_accuracy)" 과 "효과(outcome)" 는 분리
--   측정이 어렵다. "환자가 좋아졌으면 그게 정답" — outcome 자체가 두 신호를
--   모두 포함한다. 별점(star_rating)은 의미 모호 (만족도 vs 효과) → 1차 신호
--   에서 제거. adverse 는 별도 페널티 신호로 활용.
--
--   단일 핵심 신호 = ratings.outcome (rating_outcome ENUM 6 분류)
--     excellent / good / moderate / poor / no_effect / adverse
--
-- 변경 요약:
--   1. ratings.star_rating NOT NULL 제거 (CHECK 1~5 OR NULL 유지) + DEPRECATED COMMENT
--   2. fn_refresh_technique_stats() 가중치 공식 70/20/10 재작성
--        - excellent+good 비율    × 0.70  (outcome ratio, 분모 = outcome NOT NULL)
--        - 최근 30일 활성도        × 0.20  (LEAST(count_30d, 20)/20)
--        - (1 - adverse 비율)     × 0.10  (adverse penalty)
--        outcome 데이터 0 → COALESCE 0.5 (중립; 050b 의 0.7 대비 보수적)
--   3. avg_star_rating, avg_indication_accuracy 컬럼은 보존 (역사 데이터)
--      그러나 함수에서 더 이상 UPDATE 하지 않음 — 컬럼 자체는 schema 유지.
--      (반대로 trigger 함수가 NULL 로 덮어쓰지 않도록, 본 마이그 함수는 두
--       컬럼을 INSERT/UPDATE 절에서 제외.)
--   4. 기존 technique_stats.recommendation_weight 새 공식으로 일괄 재계산.
--   5. 함수 시그니처: RETURNS TRIGGER, LANGUAGE plpgsql, SECURITY DEFINER,
--      SET search_path = public — 050b 와 동일. 트리거 자체는 050 등록분
--      유지 (CREATE OR REPLACE FUNCTION 만으로 즉시 반영).
--
-- 의존:
--   - migration 049 (ratings.outcome, indication_accuracy, was_ai_recommended)
--   - migration 050 (technique_stats 컬럼 + trg_refresh_stats_on_rating 트리거)
--   - migration 050b (SECURITY DEFINER 패턴)
--
-- 멱등:
--   - ALTER COLUMN DROP NOT NULL — Postgres 는 이미 NOT NULL 아닐 때 no-op 안 됨.
--     pg_attribute 검사 후 DO 블록에서 가드.
--   - CREATE OR REPLACE FUNCTION — 재실행 안전.
--   - UPDATE technique_stats — 멱등 (동일 입력에 동일 결과).
--   - COMMENT — 항상 덮어쓰기.
-- ============================================================


-- ----------------------------------------------------------------
-- 1. ratings.star_rating NOT NULL 제거 (멱등)
-- ----------------------------------------------------------------

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM   information_schema.columns
    WHERE  table_schema = 'public'
      AND  table_name   = 'ratings'
      AND  column_name  = 'star_rating'
      AND  is_nullable  = 'NO'
  ) THEN
    EXECUTE 'ALTER TABLE public.ratings ALTER COLUMN star_rating DROP NOT NULL';
  END IF;
END $$;

-- CHECK 제약 (1~5)은 유지. 본 마이그 이전 상태에서 CHECK 절은 BETWEEN 1 AND 5.
-- BETWEEN 은 NULL 입력 시 NULL (UNKNOWN) → CHECK 통과 — 별도 변경 불필요.

COMMENT ON COLUMN public.ratings.star_rating IS
  'DEPRECATED 2026-05-06 (마이그 054). 단일 신호 모델로 전환 — outcome 6분류로 대체. NULL 허용. 신규 INSERT는 NULL 권장. 역사 데이터 조회용으로 컬럼 보존.';

COMMENT ON COLUMN public.ratings.indication_accuracy IS
  'DEPRECATED 2026-05-06 (마이그 054). outcome 으로 통합. 본 컬럼은 역사 데이터 보존 목적. 신규 INSERT NULL 권장.';

COMMENT ON COLUMN public.ratings.outcome IS
  '단일 핵심 신호 (마이그 054). rating_outcome ENUM 6분류. NULL 허용 (기존 데이터 호환) 이나 신규 INSERT 시 필수 권장. AI 추천 가중치의 70%(excellent+good 비율) + 10%(adverse 페널티) 차지.';


-- ----------------------------------------------------------------
-- 2. fn_refresh_technique_stats() — 가중치 공식 70/20/10 재작성
-- ----------------------------------------------------------------
-- 새 공식:
--   outcome_NOT_NULL_count = COUNT(*) FILTER (WHERE outcome IS NOT NULL)
--   weight =
--     CLAMP(
--         (excellent_count + good_count) / NULLIF(outcome_NOT_NULL_count, 0)  × 0.70
--       + (LEAST(recent_30d_count, 20) / 20.0)                                × 0.20
--       + (1 - (adverse_count / NULLIF(outcome_NOT_NULL_count, 0)))            × 0.10
--     , 0.0, 1.0)
--   outcome 0건 → COALESCE 로 outcome ratio 0.5, adverse penalty 1.0 처리:
--     - excellent+good 비율 분모 NULL → COALESCE(..., 0.5)
--     - adverse 비율 분모 NULL → COALESCE(adverse_ratio, 0.0) → (1 - 0.0) = 1.0
--     기본값: 0.5*0.7 + activity*0.2 + 1.0*0.1 = 0.45 + activity*0.2
--     activity 0 → 0.45 (중립). 050b 의 0.7~0.5 대비 보수적.
--
-- avg_star_rating / avg_indication_accuracy 는 INSERT/UPDATE 절에서 제외
-- (DEFAULT 0 유지 또는 기존 값 유지 — 트리거가 더 이상 갱신하지 않음).
--

CREATE OR REPLACE FUNCTION fn_refresh_technique_stats()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tech_id UUID;
BEGIN
  -- INSERT/UPDATE: NEW.technique_id, DELETE: OLD.technique_id
  v_tech_id := COALESCE(NEW.technique_id, OLD.technique_id);

  -- ratings.technique_id NULL (Anatomy Trains/LLM 의역) 케이스 스킵
  IF v_tech_id IS NULL THEN
    RETURN NULL;
  END IF;

  INSERT INTO technique_stats (
    technique_id,
    total_ratings,
    excellent_count,
    good_count,
    moderate_count,
    poor_count,
    no_effect_count,
    adverse_count,
    ai_recommended_count,
    recent_30d_avg_rating,
    recommendation_weight,
    updated_at
  )
  SELECT
    v_tech_id,
    COUNT(*),
    COUNT(*) FILTER (WHERE outcome = 'excellent'),
    COUNT(*) FILTER (WHERE outcome = 'good'),
    COUNT(*) FILTER (WHERE outcome = 'moderate'),
    COUNT(*) FILTER (WHERE outcome = 'poor'),
    COUNT(*) FILTER (WHERE outcome = 'no_effect'),
    COUNT(*) FILTER (WHERE outcome = 'adverse'),
    COUNT(*) FILTER (WHERE was_ai_recommended = true),
    -- recent_30d_avg_rating: star_rating 이 NULL 이면 AVG 가 NULL 반환 — 기존 컬럼 호환
    -- (UI/대시보드 호환 위해 컬럼은 보존, 값은 별점이 들어온 경우에만 집계)
    ROUND(AVG(star_rating) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'
                                     AND star_rating IS NOT NULL), 2),
    -- 가중치 공식 (054):
    --   outcome ratio (70%) + 활성도 (20%) + adverse penalty (10%)
    --   outcome 0건 시 COALESCE 로 중립값 → 약 0.45
    ROUND(
      LEAST(1.0, GREATEST(0.0,
        (COALESCE(
          COUNT(*) FILTER (WHERE outcome IN ('excellent','good'))::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL), 0),
          0.5
        ) * 0.70) +
        (LEAST(COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 20) / 20.0 * 0.20) +
        ((1.0 - COALESCE(
          COUNT(*) FILTER (WHERE outcome = 'adverse')::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL), 0),
          0.0
        )) * 0.10)
      ))::NUMERIC,
    4),
    NOW()
  FROM ratings
  WHERE technique_id = v_tech_id
  ON CONFLICT (technique_id) DO UPDATE SET
    total_ratings           = EXCLUDED.total_ratings,
    excellent_count         = EXCLUDED.excellent_count,
    good_count              = EXCLUDED.good_count,
    moderate_count          = EXCLUDED.moderate_count,
    poor_count              = EXCLUDED.poor_count,
    no_effect_count         = EXCLUDED.no_effect_count,
    adverse_count           = EXCLUDED.adverse_count,
    ai_recommended_count    = EXCLUDED.ai_recommended_count,
    recent_30d_avg_rating   = EXCLUDED.recent_30d_avg_rating,
    recommendation_weight   = EXCLUDED.recommendation_weight,
    updated_at              = NOW();
    -- avg_star_rating / avg_indication_accuracy 는 명시적으로 SET 절에서 제외 →
    -- 기존 row 의 역사 값 보존, 신규 row 는 컬럼 DEFAULT 0 으로 INSERT 됨.

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION fn_refresh_technique_stats() IS
  '054 단일 신호 모델: outcome 70% + 활성도 20% + adverse penalty 10%. SECURITY DEFINER 로 RLS 우회. avg_star_rating/avg_indication_accuracy 컬럼은 보존하나 본 함수가 갱신하지 않음 (역사 데이터 보존).';

-- 트리거 자체는 050 에서 등록한 trg_refresh_stats_on_rating 그대로 유지.
-- CREATE OR REPLACE FUNCTION 만으로 다음 ratings INSERT/UPDATE/DELETE 부터
-- 새 공식 즉시 반영.


-- ----------------------------------------------------------------
-- 3. 기존 technique_stats.recommendation_weight 일괄 재계산
-- ----------------------------------------------------------------
-- 트리거 함수가 새 공식으로 바뀌었지만, 기존 행은 050b 공식으로 계산된 weight
-- 를 보유. 본 UPDATE 로 한 번 재집계.

UPDATE technique_stats ts
SET
  recommendation_weight = sub.new_weight,
  updated_at            = NOW()
FROM (
  SELECT
    technique_id,
    ROUND(
      LEAST(1.0, GREATEST(0.0,
        (COALESCE(
          COUNT(*) FILTER (WHERE outcome IN ('excellent','good'))::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL), 0),
          0.5
        ) * 0.70) +
        (LEAST(COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 20) / 20.0 * 0.20) +
        ((1.0 - COALESCE(
          COUNT(*) FILTER (WHERE outcome = 'adverse')::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL), 0),
          0.0
        )) * 0.10)
      ))::NUMERIC,
    4) AS new_weight
  FROM ratings
  WHERE technique_id IS NOT NULL
  GROUP BY technique_id
) sub
WHERE ts.technique_id = sub.technique_id;

-- ratings 자체가 0건인 기법은 위 UPDATE 가 영향 주지 않음 → DEFAULT 0.5 유지.


-- ----------------------------------------------------------------
-- 4. 검증 쿼리 (참고; 정규 검증은 saas/scripts/verify-054.sql)
-- ----------------------------------------------------------------
-- SELECT is_nullable FROM information_schema.columns
--   WHERE table_name = 'ratings' AND column_name = 'star_rating';
-- 기대: YES
--
-- SELECT proname, prosecdef FROM pg_proc WHERE proname = 'fn_refresh_technique_stats';
-- 기대: prosecdef = true
--
-- SELECT MIN(recommendation_weight), MAX(recommendation_weight),
--        AVG(recommendation_weight) FROM technique_stats;
-- 기대: 0.0 ≤ MIN, MAX ≤ 1.0
