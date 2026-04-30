-- Migration 041: ratings 테이블 — 사용자별 기법 별점 평가 (Phase 1 완성)
-- 배경:
--   v1 technique_feedback (011)는 user_id 없음 → 익명. api/history.js는 ratings를
--   조회하는데 테이블이 부재해 "⭐ 좋은 평가 기법" 탭이 500 에러. 본 마이그레이션은
--   user_id FK 포함한 ratings 테이블을 신설하고 RLS로 사용자별 격리.
-- 설계:
--   - technique_id UUID FK (techniques.id) → PostgREST 임베드 조인 가능 (history.js 사용)
--   - technique_label text NOT NULL → Anatomy Trains 라인·LLM 의역 등 techniques 행 없는
--     경우의 폴백. 두 컬럼을 모두 저장해 향후 마이그레이션 여지 확보.
-- 기존 technique_feedback: 보존 (드롭하지 않음). 익명 파일럿 데이터 손실 방지.

CREATE TABLE IF NOT EXISTS ratings (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  technique_id    uuid REFERENCES techniques(id) ON DELETE SET NULL,
  technique_label text NOT NULL,
  category_key    text,
  region          text,
  acuity          text,
  symptom         text,
  star_rating     integer NOT NULL CHECK (star_rating BETWEEN 1 AND 5),
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ratings_select_own" ON ratings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "ratings_insert_own" ON ratings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_ratings_user_created
  ON ratings(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_ratings_user_star
  ON ratings(user_id, star_rating DESC);

CREATE INDEX IF NOT EXISTS idx_ratings_technique
  ON ratings(technique_id);

COMMENT ON TABLE technique_feedback IS
  'Deprecated v1 anonymous ratings (migration 011). Read-only. New writes go to ratings.';
