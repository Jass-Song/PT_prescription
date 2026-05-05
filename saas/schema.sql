-- ============================================================
-- K-Movement Optimism — Manual Therapy Techniques SaaS
-- Supabase (PostgreSQL) Schema
-- Generated: 2026-04-24
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- for fuzzy search on technique names

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE technique_category AS ENUM (
  'category_a_joint_mobilization',  -- 전통 관절가동술
  'category_b_mulligan'             -- Mulligan Concept
);

CREATE TYPE evidence_level AS ENUM (
  'level_1a', -- Systematic review of RCTs
  'level_1b', -- Individual RCT
  'level_2a', -- Systematic review of cohort studies
  'level_2b', -- Individual cohort study / low-quality RCT
  'level_3',  -- Case-control study
  'level_4',  -- Case series / poor cohort
  'level_5',  -- Expert opinion
  'insufficient' -- 근거 불충분
);

CREATE TYPE body_region AS ENUM (
  'cervical',       -- 경추
  'thoracic',       -- 흉추
  'lumbar',         -- 요추
  'sacroiliac',     -- 천장관절
  'shoulder',       -- 어깨
  'elbow',          -- 팔꿈치
  'wrist_hand',     -- 손목/손
  'hip',            -- 고관절
  'knee',           -- 무릎
  'ankle_foot',     -- 발목/발
  'temporomandibular', -- 턱관절
  'rib',            -- 늑골
  'full_spine'      -- 전척추
);

CREATE TYPE rating_outcome AS ENUM (
  'excellent',    -- 매우 효과적
  'good',         -- 효과적
  'moderate',     -- 보통
  'poor',         -- 효과 미미
  'no_effect',    -- 효과 없음
  'adverse'       -- 부작용 발생
);

-- ============================================================
-- 0. TECHNIQUE_CATEGORIES — 카테고리 마스터 테이블 (원칙 포함)
-- ============================================================

