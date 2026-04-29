-- ============================================================
-- Migration 040 — technique_embeddings RLS 수정
-- 배경: RLS 정책이 authenticated 전용이어서 anon 키로 호출하는
--       Vercel serverless API (match_techniques RPC, 직접 조회)가
--       모두 빈 결과를 반환했음.
--       match_techniques도 SECURITY DEFINER 없이 plpgsql로 작성되어
--       호출자(anon) 권한으로 실행 → RLS 차단.
-- 수정:
--   1. technique_embeddings anon 읽기 정책 추가
--   2. match_techniques 함수 SECURITY DEFINER 재생성
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

-- 1. anon 읽기 정책 추가
CREATE POLICY IF NOT EXISTS "Anon can read embeddings"
  ON technique_embeddings
  FOR SELECT
  TO anon
  USING (true);

-- 2. match_techniques 함수 SECURITY DEFINER로 재생성
--    (함수 소유자 권한으로 실행 → anon 호출에도 RLS 우회)
--    voyage-3-lite 실제 차원 = 512 (025b에서 1024→512 변경됨)
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
SECURITY DEFINER
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

-- 확인
SELECT policyname, roles, cmd
FROM pg_policies
WHERE tablename = 'technique_embeddings'
ORDER BY policyname;
