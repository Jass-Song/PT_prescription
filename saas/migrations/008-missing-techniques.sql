-- ============================================================
-- K-Movement Optimism — Migration 008
-- 미마이그레이션 테크닉 시드 SQL (55개)
-- 생성일: 2026-04-25
-- 카테고리: ART(11), CTM(7), DeepFriction(7), TriggerPoint(11),
--           AnatomyTrains(7), MDT(5), SCS(7)
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- ⚠️  실행 순서 필수:
--     1단계: 008a-new-categories-enum.sql 먼저 실행 (ENUM 확장 커밋)
--     2단계: 이 파일 실행 (카테고리 7개 + 테크닉 55개 INSERT)
-- ============================================================

-- ============================================================
-- STEP 1: 신규 그룹 카테고리 INSERT (없으면 추가)
-- ============================================================

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active)
VALUES
  ('group_special', '특수 기법', 'Special Techniques', '전문 임상 적용 특수 접근법', '[]'::jsonb, 5, true)
ON CONFLICT (category_key) DO NOTHING;

-- ============================================================
-- STEP 2: 신규 카테고리 7개 INSERT
-- ============================================================

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_art',
  'ART (능동적 이완기법)',
  'Active Release Technique',
  '연부조직 능동 이완 — ART 기반 접근법',
  '[{"icon":"🤲","title_ko":"고정 + 능동 운동의 결합","desc_ko":"치료사가 단축된 근육·건·인대에 접촉 압박을 가하면서 환자가 능동적으로 움직이는 복합 기법입니다."},{"icon":"🔍","title_ko":"단축 방향 촉진","desc_ko":"시술 전 근육의 단축 방향을 촉진으로 확인하고, 접촉 위치와 운동 방향을 결정합니다."},{"icon":"⏱️","title_ko":"반복 횟수 조절","desc_ko":"한 부위에 3~5회 반복이 원칙. 과도한 반복은 조직 자극을 유발합니다."},{"icon":"🚫","title_ko":"DVT 스크리닝 필수","desc_ko":"하지 시술 전 심부정맥혈전증(DVT) 위험 요인을 반드시 확인합니다."}]'::jsonb,
  3,
  true,
  'group_soft_tissue'
)
ON CONFLICT (category_key) DO NOTHING;

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_ctm',
  'CTM (결합조직 마사지)',
  'Connective Tissue Massage',
  '피하 결합조직 자율신경 반사 기법',
  '[{"icon":"🧠","title_ko":"자율신경 반사 기전","desc_ko":"피하 결합조직을 자극하여 척수 분절을 통한 자율신경 반사를 유도합니다."},{"icon":"📋","title_ko":"시작 부위 고정","desc_ko":"천추·허리 부위(CTM-SL)에서 시작하는 것이 원칙입니다. 순서를 어기면 자율신경 반응이 과도해질 수 있습니다."},{"icon":"⚡","title_ko":"긁기 반응 확인","desc_ko":"피부에 가는 붉은 선(dermographism)이 나타나면 올바른 깊이로 시술 중인 신호입니다."},{"icon":"🚫","title_ko":"배 CTM은 마지막","desc_ko":"배 부위(CTM-AB)는 자율신경 반응이 가장 강해 반드시 마지막 단계에만 적용합니다."}]'::jsonb,
  4,
  true,
  'group_soft_tissue'
)
ON CONFLICT (category_key) DO NOTHING;

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_deep_friction',
  '심부마찰 마사지',
  'Deep Transverse Friction Massage',
  'Cyriax 심부가로마찰 — 건·인대 병변 기법',
  '[{"icon":"🔍","title_ko":"병변 정확 촉진","desc_ko":"건 또는 인대의 압통 최대 지점을 엄지·검지로 정확히 촉진하고 시작합니다."},{"icon":"↔️","title_ko":"가로 방향 마찰","desc_ko":"섬유 방향에 직각(가로)으로 짧고 깊은 마찰을 가하는 것이 핵심입니다. 섬유 방향으로 문지르는 것이 아닙니다."},{"icon":"⏱️","title_ko":"충분한 시간","desc_ko":"한 부위에 최소 5~10분 지속 적용이 원칙입니다. 짧게 여러 곳에 적용하는 것은 효과가 낮습니다."},{"icon":"🚫","title_ko":"급성기 금기","desc_ko":"급성 건염이나 인대 파열 초기에는 금기입니다. 아급성~만성기에 적용합니다."}]'::jsonb,
  5,
  true,
  'group_soft_tissue'
)
ON CONFLICT (category_key) DO NOTHING;

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_trigger_point',
  '트리거포인트 이완',
  'Trigger Point Release',
  '근육 내 통증 유발점 허혈성 압박 기법',
  '[{"icon":"🔍","title_ko":"팽팽한 띠(Taut Band) 촉진","desc_ko":"근육 내 팽팽한 띠를 먼저 촉진하고, 그 안에서 압통 결절(tender nodule)을 찾습니다."},{"icon":"🤲","title_ko":"점진적 압박","desc_ko":"압통이 6~7/10 수준으로 느껴질 때까지 서서히 압박을 증가시킵니다. 강한 통증을 유발하지 않습니다."},{"icon":"⏱️","title_ko":"압박 유지 시간","desc_ko":"통증이 3~4/10으로 감소할 때까지 압박을 유지합니다(보통 20~90초). 이완 반응을 기다립니다."},{"icon":"🔄","title_ko":"연관통 패턴 확인","desc_ko":"압박 시 특정 방향으로 통증이 퍼지는 연관통 패턴은 올바른 트리거포인트 확인의 지표입니다."}]'::jsonb,
  6,
  true,
  'group_soft_tissue'
)
ON CONFLICT (category_key) DO NOTHING;

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_anatomy_trains',
  '근막경선 (Anatomy Trains)',
  'Anatomy Trains — Myofascial Meridians',
  'Thomas Myers 근막경선 개념 기반 치료',
  '[{"icon":"🗺️","title_ko":"경선 전체 평가","desc_ko":"증상 부위만 보지 않고 해당 경선 전체의 단축 패턴을 평가합니다."},{"icon":"🔗","title_ko":"연속성 기반 치료","desc_ko":"증상 부위 원위부(멀리)에서 이완을 시작하여 증상 부위로 접근하는 것이 원칙입니다."},{"icon":"⚖️","title_ko":"근거 수준 정직하게 고지","desc_ko":"개별 구성 기법(스트레칭, MFR)에는 근거가 있으나, 경선 전체를 단위로 치료한 RCT는 부족합니다."},{"icon":"🔄","title_ko":"동적 평가 병행","desc_ko":"정적 자세 분석보다 움직임 중 경선 단축 패턴을 동적으로 평가하는 것이 더 유용합니다."}]'::jsonb,
  7,
  true,
  'group_soft_tissue'
)
ON CONFLICT (category_key) DO NOTHING;

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_mdt',
  'MDT (맥켄지 방법)',
  'McKenzie Method / MDT',
  '방향 선호성 기반 반복 운동 치료',
  '[{"icon":"🎯","title_ko":"방향 선호성 평가 우선","desc_ko":"반복 운동 검사를 통해 방향 선호성(directional preference)을 먼저 파악합니다. 검사 없이 운동 처방하지 않습니다."},{"icon":"📉","title_ko":"집중화 현상 목표","desc_ko":"퍼져있던 통증이 중앙(허리·목)으로 모이는 집중화(centralization) 반응을 목표로 합니다."},{"icon":"🔄","title_ko":"반복 운동 원칙","desc_ko":"하루 여러 번 반복이 핵심입니다. 1회 30분 치료보다 하루 10회 자가 운동이 더 효과적입니다."},{"icon":"📚","title_ko":"자가관리 교육","desc_ko":"환자 스스로 증상을 관리하고 재발 시 대처할 수 있도록 독립성을 키우는 것이 MDT의 핵심 목표입니다."}]'::jsonb,
  4,
  true,
  'group_exercise'
)
ON CONFLICT (category_key) DO NOTHING;

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_scs',
  '스트레인-카운터스트레인',
  'Strain-Counterstrain (SCS)',
  'Jones 통증점 반사 억제 기법',
  '[{"icon":"🔍","title_ko":"통증점 촉진","desc_ko":"통증점(tender point)을 촉진하고 0~10점 통증 강도를 확인합니다. 기준 통증이 7 이상이어야 합니다."},{"icon":"🛋️","title_ko":"편안한 자세 찾기","desc_ko":"통증점 통증이 3/10 이하로 감소하는 편안한 자세(position of ease)를 찾는 것이 핵심입니다."},{"icon":"⏱️","title_ko":"90초 유지","desc_ko":"편안한 자세를 90초간 유지합니다. 반사 억제 기전이 작동하는 데 충분한 시간이 필요합니다."},{"icon":"🐢","title_ko":"느린 복귀","desc_ko":"90초 후 중립 자세로 천천히(10~15초) 복귀합니다. 빠른 복귀는 근방추 반사를 재활성화할 수 있습니다."}]'::jsonb,
  3,
  true,
  'group_joint_mobilization'
)
ON CONFLICT (category_key) DO NOTHING;

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_pne',
  '통증 신경과학 교육',
  'Pain Neuroscience Education',
  '통증 기전 이해 기반 인지·행동 교육 접근법',
  '[{"icon":"🧠","title_ko":"통증 ≠ 손상","desc_ko":"통증은 조직 손상의 직접적 신호가 아니라 뇌가 위협을 인식할 때 생성하는 출력 신호임을 교육합니다."},{"icon":"📖","title_ko":"비유와 은유 활용","desc_ko":"\"경보 시스템\", \"볼륨 조절\", \"위협 버킷\" 같은 구체적 비유를 사용하여 복잡한 신경과학 개념을 쉽게 전달합니다."},{"icon":"🔄","title_ko":"운동과 통합","desc_ko":"PNE 단독보다 운동치료와 병합할 때 두려움-회피 행동 개선과 기능 회복에 더 효과적입니다."},{"icon":"💬","title_ko":"대화형 교육","desc_ko":"일방향 강의가 아닌 환자의 통증 신념을 확인하고 함께 재구성하는 대화 방식을 사용합니다."},{"icon":"🚫","title_ko":"심리화 금지","desc_ko":"\"통증이 다 마음에서 온다\"는 식의 표현은 절대 금지합니다. 통증은 실재하며 뇌-신체 상호작용의 결과임을 강조합니다."}]'::jsonb,
  1,
  true,
  'group_special'
)
ON CONFLICT (category_key) DO NOTHING;

