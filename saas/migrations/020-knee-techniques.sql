-- Migration 020: Knee (무릎 관절) Techniques
-- 무릎 관절 28개 기법: JM 6 + Mulligan 3 + MFR 4 + ART 4 + CTM 2 + DFM 4 + TrP 5
-- sw-db-architect | 2026-04-28

BEGIN;

-- =============================================================
-- SECTION 1: category_joint_mobilization — 6 techniques
-- =============================================================

-- ────────────────────────────────
-- KN-JM-TFJ-PA: 무릎 경대퇴관절 후방 PA 글라이드
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_joint_mobilization',
  (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
  'Maitland — TFJ',
  '무릎 경대퇴관절 후방 PA 글라이드', 'Tibiofemoral PA Glide', 'KN-JM-TFJ-PA',
  'knee'::body_region, 'TFJ 후방 관절낭',
  '엎드려 눕기, 무릎 중립 위치(완전히 펴기)',
  '환자 환측 옆에 위치하여 한 손으로 대퇴 원위부를 안정화하고, 반대 손 손바닥 또는 엄지 중첩으로 경골 근위부 후방면에 접촉 준비',
  '경골 근위부 후방면 (손바닥 또는 엄지 중첩)',
  '전방 PA 글라이드 (Grade II–IV)',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 무릎이 테이블 위에서 중립 위치(완전히 펴기 또는 약간 굽힌 위치)로 이완되도록 한다. 치료 측 발목 아래에 작은 쿠션을 넣어 무릎 부위를 약간 들어올려 접근성을 높일 수 있다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 한 손을 대퇴 원위부(오금 바로 위)에 올려 대퇴골을 가볍게 안정화한다. 반대 손의 손바닥 또는 엄지 중첩을 경골 근위부 후방면(슬와부 바로 아래)에 부드럽게 접촉한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade II는 관절 저항이 느껴지기 전 범위에서 리듬감 있는 소진폭 가동을 적용하고, Grade III–IV는 관절 끝 범위에서 대진폭 또는 소진폭 가동을 적용한다. 굴곡 제한이 있는 경우 무릎을 약간 굽힌 상태로 시작할 수 있다."},{"step":4,"instruction":"경골 근위부를 전방(복측) 방향으로 리듬감 있게 밀어주며 후방 관절낭의 이완 반응을 유도한다. 시술 중 환자의 통증 반응과 조직 저항 변화를 지속적으로 확인하여 Grade를 조정한다."},{"step":5,"instruction":"30초–1분 시술 후 무릎 굽히기 범위와 통증 정도를 재평가한다. ROM 증가 또는 통증 감소가 확인되면 같은 Grade로 2–3세트 반복하거나 Grade를 상향 조정한다. 필요 시 무릎 굽히기 위치에서 동일 기법을 반복한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"knee_flexion_restriction","posterior_capsule_tightness","knee_pain"}',
  '{"fracture","joint_infection","malignancy","acute_inflammation"}',
  'level_2b'::evidence_level,
  '후방 관절낭 단축이 의심될 때 적용 가능성이 높다. Grade II–IV 적용 시 무릎 굽히기 범위의 즉각적 개선을 기대할 수 있다. 슬관절 치환술 후 재활 초기에는 Grade I–II에서 시작하여 조직 반응을 평가한 후 Grade를 올리는 것이 안전할 수 있다.',
  'fracture, joint_infection, malignancy, DVT',
  'acute_inflammation, severe_osteoporosis, anticoagulant_therapy, recent_knee_surgery',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-JM-TFJ-AP: 무릎 경대퇴관절 전방 AP 글라이드
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_joint_mobilization',
  (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
  'Maitland — TFJ',
  '무릎 경대퇴관절 전방 AP 글라이드', 'Tibiofemoral AP Glide', 'KN-JM-TFJ-AP',
  'knee'::body_region, 'TFJ 전방 관절낭',
  '바로 눕기, 무릎 약간 굽힌 위치(10–20도)',
  '환자 환측 옆에 위치하여 한 손으로 대퇴 원위부를 안정화하고, 반대 손을 경골 근위부 전방면에 접촉 준비',
  '경골 근위부 전방면 (손바닥 또는 손 웹 스페이스)',
  '후방 AP 글라이드 (Grade II–IV)',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 무릎 아래에 쿠션이나 롤을 넣어 10–20도 정도 굽힌 위치를 만든다. 이 자세는 전방 관절낭에 적당한 이완을 제공하면서 경골에 접근하기 좋은 시작 위치다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 한 손을 대퇴 원위부(슬개골 바로 위)에 올려 대퇴골을 가볍게 안정화한다. 반대 손의 손바닥 또는 웹 스페이스를 경골 근위부 전방면(경골 조면 근처)에 접촉한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade II는 저항이 느껴지기 전 범위에서 리듬 가동, Grade III–IV는 끝 범위에서 대진폭 또는 소진폭 가동을 적용한다. 무릎 펴기 제한이 심한 경우 좀 더 펴진 위치에서 시작할 수 있다."},{"step":4,"instruction":"경골 근위부를 후방(배측) 방향으로 리듬감 있게 밀어주며 전방 관절낭의 이완을 유도한다. PCL 손상 후 재활에서는 Grade I–II를 먼저 평가하고 조직 반응을 확인한 후 Grade를 상향 조정한다."},{"step":5,"instruction":"30초–1분 시술 후 무릎 펴기 범위와 종말감(end-feel)을 재평가한다. 편심성 종말감(springy) 변화나 ROM 증가가 확인되면 2–3세트 반복한다. 필요 시 무릎 각도를 달리하여 다른 범위에서도 반복 적용한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"knee_extension_restriction","anterior_capsule_tightness","PCL_rehabilitation"}',
  '{"fracture","joint_infection","malignancy","acute_inflammation"}',
  'level_2b'::evidence_level,
  '전방 관절낭 단축이 의심될 때 적용 가능성이 높다. PCL 손상 후 재활에서 무릎 펴기 기능 회복을 목표로 할 때 초기 Grade는 낮게 유지하는 것이 조직 보호에 유리할 수 있다. 시술 후 무릎 종말감 변화(탄성 증가)를 통해 관절낭 이완 효과를 평가할 수 있다.',
  'fracture, joint_infection, malignancy, DVT',
  'acute_inflammation, PCL_acute_tear, severe_osteoporosis, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-JM-TFJ-LAT: 무릎 경골 외측 글라이드
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_joint_mobilization',
  (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
  'Maitland — TFJ',
  '무릎 경골 외측 글라이드', 'Tibia Lateral Glide', 'KN-JM-TFJ-LAT',
  'knee'::body_region, 'TFJ 내측 관절낭',
  '바로 눕기, 무릎 약간 굽힌 위치(10–20도)',
  '환자 발쪽에 위치하여 한 손으로 대퇴 원위부 외측면을 안정화하고, 반대 손을 경골 근위부 내측면에 접촉 준비',
  '경골 근위부 내측면 (손바닥 또는 손 웹 스페이스)',
  '외측 글라이드 (Grade I–III)',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 무릎 아래에 쿠션을 넣어 10–20도 굽힌 편안한 위치를 만든다. 내측 관절낭 및 내측 측부인대(MCL) 주변의 긴장이 최소화되는 자세인지 확인한다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 한 손을 대퇴 원위부 외측면에 올려 안정화한다. 반대 손의 손바닥 또는 웹 스페이스를 경골 근위부 내측면에 부드럽게 접촉한다. 접촉 위치가 내측 관절선 바로 아래 경골에 있는지 확인한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade I–II는 저항 느껴지기 전 범위에서 가벼운 리듬 가동을 적용하여 통증 억제 효과를 유도한다. Grade III는 내측 관절낭 저항에 도달하는 대진폭 가동을 적용한다."},{"step":4,"instruction":"경골 근위부를 외측 방향으로 리듬감 있게 밀어주며 내측 관절낭과 MCL 주변 조직의 이완을 유도한다. 시술 중 환자가 내측 관절선 부위에서 느끼는 통증 및 저항 변화를 지속적으로 확인한다."},{"step":5,"instruction":"30초–1분 시술 후 내측 관절선 압통 정도와 무릎 가동범위를 재평가한다. 내측 공간 협착감 감소나 ROM 변화가 확인되면 2–3세트를 반복한다. 내측 측부인대 손상 후 유착 단계에서는 Grade를 점진적으로 상향 조정한다."}]'::jsonb,
  '{"pain_relief","joint_mobility","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"medial_knee_pain","medial_joint_space_restriction","MCL_post_injury_stiffness"}',
  '{"fracture","joint_infection","malignancy","acute_MCL_tear"}',
  'level_2b'::evidence_level,
  '내측 관절낭 협착 또는 MCL 유착 후 가동성 저하가 의심될 때 적용 가능성이 높다. 내측 공간이 좁아진 경우 Grade I–II에서 통증 억제 효과를 기대할 수 있다. MCL 급성 파열 시에는 금기이며, 아급성기 이후 유착 단계에서만 적용해야 할 수 있다.',
  'fracture, joint_infection, malignancy, DVT, acute_MCL_rupture',
  'acute_inflammation, severe_osteoporosis, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-JM-PFJ-MED: 슬개골 내측 글라이드
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_joint_mobilization',
  (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
  'Maitland — PFJ',
  '슬개골 내측 글라이드', 'Medial Patellar Glide', 'KN-JM-PFJ-MED',
  'knee'::body_region, 'PFJ 외측 지지띠',
  '바로 눕기, 무릎 완전히 펴기 또는 약간 굽힌 위치(0–10도)',
  '환자 환측 옆에 위치하여 양 엄지 끝을 슬개골 외측연에 중첩 접촉 준비',
  '슬개골 외측연 (양 엄지 중첩)',
  '내측 글라이드 (Grade I–III)',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 무릎을 완전히 펴거나 약간(0–10도) 굽힌 상태로 이완시킨다. 대퇴사두근이 완전히 이완되어야 슬개골 가동이 용이하므로 대퇴 근육 긴장 여부를 먼저 확인한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 앉거나 서서 양 엄지 끝을 슬개골 외측연에 나란히 중첩하여 접촉한다. 슬개골 위 연골 부위를 직접 누르지 않도록 외측연(가장자리)에만 접촉하고 있는지 확인한다."},{"step":3,"instruction":"Grade I–II는 저항이 느껴지기 전 범위에서 가벼운 리듬 진동으로 내측 방향 소진폭 가동을 적용한다. Grade III는 외측 지지띠(retinaculum) 저항에 도달하는 대진폭 가동을 적용한다. 통증이 심한 급성기는 Grade I–II만 적용한다."},{"step":4,"instruction":"슬개골을 내측 방향으로 리듬감 있게 밀어주며 외측 지지띠의 이완을 유도한다. 슬개골이 내측으로 자연스럽게 활주하는지, 또는 조기 저항이 느껴지는지 확인하면서 병변 정도를 평가한다."},{"step":5,"instruction":"30초–1분 시술 후 슬개골 내측 활주 범위와 전방 무릎 통증 정도를 재평가한다. 통증 감소 또는 내측 활주 범위 증가가 확인되면 2–3세트를 반복한다. 이후 외측 지지띠 자가 신장 운동(lateral retinaculum stretching)을 함께 교육할 수 있다."}]'::jsonb,
  '{"pain_relief","patellar_mobility","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"anterior_knee_pain","PFPS","lateral_retinaculum_tightness","patellar_tracking_dysfunction"}',
  '{"fracture","joint_infection","malignancy","acute_inflammation","patellar_instability"}',
  'level_2b'::evidence_level,
  '슬개대퇴 통증증후군(PFPS)에서 외측 지지띠 단축으로 인한 슬개골 내측 활주 제한이 의심될 때 적용 가능성이 높다. Grade I–II는 전방 무릎 통증 억제 효과를 기대할 수 있다. 슬개골 외측 불안정성(lateral patellar instability)이 있는 환자에서는 외측으로의 자발적 아탈구 위험이 있으므로 내측 글라이드가 아닌 다른 접근을 먼저 고려해야 할 수 있다.',
  'fracture, joint_infection, malignancy, patellar_fracture',
  'patellar_lateral_instability, acute_inflammation, severe_osteoporosis',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-JM-PFJ-INF: 슬개골 하방 글라이드
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_joint_mobilization',
  (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
  'Maitland — PFJ',
  '슬개골 하방 글라이드', 'Inferior Patellar Glide', 'KN-JM-PFJ-INF',
  'knee'::body_region, 'PFJ 상방 지지띠 및 슬개건',
  '바로 눕기, 무릎 완전히 펴기(0도)',
  '환자 발쪽 또는 환측 옆에 위치하여 양 엄지 끝을 슬개골 상단에 접촉 준비',
  '슬개골 상단 (양 엄지)',
  '하방 글라이드 (Grade I–III)',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 무릎을 완전히 편 상태로 이완시킨다. 대퇴사두근이 완전히 이완되어야 슬개골 하방 활주가 용이하다. 필요 시 대퇴 아래에 작은 쿠션을 놓아 근육 이완을 촉진한다."},{"step":2,"instruction":"치료사는 환자 발쪽 또는 옆쪽에 위치하여 양 엄지 끝을 슬개골 상단(상극, superior pole)에 나란히 접촉한다. 접촉은 슬개골 연골면이 아닌 상극 뼈 가장자리에만 이루어지도록 한다."},{"step":3,"instruction":"Grade I–II는 저항 느껴지기 전 범위에서 가벼운 리듬 진동으로 하방 방향 소진폭 가동을 적용한다. Grade III는 상방 지지띠 및 슬개건 저항에 도달하는 대진폭 가동을 적용한다. 슬개건병증 통증이 심한 경우 Grade I–II로 시작한다."},{"step":4,"instruction":"슬개골을 하방 방향으로 리듬감 있게 밀어주며 상방 지지띠와 슬개건 근위부의 이완을 유도한다. 슬개골이 자연스럽게 하방으로 활주하는지, 또는 상방 지지띠에서 조기 저항이 느껴지는지 평가한다."},{"step":5,"instruction":"30초–1분 시술 후 무릎 최대 굽히기 시 슬개건 부위 통증 정도와 슬개골 하방 활주 범위를 재평가한다. 통증 감소 또는 활주 범위 증가가 확인되면 2–3세트 반복한다. 슬개건병증 환자에게는 이후 편심성 수축 운동(eccentric squat)을 함께 처방할 수 있다."}]'::jsonb,
  '{"pain_relief","patellar_mobility","tendon_function"}',
  '{"subacute","chronic"}',
  '{"patellar_tendinopathy","knee_flexion_restriction","superior_retinaculum_tightness"}',
  '{"fracture","joint_infection","malignancy","acute_inflammation","patellar_tendon_rupture"}',
  'level_2b'::evidence_level,
  '슬개건병증에서 슬개골 하방 활주 제한이 의심될 때 보조적으로 적용 가능성이 있다. 슬개건 완전 파열이 있는 경우 절대 금기이므로 시술 전 기능 검사(단순 다리 들어올리기)로 건의 연속성을 확인하는 것이 중요할 수 있다. 완전 굽히기 제한이 있는 경우에도 슬개골 하방 활주 범위를 먼저 회복시킨 후 굽히기 운동을 진행하면 효율이 높아질 가능성이 있다.',
  'fracture, joint_infection, malignancy, patellar_tendon_rupture',
  'acute_inflammation, severe_osteoporosis, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-JM-PFJ-SUP: 슬개골 상방 글라이드
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_joint_mobilization',
  (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
  'Maitland — PFJ',
  '슬개골 상방 글라이드', 'Superior Patellar Glide', 'KN-JM-PFJ-SUP',
  'knee'::body_region, 'PFJ 하방 지지띠 및 슬개건',
  '바로 눕기, 무릎 약간 굽힌 위치(10–20도)',
  '환자 발쪽에 위치하여 양 엄지 끝을 슬개골 하단에 접촉 준비',
  '슬개골 하단 (양 엄지)',
  '상방 글라이드 (Grade I–III)',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 무릎 아래 쿠션을 넣어 10–20도 굽힌 편안한 위치를 만든다. 이 위치에서 슬개인대(patellar ligament) 및 하방 지지띠가 약간 이완되어 접근성이 높아진다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 양 엄지 끝을 슬개골 하단(하극, inferior pole) 가장자리에 접촉한다. 슬개건 삽입부 바로 위 슬개골 뼈 가장자리에만 접촉하며, 슬개건 자체를 직접 누르지 않도록 한다."},{"step":3,"instruction":"Grade I–II는 저항이 느껴지기 전 범위에서 가벼운 리듬 진동으로 상방 방향 소진폭 가동을 적용한다. Grade III는 하방 지지띠와 슬개건 원위 저항에 도달하는 대진폭 가동을 적용한다. 슬개건병증에서는 Grade I–II로 시작하여 통증 반응을 확인한다."},{"step":4,"instruction":"슬개골을 상방 방향으로 리듬감 있게 밀어주며 하방 지지띠 및 슬개건 근처 연부조직의 이완을 유도한다. 슬개골이 자연스럽게 상방으로 활주하는지, 또는 하방 지지띠에서 조기 저항이 느껴지는지 평가한다."},{"step":5,"instruction":"30초–1분 시술 후 무릎 완전 펴기 범위와 슬개골 상방 활주 범위를 재평가한다. 통증 감소 또는 활주 범위 증가가 확인되면 2–3세트 반복한다. 펴기 제한이 있는 경우 상방 글라이드와 함께 터미널 무릎 펴기(terminal knee extension) 운동을 병행하면 기능 회복을 더 기대할 수 있다."}]'::jsonb,
  '{"pain_relief","patellar_mobility","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"knee_extension_restriction","inferior_retinaculum_tightness","patellar_tendinopathy"}',
  '{"fracture","joint_infection","malignancy","acute_inflammation","patellar_tendon_rupture"}',
  'level_2b'::evidence_level,
  '무릎 펴기 제한과 함께 슬개골 상방 활주 제한이 의심될 때 보조적으로 적용 가능성이 있다. 슬개건병증에서 슬개건 근위 삽입부 통증 억제를 목표로 Grade I–II를 먼저 적용하는 것이 안전할 수 있다. 슬개건 완전 파열 시에는 절대 금기이므로 시술 전 건의 연속성 확인이 필요하다.',
  'fracture, joint_infection, malignancy, patellar_tendon_rupture',
  'acute_inflammation, severe_osteoporosis, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- =============================================================
-- SECTION 2: category_mulligan — 3 techniques
-- =============================================================

-- ────────────────────────────────
-- KN-MUL-FLEX: 무릎 굽히기 MWM
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mulligan',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mulligan'),
  'Mulligan MWM — 무릎 관절',
  '무릎 굽히기 MWM', 'Knee Flexion MWM', 'KN-MUL-FLEX',
  'knee'::body_region, 'TFJ 경골 근위부',
  '엎드려 눕기 또는 앉은 자세',
  '환자 환측 옆 또는 뒤쪽에 위치하여 경골 근위부를 후방·외측 또는 후방·내측 방향으로 글라이드 유지',
  '경골 근위부 내측 또는 외측 (양손 또는 웹 스페이스)',
  '경골 글라이드 유지하며 환자 능동 굽히기',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 또는 앉은 자세로 위치시킨다. 엎드려 눕기에서는 무릎 아래 쿠션을 넣어 편안하게 하고, 앉은 자세에서는 발을 바닥에 닿도록 한다. 환자에게 ''무릎을 굽힐 때 통증이나 걸리는 느낌이 나타나는 지점''을 미리 확인하게 한다."},{"step":2,"instruction":"치료사는 환자 환측 옆 또는 뒤쪽에 서서 양손의 웹 스페이스 또는 엄지와 네 손가락으로 경골 근위부를 감싸 파지한다. 최적 글라이드 방향(후방·외측 또는 후방·내측)은 환자에 따라 다를 수 있으므로 먼저 시험 적용하여 통증 없는 방향을 선택한다."},{"step":3,"instruction":"치료사가 경골 근위부에 지속적인 글라이드 힘을 유지하면서 환자에게 천천히 무릎을 굽히도록 지시한다. 시술 중 어떤 통증도 유발되어서는 안 된다(MWM 핵심 원칙). 통증이 생기면 글라이드 방향 또는 강도를 즉시 미세 조정한다."},{"step":4,"instruction":"환자가 무통 범위 내에서 최대 굽히기 위치에 도달하면 1–2초 유지 후 시작 위치로 천천히 돌아온다. 치료사는 복귀 과정에서도 글라이드 힘을 유지한다. 1세트에 6–10회를 기준으로 반복한다."},{"step":5,"instruction":"6–10회 반복 후 보조 없이 능동 굽히기 범위를 재평가한다. 즉각적인 ROM 증가 또는 통증 감소가 확인되면 올바른 글라이드 방향이 적용된 것이다. 2–3세트 반복 후 자가 MWM 방법(벨트 또는 밴드 사용)을 홈 프로그램으로 교육할 수 있다."}]'::jsonb,
  '{"pain_relief","rom_improvement","functional_improvement"}',
  '{"subacute","chronic"}',
  '{"knee_flexion_restriction","knee_flexion_pain","post_surgical_stiffness"}',
  '{"fracture","joint_infection","malignancy","acute_inflammation","instability"}',
  'level_2b'::evidence_level,
  'MWM의 핵심 원칙은 글라이드 적용 중 통증이 없어야 한다는 것이다. 글라이드 방향은 후방·외측이 일반적이지만 개인마다 최적 방향이 다를 수 있으므로 시험 적용 후 미세 조정이 필요할 수 있다. 무릎 치환술 후 조기 굽히기 회복 단계에서 즉각적 ROM 개선을 기대할 수 있다.',
  'fracture, joint_infection, malignancy, DVT',
  'instability, acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-MUL-EXT: 무릎 펴기 MWM
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mulligan',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mulligan'),
  'Mulligan MWM — 무릎 관절',
  '무릎 펴기 MWM', 'Knee Extension MWM', 'KN-MUL-EXT',
  'knee'::body_region, 'TFJ 경골 근위부',
  '앉은 자세 또는 바로 눕기',
  '환자 앞쪽 또는 옆쪽에 위치하여 경골 근위부 전방 글라이드 유지',
  '경골 근위부 후방면 또는 전방면 (양손 또는 웹 스페이스)',
  '전방 글라이드 유지하며 환자 능동 펴기',
  '[{"step":1,"instruction":"환자를 앉은 자세(발 바닥에 닿은 상태) 또는 바로 눕기 자세로 위치시킨다. 앉은 자세가 더 기능적이므로 가능하면 앉은 자세를 선호한다. 환자에게 ''무릎을 펼 때 통증이나 걸리는 느낌이 나타나는 지점''을 미리 확인하게 한다."},{"step":2,"instruction":"치료사는 환자 앞쪽 또는 옆쪽에 위치하여 양손의 웹 스페이스 또는 엄지와 네 손가락으로 경골 근위부를 감싸 파지한다. 최적 글라이드 방향(전방·외측 또는 전방·내측)은 환자마다 다를 수 있으므로 먼저 시험 적용하여 무통 방향을 선택한다."},{"step":3,"instruction":"치료사가 경골 근위부에 전방 글라이드 힘을 지속적으로 유지하면서 환자에게 천천히 무릎을 펴도록 지시한다. 시술 중 어떤 통증도 유발되어서는 안 된다(MWM 핵심 원칙). 통증이 생기면 글라이드 방향 또는 강도를 즉시 미세 조정한다."},{"step":4,"instruction":"환자가 무통 범위 내에서 최대 펴기 위치에 도달하면 1–2초 유지 후 시작 위치로 천천히 돌아온다. 치료사는 복귀 과정에서도 글라이드 힘을 유지한다. 1세트에 6–10회를 기준으로 반복한다."},{"step":5,"instruction":"6–10회 반복 후 보조 없이 능동 펴기 범위와 무릎 완전 펴기 결손(extension lag)을 재평가한다. 즉각적인 ROM 증가 또는 통증 감소가 확인되면 올바른 글라이드 방향이 적용된 것이다. 이후 세션에서 자가 MWM(벨트 이용) 및 터미널 무릎 펴기 운동을 홈 프로그램으로 교육한다."}]'::jsonb,
  '{"pain_relief","rom_improvement","functional_improvement"}',
  '{"subacute","chronic"}',
  '{"knee_extension_restriction","knee_extension_pain","PCL_rehabilitation","extension_lag"}',
  '{"fracture","joint_infection","malignancy","acute_inflammation","instability"}',
  'level_2b'::evidence_level,
  'MWM 핵심 원칙은 글라이드 적용 중 통증이 없어야 한다는 것이다. PCL 손상 후 재활에서 무릎 펴기 기능 회복을 목표로 적용할 경우 Grade를 낮게 시작하여 조직 보호를 먼저 고려하는 것이 안전할 수 있다. 즉각적 ROM 변화가 없다면 글라이드 방향과 강도를 재평가해야 한다.',
  'fracture, joint_infection, malignancy, DVT',
  'instability, acute_PCL_tear, acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-MUL-Pat: 슬개건병증 MWM
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mulligan',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mulligan'),
  'Mulligan MWM — PFJ',
  '슬개건병증 MWM', 'Patellar Tendinopathy MWM', 'KN-MUL-Pat',
  'knee'::body_region, 'PFJ 슬개골',
  '서 있는 자세 또는 앉은 자세',
  '환자 앞쪽에 위치하여 슬개골에 테이핑 또는 손으로 하방·내측 글라이드 유지',
  '슬개골 상단 (하방 글라이드 유지 — 테이프 또는 손 엄지)',
  '슬개골 하방 글라이드 유지하며 환자 능동 하프스쿼트 또는 계단 내려오기 동작',
  '[{"step":1,"instruction":"환자를 서 있는 자세(한 발로 서기 또는 양발 서기)로 위치시킨다. 앉은 자세도 가능하나 기능적 동작에서 통증 감소를 목표로 하므로 가능하면 서 있는 자세를 선호한다. 환자에게 하프스쿼트 또는 계단 내려오기 시 통증 NRS를 먼저 확인한다."},{"step":2,"instruction":"치료사는 환자 앞쪽에 위치하여 한 손의 엄지 끝 또는 두 손 엄지 중첩으로 슬개골 상단(상극)에 접촉하고 하방·내측 방향으로 지속적인 글라이드 힘을 유지한다. 대안으로 McConnell 테이핑 기법을 적용하여 슬개골을 하방·내측으로 테이핑하고 시술할 수 있다."},{"step":3,"instruction":"슬개골 하방·내측 글라이드를 유지한 상태에서 환자에게 천천히 하프스쿼트(30–40도) 또는 계단 내려오기 동작을 수행하도록 지시한다. 시술 중 슬개건 부위 통증이 줄거나 사라지는지 즉시 확인한다. 통증이 줄지 않으면 글라이드 방향을 조정한다."},{"step":4,"instruction":"무통 범위 내에서 동작을 완료한 후 시작 위치로 천천히 돌아온다. 치료사는 복귀 과정에서도 글라이드 힘을 유지한다. 1세트에 6–10회 반복하며 매 반복마다 슬개건 부위 통증 반응을 모니터링한다."},{"step":5,"instruction":"6–10회 반복 후 글라이드 없이 동일 동작을 재평가하여 통증 NRS 변화를 확인한다. 즉각적인 통증 감소가 확인되면 테이핑 방법 및 자가 슬개골 하방 글라이드 유지 방법을 환자에게 교육하여 홈 프로그램으로 적용할 수 있다."}]'::jsonb,
  '{"pain_relief","functional_improvement","tendon_function"}',
  '{"subacute","chronic"}',
  '{"patellar_tendinopathy","anterior_knee_pain","jumping_sports_pain","stair_descent_pain"}',
  '{"fracture","joint_infection","malignancy","acute_inflammation","patellar_tendon_rupture"}',
  'level_2b'::evidence_level,
  '슬개건병증에서 슬개골 하방 글라이드를 유지한 상태로 기능적 동작을 수행할 때 통증 감소를 기대할 수 있다. 스포츠 복귀 전 기능 회복 단계에서 효과적일 수 있다. 슬개건 완전 파열이 있는 경우 절대 금기이므로 시술 전 건의 연속성 확인이 필요하다. McConnell 테이핑으로 대체할 경우 피부 알레르기 반응 여부를 먼저 확인해야 할 수 있다.',
  'fracture, joint_infection, malignancy, patellar_tendon_rupture',
  'acute_inflammation, severe_osteoporosis, skin_allergy_to_tape',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();
-- Migration 020 (Part 2): Knee — MFR + ART + CTM (10 techniques)
-- 무릎 연부조직: MFR 4 + ART 4 + CTM 2
-- sw-db-architect | 2026-04-28

-- =============================================================
-- SECTION 3: category_mfr — 4 techniques (evidence_level = level_4)
-- =============================================================

-- ────────────────────────────────
-- KN-MFR-Quad: 대퇴사두근 근막이완
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mfr',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mfr'),
  'MFR — 대퇴 전방',
  '대퇴사두근 근막이완', 'Quadriceps MFR', 'KN-MFR-Quad',
  'knee'::body_region, '대퇴직근·내측광근·외측광근·중간광근 복합체(전방 대퇴)',
  '엎드려 눕기 또는 바로 눕기',
  '환자 환측 옆, 전방 대퇴 전반 접촉',
  '대퇴 전방 (손바닥 전체 또는 전완)',
  '근위부에서 원위부 방향으로 지속 압박·이완',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 또는 바로 눕기 자세로 위치시키고, 시술 측 하지가 편안하게 이완되도록 한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 손바닥 전체 또는 전완을 대퇴 전방 근위부에 부드럽게 접촉한 후, 조직이 저항하는 지점까지 서서히 하중을 싣는다."},{"step":3,"instruction":"조직의 저항이 느껴지는 지점에서 멈추고, 근막 이완(release) 반응이 일어날 때까지 90초~2분간 지속 압박을 유지한다."},{"step":4,"instruction":"이완 반응이 느껴지면 압박 방향을 근위부에서 원위부 방향으로 천천히 이동하며 대퇴 전방 전체를 체계적으로 다룬다."},{"step":5,"instruction":"시술 후 무릎 굽히기 범위와 전방 대퇴 조직의 유연성 변화를 재평가하고, 필요 시 1~2회 반복한다."}]'::jsonb,
  '{"tissue_release","rom_improvement","pain_relief"}',
  '{"subacute","chronic"}',
  '{"knee_pain","quadriceps_tightness","flexion_restriction"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '슬개건병증, 무릎 굽히기 제한, 슬개대퇴 증후군에서 대퇴사두근 근막 긴장이 기여 요인이 될 수 있음. 시술 전 조직 상태를 촉진으로 평가하여 과도한 압박이 가해지지 않도록 주의할 수 있다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy, DVT',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-MFR-Ham: 슬굴곡근 근막이완
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mfr',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mfr'),
  'MFR — 대퇴 후방',
  '슬굴곡근 근막이완', 'Hamstring MFR', 'KN-MFR-Ham',
  'knee'::body_region, '반건양근·반막양근·대퇴이두근 복합체(후방 대퇴)',
  '엎드려 눕기 또는 바로 눕기',
  '환자 환측 옆, 후방 대퇴 접촉',
  '후방 대퇴 (손바닥 전체 또는 전완)',
  '근위부에서 원위부 방향으로 지속 압박·이완',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 또는 바로 눕기 자세로 위치시키고, 시술 측 하지가 편안하게 이완되도록 한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 손바닥 전체 또는 전완을 후방 대퇴 근위부(좌골결절 아래)에 부드럽게 접촉하고, 조직 저항이 느껴지는 깊이까지 서서히 압박한다."},{"step":3,"instruction":"저항이 느껴지는 지점에서 멈추고, 조직의 이완 반응이 나타날 때까지 90초~2분간 지속 압박을 유지한다."},{"step":4,"instruction":"이완 반응이 느껴지면 근위부에서 원위부 방향으로 천천히 이동하며 슬굴곡근 전체 주행 방향을 따라 시술한다."},{"step":5,"instruction":"시술 후 무릎 펴기 범위 및 후방 대퇴 조직의 유연성 변화를 재평가하고, 필요 시 1~2회 반복한다."}]'::jsonb,
  '{"tissue_release","rom_improvement","pain_relief"}',
  '{"subacute","chronic"}',
  '{"posterior_knee_pain","extension_restriction","hamstring_tightness"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '무릎 펴기 제한, 후방 무릎 통증에서 슬굴곡근 긴장이 기여 요인이 될 수 있음. 슬굴곡근 긴장은 무릎 전방 전단력 증가에도 기여할 수 있어, 전방십자인대 부하가 우려되는 경우 이완 기법 도입이 도움이 될 수 있다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy, DVT',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-MFR-ITB: 장경인대 근막이완
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mfr',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mfr'),
  'MFR — 외측 대퇴',
  '장경인대 근막이완', 'Iliotibial Band MFR', 'KN-MFR-ITB',
  'knee'::body_region, '장경인대(TFL ~ 경골 외측 Gerdy 결절)',
  '옆으로 눕기(환측 위) 또는 앉은 자세',
  '환자 뒤쪽 또는 옆쪽, 대퇴 외측 전반 접촉',
  '장경인대 (전완 또는 손바닥)',
  '근위부에서 원위부 방향으로 지속 압박·이완',
  '[{"step":1,"instruction":"환자를 환측이 위로 향하는 옆으로 눕기 또는 앉은 자세로 위치시키고, 시술 측 하지가 편안하게 이완되도록 한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽 또는 옆쪽에 서서 전완 또는 손바닥을 대퇴 외측 근위부(대전자 바로 아래)에 접촉하고, 조직 저항이 느껴지는 깊이까지 서서히 압박한다."},{"step":3,"instruction":"저항이 느껴지는 지점에서 멈추고, 조직의 이완 반응이 나타날 때까지 90초~2분간 지속 압박을 유지한다."},{"step":4,"instruction":"이완 반응이 느껴지면 대퇴 외측 근위부에서 원위부(외측 대퇴과 방향)로 천천히 이동하며 장경인대 전체 주행을 따라 시술한다."},{"step":5,"instruction":"시술 후 외측 무릎 통증 변화 및 대퇴 외측 조직의 유연성 변화를 재평가하고, 필요 시 1~2회 반복한다."}]'::jsonb,
  '{"tissue_release","pain_relief"}',
  '{"subacute","chronic"}',
  '{"lateral_knee_pain","itb_syndrome","runners_knee"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '장경인대 증후군(러너스 니), 외측 무릎 통증에서 장경인대 근막 긴장이 기여 요인이 될 수 있음. 대퇴 외측 긴장은 슬개골 외측 편위에도 기여할 수 있어, 슬개대퇴 통증 증후군 환자에서도 보조적 적용을 고려할 수 있다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-MFR-GastSol: 비복근·가자미근 근막이완
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_mfr',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mfr'),
  'MFR — 하퇴 후방',
  '비복근·가자미근 근막이완', 'Gastrocnemius-Soleus Complex MFR', 'KN-MFR-GastSol',
  'knee'::body_region, '비복근·가자미근 복합체(후방 하퇴 ~ 아킬레스건)',
  '엎드려 눕기 또는 바로 눕기',
  '환자 발쪽, 후방 하퇴 접촉',
  '후방 하퇴 비복근·가자미근 복합체 (손바닥 전체 또는 전완)',
  '근위부에서 원위부 방향으로 지속 압박·이완',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 또는 바로 눕기 자세로 위치시키고, 시술 측 발목이 테이블 끝에서 자유롭게 이완되도록 베개나 타올을 발목 아래에 받쳐준다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 손바닥 전체 또는 전완을 후방 하퇴 근위부(비복근 근복 상단)에 접촉하고, 조직 저항이 느껴지는 깊이까지 서서히 압박한다."},{"step":3,"instruction":"저항이 느껴지는 지점에서 멈추고, 조직의 이완 반응이 나타날 때까지 90초~2분간 지속 압박을 유지한다."},{"step":4,"instruction":"이완 반응이 느껴지면 근위부에서 원위부(아킬레스건 방향)로 천천히 이동하며 비복근·가자미근 복합체 전체를 체계적으로 다룬다."},{"step":5,"instruction":"시술 후 무릎 펴기 범위 및 후방 하퇴 조직의 유연성 변화를 재평가하고, 필요 시 1~2회 반복한다."}]'::jsonb,
  '{"tissue_release","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"posterior_knee_pain","calf_tightness","extension_restriction"}',
  '{"fracture","malignancy","active_infection","DVT"}',
  'level_4'::evidence_level,
  '비복근·가자미근 긴장은 무릎 완전 펴기 제한 및 보행 중 무릎 과신전 보상 패턴에 기여할 수 있음. 특히 슬와 통증과 무릎 펴기 제한이 동반된 경우 비복근 기시부 주변 이완이 증상 완화에 도움이 될 수 있다. 시술 전 심부정맥혈전증(DVT) 위험 인자 확인이 중요할 수 있다.',
  'fracture, malignancy, active_infection, DVT',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- =============================================================
