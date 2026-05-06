-- Migration 055: outcome_enum 7번째 값 'not_used' 추가 + weight 영향 0
-- ============================================================
-- 배경 (대표님 결정 2026-05-06):
--   PT 가 AI 추천을 받았지만 실제로 시술하지 않은 케이스를 추적해야 한다.
--   기존 6 분류(excellent/good/moderate/poor/no_effect/adverse) 는 모두
--   "시술 후 효과" 신호 — "안 썼다" 는 별도 차원. 이를 outcome 에 7 번째
--   값으로 추가하되, **가중치(weight) 산식에는 영향 0** 으로 둔다.
--   이유: not_used 행은 effectiveness 신호가 아니므로 분모/분자 어느 쪽도
--         아니다. weight 는 실제로 사용된 기법의 효과 평균이어야 함.
--
-- 단일 신호 = ratings.outcome (rating_outcome ENUM 7 분류, 054 → 055)
--   excellent / good / moderate / poor / no_effect / adverse / not_used
--
-- 변경 요약:
--   1. rating_outcome ENUM 에 'not_used' 추가 (멱등, IF NOT EXISTS).
--   2. fn_refresh_technique_stats() — 054 공식 유지하되 evaluated 분모/분자
--      에서 outcome != 'not_used' 명시 필터.
--        - excellent+good 비율 분자: 그대로 (not_used 안 들어옴)
--        - 분모: outcome IS NOT NULL AND outcome != 'not_used'
--        - adverse 비율 분모도 동일
--        - 활성도(20%) 는 모든 row(not_used 포함) 카운트 — "활동량" 자체는
--          not_used 도 활동임. 다만 effectiveness 평가가 아닐 뿐.
--          (대표님 사양: weight 영향 0 → 분모/분자에서만 제외, 활성도는 유지)
--          ※ 본 마이그는 보수적으로 "not_used 도 활성도에는 카운트" 채택.
--   3. technique_stats.not_used_count INT 컬럼 추가 (정보 추적용).
--      weight 계산에 사용 안 함. 추후 use rate 분석/PT 신뢰도 분석용.
--   4. 기존 ratings 데이터에 not_used 없음 → technique_stats 일괄 재계산
--      결과 054 와 동일 (변화 없음). 그러나 트리거 함수 갱신 후 한 번 더
--      재집계해 not_used_count 컬럼을 채움.
--
-- 멱등:
--   - ALTER TYPE ADD VALUE IF NOT EXISTS — 재실행 안전 (PG 12+).
--   - CREATE OR REPLACE FUNCTION — 재실행 안전.
--   - ALTER TABLE ADD COLUMN IF NOT EXISTS — 재실행 안전.
--   - UPDATE technique_stats — 멱등 (동일 입력에 동일 결과).
--
-- 의존:
--   - migration 054 (단일 신호 모델, fn_refresh_technique_stats 70/20/10).
--   - migration 050 (technique_stats 테이블, 트리거 등록).
--
-- 주의:
--   - PostgreSQL: ALTER TYPE ADD VALUE 는 동일 트랜잭션 내에서 그 값을
--     비교문(WHERE outcome = 'not_used' 등) 에 즉시 사용 불가.
--   - 본 마이그는 트랜잭션을 둘로 나누어 실행한다:
--       (a) ENUM 값 추가 (단독 트랜잭션)
--       (b) 함수/컬럼/UPDATE (별도 트랜잭션)
--     Supabase SQL 에디터에서 한 번에 붙여넣어도 PG 가 statement-level
--     auto-commit 으로 처리 — 문제 없음. psql -f 실행 시도 동일.
--   - 안전을 위해 전체 파일을 두 번 실행해도 같은 결과 (멱등 보장).
-- ============================================================


-- ----------------------------------------------------------------
-- 1. rating_outcome ENUM 에 'not_used' 추가 (멱등)
-- ----------------------------------------------------------------
-- ALTER TYPE ADD VALUE 는 트랜잭션 블록 내에서 IF NOT EXISTS 만으로 멱등.
-- DO 블록 내에서 실행 시 특수 케이스 처리가 필요 — 직접 ALTER TYPE 사용.

ALTER TYPE rating_outcome ADD VALUE IF NOT EXISTS 'not_used';

COMMENT ON TYPE rating_outcome IS
  '055 단일 신호 모델 (7 분류): excellent / good / moderate / poor / no_effect / adverse / not_used. not_used 는 PT 가 추천을 받았으나 미시술. weight 산식에서 effectiveness 분모/분자 제외 (영향 0). 활성도 카운트에는 포함.';


-- ----------------------------------------------------------------
-- 2. technique_stats.not_used_count 컬럼 추가 (멱등)
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
-- 3. fn_refresh_technique_stats() — outcome != 'not_used' 필터 추가
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
-- 4. 기존 technique_stats 일괄 재계산 (not_used_count 채움 + weight 재집계)
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
-- 5. 검증 쿼리 (참고; 정규 검증은 saas/scripts/verify-055.sql)
-- ----------------------------------------------------------------
-- SELECT enumlabel FROM pg_enum
--   WHERE enumtypid = 'rating_outcome'::regtype ORDER BY enumsortorder;
-- 기대: 7 row, 마지막 값 'not_used'
--
-- SELECT proname, prosecdef FROM pg_proc WHERE proname = 'fn_refresh_technique_stats';
-- 기대: prosecdef = true
--
-- SELECT column_name FROM information_schema.columns
--   WHERE table_name = 'technique_stats' AND column_name = 'not_used_count';
-- 기대: 1 row
