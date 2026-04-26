-- Migration 014: 화이트리스트 접근 제어 + 신규 가입 트리거
-- 목적: 베타 테스트 기간 동안 관리자가 승인한 계정만 접근 허용
-- 퍼블리시 시 is_allowed 컬럼 제거 또는 DEFAULT true로 변경 예정

BEGIN;

-- 1. user_profiles에 화이트리스트 컬럼 추가
ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS is_allowed BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN user_profiles.is_allowed IS
  '베타 접근 허용 여부. 관리자가 수동으로 true 설정. 퍼블리시 후 제거 예정.';

-- 2. 신규 가입 시 user_profiles 자동 생성 트리거 함수
--    SECURITY DEFINER: auth 스키마 접근 권한 획득
--    SET search_path = public: 보안 취약점(search_path injection) 방지
CREATE OR REPLACE FUNCTION public.fn_on_auth_user_created()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, display_name, is_allowed)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'display_name',
      split_part(NEW.email, '@', 1)
    ),
    false
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- 3. auth.users INSERT 시 트리거 등록
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_on_auth_user_created();

-- 4. RLS 정책 업데이트
--    user_profiles: 본인 것만 읽기 (is_allowed 체크를 프론트에서 할 수 있도록)
DROP POLICY IF EXISTS "profiles_select_all_authenticated" ON user_profiles;
CREATE POLICY "profiles_select_own"
  ON user_profiles FOR SELECT
  USING (id = auth.uid());

--    techniques: is_allowed=true인 사용자만 읽기
DROP POLICY IF EXISTS "techniques_select_published" ON techniques;
CREATE POLICY "techniques_select_published"
  ON techniques FOR SELECT
  USING (
    is_published = true
    AND is_active = true
    AND EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND is_allowed = true
    )
  );

COMMIT;
