-- ============================================================
-- Migration 004a — 카테고리 재구조화 ENUM 확장 (먼저 단독 실행)
-- K-Movement Optimism — Category Hierarchy Restructure
-- 생성일: 2026-04-25
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- ⚠️  PostgreSQL 제약: 새 ENUM 값은 커밋 전에 같은 트랜잭션에서 사용 불가
--     반드시 이 파일을 실행·커밋한 뒤 004b-restructure-categories.sql 을 실행하세요.
-- ============================================================

ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_joint_mobilization';
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_mulligan';
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_iastm';
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_mfr';
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_exercise01';
-- category_d_neural은 003a에서 이미 추가됨 — 중복 추가 불필요