-- SECTION 4: category_art — 4 techniques (evidence_level = level_4)
-- =============================================================

-- ────────────────────────────────
-- ART-QuadKnee: 대퇴사두근 능동적 이완기법
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART — 대퇴 전방',
  '대퇴사두근 능동적 이완기법', 'Quadriceps Active Release Technique', 'ART-QuadKnee',
  'knee'::body_region, '대퇴직근·외측광근 근복(전방 대퇴 중간 구역)',
  '엎드려 눕기',
  '환자 환측 옆, 대퇴 전방 목표 압통점에 접촉 압박 유지',
  '대퇴직근 또는 외측광근 근복 (엄지 또는 손가락 끝)',
  '접촉 유지하며 무릎을 펴기에서 굽히기 방향으로 능동 이동',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 무릎을 약간 굽혀 대퇴직근 또는 외측광근 근복에 접근이 용이한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 엄지 또는 손가락 끝으로 대퇴 전방의 목표 압통점(유착이 의심되는 지점)에 접촉하고, 조직이 저항하는 깊이까지 압박을 유지한다."},{"step":3,"instruction":"압박을 유지한 상태에서 환자에게 무릎을 천천히 굽혀 발꿈치가 엉덩이 방향으로 이동하도록 능동 운동을 지시한다."},{"step":4,"instruction":"무릎 굽히기가 최대 범위까지 진행되는 동안 치료사는 접촉점의 압박을 일정하게 유지한다. 시술 중 환자가 느끼는 통증이 4/10 이하로 유지되도록 압박 강도를 조절한다."},{"step":5,"instruction":"무릎을 다시 펴기 자세로 돌아온 후 재평가하여 조직 긴장 변화를 확인한다. 1세트당 4~6회 반복하며, 필요 시 2~3세트 시행한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"knee_pain","quadriceps_tightness","patellar_tendinopathy"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '대퇴사두근 과사용으로 인한 근막 유착은 슬개건 부하 증가 및 무릎 굽히기 제한의 원인이 될 수 있음. 능동 운동을 통한 조직 이동이 수동적 이완보다 유착 분리에 더 효과적일 수 있다는 임상적 관찰이 있으나, 고수준 근거는 아직 제한적이다.',
  'fracture, malignancy, active_infection',
  'complete_quadriceps_tear, acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- ART-HamKnee: 슬굴곡근 능동적 이완기법
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART — 대퇴 후방',
  '슬굴곡근 능동적 이완기법', 'Hamstring Active Release Technique', 'ART-HamKnee',
  'knee'::body_region, '반건양근·대퇴이두근 근복(후방 대퇴 중간 구역)',
  '엎드려 눕기',
  '환자 환측 옆, 후방 대퇴 목표 압통점에 접촉 압박 유지',
  '슬굴곡근 근복 (엄지 또는 검지·중지)',
  '접촉 유지하며 무릎을 굽히기에서 펴기 방향으로 능동 이동',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 무릎을 약 60~90도 굽힌 상태에서 시작한다. 시술 측 발목을 치료사가 가볍게 지지할 수 있다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 엄지 또는 검지·중지로 후방 대퇴의 목표 압통점(반건양근 또는 대퇴이두근 근복)에 접촉하고, 조직이 저항하는 깊이까지 압박을 유지한다."},{"step":3,"instruction":"압박을 유지한 상태에서 환자에게 무릎을 천천히 펴서 다리를 내리도록 능동 운동을 지시한다."},{"step":4,"instruction":"무릎 펴기가 최대 범위까지 진행되는 동안 치료사는 접촉점의 압박을 일정하게 유지한다. 시술 중 환자가 느끼는 통증이 4/10 이하로 유지되도록 압박 강도를 조절한다."},{"step":5,"instruction":"다시 무릎을 굽혀 시작 자세로 돌아온 후 재평가하여 조직 긴장 변화를 확인한다. 1세트당 4~6회 반복하며, 필요 시 2~3세트 시행한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"posterior_knee_pain","hamstring_tightness","extension_restriction"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '슬굴곡근 ART는 후방 대퇴 근막 유착 해소와 무릎 펴기 제한 개선에 도움이 될 수 있음. 능동 운동 요소가 수동적 이완에 비해 조직 이동을 강화하여 유착 분리 효과를 높일 수 있다는 임상적 가설이 있으나, 고수준 근거는 아직 제한적이다.',
  'fracture, malignancy, active_infection',
  'hamstring_complete_tear, acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- ART-ITB: 장경인대 능동적 이완기법
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART — 외측 대퇴',
  '장경인대 능동적 이완기법', 'Iliotibial Band Active Release Technique', 'ART-ITB',
  'knee'::body_region, '장경인대(중간 대퇴 외측 ~ 슬관절 외측)',
  '옆으로 눕기(환측 위)',
  '환자 뒤쪽, 장경인대 외측 대퇴과 근처 압통점 접촉 유지',
  '장경인대 마찰 포인트 (엄지 또는 검지·중지)',
  '접촉 유지하며 무릎을 굽히기에서 펴기 방향으로 능동 이동',
  '[{"step":1,"instruction":"환자를 환측이 위로 향하는 옆으로 눕기 자세로 위치시키고, 무릎을 약 60~90도 굽힌 상태에서 시작한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 위치하여 엄지 또는 검지·중지로 장경인대의 마찰 포인트(외측 대퇴과 근처 압통점)에 접촉하고, 조직이 저항하는 깊이까지 압박을 유지한다."},{"step":3,"instruction":"압박을 유지한 상태에서 환자에게 무릎을 천천히 펴도록 능동 운동을 지시한다. 무릎 펴기 과정에서 장경인대가 압박 포인트 아래로 미끄러지도록 유도한다."},{"step":4,"instruction":"무릎 펴기가 최대 범위까지 진행되는 동안 치료사는 접촉점의 압박을 일정하게 유지한다. 시술 중 환자가 느끼는 통증이 4/10 이하로 유지되도록 압박 강도를 조절한다."},{"step":5,"instruction":"다시 무릎을 굽혀 시작 자세로 돌아온 후 재평가한다. 1세트당 4~6회 반복하며, 필요 시 2~3세트 시행한다."}]'::jsonb,
  '{"tissue_release","pain_relief"}',
  '{"subacute","chronic"}',
  '{"lateral_knee_pain","itb_syndrome","running_pain"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '장경인대 ART는 마찰 포인트(외측 대퇴과 근처)의 유착 해소에 효과적일 수 있다. 특히 외측 대퇴과 주변의 국소 압통이 명확히 확인되는 경우 적용을 고려할 수 있다. 그러나 장경인대 자체의 구조적 이완 가능성에 대해서는 임상적 논란이 있으므로 과도한 기대는 피하는 것이 좋다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- ART-Poplit: 슬와근 능동적 이완기법
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_art',
  (SELECT id FROM technique_categories WHERE category_key = 'category_art'),
  'ART — 슬관절 후방',
  '슬와근 능동적 이완기법', 'Popliteus Active Release Technique', 'ART-Poplit',
  'knee'::body_region, '슬와근(대퇴 외측과 ~ 경골 후방면)',
  '엎드려 눕기, 무릎 약간 굽힌 위치',
  '환자 환측 옆, 후방 슬와부(오금) 슬와근 접촉',
  '슬와부(오금) 내 슬와근 (손가락 끝)',
  '접촉 유지하며 무릎을 굽히기에서 펴기 방향으로 능동 이동',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 무릎을 약 20~30도 굽힌 이완 위치에서 시작한다. 발목 아래에 타올을 받쳐 편안한 자세를 유지한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 손가락 끝으로 슬와부(오금) 내 슬와근 위치(내측 슬와부 깊은 층)에 접촉하고, 조직이 저항하는 깊이까지 부드럽게 압박을 유지한다."},{"step":3,"instruction":"압박을 유지한 상태에서 환자에게 무릎을 천천히 펴도록 능동 운동을 지시한다. 슬와부는 혈관·신경이 밀집해 있으므로 압박 강도를 세심하게 조절한다."},{"step":4,"instruction":"무릎 펴기가 최대 범위까지 진행되는 동안 치료사는 접촉점의 압박을 일정하게 유지한다. 환자가 이상 감각(저림·찌릿함)을 보고하면 즉시 압박을 줄인다."},{"step":5,"instruction":"다시 무릎을 굽혀 시작 자세로 돌아온 후 재평가한다. 1세트당 3~5회 반복하며, 필요 시 2~3세트 시행한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"posterior_knee_pain","extension_restriction","locking_sensation"}',
  '{"fracture","malignancy","active_infection","popliteal_artery_aneurysm"}',
  'level_4'::evidence_level,
  '슬와근 긴장은 후방 무릎 통증 및 무릎 완전 펴기 마지막 범위 제한의 원인이 될 수 있음. 슬와부에는 혈관·신경이 밀집해 있어 압박 강도 조절과 환자 반응 모니터링이 특히 중요할 수 있다. 슬와 낭종(베이커 낭종)이 있는 경우 과도한 압박은 피하는 것이 좋다.',
  'fracture, malignancy, active_infection, popliteal_artery_aneurysm',
  'popliteal_cyst_large, acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- =============================================================
