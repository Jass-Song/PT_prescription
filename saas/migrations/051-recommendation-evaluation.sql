-- Migration 051: 추천 평가 타이밍 재설계 — 평가 상태 추적 및 추천-평가 매칭 (Track C Day 0 DB 인프라)
-- ============================================================
-- 배경:
--   1) recommendation_logs 에 "평가됐는지" 추적 컬럼 부재 → 다음 환자 진입 시
--      pending 추천을 조회해 평가 모달을 띄울 수 없음.
--   2) ratings 에 recommendation_log_id FK 부재 → "어느 추천에 대한 평가인지"
--      매칭 불가 → AI 피드백 루프(어떤 입력 조건/카드가 효과적이었는지) 미완성.
--   3) Track C 평가 타이밍 재설계 (모드 1: "다음 환자 진입 시 직전 추천 평가") 의
--      DB 측 전제 조건. UI/API 단은 별개 트랙.
--
-- 설계 결정:
--   - 평가 상태는 log 단위 (recommendation_logs.evaluation_status). 카드 단위
--     상태는 ratings row 의 존재 여부로 추적.
--   - 한 log 에 여러 카드(보통 5~6) 가 있어도, 첫 카드 평가 시점에
--     log.evaluation_status 가 'rated' 로 전환됨. 모든 카드 평가는 강제하지 않음
--     (UX: 스킵 버튼 제공).
--   - 14일 만료 정책 — 다음 환자 진입 시 즉시 평가 받지만 마지막 환자/휴진 케이스
--     안전망으로 expire_old_pending_evaluations() 함수 제공. 호출 책임은
--     클라이언트 진입 시 / cron (마이그 단독에서는 함수 정의만).
--   - 트리거 함수는 SECURITY DEFINER + SET search_path = public — RLS UPDATE 정책
--     의존성 제거 (마이그 050b 패턴 재사용).
--   - 기존 데이터 일괄 처리:
--       · recommendation_logs : 5/6 이전 모든 row → 'expired' (베타 출시 전 추천은
--         매칭 의미 없음). 5/6 이후는 'pending' 기본값 그대로.
--       · ratings : recommendation_log_id NULL (소급 매칭 불가).
--
-- 의존: migration 017 (recommendation_logs), 041 (ratings), 050b (트리거 패턴)
-- 멱등: 모든 DDL IF NOT EXISTS / DO block / DROP IF EXISTS — 재실행 안전.
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 1. ENUM evaluation_status_enum
-- ────────────────────────────────────────────────────────────
DO $$ BEGIN
  CREATE TYPE evaluation_status_enum AS ENUM (
    'pending',   -- 아직 평가 안 됨 (기본값)
    'rated',     -- 1개 이상 카드 평가 완료 (트리거 자동 전환)
    'expired',   -- 14일 경과 또는 5/6 이전 historical row
    'skipped'    -- 사용자가 명시적으로 스킵 (UI 측에서 UPDATE)
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

COMMENT ON TYPE evaluation_status_enum IS
  'Track C 평가 타이밍 재설계 — recommendation_logs 의 평가 상태. log 단위 추적.';


-- ────────────────────────────────────────────────────────────
-- 2. recommendation_logs 컬럼 추가 (멱등)
-- ────────────────────────────────────────────────────────────
ALTER TABLE recommendation_logs
  ADD COLUMN IF NOT EXISTS evaluation_status evaluation_status_enum
    NOT NULL DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS evaluated_at      TIMESTAMPTZ;

COMMENT ON COLUMN recommendation_logs.evaluation_status IS
  '평가 상태 (pending/rated/expired/skipped). 첫 ratings INSERT 시 트리거가 rated 로 전환.';
COMMENT ON COLUMN recommendation_logs.evaluated_at IS
  '평가 시점 (트리거가 NOW() 자동 기록). NULL = 아직 평가 안 됨 또는 skipped/expired.';


-- ────────────────────────────────────────────────────────────
-- 3. ratings 컬럼 추가 (멱등)
-- ────────────────────────────────────────────────────────────
-- ON DELETE SET NULL — 추천 log 가 삭제되어도 평가 데이터는 보존 (CASCADE 금지)
ALTER TABLE ratings
  ADD COLUMN IF NOT EXISTS recommendation_log_id      UUID
    REFERENCES recommendation_logs(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS recommended_technique_index SMALLINT;

COMMENT ON COLUMN ratings.recommendation_log_id IS
  '평가 대상 추천 log FK. NULL 허용 (수동 평가/historical 호환). ON DELETE SET NULL.';
COMMENT ON COLUMN ratings.recommended_technique_index IS
  '추천 카드 인덱스 (1-based). NULL 허용. AI 피드백 루프에서 어느 카드가 평가됐는지 매칭.';


-- ────────────────────────────────────────────────────────────
-- 4. 인덱스
-- ────────────────────────────────────────────────────────────
-- (a) pending 추천 조회 — "다음 환자 진입 시 직전 pending 추천 1개 조회"
CREATE INDEX IF NOT EXISTS idx_rec_logs_pending_user
  ON recommendation_logs (user_id, evaluation_status, created_at DESC);

-- (b) 동일 (log, card index) 중복 평가 방지 — partial unique
--     recommendation_log_id NULL 인 historical/manual rating 은 제외.
CREATE UNIQUE INDEX IF NOT EXISTS idx_ratings_rec_log_idx
  ON ratings (recommendation_log_id, recommended_technique_index)
  WHERE recommendation_log_id IS NOT NULL
    AND recommended_technique_index IS NOT NULL;


-- ────────────────────────────────────────────────────────────
-- 5. RLS UPDATE 정책 (recommendation_logs)
-- ────────────────────────────────────────────────────────────
-- 트리거가 SECURITY DEFINER 라 RLS 우회 가능하지만, 명시적 UPDATE 호출
-- (예: skipped 전환, expire 함수) 도 RLS 거치도록 정책 추가.
DROP POLICY IF EXISTS "rec_logs_update_own" ON recommendation_logs;
CREATE POLICY "rec_logs_update_own" ON recommendation_logs
  FOR UPDATE
  USING      (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);


-- ────────────────────────────────────────────────────────────
-- 6. 트리거 함수 — ratings INSERT 시 log status 'rated' 전환
-- ────────────────────────────────────────────────────────────
-- SECURITY DEFINER 이유 (마이그 050b 와 동일):
--   ratings INSERT 가 user 컨텍스트에서 발생 → RLS 정책으로 다른 사용자
--   recommendation_logs UPDATE 차단됨. SECURITY DEFINER 로 함수 소유자 권한
--   실행 → RLS 우회. (단, 본 트리거는 본인 log 만 매칭하므로 보안 영향 없음.)
CREATE OR REPLACE FUNCTION update_evaluation_status_on_rating()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- recommendation_log_id 가 매칭된 INSERT 만 처리 (수동 평가는 NULL)
  IF NEW.recommendation_log_id IS NOT NULL THEN
    UPDATE recommendation_logs
       SET evaluation_status = 'rated',
           evaluated_at      = NOW()
     WHERE id = NEW.recommendation_log_id
       AND evaluation_status = 'pending';
    -- 멱등성: pending → rated 만 전환. skipped/expired/rated 는 건드리지 않음.
    -- 두 번째 카드 평가 시 이미 rated 라 UPDATE 0 row 영향 받음.
  END IF;
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION update_evaluation_status_on_rating() IS
  'Track C 평가 타이밍 — ratings INSERT 트리거 (SECURITY DEFINER). 매칭된 log 의 pending → rated 전환. 멱등.';

-- 트리거 등록 (재실행 안전)
DROP TRIGGER IF EXISTS trg_update_evaluation_on_rating ON ratings;
CREATE TRIGGER trg_update_evaluation_on_rating
  AFTER INSERT ON ratings
  FOR EACH ROW
  EXECUTE FUNCTION update_evaluation_status_on_rating();


-- ────────────────────────────────────────────────────────────
-- 7. 만료 처리 함수 (호출은 클라이언트/cron — 본 마이그은 함수 정의만)
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION expire_old_pending_evaluations()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  UPDATE recommendation_logs
     SET evaluation_status = 'expired'
   WHERE evaluation_status = 'pending'
     AND created_at < NOW() - INTERVAL '14 days';

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END;
$$;

COMMENT ON FUNCTION expire_old_pending_evaluations() IS
  '14일 이상 된 pending 추천 → expired 일괄 전환. 클라이언트 진입 시 / cron 호출. 반환: 변경된 row 수.';


-- ────────────────────────────────────────────────────────────
-- 8. 기존 데이터 일괄 처리 (베타 출시 전 historical row 정리)
-- ────────────────────────────────────────────────────────────
-- 정책:
--   · recommendation_logs : 5/6 (현재 시점) 이전 row → 'expired'
--     - 베타 출시 5/5 이전 추천은 평가 매칭 의미 없음.
--   · ratings : recommendation_log_id 는 ALTER ADD COLUMN 시 NULL 기본값 → 소급 매칭 불가.
--
-- 멱등: WHERE evaluation_status = 'pending' 추가로 재실행 시 이미 expired 인 row 영향 없음.

UPDATE recommendation_logs
   SET evaluation_status = 'expired'
 WHERE evaluation_status = 'pending'
   AND created_at < '2026-05-06'::TIMESTAMPTZ;


-- ============================================================
-- 검증 (적용 후 saas/scripts/verify-051.sql 실행)
-- ============================================================
-- 기대:
--   1. evaluation_status_enum 타입 존재 (4 값)
--   2. recommendation_logs.evaluation_status NOT NULL DEFAULT 'pending'
--   3. recommendation_logs.evaluated_at TIMESTAMPTZ NULL
--   4. ratings.recommendation_log_id FK → recommendation_logs.id (ON DELETE SET NULL)
--   5. ratings.recommended_technique_index SMALLINT
--   6. 인덱스 idx_rec_logs_pending_user / idx_ratings_rec_log_idx 존재
--   7. RLS UPDATE policy rec_logs_update_own 존재
--   8. 트리거 trg_update_evaluation_on_rating (AFTER INSERT) 존재
--   9. 함수 expire_old_pending_evaluations 존재 + INTEGER 반환
--  10. 5/6 이전 recommendation_logs 모두 'expired'
--  11. 기존 ratings.recommendation_log_id 모두 NULL
-- ============================================================
