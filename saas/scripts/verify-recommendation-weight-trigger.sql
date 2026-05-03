-- ============================================================
-- C-4 검증 — recommendation_weight 트리거 동작 확인
-- ============================================================
-- 목적:
--   migration 049 (ratings.outcome / indication_accuracy 컬럼) +
--   migration 050 (fn_refresh_technique_stats / trg_refresh_stats_on_rating)
--   적용 후, 트리거가 ratings INSERT 마다 technique_stats 를 자동 갱신하는지
--   end-to-end 로 검증한다.
--
-- 실행 방법:
--   1. https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql/new 접속
--   2. 본 파일 전체 복사 → 붙여넣기 → Run
--   3. Results 패널 + Messages 패널 양쪽 확인
--
-- 안전성:
--   Section 3 의 INSERT 는 BEGIN ... ROLLBACK 으로 감싸져 production 데이터 영향 없음.
--   service_role (대시보드 SQL 에디터 기본) 컨텍스트에서 RLS 우회.
-- ============================================================


-- ============================================================
-- Section 1. 스키마 확인
-- ============================================================

-- 1-1. ratings 의 신규 컬럼 (049 적용 확인)
SELECT
  '1-1. ratings columns (049)' AS check_name,
  column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'ratings'
  AND column_name IN ('outcome', 'indication_accuracy', 'was_ai_recommended', 'star_rating')
ORDER BY column_name;
-- 기대: outcome (USER-DEFINED rating_outcome), indication_accuracy (smallint), was_ai_recommended (boolean), star_rating (smallint or integer)

-- 1-2. technique_stats 의 핵심 컬럼 (050 적용 확인)
SELECT
  '1-2. technique_stats columns (050)' AS check_name,
  column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'technique_stats'
  AND column_name IN ('recommendation_weight', 'total_ratings', 'avg_star_rating',
                      'excellent_count', 'good_count', 'avg_indication_accuracy',
                      'ai_recommended_count', 'updated_at')
ORDER BY column_name;


-- ============================================================
-- Section 2. 함수 / 트리거 등록 확인
-- ============================================================

-- 2-1. 트리거 함수 존재
SELECT
  '2-1. function exists' AS check_name,
  proname AS function_name,
  pg_get_function_identity_arguments(oid) AS args
FROM pg_proc
WHERE proname = 'fn_refresh_technique_stats';
-- 기대: 1 행

-- 2-2. ratings 에 등록된 트리거
SELECT
  '2-2. trigger on ratings' AS check_name,
  trigger_name, event_manipulation, action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'public' AND event_object_table = 'ratings'
  AND trigger_name = 'trg_refresh_stats_on_rating'
ORDER BY event_manipulation;
-- 기대: 3 행 (INSERT, UPDATE, DELETE 각각)


-- ============================================================
-- Section 3. End-to-End 동작 테스트 (BEGIN ... ROLLBACK)
-- ============================================================

BEGIN;

DO $$
DECLARE
  v_user_id           UUID;
  v_tech_id           UUID;
  v_tech_label        TEXT;
  v_baseline_weight   NUMERIC(5,4);
  v_baseline_total    INT;
  v_baseline_excellent INT;
  v_after5_weight     NUMERIC(5,4);
  v_after5_total      INT;
  v_after5_excellent  INT;
  v_after1_weight     NUMERIC(5,4);
  v_after1_adverse    INT;
