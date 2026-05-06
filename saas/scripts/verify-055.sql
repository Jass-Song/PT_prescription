-- ============================================================
-- verify-055.sql
-- ============================================================
-- Purpose: 마이그 055 (outcome 7값 + not_used 가중치 영향 0) 적용 후 검증.
--          6 항목 PASS/FAIL 출력.
-- Usage  : Supabase 대시보드 SQL 에디터에 본 파일 전체 붙여넣고 Run.
--          또는 psql -h <host> -U <user> -d <db> -f saas/scripts/verify-055.sql
-- Author : sw-db-architect
-- Date   : 2026-05-06
-- ============================================================
-- 검증 항목 (총 6):
--   1. rating_outcome ENUM 7 값 + 'not_used' 포함
--   2. fn_refresh_technique_stats SECURITY DEFINER + 본문에 'not_used' 제외 패턴
--   3. technique_stats.not_used_count 컬럼 존재 (INTEGER, DEFAULT 0)
--   4. technique_stats.recommendation_weight 모두 [0.0, 1.0] 범위
--   5. (E2E) BEGIN/ROLLBACK — outcome='not_used' INSERT 시 weight 변화 없음 (영향 0)
--   6. (E2E) BEGIN/ROLLBACK — outcome='good' INSERT 시 weight 정상 갱신 (effective 증가)
-- ============================================================


-- ----------------------------------------------------------------
-- 1) rating_outcome ENUM 7 값 + 'not_used' 포함
-- ----------------------------------------------------------------

SELECT
  '1. rating_outcome ENUM 7 값 + not_used' AS check_label,
  CASE
    WHEN COUNT(*) >= 7
     AND bool_or(enumlabel = 'not_used')
     AND bool_or(enumlabel = 'excellent')
     AND bool_or(enumlabel = 'good')
     AND bool_or(enumlabel = 'moderate')
     AND bool_or(enumlabel = 'poor')
     AND bool_or(enumlabel = 'no_effect')
     AND bool_or(enumlabel = 'adverse')
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  COUNT(*)                          AS value_count,
  array_agg(enumlabel ORDER BY enumsortorder) AS enum_values
FROM   pg_enum
WHERE  enumtypid = 'rating_outcome'::regtype;
-- 기대: PASS / 7 / {excellent,good,moderate,poor,no_effect,adverse,not_used}


-- ----------------------------------------------------------------
-- 2) fn_refresh_technique_stats SECURITY DEFINER + 'not_used' 제외 패턴
-- ----------------------------------------------------------------

SELECT
  '2. fn_refresh_technique_stats — 055 본문 패턴' AS check_label,
  CASE
    WHEN function_count = 1
     AND security_definer = true
     AND has_not_used_filter = true
     AND has_not_used_count = true
     AND has_070 = true
     AND has_020 = true
     AND has_010 = true
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  function_count, security_definer,
  has_not_used_filter, has_not_used_count,
  has_070, has_020, has_010
FROM (
  SELECT
    COUNT(*)                                          AS function_count,
    bool_and(prosecdef = true)                        AS security_definer,
    bool_or(pg_get_functiondef(oid) LIKE '%outcome != ''not_used''%') AS has_not_used_filter,
    bool_or(pg_get_functiondef(oid) LIKE '%not_used_count%')          AS has_not_used_count,
    bool_or(pg_get_functiondef(oid) LIKE '%0.70%')                    AS has_070,
    bool_or(pg_get_functiondef(oid) LIKE '%0.20%')                    AS has_020,
    bool_or(pg_get_functiondef(oid) LIKE '%0.10%')                    AS has_010
  FROM pg_proc
  WHERE proname = 'fn_refresh_technique_stats'
) sub;
-- 기대: PASS / 모든 플래그 t


-- ----------------------------------------------------------------
-- 3) technique_stats.not_used_count 컬럼 존재
-- ----------------------------------------------------------------

SELECT
  '3. technique_stats.not_used_count 컬럼' AS check_label,
  CASE
    WHEN data_type = 'integer'
     AND column_default LIKE '%0%'
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  data_type, is_nullable, column_default
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'technique_stats'
  AND  column_name  = 'not_used_count';
