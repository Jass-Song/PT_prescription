-- Migration 050b: 050 트리거 함수 hotfix (출시 전 BLOCKER 2개 + SHOULD-FIX 1개 해결)
-- ============================================================
-- 발견 경위:
--   PR #31 머지 직후 정적 QA 리뷰에서 출시 차단 이슈 2건 발견.
--   본 마이그레이션은 050 의 fn_refresh_technique_stats 함수를 CREATE OR REPLACE
--   로 덮어쓴다. 트리거 자체는 050 에서 등록된 것 그대로 유지.
--
-- 수정 내용:
--   1. (BLOCKER) SECURITY DEFINER + SET search_path = public 추가
--      → 트리거가 호출자 컨텍스트에서 실행되면 RLS (ratings_select_own) 로 인해
--        다른 사용자 ratings 가 집계 대상에서 제외됐음. SECURITY DEFINER 로 함수
--        소유자 (postgres super-user) 권한으로 실행 → RLS 우회. technique_stats
--        INSERT 도 동일하게 우회 가능.
--   2. (SHOULD-FIX) outcome 비율 분모를 outcome IS NOT NULL 인 행으로 한정
--      → outcome 을 안 채우고 별점만 보낸 사용자가 가중치를 0 으로 처지지 않게.
--        모든 outcome 이 NULL 이면 분자/분모 모두 0 → COALESCE 로 0.5 (중립) 처리.
--   3. (NIT) DELETE 로 마지막 평가 사라질 때 weight = NULL 되는 케이스는 그대로 둠
--      (해당 기법은 시드 가중치 0.7 또는 새 평가가 들어올 때까지 NULL).
--
-- 멱등: CREATE OR REPLACE FUNCTION 단독. 050 의 ALTER TABLE / 트리거 / 백필 INSERT
--       는 재실행 불필요.
-- ============================================================

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
    -- 가중치 공식 (050b 수정):
    --   별점(20) + 적응증 정확도(30, NULL → 디폴트 3) + 최근 30일 활성도(20)
    --   + 효과 분류(30, outcome 미입력 행은 분모에서 제외, 전부 NULL 이면 중립 0.5)
    ROUND(
      LEAST(1.0, GREATEST(0.0,
        (AVG(star_rating) / 5.0 * 0.20) +
        (COALESCE(AVG(indication_accuracy) FILTER (WHERE indication_accuracy IS NOT NULL), 3) / 5.0 * 0.30) +
        (LEAST(COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 20) / 20.0 * 0.20) +
        (COALESCE(
          COUNT(*) FILTER (WHERE outcome IN ('excellent','good'))::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL), 0),
          0.5
        ) * 0.30)
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

COMMENT ON FUNCTION fn_refresh_technique_stats() IS
  '050b hotfix: SECURITY DEFINER 로 RLS 우회 (다른 사용자 ratings 집계 가능) + outcome 비율 분모를 비-NULL 행으로 한정 (별점만 보낸 케이스 가중치 보호).';

-- 검증: 함수 시그니처 + SECURITY DEFINER 확인
-- SELECT proname, prosecdef, prolang
-- FROM pg_proc
-- WHERE proname = 'fn_refresh_technique_stats';
-- 기대: prosecdef = true (SECURITY DEFINER)