BEGIN
  -- (a) 테스트 대상 선택
  SELECT id INTO v_user_id FROM auth.users ORDER BY created_at LIMIT 1;
  IF v_user_id IS NULL THEN
    RAISE NOTICE '[SKIP] auth.users 비어있음 — E2E 테스트 불가';
    RETURN;
  END IF;

  SELECT t.id, t.name_ko
    INTO v_tech_id, v_tech_label
  FROM techniques t
  WHERE t.is_published = true AND t.is_active = true
  ORDER BY t.created_at
  LIMIT 1;

  IF v_tech_id IS NULL THEN
    RAISE NOTICE '[SKIP] published 기법 없음 — E2E 테스트 불가';
    RETURN;
  END IF;

  RAISE NOTICE '── 테스트 대상 ──';
  RAISE NOTICE '  user_id      = %', v_user_id;
  RAISE NOTICE '  technique_id = % (%)', v_tech_id, v_tech_label;

  -- (b) baseline (technique_stats 행 없으면 NULL — 새 기법은 0 부터 시작)
  SELECT recommendation_weight, total_ratings, excellent_count
    INTO v_baseline_weight, v_baseline_total, v_baseline_excellent
  FROM technique_stats
  WHERE technique_id = v_tech_id;

  RAISE NOTICE '── Baseline (트리거 발화 전) ──';
  RAISE NOTICE '  recommendation_weight = %', v_baseline_weight;
  RAISE NOTICE '  total_ratings         = %', v_baseline_total;
  RAISE NOTICE '  excellent_count       = %', v_baseline_excellent;

  -- (c) 5★ + outcome=excellent + accuracy=5 INSERT
  INSERT INTO ratings (
    user_id, technique_id,
    star_rating, outcome, indication_accuracy, was_ai_recommended
  ) VALUES (
    v_user_id, v_tech_id,
    5, 'excellent', 5, true
  );

  SELECT recommendation_weight, total_ratings, excellent_count
    INTO v_after5_weight, v_after5_total, v_after5_excellent
  FROM technique_stats
  WHERE technique_id = v_tech_id;

  RAISE NOTICE '── After 5★ + excellent + accuracy=5 INSERT ──';
  RAISE NOTICE '  recommendation_weight = %', v_after5_weight;
  RAISE NOTICE '  total_ratings         = %', v_after5_total;
  RAISE NOTICE '  excellent_count       = %', v_after5_excellent;

  IF v_after5_total = COALESCE(v_baseline_total, 0) THEN
    RAISE WARNING '⚠️  total_ratings 변동 없음 → 트리거 발화 실패 의심';
  ELSE
    RAISE NOTICE '✅ total_ratings 증가: % → %', COALESCE(v_baseline_total,0), v_after5_total;
  END IF;

  IF v_after5_excellent = COALESCE(v_baseline_excellent, 0) THEN
    RAISE WARNING '⚠️  excellent_count 증가 없음 → outcome 컬럼 인식 실패 의심';
  ELSE
    RAISE NOTICE '✅ excellent_count 증가: % → %', COALESCE(v_baseline_excellent,0), v_after5_excellent;
  END IF;

  IF v_after5_weight IS NULL THEN
    RAISE WARNING '⚠️  recommendation_weight NULL → 트리거 미발화 또는 함수 오류';
  ELSIF v_baseline_weight IS NOT NULL AND v_after5_weight = v_baseline_weight THEN
    RAISE WARNING '⚠️  recommendation_weight 변동 없음 → 공식이 별점에 둔감';
  ELSE
    RAISE NOTICE '✅ recommendation_weight: % → %', v_baseline_weight, v_after5_weight;
  END IF;

  -- (d) 1★ + outcome=adverse + accuracy=1 INSERT — 가중치 감소 검증
  INSERT INTO ratings (
    user_id, technique_id,
    star_rating, outcome, indication_accuracy, was_ai_recommended
  ) VALUES (
    v_user_id, v_tech_id,
    1, 'adverse', 1, false
  );

  SELECT recommendation_weight, adverse_count
    INTO v_after1_weight, v_after1_adverse
  FROM technique_stats
  WHERE technique_id = v_tech_id;

  RAISE NOTICE '── After 1★ + adverse + accuracy=1 INSERT ──';
  RAISE NOTICE '  recommendation_weight = %', v_after1_weight;
  RAISE NOTICE '  adverse_count         = %', v_after1_adverse;

  IF v_after1_weight >= v_after5_weight THEN
    RAISE WARNING '⚠️  1★+adverse 후 가중치 감소 안 함 (% >= %) — 공식 점검 필요',
      v_after1_weight, v_after5_weight;
  ELSE
    RAISE NOTICE '✅ recommendation_weight 감소 확인: % → %', v_after5_weight, v_after1_weight;
  END IF;

  RAISE NOTICE '════════════════════════════════════════';
  RAISE NOTICE '검증 결과 요약';
  RAISE NOTICE '  baseline → +5★/excellent → +1★/adverse';
  RAISE NOTICE '  weight: % → % → %', v_baseline_weight, v_after5_weight, v_after1_weight;
  RAISE NOTICE '  total : % → % → %',
    COALESCE(v_baseline_total,0), v_after5_total, v_after5_total + 1;
  RAISE NOTICE '════════════════════════════════════════';
END $$;

ROLLBACK;


-- ============================================================
-- Section 4. ROLLBACK 검증 (테스트 데이터 잔여 0 확인)
-- ============================================================
SELECT
  '4. residual rows' AS check_name,
  COUNT(*) AS leftover_count
FROM ratings r
JOIN auth.users u ON r.user_id = u.id
WHERE r.created_at > NOW() - INTERVAL '5 minutes'
  AND r.outcome IN ('excellent', 'adverse')
  AND r.was_ai_recommended IN (true, false);
-- 기대: 0 (ROLLBACK 으로 모든 테스트 INSERT 제거)
