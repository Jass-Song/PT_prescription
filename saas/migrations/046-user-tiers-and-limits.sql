-- ============================================================
-- Migration 046 — 사용자 등급 + 등급별 일일 한도
-- 배경:
--   현재 DAILY_LIMIT=20 hardcoded → 사용자 차등 불가, 결제 모델 미대비
--   Option C 채택 — 베타/프로/어드민 등급 시스템 도입
-- 목표:
--   1. user_tiers — 사용자별 등급 매핑 (기본 'beta')
--   2. tier_limits — 등급별 일일 한도 (어드민이 변경 가능)
--   3. RLS — 일반 사용자는 본인 등급 조회만, 변경은 admin tier만
-- 후속:
--   - api/recommend.js: getUserDailyLimit() 동적 조회
--   - api/admin.js: 등급/한도 CRUD 엔드포인트
--   - debug/admin.html: 어드민 UI
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

-- ── 1. tier_limits — 등급별 한도 ──
CREATE TABLE IF NOT EXISTS tier_limits (
  tier         TEXT PRIMARY KEY,
  daily_limit  INT NOT NULL CHECK (daily_limit >= 0),
  description  TEXT,
  updated_at   TIMESTAMPTZ DEFAULT now(),
  updated_by   UUID REFERENCES auth.users(id)
);

-- 초기 등급 3종 (멱등 — ON CONFLICT 처리)
INSERT INTO tier_limits (tier, daily_limit, description) VALUES
  ('beta',  20,     '베타 무료 사용자 (기본 등급)'),
  ('pro',   100,    '프로 구독자'),
  ('admin', 999999, '관리자 (사실상 무제한)')
ON CONFLICT (tier) DO NOTHING;

COMMENT ON TABLE tier_limits IS '등급별 일일 추천 한도 — admin tier만 수정 가능';
COMMENT ON COLUMN tier_limits.daily_limit IS '0이면 모든 호출 차단(긴급 정지), 999999는 사실상 무제한';

-- ── 2. user_tiers — 사용자별 등급 ──
CREATE TABLE IF NOT EXISTS user_tiers (
  user_id      UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  tier         TEXT NOT NULL DEFAULT 'beta' REFERENCES tier_limits(tier),
  notes        TEXT,
  updated_at   TIMESTAMPTZ DEFAULT now(),
  updated_by   UUID REFERENCES auth.users(id)
);

CREATE INDEX IF NOT EXISTS idx_user_tiers_tier ON user_tiers(tier);

COMMENT ON TABLE user_tiers IS '사용자별 등급 매핑 — 행 없으면 기본 beta';

-- ── 3. is_admin() helper function ──
-- RLS 정책에서 사용 + api/admin.js에서도 호출 가능
CREATE OR REPLACE FUNCTION is_admin(check_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_tiers
    WHERE user_id = check_user_id AND tier = 'admin'
  );
END;
$$;

COMMENT ON FUNCTION is_admin IS '주어진 user_id가 admin tier인지 반환';

-- ── 4. RLS 정책 ──
ALTER TABLE tier_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_tiers ENABLE ROW LEVEL SECURITY;

-- tier_limits — 인증 사용자 모두 SELECT 가능, 수정은 admin만
DROP POLICY IF EXISTS "tier_limits select for authenticated" ON tier_limits;
CREATE POLICY "tier_limits select for authenticated"
  ON tier_limits FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "tier_limits update by admin" ON tier_limits;
CREATE POLICY "tier_limits update by admin"
  ON tier_limits FOR UPDATE
  TO authenticated
  USING (is_admin(auth.uid()))
  WITH CHECK (is_admin(auth.uid()));

DROP POLICY IF EXISTS "tier_limits insert by admin" ON tier_limits;
CREATE POLICY "tier_limits insert by admin"
  ON tier_limits FOR INSERT
  TO authenticated
  WITH CHECK (is_admin(auth.uid()));

-- user_tiers — 사용자 본인 SELECT, 수정/INSERT는 admin만
DROP POLICY IF EXISTS "user_tiers select own or admin" ON user_tiers;
CREATE POLICY "user_tiers select own or admin"
  ON user_tiers FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR is_admin(auth.uid()));

DROP POLICY IF EXISTS "user_tiers update by admin" ON user_tiers;
CREATE POLICY "user_tiers update by admin"
  ON user_tiers FOR UPDATE
  TO authenticated
  USING (is_admin(auth.uid()))
  WITH CHECK (is_admin(auth.uid()));

DROP POLICY IF EXISTS "user_tiers insert by admin" ON user_tiers;
CREATE POLICY "user_tiers insert by admin"
  ON user_tiers FOR INSERT
  TO authenticated
  WITH CHECK (is_admin(auth.uid()));

-- anon 키 (서버 fetch에서 user_tier·tier_limit 조회) 읽기 허용
DROP POLICY IF EXISTS "tier_limits select for anon" ON tier_limits;
CREATE POLICY "tier_limits select for anon"
  ON tier_limits FOR SELECT
  TO anon
  USING (true);

-- 서버 측에서 user 토큰으로 본인 user_tier 조회 가능 (이미 위 정책으로 처리됨)

-- ── 5. 첫 admin 시드 ──
-- ⚠️ 실행 전 대표님 본인의 auth.users.id 확인 필요
-- Supabase Dashboard → Authentication → Users 에서 이메일로 검색 후 UUID 복사
-- 아래 INSERT의 'YOUR-USER-ID' 자리에 붙여넣고 주석 해제하여 실행

-- INSERT INTO user_tiers (user_id, tier, notes)
-- VALUES ('YOUR-USER-ID-HERE', 'admin', '초기 어드민 — 대표님')
-- ON CONFLICT (user_id) DO UPDATE SET tier = 'admin';

-- 또는 이메일 기반 자동 시드:
-- INSERT INTO user_tiers (user_id, tier, notes)
-- SELECT id, 'admin', '초기 어드민' FROM auth.users WHERE email = 'YOUR-EMAIL@example.com'
-- ON CONFLICT (user_id) DO UPDATE SET tier = 'admin';

-- ── 확인 쿼리 ──
SELECT tier, daily_limit, description FROM tier_limits ORDER BY daily_limit;
SELECT COUNT(*) AS total_users, tier FROM user_tiers GROUP BY tier;
