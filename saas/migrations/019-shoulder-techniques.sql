-- Migration 019: Shoulder Techniques
-- 견관절 35개 기법: JM 9 + Mulligan 3 + MFR 5 + ART 5 + CTM 3 + DFM 4 + TrP 6
-- sw-db-architect | 2026-04-28

BEGIN;

-- =============================================================
-- SECTION 1: category_joint_mobilization — 9 techniques
-- =============================================================

-- ────────────────────────────────
-- SH-JM-GHJ-POST: 견관절 GHJ 후방 글라이드
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
  'Maitland — GHJ',
  '견관절 GHJ 후방 글라이드', 'Shoulder Posterior GHJ Glide', 'SH-JM-GHJ-POST',
  'shoulder'::body_region, 'GHJ 후방 관절낭',
  '옆으로 눕기(환측 위) 또는 앉은 자세, 팔 몸통 옆에 편히 이완',
  '환자 옆쪽 또는 뒤쪽에 위치하여 상완골두 전방면에 엄지 또는 손바닥 접촉 준비',
  '상완골두 전방면 (엄지 또는 손바닥)',
  '전방 PA 글라이드 (Grade I–IV)',
  '[{"step":1,"instruction":"환자를 환측이 위로 향하는 옆으로 눕기 또는 앉은 자세로 위치시키고, 팔이 몸통 옆에서 편안하게 이완되도록 한다."},{"step":2,"instruction":"치료사는 환자 옆쪽 또는 뒤쪽에 서서 한 손으로 견갑골 후방면을 가볍게 안정화하고, 반대 손 엄지 또는 손바닥을 상완골두 전방면에 부드럽게 접촉한다."},{"step":3,"instruction":"Grade에 따라 힘을 조절한다. Grade I–II는 관절 저항이 느껴지기 전 범위에서 소진폭 리듬 가동, Grade III–IV는 관절 끝 범위에서 대진폭 또는 소진폭 가동을 적용한다."},{"step":4,"instruction":"상완골두를 후방(PA, posterior to anterior 역방향으로 실제로는 전방) 방향으로 리듬감 있게 밀어주며, 관절낭의 이완 반응을 촉진한다. 시술 중 환자의 통증 및 저항 변화를 지속적으로 확인한다."},{"step":5,"instruction":"30초–1분 시술 후 재평가하여 외전과 바깥쪽으로 돌리기 범위의 변화를 확인한다. 필요 시 Grade 조정 후 2–3세트 반복한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","external_rotation_restriction","abduction_restriction"}',
  '{"fracture","joint_infection","malignancy","acute_inflammation"}',
  'level_2b'::evidence_level,
  '후방 관절낭 단축이 의심될 때 적용 가능성이 높다. Grade I–II는 통증 억제 효과를 기대할 수 있고, Grade III–IV는 관절낭 이완 및 ROM 회복을 목표로 할 수 있다. 유착성 관절낭염 아급성기에 가장 많이 활용되는 기법 중 하나일 수 있다.',
  'fracture, joint_infection, malignancy',
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
-- SH-JM-GHJ-ANT: 견관절 GHJ 전방 글라이드
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
  'Maitland — GHJ',
  '견관절 GHJ 전방 글라이드', 'Shoulder Anterior GHJ Glide', 'SH-JM-GHJ-ANT',
  'shoulder'::body_region, 'GHJ 전방 관절낭',
  '엎드려 눕기 또는 앉은 자세, 팔 몸통 옆에 편히 위치',
  '환자 앞쪽 또는 옆쪽에 위치하여 상완골두 후방면에 접촉 준비',
  '상완골두 후방면 (손바닥 또는 엄지)',
  '후방 AP 글라이드 (Grade I–IV)',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 놓고, 시술 측 팔이 테이블 가장자리 밖으로 약간 나오도록 하여 상완골두 접근이 용이하게 한다. 앉은 자세라면 팔을 몸통 옆에 편히 이완시킨다."},{"step":2,"instruction":"치료사는 환자 앞쪽 또는 옆쪽에 서서 한 손으로 전방 어깨 주변을 가볍게 안정화하고, 반대 손의 손바닥 또는 엄지를 상완골두 후방면에 접촉한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade I–II는 저항 느껴지기 전 범위에서 리듬 가동, Grade III–IV는 끝 범위에서 대진폭 또는 소진폭 가동을 적용한다."},{"step":4,"instruction":"상완골두를 후방(AP, 전방에서 후방) 방향으로 리듬감 있게 밀어주며 전방 관절낭의 이완을 유도한다. 시술 중 환자의 통증 반응과 저항 변화를 지속 확인한다."},{"step":5,"instruction":"30초–1분 시술 후 어깨 펴기와 안쪽으로 돌리기 범위를 재평가한다. 필요 시 Grade 조정 후 2–3세트 반복한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","extension_restriction","internal_rotation_restriction"}',
  '{"fracture","joint_infection","malignancy","anterior_instability"}',
  'level_2b'::evidence_level,
  '전방 관절낭 단축이 의심될 때 적용 가능성이 높다. 어깨 뒤로 젖히기나 안쪽으로 돌리기가 제한된 경우 효과를 기대할 수 있다. 전방 불안정성이 있는 어깨에서는 오히려 증상을 악화시킬 수 있으므로 시술 전 안정성 평가가 중요할 수 있다.',
  'fracture, joint_infection, malignancy',
  'anterior_instability, acute_inflammation, anticoagulant_therapy',
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
-- SH-JM-GHJ-INF: 견관절 GHJ 하방 견인
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
  'Maitland — GHJ',
  '견관절 GHJ 하방 견인', 'Shoulder GHJ Inferior Traction', 'SH-JM-GHJ-INF',
  'shoulder'::body_region, 'GHJ 관절강 하방',
  '앉은 자세 또는 바로 눕기, 팔 중립 위치',
  '환자 환측 옆쪽에 위치하여 한 손으로 어깨 위를 고정하고 반대 손으로 상완 근위부를 파지',
  '상완골 근위부 내측',
  '장축 하방 견인 (Distraction)',
  '[{"step":1,"instruction":"환자를 앉은 자세 또는 바로 눕기 자세로 편안하게 위치시키고, 시술 측 팔이 몸통 옆 중립 위치에서 이완되도록 한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 한 손(안정화 손)을 어깨 위 견봉 부근에 올려 골반 방향으로 고정력을 제공하고, 반대 손으로 상완골 근위부 내측을 부드럽게 감싸 파지한다."},{"step":3,"instruction":"Grade에 따라 장축 하방(중력 방향) 견인력을 적용한다. Grade I는 매우 가벼운 분리력, Grade II는 관절 저항이 느껴지기 직전까지 분리, 통증 억제가 주목적일 때는 Grade I–II를 사용한다."},{"step":4,"instruction":"견인을 리듬감 있게 유지하거나(진동형) 지속적으로 적용하면서 관절강 내 압력 감소 및 통증 억제 반응을 유도한다. 환자의 통증 변화와 근육 이완 반응을 지속 확인한다."},{"step":5,"instruction":"30초–1분 시술 후 어깨 통증 NRS와 전반적 관절 움직임을 재평가한다. 급성기에는 Grade I 견인 후 통증 변화를 먼저 확인하고 다음 치료 계획을 결정한다."}]'::jsonb,
  '{"pain_relief","joint_decompression"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","rest_pain","movement_pain"}',
  '{"fracture","joint_infection","malignancy","inferior_instability"}',
  'level_2b'::evidence_level,
  '통증 억제 목적의 Grade I–II 견인은 급성기에도 적용 가능성이 있다. 관절강 내 압력 감소를 통해 통증 억제 효과를 기대할 수 있다. 하방 불안정성이 있는 경우 견인 방향이 불안정성을 악화시킬 수 있으므로 주의가 필요할 수 있다.',
  'fracture, joint_infection, malignancy',
  'inferior_instability, acute_inflammation',
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
-- SH-JM-GHJ-ABD: 견관절 외전 위치 하방 글라이드
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
  'Maitland — GHJ',
  '견관절 외전 위치 하방 글라이드', 'Shoulder GHJ Inferior Glide in Abduction', 'SH-JM-GHJ-ABD',
  'shoulder'::body_region, 'GHJ 하방 관절낭',
  '앉은 자세, 팔 90도 바깥쪽으로 벌린 위치에서 시작',
  '환자 환측 옆쪽에 위치하여 한 손으로 견갑골을 안정화하고 반대 손으로 상완 원위부를 파지',
  '상완골 원위부 외측',
  '하방 글라이드 유지하며 외전 범위 증가',
  '[{"step":1,"instruction":"환자를 앉은 자세로 위치시키고, 시술 측 팔을 90도 바깥쪽으로 벌린 위치(어깨 옆으로 들기)에서 출발한다. 팔꿈치는 굽히기 또는 펴기 어느 방향이든 환자가 편안한 방향으로 한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 안정화 손으로 견갑골 내측연 또는 상부를 골반 방향으로 눌러 고정하고, 반대 손으로 상완골 원위부 외측을 감싸 파지한다."},{"step":3,"instruction":"하방 글라이드 힘을 적용하면서 환자에게 팔을 천천히 더 높이 들어올리도록 유도한다. 치료사는 글라이드를 유지한 상태에서 환자의 능동 외전 범위가 확장되는 것을 보조한다."},{"step":4,"instruction":"환자가 통증 없이 도달할 수 있는 최대 외전 범위에서 3–5초 유지 후 시작 위치로 돌아온다. Grade에 따라 힘 강도를 조절하며 5–10회 반복한다."},{"step":5,"instruction":"시술 후 외전 가동범위와 painful arc 구간 변화를 재평가한다. 통증 호 구간이 줄어들거나 전체 외전 범위가 증가했는지 확인하고 다음 치료 계획에 반영한다."}]'::jsonb,
  '{"rom_improvement","pain_relief"}',
  '{"subacute","chronic"}',
  '{"abduction_restriction","painful_arc","shoulder_impingement"}',
  '{"fracture","joint_infection","malignancy","inferior_instability"}',
  'level_2b'::evidence_level,
  '외전 90도 이상에서 나타나는 painful arc에 효과를 기대할 수 있다. 하방 글라이드를 유지한 상태에서 능동 움직임을 결합하므로 Mulligan MWM 개념과 유사한 측면이 있다. 하방 불안정성이 있는 경우 글라이드 방향이 불안정성을 악화시킬 가능성이 있다.',
  'fracture, joint_infection, malignancy',
  'inferior_instability, rotator_cuff_complete_tear, acute_inflammation',
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
-- SH-JM-ACJ-PA: 견봉쇄골관절 전방 PA 가동술
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
  'Maitland — ACJ',
  '견봉쇄골관절 전방 PA 가동술', 'ACJ Anterior-Posterior Mobilization', 'SH-JM-ACJ-PA',
  'shoulder'::body_region, 'ACJ 관절낭 및 주변 인대',
  '앉은 자세, 팔 편한 위치로 옆에 놓기',
  '환자 등쪽에 위치하여 양 엄지를 쇄골 외측단 후방면에 중첩 접촉',
  '쇄골 외측단 후방면 (엄지 중첩)',
  '전방 PA 방향 (Grade I–III)',
  '[{"step":1,"instruction":"환자를 등받이 없는 의자에 앉힌 자세로 위치시키고, 시술 측 팔은 몸통 옆에서 편안하게 이완되도록 한다. 어깨가 올라가지 않도록 주의한다."},{"step":2,"instruction":"치료사는 환자 등쪽에 서서 쇄골 외측단(견봉 방향 쇄골 끝)의 위치를 촉진으로 확인하고, 양 엄지를 중첩하여 쇄골 외측단 후방면에 접촉한다."},{"step":3,"instruction":"Grade I–II는 엄지로 가벼운 전방 방향 리듬 진동을 가한다. 통증 억제 또는 예비 평가 목적에 적합하다. Grade III는 관절 끝 범위까지 밀어주는 대진폭 가동을 적용한다."},{"step":4,"instruction":"PA 방향(후방에서 전방)으로 리듬감 있게 5–10회 가동하면서 관절낭 이완 반응 및 통증 변화를 확인한다. 과도한 압력으로 국소 통증이 심해지면 Grade를 낮춘다."},{"step":5,"instruction":"시술 후 어깨 상부 통증 NRS와 외전 마지막 범위 통증 변화를 재평가한다. 증상이 호전되면 동일 Grade 2–3세트를 추가 적용하거나 다음 방문에 Grade를 올린다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","acromial_pain","end_range_pain"}',
  '{"fracture","joint_infection","malignancy","acute_acj_separation"}',
  'level_2b'::evidence_level,
  'AC 관절 기능장애로 인한 어깨 상부 통증 및 외전 마지막 범위 통증에 효과를 기대할 수 있다. 급성 ACJ 분리(등급 III 이상)에서는 관절 구조 손상 가능성이 있어 시술 전 분리 등급 확인이 중요할 수 있다.',
  'fracture, joint_infection, malignancy',
  'acute_ACJ_separation, acute_inflammation',
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
-- SH-JM-ACJ-INF: 견봉쇄골관절 하방 가동술
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
  'Maitland — ACJ',
  '견봉쇄골관절 하방 가동술', 'ACJ Inferior Mobilization', 'SH-JM-ACJ-INF',
  'shoulder'::body_region, 'ACJ 상방 관절낭',
  '앉은 자세',
  '환자 옆쪽 또는 앞쪽에 위치하여 엄지 또는 검지 끝을 쇄골 외측단 상방에 접촉',
  '쇄골 외측단 상방 (엄지 끝)',
  '하방 (Grade I–III)',
  '[{"step":1,"instruction":"환자를 앉은 자세로 위치시키고 어깨가 들리지 않도록 편안히 이완시킨다. 시술 측 팔은 몸통 옆에서 자연스럽게 이완한다."},{"step":2,"instruction":"치료사는 환자 옆쪽 또는 앞쪽에 서서 쇄골 외측단을 촉진으로 확인하고, 엄지 끝(또는 검지 끝)을 쇄골 외측단 상방에 부드럽게 접촉한다."},{"step":3,"instruction":"Grade I–II는 가벼운 리듬 진동으로 하방 방향의 소진폭 가동을 적용하여 ACJ 상방 관절낭의 이완을 유도한다. Grade III는 조직 저항에 도달하는 대진폭 가동을 적용한다."},{"step":4,"instruction":"하방 방향으로 5–10회 리듬감 있게 가동하면서 통증 반응과 관절 이동성 변화를 확인한다. 쇄골이 아닌 견봉에 압력이 가해지지 않도록 접촉 위치를 정확히 유지한다."},{"step":5,"instruction":"시술 후 어깨 상부 압통 정도와 어깨 들어올리기 범위를 재평가한다. 증상이 감소하면 동일 Grade로 2–3세트를 추가하거나 다음 방문에 Grade를 상향 조정한다."}]'::jsonb,
  '{"pain_relief","joint_mobility"}',
  '{"subacute","chronic"}',
  '{"superior_shoulder_pain","acromial_pain"}',
  '{"fracture","joint_infection","malignancy","acute_acj_separation"}',
  'level_2b'::evidence_level,
  'ACJ 상방 압통 및 쇄골 분리 후 기능 저하에 효과를 기대할 수 있다. 쇄골 외측단 위치를 정확히 촉진하지 않으면 견봉에 압력이 가해져 충돌 증상을 유발할 가능성이 있다. 골다공증이 있는 고령 환자는 Grade I–II 이상의 가동에 주의가 필요할 수 있다.',
  'fracture, joint_infection, malignancy',
  'acute_ACJ_separation, acute_inflammation, severe_osteoporosis',
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
-- SH-JM-SCJ-ANT: 흉쇄관절 전방 글라이드
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
  'Maitland — SCJ',
  '흉쇄관절 전방 글라이드', 'Sternoclavicular Joint Anterior Glide', 'SH-JM-SCJ-ANT',
  'shoulder'::body_region, 'SCJ 후방 관절낭',
  '바로 눕기, 팔 몸통 옆에 이완',
  '환자 머리 쪽 또는 옆쪽에 위치하여 엄지 끝을 쇄골 내측단 후방면에 접촉',
  '쇄골 내측단 후방면 (엄지 끝 — 흉골병과의 관절 경계)',
  '전방 글라이드 (Grade I–III)',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고, 시술 측 팔이 몸통 옆에서 편안하게 이완되도록 한다. 흉골 상단과 쇄골 내측단 접합부(SCJ)의 위치를 촉진으로 먼저 확인한다."},{"step":2,"instruction":"치료사는 환자 머리 쪽 또는 환측 옆에 서서 엄지 끝을 쇄골 내측단 후방면에 접촉한다. 흉골 자체나 흉골병이 아닌 쇄골-흉골 관절 경계에 정확히 위치시킨다."},{"step":3,"instruction":"Grade I–II는 매우 가벼운 힘으로 전방 방향 리듬 진동을 적용한다. 이 관절은 매우 작고 주변에 중요한 구조물(경정맥, 경동맥)이 있으므로 항상 Grade I–II를 먼저 평가 목적으로 적용한다."},{"step":4,"instruction":"전방 글라이드를 리듬감 있게 5–10회 적용하면서 쇄골 거상 및 후인 움직임 변화와 통증 반응을 확인한다. 엄지 끝에서 느껴지는 조직 저항 변화를 통해 Grade를 결정한다."},{"step":5,"instruction":"시술 후 팔 들어올리기와 어깨 후인 범위를 재평가한다. 흉쇄관절 위치 특성상 전신 혈관 구조물 근처이므로 시술 후 환자의 어지럼증, 두통 등 이상 반응을 반드시 확인한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"anterior_chest_pain","shoulder_elevation_restriction"}',
  '{"fracture","joint_infection","malignancy","scj_instability"}',
  'level_2b'::evidence_level,
  '흉쇄관절은 어깨 복합체의 근위부 관절로, 이 관절의 기능 제한이 쇄골 거상·후인 제한 및 전방 흉통에 기여할 가능성이 있다. 흉골 후방에 대혈관이 위치하므로 Grade III 이상의 강한 가동은 신중하게 결정해야 할 수 있다. 시술 전 SCJ 탈구 여부 확인이 필수적이다.',
  'fracture, joint_infection, malignancy, SCJ_dislocation',
  'SCJ_instability, acute_inflammation, severe_osteoporosis',
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
-- SH-JM-STJ-INF: 견갑흉곽관절 하방 활주
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
  'Maitland — STJ',
  '견갑흉곽관절 하방 활주', 'Scapular Inferior Glide', 'SH-JM-STJ-INF',
  'shoulder'::body_region, '견갑흉곽관절 하방 구역',
  '옆으로 눕기(환측 위) 또는 앉은 자세',
  '환자 뒤쪽에 위치하여 한 손은 견갑골 내측연 상부에, 반대 손은 하각 아래를 받침',
  '견갑골 내측연 상부 + 하각',
  '하방 활주 (Grade I–III)',
  '[{"step":1,"instruction":"환자를 환측이 위로 향하는 옆으로 눕기 자세로 위치시킨다. 시술 측 팔은 몸통 앞으로 편안하게 받쳐 어깨 근육 이완을 촉진한다. 앉은 자세로 시술할 경우 등을 약간 구부려 견갑 주변 근육 긴장을 줄인다."},{"step":2,"instruction":"치료사는 환자 등 쪽에 서서 한 손의 손가락 끝을 견갑골 내측연 상부(상각 근처)에 접촉하고, 반대 손으로 견갑골 하각 아래를 받쳐 견갑골 전체를 양손으로 조절 가능한 위치를 확보한다."},{"step":3,"instruction":"Grade I–II는 견갑골 내측연 상부를 가볍게 하방으로 밀어주는 리듬 진동을 적용하여 상방 고정감 이완을 유도한다. Grade III는 조직 저항에 도달할 때까지 대진폭 하방 활주를 적용한다."},{"step":4,"instruction":"하방 활주를 5–10회 반복하며 견갑골이 흉곽을 따라 하방으로 부드럽게 미끄러지는 감각을 확인한다. 견갑골이 흉곽에서 들리는 날개견갑 동작이 심해지면 힘 방향을 수정한다."},{"step":5,"instruction":"시술 후 어깨 들어올리기 범위 및 견갑골 리듬(scapulohumeral rhythm)을 재평가한다. 날개견갑(winged scapula) 증상이나 어깨 들기 협응 이상의 변화를 확인하고 다음 치료 계획에 반영한다."}]'::jsonb,
  '{"scapular_mobility","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"shoulder_elevation_difficulty","scapular_dyskinesis","shoulder_pain"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_2b'::evidence_level,
  '견갑흉곽관절은 해부학적 진관절이 아니지만 기능적으로 어깨 복합체 움직임의 핵심 구성 요소일 수 있다. 견갑골 하강 제한이나 날개견갑 패턴에서 하방 활주를 통해 흉곽 위 견갑골 활주 기능 회복을 기대할 수 있다. 견갑골 골절이 있는 경우 절대 금기이므로 외상력 확인이 선행되어야 한다.',
  'fracture, scapular_fracture, malignancy',
  'acute_inflammation, severe_rotator_cuff_tear',
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
-- SH-JM-STJ-MED: 견갑흉곽관절 내측 활주
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
  'Maitland — STJ',
  '견갑흉곽관절 내측 활주', 'Scapular Medial Glide', 'SH-JM-STJ-MED',
  'shoulder'::body_region, '견갑흉곽관절 외측 구역',
  '엎드려 눕기, 팔 몸통 옆에 이완 또는 앉은 자세',
  '환자 뒤쪽에 위치하여 한 손의 손바닥 또는 손가락 끝을 견갑골 외측연(액와 아래)에 접촉',
  '견갑골 외측연 (손바닥 또는 손가락 끝)',
  '내측 활주 (Grade I–III)',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고, 시술 측 팔은 몸통 옆에서 편안하게 이완되도록 한다. 앉은 자세라면 등을 약간 구부려 승모근과 능형근 긴장을 줄인다."},{"step":2,"instruction":"치료사는 환자 등 쪽에 서서 겨드랑이 아래를 통해 견갑골 외측연에 접근한다. 손바닥 또는 손가락 끝을 견갑골 외측연에 부드럽게 접촉하여 견갑골을 파지하는 느낌으로 자세를 잡는다."},{"step":3,"instruction":"Grade I–II는 견갑골 외측연을 가볍게 내측(척추 방향)으로 밀어주는 리듬 진동을 적용한다. Grade III는 능형근 수축이 느껴지는 저항 범위까지 대진폭 내측 활주를 적용한다."},{"step":4,"instruction":"내측 활주를 5–10회 반복하며 견갑골이 흉곽 위를 내측으로 부드럽게 미끄러지는 감각을 확인한다. 시술 중 어깨가 앞으로 구부러지거나 과도하게 들리는 보상 동작이 생기면 환자에게 자세 교정을 안내한다."},{"step":5,"instruction":"시술 후 견갑골 내전 범위 및 라운드숄더 자세 변화를 재평가한다. 견갑골이 척추 방향으로 더 가까이 이동할 수 있는지, 어깨 앞쪽 긴장감이 감소했는지를 확인하고 다음 치료 계획에 반영한다."}]'::jsonb,
  '{"scapular_mobility","postural_correction"}',
  '{"subacute","chronic"}',
  '{"scapular_dyskinesis","rounded_shoulder","shoulder_pain"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_2b'::evidence_level,
  '견갑골 전방 경사(전인) 우세 및 라운드숄더 패턴에서 흉곽 위 견갑골 내측 활주 기능 회복을 기대할 수 있다. 능형근과 중부 승모근의 수동적 이완을 먼저 적용한 후 시술하면 내측 활주 효율이 높아질 가능성이 있다. 견갑골 골절 이력이 있는 경우 절대 금기이므로 시술 전 외상력 확인이 필요하다.',
  'fracture, scapular_fracture, malignancy',
  'acute_inflammation, severe_osteoporosis',
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
-- SH-MUL-FLEX: 견관절 굴곡 MWM
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
  'Mulligan MWM — 견관절',
  '견관절 굴곡 MWM', 'Shoulder Flexion MWM', 'SH-MUL-FLEX',
  'shoulder'::body_region, 'GHJ 상완골두',
  '앉은 자세, 팔 몸통 옆에 이완',
  '환자 환측 뒤쪽에 위치하여 양손으로 상완골두 후방·외측면을 웹 스페이스 또는 엄지와 네 손가락으로 파지',
  '상완골두 후방·외측면',
  '후방·외측 글라이드 유지하며 환자 능동 굴곡',
  '[{"step":1,"instruction":"환자를 앉은 자세로 위치시키고, 시술 측 팔이 몸통 옆에서 자연스럽게 이완되도록 한다. 환자에게 ''팔을 앞으로 들어올릴 때 통증이나 제한이 느껴지는 범위까지만 움직여도 괜찮다''고 설명하여 긴장을 줄인다."},{"step":2,"instruction":"치료사는 환자 환측 뒤쪽에 서서 양손의 웹 스페이스(엄지와 검지 사이) 또는 엄지와 네 손가락으로 상완골두 후방·외측면을 부드럽게 감싸 파지한다. 과도한 압력으로 통증이 생기지 않도록 주의한다."},{"step":3,"instruction":"환자에게 팔을 천천히 앞으로 들어올리도록 지시하면서, 치료사는 동시에 상완골두를 후방·외측 방향으로 지속적인 글라이드 힘을 유지한다. 글라이드 방향은 환자의 통증이 사라지거나 줄어드는 방향으로 미세 조정한다."},{"step":4,"instruction":"환자가 무통 범위 내에서 최대 굴곡 위치에 도달하면 1–2초 유지 후 시작 위치로 천천히 돌아온다. 시술 중 어떤 통증도 유발되어서는 안 된다(MWM 핵심 원칙). 통증이 생기면 글라이드 방향 또는 강도를 즉시 조정한다."},{"step":5,"instruction":"6–10회 반복 후 보조 없이 능동 굴곡 범위를 재평가한다. 즉각적인 ROM 증가 또는 통증 감소가 확인되면 올바른 글라이드 방향이 적용된 것이다. 다음 세션에서 자가 MWM(벨트 또는 파트너 사용) 홈프로그램을 교육할 수 있다."}]'::jsonb,
  '{"pain_relief","rom_improvement","functional_improvement"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","flexion_restriction","overhead_difficulty"}',
  '{"fracture","joint_infection","malignancy","instability"}',
  'level_2b'::evidence_level,
  'MWM의 핵심 원칙은 글라이드 적용 중 통증이 없어야 한다는 것이다. 글라이드 방향은 후방·외측이 일반적이지만 개인마다 최적 방향이 다를 수 있으므로 미세 조정이 필요할 수 있다. 즉각적 ROM 변화가 없다면 글라이드 방향과 강도를 재평가해야 한다.',
  'fracture, joint_infection, malignancy',
  'instability, acute_inflammation',
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
-- SH-MUL-ABD: 견관절 외전 MWM
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
  'Mulligan MWM — 견관절',
  '견관절 외전 MWM', 'Shoulder Abduction MWM', 'SH-MUL-ABD',
  'shoulder'::body_region, 'GHJ 상완골두',
  '앉은 자세, 팔 몸통 옆에 이완',
  '환자 뒤쪽에 위치하여 양손으로 상완골두 후방·외측면을 파지',
  '상완골두 후방·외측면',
  '후방·외측 글라이드 유지하며 환자 능동 외전',
  '[{"step":1,"instruction":"환자를 앉은 자세로 위치시키고, 시술 측 팔이 몸통 옆에서 자연스럽게 이완되도록 한다. 환자에게 팔을 옆으로 들어올릴 때 통증이나 걸리는 느낌이 나타나는 지점을 미리 확인하게 한다(painful arc 구간 파악)."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 서서 양손으로 상완골두 후방·외측면을 부드럽게 감싸 파지한다. 엄지 또는 웹 스페이스를 이용하여 파지하되, 상완골두에 직접 압박이 가해지지 않도록 한다."},{"step":3,"instruction":"환자에게 팔을 천천히 옆으로 들어올리도록 지시하면서, 치료사는 동시에 상완골두를 후방·외측 방향으로 지속적인 글라이드 힘을 유지한다. painful arc 구간에서 환자가 통증 없이 통과하는지 확인한다."},{"step":4,"instruction":"환자가 무통 범위 내에서 최대 외전 위치에 도달하면 1–2초 유지 후 시작 위치로 천천히 돌아온다. 시술 중 어떤 통증도 유발되어서는 안 된다. 통증이 있으면 즉시 글라이드 방향을 조정한다."},{"step":5,"instruction":"6–10회 반복 후 보조 없이 능동 외전 범위를 재평가한다. painful arc 구간의 통증 감소 또는 전체 외전 범위 증가가 확인되면 올바른 적용이 된 것이다. 가능하다면 이후 세션에서 벨트를 이용한 자가 MWM 방법을 교육한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"abduction_restriction","painful_arc","shoulder_impingement"}',
  '{"fracture","joint_infection","malignancy","instability"}',
  'level_2b'::evidence_level,
  'painful arc(60–120도 범위의 통증 호) 증상에 즉각적인 통증 감소 효과를 기대할 수 있다. 글라이드 방향이 정확하지 않으면 통증이 줄지 않으므로 후방·외측 외에 다른 방향도 시험해볼 가능성이 있다. 하방 불안정성이나 회전근개 완전 파열이 있는 경우 적용을 피하는 것이 안전할 수 있다.',
  'fracture, joint_infection, malignancy',
  'inferior_instability, complete_rotator_cuff_tear, acute_inflammation',
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
-- SH-MUL-ER: 견관절 외회전 MWM
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
  'Mulligan MWM — 견관절',
  '견관절 외회전 MWM', 'Shoulder External Rotation MWM', 'SH-MUL-ER',
  'shoulder'::body_region, 'GHJ 후방 관절낭',
  '앉은 자세 또는 바로 눕기, 팔 90도 들어올린 위치',
  '환자 앞쪽 또는 환측 옆에 위치하여 한 손으로 상완골두 전방면에 접촉',
  '상완골두 전방면 (손바닥 또는 엄지)',
  '전방 글라이드 유지하며 환자 능동 바깥쪽으로 돌리기',
  '[{"step":1,"instruction":"환자를 앉은 자세 또는 바로 눕기 자세로 위치시키고, 시술 측 팔을 90도 들어올린 위치(어깨 옆으로 들기 90도, 팔꿈치 굽히기 90도)에서 출발한다. 환자에게 팔을 바깥쪽으로 돌릴 때 통증이나 제한이 나타나는 범위를 먼저 확인하게 한다."},{"step":2,"instruction":"치료사는 환자 앞쪽 또는 환측 옆에 위치하여 한 손으로 상완골두 전방면(어깨 앞쪽)에 손바닥 또는 엄지를 부드럽게 접촉한다. 반대 손은 전완 또는 팔꿈치를 지지한다."},{"step":3,"instruction":"환자에게 팔을 바깥쪽으로 천천히 돌리도록 지시하면서, 치료사는 동시에 상완골두를 전방 방향으로 지속적인 글라이드 힘을 유지한다. 글라이드 방향은 환자의 통증이 사라지거나 줄어드는 방향으로 미세 조정한다."},{"step":4,"instruction":"환자가 무통 범위 내에서 최대 바깥쪽으로 돌리기 위치에 도달하면 1–2초 유지 후 시작 위치로 천천히 돌아온다. 시술 중 어떤 통증도 유발되어서는 안 된다. 통증이 있으면 즉시 글라이드 방향 또는 강도를 조정한다."},{"step":5,"instruction":"6–10회 반복 후 보조 없이 능동 바깥쪽으로 돌리기 범위를 재평가한다. ROM 증가 또는 통증 감소가 확인되면 올바른 적용이 된 것이다. 필요 시 다음 세션에서 자가 MWM 홈프로그램을 교육한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"external_rotation_restriction","shoulder_pain","rotator_cuff_dysfunction"}',
  '{"fracture","joint_infection","malignancy","anterior_instability"}',
  'level_2b'::evidence_level,
  '어깨 바깥쪽으로 돌리기 제한은 유착성 관절낭염, 회전근개 병증, 후방 관절낭 단축에서 흔히 나타날 수 있다. 전방 글라이드를 통해 상완골두의 위치를 조정하면서 능동 외회전을 허용하는 원리로 즉각적인 ROM 회복을 기대할 수 있다. 전방 불안정성이 있는 경우 전방 글라이드가 불안정성을 악화시킬 가능성이 있으므로 적용 전 안정성 평가가 필요할 수 있다.',
  'fracture, joint_infection, malignancy',
  'anterior_instability, acute_inflammation',
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
-- Migration 019 (Part 2): Shoulder — MFR + ART (10 techniques)
-- K-Movement Optimism / PT 처방 도우미
-- 생성일: 2026-04-28
-- 작성자: sw-db-architect
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
--
-- 포함 기법:
--   SECTION 3: category_mfr (5개) — 어깨 근막이완
--     [1]  소흉근 근막이완                          SH-MFR-PecMin
--     [2]  극상근 근막이완                          SH-MFR-Supra
--     [3]  극하근·소원근 근막이완                    SH-MFR-Infra
--     [4]  견갑하근 근막이완                         SH-MFR-Sub
--     [5]  견갑대 후방 근막이완                      SH-MFR-Post
--   SECTION 4: category_art (5개) — 어깨 능동적 이완기법
--     [6]  극상근 능동적 이완기법                    ART-Supra
--     [7]  극하근 능동적 이완기법                    ART-Infra
--     [8]  견갑하근 능동적 이완기법                  ART-Sub
--     [9]  소흉근 능동적 이완기법                    ART-PecMin
--     [10] 삼두근 장두 능동적 이완기법               ART-TricepsLH
--
-- 전제 조건:
--   - 019-part1 실행 완료 (BEGIN 포함)
--   - category_mfr, category_art enum 존재
--   - 'shoulder'::body_region enum 값 존재
--   - evidence_level 'level_4' 존재
-- ============================================================

