-- ============================================================
-- 055b — technique_stats.not_used_count 컬럼 + 함수 + 일괄 재계산
-- ============================================================
-- 전제: 055a 가 이미 실행·commit 되어 rating_outcome 에 'not_used' 등록됨.
--       같은 쿼리 창에서 055a + 055b 함께 실행 시 PG 55P04 발생.
--
-- 본 파일은 'not_used' 참조를 포함:
--   1) technique_stats.not_used_count 컬럼 추가
--   2) fn_refresh_technique_stats() — outcome != 'not_used' 분모/분자 제외
--   3) technique_stats 일괄 재계산 (not_used_count 채움 + weight 갱신)
--
-- 멱등:
--   - ADD COLUMN IF NOT EXISTS — 재실행 안전.
--   - CREATE OR REPLACE FUNCTION — 재실행 안전.
--   - UPDATE technique_stats — 동일 입력에 동일 결과 (멱등).
--
-- 의존:
--   - 055a (ENUM 'not_used' 등록).
--   - 050 (technique_stats 테이블 + 트리거 fn_refresh_technique_stats 등록).
--   - 054 (단일 신호 모델 70/20/10 공식).
-- ============================================================


-- ----------------------------------------------------------------
-- 1. technique_stats.not_used_count 컬럼 추가 (멱등)
-- ----------------------------------------------------------------
-- weight 계산에 사용 안 함. 정보 추적용 (use rate, PT 신뢰도 분석).

ALTER TABLE public.technique_stats
  ADD COLUMN IF NOT EXISTS not_used_count INT DEFAULT 0;

COMMENT ON COLUMN public.technique_stats.not_used_count IS
  '055: PT 가 AI 추천을 받았으나 미시술한 케이스 누계. weight 영향 없음. use rate / 추천 채택률 분석용.';

-- 기존 row NULL 가드 (DEFAULT 0 이지만 ADD COLUMN 후 기존 row 는 0 으로
-- 자동 채워짐 — PG 11+ 부터 metadata-only 변경. 안전 차원에서 한 번 더 보정).
UPDATE public.technique_stats
SET not_used_count = 0
WHERE not_used_count IS NULL;


-- ----------------------------------------------------------------
-- 2. fn_refresh_technique_stats() — outcome != 'not_used' 필터 추가
-- ----------------------------------------------------------------
-- 054 공식 유지: outcome ratio (70%) + 활성도 (20%) + adverse penalty (10%)
-- 변경: effectiveness 분모/분자 에서 outcome != 'not_used' 명시 제외.
--      - 분자(excellent+good): 그대로 (not_used 가 들어가지 않음)
--      - 분모(outcome IS NOT NULL): outcome != 'not_used' 추가
--      - adverse 비율 분모도 동일
-- 활성도(20%) 는 모든 row 카운트 (not_used 도 활동임). recent_30d 도 동일.
-- not_used_count INSERT 절 추가 → 컬럼 채움.

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
    not_used_count,
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
    COUNT(*) FILTER (WHERE outcome = 'not_used'),
    COUNT(*) FILTER (WHERE was_ai_recommended = true),
    -- recent_30d_avg_rating: star_rating 보존 컬럼 (054 DEPRECATED)
    ROUND(AVG(star_rating) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'
                                     AND star_rating IS NOT NULL), 2),
    -- 가중치 공식 (055 = 054 공식 유지 + not_used 분모/분자 제외):
    --   outcome ratio (70%) + 활성도 (20%) + adverse penalty (10%)
    --   evaluated_count = COUNT(outcome IS NOT NULL AND outcome != 'not_used')
    --   not_used 만 들어온 기법은 evaluated 0 → COALESCE 0.5 (중립)
    ROUND(
      LEAST(1.0, GREATEST(0.0,
        (COALESCE(
          COUNT(*) FILTER (WHERE outcome IN ('excellent','good'))::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL AND outcome != 'not_used'), 0),
          0.5
        ) * 0.70) +
        (LEAST(COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 20) / 20.0 * 0.20) +
        ((1.0 - COALESCE(
          COUNT(*) FILTER (WHERE outcome = 'adverse')::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL AND outcome != 'not_used'), 0),
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
    not_used_count          = EXCLUDED.not_used_count,
    ai_recommended_count    = EXCLUDED.ai_recommended_count,
    recent_30d_avg_rating   = EXCLUDED.recent_30d_avg_rating,
    recommendation_weight   = EXCLUDED.recommendation_weight,
    updated_at              = NOW();
    -- avg_star_rating / avg_indication_accuracy 는 SET 절에서 의도적 제외
    -- (054 — 역사 데이터 보존, 본 함수 갱신 중단)

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION fn_refresh_technique_stats() IS
  '055: 054 공식 유지(outcome 70% + 활성도 20% + adverse 10%) + not_used 분모/분자 제외. SECURITY DEFINER. avg_star_rating/avg_indication_accuracy 는 보존하되 갱신 안 함. not_used_count 컬럼은 정보 추적용으로 INSERT.';


-- ----------------------------------------------------------------
-- 3. 기존 technique_stats 일괄 재계산 (not_used_count 채움 + weight 재집계)
-- ----------------------------------------------------------------
-- 기존 ratings 데이터에 not_used 없음 → weight 값 자체는 054 와 동일 결과.
-- 그러나 not_used_count 컬럼이 신설됐으므로 한 번 재집계 (모두 0 채움).
-- ratings 가 0건인 기법은 영향 없음 (DEFAULT 유지).

UPDATE technique_stats ts
SET
  not_used_count        = sub.nu,
  recommendation_weight = sub.new_weight,
  updated_at            = NOW()
FROM (
  SELECT
    technique_id,
    COUNT(*) FILTER (WHERE outcome = 'not_used') AS nu,
    ROUND(
      LEAST(1.0, GREATEST(0.0,
        (COALESCE(
          COUNT(*) FILTER (WHERE outcome IN ('excellent','good'))::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL AND outcome != 'not_used'), 0),
          0.5
        ) * 0.70) +
        (LEAST(COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 20) / 20.0 * 0.20) +
        ((1.0 - COALESCE(
          COUNT(*) FILTER (WHERE outcome = 'adverse')::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL AND outcome != 'not_used'), 0),
          0.0
        )) * 0.10)
      ))::NUMERIC,
    4) AS new_weight
  FROM ratings
  WHERE technique_id IS NOT NULL
  GROUP BY technique_id
) sub
WHERE ts.technique_id = sub.technique_id;

-- ratings.outcome COMMENT 갱신 — 054 코멘트에 'not_used' 7 번째 분류 명시
COMMENT ON COLUMN public.ratings.outcome IS
  '단일 핵심 신호 (마이그 055). rating_outcome ENUM 7분류 (054 의 6 + 055 의 not_used). NULL 허용 (기존 데이터 호환). not_used = PT 가 추천을 받았으나 미시술. effectiveness 가중치(70%)/adverse 가중치(10%) 분모/분자 제외, 활성도 가중치(20%) 에는 포함.';


-- ----------------------------------------------------------------
-- 4. 검증 쿼리 (참고; 정규 검증은 saas/scripts/verify-055.sql)
-- ----------------------------------------------------------------
-- SELECT proname, prosecdef FROM pg_proc WHERE proname = 'fn_refresh_technique_stats';
-- 기대: prosecdef = true
--
-- SELECT column_name FROM information_schema.columns
--   WHERE table_name = 'technique_stats' AND column_name = 'not_used_count';
-- 기대: 1 row
