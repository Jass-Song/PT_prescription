-- Migration 025b: technique_embeddings 벡터 차원 수정 (1024 → 512)
-- voyage-3-lite 실제 차원수는 512
-- 025-pgvector-setup.sql 실행 후 이 파일을 실행하세요.

-- 기존 인덱스 제거 (타입 변경 전 필수)
DROP INDEX IF EXISTS technique_embeddings_embedding_idx;

-- 컬럼 타입 변경
ALTER TABLE technique_embeddings
  ALTER COLUMN embedding TYPE vector(512);

-- match_techniques 함수도 512차원으로 재생성
CREATE OR REPLACE FUNCTION match_techniques(
  query_embedding vector(512),
  match_threshold float DEFAULT 0.3,
  match_count int DEFAULT 20
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

-- 인덱스 재생성 (512차원)
CREATE INDEX IF NOT EXISTS technique_embeddings_embedding_idx
  ON technique_embeddings
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 20);