-- ============================================================
-- SECTION 3: category_mfr — 어깨 근막이완 기법 5개
-- evidence_level = 'level_4'
-- ============================================================

-- ============================================================
-- [1] 소흉근 근막이완
-- ============================================================
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
  'MFR — 견갑 전방',
  '소흉근 근막이완', 'Pectoralis Minor MFR', 'SH-MFR-PecMin',
  'shoulder'::body_region, '소흉근(제3–5늑골 → 오구돌기)',
  '바로 눕기',
  '환자 환측 옆, 한 손 가슴뼈(흉골) 안정화, 한 손 소흉근 근복 접촉',
  '제3–5늑골 수준 소흉근 근복 (손가락 끝 또는 엄지)',
  '소흉근 주행 방향(늑골-오구돌기)과 수직 압박 유지 후 조직 장벽에서 근막 이완 대기',
  '[{"step":1,"instruction":"자세 세팅 및 촉진 단계: 환자를 바로 눕힌다. 치료사는 환측 옆에 서서 한 손을 가슴뼈(흉골) 위에 올려 흉곽을 안정화한다. 반대쪽 손가락 끝 또는 엄지로 대흉근 내측 경계를 따라 심층에 위치한 소흉근 근복을 촉진한다. 제3–4늑골 수준에서 압통이 가장 강한 구간을 확인한다."},{"step":2,"instruction":"심층 접근 단계: 손가락 끝을 대흉근 섬유 사이 또는 내측으로 부드럽게 밀어 소흉근 근복에 접촉한다. 환자가 숨을 내쉬는 순간 서서히 깊이를 증가시켜 소흉근 근막 장벽이 느껴지는 깊이까지 도달한다. 급격히 힘으로 밀지 않는다."},{"step":3,"instruction":"근막 이완 대기 단계: 소흉근 근막 장벽에서 압박을 유지하며 조직이 스스로 이완될 때까지 기다린다. 장벽에서 조직이 녹아드는 듯한 느낌(release)이 오면 손가락을 따라 더 깊이 이동한다. 한 구간당 60–90초 기다린다."},{"step":4,"instruction":"구간 이동 및 전체 근복 탐색 단계: 제3늑골 부착부에서 오구돌기 방향으로 1–2cm씩 이동하며 소흉근 전체 주행 경로를 탐색한다. 오구돌기 직하방 부착부는 별도로 집중 이완한다. 양측 비교 시 건측에 비해 경직 정도를 확인한다."},{"step":5,"instruction":"재평가 단계: 시술 후 어깨 굴곡 및 외전 ROM을 재측정한다. 견갑골 전방 경사 변화 여부를 시진으로 확인한다. 환자가 호흡 시 흉곽 움직임이 더 자유로워졌는지 확인한다. 통증 NRS를 재측정한다."}]'::jsonb,
  '{"tissue_release","scapular_mobility","postural_correction"}',
  '{"subacute","chronic"}',
  '{"anterior_chest_tightness","scapular_dyskinesis","shoulder_impingement"}',
  '{"rib_fracture","malignancy","acute_inflammation","thrombosis"}',
  'level_4'::evidence_level,
  '소흉근 단축은 견갑골 전방 경사와 전인을 유발해 어깨 충돌 및 회전근개 기능 저하와 연관될 수 있다. 앉은 자세 자세 불량이 있는 환자에서 빈번히 관찰됨',
  'rib_fracture, malignancy, deep_vein_thrombosis',
  'acute_inflammation, anticoagulant_therapy, recent_surgery',
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

