-- ============================================================
-- Migration 008a — ENUM 확장 (반드시 먼저 단독 실행)
-- K-Movement Optimism — 7개 신규 테크닉 카테고리
-- 생성일: 2026-04-25
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- ⚠️  PostgreSQL 제약: 새 ENUM 값은 커밋 전에 같은 트랜잭션에서 사용 불가
--     반드시 이 파일을 실행·커밋한 뒤 008-missing-techniques.sql 을 실행하세요.
-- ============================================================

-- 연부조직 기법 신규 카테고리
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_art';           -- Active Release Technique
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_ctm';           -- Connective Tissue Massage
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_deep_friction'; -- Deep Transverse Friction Massage
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_trigger_point'; -- Trigger Point Release
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_anatomy_trains'; -- Anatomy Trains

-- 특수 기법 신규 카테고리
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_mdt';  -- McKenzie Method / MDT
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_scs';  -- Strain-Counterstrain
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_pne';  -- Pain Neuroscience Education
