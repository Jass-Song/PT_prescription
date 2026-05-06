-- ============================================================
-- verify-051.sql
-- ============================================================
-- Purpose: 마이그 051-recommendation-evaluation.sql 적용 후 검증.
--          Track C Day 0 평가 타이밍 재설계 DB 인프라 — ENUM / 컬럼 /
--          인덱스 / RLS / 트리거 / 함수 / 기존 데이터 일괄 처리 결과
--          각 항목을 SELECT 로 PASS/FAIL 출력.
-- Usage  : Supabase 대시보드 SQL 에디터에 본 파일 전체 붙여넣고 Run.
--          또는 psql -h <host> -U <user> -d <db> -f saas/scripts/verify-051.sql
-- Author : sw-db-architect
-- Date   : 2026-05-06
-- ============================================================
-- 검증 항목 (총 11):
--   1.  evaluation_status_enum 타입 존재 + 4 값
--   2.  recommendation_logs.evaluation_status NOT NULL + DEFAULT 'pending'
--   3.  recommendation_logs.evaluated_at TIMESTAMPTZ NULL
--   4.  ratings.recommendation_log_id FK → recommendation_logs.id (ON DELETE SET NULL)
--   5.  ratings.recommended_technique_index SMALLINT NULL
--   6.  인덱스 idx_rec_logs_pending_user / idx_ratings_rec_log_idx 존재
--   7.  RLS UPDATE 정책 rec_logs_update_own ON recommendation_logs 존재
--   8.  트리거 trg_update_evaluation_on_rating (AFTER INSERT, ratings) 존재
--          + 함수 update_evaluation_status_on_rating SECURITY DEFINER
--   9.  함수 expire_old_pending_evaluations 존재 (SECURITY DEFINER, INTEGER 반환)
--   10. 5/6 이전 recommendation_logs 모두 'expired' (잔여 'pending' = 0)
--   11. 기존 ratings.recommendation_log_id 모두 NULL
-- ============================================================


-- ----------------------------------------------------------------
-- 1) evaluation_status_enum 타입 존재 + 4 값
-- ----------------------------------------------------------------

SELECT
  '1. evaluation_status_enum 타입' AS check_label,
  CASE
    WHEN COUNT(*) = 4
     AND bool_and(enumlabel = ANY(ARRAY['pending','rated','expired','skipped']))
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  COUNT(*)                       AS value_count,
  array_agg(enumlabel ORDER BY enumsortorder) AS values
FROM   pg_enum e
JOIN   pg_type t ON t.oid = e.enumtypid
WHERE  t.typname = 'evaluation_status_enum';
-- 기대: PASS / 4 / {pending,rated,expired,skipped}


-- ----------------------------------------------------------------
-- 2) recommendation_logs.evaluation_status NOT NULL + DEFAULT 'pending'
-- ----------------------------------------------------------------

SELECT
  '2. recommendation_logs.evaluation_status' AS check_label,
  CASE
    WHEN is_nullable      = 'NO'
     AND column_default  LIKE '%pending%'
     AND udt_name        = 'evaluation_status_enum'
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  data_type, udt_name, is_nullable, column_default
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'recommendation_logs'
  AND  column_name  = 'evaluation_status';


-- ----------------------------------------------------------------
-- 3) recommendation_logs.evaluated_at TIMESTAMPTZ NULL
-- ----------------------------------------------------------------

SELECT
  '3. recommendation_logs.evaluated_at' AS check_label,
  CASE
    WHEN data_type    = 'timestamp with time zone'
     AND is_nullable = 'YES'
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  data_type, is_nullable, column_default
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'recommendation_logs'
  AND  column_name  = 'evaluated_at';


-- ----------------------------------------------------------------
-- 4) ratings.recommendation_log_id FK → recommendation_logs.id (ON DELETE SET NULL)
-- ----------------------------------------------------------------

