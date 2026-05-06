-- ============================================================
-- verify-054.sql
-- ============================================================
-- Purpose: 마이그 054 (단일 신호 모델 — outcome only, weight 70/20/10)
--          적용 후 검증. 7 항목 PASS/FAIL 출력.
-- Usage  : Supabase 대시보드 SQL 에디터에 본 파일 전체 붙여넣고 Run.
--          또는 psql -h <host> -U <user> -d <db> -f saas/scripts/verify-054.sql
-- Author : sw-db-architect
-- Date   : 2026-05-06
-- ============================================================
-- 검증 항목 (총 7):
--   1. ratings.star_rating is_nullable = 'YES'
--   2. fn_refresh_technique_stats SECURITY DEFINER 함수 존재
--   3. 함수 본문에 새 가중치 공식 패턴 포함
--      ('outcome IS NOT NULL' / '0.70' / '0.20' / '0.10' / 'adverse')
--   4. technique_stats.recommendation_weight 모두 [0.0, 1.0] 범위
--   5. (INFO) 가중치 분포 — 050b 와 비교용 통계 출력
--   6. ratings.star_rating COMMENT 'DEPRECATED' 포함
--   7. (E2E) BEGIN/ROLLBACK — star_rating=NULL, outcome='good' INSERT 시
--      트리거가 weight 정상 갱신 (NULL 아님, 0~1 범위)
-- ============================================================


-- ----------------------------------------------------------------
-- 1) ratings.star_rating is_nullable = 'YES'
-- ----------------------------------------------------------------

SELECT
  '1. ratings.star_rating NULL 허용' AS check_label,
  CASE
    WHEN is_nullable = 'YES' THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  data_type, is_nullable, column_default
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'ratings'
  AND  column_name  = 'star_rating';
-- 기대: PASS / smallint / YES


-- ----------------------------------------------------------------
-- 2) fn_refresh_technique_stats SECURITY DEFINER 존재
-- ----------------------------------------------------------------

SELECT
  '2. fn_refresh_technique_stats SECURITY DEFINER' AS check_label,
  CASE
    WHEN COUNT(*) = 1
     AND bool_and(prosecdef = true)
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  COUNT(*)                    AS function_count,
  array_agg(prosecdef)        AS security_definer_flags
FROM   pg_proc
WHERE  proname = 'fn_refresh_technique_stats';
-- 기대: PASS / 1 / {true}


-- ----------------------------------------------------------------
-- 3) 함수 본문에 새 가중치 공식 패턴 포함
-- ----------------------------------------------------------------

SELECT
  '3. 함수 본문 — 054 가중치 패턴' AS check_label,
  CASE
    WHEN body LIKE '%outcome IS NOT NULL%'
     AND body LIKE '%0.70%'
     AND body LIKE '%0.20%'
     AND body LIKE '%0.10%'
     AND body LIKE '%adverse%'
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  -- 디버그용: 각 패턴 매칭 여부
  (body LIKE '%outcome IS NOT NULL%') AS has_outcome_not_null,
  (body LIKE '%0.70%')                 AS has_070,
  (body LIKE '%0.20%')                 AS has_020,
  (body LIKE '%0.10%')                 AS has_010,
  (body LIKE '%adverse%')              AS has_adverse
FROM (
  SELECT pg_get_functiondef(oid) AS body
  FROM   pg_proc
  WHERE  proname = 'fn_refresh_technique_stats'
) sub;
-- 기대: PASS / 모든 플래그 t


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
-- 5) (INFO) 가중치 분포 — 분석용
-- ----------------------------------------------------------------

SELECT
  '5. INFO: weight 분포'           AS check_label,
  COUNT(*)                          AS total_techniques,
  COUNT(*) FILTER (WHERE recommendation_weight IS NULL) AS null_weight,
  ROUND(MIN(recommendation_weight), 4)  AS min_w,
  ROUND(AVG(recommendation_weight), 4)  AS avg_w,
  ROUND(MAX(recommendation_weight), 4)  AS max_w,
  COUNT(*) FILTER (WHERE recommendation_weight < 0.4)             AS under_04,
  COUNT(*) FILTER (WHERE recommendation_weight BETWEEN 0.4 AND 0.6) AS mid_04_06,
  COUNT(*) FILTER (WHERE recommendation_weight > 0.6)             AS over_06