-- ============================================================
-- [2] 극상근 근막이완
-- ============================================================
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
  'MFR — 회전근개',
  '극상근 근막이완', 'Supraspinatus MFR', 'SH-MFR-Supra',
  'shoulder'::body_region, '극상근(극상와 → 상완골 대결절)',
  '앉은 자세 또는 엎드려 눕기',
  '환자 뒤쪽, 한 손 어깨(견봉) 안정화, 한 손 극상근 근복 접촉',
  '극상와 내 극상근 근복 (엄지 또는 손가락 끝)',
  '극상근 주행 방향(극상와-대결절)과 수직 압박 유지 후 조직 장벽에서 근막 이완 대기',
  '[{"step":1,"instruction":"자세 세팅 및 촉진 단계: 환자를 앉은 자세 또는 엎드려 눕힌다. 치료사는 환자 뒤쪽에 위치하여 한 손을 어깨(견봉) 위에 올려 견갑대를 안정화한다. 반대쪽 엄지 또는 손가락 끝으로 견봉 내측 극상와 방향으로 촉진하며 극상근 근복을 확인한다. 근복이 다른 부위보다 단단하거나 압통이 있는 구간을 탐색한다."},{"step":2,"instruction":"심층 접근 단계: 상부 승모근을 부드럽게 내측으로 밀어낸 뒤 손가락 끝 또는 엄지가 극상와 바닥 방향으로 향하도록 접촉한다. 환자가 숨을 내쉬는 순간 서서히 깊이를 증가시켜 극상근 근막 장벽이 느껴지는 깊이까지 도달한다."},{"step":3,"instruction":"근막 이완 대기 단계: 극상근 근막 장벽에서 압박을 유지하며 조직이 스스로 이완될 때까지 기다린다. 장벽에서 조직이 부드럽게 녹아드는 느낌이 오면 손가락을 따라 더 깊이 이동하거나 대결절 방향으로 조금씩 이동한다. 한 구간당 60–90초 기다린다."},{"step":4,"instruction":"구간 이동 및 전체 근복 탐색 단계: 극상와 내측(척추 인접부)에서 외측(대결절 부착부) 방향으로 1–2cm씩 이동하며 극상근 전체 주행 경로를 탐색한다. 건-근 접합부(대결절 직상방) 구간은 특히 집중 탐색한다."},{"step":5,"instruction":"재평가 단계: 시술 후 어깨 외전 painful arc(60–120° 구간) 변화 여부를 확인한다. 외전 ROM을 재측정한다. 통증 NRS를 재측정한다. 필요 시 어깨 외전 저항 검사(empty can test)를 재시행하여 통증 변화를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","abduction_restriction","rotator_cuff_dysfunction"}',
  '{"fracture","malignancy","acute_inflammation","open_wound"}',
  'level_4'::evidence_level,
  '극상근 근막 제한은 외전 painful arc 및 견봉하 공간 감소와 연관될 수 있다. 회전근개 건병증 환자에서 극상와 내 조직 경직이 빈번히 관찰됨',
  'fracture, malignancy, active_infection',
  'acute_inflammation, recent_rotator_cuff_surgery, anticoagulant_therapy',
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

