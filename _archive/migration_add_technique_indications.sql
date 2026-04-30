-- ============================================================
-- Migration: Add technique_indications junction table
-- K-Movement Optimism — Manual Therapy Techniques SaaS
-- Date: 2026-04-25
-- Purpose: 부위·증상·테크닉 다대다 관계 + 추천 점수 뷰
-- ============================================================

-- ============================================================
-- STEP 1: technique_indications junction 테이블 생성
-- ============================================================

CREATE TABLE technique_indications (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- 핵심 관계
  technique_id     UUID NOT NULL REFERENCES techniques(id) ON DELETE CASCADE,
  body_region      body_region NOT NULL,             -- 기존 enum 재사용
  symptom_tag_id   UUID NOT NULL REFERENCES technique_tags(id),
  -- technique_tags.tag_type = 'symptom' 인 행만 연결 (CHECK로 강제)

  -- 근거 및 추천 강도
  evidence_level   evidence_level DEFAULT 'level_5', -- 기존 enum 재사용
  effect_size      NUMERIC(4,3),                     -- Cohen's d 등 효과크기 (NULL 허용)
  recommendation   TEXT NOT NULL DEFAULT 'moderate'
                   CHECK (recommendation IN ('strong', 'moderate', 'weak', 'contraindicated')),
  notes            TEXT,                             -- 임상 메모

  -- 메타
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW(),

  -- 동일 테크닉·부위·증상 조합 중복 방지
  UNIQUE (technique_id, body_region, symptom_tag_id)
);

-- symptom 태그만 연결 가능하도록 CHECK constraint 추가
-- (technique_tags.tag_type 직접 참조는 FK로 불가하므로 트리거로 보완)
CREATE OR REPLACE FUNCTION fn_check_symptom_tag_type()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM technique_tags
    WHERE id = NEW.symptom_tag_id
      AND tag_type = 'symptom'
  ) THEN
    RAISE EXCEPTION
      'technique_indications.symptom_tag_id must reference a technique_tags row with tag_type = ''symptom''. Got id: %',
      NEW.symptom_tag_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_tech_ind_check_symptom_type
  BEFORE INSERT OR UPDATE ON technique_indications
  FOR EACH ROW EXECUTE FUNCTION fn_check_symptom_tag_type();

-- ============================================================
-- STEP 2: 인덱스
-- ============================================================

CREATE INDEX idx_tech_ind_technique    ON technique_indications (technique_id);
CREATE INDEX idx_tech_ind_body_region  ON technique_indications (body_region);
CREATE INDEX idx_tech_ind_symptom      ON technique_indications (symptom_tag_id);
CREATE INDEX idx_tech_ind_recommend    ON technique_indications (recommendation);
CREATE INDEX idx_tech_ind_body_symptom ON technique_indications (body_region, symptom_tag_id);

-- ============================================================
-- STEP 3: updated_at 트리거
-- ============================================================

CREATE TRIGGER trg_tech_ind_updated_at
  BEFORE UPDATE ON technique_indications
  FOR EACH ROW EXECUTE FUNCTION fn_update_updated_at();

-- ============================================================
-- STEP 4: RLS 정책
-- ============================================================

ALTER TABLE technique_indications ENABLE ROW LEVEL SECURITY;

-- 로그인 사용자는 읽기 가능
CREATE POLICY "tech_ind_select_authenticated"
  ON technique_indications FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- verified 사용자만 INSERT
CREATE POLICY "tech_ind_insert_verified"
  ON technique_indications FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
        AND is_verified = true
    )
  );

-- verified 사용자만 UPDATE
CREATE POLICY "tech_ind_update_verified"
  ON technique_indications FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
        AND is_verified = true
    )
  );

-- ============================================================
-- STEP 5: 추천 뷰 — v_technique_recommendations
-- ============================================================
-- 기존 v_techniques_with_stats 뷰는 변경 없이 유지.
-- 새 뷰를 추가하여 부위·증상 기반 추천 점수를 제공.

CREATE VIEW v_technique_recommendations AS
SELECT
  t.id                      AS technique_id,
  t.name_ko,
  t.name_en,
  t.abbreviation,
  t.category,
  t.body_region,
  ti.symptom_tag_id,
  tt.tag_key                AS symptom_key,
  tt.label_ko               AS symptom_label_ko,
  ti.recommendation,
  ti.evidence_level,
  ti.effect_size,
  ti.notes,

  -- 추천 점수 공식:
  --   evidence 기여 40% (level_1a = 1.0 … level_5 = 0.10)
  --   effect_size 기여 30% (NULL → 0.5 대체)
  --   recommendation_weight 기여 30% (technique_stats, NULL → 0.5 대체)
  ROUND(
    LEAST(1.0, GREATEST(0.0,
      CASE ti.evidence_level
        WHEN 'level_1a'    THEN 1.00
        WHEN 'level_1b'    THEN 0.85
        WHEN 'level_2a'    THEN 0.70
        WHEN 'level_2b'    THEN 0.55
        WHEN 'level_3'     THEN 0.40
        WHEN 'level_4'     THEN 0.25
        WHEN 'level_5'     THEN 0.10
        ELSE 0.05                          -- 'insufficient' 등
      END * 0.40
      + COALESCE(ti.effect_size, 0.5) * 0.30
      + COALESCE(s.recommendation_weight, 0.5) * 0.30
    )),
  4) AS recommendation_score

FROM technique_indications ti
JOIN techniques       t  ON t.id  = ti.technique_id
JOIN technique_tags   tt ON tt.id = ti.symptom_tag_id
LEFT JOIN technique_stats s ON s.technique_id = ti.technique_id

WHERE t.is_active    = true
  AND t.is_published = true
  AND ti.recommendation != 'contraindicated';

-- ============================================================
-- STEP 6: 기존 symptom_tags 배열 → technique_indications 마이그레이션
-- ============================================================
-- techniques.symptom_tags TEXT[] 의 tag_key 값을 technique_tags 테이블과
-- 매핑하여 technique_indications 행으로 변환한다.
-- 이미 존재하는 (technique_id, body_region, symptom_tag_id) 조합은 무시.

INSERT INTO technique_indications
  (technique_id, body_region, symptom_tag_id, evidence_level, recommendation)
SELECT
  t.id                AS technique_id,
  t.body_region,
  tt.id               AS symptom_tag_id,
  t.evidence_level,
  'moderate'          AS recommendation
FROM techniques t
CROSS JOIN UNNEST(t.symptom_tags) AS stag_key
JOIN technique_tags tt
  ON tt.tag_key  = stag_key
 AND tt.tag_type = 'symptom'
WHERE t.is_active = true
ON CONFLICT (technique_id, body_region, symptom_tag_id) DO NOTHING;

-- ============================================================
-- END OF MIGRATION
-- ============================================================