FROM   technique_stats;
-- 050b 평균 대비 변화 관찰 (분모 변화 + 별점 가중 제거 영향).


-- ----------------------------------------------------------------
-- 6) ratings.star_rating COMMENT 'DEPRECATED'
-- ----------------------------------------------------------------

SELECT
  '6. ratings.star_rating DEPRECATED 코멘트' AS check_label,
  CASE
    WHEN col_description IS NOT NULL
     AND col_description LIKE '%DEPRECATED%'
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  col_description
FROM (
  SELECT col_description(
    ('public.ratings'::regclass)::oid,
    (SELECT ordinal_position FROM information_schema.columns
       WHERE table_schema='public' AND table_name='ratings' AND column_name='star_rating')::int
  ) AS col_description
) sub;
-- 기대: PASS / DEPRECATED 포함 텍스트


-- ----------------------------------------------------------------
-- 7) (E2E) BEGIN/ROLLBACK — star_rating=NULL, outcome='good' INSERT
--    트리거가 weight 정상 갱신 (NULL 아님, 0~1)
-- ----------------------------------------------------------------
-- 안전: BEGIN ... ROLLBACK — 실제 데이터 변경 안 함.
-- 본 블록은 단일 트랜잭션 내에서 실행돼야 함 (verify 전체 파일을 한 번에
-- 실행하면 PG 가 자동 트랜잭션 처리).

DO $$
DECLARE
  v_user_id    UUID;
  v_tech_id    UUID;
  v_label      TEXT;
  v_weight_pre NUMERIC(5,4);
  v_weight_post NUMERIC(5,4);
  v_rating_id  UUID;
  v_pass       BOOLEAN := false;
BEGIN
  -- 임의 1명 user + 1개 technique 픽업 (없으면 SKIP)
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;
  SELECT id, name_ko INTO v_tech_id, v_label FROM techniques WHERE is_active = true LIMIT 1;

  IF v_user_id IS NULL OR v_tech_id IS NULL THEN
    RAISE NOTICE '7. E2E: SKIP — auth.users 또는 techniques 데이터 부족';
    RETURN;
  END IF;

  SELECT recommendation_weight INTO v_weight_pre
  FROM technique_stats WHERE technique_id = v_tech_id;

  -- savepoint 로 INSERT 후 무조건 ROLLBACK
  BEGIN
    INSERT INTO ratings (user_id, technique_id, technique_label, star_rating, outcome)
    VALUES (v_user_id, v_tech_id, COALESCE(v_label, 'verify-054 test'), NULL, 'good')
    RETURNING id INTO v_rating_id;

    -- 트리거 발화 후 weight 재조회
    SELECT recommendation_weight INTO v_weight_post
    FROM technique_stats WHERE technique_id = v_tech_id;

    IF v_weight_post IS NOT NULL
       AND v_weight_post BETWEEN 0.0 AND 1.0 THEN
      v_pass := true;
    END IF;

    RAISE NOTICE '7. E2E: % — pre=% post=% rating_id=%',
      CASE WHEN v_pass THEN 'PASS' ELSE 'FAIL' END,
      v_weight_pre, v_weight_post, v_rating_id;

    -- 의도적 예외로 트랜잭션 롤백
    RAISE EXCEPTION 'verify-054 E2E rollback (intentional)';
  EXCEPTION
    WHEN OTHERS THEN
      -- 의도적 롤백 메시지면 통과, 아니면 재발생
      IF SQLERRM LIKE '%verify-054 E2E rollback%' THEN
        RAISE NOTICE '7. E2E: 트랜잭션 롤백 완료 (테스트 데이터 제거됨)';
      ELSE
        RAISE NOTICE '7. E2E: FAIL — 예상 외 예외: %', SQLERRM;
        RAISE;
      END IF;
  END;
END $$;
-- 기대: NOTICE '7. E2E: PASS — pre=... post=... rating_id=...'
--       이어서 NOTICE '7. E2E: 트랜잭션 롤백 완료'