-- 기대: PASS / integer / DEFAULT 0


-- ----------------------------------------------------------------
-- 4) technique_stats.recommendation_weight 모두 [0.0, 1.0]
-- ----------------------------------------------------------------

SELECT
  '4. recommendation_weight 범위 [0,1]' AS check_label,
  CASE
    WHEN COUNT(*) FILTER (
      WHERE recommendation_weight IS NOT NULL
        AND (recommendation_weight < 0.0 OR recommendation_weight > 1.0)
    ) = 0
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  COUNT(*)                                   AS total_rows,
  COUNT(*) FILTER (WHERE recommendation_weight IS NULL) AS null_count,
  MIN(recommendation_weight)                 AS min_weight,
  MAX(recommendation_weight)                 AS max_weight
FROM   technique_stats;
-- 기대: PASS / 0 위반


-- ----------------------------------------------------------------
-- 5) (E2E) outcome='not_used' INSERT → weight 변화 없음 (영향 0)
-- ----------------------------------------------------------------
-- BEGIN/ROLLBACK — 실제 데이터 변경 안 함.
-- 활성도(20%) recent_30d 카운트는 +1 영향 받음 → 정확히 "변화 없음" 검증을
-- 위해 비교 시점에 effective ratio 만으로 검증. 다만 활성도 가중치는
-- LEAST(count, 20)/20 * 0.20 → recent_30d 가 20 이상이면 변화 0,
-- 20 미만이면 +0.01 (1/20 * 0.20) 변화 가능.
-- 따라서 본 검증은 "effective 분자/분모 변화 0" 을 기준으로 한다:
-- not_used 행은 evaluated_count 분모에 포함되지 않아야 함.

DO $$
DECLARE
  v_user_id     UUID;
  v_tech_id     UUID;
  v_label       TEXT;
  v_eff_pre     INT;
  v_eff_post    INT;
  v_evald_pre   INT;
  v_evald_post  INT;
  v_nu_pre      INT;
  v_nu_post     INT;
  v_pass        BOOLEAN := false;
BEGIN
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;
  SELECT id, name_ko INTO v_tech_id, v_label FROM techniques WHERE is_active = true LIMIT 1;

  IF v_user_id IS NULL OR v_tech_id IS NULL THEN
    RAISE NOTICE '5. E2E not_used: SKIP — auth.users 또는 techniques 데이터 부족';
    RETURN;
  END IF;

  -- pre 측정 (effective + evaluated + not_used_count)
  SELECT excellent_count + good_count, not_used_count
    INTO v_eff_pre, v_nu_pre
  FROM technique_stats WHERE technique_id = v_tech_id;
  v_eff_pre := COALESCE(v_eff_pre, 0);
  v_nu_pre  := COALESCE(v_nu_pre, 0);

  SELECT COUNT(*) INTO v_evald_pre
  FROM ratings
  WHERE technique_id = v_tech_id
    AND outcome IS NOT NULL
    AND outcome != 'not_used';

  BEGIN
    INSERT INTO ratings (user_id, technique_id, technique_label, star_rating, outcome)
    VALUES (v_user_id, v_tech_id, COALESCE(v_label, 'verify-055 not_used'), NULL, 'not_used');

    SELECT excellent_count + good_count, not_used_count
      INTO v_eff_post, v_nu_post
    FROM technique_stats WHERE technique_id = v_tech_id;

    SELECT COUNT(*) INTO v_evald_post
    FROM ratings
    WHERE technique_id = v_tech_id
      AND outcome IS NOT NULL
      AND outcome != 'not_used';

    -- 검증: effective_count 변화 0, evaluated 분모 변화 0, not_used_count +1
    IF v_eff_post = v_eff_pre
       AND v_evald_post = v_evald_pre
       AND v_nu_post = v_nu_pre + 1 THEN
      v_pass := true;
    END IF;

    RAISE NOTICE '5. E2E not_used: % — eff(pre/post)=%/% evald=%/% nu_count=%/%',
      CASE WHEN v_pass THEN 'PASS' ELSE 'FAIL' END,
      v_eff_pre, v_eff_post, v_evald_pre, v_evald_post, v_nu_pre, v_nu_post;

    RAISE EXCEPTION 'verify-055 E2E not_used rollback (intentional)';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLERRM LIKE '%verify-055 E2E not_used rollback%' THEN
        RAISE NOTICE '5. E2E not_used: 트랜잭션 롤백 완료';
      ELSE
        RAISE NOTICE '5. E2E not_used: FAIL — 예상 외 예외: %', SQLERRM;
        RAISE;
      END IF;
  END;
