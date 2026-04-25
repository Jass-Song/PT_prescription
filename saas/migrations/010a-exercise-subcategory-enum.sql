-- ============================================================
-- Migration 010a — ENUM 확장 (반드시 먼저 단독 실행)
-- K-Movement Optimism — 운동 처방 세부 카테고리 4개
-- 생성일: 2026-04-25
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- ⚠️  PostgreSQL 제약: 새 ENUM 값은 커밋 전에 같은 트랜잭션에서 사용 불가
--     반드시 이 파일을 실행·커밋한 뒤 010-exercise-subcategory-categories.sql 을 실행하세요.
-- ============================================================

ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_ex_neuromuscular'; -- 신경근·운동조절 훈련
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_ex_resistance';    -- 근력·저항성 운동
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_ex_aerobic';       -- 유산소·활동성 운동
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_ex_bodyweight';    -- 자체중량·방향성 운동
