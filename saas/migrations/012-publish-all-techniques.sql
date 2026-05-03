-- ============================================================
-- Migration 012 — 전체 테크닉 is_published = true 활성화
-- K-Movement Optimism
-- 생성일: 2026-04-26
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- 배경:
--   Migration 008에서 삽입된 55개 신규 테크닉(카테고리:
--   category_art, category_ctm, category_deep_friction,
--   category_trigger_point, category_anatomy_trains,
--   category_mdt, category_scs, category_pne)이
--   is_published = false로 삽입되어 anon key API 호출 시 표시되지 않음.
--
--   RLS 정책 (005b): is_published = true OR auth.uid() IS NOT NULL
--   anon key 사용 시 auth.uid() = NULL → is_published = false 기법 전체 차단
--
-- 수정:
--   is_published = false인 모든 기법을 true로 일괄 활성화
-- ============================================================

UPDATE techniques
SET is_published = true
WHERE is_published = false;

-- ============================================================
-- 검증 쿼리 (실행 후 아래 주석 해제하여 확인)
-- ============================================================
-- SELECT category, count(*), bool_and(is_published) AS all_published
-- FROM techniques
-- GROUP BY category
-- ORDER BY category;

-- 예상 결과: 모든 카테고리에서 all_published = true
-- 신규 카테고리 포함 확인:
-- SELECT category, count(*) FROM techniques
-- WHERE category IN (
--   'category_art', 'category_ctm', 'category_deep_friction',
--   'category_trigger_point', 'category_anatomy_trains',
--   'category_mdt', 'category_scs', 'category_pne'
-- )
-- GROUP BY category
-- ORDER BY category;
