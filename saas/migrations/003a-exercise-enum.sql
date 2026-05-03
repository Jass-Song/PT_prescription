-- ============================================================
-- Migration 003a — ENUM 확장 (반드시 먼저 단독 실행)
-- K-Movement Optimism — Exercise & Neural Techniques
-- ============================================================
-- ⚠️  PostgreSQL 제약: 새 ENUM 값은 커밋 전에 같은 트랜잭션에서 사용 불가
--     반드시 이 파일을 실행·커밋한 뒤 003-exercise-setup.sql 을 실행하세요.
-- ============================================================

ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_c_exercise';
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_exercise01';
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_d_neural';

-- unique index는 002a에서 이미 생성됨 — 중복 생성 불필요
