-- ============================================================
-- Migration 048 — tier 변경 시점 별도 추적 (tier_updated_at)
-- 배경:
--   user_profiles.updated_at은 모든 컬럼 변경에 반응 (display_name, pt_settings 등 포함)
--   tier 변경 시점만 따로 추적 필요 (등급 변경 이력·결제·만료 추적용)
-- 전략:
--   1. tier_updated_at TIMESTAMPTZ 컬럼 추가 (기본값 = updated_at, 신규는 now())
--   2. BEFORE UPDATE 트리거: tier가 실제로 변경된 경우에만 tier_updated_at 갱신
-- 후속:
--   - api/admin.js: 응답에 tier_updated_at 포함
--   - debug/admin.html: 표시
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

-- ── 1. 컬럼 추가 ──
ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS tier_updated_at TIMESTAMPTZ;

-- 기존 행 백필: 가장 가까운 정보(updated_at) 사용
UPDATE user_profiles
  SET tier_updated_at = COALESCE(updated_at, now())
  WHERE tier_updated_at IS NULL;

COMMENT ON COLUMN user_profiles.tier_updated_at IS 'tier 컬럼이 마지막으로 변경된 시각 (트리거로 자동 관리)';

-- ── 2. 트리거 함수 — tier 변경 감지 시 자동 업데이트 ──
CREATE OR REPLACE FUNCTION update_user_profiles_tier_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.tier IS DISTINCT FROM OLD.tier THEN
    NEW.tier_updated_at = now();
  END IF;
  RETURN NEW;
END;
$$;

-- ── 3. 트리거 등록 ──
DROP TRIGGER IF EXISTS user_profiles_tier_updated_at_trigger ON user_profiles;
CREATE TRIGGER user_profiles_tier_updated_at_trigger
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_user_profiles_tier_updated_at();

-- ── 확인 쿼리 ──
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'user_profiles' AND column_name IN ('tier', 'tier_updated_at', 'updated_at');

SELECT tier, COUNT(*) AS users, MIN(tier_updated_at) AS earliest, MAX(tier_updated_at) AS latest
FROM user_profiles GROUP BY tier;