-- SECTION 5: category_ctm — 2 techniques (evidence_level = level_4)
-- =============================================================

-- ────────────────────────────────
-- CTM-KneeAnterior: 무릎 전방 결합조직 마사지
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_ctm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ctm'),
  'CTM — 무릎 전방',
  '무릎 전방 결합조직 마사지', 'Anterior Knee Connective Tissue Massage', 'CTM-KneeAnterior',
  'knee'::body_region, '슬개골 주변·슬개건·지방패드 피하결합조직',
  '바로 눕기, 무릎 약간 굽힌 위치(베개 지지)',
  '환자 환측 옆, 무릎 전방 피하결합조직 접촉',
  '슬개골 주변·슬개건 피하결합조직 (손가락 끝 긁기 기법)',
  '피부 접힘이 형성되는 방향으로 短파 긁기 스트로크',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고, 무릎 아래에 베개를 받쳐 무릎이 약간 굽혀진 편안한 이완 위치를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 위치하여 검지·중지·약지 손가락 끝을 슬개골 내측 또는 외측 경계 근처의 피하결합조직에 가볍게 접촉한다."},{"step":3,"instruction":"손가락을 피부에 밀착시킨 채 짧고 리듬감 있는 긁기 스트로크(CTM 특유의 short stroke)를 슬개골 주변 및 슬개건 방향으로 반복 적용한다. 피부가 움직이되 미끄러지지 않도록 압박 깊이를 유지한다."},{"step":4,"instruction":"슬개골 상방, 내측, 외측, 슬개건 근위부 순서로 체계적으로 시술하며, 각 구역에서 1~2분씩 시행한다. 자율신경 반응(피부 홍조, 소름)은 정상 반응일 수 있다."},{"step":5,"instruction":"시술 후 전방 무릎 통증 변화 및 조직 유연성(슬개골 이동성)을 재평가하고, 필요 시 2~3회 반복한다."}]'::jsonb,
  '{"tissue_release","pain_relief","circulation_improvement"}',
  '{"subacute","chronic"}',
  '{"anterior_knee_pain","patellar_tendinopathy","knee_stiffness"}',
  '{"fracture","malignancy","skin_infection_in_area"}',
  'level_4'::evidence_level,
  '무릎 전방 결합조직 마사지는 슬개건병증 및 지방패드 자극으로 인한 전방 통증의 국소 순환 개선에 도움이 될 수 있음. CTM의 반사적 자율신경 효과를 통한 통증 조절 가능성도 제안되고 있으나, 무릎에 특화된 고수준 근거는 아직 제한적이다.',
  'fracture, malignancy, skin_infection_in_area',
  'acute_inflammation, anticoagulant_therapy, open_wound',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- CTM-KneePosterior: 무릎 후방 결합조직 마사지
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_ctm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ctm'),
  'CTM — 무릎 후방',
  '무릎 후방 결합조직 마사지', 'Posterior Knee Connective Tissue Massage', 'CTM-KneePosterior',
  'knee'::body_region, '슬와부(오금) 피하결합조직 및 슬와 인대',
  '엎드려 눕기, 무릎 이완 위치',
  '환자 환측 옆, 슬와부(오금) 피하결합조직 접촉',
  '슬와부 피하결합조직 (손가락 끝 긁기 기법)',
  '피부 접힘이 형성되는 방향으로 短파 긁기 스트로크',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고, 발목 아래에 타올을 받쳐 무릎이 자연스럽게 이완된 위치를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 위치하여 검지·중지·약지 손가락 끝을 슬와부(오금) 내측 또는 외측 경계의 피하결합조직에 가볍게 접촉한다."},{"step":3,"instruction":"손가락을 피부에 밀착시킨 채 짧고 리듬감 있는 긁기 스트로크(CTM 특유의 short stroke)를 슬와부 전반에 걸쳐 반복 적용한다. 슬와부 중앙의 혈관·신경 구조를 피하여 내측 및 외측 경계 위주로 시술한다."},{"step":4,"instruction":"슬와부 내측, 외측, 슬관절 후방 관절선 방향으로 체계적으로 시술하며, 각 구역에서 1~2분씩 시행한다. 자율신경 반응(피부 홍조, 소름)은 정상 반응일 수 있다."},{"step":5,"instruction":"시술 후 후방 무릎 통증 변화 및 무릎 굽히기 범위를 재평가하고, 필요 시 2~3회 반복한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"posterior_knee_pain","flexion_restriction","knee_stiffness"}',
  '{"fracture","malignancy","skin_infection_in_area","popliteal_cyst_ruptured"}',
  'level_4'::evidence_level,
  '무릎 후방 결합조직 마사지는 후방 무릎 긴장감 완화와 굽히기 범위 개선에 도움이 될 수 있음. 슬와부 중앙에는 혈관·신경이 밀집해 있으므로, 시술 시 내측·외측 경계 위주로 적용하고 중앙 깊은 압박은 피하는 것이 안전할 수 있다. 슬와 낭종(베이커 낭종)이 있는 경우 시술 전 상태 확인이 중요할 수 있다.',
  'fracture, malignancy, skin_infection_in_area, popliteal_cyst_ruptured',
  'acute_inflammation, popliteal_cyst, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();