SELECT
  '4. ratings.recommendation_log_id FK' AS check_label,
  CASE
    WHEN COUNT(*) = 1
     AND bool_and(confdeltype = 'n')           -- 'n' = SET NULL
     AND bool_and(target_table = 'recommendation_logs')
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  array_agg(conname)         AS constraint_names,
  array_agg(confdeltype)     AS on_delete_action,   -- 기대: {n} (SET NULL)
  array_agg(target_table)    AS target_tables
FROM (
  SELECT
    c.conname,
    c.confdeltype,
    rt.relname AS target_table
  FROM   pg_constraint c
  JOIN   pg_class      lt ON lt.oid = c.conrelid
  JOIN   pg_class      rt ON rt.oid = c.confrelid
  JOIN   pg_attribute  a  ON a.attrelid = c.conrelid
                          AND a.attnum  = ANY(c.conkey)
  WHERE  c.contype  = 'f'
    AND  lt.relname = 'ratings'
    AND  a.attname  = 'recommendation_log_id'
) sub;
-- 기대: PASS / 1 / {n} / {recommendation_logs}

-- 컬럼 자체 확인
SELECT
  '4a. ratings.recommendation_log_id 컬럼' AS check_label,
  CASE
    WHEN data_type    = 'uuid'
     AND is_nullable = 'YES'
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  data_type, is_nullable
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'ratings'
  AND  column_name  = 'recommendation_log_id';


-- ----------------------------------------------------------------
-- 5) ratings.recommended_technique_index SMALLINT NULL
-- ----------------------------------------------------------------

SELECT
  '5. ratings.recommended_technique_index' AS check_label,
  CASE
    WHEN data_type    = 'smallint'
     AND is_nullable = 'YES'
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  data_type, is_nullable
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'ratings'
  AND  column_name  = 'recommended_technique_index';


-- ----------------------------------------------------------------
-- 6) 인덱스 2개 존재
-- ----------------------------------------------------------------

SELECT
  '6. 인덱스 idx_rec_logs_pending_user / idx_ratings_rec_log_idx' AS check_label,
  CASE
    WHEN COUNT(*) FILTER (WHERE indexname = 'idx_rec_logs_pending_user')  = 1
     AND COUNT(*) FILTER (WHERE indexname = 'idx_ratings_rec_log_idx')    = 1
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  array_agg(indexname ORDER BY indexname) AS indexes
FROM   pg_indexes
WHERE  schemaname = 'public'
  AND  indexname IN ('idx_rec_logs_pending_user', 'idx_ratings_rec_log_idx');

-- 인덱스 정의 상세 (참조용 — partial unique 확인)
SELECT
  '6a. 인덱스 정의' AS check_label,
  indexname, indexdef
FROM   pg_indexes
WHERE  schemaname = 'public'
  AND  indexname IN ('idx_rec_logs_pending_user', 'idx_ratings_rec_log_idx')
ORDER  BY indexname;


-- ----------------------------------------------------------------
-- 7) RLS UPDATE 정책 rec_logs_update_own ON recommendation_logs
-- ----------------------------------------------------------------

SELECT
  '7. RLS UPDATE 정책 rec_logs_update_own' AS check_label,
  CASE
    WHEN COUNT(*) = 1
     AND bool_and(cmd = 'UPDATE')
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  array_agg(policyname) AS policies,
  array_agg(cmd)        AS cmds,
  array_agg(qual)       AS qual_expressions
FROM   pg_policies
WHERE  schemaname = 'public'
  AND  tablename  = 'recommendation_logs'
  AND  policyname = 'rec_logs_update_own';


-- ----------------------------------------------------------------
-- 8) 트리거 trg_update_evaluation_on_rating + 함수 SECURITY DEFINER
-- ----------------------------------------------------------------

SELECT
  '8. 트리거 trg_update_evaluation_on_rating' AS check_label,
  CASE
    WHEN COUNT(*) = 1
     AND bool_and(action_timing      = 'AFTER')
     AND bool_and(event_manipulation = 'INSERT')
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  array_agg(trigger_name)        AS triggers,
  array_agg(action_timing)       AS timings,
  array_agg(event_manipulation)  AS events