-- ============================================================
-- [3] 극하근·소원근 근막이완
-- ============================================================
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
  'MFR — 회전근개',
  '극하근·소원근 근막이완', 'Infraspinatus / Teres Minor MFR', 'SH-MFR-Infra',
  'shoulder'::body_region, '극하근·소원근(극하와·견갑골 외측연 → 상완골 대결절)',
  '옆으로 눕기(환측 위) 또는 앉은 자세',
  '환자 뒤쪽, 견갑골 외측연 ~ 극하와 수준에서 접촉',
  '극하와 내 및 견갑골 외측연 극하근·소원근 근복',
  '극하근·소원근 주행 방향(극하와-대결절)과 수직 압박 유지 후 조직 장벽에서 근막 이완 대기',
  '[{"step":1,"instruction":"자세 세팅 및 촉진 단계: 환자를 환측이 위가 되도록 옆으로 눕힌다(또는 앉은 자세). 치료사는 환자 뒤쪽에 위치하여 견갑골 외측연에서 극하와까지 손바닥으로 부드럽게 쓸어 극하근과 소원근 주행 경로를 확인한다. 견갑골 외측연과 극하와 사이 구간에서 압통 또는 경직이 강한 구간을 탐색한다."},{"step":2,"instruction":"접촉 및 심층 접근 단계: 손가락 끝을 극하와 내 극하근 근복 또는 견갑골 외측연 소원근 근복에 접촉한다. 환자가 숨을 내쉬는 순간 서서히 깊이를 증가시켜 근막 장벽이 느껴지는 깊이까지 도달한다. 과도한 힘을 사용하지 않는다."},{"step":3,"instruction":"근막 이완 대기 단계: 근막 장벽에서 압박을 유지하며 조직이 스스로 이완될 때까지 기다린다. 조직이 부드럽게 풀리는 느낌이 오면 손가락을 따라 더 외측(대결절 방향)으로 조금씩 이동한다. 한 구간당 60–90초 기다린다."},{"step":4,"instruction":"극하근과 소원근 분리 탐색 단계: 극하근(극하와 상부, 수평 주행)과 소원근(견갑골 외측연 하부, 대각선 주행)은 서로 다른 주행 방향을 가지므로 접촉 위치를 조정하며 각각 탐색한다. 소원근은 견갑골 외측연을 따라 상방 1/3 구간에서 주로 촉진된다."},{"step":5,"instruction":"재평가 단계: 시술 후 어깨 안쪽으로 돌리기(내회전) ROM을 재측정한다. 후방 어깨 통증 NRS를 재측정한다. 환측으로 눕기 시 불편감 변화를 확인한다. 필요 시 팔꿈치를 옆구리에 붙인 채 내회전 저항 검사를 재시행하여 통증 변화를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"posterior_shoulder_pain","internal_rotation_restriction","sleep_pain"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '극하근과 소원근의 근막 제한은 어깨 안쪽으로 돌리기 제한 및 후방 어깨 통증의 주요 원인이 될 수 있다. 수면 시 환측으로 눕기 불편함 호소 환자에서 빈번히 관찰됨',
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

-- ============================================================
-- [4] 견갑하근 근막이완
-- ============================================================
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
  'MFR — 회전근개',
  '견갑하근 근막이완', 'Subscapularis MFR', 'SH-MFR-Sub',
  'shoulder'::body_region, '견갑하근(견갑하와 → 상완골 소결절)',
  '바로 눕기, 팔 90도 외전 위치 또는 앉은 자세',
  '환자 환측 옆, 액와(겨드랑이) 공간을 통해 견갑하와 접근',
  '액와 공간을 통한 견갑하근 근복 (손가락 끝, 내측연 접근)',
  '수직(전방에서 견갑하와 방향) 압박 유지 후 조직 장벽에서 근막 이완 대기',
  '[{"step":1,"instruction":"자세 세팅 및 액와 접근 확인 단계: 환자를 바로 눕히고 환측 팔을 약 90° 외전시켜 액와(겨드랑이) 공간을 확보한다. 치료사는 환측 옆에 서서 손가락 끝을 액와 공간으로 부드럽게 삽입한다. 견갑골 내측연 방향으로 손가락을 이동하며 견갑하와 표면을 촉진한다."},{"step":2,"instruction":"심층 접근 및 견갑하근 확인 단계: 손가락 끝을 견갑골 전면(견갑하와)에 접촉시킨다. 환자가 숨을 내쉬는 순간 서서히 깊이를 증가시켜 견갑하근 근복 표면이 느껴지는 깊이까지 도달한다. 압통 또는 경직이 가장 강한 구간을 확인한다."},{"step":3,"instruction":"근막 이완 대기 단계: 견갑하근 근막 장벽에서 압박을 유지하며 조직이 스스로 이완될 때까지 기다린다. 조직이 부드럽게 풀리는 느낌이 오면 손가락을 따라 조금씩 외측(소결절 방향)으로 이동한다. 한 구간당 60–90초 기다린다."},{"step":4,"instruction":"구간 이동 및 전체 근복 탐색 단계: 견갑하와 내측(척추연 인접부)에서 외측(액와 방향)으로 1–2cm씩 이동하며 견갑하근 전체 주행 경로를 탐색한다. 상부 섬유(수평 주행)와 하부 섬유(사선 주행)가 다른 방향임을 고려하여 접촉 각도를 조정한다."},{"step":5,"instruction":"재평가 단계: 시술 후 어깨 바깥쪽으로 돌리기(외회전) ROM을 재측정한다. 어깨 앞쪽 통증 NRS를 재측정한다. 팔을 머리 위로 올리기 시 불편감 변화를 확인한다. 필요 시 외회전 저항 검사를 재시행하여 통증 변화를 확인한다."}]'::jsonb,
  '{"tissue_release","rom_improvement","pain_relief"}',
  '{"subacute","chronic"}',
  '{"anterior_shoulder_pain","external_rotation_restriction","frozen_shoulder"}',
  '{"fracture","malignancy","acute_inflammation","lymph_node_enlargement"}',
  'level_4'::evidence_level,
  '견갑하근 근막 제한은 어깨 바깥쪽으로 돌리기 제한과 어깨 앞쪽 통증의 원인이 될 수 있다. 유착성 관절낭염 환자에서 외회전 제한의 핵심 요인 중 하나',
  'fracture, malignancy, active_axillary_infection',
  'acute_inflammation, lymphadenopathy, anticoagulant_therapy',
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

-- ============================================================
-- [5] 견갑대 후방 근막이완
-- ============================================================
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
  'MFR — 견갑 후방',
  '견갑대 후방 근막이완', 'Posterior Shoulder Complex MFR', 'SH-MFR-Post',
  'shoulder'::body_region, '후방 삼각근·극하근·소원근·대원근 복합체',
  '옆으로 눕기(환측 위) 또는 앉은 자세, 팔 가슴 앞쪽으로 교차',
  '환자 뒤쪽, 후방 어깨 전반에 넓게 접촉',
  '후방 삼각근·극하근·소원근·대원근 복합체 (전체 손바닥 또는 손가락 전체)',
  '후방 어깨 복합체 전반에 걸친 넓은 면적 수직 압박 유지 후 조직 장벽에서 근막 이완 대기',
  '[{"step":1,"instruction":"자세 세팅 및 후방 어깨 평가 단계: 환자를 환측이 위가 되도록 옆으로 눕히고 팔을 가슴 앞쪽으로 가볍게 교차시켜 후방 어깨 복합체를 노출시킨다(또는 앉은 자세). 치료사는 환자 뒤쪽에 위치하여 후방 삼각근에서 극하근·소원근·대원근 방향으로 손바닥 전체를 이용해 부드럽게 쓸어 가장 긴장이 높은 구간을 탐색한다."},{"step":2,"instruction":"넓은 면적 접촉 및 초기 압박 단계: 전체 손바닥 또는 손가락 전체를 후방 어깨 복합체에 밀착시킨다. 환자가 숨을 내쉬는 순간 서서히 조직 장벽이 느껴지는 깊이까지 균일한 압박을 가한다. 한 부위에 집중하지 않고 넓은 면적을 동시에 접촉하는 것이 핵심이다."},{"step":3,"instruction":"근막 이완 대기 단계: 후방 어깨 복합체 전반의 근막 장벽에서 압박을 유지하며 조직이 스스로 이완될 때까지 기다린다. 장벽에서 조직이 부드럽게 풀리는 느낌이 오면 손바닥을 따라 이완 방향으로 자연스럽게 이동한다. 한 구간당 60–120초 기다린다."},{"step":4,"instruction":"국소 집중 이완 단계: 넓은 면적 이완 후 가장 경직이 강하게 남아 있는 국소 구간(예: 극하근 중부 또는 대원근 근복 중앙)을 손가락 끝으로 집중 이완한다. 접촉 면적을 줄여 보다 깊은 국소 이완을 유도한다."},{"step":5,"instruction":"재평가 단계: 시술 후 어깨 굴곡 및 수평 내전(팔을 가슴 앞으로 모으기) ROM을 재측정한다. 후방 어깨 통증 NRS를 재측정한다. 오버헤드 활동 시 불편감 변화를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","postural_correction"}',
  '{"subacute","chronic"}',
  '{"posterior_shoulder_pain","scapular_dyskinesis","overhead_difficulty"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '후방 어깨 복합체의 근막 제한은 견갑골 전방 경사 및 내회전 증가를 유발해 충돌 증후군과 연관될 수 있다. 투구 동작이나 반복적 오버헤드 활동 후 빈번히 관찰됨',
  'fracture, malignancy, active_infection',
  'acute_inflammation, recent_surgery, anticoagulant_therapy',
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