-- Migration 020 (Part 3): Knee — DFM + TrP (9 techniques)
-- 슬관절 심부마찰 마사지 4개 + 트리거포인트 이완 5개
-- sw-db-architect | 2026-04-28

-- =============================================================
-- SECTION 6: category_deep_friction — 4 techniques (level_3)
-- =============================================================

-- ────────────────────────────────
-- DFM-PatTend: 슬개건 심부마찰 마사지
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'DFM — 슬개건',
  '슬개건 심부마찰 마사지', 'Patellar Tendon Deep Friction Massage', 'DFM-PatTend',
  'knee'::body_region, '슬개건(슬개골 하극 ~ 경골 조면)',
  '바로 눕기, 무릎 약간 굽힌 위치(롤 받침)',
  '환자 환측 옆, 검지·중지로 슬개건 접촉',
  '슬개건 중간부 또는 슬개골 하극 부착부 (검지·중지 중첩)',
  '건 주행 방향에 수직으로 횡마찰',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 무릎 아래에 롤 타월이나 쿠션을 받쳐 무릎을 약간 굽힌 편안한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 검지와 중지를 중첩하여 슬개건 중간부 또는 슬개골 하극 부착부의 압통 최대점을 촉진한다."},{"step":3,"instruction":"건 주행 방향에 수직으로 횡마찰을 가하기 전, 손가락 끝이 건 조직에 충분히 밀착되도록 피부를 약간 이동시켜 접촉 위치를 잡는다."},{"step":4,"instruction":"건 섬유 방향에 수직으로 횡마찰을 리듬감 있게 시행한다. 압력은 조직 저항이 느껴지는 수준으로 유지하며 매 왕복 시 동일한 범위와 속도를 유지한다."},{"step":5,"instruction":"1회당 3–5분 시행 후 재평가하여 압통 변화와 기능 개선 여부를 확인한다. 시술 직후 경미한 불편감은 정상 반응일 수 있으며 통상 24시간 내 소실 가능하다."}]'::jsonb,
  '{"pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"patellar_tendinopathy","anterior_knee_pain"}',
  '{"fracture","malignancy","acute_inflammation","open_wound"}',
  'level_3'::evidence_level,
  '슬개건 Cyriax 마찰 마사지는 건 조직 교원질 재배열과 통증 감소에 도움이 될 수 있다. 슬개건병증 보존적 치료 프로토콜에 포함될 수 있으나 단독 근거는 제한적이다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- DFM-MCL: 내측측부인대 심부마찰 마사지
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'DFM — 내측 인대',
  '내측측부인대 심부마찰 마사지', 'Medial Collateral Ligament Deep Friction Massage', 'DFM-MCL',
  'knee'::body_region, 'MCL(대퇴 내측과 ~ 경골 내측면)',
  '바로 눕기, 무릎 약간 굽힌 위치',
  '환자 환측 옆, 엄지 또는 검지로 MCL 접촉',
  'MCL 압통 최대점 (엄지 또는 검지·중지 중첩)',
  '인대 주행 방향에 수직으로 횡마찰',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 무릎 아래에 롤 타월을 받쳐 무릎을 약간 굽혀 MCL 접근이 용이한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 엄지 또는 검지·중지로 대퇴 내측과에서 경골 내측면까지 MCL 주행 경로를 촉진하여 압통 최대점을 확인한다."},{"step":3,"instruction":"손가락 끝이 인대 조직에 충분히 밀착되도록 피부를 가볍게 이동시켜 접촉 위치를 잡는다. 인대 특정 부착부(대퇴 또는 경골 부착부) 병변이 의심되면 해당 부위에 집중한다."},{"step":4,"instruction":"인대 섬유 방향에 수직으로 횡마찰을 리듬감 있게 시행한다. 압력은 저항이 느껴지는 수준으로 유지하며 동일한 범위와 속도로 반복한다."},{"step":5,"instruction":"3–5분 시행 후 무릎 내측 압통 및 내반 스트레스 검사 반응 변화를 재평가한다. 급성 파열 시 절대 적용하지 않으며 만성 단계(6주 이후) 이후에 적용 가능하다."}]'::jsonb,
  '{"pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"medial_knee_pain","mcl_sprain"}',
  '{"fracture","malignancy","acute_inflammation","mcl_complete_rupture"}',
  'level_3'::evidence_level,
  'MCL 부분 손상 후 만성 단계에서 인대 유착 감소와 조직 리모델링에 도움이 될 수 있다. 급성 파열은 절대 금기이며 손상 후 6주 이상 경과한 아급성~만성 단계에서 고려 가능하다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- DFM-LCL: 외측측부인대 심부마찰 마사지
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'DFM — 외측 인대',
  '외측측부인대 심부마찰 마사지', 'Lateral Collateral Ligament Deep Friction Massage', 'DFM-LCL',
  'knee'::body_region, 'LCL(대퇴 외측과 ~ 비골두)',
  '바로 눕기 또는 옆으로 눕기(건측 위), 무릎 약간 굽힌 위치',
  '환자 환측 옆, 엄지로 LCL 접촉',
  'LCL 압통 최대점 (엄지 끝)',
  '인대 주행 방향에 수직으로 횡마찰',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 건측이 위로 향하는 옆으로 눕기 자세로 위치시키고 무릎을 약간 굽혀 LCL 접근이 용이한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 엄지 끝으로 대퇴 외측과에서 비골두까지 LCL 주행 경로를 촉진하여 압통 최대점을 확인한다."},{"step":3,"instruction":"엄지 끝이 인대 조직에 충분히 밀착되도록 피부를 가볍게 이동시켜 접촉 위치를 잡는다. 장경인대와의 해부학적 관계를 고려하여 LCL 위치를 정확히 확인 후 시행한다."},{"step":4,"instruction":"인대 섬유 방향에 수직으로 횡마찰을 리듬감 있게 시행한다. 엄지에 가해지는 압력을 일정하게 유지하면서 동일한 범위와 속도로 반복한다."},{"step":5,"instruction":"3–5분 시행 후 무릎 외측 압통 및 외반 스트레스 검사 반응 변화를 재평가한다. 장경인대 증후군과 감별 진단 후 적용하는 것이 권장된다."}]'::jsonb,
  '{"pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"lateral_knee_pain","lcl_sprain"}',
  '{"fracture","malignancy","acute_inflammation","lcl_complete_rupture"}',
  'level_3'::evidence_level,
  'LCL 부분 손상 후 만성 단계에서 인대 유착 감소에 도움이 될 수 있다. 장경인대 증후군과 감별 진단 후 적용 필요하며 두 질환이 동반될 가능성도 있다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- DFM-PoplitTend: 슬와근건 심부마찰 마사지
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'DFM — 슬관절 후방',
  '슬와근건 심부마찰 마사지', 'Popliteus Tendon Deep Friction Massage', 'DFM-PoplitTend',
  'knee'::body_region, '슬와근건(대퇴 외측과 후방 ~ 슬와부)',
  '엎드려 눕기, 무릎 약간 굽힌 위치',
  '환자 환측 옆, 슬와부(오금) 외측에서 슬와근건 접촉',
  '슬와근건 (엄지 또는 검지·중지)',
  '건 주행 방향에 수직으로 횡마찰',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 무릎 아래에 작은 롤 타월을 받쳐 무릎을 약간 굽혀 슬와부 접근이 용이한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 슬와부(오금) 외측에서 대퇴 외측과 후방까지 슬와근건 주행 경로를 촉진하여 압통 최대점을 확인한다."},{"step":3,"instruction":"엄지 또는 검지·중지 끝이 건 조직에 충분히 밀착되도록 피부를 가볍게 이동시켜 접촉 위치를 잡는다. 슬와부 혈관·신경 구조물과의 인접성을 인식하며 접촉 위치를 정확히 잡는다."},{"step":4,"instruction":"건 섬유 방향에 수직으로 횡마찰을 리듬감 있게 시행한다. 슬와부 혈관·신경에 과도한 압력이 가해지지 않도록 주의하면서 적절한 압력으로 반복한다."},{"step":5,"instruction":"3–5분 시행 후 무릎 후방 외측 통증과 무릎 가동범위 변화를 재평가한다. 무릎 잠김(locking) 증상이 있는 경우 반월판 병변과의 감별 진단이 선행되어야 한다."}]'::jsonb,
  '{"pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"posterior_knee_pain","posterolateral_knee_pain"}',
  '{"fracture","malignancy","acute_inflammation","dvt"}',
  'level_3'::evidence_level,
  '슬와근건 마찰은 후방 외측 무릎 통증 및 무릎 잠김 증상의 원인이 될 수 있는 건 유착 해소에 도움이 될 수 있다. 슬와부 혈관·신경 구조물 인접성으로 인해 해부학 지식이 충분한 치료사가 시행하는 것이 바람직하다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- =============================================================
