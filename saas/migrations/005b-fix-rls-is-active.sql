-- ============================================================
-- Migration 005b — techniques RLS 정책에 is_active 조건 추가
-- K-Movement Optimism
-- 생성일: 2026-04-25
-- ============================================================
-- 문제: 기존 정책이 auth.uid() IS NOT NULL 이면 is_active 무관하게 전체 노출
-- 수정: is_active = true 조건 추가 → 비활성 기법은 관리자도 API로 조회 불가
-- ============================================================

DROP POLICY IF EXISTS "techniques_select_published" ON techniques;

CREATE POLICY "techniques_select_published"
  ON techniques FOR SELECT
  USING (
    is_active = true
    AND (is_published = true OR auth.uid() IS NOT NULL)
  );
