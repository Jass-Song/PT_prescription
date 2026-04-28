-- ============================================================
-- Migration 039 — body_region NOT NULL 제약 해제
-- 배경: PNE 등 범용(전신) 기법은 특정 body_region에 속하지 않음
--       체계적 교육(PNE), 일부 anatomy_trains 기법이 해당
-- 실행 순서: 039 → 038 (재실행)
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

-- body_region 컬럼 NULL 허용으로 변경
ALTER TABLE techniques
  ALTER COLUMN body_region DROP NOT NULL;

-- 확인
SELECT column_name, is_nullable, data_type
FROM information_schema.columns
WHERE table_name = 'techniques'
  AND column_name = 'body_region';
