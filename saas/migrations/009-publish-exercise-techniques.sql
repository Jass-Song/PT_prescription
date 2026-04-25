-- ============================================================
-- Migration 009 — 운동 처방 기법 is_published = true 설정
-- K-Movement Optimism
-- 생성일: 2026-04-25
-- ============================================================
-- 배경:
--   Migration 007에서 삽입된 category_f_therapeutic_exercise 기법 9개가
--   is_published = false로 삽입됨.
--   005b RLS 정책: is_published = true OR auth.uid() IS NOT NULL
--   API는 anon key 사용(auth.uid() = NULL) → is_published = false 기법 전체 차단
-- 수정:
--   운동 처방 관련 두 카테고리 기법 전체를 is_published = true로 업데이트
-- ============================================================

UPDATE techniques
SET is_published = true
WHERE category IN ('category_exercise01', 'category_f_therapeutic_exercise');

-- 검증 쿼리
-- SELECT category, count(*), bool_and(is_published) as all_published
-- FROM techniques
-- WHERE category IN ('category_exercise01', 'category_f_therapeutic_exercise')
-- GROUP BY category;