CREATE TABLE technique_categories (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_key     TEXT UNIQUE NOT NULL,  -- 'category_a_joint_mobilization'
  name_ko          TEXT NOT NULL,          -- '관절가동술'
  name_en          TEXT NOT NULL,          -- 'Joint Mobilization'
  subtitle_ko      TEXT,                   -- 'Maitland Concept 기반 접근법'
  subtitle_en      TEXT,
  basic_principles JSONB DEFAULT '[]',     -- [{icon, title_ko, desc_ko}]
  sort_order       INT DEFAULT 0,
  is_active        BOOLEAN DEFAULT true,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_technique_categories_key ON technique_categories(category_key);

-- ============================================================
-- 1. TECHNIQUES — 테크닉 마스터 테이블
-- ============================================================

CREATE TABLE techniques (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- 기본 정보
  name_ko           TEXT NOT NULL,                     -- 한국어 명칭
  name_en           TEXT NOT NULL,                     -- 영어 명칭
  abbreviation      TEXT,                              -- 약어 (예: SNAG, MWM, PA)
  category          technique_category NOT NULL,       -- A: 전통 관절가동술 / B: Mulligan
  category_id       UUID REFERENCES technique_categories(id),  -- 카테고리 FK (NULL 허용: 기존 데이터 호환)
  subcategory       TEXT,                              -- 세부 분류 (예: Maitland Grade, Mulligan SNAG)

  -- 신체 부위
  body_region       body_region NOT NULL,
  body_segment      TEXT,                              -- 세부 분절 (예: C3-C4, L4-L5)
  is_bilateral      BOOLEAN DEFAULT false,             -- 양측 적용 가능 여부

  -- 기술 설명
  description       TEXT,                              -- 테크닉 개요
  technique_steps   JSONB,                             -- 단계별 수행 방법 [{step: 1, instruction: "..."}]
  patient_position  TEXT,                              -- 환자 자세
  therapist_position TEXT,                             -- 치료사 자세
  contact_point     TEXT,                              -- 접촉 부위
  direction         TEXT,                              -- 적용 방향/벡터

  -- AI 추천용 태그 (배열)
  purpose_tags      TEXT[] DEFAULT '{}',               -- 예: ['pain_relief','rom_improvement','neurodynamics']
  target_tags       TEXT[] DEFAULT '{}',               -- 예: ['acute','chronic','post_surgical','athlete']
  symptom_tags      TEXT[] DEFAULT '{}',               -- 예: ['cervicogenic_headache','LBP','frozen_shoulder']
  contraindication_tags TEXT[] DEFAULT '{}',           -- 예: ['osteoporosis','malignancy','instability']

  -- 근거 기반
  evidence_level    evidence_level DEFAULT 'level_5',
  key_references    JSONB,                             -- [{pmid: "12345", title: "...", year: 2020}]
  clinical_notes    TEXT,                              -- 임상 팁 및 주의사항

  -- 금기증 (텍스트)
  absolute_contraindications TEXT,                    -- 절대 금기
  relative_contraindications TEXT,                    -- 상대적 금기

  -- 메타
  is_active         BOOLEAN DEFAULT true,
  is_published      BOOLEAN DEFAULT false,             -- 공개 여부 (admin 승인 후 true)
  created_by        UUID REFERENCES auth.users(id),
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- 검색 성능 인덱스
CREATE INDEX idx_techniques_category ON techniques(category);
CREATE INDEX idx_techniques_body_region ON techniques(body_region);
CREATE INDEX idx_techniques_purpose_tags ON techniques USING GIN(purpose_tags);
CREATE INDEX idx_techniques_target_tags ON techniques USING GIN(target_tags);
CREATE INDEX idx_techniques_symptom_tags ON techniques USING GIN(symptom_tags);
CREATE INDEX idx_techniques_name_trgm ON techniques USING GIN(name_ko gin_trgm_ops);
CREATE INDEX idx_techniques_is_published ON techniques(is_published) WHERE is_published = true;

-- ============================================================
-- 2. TECHNIQUE_TAGS — 태그 정규화 마스터 테이블
-- ============================================================

CREATE TYPE tag_type AS ENUM (
  'purpose',          -- 목적 태그
  'target',           -- 대상 태그
  'symptom',          -- 증상 태그
  'contraindication'  -- 금기증 태그
);

CREATE TABLE technique_tags (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tag_type    tag_type NOT NULL,
  tag_key     TEXT NOT NULL,              -- 시스템 키 (영어, snake_case)
  label_ko    TEXT NOT NULL,              -- 한국어 표시명
  label_en    TEXT NOT NULL,              -- 영어 표시명
  description TEXT,                       -- 태그 설명
  is_active   BOOLEAN DEFAULT true,
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(tag_type, tag_key)
);

CREATE INDEX idx_technique_tags_type ON technique_tags(tag_type);
CREATE INDEX idx_technique_tags_key ON technique_tags(tag_key);

-- ============================================================
-- 3. RATINGS — 사용 후 효과 평가 테이블
-- ============================================================

CREATE TABLE ratings (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- 관계
  technique_id      UUID NOT NULL REFERENCES techniques(id) ON DELETE CASCADE,
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 핵심 평가
  star_rating       SMALLINT NOT NULL CHECK (star_rating BETWEEN 1 AND 5),  -- 별점 1-5
  outcome           rating_outcome,                   -- 효과 분류

  -- 적응증 적합도 피드백 (AI 추천 피드백 루프 핵심)
  indication_accuracy SMALLINT CHECK (indication_accuracy BETWEEN 1 AND 5),
  -- 1: 완전히 잘못된 추천 / 5: 완벽히 맞는 추천
  -- AI 추천으로 이 테크닉을 사용했는지 여부
  was_ai_recommended  BOOLEAN DEFAULT false,
  ai_recommendation_score NUMERIC(4,3), -- 추천 당시 AI 점수 (0.000 - 1.000), 사후 분석용

  -- 증례 메모
  patient_profile   TEXT,      -- 환자 프로필 (익명: 40대 남성 만성 요통 등)
  clinical_context  TEXT,      -- 임상 맥락 (증상, 기간, 이전 치료 등)
  application_notes TEXT,      -- 적용 시 특이사항
  response_notes    TEXT,      -- 환자 반응 및 결과

  -- 태그 (이 케이스에서 실제 해당된 태그)
  actual_symptom_tags TEXT[] DEFAULT '{}',
  actual_target_tags  TEXT[] DEFAULT '{}',

  -- 세션 정보
  session_date      DATE,                              -- 적용 날짜
  follow_up_rating  SMALLINT CHECK (follow_up_rating BETWEEN 1 AND 5), -- 추후 추적 효과
  follow_up_date    DATE,

  -- 메타
  is_anonymous      BOOLEAN DEFAULT false,             -- 커뮤니티 공유 시 익명 처리
  is_shared         BOOLEAN DEFAULT false,             -- 커뮤니티 공개 여부
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ratings_technique_id ON ratings(technique_id);
CREATE INDEX idx_ratings_user_id ON ratings(user_id);
CREATE INDEX idx_ratings_star_rating ON ratings(star_rating);
CREATE INDEX idx_ratings_created_at ON ratings(created_at DESC);
CREATE INDEX idx_ratings_was_ai_recommended ON ratings(was_ai_recommended);

-- ============================================================
-- 4. TECHNIQUE_STATS — 테크닉 집계 통계 (AI 추천 가중치용)
-- 실시간 집계 뷰 + 캐시 테이블 이중 구조
-- ============================================================

CREATE TABLE technique_stats (
  technique_id          UUID PRIMARY KEY REFERENCES techniques(id) ON DELETE CASCADE,

  -- 기본 통계
  total_ratings         INT DEFAULT 0,
  avg_star_rating       NUMERIC(3,2) DEFAULT 0,
  total_uses            INT DEFAULT 0,         -- usage_logs 기준 총 사용 횟수

  -- 효과 분포
  excellent_count       INT DEFAULT 0,
  good_count            INT DEFAULT 0,
  moderate_count        INT DEFAULT 0,
  poor_count            INT DEFAULT 0,
  no_effect_count       INT DEFAULT 0,
  adverse_count         INT DEFAULT 0,

  -- AI 추천 정확도 통계
  ai_recommended_count  INT DEFAULT 0,
  avg_indication_accuracy NUMERIC(3,2) DEFAULT 0,

  -- 즐겨찾기 수
  favorite_count        INT DEFAULT 0,

  -- 최근 30일 활성도
  recent_30d_uses       INT DEFAULT 0,
  recent_30d_avg_rating NUMERIC(3,2) DEFAULT 0,

  -- AI 추천 가중치 (0.000 - 1.000)
  -- 별점 + 적응증 정확도 + 활성도 복합 산출
  recommendation_weight NUMERIC(5,4) DEFAULT 0.5000,

  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_technique_stats_recommendation_weight
  ON technique_stats(recommendation_weight DESC);
CREATE INDEX idx_technique_stats_avg_rating
  ON technique_stats(avg_star_rating DESC);

-- ============================================================
-- 5. USAGE_LOGS — 사용 이력 테이블
-- ============================================================

CREATE TABLE usage_logs (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  technique_id    UUID NOT NULL REFERENCES techniques(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 진입 경로
  source          TEXT DEFAULT 'manual',
  -- 값: 'manual' | 'ai_recommendation' | 'search' | 'favorite' | 'recent' | 'community'

  -- AI 추천 세션 정보 (source = 'ai_recommendation'일 때)
  recommendation_session_id UUID,             -- 추천 세션 묶음 ID
  recommendation_rank       SMALLINT,         -- 해당 추천에서 몇 번째였는지

  -- 사용 컨텍스트 (AI 추천 입력 파라미터 저장 — 사후 분석용)
  query_body_region   body_region,
  query_purpose_tags  TEXT[] DEFAULT '{}',
  query_target_tags   TEXT[] DEFAULT '{}',
  query_symptom_tags  TEXT[] DEFAULT '{}',

  -- 이후 평가 연결
  rating_id       UUID REFERENCES ratings(id),     -- 사용 후 평가 작성 시 연결

  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_usage_logs_technique_id ON usage_logs(technique_id);
CREATE INDEX idx_usage_logs_user_id ON usage_logs(user_id);
CREATE INDEX idx_usage_logs_created_at ON usage_logs(created_at DESC);
CREATE INDEX idx_usage_logs_source ON usage_logs(source);
CREATE INDEX idx_usage_logs_recommendation_session ON usage_logs(recommendation_session_id);

-- ============================================================
-- 6. USER_FAVORITES — 즐겨찾기 테이블
-- ============================================================

CREATE TABLE user_favorites (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  technique_id    UUID NOT NULL REFERENCES techniques(id) ON DELETE CASCADE,
  collection_name TEXT DEFAULT '기본',         -- 즐겨찾기 폴더/컬렉션명
  notes           TEXT,                        -- 개인 메모
  sort_order      INT DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, technique_id)
);

CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_user_favorites_technique_id ON user_favorites(technique_id);
CREATE INDEX idx_user_favorites_collection ON user_favorites(user_id, collection_name);

-- ============================================================
-- 7. USER_PROFILES — 치료사 프로필 (auth.users 확장)
-- ============================================================

CREATE TABLE user_profiles (
  id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name      TEXT,
  credential        TEXT,                      -- 자격 (PT, OT, DO, DC 등)
  specialty_tags    TEXT[] DEFAULT '{}',       -- 전문 분야 태그
  years_experience  SMALLINT,
  institution       TEXT,                      -- 소속 기관 (선택)
  bio               TEXT,
  avatar_url        TEXT,
  is_verified       BOOLEAN DEFAULT false,     -- 자격증 인증 여부
  notification_pref JSONB DEFAULT '{"email": true, "push": true}',
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 8. COMMUNITY_CASES — 케이스 공유 (미래 확장)
-- ratings.is_shared = true인 케이스의 커뮤니티 레이어
-- ============================================================

CREATE TABLE community_cases (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  rating_id       UUID NOT NULL REFERENCES ratings(id) ON DELETE CASCADE,
  technique_id    UUID NOT NULL REFERENCES techniques(id),
  author_id       UUID NOT NULL REFERENCES auth.users(id),

  title           TEXT NOT NULL,               -- 케이스 제목
  summary         TEXT,                        -- 요약 (검색용)
  tags            TEXT[] DEFAULT '{}',

  -- 커뮤니티 상호작용
  like_count      INT DEFAULT 0,
  comment_count   INT DEFAULT 0,
  view_count      INT DEFAULT 0,

  is_published    BOOLEAN DEFAULT true,
  published_at    TIMESTAMPTZ DEFAULT NOW(),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_community_cases_technique_id ON community_cases(technique_id);
CREATE INDEX idx_community_cases_published ON community_cases(is_published, published_at DESC);
CREATE INDEX idx_community_cases_tags ON community_cases USING GIN(tags);

-- ============================================================
-- VIEWS — 자주 사용하는 집계 뷰
-- ============================================================

-- 테크닉 + 통계 통합 뷰 (목록 API용)
DROP VIEW IF EXISTS v_techniques_with_stats;
CREATE VIEW v_techniques_with_stats AS
SELECT
  t.id,
  t.name_ko,
  t.name_en,
  t.abbreviation,
  t.category,
  t.category_id,
  tc.name_ko          AS category_name_ko,
  tc.subtitle_ko      AS category_subtitle_ko,
  tc.basic_principles AS category_principles,
  t.body_region,
  t.evidence_level,
  t.purpose_tags,
  t.target_tags,
  t.symptom_tags,
  t.is_published,
  COALESCE(s.avg_star_rating, 0)          AS avg_star_rating,
  COALESCE(s.total_ratings, 0)            AS total_ratings,
  COALESCE(s.total_uses, 0)               AS total_uses,
  COALESCE(s.favorite_count, 0)           AS favorite_count,
  COALESCE(s.recommendation_weight, 0.5)  AS recommendation_weight,
  t.created_at
FROM techniques t
LEFT JOIN technique_categories tc ON t.category_id = tc.id
LEFT JOIN technique_stats s ON t.id = s.technique_id
WHERE t.is_active = true;

-- 개인 대시보드 뷰 (사용자별 사용 통계)
CREATE VIEW v_user_activity_summary AS
SELECT
  ul.user_id,
  COUNT(DISTINCT ul.technique_id)         AS unique_techniques_used,
  COUNT(ul.id)                            AS total_uses,
  COUNT(r.id)                             AS total_ratings,
  ROUND(AVG(r.star_rating), 2)            AS avg_rating_given,
  MAX(ul.created_at)                      AS last_activity_at
FROM usage_logs ul
LEFT JOIN ratings r ON r.user_id = ul.user_id
GROUP BY ul.user_id;

-- ============================================================
-- FUNCTIONS — 자동화 함수
-- ============================================================

-- updated_at 자동 갱신 함수
CREATE OR REPLACE FUNCTION fn_update_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- technique_stats 갱신 함수 (ratings INSERT/UPDATE 시 트리거)
CREATE OR REPLACE FUNCTION fn_refresh_technique_stats()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_tech_id UUID;
BEGIN
  -- INSERT/UPDATE: 새 technique_id, DELETE: 이전 technique_id
  v_tech_id := COALESCE(NEW.technique_id, OLD.technique_id);

  INSERT INTO technique_stats (
    technique_id,
    total_ratings,
    avg_star_rating,
    excellent_count,
    good_count,
    moderate_count,
    poor_count,
    no_effect_count,
    adverse_count,
    ai_recommended_count,
    avg_indication_accuracy,
    recent_30d_avg_rating,
    recommendation_weight,
    updated_at
  )
  SELECT
    v_tech_id,
    COUNT(*),
    ROUND(AVG(star_rating), 2),
    COUNT(*) FILTER (WHERE outcome = 'excellent'),
    COUNT(*) FILTER (WHERE outcome = 'good'),
    COUNT(*) FILTER (WHERE outcome = 'moderate'),
    COUNT(*) FILTER (WHERE outcome = 'poor'),
    COUNT(*) FILTER (WHERE outcome = 'no_effect'),
    COUNT(*) FILTER (WHERE outcome = 'adverse'),
    COUNT(*) FILTER (WHERE was_ai_recommended = true),
    ROUND(AVG(indication_accuracy) FILTER (WHERE indication_accuracy IS NOT NULL), 2),
    ROUND(AVG(star_rating) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 2),
    -- 추천 가중치: 별점 20% + 적응증 정확도 30% + 최근 30일 활성도 20% + 효과 분류 30%
    ROUND(
      LEAST(1.0, GREATEST(0.0,
        (AVG(star_rating) / 5.0 * 0.20) +
        (COALESCE(AVG(indication_accuracy) FILTER (WHERE indication_accuracy IS NOT NULL), 3) / 5.0 * 0.30) +
        (LEAST(COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 20) / 20.0 * 0.20) +
        ((COUNT(*) FILTER (WHERE outcome IN ('excellent','good'))::FLOAT / NULLIF(COUNT(*), 0)) * 0.30)
      )),
    4),
    NOW()
  FROM ratings
  WHERE technique_id = v_tech_id
  ON CONFLICT (technique_id) DO UPDATE SET
    total_ratings             = EXCLUDED.total_ratings,
    avg_star_rating           = EXCLUDED.avg_star_rating,
    excellent_count           = EXCLUDED.excellent_count,
    good_count                = EXCLUDED.good_count,
    moderate_count            = EXCLUDED.moderate_count,
    poor_count                = EXCLUDED.poor_count,
    no_effect_count           = EXCLUDED.no_effect_count,
    adverse_count             = EXCLUDED.adverse_count,
    ai_recommended_count      = EXCLUDED.ai_recommended_count,
    avg_indication_accuracy   = EXCLUDED.avg_indication_accuracy,
    recent_30d_avg_rating     = EXCLUDED.recent_30d_avg_rating,
    recommendation_weight     = EXCLUDED.recommendation_weight,
    updated_at                = NOW();

  RETURN NULL;
END;
$$;

-- usage_logs INSERT 시 technique_stats.total_uses 갱신 함수
CREATE OR REPLACE FUNCTION fn_increment_technique_uses()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO technique_stats (technique_id, total_uses, recent_30d_uses, updated_at)
  VALUES (NEW.technique_id, 1, 1, NOW())
  ON CONFLICT (technique_id) DO UPDATE SET
    total_uses      = technique_stats.total_uses + 1,
    recent_30d_uses = (
      SELECT COUNT(*) FROM usage_logs
      WHERE technique_id = NEW.technique_id
        AND created_at >= NOW() - INTERVAL '30 days'
    ),
    updated_at      = NOW();

  RETURN NEW;
END;
$$;

-- user_favorites 변경 시 favorite_count 갱신
CREATE OR REPLACE FUNCTION fn_sync_favorite_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_tech_id UUID;
  v_count   INT;
BEGIN
  v_tech_id := COALESCE(NEW.technique_id, OLD.technique_id);
  SELECT COUNT(*) INTO v_count FROM user_favorites WHERE technique_id = v_tech_id;

  INSERT INTO technique_stats (technique_id, favorite_count, updated_at)
  VALUES (v_tech_id, v_count, NOW())
  ON CONFLICT (technique_id) DO UPDATE SET
    favorite_count = v_count,
    updated_at     = NOW();

  RETURN NULL;
END;
$$;

-- ============================================================
-- TRIGGERS
-- ============================================================

-- updated_at 자동 갱신
CREATE TRIGGER trg_techniques_updated_at
  BEFORE UPDATE ON techniques
  FOR EACH ROW EXECUTE FUNCTION fn_update_updated_at();

CREATE TRIGGER trg_ratings_updated_at
  BEFORE UPDATE ON ratings
  FOR EACH ROW EXECUTE FUNCTION fn_update_updated_at();

CREATE TRIGGER trg_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION fn_update_updated_at();

CREATE TRIGGER trg_community_cases_updated_at
  BEFORE UPDATE ON community_cases
  FOR EACH ROW EXECUTE FUNCTION fn_update_updated_at();

-- ratings 변경 시 통계 갱신
CREATE TRIGGER trg_refresh_stats_on_rating
  AFTER INSERT OR UPDATE OR DELETE ON ratings
  FOR EACH ROW EXECUTE FUNCTION fn_refresh_technique_stats();

-- usage_logs 추가 시 사용 횟수 갱신
CREATE TRIGGER trg_increment_uses_on_log
  AFTER INSERT ON usage_logs
  FOR EACH ROW EXECUTE FUNCTION fn_increment_technique_uses();

-- 즐겨찾기 변경 시 카운트 갱신
CREATE TRIGGER trg_sync_favorite_count
  AFTER INSERT OR DELETE ON user_favorites
  FOR EACH ROW EXECUTE FUNCTION fn_sync_favorite_count();

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

ALTER TABLE technique_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "categories_select_all"
  ON technique_categories FOR SELECT
  USING (is_active = true OR auth.uid() IS NOT NULL);

ALTER TABLE techniques         ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings            ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_logs         ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites     ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles      ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_cases    ENABLE ROW LEVEL SECURITY;
ALTER TABLE technique_stats    ENABLE ROW LEVEL SECURITY;
ALTER TABLE technique_tags     ENABLE ROW LEVEL SECURITY;

-- techniques: 로그인 사용자는 공개 테크닉 읽기 가능, admin만 쓰기
CREATE POLICY "techniques_select_published"
  ON techniques FOR SELECT
  USING (is_published = true OR auth.uid() IS NOT NULL);

CREATE POLICY "techniques_insert_admin"
  ON techniques FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND is_verified = true
    )
  );

CREATE POLICY "techniques_update_admin"
  ON techniques FOR UPDATE
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());

-- technique_tags: 모든 인증 사용자 읽기 가능
CREATE POLICY "tags_select_authenticated"
  ON technique_tags FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- technique_stats: 모든 인증 사용자 읽기 가능
CREATE POLICY "stats_select_authenticated"
  ON technique_stats FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- ratings: 본인 것만 CRUD, 공유된 것은 읽기 가능
CREATE POLICY "ratings_select_own_or_shared"
  ON ratings FOR SELECT
  USING (user_id = auth.uid() OR is_shared = true);

CREATE POLICY "ratings_insert_own"
  ON ratings FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "ratings_update_own"
  ON ratings FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "ratings_delete_own"
  ON ratings FOR DELETE
  USING (user_id = auth.uid());

-- usage_logs: 본인 것만
CREATE POLICY "usage_logs_select_own"
  ON usage_logs FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "usage_logs_insert_own"
  ON usage_logs FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- user_favorites: 본인 것만
CREATE POLICY "favorites_select_own"
  ON user_favorites FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "favorites_insert_own"
  ON user_favorites FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "favorites_update_own"
  ON user_favorites FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "favorites_delete_own"
  ON user_favorites FOR DELETE
  USING (user_id = auth.uid());

-- user_profiles: 본인 것은 CRUD, 다른 사람 것은 읽기만
CREATE POLICY "profiles_select_all_authenticated"
  ON user_profiles FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "profiles_insert_own"
  ON user_profiles FOR INSERT
  WITH CHECK (id = auth.uid());

CREATE POLICY "profiles_update_own"
  ON user_profiles FOR UPDATE
  USING (id = auth.uid());

-- community_cases: 공개된 것 읽기, 본인 것 CRUD
CREATE POLICY "cases_select_published"
  ON community_cases FOR SELECT
  USING (is_published = true OR author_id = auth.uid());

CREATE POLICY "cases_insert_own"
  ON community_cases FOR INSERT
  WITH CHECK (author_id = auth.uid());

CREATE POLICY "cases_update_own"
  ON community_cases FOR UPDATE
  USING (author_id = auth.uid());

CREATE POLICY "cases_delete_own"
  ON community_cases FOR DELETE
  USING (author_id = auth.uid());

-- ============================================================
-- SEED DATA — 태그 마스터 초기값
-- ============================================================

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, subtitle_en, basic_principles, sort_order) VALUES
(
  'category_a_joint_mobilization',
  '관절가동술',
  'Joint Mobilization',
  'Maitland Concept 기반 접근법',
  'Maitland Concept-Based Approach',
  '[
    {"icon":"🎯","title_ko":"치료 전 평가가 먼저","desc_ko":"시술 전 반드시 관절 가동 범위(ROM)와 통증 위치를 확인하세요. 치료 후 변화를 비교해야 효과를 판단할 수 있습니다."},
    {"icon":"🖐️","title_ko":"저항 감지가 핵심 (R1 / R2)","desc_ko":"R1은 처음 조직 저항이 느껴지는 지점, R2는 최대 저항 지점입니다. Grade I-II는 R1 이전, Grade III-IV는 R1-R2 사이에서 시행합니다."},
    {"icon":"📊","title_ko":"Grade 선택 기준","desc_ko":"Grade I-II: 통증이 주 증상일 때 (부드럽게). Grade III-IV: 관절 굳음이 주 증상일 때 (더 깊게). 처음에는 낮은 Grade로 시작해 반응을 봅니다."},
    {"icon":"🔄","title_ko":"시술 후 즉각 재평가","desc_ko":"3-5회 시행 후 ROM 변화와 통증 변화를 반드시 확인하세요. 변화가 없으면 방향, 분절, 또는 Grade를 조정합니다."},
    {"icon":"⚠️","title_ko":"절대 금기 확인","desc_ko":"골절, 종양, 심한 골다공증, 척수 압박 증상(양하지 저림·대소변 장애)이 있으면 시행하지 마세요."}
  ]',
  1
),
(
  'category_b_mulligan',
  'Mulligan Concept',
  'Mulligan Concept',
  'MWM / SNAG / NAG 기반 접근법',
  'MWM / SNAG / NAG-Based Approach',
  '[
    {"icon":"🚫","title_ko":"No Pain Rule (절대 원칙)","desc_ko":"시술 중 통증이 발생하면 즉시 방향을 수정하거나 중단하세요. Mulligan의 핵심 원칙 — 통증 없는 범위에서만 시행합니다."},
    {"icon":"✅","title_ko":"PILL 반응 확인","desc_ko":"Pain-free(통증 없음), Instant(즉각), Long-lasting(지속) — 세 가지가 모두 나타나야 올바른 방향과 분절을 선택한 것입니다."},
    {"icon":"🤝","title_ko":"수동 활주 + 능동 운동 결합","desc_ko":"치료사가 활주(glide)를 유지하는 동안 환자가 스스로 움직입니다. 수동 치료와 능동 운동의 결합이 핵심입니다."},
    {"icon":"🔍","title_ko":"방향 재탐색","desc_ko":"PILL 반응이 없으면 활주 방향(전상방/내측/외측), 분절 레벨, 활주 크기를 순서대로 조정하세요."},
    {"icon":"📏","title_ko":"즉각 ROM 확인","desc_ko":"1세트(6-10회) 후 즉각적인 ROM 증가가 없으면 파라미터를 변경합니다. 효과는 첫 세션에서 즉시 나타나야 합니다."}
  ]',
  2
);

INSERT INTO technique_tags (tag_type, tag_key, label_ko, label_en, sort_order) VALUES
-- purpose tags
('purpose', 'pain_relief',        '통증 감소',     'Pain Relief',           1),
('purpose', 'rom_improvement',    '관절가동범위 개선', 'ROM Improvement',     2),
('purpose', 'neurodynamics',      '신경가동술',     'Neurodynamics',         3),
('purpose', 'muscle_inhibition',  '근육 억제',     'Muscle Inhibition',     4),
('purpose', 'proprioception',     '고유감각 개선', 'Proprioception',        5),
('purpose', 'stabilization',      '안정화',        'Stabilization',         6),
('purpose', 'soft_tissue',        '연부조직 가동', 'Soft Tissue Mob.',      7),
('purpose', 'traction',           '견인',          'Traction',              8),

-- target tags
('target', 'acute',               '급성기',        'Acute',                 1),
('target', 'subacute',            '아급성기',      'Subacute',              2),
('target', 'chronic',             '만성',          'Chronic',               3),
('target', 'post_surgical',       '수술 후',       'Post-Surgical',         4),
('target', 'athlete',             '운동선수',      'Athlete',               5),
('target', 'elderly',             '노인',          'Elderly',               6),
('target', 'hypermobile',         '과가동성',      'Hypermobile',           7),

-- symptom tags
('symptom', 'lbp_nonspecific',    '비특이성 요통', 'Non-specific LBP',      1),
('symptom', 'radiculopathy',      '신경근증',      'Radiculopathy',         2),
('symptom', 'cervicogenic_ha',    '경추성 두통',   'Cervicogenic HA',       3),
('symptom', 'frozen_shoulder',    '유착성 관절낭염','Frozen Shoulder',       4),
('symptom', 'rotator_cuff',       '회전근개 문제', 'Rotator Cuff',          5),
('symptom', 'lateral_epicondylalgia','외측 상과통', 'Lateral Epicondylalgia',6),
('symptom', 'knee_oa',            '무릎 골관절염', 'Knee OA',               7),
('symptom', 'ankle_sprain',       '발목 염좌',     'Ankle Sprain',          8),
('symptom', 'patellofemoral',     '슬개대퇴 통증', 'Patellofemoral Pain',   9),
('symptom', 'disc_herniation',    '추간판 탈출증', 'Disc Herniation',       10),

-- contraindication tags
('contraindication', 'osteoporosis',   '골다공증',    'Osteoporosis',         1),
('contraindication', 'malignancy',     '악성 종양',   'Malignancy',           2),
('contraindication', 'instability',    '불안정성',    'Instability',          3),
('contraindication', 'fracture',       '골절',        'Fracture',             4),
('contraindication', 'vbi_risk',       'VBI 위험',    'VBI Risk',             5),
('contraindication', 'inflammation_acute','급성 염증', 'Acute Inflammation',  6),
('contraindication', 'neurological_deficit','신경학적 결손','Neuro Deficit',  7);

-- ============================================================
-- N. TERM_GLOSSARY — 한국어 PT 용어 표준화 단일 진실 소스
-- ============================================================
-- 시드 데이터는 saas/migrations/052-term-glossary.sql 단독 책임 (여기 미포함).
-- 정의는 마이그 052 와 동기화. 변경 시 양쪽 모두 갱신할 것.
-- 단일 진실 소스: pt-prescription/docs/clinical-terminology-audit-2026-05-05.md §6
-- 설계 문서: saas/docs/term-glossary-design.md
-- ============================================================

CREATE TABLE IF NOT EXISTS term_glossary (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  original_ko              TEXT NOT NULL,
  replacement_ko           TEXT,
  english                  TEXT,
  category                 TEXT NOT NULL CHECK (category IN (
                             'posture','movement','examination','anatomy',
                             'depth','foreign','expression','preserved'
                           )),
  body_region              TEXT,
  disambiguation_pattern   TEXT,
  is_preserved             BOOLEAN NOT NULL DEFAULT false,
  status                   TEXT NOT NULL DEFAULT 'active'
                             CHECK (status IN ('active','review','deprecated')),
  frequency                INTEGER,
  evidence_url             TEXT,
  notes                    TEXT,
  created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (original_ko, body_region)
);

CREATE INDEX IF NOT EXISTS idx_term_glossary_original_active
  ON term_glossary(original_ko) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_term_glossary_category
  ON term_glossary(category);
CREATE INDEX IF NOT EXISTS idx_term_glossary_preserved
  ON term_glossary(is_preserved) WHERE is_preserved = true;

CREATE OR REPLACE FUNCTION fn_touch_term_glossary_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_term_glossary_updated_at ON term_glossary;
CREATE TRIGGER trg_term_glossary_updated_at
  BEFORE UPDATE ON term_glossary
  FOR EACH ROW EXECUTE FUNCTION fn_touch_term_glossary_updated_at();

ALTER TABLE term_glossary ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "term_glossary_select_all" ON term_glossary;
CREATE POLICY "term_glossary_select_all"
  ON term_glossary FOR SELECT
  USING (true);

-- ============================================================
-- END OF SCHEMA
-- ============================================================
