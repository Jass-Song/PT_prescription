-- ============================================================
-- Migration 002a — ENUM 확장 + UNIQUE 제약 (반드시 먼저 단독 실행)
-- K-Movement Optimism — Manual Therapy Techniques SaaS
-- ============================================================
-- ⚠️  PostgreSQL 제약: 새 ENUM 값은 커밋 전에 같은 트랜잭션에서 사용 불가 (ERROR 55P04)
--     반드시 이 파일을 실행·커밋한 뒤 002-soft-tissue-techniques.sql 을 실행하세요.
-- ============================================================

-- 1. ENUM 확장
ALTER TYPE technique_category ADD VALUE IF NOT EXISTS 'category_e_soft_tissue';

-- 2. abbreviation 유니크 인덱스 추가 (ON CONFLICT (abbreviation) 에 필요)
--    ALTER TABLE ADD CONSTRAINT은 IF NOT EXISTS 미지원 → CREATE UNIQUE INDEX 사용
CREATE UNIQUE INDEX IF NOT EXISTS uq_techniques_abbreviation
  ON techniques (abbreviation)
  WHERE abbreviation IS NOT NULL;
