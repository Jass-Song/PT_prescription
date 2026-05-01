-- ============================================================
-- Migration 044 — applicable_muscles JSONB 컬럼 추가
-- 배경:
--   1 테크닉 = 1 근육 패턴 한계로 임상적으로 관련된 다부위가 노출되지 않음
--   (예: 요추 만성 방사통에서 ART 추천 시 척추세움근만 나오고 장요근/요방형근 누락)
--   → 한 테크닉 행에 적용 가능 근육 다수를 JSONB 배열로 저장하여
--     모달리티(카테고리) 단위 카드에서 다부위 동시 노출 가능하게 함
-- 변경:
--   - techniques 테이블에 applicable_muscles JSONB 컬럼 추가 (기본 [])
--   - GIN 인덱스 추가 (향후 근육별 검색·필터링 대비)
-- 관련:
--   - 045-backfill-applicable-muscles.sql (1차 백필)
--   - api/recommend.js (모달리티 카드 + applicable_muscles 노출)
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

ALTER TABLE techniques
  ADD COLUMN IF NOT EXISTS applicable_muscles JSONB NOT NULL DEFAULT '[]'::jsonb;

COMMENT ON COLUMN techniques.applicable_muscles IS
  '한 테크닉이 임상적으로 적용 가능한 근육·구조 리스트. 형식: [{"muscle_ko":"척추세움근","muscle_en":"erector spinae","segment":"L1-L5"}]. 빈 배열은 비-근육 표적(관절가동술/MDT/PNE/d_neural 등)을 의미.';

CREATE INDEX IF NOT EXISTS idx_techniques_applicable_muscles
  ON techniques USING gin(applicable_muscles);

-- 확인
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'techniques' AND column_name = 'applicable_muscles';
