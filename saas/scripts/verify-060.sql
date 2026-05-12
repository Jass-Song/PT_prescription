-- ============================================================
-- verify-060.sql
-- ============================================================
-- Purpose: 마이그 060 (ratings.technique_id NOT NULL 제거) 적용 후 검증.
--          §1 ~ §4 항목별 PASS/FAIL 판정 + 운영 절차 안내.
-- Usage  : Supabase 대시보드 SQL 에디터에 본 파일 전체 붙여넣고 Run.
--          또는 psql -h <host> -U <user> -d <db> -f saas/scripts/verify-060.sql
-- Author : sw-db-architect
-- Date   : 2026-05-12
-- ============================================================
-- 검증 항목 (총 4):
--   §1. ratings.technique_id is_nullable = 'YES' (NOT NULL 제거됨)
--   §2. FK 제약 유지 — technique_id → techniques(id) ON DELETE CASCADE
--   §3. NULL INSERT 시뮬레이션 — savepoint + ROLLBACK 로 비파괴 검증
--       (실 production 데이터 0 변경)
--   §4. 운영 절차 안내 — 적용 순서 / 후속 / 모니터링
-- ============================================================


-- ----------------------------------------------------------------
-- §1) ratings.technique_id NULLABLE 확인
-- ----------------------------------------------------------------
-- 기대: PASS / YES / YES
SELECT
  '1-a. ratings.technique_id is_nullable' AS check_label,
  CASE WHEN is_nullable = 'YES' THEN 'PASS' ELSE 'FAIL' END AS result,
  is_nullable AS actual,
  'YES'       AS expected
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'ratings'
  AND  column_name  = 'technique_id';

-- 참고 — 컬럼 명세 확인 (UUID 타입 유지)
-- 기대: technique_id | uuid | YES
SELECT
  '1-b. technique_id 컬럼 명세' AS check_label,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'ratings'
  AND  column_name  = 'technique_id';


-- ----------------------------------------------------------------
-- §2) FK 제약 유지 확인 — technique_id → techniques(id)
-- ----------------------------------------------------------------
-- 기대: PASS / 1 / 1 + ON DELETE: c (CASCADE)
SELECT
  '2-a. FK ratings.technique_id → techniques(id) 존재' AS check_label,
  CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS actual,
  1        AS expected
FROM   pg_constraint c
JOIN   pg_class      t  ON t.oid  = c.conrelid
JOIN   pg_namespace  n  ON n.oid  = t.relnamespace
JOIN   pg_class      rt ON rt.oid = c.confrelid
WHERE  n.nspname  = 'public'
  AND  t.relname  = 'ratings'
  AND  rt.relname = 'techniques'
  AND  c.contype  = 'f'
  AND  (
    SELECT array_agg(att.attname::text ORDER BY att.attname::text)
    FROM   unnest(c.conkey) AS k(attnum)
    JOIN   pg_attribute att
      ON   att.attrelid = c.conrelid AND att.attnum = k.attnum
  ) = ARRAY['technique_id']::text[];

-- ON DELETE 정책 확인 (기대: c = CASCADE)
-- confdeltype: 'a' = NO ACTION, 'r' = RESTRICT, 'c' = CASCADE,
--              'n' = SET NULL, 'd' = SET DEFAULT
SELECT
  '2-b. ON DELETE 정책' AS check_label,
  CASE WHEN c.confdeltype = 'c' THEN 'PASS' ELSE 'FAIL' END AS result,
  c.confdeltype::TEXT AS actual,
  'c (CASCADE)'        AS expected,
  c.conname            AS fk_constraint_name
FROM   pg_constraint c
JOIN   pg_class      t  ON t.oid  = c.conrelid
JOIN   pg_namespace  n  ON n.oid  = t.relnamespace
JOIN   pg_class      rt ON rt.oid = c.confrelid
WHERE  n.nspname  = 'public'
  AND  t.relname  = 'ratings'
  AND  rt.relname = 'techniques'
  AND  c.contype  = 'f'
  AND  (
    SELECT array_agg(att.attname::text ORDER BY att.attname::text)
    FROM   unnest(c.conkey) AS k(attnum)
    JOIN   pg_attribute att
      ON   att.attrelid = c.conrelid AND att.attnum = k.attnum
  ) = ARRAY['technique_id']::text[];


-- ----------------------------------------------------------------
-- §3) NULL INSERT 시뮬레이션 (비파괴 — savepoint + ROLLBACK)
-- ----------------------------------------------------------------
-- 목적: technique_id = NULL 케이스 (Anatomy Trains/LLM 의역/glossary 변환)
--       이 실제로 INSERT 가능한지 검증. 데이터는 ROLLBACK 으로 즉시 제거.
--
-- 주의: 본 블록은 auth.users 에 최소 1개 user 가 존재해야 동작.
--       (RLS 우회 — SECURITY DEFINER 컨텍스트가 아닐 경우 service_role
--        세션 또는 admin 계정으로 실행 권장)
--
-- 기대: PASS — INSERT 성공 후 ROLLBACK
DO $$
DECLARE
  v_user_id    UUID;
  v_inserted   UUID;
  v_can_insert BOOLEAN := FALSE;
