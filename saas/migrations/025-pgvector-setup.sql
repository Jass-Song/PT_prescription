-- Migration 025: pgvector 시멘틱 검색 설정
-- Supabase SQL Editor에서 실행하세요.
-- 실행 전제: Supabase pgvector extension 사용 가능

-- 1. pgvector extension 활성화
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. 임베딩 테이블 생성
CREATE TABLE IF NOT EXISTS technique_embeddings (
  id UUID PRIMARY KEY REFERENCES techniques(id) ON DELETE CASCADE,
  embedding vector(1024),       -- voyage-3-lite 차원수
  embedded_text TEXT,            -- 임베딩에 사용한 원본 텍스트 (디버깅용)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. 벡터 유사도 검색 인덱스 (IVFFlat — Supabase 권장)
-- techniques 194개 기준: sqrt(194) ≈ 14 → 반올림하여 20 lists
CREATE INDEX IF NOT EXISTS technique_embeddings_embedding_idx
  ON technique_embeddings
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 20);

-- 4. updated_at 자동 갱신 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER technique_embeddings_updated_at
  BEFORE UPDATE ON technique_embeddings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 5. 시멘틱 매치 함수 (recommend.js에서 RPC로 호출)
CREATE OR REPLACE FUNCTION match_techniques(
  query_embedding vector(1024),
  match_threshold float DEFAULT 0.3,
  match_count int DEFAULT 10
)
RETURNS TABLE (
  id UUID,
  similarity float
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    te.id,
    1 - (te.embedding <=> query_embedding) AS similarity
  FROM technique_embeddings te
  WHERE 1 - (te.embedding <=> query_embedding) > match_threshold
  ORDER BY te.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- 6. RLS 정책: technique_embeddings는 techniques와 동일 접근 권한
ALTER TABLE technique_embeddings ENABLE ROW LEVEL SECURITY;

-- 인증된 사용자 읽기 허용
CREATE POLICY "Authenticated users can read embeddings"
  ON technique_embeddings
  FOR SELECT
  TO authenticated
  USING (true);

-- service_role만 쓰기 허용 (embed-techniques.js 스크립트 전용)
CREATE POLICY "Service role can manage embeddings"
  ON technique_embeddings
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
