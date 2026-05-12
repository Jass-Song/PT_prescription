-- ============================================================
-- verify-059.sql
-- ============================================================
-- Purpose: 마이그 059 (patients 테이블 + recommendation_logs.patient_id FK)
--          적용 후 검증. §1 ~ §4 항목별 PASS/FAIL 판정.
-- Usage  : Supabase 대시보드 SQL 에디터에 본 파일 전체 붙여넣고 Run.
--          또는 psql -h <host> -U <user> -d <db> -f saas/scripts/verify-059.sql
-- Author : sw-db-architect
-- Date   : 2026-05-12
-- ============================================================
-- 검증 항목 (총 4):
--   §1. patients 테이블 존재 + 컬럼 7개 (id/user_id/label/created_at/
--       last_visit_at/visit_count/notes) + UNIQUE (user_id, label) 제약
--   §2. recommendation_logs.patient_id 컬럼 존재 + FK → patients(id)
--       ON DELETE SET NULL
--   §3. patients RLS 활성 + patients_own 정책 (FOR ALL, USING/WITH CHECK
--       모두 user_id = auth.uid())
--   §4. 인덱스 2개 (idx_patients_user_id, idx_patients_last_visit) +
--       recommendation_logs idx_rec_logs_patient 존재
-- ============================================================


-- ----------------------------------------------------------------
-- §1) patients 테이블 컬럼 7개 + UNIQUE (user_id, label) 제약
-- ----------------------------------------------------------------
-- 기대: PASS / 7 / 7
SELECT
  '1-a. patients 컬럼 개수' AS check_label,
  CASE WHEN COUNT(*) = 7 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS actual,
  7        AS expected
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'patients';

-- 참고 — 컬럼 명/타입 명세 확인 (락인 스펙과 1:1 매치)
-- 기대 (7 row):
--   id            | uuid                        | NO  (PK, DEFAULT uuid_generate_v4())
--   user_id       | uuid                        | NO  (FK auth.users, NOT NULL)
--   label         | text                        | NO  (NOT NULL)
--   created_at    | timestamp with time zone    | YES (DEFAULT NOW())
--   last_visit_at | timestamp with time zone    | YES (DEFAULT NOW())
--   visit_count   | integer                     | NO  (NOT NULL DEFAULT 0)
--   notes         | text                        | YES
SELECT
  '1-b. patients 컬럼 명세' AS check_label,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'patients'
ORDER  BY ordinal_position;

-- UNIQUE (user_id, label) 제약 존재
-- 기대: PASS / 1 / 1
SELECT
  '1-c. UNIQUE (user_id, label) 제약' AS check_label,
  CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS actual,
  1        AS expected
FROM   pg_constraint c
JOIN   pg_class      t  ON t.oid  = c.conrelid
JOIN   pg_namespace  n  ON n.oid  = t.relnamespace
WHERE  n.nspname = 'public'
  AND  t.relname = 'patients'
  AND  c.contype = 'u'
  AND  (
          SELECT array_agg(att.attname ORDER BY att.attname)
          FROM   unnest(c.conkey) AS k(attnum)
          JOIN   pg_attribute att
            ON   att.attrelid = c.conrelid AND att.attnum = k.attnum
       ) = ARRAY['label','user_id'];


-- ----------------------------------------------------------------
-- §2) recommendation_logs.patient_id 컬럼 + FK 제약 확인
-- ----------------------------------------------------------------
-- patient_id 컬럼 존재 + uuid 타입 + NULLABLE
-- 기대: PASS / 1 / 1
SELECT
  '2-a. recommendation_logs.patient_id 컬럼' AS check_label,
  CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS actual,
  1        AS expected
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'recommendation_logs'
  AND  column_name  = 'patient_id'
  AND  data_type    = 'uuid'
  AND  is_nullable  = 'YES';

-- FK 제약 (patient_id → patients.id ON DELETE SET NULL) 존재
-- 기대: PASS / 1 / 1 / SET NULL
SELECT
  '2-b. patient_id FK → patients(id) ON DELETE SET NULL' AS check_label,
  CASE
    WHEN COUNT(*) = 1
     AND MAX(rc.delete_rule) = 'SET NULL'
    THEN 'PASS' ELSE 'FAIL'
  END AS result,
  COUNT(*)              AS actual,
  MAX(rc.delete_rule)   AS delete_rule,
  1                     AS expected_count
FROM   information_schema.referential_constraints rc
JOIN   information_schema.key_column_usage kcu
  ON   kcu.constraint_name   = rc.constraint_name
  AND  kcu.constraint_schema = rc.constraint_schema
