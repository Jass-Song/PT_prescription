-- ============================================================
-- Migration 047 — tier 컬럼을 user_profiles로 이전 (046 정정)
-- 배경:
--   046에서 신규 user_tiers 테이블을 만들었으나 user_profiles가 이미 존재.
--   별도 테이블은 불필요한 join 발생 → user_profiles에 tier 컬럼 통합.
-- 안전성:
--   - 046이 이미 실행된 경우: user_tiers 데이터를 user_profiles로 이전 후 DROP
--   - 046이 실행되지 않은 경우: 그냥 user_profiles에 tier 추가 (no-op for migration)
-- 유지:
--   - tier_limits 테이블 (등급별 한도 정의 마스터 — 별도 관심사)
--   - is_admin() 함수 (참조 테이블만 변경)
-- 후속:
--   - api/recommend.js / api/admin.js: user_tiers → user_profiles 조회 변경
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

-- ── 1. user_profiles에 tier 컬럼 추가 ──
ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS tier TEXT NOT NULL DEFAULT 'beta';

-- tier_limits 참조 무결성 (FK)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'user_profiles_tier_fkey'
  ) THEN
    ALTER TABLE user_profiles
      ADD CONSTRAINT user_profiles_tier_fkey
      FOREIGN KEY (tier) REFERENCES tier_limits(tier);
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_user_profiles_tier ON user_profiles(tier);

COMMENT ON COLUMN user_profiles.tier IS '사용자 등급 (beta/pro/admin) — tier_limits FK';

-- ── 2. user_tiers → user_profiles 데이터 이전 (046이 실행된 경우만) ──
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_tiers') THEN
    -- user_tiers의 데이터를 user_profiles에 반영
    UPDATE user_profiles up
    SET tier = ut.tier
    FROM user_tiers ut
    WHERE up.id = ut.user_id;

    -- user_profiles에 행이 없는 user_tiers 항목은 새로 INSERT
    INSERT INTO user_profiles (id, tier)
    SELECT ut.user_id, ut.tier
    FROM user_tiers ut
    LEFT JOIN user_profiles up ON up.id = ut.user_id
    WHERE up.id IS NULL
    ON CONFLICT (id) DO NOTHING;

    -- user_tiers 삭제
    DROP TABLE IF EXISTS user_tiers CASCADE;
    RAISE NOTICE 'user_tiers 데이터 user_profiles로 이전 완료, 테이블 삭제';
  END IF;
END$$;

-- ── 3. is_admin() 재정의 — user_profiles 참조 ──
CREATE OR REPLACE FUNCTION is_admin(check_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = check_user_id AND tier = 'admin'
  );
END;
$$;

COMMENT ON FUNCTION is_admin IS '주어진 user_id가 admin tier인지 (user_profiles 기준)';

-- ── 4. tier_limits RLS 정책은 그대로 유지 (is_admin 재정의로 자동 반영) ──

-- ── 5. user_profiles tier 변경 권한 — admin만 ──
-- 주의: user_profiles에는 이미 다른 RLS 정책이 있을 수 있음
-- tier 컬럼 변경만 추가 정책으로 가드 (다른 컬럼은 기존 정책 그대로)
DROP POLICY IF EXISTS "user_profiles tier update by admin only" ON user_profiles;
CREATE POLICY "user_profiles tier update by admin only"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (
    -- 본인이 자기 행 SELECT는 가능 (기존 정책)
    auth.uid() = id OR is_admin(auth.uid())
  )
  WITH CHECK (
    -- tier 변경은 admin만, 그 외 컬럼은 본인 가능
    is_admin(auth.uid())
    OR (auth.uid() = id AND tier = (SELECT tier FROM user_profiles WHERE id = auth.uid()))
  );

-- ── 6. 첫 admin 시드 ──
-- ⚠️ 실행 전 주석 해제 + 본인 이메일/UUID 입력
-- INSERT 대신 UPDATE (user_profiles 행은 일반적으로 가입 시 자동 생성됨)
-- UPDATE user_profiles
--   SET tier = 'admin'
--   WHERE id = (SELECT id FROM auth.users WHERE email = 'junnyhsong@gmail.com');

-- ── 확인 쿼리 ──
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'user_profiles' AND column_name = 'tier';

SELECT tier, COUNT(*) AS user_count FROM user_profiles GROUP BY tier ORDER BY user_count DESC;
