-- ============================================================
-- Migration 007a — ENUM 확장 (반드시 먼저 단독 실행)
-- K-Movement Optimism — Therapeutic Exercise Category
-- 생성일: 2026-04-25
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- ⚠️  PostgreSQL 제약: 새 ENUM 값은 커밋 전에 같은 트랜잭션에서 사용 불가
--     반드시 이 파일을 실행·커밋한 뒤 007-tech-F-therapeutic-exercise.sql 을 실행하세요.
-- ============================================================

ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_f_therapeutic_exercise';