-- ============================================================
-- STEP 3: 테크닉 INSERT (55개)
-- ============================================================

-- ────────────────────────────────
-- ART 기법 11개
-- ────────────────────────────────

-- 1/55: 장딴지근 능동적 이완기법
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART',
  '장딴지근 능동적 이완기법', 'Active Release Technique — Gastrocnemius', 'ART-Gastroc',
  'ankle_foot'::body_region, '대퇴골 내측과·외측과(무릎 뒤쪽 뼈) ~ 종골(calcaneus, 발뒤꿈치 뼈)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(calf-gastrocnemius.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_2b'::evidence_level,
  'MD 파일(calf-gastrocnemius.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 2/55: 발바닥 근막 능동적 이완기법
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART',
  '발바닥 근막 능동적 이완기법', 'Active Release Technique — Plantar Fascia', 'ART-PlantarFascia',
  'ankle_foot'::body_region, '종골(calcaneus, 발뒤꿈치 뼈) 내측 결절 ~ 발가락 기저부 (중족지골관절, MTP joint)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(foot-plantar-fascia.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_2b'::evidence_level,
  'MD 파일(foot-plantar-fascia.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 3/55: 아래팔 폄근 능동적 이완기법
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART',
  '아래팔 폄근 능동적 이완기법', 'Active Release Technique — Forearm Wrist Extensors (Lateral Epicondyle)', 'ART-Ext',
  'elbow'::body_region, '위팔뼈 가쪽위관절융기(외측상과) → 손목 폄근(단요측수근신근·장요측수근신근·총지신근 등)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(forearm-extensor-wrist.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_2b'::evidence_level,
  'MD 파일(forearm-extensor-wrist.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 4/55: 아래팔 굽힘근 능동적 이완기법
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART',
  '아래팔 굽힘근 능동적 이완기법', 'Active Release Technique — Forearm Wrist Flexors (Medial Epicondyle)', 'ART-Flex',
  'elbow'::body_region, '위팔뼈 안쪽위관절융기(내측상과) → 손목 굽힘근(요측수근굴근·척측수근굴근·천지굴근 등)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(forearm-flexor-wrist.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(forearm-flexor-wrist.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 5/55: 궁둥구멍근 능동적 이완기법
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART',
  '궁둥구멍근 능동적 이완기법', 'Active Release Technique — Piriformis', 'ART-Piriformis',
  'hip'::body_region, '천골(sacrum, 엉치뼈) ~ 대퇴골 대전자(greater trochanter, 허벅지 바깥 위쪽 돌출 뼈)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(hip-piriformis.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(hip-piriformis.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 6/55: 엉덩허리근 능동적 이완기법
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART',
  '엉덩허리근 능동적 이완기법', 'Active Release Technique — Iliopsoas', 'ART-Iliopsoas',
  'hip'::body_region, 'L1-L4 신경 지배 (엉덩허리근 기시 부위)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(hip-psoas.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(hip-psoas.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 7/55: 목갈비근 능동적 이완기법
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART',
  '목갈비근 능동적 이완기법', 'Active Release Technique — Scalenes', 'ART-Scalenes',
  'cervical'::body_region, 'C3–C6 기시부, 1번 갈비뼈(제1늑골) 부착부',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(neck-scalenes.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","radicular_pain"}', '{"vbi_risk","fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(neck-scalenes.md) 임상 팁 참조. 절대 금기: vbi_risk, fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 8/55: 작은가슴근 능동적 이완기법
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART',
  '작은가슴근 능동적 이완기법', 'Active Release Technique — Pectoralis Minor', 'ART-Pec Minor',
  'shoulder'::body_region, '3–5번 갈비뼈(늑골) 기시부 → 어깨뼈 부리돌기(오훼돌기, coracoid process)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(shoulder-pectoralis-minor.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(shoulder-pectoralis-minor.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 9/55: 어깨 회전근개 능동적 이완기법
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART',
  '어깨 회전근개 능동적 이완기법', 'Active Release Technique — Rotator Cuff (Supraspinatus & Infraspinatus)', 'ART-RC',
  'shoulder'::body_region, '가시위근(극상근, Supraspinatus), 가시아래근(극하근, Infraspinatus)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(shoulder-rotator-cuff.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(shoulder-rotator-cuff.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 10/55: 넙다리뒤근육 능동적 이완기법
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART',
  '넙다리뒤근육 능동적 이완기법', 'Active Release Technique — Hamstrings', 'ART-Hamstring',
  'knee'::body_region, '궁둥뼈결절(ischial tuberosity, 앉을 때 닿는 뼈 돌출부) ~ 무릎 안쪽·바깥쪽 뼈 (경골내측과·비골두)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(thigh-hamstring.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_2b'::evidence_level,
  'MD 파일(thigh-hamstring.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 11/55: 넙다리네갈래근 능동적 이완기법
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART',
  '넙다리네갈래근 능동적 이완기법', 'Active Release Technique — Quadriceps', 'ART-Quad',
  'knee'::body_region, '장골전상극(ASIS, 골반 앞쪽 뼈 돌출부) ~ 무릎뼈(patella, 슬개골)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(thigh-quadriceps.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_2b'::evidence_level,
  'MD 파일(thigh-quadriceps.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- ────────────────────────────────
-- CTM 기법 7개
-- ────────────────────────────────

-- 12/55: 배 결합조직 마사지
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_ctm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ctm'),
  'CTM',
  '배 결합조직 마사지', 'Abdominal Connective Tissue Massage', 'CTM-AB',
  'lumbar'::body_region, '배 앞쪽 근막, 내장 반사 구역 (척수 분절 T5–L2 대응)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(abdomen.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief"}', '{"subacute","chronic","post_surgical"}',
  '{"movement_pain","rest_pain"}', '{"fracture","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(abdomen.md) 임상 팁 참조. 절대 금기: fracture, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 13/55: 엉덩이·허벅지 바깥쪽 결합조직 마사지
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_ctm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ctm'),
  'CTM',
  '엉덩이·허벅지 바깥쪽 결합조직 마사지', 'Hip and Lateral Thigh Connective Tissue Massage', 'CTM-HL',
  'hip'::body_region, '엉덩이뼈 능선(장골능)·허벅지 바깥쪽 근막(장경인대 주변)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(hip-lateral.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(hip-lateral.md) 임상 팁 참조. 절대 금기: fracture, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 14/55: 종아리·발 결합조직 마사지
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_ctm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ctm'),
  'CTM',
  '종아리·발 결합조직 마사지', 'Lower Leg and Foot Connective Tissue Massage', 'CTM-LF',
  'ankle_foot'::body_region, '종아리 전체·발목·발등·발바닥 근막',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(lower-leg-foot.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(lower-leg-foot.md) 임상 팁 참조. 절대 금기: fracture, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 15/55: 목·뒤통수 결합조직 마사지
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_ctm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ctm'),
  'CTM',
  '목·뒤통수 결합조직 마사지', 'Neck-Occipital Connective Tissue Massage', 'CTM-NO',
  'cervical'::body_region, 'C1–C7, 뒤통수(후두골) 하단 경계',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(neck-occipital.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"vbi_risk","fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(neck-occipital.md) 임상 팁 참조. 절대 금기: vbi_risk, fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 16/55: 천추·허리 부위 결합조직 마사지
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_ctm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ctm'),
  'CTM',
  '천추·허리 부위 결합조직 마사지', 'Sacral-Lumbar Connective Tissue Massage', 'CTM-SL',
  'lumbar'::body_region, 'L1–S4',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(sacral-lumbar-region.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(sacral-lumbar-region.md) 임상 팁 참조. 절대 금기: fracture, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 17/55: 어깨·가슴 앞쪽 결합조직 마사지
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_ctm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ctm'),
  'CTM',
  '어깨·가슴 앞쪽 결합조직 마사지', 'Shoulder and Anterior Chest Connective Tissue Massage', 'CTM-SC',
  'shoulder'::body_region, '빗장뼈(쇄골) 주변, 어깨 앞쪽, 가슴 앞쪽(흉골 옆)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(shoulder-chest.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(shoulder-chest.md) 임상 팁 참조. 절대 금기: fracture, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 18/55: 등 상부·중부 결합조직 마사지
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_ctm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ctm'),
  'CTM',
  '등 상부·중부 결합조직 마사지', 'Thoracic Back Connective Tissue Massage', 'CTM-TB',
  'thoracic'::body_region, 'T1–T12',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(thoracic-back.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(thoracic-back.md) 임상 팁 참조. 절대 금기: fracture, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- ────────────────────────────────
-- DeepFriction 기법 7개
-- ────────────────────────────────

-- 19/55: 아킬레스건 심부마사지
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'DeepFriction',
  '아킬레스건 심부마사지', 'Deep Transverse Friction Massage — Achilles Tendon', 'DTFM-Achilles',
  'ankle_foot'::body_region, '아킬레스건(Achilles tendon) — 건 중간부(midportion, 발꿈치뼈 위 2~6cm 구간) 및 건-뼈 이행부(insertional, 발꿈치뼈 부착부)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(achilles-tendon.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","osteoporosis","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(achilles-tendon.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 20/55: 팔꿈치 가쪽 뼈 돌출 부위 심부마사지 (테니스 엘보)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'DeepFriction',
  '팔꿈치 가쪽 뼈 돌출 부위 심부마사지 (테니스 엘보)', 'Deep Transverse Friction Massage — Lateral Epicondyle (Tennis Elbow)', 'DTFM-Lateral Epicondyle',
  'elbow'::body_region, '손목 폄근 기시부 — 단요측수근신근(ECRB, extensor carpi radialis brevis) 및 총지신근(EDC) 기시부, 팔꿈치 가쪽 뼈 돌출 부위(lateral epicondyle) 부착부',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(elbow-lateral-epicondyle.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain"}', '{"fracture","malignancy","inflammation_acute"}',
  'level_2b'::evidence_level,
  'MD 파일(elbow-lateral-epicondyle.md) 임상 팁 참조. 절대 금기: fracture, malignancy. 상대 금기: inflammation_acute.',
  'fracture, malignancy',
  'inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 21/55: 팔꿈치 안쪽 뼈 돌출 부위 심부마사지 (골프 엘보)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'DeepFriction',
  '팔꿈치 안쪽 뼈 돌출 부위 심부마사지 (골프 엘보)', 'Deep Transverse Friction Massage — Medial Epicondyle (Golfer''s Elbow)', 'DTFM-Medial Epicondyle',
  'elbow'::body_region, '손목 굽힘근 기시부 — 원형 엎침근(pronator teres), 요측수근굴근(FCR), 척측수근굴근(FCU) 공동 기시부, 팔꿈치 안쪽 뼈 돌출 부위(medial epicondyle) 부착부',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(elbow-medial-epicondyle.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain"}', '{"fracture","instability","malignancy","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(elbow-medial-epicondyle.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy. 상대 금기: inflammation_acute.',
  'fracture, instability, malignancy',
  'inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 22/55: 발바닥 근막 기시부 심부마사지 (발꿈치 통증)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'DeepFriction',
  '발바닥 근막 기시부 심부마사지 (발꿈치 통증)', 'Deep Transverse Friction Massage — Plantar Fascia Origin (Heel Pain)', 'DTFM-Plantar Fascia',
  'ankle_foot'::body_region, '발바닥 근막(plantar fascia) 기시부 — 발꿈치뼈(calcaneus, 종골) 내측 결절(medial tubercle) 부착 지점',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(foot-plantar-fascia.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","malignancy","osteoporosis","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(foot-plantar-fascia.md) 임상 팁 참조. 절대 금기: fracture, malignancy. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 23/55: 무릎 안쪽 인대 심부마사지 (내측 측부인대 손상)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'DeepFriction',
  '무릎 안쪽 인대 심부마사지 (내측 측부인대 손상)', 'Deep Transverse Friction Massage — Medial Collateral Ligament (MCL)', 'DTFM-MCL',
  'knee'::body_region, '내측 측부인대(medial collateral ligament, MCL) — 대퇴골(허벅지뼈) 내측 상과 기시부·인대 중간부·경골(정강이뼈) 부착부',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(knee-medial-collateral-ligament.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain"}', '{"fracture","instability","malignancy","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(knee-medial-collateral-ligament.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy. 상대 금기: inflammation_acute.',
  'fracture, instability, malignancy',
  'inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 24/55: 무릎뼈 아래 힘줄 심부마사지 (점퍼스 니)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'DeepFriction',
  '무릎뼈 아래 힘줄 심부마사지 (점퍼스 니)', 'Deep Transverse Friction Massage — Patellar Tendon (Jumper''s Knee)', 'DTFM-Patellar Tendon',
  'knee'::body_region, '무릎뼈 아래 힘줄(patellar tendon) — 무릎뼈(patella) 하극(lower pole) 부착부 및 힘줄 중간부',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(knee-patellar-tendon.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain"}', '{"fracture","malignancy","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(knee-patellar-tendon.md) 임상 팁 참조. 절대 금기: fracture, malignancy. 상대 금기: inflammation_acute.',
  'fracture, malignancy',
  'inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 25/55: 어깨 가시위근 힘줄 심부마사지
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'DeepFriction',
  '어깨 가시위근 힘줄 심부마사지', 'Deep Transverse Friction Massage — Supraspinatus Tendon', 'DTFM-Supraspinatus',
  'shoulder'::body_region, '가시위근 힘줄 (supraspinatus tendon) — 대결절(greater tubercle) 부착부 및 건-근 이행부',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(shoulder-supraspinatus-tendon.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain"}', '{"fracture","malignancy","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(shoulder-supraspinatus-tendon.md) 임상 팁 참조. 절대 금기: fracture, malignancy. 상대 금기: inflammation_acute.',
  'fracture, malignancy',
  'inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- ────────────────────────────────
-- TriggerPoint 기법 11개
-- ────────────────────────────────

-- 26/55: 장딴지근·가자미근 트리거포인트 압박
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TriggerPoint',
  '장딴지근·가자미근 트리거포인트 압박', 'Gastrocnemius & Soleus Trigger Point Release', 'GAST-SOL-TPR',
  'ankle_foot'::body_region, '오금(무릎 뒤 관절)–발꿈치(종골) 사이 종아리 전체',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(calf-gastrocnemius-soleus.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(calf-gastrocnemius-soleus.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 27/55: 손목 폄근 트리거포인트 허혈성 압박 (아래팔 폄근)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TriggerPoint',
  '손목 폄근 트리거포인트 허혈성 압박 (아래팔 폄근)', 'Wrist Extensor Trigger Point — Ischemic Compression (Lateral Epicondylalgia)', 'WE-TrP',
  'elbow'::body_region, '손목 요측수근신근 (ECRB/ECRL, Extensor Carpi Radialis Brevis/Longus), 총지신근 (EDC, Extensor Digitorum Communis) — 가쪽위관절융기(lateral epicondyle, 팔꿈치 바깥쪽 뼈 돌출부) 기시부에서 아래팔까지',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(forearm-extensor-wrist.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_2b'::evidence_level,
  'MD 파일(forearm-extensor-wrist.md) 임상 팁 참조. 절대 금기: fracture, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 28/55: 중간볼기근 트리거포인트 압박
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TriggerPoint',
  '중간볼기근 트리거포인트 압박', 'Gluteus Medius Trigger Point Release', 'GMED-TPR',
  'hip'::body_region, '장골능(엉덩이 위쪽 뼈)–대퇴골 대전자(허벅지 뼈 바깥 돌기) 사이 엉덩이 옆',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(hip-glute-medius.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(hip-glute-medius.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 29/55: 궁둥구멍근 트리거포인트 압박
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TriggerPoint',
  '궁둥구멍근 트리거포인트 압박', 'Piriformis Trigger Point Release', 'PIR-TPR',
  'hip'::body_region, '천골(엉치뼈)–대퇴골 대전자(허벅지 뼈 바깥 돌기) 사이',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(hip-piriformis.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(hip-piriformis.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 30/55: 허리네모근 트리거포인트 압박
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TriggerPoint',
  '허리네모근 트리거포인트 압박', 'Quadratus Lumborum Trigger Point Release', 'QL-TPR',
  'lumbar'::body_region, 'L1-L4 (허리 척추 1~4번) 옆쪽',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(lower-back-quadratus-lumborum.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(lower-back-quadratus-lumborum.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 31/55: 목빗근 트리거포인트 허혈성 압박
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TriggerPoint',
  '목빗근 트리거포인트 허혈성 압박', 'Sternocleidomastoid (SCM) Trigger Point — Ischemic Compression', 'SCM-TrP',
  'cervical'::body_region, '목빗근 (Sternocleidomastoid) — 흉골(가슴뼈)·빗장뼈(쇄골)에서 귀 뒤 유양돌기(mastoid process)까지',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(neck-sternocleidomastoid.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"vbi_risk","fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(neck-sternocleidomastoid.md) 임상 팁 참조. 절대 금기: vbi_risk, fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 32/55: 위등세모근 트리거포인트 허혈성 압박
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TriggerPoint',
  '위등세모근 트리거포인트 허혈성 압박', 'Upper Trapezius Trigger Point — Ischemic Compression', 'UT-TrP',
  'cervical'::body_region, '위등세모근 (Upper Trapezius) — 목덜미~어깨 봉우리(acromion) 구간',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(neck-upper-trapezius.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"vbi_risk","fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_2b'::evidence_level,
  'MD 파일(neck-upper-trapezius.md) 임상 팁 참조. 절대 금기: vbi_risk, fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 33/55: 가시아래근 트리거포인트 허혈성 압박
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TriggerPoint',
  '가시아래근 트리거포인트 허혈성 압박', 'Infraspinatus Trigger Point — Ischemic Compression', 'IS-TrP',
  'shoulder'::body_region, '가시아래근 (Infraspinatus) — 어깨뼈(견갑골, scapula) 뒤면의 가시아래오목(infraspinous fossa)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(shoulder-infraspinatus.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_2b'::evidence_level,
  'MD 파일(shoulder-infraspinatus.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 34/55: 넙다리뒤근육 트리거포인트 압박
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TriggerPoint',
  '넙다리뒤근육 트리거포인트 압박', 'Hamstring Trigger Point Release', 'HAM-TPR',
  'hip'::body_region, '좌골결절(앉는 뼈)–오금(무릎 뒤 관절) 사이 허벅지 뒤쪽',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(thigh-hamstring.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(thigh-hamstring.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 35/55: 넙다리근막긴장근 트리거포인트 압박
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TriggerPoint',
  '넙다리근막긴장근 트리거포인트 압박', 'Tensor Fascia Latae Trigger Point Release', 'TFL-TPR',
  'hip'::body_region, '상전장골극(앞쪽 엉덩이 뼈 위 돌기)–장경인대(허벅지 바깥 긴 띠) 상부',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(thigh-tensor-fascia-latae.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","radicular_pain"}', '{"fracture","instability","malignancy","osteoporosis","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(thigh-tensor-fascia-latae.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 36/55: 마름근 트리거포인트 허혈성 압박
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TriggerPoint',
  '마름근 트리거포인트 허혈성 압박', 'Rhomboid Major/Minor Trigger Point — Ischemic Compression', 'RH-TrP',
  'thoracic'::body_region, '마름근 (Rhomboid Major & Minor) — 등 척추(T2~T5)에서 어깨뼈(견갑골) 안쪽 경계까지',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(upper-back-rhomboids.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(upper-back-rhomboids.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- ────────────────────────────────
-- AnatomyTrains 기법 7개
-- ────────────────────────────────

-- 37/55: 팔 경선
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_anatomy_trains',
  (SELECT id FROM technique_categories WHERE category_key = 'category_anatomy_trains'),
  'AnatomyTrains',
  '팔 경선', 'Arm Lines', 'AL',
  'full_spine'::body_region, '앞 표재 팔 경선(SFAL) / 앞 심부 팔 경선(DFAL) / 뒤 표재 팔 경선(SBAL) / 뒤 심부 팔 경선(DBAL) — 4개 통합',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(AL-arm-lines.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{}', '{}',
  '{}', '{"fracture","instability","malignancy","osteoporosis","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(AL-arm-lines.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 38/55: 심부 전면 경선
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_anatomy_trains',
  (SELECT id FROM technique_categories WHERE category_key = 'category_anatomy_trains'),
  'AnatomyTrains',
  '심부 전면 경선', 'Deep Front Line', 'DFL',
  'full_spine'::body_region, '후경골근·장지굴근 → 슬와근 → 내전근군 → 골반기저근 → 장요근 → 횡격막 → 대요근·소요근 → 전종인대 → 경추 심부굴곡근',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(DFL-deep-front-line.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","stabilization","proprioception"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(DFL-deep-front-line.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 39/55: 기능선
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_anatomy_trains',
  (SELECT id FROM technique_categories WHERE category_key = 'category_anatomy_trains'),
  'AnatomyTrains',
  '기능선', 'Functional Lines', 'FL',
  'full_spine'::body_region, '앞 기능선(FFL): 대흉근 → 복직근 → 반대쪽 내전근 / 뒤 기능선(BFL): 광배근 → 천결절인대 → 반대쪽 햄스트링',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(FL-functional-lines.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{}', '{}',
  '{}', '{"fracture","malignancy","osteoporosis","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(FL-functional-lines.md) 임상 팁 참조. 절대 금기: fracture, malignancy. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 40/55: 측면 경선
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_anatomy_trains',
  (SELECT id FROM technique_categories WHERE category_key = 'category_anatomy_trains'),
  'AnatomyTrains',
  '측면 경선', 'Lateral Line', 'LL',
  'full_spine'::body_region, '비골근 → 장경인대·IT band → 대퇴근막장근(TFL) → 복사근 → 늑간근 → 흉쇄유돌근·판상근',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(LL-lateral-line.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","stabilization","proprioception"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain"}', '{"fracture","malignancy","osteoporosis","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(LL-lateral-line.md) 임상 팁 참조. 절대 금기: fracture, malignancy. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 41/55: 후면 표재 경선
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_anatomy_trains',
  (SELECT id FROM technique_categories WHERE category_key = 'category_anatomy_trains'),
  'AnatomyTrains',
  '후면 표재 경선', 'Superficial Back Line', 'SBL',
  'full_spine'::body_region, '족저근막 → 비복근·가자미근 → 햄스트링 → 천결절인대 → 척추기립근 → 판상근 → 두피건막',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(SBL-superficial-back-line.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","proprioception"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain"}', '{"fracture","malignancy","osteoporosis","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(SBL-superficial-back-line.md) 임상 팁 참조. 절대 금기: fracture, malignancy. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 42/55: 전면 표재 경선
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_anatomy_trains',
  (SELECT id FROM technique_categories WHERE category_key = 'category_anatomy_trains'),
  'AnatomyTrains',
  '전면 표재 경선', 'Superficial Front Line', 'SFL',
  'full_spine'::body_region, '발등 단신근 → 전경골근 → 대퇴직근·대퇴사두근 → 복직근 → 흉골근·흉쇄유돌근',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(SFL-superficial-front-line.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","proprioception"}', '{"subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain"}', '{"fracture","malignancy","inflammation_acute"}',
  'level_3'::evidence_level,
  'MD 파일(SFL-superficial-front-line.md) 임상 팁 참조. 절대 금기: fracture, malignancy. 상대 금기: inflammation_acute.',
  'fracture, malignancy',
  'inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 43/55: 나선 경선
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_anatomy_trains',
  (SELECT id FROM technique_categories WHERE category_key = 'category_anatomy_trains'),
  'AnatomyTrains',
  '나선 경선', 'Spiral Line', 'SL',
  'full_spine'::body_region, '판상근(두부) → 능형근 → 전거근 → 외복사근 → 반대쪽 내복사근 → 장경인대 → 전경골근 → 비골근 → 족저근막 → 다시 상행',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(SL-spiral-line.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","stabilization","proprioception"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain"}', '{"fracture","malignancy","osteoporosis","inflammation_acute"}',
  'level_5'::evidence_level,
  'MD 파일(SL-spiral-line.md) 임상 팁 참조. 절대 금기: fracture, malignancy. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, malignancy',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- ────────────────────────────────
-- MDT 기법 5개
-- ────────────────────────────────

-- 44/55: 목 굴곡·측방 방향 선호 운동 (앞으로 숙이기 + 옆으로 굽히기)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mdt',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mdt'),
  'MDT',
  '목 굴곡·측방 방향 선호 운동 (앞으로 숙이기 + 옆으로 굽히기)', 'MDT Cervical Flexion and Lateral Principle', 'MDT-CFL',
  'cervical'::body_region, 'C1–C4 (상위 목 척추, 굴곡 선호 빈도 높음), 측방은 전 분절 가능',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(cervical-flexion-lateral.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"vbi_risk","fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_2b'::evidence_level,
  'MD 파일(cervical-flexion-lateral.md) 임상 팁 참조. 절대 금기: vbi_risk, fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 45/55: 목 후퇴·신전 방향 선호 운동 (턱 당기기 + 뒤로 젖히기)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mdt',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mdt'),
  'MDT',
  '목 후퇴·신전 방향 선호 운동 (턱 당기기 + 뒤로 젖히기)', 'MDT Cervical Retraction and Extension', 'MDT-CRE',
  'cervical'::body_region, 'C3–C7 (중·하위 목 척추, 경추 후관절 및 디스크 주요 분절)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(cervical-retraction-extension.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}', '{"acute","subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"vbi_risk","fracture","instability","malignancy","neurological_deficit","osteoporosis"}',
  'level_1b'::evidence_level,
  'MD 파일(cervical-retraction-extension.md) 임상 팁 참조. 절대 금기: vbi_risk, fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis.',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit',
  'osteoporosis',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 46/55: 허리 신전 방향 선호 운동 (뒤로 젖히기 방향)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mdt',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mdt'),
  'MDT',
  '허리 신전 방향 선호 운동 (뒤로 젖히기 방향)', 'MDT Lumbar Extension Principle', 'MDT-LE',
  'lumbar'::body_region, 'L1–L5, L5–S1 (특정 분절 없이 전체 허리에 적용)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(lumbar-extension-principle.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}', '{"acute","subacute","chronic","hypomobile"}',
  '{"movement_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis"}',
  'level_1b'::evidence_level,
  'MD 파일(lumbar-extension-principle.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 47/55: 허리 굴곡 방향 선호 운동 (앞으로 굽히기 방향)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mdt',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mdt'),
  'MDT',
  '허리 굴곡 방향 선호 운동 (앞으로 굽히기 방향)', 'MDT Lumbar Flexion Principle', 'MDT-LF',
  'lumbar'::body_region, 'L1–L5, L5–S1 (특히 상위 허리 분절에서 굴곡 선호 빈도 높음)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(lumbar-flexion-principle.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis"}',
  'level_2b'::evidence_level,
  'MD 파일(lumbar-flexion-principle.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 48/55: 허리 측방 이동 교정 (옆으로 치우침 교정)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mdt',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mdt'),
  'MDT',
  '허리 측방 이동 교정 (옆으로 치우침 교정)', 'MDT Lumbar Lateral Shift Correction', 'MDT-LLS',
  'lumbar'::body_region, 'L4–L5, L5–S1 (측방 이동이 가장 빈번한 분절)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(lumbar-lateral-shift-correction.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}', '{"acute","subacute","hypomobile"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_2b'::evidence_level,
  'MD 파일(lumbar-lateral-shift-correction.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: 없음.',
  'fracture, instability, malignancy, neurological_deficit',
  '',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- ────────────────────────────────
-- SCS 기법 7개
-- ────────────────────────────────

-- 49/55: 목 앞쪽 통증점 카운터스트레인
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS',
  '목 앞쪽 통증점 카운터스트레인', 'Cervical Anterior Tender Points — Strain-Counterstrain', 'CA SCS',
  'cervical'::body_region, 'C1-C7 전방',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(cervical-anterior-tender-points.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"acute","subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"vbi_risk","fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(cervical-anterior-tender-points.md) 임상 팁 참조. 절대 금기: vbi_risk, fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 50/55: 목 뒤쪽 통증점 카운터스트레인
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS',
  '목 뒤쪽 통증점 카운터스트레인', 'Cervical Posterior Tender Points — Strain-Counterstrain', 'CP SCS',
  'cervical'::body_region, 'C1-C7 후방',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(cervical-posterior-tender-points.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"acute","subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"vbi_risk","fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(cervical-posterior-tender-points.md) 임상 팁 참조. 절대 금기: vbi_risk, fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 51/55: 엉덩이·어깨 통증점 카운터스트레인
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS',
  '엉덩이·어깨 통증점 카운터스트레인', 'Hip & Shoulder Tender Points — Strain-Counterstrain', 'HS SCS',
  'hip'::body_region, '엉덩이관절(Hip Joint), 어깨관절(Glenohumeral Joint), 견봉쇄골관절(AC Joint)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(hip-shoulder-tender-points.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"acute","subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(hip-shoulder-tender-points.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 52/55: 허리 앞쪽 통증점 카운터스트레인
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS',
  '허리 앞쪽 통증점 카운터스트레인', 'Lumbar Anterior Tender Points — Strain-Counterstrain', 'LA SCS',
  'lumbar'::body_region, 'L1-L5 전방',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(lumbar-anterior-tender-points.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"acute","subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(lumbar-anterior-tender-points.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 53/55: 허리 뒤쪽 통증점 카운터스트레인
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS',
  '허리 뒤쪽 통증점 카운터스트레인', 'Lumbar Posterior Tender Points — Strain-Counterstrain', 'LP SCS',
  'lumbar'::body_region, 'L1-L5 후방',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(lumbar-posterior-tender-points.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"acute","subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(lumbar-posterior-tender-points.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 54/55: 엉치뼈·골반 통증점 카운터스트레인
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS',
  '엉치뼈·골반 통증점 카운터스트레인', 'Sacral & Iliac Tender Points — Strain-Counterstrain', 'SI SCS',
  'sacroiliac'::body_region, '엉치뼈(천골, Sacrum), 엉덩이관절(천장관절, Sacroiliac Joint), 골반뼈(장골, Ilium)',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(sacral-iliac-tender-points.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"acute","subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(sacral-iliac-tender-points.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- 55/55: 등·갈비뼈 통증점 카운터스트레인
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS',
  '등·갈비뼈 통증점 카운터스트레인', 'Thoracic & Rib Tender Points — Strain-Counterstrain', 'T/Rib SCS',
  'thoracic'::body_region, 'T1-T12, Rib 1-12',
  NULL, NULL, NULL, NULL,
  '[{"step":1,"instruction":"MD 파일(thoracic-rib-tender-points.md)의 시술 방법 4절 참조 — 상세 단계별 절차 포함"},{"step":2,"instruction":"환자 자세 및 치료사 접촉 위치 확인 후 시작"},{"step":3,"instruction":"기법 적용 및 환자 반응 모니터링"},{"step":4,"instruction":"시술 후 재평가 — 통증 NRS, 가동범위 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"acute","subacute","chronic","post_surgical","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","osteoporosis","inflammation_acute"}',
  'level_4'::evidence_level,
  'MD 파일(thoracic-rib-tender-points.md) 임상 팁 참조. 절대 금기: fracture, instability, malignancy, neurological_deficit. 상대 금기: osteoporosis, inflammation_acute.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- ============================================================
-- 검증 쿼리 (실행 후 확인용)
-- SELECT category, COUNT(*) FROM techniques GROUP BY category ORDER BY category;
-- 기대값: category_art=11, category_ctm=7, category_deep_friction=7,
--         category_trigger_point=11, category_anatomy_trains=7, category_mdt=5, category_scs=7
-- ============================================================
