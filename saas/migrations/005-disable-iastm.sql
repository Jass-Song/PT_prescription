-- ============================================================
-- Migration 005 — IASTM 기법 일시 비활성화
-- K-Movement Optimism
-- 생성일: 2026-04-25
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- ⚠️  IASTM 콘텐츠 준비 완료 후 재활성화:
--     UPDATE techniques SET is_active = true, updated_at = NOW()
--     WHERE category = 'category_iastm';
-- ============================================================

UPDATE techniques
SET is_active  = false,
    updated_at = NOW()
WHERE category = 'category_iastm';

-- 확인 쿼리
-- SELECT name_ko, is_active FROM techniques WHERE category = 'category_iastm';