END $$;
-- 기대: NOTICE '5. E2E not_used: PASS — eff(pre/post)=X/X evald=Y/Y nu_count=Z/Z+1'


-- ----------------------------------------------------------------
-- 6) (E2E) outcome='good' INSERT → effective_count +1, weight 갱신
-- ----------------------------------------------------------------
-- 비교: not_used 와 달리 good 은 effective 분자/분모 모두 +1.

DO $$
DECLARE
  v_user_id     UUID;
  v_tech_id     UUID;
  v_label       TEXT;
  v_eff_pre     INT;
  v_eff_post    INT;
  v_evald_pre   INT;
  v_evald_post  INT;
  v_weight_pre  NUMERIC(5,4);
  v_weight_post NUMERIC(5,4);
  v_pass        BOOLEAN := false;
BEGIN
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;
  SELECT id, name_ko INTO v_tech_id, v_label FROM techniques WHERE is_active = true LIMIT 1;

  IF v_user_id IS NULL OR v_tech_id IS NULL THEN
    RAISE NOTICE '6. E2E good: SKIP — 데이터 부족';
    RETURN;
  END IF;

  SELECT excellent_count + good_count, recommendation_weight
    INTO v_eff_pre, v_weight_pre
  FROM technique_stats WHERE technique_id = v_tech_id;
  v_eff_pre := COALESCE(v_eff_pre, 0);

  SELECT COUNT(*) INTO v_evald_pre
  FROM ratings
  WHERE technique_id = v_tech_id
    AND outcome IS NOT NULL
    AND outcome != 'not_used';

  BEGIN
    INSERT INTO ratings (user_id, technique_id, technique_label, star_rating, outcome)
    VALUES (v_user_id, v_tech_id, COALESCE(v_label, 'verify-055 good'), NULL, 'good');

    SELECT excellent_count + good_count, recommendation_weight
      INTO v_eff_post, v_weight_post
    FROM technique_stats WHERE technique_id = v_tech_id;

    SELECT COUNT(*) INTO v_evald_post
    FROM ratings
    WHERE technique_id = v_tech_id
      AND outcome IS NOT NULL
      AND outcome != 'not_used';

    -- 검증: effective +1, evaluated +1, weight in [0,1] (변화 가능)
    IF v_eff_post = v_eff_pre + 1
       AND v_evald_post = v_evald_pre + 1
       AND v_weight_post IS NOT NULL
       AND v_weight_post BETWEEN 0.0 AND 1.0 THEN
      v_pass := true;
    END IF;

    RAISE NOTICE '6. E2E good: % — eff(pre/post)=%/% evald=%/% w(pre/post)=%/%',
      CASE WHEN v_pass THEN 'PASS' ELSE 'FAIL' END,
      v_eff_pre, v_eff_post, v_evald_pre, v_evald_post,
      v_weight_pre, v_weight_post;

    RAISE EXCEPTION 'verify-055 E2E good rollback (intentional)';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLERRM LIKE '%verify-055 E2E good rollback%' THEN
        RAISE NOTICE '6. E2E good: 트랜잭션 롤백 완료';
      ELSE
        RAISE NOTICE '6. E2E good: FAIL — 예상 외 예외: %', SQLERRM;
        RAISE;
      END IF;
  END;
END $$;
-- 기대: NOTICE '6. E2E good: PASS — eff +1, evald +1, weight in [0,1]'
