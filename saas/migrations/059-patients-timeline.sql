-- ============================================================
-- Migration 059 — patients 테이블 + recommendation_logs.patient_id FK
-- ============================================================
-- 목적: Patient Timeline P1 — 환자별 세션 history 트래킹 도구화.
--      베타 출시 직전 마지막 DB 작업. 다음 두 가지를 도입:
--        (a) patients 테이블 신설 — PT 별 환자 레지스트리
--            (라벨 텍스트 식별 + 방문 통계 + PT 메모)
--        (b) recommendation_logs.patient_id (UUID, NULLABLE FK) 추가 —
--            기존 추천 로그를 환자별로 묶고 최근 3 세션 prompt augmentation 에 활용
--
-- 대표님 결정 (2026-05-12):
--   - 식별 방식: 드롭다운 + 신규 등록 (구조적 UI)
--   - History 깊이: 최근 3 세션 (LLM 프롬프트 augmentation)
--
-- 락인 스펙 (다른 에이전트와 contract — 변경 금지):
--   patients (
--     id UUID PK, user_id UUID FK auth.users CASCADE,
--     label TEXT NOT NULL,
--     created_at TIMESTAMPTZ DEFAULT NOW(),
--     last_visit_at TIMESTAMPTZ DEFAULT NOW(),
--     visit_count INTEGER NOT NULL DEFAULT 0,
--     notes TEXT,
--     UNIQUE (user_id, label)
--   )
--   recommendation_logs ADD COLUMN patient_id UUID REFERENCES patients(id) ON DELETE SET NULL
--
-- 멱등성:
--   - CREATE TABLE IF NOT EXISTS / ADD COLUMN IF NOT EXISTS /
--     CREATE INDEX IF NOT EXISTS / CREATE POLICY IF NOT EXISTS 전반 사용
--   - 본 마이그 재실행 시 POST-CHECK 만 다시 출력, 데이터 변경 0
--
-- 데이터 시드:
--   - 0 row (베타 시작 시 환자 0 명 상태로 출발 — 시드 절대 금지)
--   - 기존 recommendation_logs.patient_id 는 모두 NULL (기존 로그 보존)
--
-- 영향 범위:
--   - 신규 테이블 patients (RLS ON, own-row only)
--   - recommendation_logs 컬럼 1개 추가 (NULLABLE FK, 기존 정책 무영향)
--   - schema.sql 동기화 별도 커밋
--
-- 롤백 (필요 시 — 베타 데이터 발생 전 한정):
--   ALTER TABLE recommendation_logs DROP COLUMN IF EXISTS patient_id;
--   DROP TABLE IF EXISTS patients CASCADE;
--
-- 전제: auth.users / recommendation_logs (마이그 017) production 적용 완료
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- Author : sw-db-architect | 2026-05-12
-- ============================================================

BEGIN;

-- ----------------------------------------------------------------
-- §1) patients 테이블 — PT 별 환자 레지스트리
-- ----------------------------------------------------------------
-- 식별: label TEXT (PT 자유 입력 — 이름/별명/번호)
-- 충돌 방지: UNIQUE (user_id, label) — 같은 PT 의 동명 환자 중복 차단
-- 삭제 정책: ON DELETE CASCADE (auth.users) — PT 탈퇴 시 환자 데이터 동반 정리

CREATE TABLE IF NOT EXISTS patients (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id        UUID NOT NULL
                   REFERENCES auth.users(id) ON DELETE CASCADE,
  label          TEXT NOT NULL,
                   -- PT 가 입력한 환자 식별 텍스트 (이름·별명·번호)
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  last_visit_at  TIMESTAMPTZ DEFAULT NOW(),
  visit_count    INTEGER NOT NULL DEFAULT 0,
  notes          TEXT,
                   -- PT 메모 (선택)
  UNIQUE (user_id, label)
                   -- 같은 PT 의 동명 환자 라벨 충돌 방지
);

-- ----------------------------------------------------------------
-- §2) patients 인덱스
-- ----------------------------------------------------------------
-- idx_patients_user_id        — PT 본인 환자 목록 조회 (드롭다운 로딩)
-- idx_patients_last_visit     — 최근 방문 순 정렬 (드롭다운 정렬 / 활성 환자 표시)

CREATE INDEX IF NOT EXISTS idx_patients_user_id
  ON patients(user_id);

CREATE INDEX IF NOT EXISTS idx_patients_last_visit
  ON patients(user_id, last_visit_at DESC);