-- ============================================================
-- SECTION 4: category_art — 어깨 능동적 이완기법 5개
-- evidence_level = 'level_4'
-- ============================================================

-- ============================================================
-- [6] 극상근 능동적 이완기법
-- ============================================================
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
  'ART — 회전근개',
  '극상근 능동적 이완기법', 'Supraspinatus Active Release Technique', 'ART-Supra',
  'shoulder'::body_region, '극상근건(극상와 ~ 상완골 대결절)',
  '앉은 자세 또는 엎드려 눕기',
  '환자 뒤쪽, 한 손 극상와 내 극상근 근복에 접촉 압박 유지',
  '극상와 내 극상근 근복 (엄지 끝 또는 검지·중지)',
  '접촉 유지하며 팔을 외전에서 내전 방향으로 능동 이동',
  '[{"step":1,"instruction":"촉진 및 목표 구간 확인 단계: 환자를 앉은 자세 또는 엎드려 눕힌다. 치료사는 환자 뒤쪽에 위치하여 상부 승모근을 부드럽게 내측으로 밀어낸 뒤 엄지 또는 검지·중지 끝으로 극상와를 촉진한다. 단단한 띠 형태의 경결 또는 압통이 강한 구간(주로 대결절 부착 직전)을 확인한다."},{"step":2,"instruction":"접촉 고정 단계: 목표 구간에 엄지 또는 손가락 끝을 밀착시키고 서서히 깊이를 증가시켜 극상근 근복에 접촉한다. 환자에게 팔을 외전 90° 위치로 들어올리도록 한다. 통증 NRS 기준점을 확인한다."},{"step":3,"instruction":"능동 이완 시행 단계: 접촉 압박을 유지한 상태에서 환자에게 팔을 천천히 내전 방향으로(옆구리 쪽으로) 내리도록 지시한다. 5–8초에 걸쳐 천천히 이동하며 극상근을 신장한다. 치료사 손 아래에서 조직의 긴장이 증가하는 것을 확인한다. 최대 내전 위치에서 2–3초 유지 후 시작 자세로 복귀한다."},{"step":4,"instruction":"반복 및 접촉 위치 이동 단계: 1회 완료 후 시작 자세로 복귀한다. 2–3회 반복 후 접촉 위치를 1–2cm씩 이동하며 극상근 전체 주행 경로(극상와 내측 ~ 대결절 부착부)를 탐색한다. 각 부위 2–3회 반복한다."},{"step":5,"instruction":"이상 반응 확인 및 재평가 단계: 시술 중 강한 찌릿한 신경 증상이 발생하면 위치를 조정한다. 시술 후 앉은 자세에서 어깨 외전 painful arc 변화를 확인한다. 외전 ROM 및 통증 NRS를 재측정한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","abduction_restriction","rotator_cuff_dysfunction"}',
  '{"fracture","malignancy","acute_inflammation","complete_rotator_cuff_tear"}',
  'level_4'::evidence_level,
  '극상근 ART는 반복적 미세외상 또는 과사용으로 인한 근막 유착 해소에 효과적일 수 있다. 정적 스트레칭보다 동적 이완으로 건-근 접합부 긴장 개선에 유리할 수 있음',
  'fracture, malignancy, active_infection',
  'complete_rotator_cuff_tear, acute_inflammation, anticoagulant_therapy',
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

-- ============================================================
-- [7] 극하근 능동적 이완기법
-- ============================================================
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
  'ART — 회전근개',
  '극하근 능동적 이완기법', 'Infraspinatus Active Release Technique', 'ART-Infra',
  'shoulder'::body_region, '극하근(극하와 ~ 상완골 대결절 후방면)',
  '옆으로 눕기(환측 위) 또는 앉은 자세',
  '환자 뒤쪽, 극하와에 접촉 압박 유지',
  '극하와 내 극하근 근복 (엄지 또는 검지·중지)',
  '접촉 유지하며 팔을 내회전에서 외회전 방향으로 능동 이동',
  '[{"step":1,"instruction":"촉진 및 목표 구간 확인 단계: 환자를 환측이 위가 되도록 옆으로 눕힌다(또는 앉은 자세). 치료사는 환자 뒤쪽에 위치하여 엄지 또는 검지·중지 끝으로 극하와를 촉진한다. 대결절 후방면 부착부 방향으로 단단한 경결 또는 압통이 강한 구간을 확인한다."},{"step":2,"instruction":"접촉 고정 단계: 목표 구간에 엄지 또는 손가락 끝을 밀착시키고 서서히 깊이를 증가시켜 극하근 근복에 접촉한다. 환자에게 팔꿈치를 90° 굴곡한 상태에서 팔을 안쪽으로 돌린 자세(내회전)를 취하도록 한다. 통증 NRS 기준점을 확인한다."},{"step":3,"instruction":"능동 이완 시행 단계: 접촉 압박을 유지한 상태에서 환자에게 팔을 천천히 바깥쪽으로 돌리도록(외회전) 지시한다. 5–8초에 걸쳐 천천히 이동하며 극하근을 신장한다. 치료사 손 아래에서 조직의 긴장이 증가하는 것을 확인한다. 최대 외회전 위치에서 2–3초 유지 후 시작 자세로 복귀한다."},{"step":4,"instruction":"반복 및 접촉 위치 이동 단계: 1회 완료 후 시작 자세로 복귀한다. 2–3회 반복 후 접촉 위치를 1–2cm씩 이동하며 극하근 전체 주행 경로(극하와 내측 ~ 대결절 후방 부착부)를 탐색한다. 각 부위 2–3회 반복한다."},{"step":5,"instruction":"이상 반응 확인 및 재평가 단계: 시술 중 강한 찌릿한 신경 증상이 발생하면 위치를 조정한다. 시술 후 어깨 외회전 ROM 및 후방 어깨 통증 NRS를 재측정한다. 환측으로 눕기 시 불편감 변화를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"posterior_shoulder_pain","external_rotation_restriction","rotator_cuff_dysfunction"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '극하근 ART는 어깨 외회전 제한 및 후방 어깨 통증의 근막 원인 해소에 도움이 될 수 있다. 어깨 관절경 수술 전 보존적 치료 옵션으로 고려될 수 있음',
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

-- ============================================================
-- [8] 견갑하근 능동적 이완기법
-- ============================================================
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
  'ART — 회전근개',
  '견갑하근 능동적 이완기법', 'Subscapularis Active Release Technique', 'ART-Sub',
  'shoulder'::body_region, '견갑하근(견갑하와 ~ 소결절)',
  '바로 눕기, 팔 바깥쪽으로 벌린 자세',
  '환자 환측 옆, 액와(겨드랑이)를 통해 견갑하근 접근',
  '액와 공간을 통한 견갑하근 근복 (손가락 끝)',
  '접촉 유지하며 팔을 외회전에서 내회전 방향으로 능동 이동',
  '[{"step":1,"instruction":"자세 세팅 및 액와 접근 단계: 환자를 바로 눕히고 환측 팔을 약 90° 외전 및 외회전시켜 액와 공간을 확보한다. 치료사는 환측 옆에 서서 손가락 끝을 액와 공간으로 부드럽게 삽입한다. 견갑골 내측연 방향으로 손가락을 이동하며 견갑하와 표면의 견갑하근 근복을 촉진한다."},{"step":2,"instruction":"접촉 고정 단계: 압통 또는 경직이 강한 구간에 손가락 끝을 밀착시키고 서서히 깊이를 증가시켜 견갑하근 근복에 접촉한다. 환자에게 팔꿈치를 90° 굴곡한 상태에서 팔을 바깥쪽으로 돌린 자세(외회전)를 취하도록 한다. 통증 NRS 기준점을 확인한다."},{"step":3,"instruction":"능동 이완 시행 단계: 접촉 압박을 유지한 상태에서 환자에게 팔을 천천히 안쪽으로 돌리도록(내회전) 지시한다. 5–8초에 걸쳐 천천히 이동하며 견갑하근을 신장한다. 치료사 손 아래에서 조직의 긴장이 증가하는 것을 확인한다. 최대 내회전 위치에서 2–3초 유지 후 시작 자세로 복귀한다."},{"step":4,"instruction":"반복 및 접촉 위치 이동 단계: 1회 완료 후 시작 자세로 복귀한다. 2–3회 반복 후 접촉 위치를 1–2cm씩 이동하며 견갑하근 전체 주행 경로를 탐색한다. 상부 섬유와 하부 섬유의 주행 방향이 다름을 고려하여 접촉 각도를 조정한다."},{"step":5,"instruction":"이상 반응 확인 및 재평가 단계: 시술 중 강한 찌릿한 신경 증상(액와신경 자극 가능성)이 발생하면 위치를 조정한다. 시술 후 어깨 외회전 ROM 및 어깨 앞쪽 통증 NRS를 재측정한다. 팔을 머리 위로 올리기 시 불편감 변화를 확인한다."}]'::jsonb,
  '{"tissue_release","rom_improvement","pain_relief"}',
  '{"subacute","chronic"}',
  '{"external_rotation_restriction","frozen_shoulder","anterior_shoulder_pain"}',
  '{"fracture","malignancy","acute_inflammation","lymph_node_enlargement"}',
  'level_4'::evidence_level,
  '견갑하근 ART는 외회전 제한이 심한 경우(유착성 관절낭염 포함)에서 도움이 될 수 있다. 액와 접근은 치료사의 해부학 숙지 필수',
  'fracture, malignancy, active_axillary_infection',
  'lymphadenopathy, acute_inflammation, anticoagulant_therapy',
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

-- ============================================================
-- [9] 소흉근 능동적 이완기법
-- ============================================================
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
  'ART — 견갑 전방',
  '소흉근 능동적 이완기법', 'Pectoralis Minor Active Release Technique', 'ART-PecMin',
  'shoulder'::body_region, '소흉근(제3–5늑골 ~ 오구돌기)',
  '바로 눕기',
  '환자 환측 옆, 소흉근 근복에 접촉 압박 유지',
  '제3–4늑골 수준 소흉근 근복 (손가락 끝)',
  '접촉 유지하며 팔을 내전에서 외전 + 외회전 방향으로 능동 이동',
  '[{"step":1,"instruction":"촉진 및 목표 구간 확인 단계: 환자를 바로 눕힌다. 치료사는 환측 옆에 서서 대흉근 내측 경계를 따라 손가락 끝을 심층으로 밀어 소흉근 근복을 촉진한다. 제3–4늑골 수준에서 단단한 경결 또는 압통이 강한 구간을 확인한다. 오구돌기 직하방 부착부의 압통도 확인한다."},{"step":2,"instruction":"접촉 고정 단계: 목표 구간에 손가락 끝을 밀착시키고 서서히 깊이를 증가시켜 소흉근 근복에 접촉한다. 환자에게 팔을 옆구리에 붙이고 약간 안쪽으로 돌린 자세(내전+내회전)를 취하도록 한다. 통증 NRS 기준점을 확인한다."},{"step":3,"instruction":"능동 이완 시행 단계: 접촉 압박을 유지한 상태에서 환자에게 팔을 천천히 바깥쪽으로 벌리고 동시에 바깥쪽으로 돌리도록(외전+외회전) 지시한다. 5–8초에 걸쳐 천천히 이동하며 소흉근을 신장한다. 치료사 손 아래에서 조직의 긴장이 증가하는 것을 확인한다. 최대 외전+외회전 위치에서 2–3초 유지 후 시작 자세로 복귀한다."},{"step":4,"instruction":"반복 및 접촉 위치 이동 단계: 1회 완료 후 시작 자세로 복귀한다. 2–3회 반복 후 접촉 위치를 1–2cm씩 이동하며 소흉근 전체 주행 경로(제3–5늑골 부착부 ~ 오구돌기)를 탐색한다. 오구돌기 부착부는 별도로 집중 탐색한다."},{"step":5,"instruction":"이상 반응 확인 및 재평가 단계: 시술 중 팔이나 손가락으로 퍼지는 저림 증상이 발생하면 위치를 조정한다(쇄골하혈관·상완신경총 인접). 시술 후 어깨 굴곡 ROM 및 견갑골 전방 경사 변화를 확인한다. 전흉부 긴장감 NRS를 재측정한다."}]'::jsonb,
  '{"tissue_release","scapular_mobility","postural_correction"}',
  '{"subacute","chronic"}',
  '{"anterior_chest_tightness","scapular_dyskinesis","shoulder_impingement"}',
  '{"rib_fracture","malignancy","acute_inflammation","thrombosis"}',
  'level_4'::evidence_level,
  '소흉근 ART는 단축된 소흉근의 오구돌기 부착부 긴장 해소에 효과적일 수 있다. 흉근 단축으로 인한 견갑골 전방 경사 교정의 보조적 치료로 활용될 수 있음',
  'rib_fracture, malignancy, deep_vein_thrombosis',
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