JOIN   information_schema.constraint_column_usage ccu
  ON   ccu.constraint_name   = rc.unique_constraint_name
  AND  ccu.constraint_schema = rc.unique_constraint_schema
WHERE  kcu.table_schema = 'public'
  AND  kcu.table_name   = 'recommendation_logs'
  AND  kcu.column_name  = 'patient_id'
  AND  ccu.table_name   = 'patients'
  AND  ccu.column_name  = 'id';


-- ----------------------------------------------------------------
-- §3) RLS 활성 + patients_own 정책 (FOR ALL / own-row only)
-- ----------------------------------------------------------------
-- RLS 활성 여부
-- 기대: PASS / true / true
SELECT
  '3-a. patients RLS 활성' AS check_label,
  CASE WHEN relrowsecurity THEN 'PASS' ELSE 'FAIL' END AS result,
  relrowsecurity AS actual,
  true           AS expected
FROM   pg_class
WHERE  oid = 'public.patients'::regclass;

-- patients_own 정책 존재 + USING / WITH CHECK 양쪽 모두 user_id = auth.uid()
-- 기대: PASS / 1 / 1 (cmd='ALL', roles 에 authenticated 포함)
SELECT
  '3-b. patients_own 정책 (FOR ALL)' AS check_label,
  CASE
    WHEN COUNT(*) = 1
     AND MAX(cmd) = 'ALL'
     AND MAX(qual)       ILIKE '%user_id%=%auth.uid()%'
     AND MAX(with_check) ILIKE '%user_id%=%auth.uid()%'
    THEN 'PASS' ELSE 'FAIL'
  END AS result,
  COUNT(*) AS actual,
  1        AS expected
FROM   pg_policies
WHERE  schemaname = 'public'
  AND  tablename  = 'patients'
  AND  policyname = 'patients_own';

-- 참고 — 정책 본문 출력 (디버깅용)
SELECT
  '3-c. patients_own 정책 본문 (참고)' AS check_label,
  policyname,
  cmd,
  roles,
  qual         AS using_expr,
  with_check   AS check_expr
FROM   pg_policies
WHERE  schemaname = 'public'
  AND  tablename  = 'patients';


-- ----------------------------------------------------------------
-- §4) 인덱스 2개 (patients) + 1개 (recommendation_logs.patient_id)
-- ----------------------------------------------------------------
-- patients 인덱스 (idx_patients_user_id + idx_patients_last_visit)
-- 기대: PASS / 2 / 2
SELECT
  '4-a. patients 인덱스 (user_id + last_visit)' AS check_label,
  CASE WHEN COUNT(*) = 2 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS actual,
  2        AS expected
FROM   pg_indexes
WHERE  schemaname = 'public'
  AND  tablename  = 'patients'
  AND  indexname  IN ('idx_patients_user_id','idx_patients_last_visit');

-- recommendation_logs.patient_id 인덱스 (idx_rec_logs_patient)
-- 기대: PASS / 1 / 1
SELECT
  '4-b. idx_rec_logs_patient (patient_id, created_at DESC)' AS check_label,
  CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS actual,
  1        AS expected
FROM   pg_indexes
WHERE  schemaname = 'public'
  AND  tablename  = 'recommendation_logs'
  AND  indexname  = 'idx_rec_logs_patient';

-- 참고 — patients 인덱스 정의 출력 (디버깅용)
SELECT
  '4-c. patients 인덱스 정의 (참고)' AS check_label,
  indexname,
  indexdef
FROM   pg_indexes
WHERE  schemaname = 'public'
  AND  tablename  = 'patients'
ORDER  BY indexname;


-- ----------------------------------------------------------------
-- 참고) patients row count — 베타 시작 시 0 유지 확인
-- ----------------------------------------------------------------
-- 기대 (베타 시작 직후): 0
-- 베타 운영 중 환자 등록되면 자연스레 증가 — 본 verify 는 시드 0 가정만 검증
SELECT
  'X. patients row count (시드 0 확인 — 참고)' AS check_label,
  COUNT(*) AS actual,
  0        AS expected_at_beta_start
FROM   patients;


-- ============================================================
-- END OF verify-059
-- ============================================================
-- §1~§4 모두 PASS 일 때 059 production 적용 성공:
--   §1 patients 스키마 7-컬럼 + UNIQUE (user_id, label)
--   §2 recommendation_logs.patient_id FK ON DELETE SET NULL
--   §3 RLS own-row only (patients_own FOR ALL)
--   §4 인덱스 3개 (patients × 2 + rec_logs × 1)
-- 후속: sw-backend-dev recommend.js 최근 3 세션 prompt augmentation +
--      sw-frontend-dev 환자 드롭다운 + 신규 등록 UI 연동.
-- ============================================================
