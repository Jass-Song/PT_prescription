-- Migration 013 (REVISED): 기존 테이블 최대 활용 + 최소 신규 테이블
-- 목적: 크로스 디바이스 설정 동기화, 사용자별 AI 추천 이력 추적, 개인화 기반
-- 전략:
--   - 설정 저장 → user_profiles(기존) 에 pt_settings 컬럼 추가
--   - 추천 이력 → recommendation_logs(신규, 불가피):
--       usage_logs.technique_id UUID NOT NULL FK 제약으로 세션 단위 로깅 불가.
--       Anatomy Trains 라인은 DB UUID 없음. usage_logs는 기법 단위 추적용으로 설계됨.

-- ── 1. user_profiles 확장 — PT 기본 설정 저장 ────────────────────────────────
ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS pt_settings jsonb
    DEFAULT '{"mt_groups":["mt_joint","mt_soft"],"ex_groups":[]}';

-- ── 2. recommendation_logs — AI 추천 세션 이력 ──────────────────────────────
CREATE TABLE IF NOT EXISTS recommendation_logs (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  region                 text,
  acuity                 text,
  symptom                text,
  selected_categories    text[],
  recommended_techniques jsonb,   -- [{name, category_key}]
  created_at             timestamptz DEFAULT now()
);

ALTER TABLE recommendation_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "rec_logs_select_own" ON recommendation_logs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "rec_logs_insert_own" ON recommendation_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_rec_logs_user_created
  ON recommendation_logs(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_rec_logs_categories
  ON recommendation_logs USING GIN(selected_categories);

-- ── 3. 관리자용 분석 뷰 ─────────────────────────────────────────────────────
CREATE OR REPLACE VIEW recommendation_analytics AS
SELECT
  rl.id,
  rl.user_id,
  up.display_name,
  rl.region,
  rl.acuity,
  rl.symptom,
  rl.selected_categories,
  rl.recommended_techniques,
  rl.created_at
FROM recommendation_logs rl
LEFT JOIN user_profiles up ON up.id = rl.user_id
ORDER BY rl.created_at DESC;