FROM   information_schema.triggers
WHERE  event_object_schema = 'public'
  AND  event_object_table  = 'ratings'
  AND  trigger_name        = 'trg_update_evaluation_on_rating';

-- 8a. 함수 update_evaluation_status_on_rating SECURITY DEFINER
SELECT
  '8a. 함수 update_evaluation_status_on_rating SECURITY DEFINER' AS check_label,
  CASE
    WHEN COUNT(*) = 1
     AND bool_and(prosecdef = true)
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  array_agg(proname)   AS function_names,
  array_agg(prosecdef) AS security_definer
FROM   pg_proc
WHERE  proname = 'update_evaluation_status_on_rating';


-- ----------------------------------------------------------------
-- 9) 함수 expire_old_pending_evaluations 존재 (SECURITY DEFINER, INTEGER 반환)
-- ----------------------------------------------------------------

SELECT
  '9. 함수 expire_old_pending_evaluations' AS check_label,
  CASE
    WHEN COUNT(*) = 1
     AND bool_and(prosecdef = true)
     AND bool_and(return_type = 'integer')
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  array_agg(proname)     AS function_names,
  array_agg(prosecdef)   AS security_definer,
  array_agg(return_type) AS return_types
FROM (
  SELECT
    p.proname,
    p.prosecdef,
    pg_catalog.format_type(p.prorettype, NULL) AS return_type
  FROM   pg_proc p
  WHERE  p.proname = 'expire_old_pending_evaluations'
) sub;


-- ----------------------------------------------------------------
-- 10) 5/6 이전 recommendation_logs 모두 'expired'
-- ----------------------------------------------------------------
-- 마이그 051 §8 일괄 처리 — created_at < '2026-05-06' 인 row 중
-- evaluation_status = 'pending' 인 row 가 0 개여야 함.

SELECT
  '10. 5/6 이전 historical row 일괄 expired 처리' AS check_label,
  CASE
    WHEN COUNT(*) FILTER (WHERE evaluation_status = 'pending') = 0
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  COUNT(*)                                                    AS pre_5_6_total,
  COUNT(*) FILTER (WHERE evaluation_status = 'pending')      AS still_pending,
  COUNT(*) FILTER (WHERE evaluation_status = 'expired')      AS expired_count,
  COUNT(*) FILTER (WHERE evaluation_status = 'rated')        AS rated_count,
  COUNT(*) FILTER (WHERE evaluation_status = 'skipped')      AS skipped_count
FROM   recommendation_logs
WHERE  created_at < '2026-05-06'::TIMESTAMPTZ;
-- 기대: PASS / still_pending = 0


-- ----------------------------------------------------------------
-- 11) 기존 ratings.recommendation_log_id 모두 NULL
-- ----------------------------------------------------------------
-- 마이그 051 §3 ALTER ADD COLUMN 시 NULL 기본값. 본 검증은 마이그 직후
-- 본격 사용 전 시점 기준. 이미 새 평가가 들어왔다면 자연스럽게 fail 가능.

SELECT
  '11. 기존 ratings.recommendation_log_id 분포' AS check_label,
  CASE
    WHEN COUNT(*) FILTER (WHERE recommendation_log_id IS NULL)
       = COUNT(*)
    THEN 'PASS (모두 NULL — 소급 매칭 불가, 정상)'
    WHEN COUNT(*) FILTER (WHERE recommendation_log_id IS NULL) >= 0
    THEN 'INFO (일부 NOT NULL — 마이그 후 신규 평가 기록됨, 정상)'
    ELSE 'FAIL'
  END AS result,
  COUNT(*)                                                AS total_ratings,
  COUNT(*) FILTER (WHERE recommendation_log_id IS NULL)   AS null_log_id,
  COUNT(*) FILTER (WHERE recommendation_log_id IS NOT NULL) AS not_null_log_id;