-- ============================================================
-- [10] 삼두근 장두 능동적 이완기법
-- ============================================================
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
  'ART — 견관절 후방',
  '삼두근 장두 능동적 이완기법', 'Triceps Long Head Active Release Technique', 'ART-TricepsLH',
  'shoulder'::body_region, '삼두근 장두(견갑골 관절하결절 ~ 팔꿈치 주두)',
  '앉은 자세 또는 옆으로 눕기(환측 위)',
  '환자 뒤쪽 또는 옆쪽, 후방 상완 삼두근 장두 근복 접촉',
  '후방 상완 삼두근 장두 근복 (엄지 또는 손가락 끝)',
  '접촉 유지하며 팔꿈치를 펴기(신전)에서 굽히기(굴곡)로 능동 이동',
  '[{"step":1,"instruction":"촉진 및 목표 구간 확인 단계: 환자를 앉은 자세 또는 환측이 위가 되도록 옆으로 눕힌다. 치료사는 환자 뒤쪽 또는 옆쪽에 위치하여 후방 상완부 삼두근 장두 주행 경로(견갑골 관절하결절에서 팔꿈치 주두 방향)를 따라 엄지 또는 손가락 끝으로 촉진한다. 단단한 경결 또는 압통이 강한 구간(주로 근복 중간~상부)을 확인한다."},{"step":2,"instruction":"접촉 고정 단계: 목표 구간에 엄지 또는 손가락 끝을 밀착시키고 서서히 깊이를 증가시켜 삼두근 장두 근복에 접촉한다. 환자에게 팔꿈치를 완전히 펴도록(신전) 한다. 통증 NRS 기준점을 확인한다."},{"step":3,"instruction":"능동 이완 시행 단계: 접촉 압박을 유지한 상태에서 환자에게 팔꿈치를 천천히 굽히도록(굴곡) 지시한다. 5–8초에 걸쳐 천천히 이동하며 삼두근 장두를 신장한다. 치료사 손 아래에서 조직의 긴장이 증가하는 것을 확인한다. 최대 굴곡 위치에서 2–3초 유지 후 시작 자세(팔꿈치 펴기)로 복귀한다."},{"step":4,"instruction":"반복 및 접촉 위치 이동 단계: 1회 완료 후 시작 자세로 복귀한다. 2–3회 반복 후 접촉 위치를 1–2cm씩 이동하며 삼두근 장두 전체 주행 경로를 탐색한다. 어깨 굴곡을 동시에 추가(팔을 앞으로 들어올리면서 팔꿈치 굴곡)하면 견갑골 관절하결절 부착부까지 장두 전체를 더 충분히 신장할 수 있다."},{"step":5,"instruction":"이상 반응 확인 및 재평가 단계: 시술 중 강한 찌릿한 신경 증상이 발생하면 위치를 조정한다(요골신경 인접 구간 주의). 시술 후 어깨 굴곡 마지막 범위 ROM 및 후방 상완 통증 NRS를 재측정한다. 팔을 머리 위로 완전히 올리기 시 불편감 변화를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"posterior_arm_pain","shoulder_flexion_restriction","overhead_difficulty"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '삼두근 장두 ART는 어깨 굴곡 마지막 범위 제한 및 후방 상완 통증의 원인이 될 수 있는 근막 유착 해소에 도움이 될 수 있다',
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
-- Migration 019 (Part 3): Shoulder — CTM + DFM + TrP (13 techniques)
-- sw-db-architect | 2026-04-28
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql

-- ============================================================
-- SECTION 5: category_ctm — CTM 결합조직 마사지 (3 techniques)
-- evidence_level = 'level_4'
-- ============================================================

-- [1] CTM-Periscap
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
  'CTM — 견갑 주변',
  '견갑골 주변 결합조직 마사지', 'Periscapular Connective Tissue Massage', 'CTM-Periscap',
  'shoulder'::body_region, '견갑골 내측연·상각·하각 주변 피하결합조직',
  '앉은 자세 또는 엎드려 눕기',
  '환자 뒤쪽, 견갑골 주변 결합조직 전반 접촉',
  '견갑골 내측연·상각·하각 주변 피하결합조직 (손가락 끝 또는 엄지 긁기 기법)',
  '피부-결합조직층을 견갑골 경계선을 따라 섬유 방향으로 긁기 (Picking-up / Rolling)',
  '[{"step":1,"instruction":"환자를 앉은 자세 또는 엎드려 눕기 자세로 준비하고 어깨와 등 상부를 충분히 노출한다. 견갑골 경계(내측연·상각·하각)를 촉진하여 위치를 확인한다."},{"step":2,"instruction":"손가락 끝 또는 엄지로 견갑골 내측연 주변 피하결합조직에 가볍게 접촉한 후 피부를 들어올리듯 긁기(picking-up) 기법을 적용한다. 압통 부위와 조직 저항이 높은 부위를 탐색한다."},{"step":3,"instruction":"견갑골 내측연 상단에서 하각 방향으로 천천히 이동하면서 피하결합조직층을 지속적으로 자극한다. 조직 저항이 느껴지면 그 위치에서 몇 초간 멈추며 이완을 유도한다."},{"step":4,"instruction":"내측연 작업 완료 후 견갑골 상각(superior angle) 주변으로 이동하여 동일한 긁기 기법을 적용한다. 이어서 견갑골 하각(inferior angle) 주변도 같은 방식으로 처치한다."},{"step":5,"instruction":"시술 후 어깨와 견갑 주변 움직임(팔 들어올리기, 어깨 돌리기)을 재평가하여 조직 긴장 변화 및 통증 감소 여부를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","circulation_improvement"}',
  '{"subacute","chronic"}',
  '{"periscapular_pain","shoulder_stiffness","muscle_tension"}',
  '{"fracture","malignancy","skin_infection","acute_inflammation"}',
  'level_4'::evidence_level,
  '견갑 주변 결합조직 마사지는 견갑 주변 근육 긴장 완화와 국소 순환 개선에 도움이 될 수 있다. 오랜 시간 앉아서 일하는 환자의 어깨 결림에 자주 활용됨',
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

-- [2] CTM-ShAnterior
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
  'CTM — 견관절 전방',
  '견관절 전방 결합조직 마사지', 'Anterior Shoulder Connective Tissue Massage', 'CTM-ShAnterior',
  'shoulder'::body_region, '전방 삼각근·흉근·쇄골하근 피하결합조직',
  '바로 눕기 또는 앉은 자세',
  '환자 환측 옆 또는 앞쪽, 전방 어깨 결합조직 접촉',
  '전방 삼각근·흉근 접합부 피하결합조직 (손가락 끝 긁기 기법)',
  '피하결합조직층을 전방 어깨 윤곽을 따라 섬유 방향으로 긁기',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 앉은 자세로 준비하고 전방 어깨 부위(전방 삼각근, 흉근 구역, 쇄골하 구역)를 노출한다. 압통점 및 조직 긴장이 높은 구역을 촉진으로 먼저 탐색한다."},{"step":2,"instruction":"손가락 끝으로 전방 삼각근 구역 피하결합조직에 가볍게 접촉하여 긁기(picking-up) 기법을 적용한다. 조직 저항이 느껴지는 부위에서 멈추며 이완을 유도한다."},{"step":3,"instruction":"전방 삼각근과 흉근 접합부를 따라 이동하면서 연속적으로 피하결합조직층을 자극한다. 흉근 외측 경계까지 탐색 범위를 확장한다."},{"step":4,"instruction":"쇄골하 구역(쇄골하근 주변 피하결합조직)으로 이동하여 동일한 긁기 기법을 적용한다. 단, 쇄골하혈관 인근이므로 깊은 압박은 피하고 피하층 수준에서만 작업한다."},{"step":5,"instruction":"시술 후 팔 들어올리기 및 어깨 전방 굴곡 동작을 재평가하여 전방 어깨 조직 긴장 변화와 통증 감소 여부를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","postural_correction"}',
  '{"subacute","chronic"}',
  '{"anterior_shoulder_pain","chest_tightness","shoulder_stiffness"}',
  '{"fracture","malignancy","skin_infection","acute_inflammation"}',
  'level_4'::evidence_level,
  '전방 어깨 결합조직 마사지는 흉근 및 전방 삼각근 구역의 조직 긴장 완화에 도움이 될 수 있다. 구부정한 자세(전방 머리 자세)와 연관된 전방 어깨 통증에서 자주 활용됨',
  'fracture, malignancy, skin_infection_in_area',
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

-- [3] CTM-ShPosterior
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
  'CTM — 견관절 후방',
  '견관절 후방 결합조직 마사지', 'Posterior Shoulder Connective Tissue Massage', 'CTM-ShPosterior',
  'shoulder'::body_region, '후방 삼각근·극하근·소원근 피하결합조직',
  '옆으로 눕기(환측 위) 또는 앉은 자세',
  '환자 뒤쪽, 후방 어깨 결합조직 접촉',
  '후방 삼각근·극하근·소원근 피하결합조직 (손가락 끝 긁기 기법)',
  '피하결합조직층을 후방 어깨 윤곽을 따라 섬유 방향으로 긁기',
  '[{"step":1,"instruction":"환자를 옆으로 눕기(환측 위) 또는 앉은 자세로 준비하고 후방 어깨 부위(후방 삼각근, 극하근, 소원근 구역)를 노출한다. 압통점 및 조직 긴장이 높은 구역을 촉진으로 먼저 탐색한다."},{"step":2,"instruction":"손가락 끝으로 후방 삼각근 구역 피하결합조직에 가볍게 접촉하여 긁기(picking-up) 기법을 적용한다. 조직 저항이 느껴지는 부위에서 멈추며 이완을 유도한다."},{"step":3,"instruction":"후방 삼각근에서 극하근 구역으로 이동하면서 연속적으로 피하결합조직층을 자극한다. 극하와(infraspinous fossa) 전체 범위를 탐색한다."},{"step":4,"instruction":"견갑골 외측연 하부의 소원근 구역으로 이동하여 동일한 긁기 기법을 적용한다. 겨드랑이(액와) 후방 주름 직상방까지 탐색 범위를 확장할 수 있다."},{"step":5,"instruction":"시술 후 팔 내회전 동작 및 수평 내전(팔을 가슴 앞으로 가져가기) 동작을 재평가하여 후방 어깨 조직 긴장 변화와 통증 감소 여부를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"posterior_shoulder_pain","sleep_pain","internal_rotation_restriction"}',
  '{"fracture","malignancy","skin_infection","acute_inflammation"}',
  'level_4'::evidence_level,
  '후방 어깨 결합조직 마사지는 후방 어깨 통증 완화와 내회전 범위 회복에 도움이 될 수 있다. 수면 시 환측 어깨 통증을 호소하는 환자에서 보조적 치료로 활용될 수 있음',
  'fracture, malignancy, skin_infection_in_area',
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

-- ============================================================
-- SECTION 6: category_deep_friction — 심부마찰 마사지 (4 techniques)
-- evidence_level = 'level_3'
-- ============================================================

