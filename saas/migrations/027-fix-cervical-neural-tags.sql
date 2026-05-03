-- ============================================================
-- Migration 027 — 경추 신경가동술 target_tags 수정
-- NEU-CX-Slider, NEU-CX-Tensioner에 'acute' 추가
-- (migration 016 기존 d_neural 기법과 동일한 태그 세트로 통일)
-- 생성일: 2026-04-28
-- 작성자: sw-db-architect
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

UPDATE techniques
SET target_tags = ARRAY['acute', 'subacute', 'chronic', 'sensitized']
WHERE abbreviation IN ('NEU-CX-Slider', 'NEU-CX-Tensioner');
