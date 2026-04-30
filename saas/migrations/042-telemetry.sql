-- Migration 042: 프로덕션 텔레메트리
-- 1) error_logs — 클라이언트/서버 에러 집계 (DIY Sentry 대체, 파일럿 단계용)
-- 2) recommendation_logs.latency_ms — 추천 요청 총 응답 시간 추적

ALTER TABLE recommendation_logs
  ADD COLUMN IF NOT EXISTS latency_ms integer;

CREATE TABLE IF NOT EXISTS error_logs (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source       text NOT NULL,                 -- 'client' | 'server'
  message      text NOT NULL,
  stack        text,
  url          text,
  user_agent   text,
  http_status  integer,
  request_path text,
  context      jsonb,
  user_id      uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- RLS 활성화 + INSERT/SELECT 정책 미정의 → service role만 읽기/쓰기 가능.
-- /api/log-error는 SUPABASE_SERVICE_KEY로 인서트, 조회는 Supabase 대시보드에서 service role로.
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_error_logs_created ON error_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_error_logs_user    ON error_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_error_logs_source  ON error_logs(source, created_at DESC);