-- [4] DFM-SupraTend
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
  'DFM — 회전근개건',
  '극상근건 심부마찰 마사지', 'Supraspinatus Tendon Deep Friction Massage', 'DFM-SupraTend',
  'shoulder'::body_region, '극상근건 부착부(상완골 대결절 직상방, 견봉 직하방)',
  '앉은 자세, 팔 몸통 뒤쪽으로 살짝 가져가 극상근건 노출 (어깨 내회전·신전 위치)',
  '환자 앞쪽 또는 옆쪽, 검지·중지로 견봉 전방 하방 접촉',
  '극상근건 부착부 (견봉 직하방 ~ 대결절 상방, 검지·중지 중첩)',
  '건 주행 방향에 수직으로 횡마찰 (Transverse friction)',
  '[{"step":1,"instruction":"환자를 앉은 자세로 준비하고 치료 측 팔을 등 뒤로 살짝 가져가(어깨 내회전·신전) 극상근건이 견봉 전방으로 노출되도록 유도한다. 견봉 전방 하방 경계를 촉진으로 확인한다."},{"step":2,"instruction":"검지·중지를 중첩하여 견봉 직하방에서 대결절 상방 사이의 극상근건 부착부에 접촉한다. 건 주행 방향을 확인하고, 이와 수직인 횡마찰 방향을 설정한다."},{"step":3,"instruction":"피부와 함께 검지·중지를 건 주행과 수직 방향으로 짧고 빠르게 내-외측으로 왕복 마찰한다. 압력은 건 표면에 전달될 정도로 충분히 유지하되 무력감 호소 시 즉시 감압한다. 1회 세트 2~3분 지속한다."},{"step":4,"instruction":"마찰 중 환자의 통증 반응을 지속적으로 확인한다. NRS 4~5 수준의 ''시원하게 아픈'' 느낌이 적절하며, NRS 6 이상이면 압력을 줄인다. 1세트 완료 후 30초 휴식 후 1~2세트 추가 적용한다."},{"step":5,"instruction":"시술 후 팔 외전 동작(팔 옆으로 들어올리기)을 재평가하여 통증 호arc 범위 변화와 통증 강도 감소 여부를 확인한다."}]'::jsonb,
  '{"tendon_rehabilitation","pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"supraspinatus_tendinopathy","shoulder_pain","abduction_restriction"}',
  '{"fracture","malignancy","acute_bursitis","calcific_tendinitis_acute"}',
  'level_3'::evidence_level,
  '극상근건 심부마찰은 건 조직의 교원질 재배열과 국소 혈류 촉진에 도움이 될 수 있다. Cyriax 마찰 마사지는 건병증의 보존적 치료 옵션으로 임상에서 활용될 수 있으나 증거 수준은 제한적',
  'fracture, malignancy, active_bursitis_acute',
  'calcific_tendinitis, acute_inflammation, anticoagulant_therapy',
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

-- [5] DFM-BicepsTend
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
  'DFM — 이두박근건',
  '이두박근 장두건 심부마찰 마사지', 'Biceps Long Head Tendon Deep Friction Massage', 'DFM-BicepsTend',
  'shoulder'::body_region, '결절간구(이두박근건구) 내 이두박근 장두건',
  '앉은 자세, 팔 내회전시켜 결절간구 전면 노출',
  '환자 앞쪽, 검지·중지로 결절간구 위 이두건 접촉',
  '결절간구 내 이두박근 장두건 (검지·중지 중첩)',
  '건 주행 방향(세로)에 수직으로 횡마찰',
  '[{"step":1,"instruction":"환자를 앉은 자세로 준비하고 치료 측 팔을 내회전시켜 결절간구(intertubercular groove)가 전방으로 노출되도록 유도한다. 대결절과 소결절 사이 결절간구 위치를 촉진으로 확인한다."},{"step":2,"instruction":"검지·중지를 중첩하여 결절간구 내 이두박근 장두건에 접촉한다. 건 주행 방향(세로)을 확인하고 이와 수직인 횡마찰 방향을 설정한다."},{"step":3,"instruction":"피부와 함께 검지·중지를 건 주행과 수직 방향(내-외측)으로 짧고 빠르게 왕복 마찰한다. 압력은 결절간구 내 건 표면에 전달될 정도로 유지한다. 1회 세트 2~3분 지속한다."},{"step":4,"instruction":"마찰 중 환자의 통증 반응을 지속적으로 확인한다. NRS 4~5 수준의 ''시원하게 아픈'' 느낌이 적절하며 NRS 6 이상이면 압력을 줄인다. 1세트 완료 후 30초 휴식 후 1~2세트 추가 적용한다."},{"step":5,"instruction":"시술 후 팔 굴곡(팔 앞으로 들어올리기) 및 Speed test 재평가하여 전방 어깨 통증 강도 변화 여부를 확인한다."}]'::jsonb,
  '{"tendon_rehabilitation","pain_relief"}',
  '{"subacute","chronic"}',
  '{"biceps_tendinopathy","anterior_shoulder_pain","overhead_pain"}',
  '{"fracture","malignancy","biceps_rupture","acute_inflammation"}',
  'level_3'::evidence_level,
  '이두박근 장두건 마찰은 건구 내 건 미끄러짐 개선과 국소 통증 감소에 도움이 될 수 있다. Speed test 양성 및 결절간구 압통이 있는 환자에서 보조적 치료로 고려될 수 있음',
  'fracture, malignancy, biceps_complete_rupture',
  'acute_tenosynovitis, anticoagulant_therapy',
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

-- [6] DFM-Subacromial
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
  'DFM — 점액낭',
  '견봉하 점액낭 주변 심부마찰 마사지', 'Subacromial Region Deep Friction Massage', 'DFM-Subacromial',
  'shoulder'::body_region, '견봉하 공간(견봉 하방 ~ 극상근건 상방)',
  '앉은 자세, 팔 몸통 뒤쪽으로 살짝 가져가 견봉하 공간 노출',
  '환자 앞쪽, 엄지 또는 검지로 견봉 전방 하방 경계 접촉',
  '견봉 전방 하방 경계 (견봉하 공간 입구)',
  '견봉 전하방에서 수직 압박 + 소범위 횡마찰',
  '[{"step":1,"instruction":"환자를 앉은 자세로 준비하고 치료 측 팔을 등 뒤로 살짝 가져가(어깨 내회전·신전) 견봉하 공간을 전방으로 노출시킨다. 견봉 전하방 경계를 촉진으로 확인한다."},{"step":2,"instruction":"엄지 또는 검지 끝으로 견봉 전방 하방 경계에 접촉하여 견봉하 공간 입구 위치를 확인한다. 조직 저항 및 압통 위치를 탐색한다."},{"step":3,"instruction":"접촉점에서 수직 방향으로 가볍게 압박을 가하면서 소범위 횡마찰을 적용한다. 단, 급성 점액낭염이 아닌 만성 상태에서만 시행하며, 조직 저항이 느껴지는 범위 내에서만 마찰 범위를 유지한다."},{"step":4,"instruction":"마찰 중 환자의 통증 반응을 지속적으로 확인한다. NRS 4~5 수준의 ''시원하게 아픈'' 느낌이 적절하며 NRS 6 이상이면 압력을 줄인다. 1세트 2분 후 30초 휴식 후 1~2세트 추가 적용한다."},{"step":5,"instruction":"시술 후 팔 외전 및 전방 굴곡 동작을 재평가하여 견봉하 통증 호arc 범위 변화와 통증 강도 감소 여부를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief"}',
  '{"subacute","chronic"}',
  '{"shoulder_impingement","subacromial_pain","overhead_difficulty"}',
  '{"acute_bursitis","fracture","malignancy","acute_inflammation"}',
  'level_3'::evidence_level,
  '견봉하 구역 마찰은 견봉하 조직 유착 완화와 통증 감소에 도움이 될 수 있다. 만성 충돌증후군 환자에서 운동치료와 병행 시 효과적일 수 있음. 급성 점액낭염은 절대 금기',
  'acute_bursitis, fracture, malignancy',
  'calcific_tendinitis_acute, anticoagulant_therapy',
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

-- [7] DFM-ACJCap
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
  'DFM — ACJ',
  '견봉쇄골관절 관절낭 심부마찰 마사지', 'ACJ Capsule Deep Friction Massage', 'DFM-ACJCap',
  'shoulder'::body_region, 'ACJ 상방·전방 관절낭 인대',
  '앉은 자세',
  '환자 뒤쪽, 엄지 끝으로 ACJ 상방·전방 접촉',
  'ACJ 관절선 상방 및 전방 관절낭 (엄지 끝)',
  '관절선에 수직 횡마찰',
  '[{"step":1,"instruction":"환자를 앉은 자세로 준비하고 ACJ(견봉쇄골관절) 위치를 촉진으로 확인한다. 쇄골 외측 끝에서 견봉 내측 경계 사이의 관절선을 탐색하고 압통점 위치를 파악한다."},{"step":2,"instruction":"엄지 끝을 ACJ 관절선 상방 및 전방 관절낭에 접촉한다. 관절선 주행 방향을 확인하고 이와 수직인 횡마찰 방향을 설정한다."},{"step":3,"instruction":"엄지 끝으로 관절선에 수직 방향으로 짧고 빠르게 왕복 마찰한다. 압력은 관절낭 표면에 전달될 정도로 유지한다. 1회 세트 2~3분 지속한다."},{"step":4,"instruction":"마찰 중 환자의 통증 반응을 지속적으로 확인한다. NRS 4~5 수준이 적절하며 NRS 6 이상이면 압력을 줄인다. 1세트 완료 후 30초 휴식 후 1~2세트 추가 적용한다."},{"step":5,"instruction":"시술 후 팔 수평 내전(팔을 가슴 앞으로 가져가기) 및 어깨 끝 범위 거상 동작을 재평가하여 ACJ 주변 통증 강도 변화 여부를 확인한다."}]'::jsonb,
  '{"tendon_rehabilitation","pain_relief","joint_mobility"}',
  '{"subacute","chronic"}',
  '{"acj_pain","superior_shoulder_pain","end_range_pain"}',
  '{"acute_acj_separation","fracture","malignancy","acute_inflammation"}',
  'level_3'::evidence_level,
  'ACJ 관절낭 마찰은 만성 ACJ 기능장애에서 관절낭 인대 유착 감소와 국소 통증 완화에 도움이 될 수 있다. Grade I–II AC 분리 후 만성 통증 단계에서 고려될 수 있음',
  'acute_ACJ_separation_grade3plus, fracture, malignancy',
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

-- ============================================================
-- SECTION 7: category_trigger_point — 트리거포인트 이완 (6 techniques)
-- evidence_level = 'level_4'
-- ============================================================

-- [8] SH-TrP-Supra
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
  'TrP — 회전근개',
  '극상근 트리거포인트 이완', 'Supraspinatus Trigger Point Release', 'SH-TrP-Supra',
  'shoulder'::body_region, '극상와 내 극상근 근복 (연관통: 어깨 외측 ~ 상완 외측 ~ 전완)',
  '앉은 자세 또는 엎드려 눕기',
  '환자 뒤쪽, 극상와 내 압통점 촉진',
  '극상와 내 극상근 근복 (엄지 또는 검지·중지)',
  '압통점에 수직 지속 압박 (Ischemic compression) 후 이완',
  '[{"step":1,"instruction":"환자를 앉은 자세 또는 엎드려 눕기 자세로 준비한다. 극상와(supraspinous fossa) 내 극상근 근복을 촉진하여 경결(taut band) 및 압통점을 탐색한다. 전형적 위치는 극상와 중앙 ~ 외측 1/3 구간이다."},{"step":2,"instruction":"엄지 또는 검지·중지로 목표 압통점에 수직 방향 압박을 서서히 가한다. 환자에게 어깨 외측 ~ 상완 외측으로 퍼지는 연관통 재현 여부를 확인한다. NRS 기준점을 확인한다."},{"step":3,"instruction":"압통점에 NRS 4~5 수준의 압박을 유지하며 지속 압박(ischemic compression)을 적용한다. 30~90초 압박을 유지하면서 환자가 통증 감소(NRS 2 이하)를 느낄 때까지 기다린다."},{"step":4,"instruction":"압통 경감이 확인되면 압박을 서서히 해제한다. 동일 부위 주변의 다른 압통점을 탐색하여 2~3회 반복 적용한다. 시술 측 총 처치 시간은 5~10분을 넘지 않도록 한다."},{"step":5,"instruction":"시술 후 팔 외전 및 전방 굴곡 ROM을 재평가하고 어깨 외측 연관통 강도 변화를 확인한다. 운동 병행 시 회전근개 강화 운동을 이후 세션에 도입하는 것을 고려할 수 있다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","referred_pain_arm","rotator_cuff_dysfunction"}',
  '{"fracture","malignancy","acute_inflammation","coagulation_disorder"}',
  'level_4'::evidence_level,
  '극상근 트리거포인트는 어깨 측면과 팔 바깥쪽으로 퍼지는 연관통을 유발할 수 있다. 회전근개 병증 및 오십견에서 빈번히 동반되며 근막통증증후군의 주요 원인이 될 수 있음',
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