-- ----------------------------------------------------------------
-- §3) recommendation_logs.patient_id FK 추가
-- ----------------------------------------------------------------
-- NULLABLE — 기존 로그 (베타 이전) 는 환자 미연결 상태로 보존
-- ON DELETE SET NULL — 환자 레코드 삭제 시 로그 자체는 유지 (분석 데이터 보존)

ALTER TABLE recommendation_logs
  ADD COLUMN IF NOT EXISTS patient_id UUID
    REFERENCES patients(id) ON DELETE SET NULL;

-- 환자별 timeline 조회 인덱스 — (patient_id, created_at DESC) 로 최근 3 세션 빠르게 슬라이스
CREATE INDEX IF NOT EXISTS idx_rec_logs_patient
  ON recommendation_logs(patient_id, created_at DESC);

-- ----------------------------------------------------------------
-- §4) RLS — patients 본인 row 만 (own-row only)
-- ----------------------------------------------------------------
-- USING + WITH CHECK 모두 user_id = auth.uid() 강제 —
-- SELECT / INSERT / UPDATE / DELETE 전부 본인 환자에만 가능.

ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS patients_own
  ON patients
  FOR ALL
  TO authenticated
  USING      (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ----------------------------------------------------------------
-- §5) POST-CHECK — 적용 결과 NOTICE (베타 시작 시 환자 0 row 유지 확인)
-- ----------------------------------------------------------------
DO $$
DECLARE
  v_patients_count    INT;
  v_patient_id_exists BOOLEAN;
  v_rls_enabled       BOOLEAN;
  v_policy_count      INT;
  v_index_count       INT;
BEGIN
  -- patients row 수 (베타 시드 0 확인)
  SELECT COUNT(*) INTO v_patients_count FROM patients;

  -- recommendation_logs.patient_id 컬럼 존재 확인
  SELECT EXISTS (
    SELECT 1
    FROM   information_schema.columns
    WHERE  table_schema = 'public'
      AND  table_name   = 'recommendation_logs'
      AND  column_name  = 'patient_id'
  ) INTO v_patient_id_exists;

  -- patients RLS 활성 여부
  SELECT relrowsecurity INTO v_rls_enabled
  FROM   pg_class
  WHERE  oid = 'public.patients'::regclass;

  -- patients_own 정책 존재 확인
  SELECT COUNT(*) INTO v_policy_count
  FROM   pg_policies
  WHERE  schemaname = 'public'
    AND  tablename  = 'patients'
    AND  policyname = 'patients_own';

  -- 인덱스 2개 (idx_patients_user_id + idx_patients_last_visit) 확인
  SELECT COUNT(*) INTO v_index_count
  FROM   pg_indexes
  WHERE  schemaname = 'public'
    AND  tablename  = 'patients'
    AND  indexname  IN ('idx_patients_user_id','idx_patients_last_visit');

  RAISE NOTICE '------------------------------------------------------------';
  RAISE NOTICE '059 POST-CHECK';
  RAISE NOTICE '  patients row count            : % (expected 0 — 베타 시작)', v_patients_count;
  RAISE NOTICE '  recommendation_logs.patient_id: % (expected true)',  v_patient_id_exists;
  RAISE NOTICE '  patients RLS enabled          : % (expected true)',  v_rls_enabled;
  RAISE NOTICE '  patients_own policy count     : % (expected 1)',     v_policy_count;
  RAISE NOTICE '  patients indexes (user_id,last_visit): % (expected 2)', v_index_count;
  RAISE NOTICE '------------------------------------------------------------';

  IF v_patients_count <> 0 THEN
    RAISE EXCEPTION '059 FAIL — patients 테이블에 시드 데이터 존재 (베타 시작 시 0 row 유지 필요): %', v_patients_count;
  END IF;
  IF NOT v_patient_id_exists THEN
    RAISE EXCEPTION '059 FAIL — recommendation_logs.patient_id 컬럼 미생성';
  END IF;
  IF NOT v_rls_enabled THEN
    RAISE EXCEPTION '059 FAIL — patients RLS 비활성';
  END IF;
  IF v_policy_count <> 1 THEN
    RAISE EXCEPTION '059 FAIL — patients_own 정책 누락 (count=%)', v_policy_count;
  END IF;
  IF v_index_count <> 2 THEN
    RAISE EXCEPTION '059 FAIL — patients 인덱스 누락 (count=%, expected 2)', v_index_count;
  END IF;
END $$;

COMMIT;

-- ============================================================
-- END OF Migration 059
-- ============================================================
-- 후속: saas/scripts/verify-059.sql §1~§4 실행 → 4 항목 PASS 확인 →
--       sw-backend-dev (recommend.js 환자 history augmentation) +
--       sw-frontend-dev (드롭다운 + 신규 등록 UI) 연동.
-- ============================================================
