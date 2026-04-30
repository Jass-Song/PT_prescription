-- ============================================================
-- Migration: technique_categories 테이블 추가 + category_id FK
-- 기존 Supabase DB에 실행하는 마이그레이션 파일
-- Generated: 2026-04-25
-- ============================================================

-- ── 1. technique_categories 테이블 생성 ──────────────────────
CREATE TABLE IF NOT EXISTS technique_categories (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_key     TEXT UNIQUE NOT NULL,
  name_ko          TEXT NOT NULL,
  name_en          TEXT NOT NULL,
  subtitle_ko      TEXT,
  subtitle_en      TEXT,
  basic_principles JSONB DEFAULT '[]',
  sort_order       INT DEFAULT 0,
  is_active        BOOLEAN DEFAULT true,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_technique_categories_key
  ON technique_categories(category_key);

-- ── 2. techniques 테이블에 category_id FK 추가 ────────────────
ALTER TABLE techniques
  ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES technique_categories(id);

-- ── 3. v_techniques_with_stats 뷰 업데이트 ───────────────────
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
  COALESCE(s.avg_star_rating, 0)         AS avg_star_rating,
  COALESCE(s.total_ratings, 0)           AS total_ratings,
  COALESCE(s.total_uses, 0)             AS total_uses,
  COALESCE(s.favorite_count, 0)         AS favorite_count,
  COALESCE(s.recommendation_weight, 0.5) AS recommendation_weight,
  t.created_at
FROM techniques t
LEFT JOIN technique_categories tc ON t.category_id = tc.id
LEFT JOIN technique_stats s ON t.id = s.technique_id
WHERE t.is_active = true;

-- ── 4. RLS 설정 ───────────────────────────────────────────────
ALTER TABLE technique_categories ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'technique_categories' AND policyname = 'categories_select_all'
  ) THEN
    CREATE POLICY "categories_select_all"
      ON technique_categories FOR SELECT
      USING (is_active = true OR auth.uid() IS NOT NULL);
  END IF;
END $$;

-- ── 5. updated_at 자동 갱신 트리거 ───────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_technique_categories_updated_at'
  ) THEN
    CREATE TRIGGER trg_technique_categories_updated_at
      BEFORE UPDATE ON technique_categories
      FOR EACH ROW EXECUTE FUNCTION fn_update_updated_at();
  END IF;
END $$;

-- ── 6. 카테고리 시드 데이터 ──────────────────────────────────
INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, subtitle_en, basic_principles, sort_order)
VALUES (
  'category_a_joint_mobilization',
  '관절가동술',
  'Joint Mobilization',
  'Maitland Concept 기반 접근법',
  'Maitland Concept-Based Approach',
  '[{"icon":"target","title_ko":"치료 전 평가가 먼저","desc_ko":"시술 전 반드시 관절 가동 범위(ROM)와 통증 위치를 확인하세요. 치료 후 변화를 비교해야 효과를 판단할 수 있습니다."},{"icon":"hand","title_ko":"저항 감지가 핵심 (R1 / R2)","desc_ko":"R1은 처음 조직 저항이 느껴지는 지점, R2는 최대 저항 지점입니다. Grade I-II는 R1 이전, Grade III-IV는 R1-R2 사이에서 시행합니다."},{"icon":"chart","title_ko":"Grade 선택 기준","desc_ko":"Grade I-II: 통증이 주 증상일 때 (부드럽게). Grade III-IV: 관절 굳음이 주 증상일 때 (더 깊게). 처음에는 낮은 Grade로 시작해 반응을 봅니다."},{"icon":"refresh","title_ko":"시술 후 즉각 재평가","desc_ko":"3-5회 시행 후 ROM 변화와 통증 변화를 반드시 확인하세요. 변화가 없으면 방향, 분절, 또는 Grade를 조정합니다."},{"icon":"warning","title_ko":"절대 금기 확인","desc_ko":"골절, 종양, 심한 골다공증, 척수 압박 증상(양하지 저림, 대소변 장애)이 있으면 시행하지 마세요."}]'::jsonb,
  1
)
ON CONFLICT (category_key) DO UPDATE SET
  name_ko          = EXCLUDED.name_ko,
  name_en          = EXCLUDED.name_en,
  subtitle_ko      = EXCLUDED.subtitle_ko,
  subtitle_en      = EXCLUDED.subtitle_en,
  basic_principles = EXCLUDED.basic_principles,
  sort_order       = EXCLUDED.sort_order,
  updated_at       = NOW();

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, subtitle_en, basic_principles, sort_order)
VALUES (
  'category_b_mulligan',
  'Mulligan Concept',
  'Mulligan Concept',
  'MWM / SNAG / NAG 기반 접근법',
  'MWM / SNAG / NAG-Based Approach',
  '[{"icon":"no_entry","title_ko":"No Pain Rule (절대 원칙)","desc_ko":"시술 중 통증이 발생하면 즉시 방향을 수정하거나 중단하세요. Mulligan의 핵심 원칙 - 통증 없는 범위에서만 시행합니다."},{"icon":"check","title_ko":"PILL 반응 확인","desc_ko":"Pain-free(통증 없음), Instant(즉각), Long-lasting(지속) - 세 가지가 모두 나타나야 올바른 방향과 분절을 선택한 것입니다."},{"icon":"handshake","title_ko":"수동 활주 + 능동 운동 결합","desc_ko":"치료사가 활주(glide)를 유지하는 동안 환자가 스스로 움직입니다. 수동 치료와 능동 운동의 결합이 핵심입니다."},{"icon":"search","title_ko":"방향 재탐색","desc_ko":"PILL 반응이 없으면 활주 방향(전상방, 내측, 외측), 분절 레벨, 활주 크기를 순서대로 조정하세요."},{"icon":"ruler","title_ko":"즉각 ROM 확인","desc_ko":"1세트(6-10회) 후 즉각적인 ROM 증가가 없으면 파라미터를 변경합니다. 효과는 첫 세션에서 즉시 나타나야 합니다."}]'::jsonb,
  2
)
ON CONFLICT (category_key) DO UPDATE SET
  name_ko          = EXCLUDED.name_ko,
  name_en          = EXCLUDED.name_en,
  subtitle_ko      = EXCLUDED.subtitle_ko,
  subtitle_en      = EXCLUDED.subtitle_en,
  basic_principles = EXCLUDED.basic_principles,
  sort_order       = EXCLUDED.sort_order,
  updated_at       = NOW();

-- ── 완료 확인 ─────────────────────────────────────────────────
SELECT category_key, name_ko, sort_order,
       jsonb_array_length(basic_principles) AS principle_count
FROM technique_categories
ORDER BY sort_order;