-- [9] SH-TrP-Infra
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
  'TrP — 회전근개',
  '극하근 트리거포인트 이완', 'Infraspinatus Trigger Point Release', 'SH-TrP-Infra',
  'shoulder'::body_region, '극하와 상부·외측 극하근 근복 (연관통: 어깨 전방·외측 ~ 상완 외측)',
  '옆으로 눕기(환측 위) 또는 앉은 자세',
  '환자 뒤쪽, 극하와 내 압통점 촉진',
  '극하와 상부·외측 극하근 근복 (엄지 또는 검지·중지)',
  '압통점에 수직 지속 압박 (Ischemic compression) 후 이완',
  '[{"step":1,"instruction":"환자를 옆으로 눕기(환측 위) 또는 앉은 자세로 준비한다. 극하와(infraspinous fossa) 상부 및 외측 극하근 근복을 촉진하여 경결(taut band) 및 압통점을 탐색한다. 전형적 위치는 극상와와 극하와 경계선 하방 ~ 견갑골 외측연 방향이다."},{"step":2,"instruction":"엄지 또는 검지·중지로 목표 압통점에 수직 방향 압박을 서서히 가한다. 환자에게 어깨 전방 및 외측, 상완 외측으로 퍼지는 심부 연관통 재현 여부를 확인한다. NRS 기준점을 확인한다."},{"step":3,"instruction":"압통점에 NRS 4~5 수준의 압박을 유지하며 지속 압박(ischemic compression)을 적용한다. 30~90초 압박을 유지하면서 환자가 통증 감소(NRS 2 이하)를 느낄 때까지 기다린다."},{"step":4,"instruction":"압통 경감이 확인되면 압박을 서서히 해제한다. 동일 부위 주변의 다른 압통점을 탐색하여 2~3회 반복 적용한다. 시술 측 총 처치 시간은 5~10분을 넘지 않도록 한다."},{"step":5,"instruction":"시술 후 어깨 외회전 ROM 및 수평 내전 동작을 재평가하고 전방·외측 어깨 연관통 강도 변화를 확인한다. 야간 통증 패턴 변화 여부를 다음 방문 시 추적한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"posterior_shoulder_pain","anterior_shoulder_pain","external_rotation_restriction"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '극하근 트리거포인트는 어깨 앞쪽과 팔 바깥쪽으로 퍼지는 심부 연관통을 유발할 수 있다. 야간 어깨 통증과 외회전 제한의 잦은 원인 중 하나',
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

-- [10] SH-TrP-TMin
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
  'TrP — 회전근개',
  '소원근 트리거포인트 이완', 'Teres Minor Trigger Point Release', 'SH-TrP-TMin',
  'shoulder'::body_region, '견갑골 외측연 하부 소원근 근복 (연관통: 삼각근 후방 부위)',
  '옆으로 눕기(환측 위) 또는 앉은 자세',
  '환자 뒤쪽, 견갑골 외측연 하부 소원근 근복 촉진',
  '견갑골 외측연 하부 소원근 근복 (엄지 끝)',
  '압통점에 수직 지속 압박 (Ischemic compression) 후 이완',
  '[{"step":1,"instruction":"환자를 옆으로 눕기(환측 위) 또는 앉은 자세로 준비한다. 견갑골 외측연 하부를 촉진하여 소원근(teres minor) 근복을 탐색한다. 극하근 하방, 대원근(teres major) 상방에 위치하며 견갑골 외측연 근처에서 압통점을 탐색한다."},{"step":2,"instruction":"엄지 끝으로 목표 압통점에 수직 방향 압박을 서서히 가한다. 환자에게 삼각근 후방 부위로 국소 퍼지는 연관통 재현 여부를 확인한다. NRS 기준점을 확인한다."},{"step":3,"instruction":"압통점에 NRS 4~5 수준의 압박을 유지하며 지속 압박(ischemic compression)을 적용한다. 30~90초 압박을 유지하면서 환자가 통증 감소(NRS 2 이하)를 느낄 때까지 기다린다."},{"step":4,"instruction":"압통 경감이 확인되면 압박을 서서히 해제한다. 극하근 트리거포인트와 함께 발생하는 경우가 많으므로 극하와 구역도 연속 평가한다. 시술 측 총 처치 시간은 5~10분을 넘지 않도록 한다."},{"step":5,"instruction":"시술 후 어깨 외회전 ROM 및 삼각근 후방 압통 변화를 재평가한다. 극하근 트리거포인트 치료와 병행하면 더 효과적일 수 있음을 다음 세션 계획에 반영한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"posterior_shoulder_pain","deltoid_area_pain"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '소원근 트리거포인트는 삼각근 후방 부위로 국소 연관통을 나타낼 수 있다. 극하근 트리거포인트와 함께 발생하는 경우가 많아 두 근육을 함께 평가하는 것이 유리할 수 있음',
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

-- [11] SH-TrP-Sub
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
  'TrP — 회전근개',
  '견갑하근 트리거포인트 이완', 'Subscapularis Trigger Point Release', 'SH-TrP-Sub',
  'shoulder'::body_region, '견갑하와 내 견갑하근 근복 (연관통: 어깨 후방·상완 내측·손목 내측)',
  '바로 눕기, 팔 약간 바깥쪽으로 벌린 위치',
  '환자 환측 옆, 액와 공간을 통해 견갑하와 접근',
  '액와 공간을 통한 견갑하근 근복 (손가락 끝)',
  '액와 공간 후방벽을 통해 견갑하와 방향으로 수직 압박',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 준비하고 치료 측 팔을 약 30~45° 외전시켜 액와(axilla) 공간을 확보한다. 치료사는 환자 환측 옆에 위치한다. 겨드랑이 후방벽을 통해 견갑하와 방향으로 접근할 준비를 한다."},{"step":2,"instruction":"손가락 끝(2~4지)으로 액와 후방벽을 따라 견갑하와(subscapular fossa) 방향으로 조심스럽게 접근한다. 액와 혈관·신경(brachial plexus) 위치에 주의하여 정중 액와선 후방에서 접근한다. 견갑하근 근복에서 압통점을 탐색한다."},{"step":3,"instruction":"목표 압통점에 수직 방향 압박을 서서히 가한다. 환자에게 어깨 후방 및 상완 내측으로 퍼지는 연관통 재현 여부를 확인한다. NRS 4~5 수준을 유지하며 30~90초 지속 압박을 적용한다."},{"step":4,"instruction":"압통 경감이 확인되면 압박을 서서히 해제한다. 견갑하근은 범위가 넓으므로 상부(견갑골 상각 근처)와 중간부를 구분하여 2~3곳의 압통점을 순차적으로 처치한다. 시술 측 총 처치 시간은 5~10분을 넘지 않도록 한다."},{"step":5,"instruction":"시술 후 어깨 외회전 ROM을 재평가하고 오십견 환자의 경우 외회전 범위 변화를 특히 주의하여 기록한다. 견갑하근 스트레칭(외회전 수동 신장) 운동을 이후 세션에 병행하는 것을 고려할 수 있다."}]'::jsonb,
  '{"pain_relief","trigger_point_release","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"external_rotation_restriction","posterior_shoulder_pain","frozen_shoulder"}',
  '{"fracture","malignancy","acute_inflammation","lymph_node_enlargement"}',
  'level_4'::evidence_level,
  '견갑하근 트리거포인트는 어깨 뒤쪽과 팔 안쪽으로 퍼지는 연관통을 유발할 수 있다. 유착성 관절낭염의 외회전 제한과 강하게 연관될 수 있어 오십견 치료 시 반드시 평가 권고',
  'fracture, malignancy, active_axillary_infection',
  'lymphadenopathy, acute_inflammation, anticoagulant_therapy',
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

-- [12] SH-TrP-PecMin
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
  'TrP — 전방 흉근',
  '소흉근 트리거포인트 이완', 'Pectoralis Minor Trigger Point Release', 'SH-TrP-PecMin',
  'shoulder'::body_region, '소흉근 중간 근복(제3–4늑골 수준) (연관통: 전방 흉부·상완 내측·4·5번 손가락)',
  '바로 눕기',
  '환자 환측 옆, 흉근 구역 소흉근 압통점 촉진',
  '제3–4늑골 수준 소흉근 근복 (손가락 끝 또는 엄지)',
  '소흉근 주행 방향(쇄골오훼돌기-늑골)에 수직 압박 또는 지속 압박',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 준비하고 치료 측 팔을 약 30° 외전시켜 흉근 구역을 이완시킨다. 대흉근 내측 경계에서 안쪽으로 소흉근 위치(제3~5늑골에서 쇄골오훼돌기 방향)를 촉진으로 확인한다."},{"step":2,"instruction":"손가락 끝 또는 엄지로 대흉근을 통해 소흉근 근복(제3~4늑골 수준)에 도달한다. 압통점을 탐색하며 NRS 기준점을 확인한다. 환자에게 전방 흉부 및 팔 안쪽, 4·5번째 손가락으로 퍼지는 연관통 재현 여부를 확인한다."},{"step":3,"instruction":"목표 압통점에 NRS 4~5 수준의 압박을 유지하며 지속 압박(ischemic compression)을 적용한다. 30~90초 압박을 유지하면서 환자가 통증 감소(NRS 2 이하)를 느낄 때까지 기다린다."},{"step":4,"instruction":"압통 경감이 확인되면 압박을 서서히 해제한다. 소흉근 상부(제3늑골 수준)와 하부(제5늑골 수준)를 각각 탐색하여 2~3곳의 압통점을 순차적으로 처치한다. 시술 측 총 처치 시간은 5~10분을 넘지 않도록 한다."},{"step":5,"instruction":"시술 후 어깨 후방 당김 동작(양팔 뒤로 당기기) 및 팔 외전 ROM을 재평가하고 흉곽출구 증상과 유사한 팔 저림 변화를 확인한다. 흉곽출구증후군 감별을 위해 EAST test 등 특수검사 결과도 재평가에 포함한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"anterior_chest_pain","arm_inner_pain","finger_numbness_4_5"}',
  '{"rib_fracture","malignancy","acute_inflammation","thrombosis"}',
  'level_4'::evidence_level,
  '소흉근 트리거포인트는 가슴 앞쪽과 팔 안쪽, 4·5번째 손가락으로 퍼지는 연관통을 유발할 수 있다. 흉곽출구증후군 증상과 유사할 수 있어 감별진단이 필요함',
  'rib_fracture, malignancy, deep_vein_thrombosis',
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

-- [13] SH-TrP-Delt
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
  'TrP — 삼각근',
  '삼각근 트리거포인트 이완', 'Deltoid Trigger Point Release', 'SH-TrP-Delt',
  'shoulder'::body_region, '전방·중간·후방 삼각근 근복 (연관통: 어깨 외측 전반 국소)',
  '앉은 자세 또는 옆으로 눕기(건측 위)',
  '환자 환측 옆, 삼각근 해당 구획 압통점 촉진',
  '전방·중간·후방 삼각근 근복 각 구획 (엄지 또는 검지·중지)',
  '압통점에 수직 지속 압박 (Ischemic compression) 후 이완',
  '[{"step":1,"instruction":"환자를 앉은 자세 또는 옆으로 눕기(건측 위) 자세로 준비한다. 삼각근을 전방·중간·후방 구획으로 구분하여 각 구획의 근복을 촉진하며 경결(taut band) 및 압통점을 탐색한다."},{"step":2,"instruction":"증상과 관련된 구획(전방: 굴곡·내회전 통증 / 중간: 외전 통증 / 후방: 신전·외회전 통증)을 우선 처치한다. 엄지 또는 검지·중지로 목표 압통점에 수직 방향 압박을 서서히 가한다. 어깨 외측 국소 연관통 재현 여부를 확인하고 NRS 기준점을 확인한다."},{"step":3,"instruction":"압통점에 NRS 4~5 수준의 압박을 유지하며 지속 압박(ischemic compression)을 적용한다. 30~90초 압박을 유지하면서 환자가 통증 감소(NRS 2 이하)를 느낄 때까지 기다린다."},{"step":4,"instruction":"압통 경감이 확인되면 압박을 서서히 해제한다. 각 구획별로 2~3곳의 압통점을 순차적으로 처치한다. 증상이 있는 모든 구획을 탐색하되 시술 측 총 처치 시간은 10~15분을 넘지 않도록 한다."},{"step":5,"instruction":"시술 후 해당 구획과 관련된 동작(외전, 전방 굴곡, 신전)을 재평가하여 동작 통증 강도 변화를 확인한다. 회전근개 강화 운동 또는 어깨 안정화 운동과 병행하는 것을 고려할 수 있다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"lateral_shoulder_pain","movement_pain","overhead_difficulty"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '삼각근 트리거포인트는 어깨 바깥쪽에 국소적인 연관통을 유발할 수 있다. 전방 섬유는 굴곡·내회전 동작, 중간 섬유는 외전 동작, 후방 섬유는 신전·외회전 동작 시 통증을 유발할 수 있음',
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
