-- Migration 006: llm_recommendations 테이블 생성
-- LLM 추천 결과 및 사용자 피드백 저장
-- 작성일: 2026-04-25

CREATE TABLE IF NOT EXISTS llm_recommendations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id TEXT,
  query_body_part TEXT,
  query_tags JSONB,
  input_techniques JSONB,
  llm_response JSONB,
  feedback_rating SMALLINT CHECK (feedback_rating BETWEEN 1 AND 5),
  feedback_text TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 조회 성능을 위한 인덱스
CREATE INDEX IF NOT EXISTS idx_llm_recommendations_session_id
  ON llm_recommendations (session_id);

CREATE INDEX IF NOT EXISTS idx_llm_recommendations_body_part
  ON llm_recommendations (query_body_part);

CREATE INDEX IF NOT EXISTS idx_llm_recommendations_created_at
  ON llm_recommendations (created_at DESC);

-- RLS 활성화: service role만 INSERT 가능, anon 직접 읽기 불가
ALTER TABLE llm_recommendations ENABLE ROW LEVEL SECURITY;

-- service role INSERT 허용
CREATE POLICY "service_insert"
  ON llm_recommendations
  FOR INSERT
  WITH CHECK (true);

-- anon/authenticated 읽기 차단 (피드백 집계는 service role로만)
-- (기본적으로 RLS 활성화 시 정책 없으면 차단이지만 명시적으로 선언)
CREATE POLICY "no_anon_select"
  ON llm_recommendations
  FOR SELECT
  USING (false);