BEGIN
  -- 검증용 user_id 확보 (가장 오래된 user 1명)
  SELECT id INTO v_user_id
  FROM   auth.users
  ORDER  BY created_at ASC
  LIMIT  1;

  IF v_user_id IS NULL THEN
    RAISE NOTICE '[POST-CHECK §3 SKIP] auth.users 비어있음 — INSERT 시뮬레이션 생략';
    RETURN;
  END IF;

  -- 트랜잭션 내부 savepoint
  BEGIN
    INSERT INTO ratings (
      user_id,
      technique_id,
      technique_label,
      outcome,
      was_ai_recommended
    ) VALUES (
      v_user_id,
      NULL,                                              -- ★ NULL 케이스
      'verify-060 dry-run (Quadratus lumborum)',
      'good',
      TRUE
    )
    RETURNING id INTO v_inserted;

    v_can_insert := TRUE;
    RAISE NOTICE '[POST-CHECK §3] NULL INSERT 성공 — id=%', v_inserted;

    -- 비파괴: 즉시 제거
    DELETE FROM ratings WHERE id = v_inserted;
    RAISE NOTICE '[POST-CHECK §3] 시뮬레이션 row 삭제 완료 (production 데이터 0 변경)';

  EXCEPTION
    WHEN not_null_violation THEN
      RAISE EXCEPTION '[POST-CHECK §3 FAIL] NOT NULL 위반 — 마이그 060 미적용 상태';
    WHEN OTHERS THEN
      RAISE NOTICE '[POST-CHECK §3 INFO] INSERT 거부 (NOT NULL 이외): % (%)', SQLERRM, SQLSTATE;
      -- 정책/트리거 기타 사유로 INSERT 거부될 수 있음. NOT NULL 제거 자체는 §1 으로 확인.
  END;

  IF v_can_insert THEN
    RAISE NOTICE '[POST-CHECK §3 PASS] technique_id = NULL INSERT 허용 확인';
  END IF;
END $$;


-- ----------------------------------------------------------------
-- §4) 운영 절차 안내
-- ----------------------------------------------------------------
-- 대표님 production 적용 순서:
--   1) Supabase SQL 에디터에서
--      saas/migrations/060-ratings-technique-id-nullable.sql 전체 실행
--      → 내장 POST-CHECK §1, §2 NOTICE 확인 (PASS)
--   2) 본 verify-060.sql 실행
--      → §1, §2 결과 PASS 행 확인
--      → §3 NOTICE: "NULL INSERT 성공" + "시뮬레이션 row 삭제 완료"
--      → §4 본 안내 출력
--   3) 대표님 E2E 재시도:
--      - "허리네모근(Quadratus lumborum) 통압유발점(trigger point)" 등
--        용어집 변환된 이름으로 feedback 제출
--      - 기대: ratings INSERT 200 OK
--      - DB 확인: SELECT id, technique_id, technique_label, outcome
--                 FROM ratings ORDER BY created_at DESC LIMIT 5;
--        → 변환된 이름 row 가 technique_id = NULL,
--          technique_label = 변환된 이름 으로 적재된다
--
-- 적용 후 모니터링 쿼리 (1주일 후 권장 실행):
--   -- NULL technique_id 비율 추이
--   SELECT
--     DATE(created_at)                                    AS d,
--     COUNT(*)                                            AS total,
--     COUNT(*) FILTER (WHERE technique_id IS NULL)        AS null_fk,
--     ROUND(100.0 * COUNT(*) FILTER (WHERE technique_id IS NULL)
--                 / NULLIF(COUNT(*), 0), 1)               AS null_pct
--   FROM   ratings
--   WHERE  created_at >= NOW() - INTERVAL '7 days'
--   GROUP  BY 1
--   ORDER  BY 1;
--
--   -- 어떤 technique_label 이 매치 실패하는지 (lookup 개선 단서)
--   SELECT technique_label, COUNT(*) AS hits
--   FROM   ratings
--   WHERE  technique_id IS NULL
--     AND  created_at >= NOW() - INTERVAL '7 days'
--   GROUP  BY 1
--   ORDER  BY 2 DESC
--   LIMIT  20;
--
-- 후속 작업 후보 (백로그):
--   - feedback.js technique lookup 개선 — 괄호 () 제거 후 retry
--   - 또는 frontend pending modal 에서 원본 name_ko 보존
--     (display 이름 vs lookup 이름 분리)
-- ----------------------------------------------------------------

SELECT '4. 운영 절차 안내' AS check_label,
       '본 파일 상단 §4 주석 참고 — 적용 순서 / 모니터링 쿼리 / 후속 백로그' AS note;