-- SECTION 7: category_trigger_point — 5 techniques (level_4)
-- =============================================================

-- ────────────────────────────────
-- KN-TrP-RF: 대퇴직근 트리거포인트 이완
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TrP — 대퇴 전방',
  '대퇴직근 트리거포인트 이완', 'Rectus Femoris Trigger Point Release', 'KN-TrP-RF',
  'knee'::body_region, '대퇴직근 중간 근복 (연관통: 무릎 앞쪽 ~ 슬개골 주변)',
  '바로 눕기 또는 엎드려 눕기',
  '환자 환측 옆, 대퇴 전방 압통점 촉진',
  '대퇴직근 중간 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 엎드려 눕기 자세로 위치시키고 대퇴 전방 근육이 이완될 수 있도록 편안한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 엄지 또는 검지·중지로 대퇴 전방을 촉진하여 단단한 띠(taut band)와 그 안의 압통 결절(tender nodule)을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 무릎 앞쪽 또는 슬개골 주변으로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50–70% 감소할 때까지 7–10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 주변 근육을 가볍게 이완 마사지한다. 2–3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 대퇴직근 신장 운동(바로 눕기 또는 옆으로 눕기에서 무릎 굽히기)으로 치료 효과를 강화한다. 무릎 앞쪽 통증 변화 및 슬개대퇴 통증증후군 증상 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"anterior_knee_pain","patellofemoral_pain","quadriceps_tightness"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '대퇴직근 트리거포인트는 무릎 앞쪽과 슬개골 주변으로 연관통을 유발할 수 있다. 슬개건병증과 감별이 필요하며 슬개대퇴 통증증후군 환자에서 빈번히 관찰될 수 있다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-TrP-VMO: 내측광근(VMO) 트리거포인트 이완
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TrP — 대퇴 내측',
  '내측광근(VMO) 트리거포인트 이완', 'Vastus Medialis Oblique Trigger Point Release', 'KN-TrP-VMO',
  'knee'::body_region, '내측광근(VMO) 근복(대퇴 내측 하부) (연관통: 무릎 내측·슬개골 내측)',
  '바로 눕기',
  '환자 환측 옆, 대퇴 내측 하부 VMO 압통점 촉진',
  'VMO 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 대퇴 내측 근육이 이완될 수 있도록 무릎 아래에 가볍게 지지물을 받친다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 엄지 또는 검지·중지로 대퇴 내측 하부 VMO 근복을 촉진하여 단단한 띠와 압통 결절을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 무릎 내측 또는 슬개골 내측으로 퍼지는지 확인한다."},{"step":4,"instruction":"압통이 50–70% 감소할 때까지 7–10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 VMO 주변 조직을 가볍게 이완 마사지한다. 2–3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 사두근 등척성 수축(leg press at 30° knee flexion) 등 VMO 활성화 운동으로 치료 효과를 강화한다. 무릎 내측 통증 및 슬개대퇴 통증 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"medial_knee_pain","patellofemoral_pain","anterior_knee_pain"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  'VMO 트리거포인트는 무릎 내측 통증과 슬개골 내측 부위 연관통을 유발할 수 있다. PFPS 및 내측 무릎 통증 환자에서 VMO 약화와 함께 빈번히 관찰될 가능성이 있다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-TrP-Poplit: 슬와근 트리거포인트 이완
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TrP — 슬관절 후방',
  '슬와근 트리거포인트 이완', 'Popliteus Trigger Point Release', 'KN-TrP-Poplit',
  'knee'::body_region, '슬와근 근복(슬와부 내측) (연관통: 무릎 뒤쪽 국소)',
  '엎드려 눕기, 무릎 약간 굽힌 위치',
  '환자 환측 옆, 슬와부(오금) 내측 슬와근 접촉',
  '슬와부 내측 슬와근 (손가락 끝 — 오금 혈관·신경 주의)',
  '수직 허혈성 압박',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 무릎 아래에 작은 롤 타월을 받쳐 무릎을 약간 굽혀 슬와근 접근이 용이한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 슬와부(오금) 내측에서 슬와근 근복을 신중하게 촉진한다. 슬와부에는 슬와 동맥·정맥과 비골신경이 통과하므로 맥박이 느껴지는 중앙부를 피하고 내측 경계에서 접촉한다."},{"step":3,"instruction":"손가락 끝으로 슬와근 조직의 단단한 띠와 압통 결절을 확인한다. 압박 후 연관통이 무릎 뒤쪽 국소 부위로 나타나는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 7–10초간 유지한다. 슬와부 혈관·신경 압박이 의심되면 즉시 압력을 해제한다. 압통이 완화되면 압력을 서서히 해제한다."},{"step":5,"instruction":"시술 후 무릎 완전 펴기 가동범위 변화와 후방 무릎 통증 감소 여부를 재평가한다. 무릎 완전 펴기 마지막 범위 불편감이 있는 경우 특히 적용 효과를 기대할 수 있다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"posterior_knee_pain","knee_extension_restriction"}',
  '{"fracture","malignancy","acute_inflammation","dvt"}',
  'level_4'::evidence_level,
  '슬와근 트리거포인트는 무릎 뒤쪽 국소 통증과 무릎 완전 펴기 마지막 범위 불편감을 유발할 수 있다. 슬와부 혈관·신경 구조물과의 인접성으로 인해 접촉 위치를 신중하게 선택해야 할 수 있다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-TrP-SemiTend: 반건양근 트리거포인트 이완
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TrP — 대퇴 후방 내측',
  '반건양근 트리거포인트 이완', 'Semitendinosus Trigger Point Release', 'KN-TrP-SemiTend',
  'knee'::body_region, '반건양근 근복(후방 대퇴 내측) (연관통: 후방 대퇴~무릎 내측~하퇴 내측)',
  '엎드려 눕기',
  '환자 환측 옆, 후방 대퇴 내측 반건양근 압통점 촉진',
  '반건양근 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 후방 대퇴 근육이 이완될 수 있도록 편안한 자세를 만든다. 필요 시 발목 아래에 롤 타월을 받쳐 무릎을 약간 굽힌다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 엄지 또는 검지·중지로 후방 대퇴 내측에서 반건양근 근복을 촉진하여 단단한 띠와 압통 결절을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 후방 대퇴에서 무릎 내측을 거쳐 하퇴 내측으로 퍼지는지 확인한다."},{"step":4,"instruction":"압통이 50–70% 감소할 때까지 7–10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 반건양근 주변 조직을 가볍게 이완 마사지한다. 2–3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 무릎 굽히기 가동범위와 후방 대퇴 긴장도 변화를 재평가한다. 슬근(hamstring) 신장 운동으로 치료 효과를 강화할 수 있다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"posterior_knee_pain","medial_knee_pain","hamstring_tightness"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '반건양근 트리거포인트는 후방 대퇴부터 무릎 내측으로 퍼지는 연관통을 유발할 수 있다. 내측 무릎 통증의 원인을 평가할 때 MCL 병변과 함께 슬근 트리거포인트 가능성도 고려할 수 있다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────────────────