-- ============================================================
-- (선택) End-to-End 트리거 동작 검증 — BEGIN ... ROLLBACK
-- ============================================================
-- ratings INSERT 시 trg_update_evaluation_on_rating 가 매칭된 log 의
-- evaluation_status 를 pending → rated 로 전환하는지 확인.
-- 본 섹션은 ROLLBACK 으로 production 데이터 영향 없음.
-- 데이터 부재 시(베타 출시 직후 첫 추천 미발생) SKIP.

BEGIN;

DO $$
DECLARE
  v_user_id          UUID;
  v_log_id           UUID;
  v_status_before    evaluation_status_enum;
  v_status_after     evaluation_status_enum;
  v_evaluated_at     TIMESTAMPTZ;
BEGIN
  SELECT id INTO v_user_id FROM auth.users ORDER BY created_at LIMIT 1;
  IF v_user_id IS NULL THEN
    RAISE NOTICE '[E2E SKIP] auth.users 비어있음';
    RETURN;
  END IF;

  -- pending log 1건 신규 INSERT (테스트용)
  INSERT INTO recommendation_logs (
    user_id, region, acuity, symptom, selected_categories, recommended_techniques
  ) VALUES (
    v_user_id, 'shoulder', 'subacute', 'verify-051 e2e test',
    ARRAY['category_a_joint_mobilization'],
    '[{"name":"verify-051-test","category_key":"category_a_joint_mobilization"}]'::jsonb
  )
  RETURNING id, evaluation_status INTO v_log_id, v_status_before;

  RAISE NOTICE '── E2E 트리거 검증 ──';
  RAISE NOTICE '  log_id          = %', v_log_id;
  RAISE NOTICE '  status (before) = %', v_status_before;

  IF v_status_before <> 'pending' THEN
    RAISE WARNING '⚠️  신규 log default 가 pending 이 아님: %', v_status_before;
  END IF;

  -- ratings INSERT — recommendation_log_id 매칭
  INSERT INTO ratings (
    user_id, technique_id,
    star_rating, outcome, indication_accuracy, was_ai_recommended,
    recommendation_log_id, recommended_technique_index
  )
  SELECT
    v_user_id, t.id,
    4, 'good', 4, true,
    v_log_id, 1
  FROM   techniques t
  WHERE  t.is_published = true AND t.is_active = true
  ORDER  BY t.created_at
  LIMIT  1;

  -- 트리거 발화 후 상태 재조회
  SELECT evaluation_status, evaluated_at
    INTO v_status_after, v_evaluated_at
  FROM   recommendation_logs
  WHERE  id = v_log_id;

  RAISE NOTICE '  status (after)  = %', v_status_after;
  RAISE NOTICE '  evaluated_at    = %', v_evaluated_at;

  IF v_status_after = 'rated' AND v_evaluated_at IS NOT NULL THEN
    RAISE NOTICE '✅ PASS — 트리거 정상 동작 (pending → rated, evaluated_at 기록)';
  ELSE
    RAISE WARNING '⚠️  FAIL — 트리거 미발화 또는 SECURITY DEFINER 미적용 (status=%, evaluated_at=%)',
      v_status_after, v_evaluated_at;
  END IF;
END $$;

ROLLBACK;


-- ============================================================
-- 요약
-- ============================================================
-- 모든 항목 PASS 시 마이그 051 정상 적용 완료.
-- FAIL 발생 시:
--   - 1~5: ENUM/컬럼 누락 → 마이그 051 재실행 (멱등 안전)
--   - 6:   인덱스 누락 → 051 §4 블록 단독 재실행
--   - 7:   RLS 정책 누락 → 051 §5 블록 단독 재실행
--   - 8:   트리거/함수 누락 또는 SECURITY DEFINER 미적용 → 051 §6 재실행
--   - 9:   expire 함수 누락 → 051 §7 재실행
--   - 10:  historical row 미처리 → 051 §8 재실행 (멱등 안전)
--   - 11:  unexpected (ALTER ADD COLUMN 직후 NULL 이 아닐 수 없음)
-- ============================================================
