-- Migration 043: session_logs — 추천 요청 세션 자동 기록
-- 기존 usage_logs(technique_id NOT NULL)와 달리 세션 단위로 부위·acuity·증상 집계 가능
-- recommend.js logSessionUsage() 헬퍼가 fire-and-forget으로 INSERT

CREATE TABLE IF NOT EXISTS session_logs (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  region       text,
  acuity       text,
  symptom      text,
  categories   text[],
  result_count integer,
  response_ms  integer,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_session_logs_user    ON session_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_session_logs_created ON session_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_session_logs_region  ON session_logs(region, acuity, symptom);

-- RLS: service role만 읽기/쓰기 (logSessionUsage는 SUPABASE_SERVICE_ROLE_KEY 사용)
ALTER TABLE session_logs ENABLE ROW LEVEL SECURITY;

-- 사용자 본인 기록은 SELECT 허용 (대시보드용)
CREATE POLICY "session_logs_select_own"
  ON session_logs FOR SELECT
  USING (auth.uid() = user_id);