-- KN-TrP-BF: 대퇴이두근 트리거포인트 이완
-- ────────────────────────────────
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'TrP — 대퇴 후방 외측',
  '대퇴이두근 트리거포인트 이완', 'Biceps Femoris Trigger Point Release', 'KN-TrP-BF',
  'knee'::body_region, '대퇴이두근 근복(후방 대퇴 외측) (연관통: 후방 대퇴~무릎 외측~비골두)',
  '엎드려 눕기',
  '환자 환측 옆, 후방 대퇴 외측 대퇴이두근 압통점 촉진',
  '대퇴이두근 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 후방 대퇴 근육이 이완될 수 있도록 편안한 자세를 만든다. 필요 시 발목 아래에 롤 타월을 받쳐 무릎을 약간 굽힌다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 엄지 또는 검지·중지로 후방 대퇴 외측에서 대퇴이두근 근복을 촉진하여 단단한 띠와 압통 결절을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 무릎 외측과 비골두 부위로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50–70% 감소할 때까지 7–10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 대퇴이두근 주변 조직을 가볍게 이완 마사지한다. 2–3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 무릎 외측 통증 및 비골두 압통 변화를 재평가한다. 장경인대 증후군 증상과 연관되어 함께 발생하는 경우가 많을 수 있어 ITB 관련 기법과 병행 고려가 가능하다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"lateral_knee_pain","posterior_knee_pain","hamstring_tightness","iliotibial_band_syndrome"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '대퇴이두근 트리거포인트는 무릎 외측과 비골두 부위로 퍼지는 연관통을 유발할 수 있다. 장경인대 증후군과 연관되어 함께 발생하는 경우가 많을 가능성이 있어 감별 및 병행 평가가 도움이 될 수 있다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();

COMMIT;
