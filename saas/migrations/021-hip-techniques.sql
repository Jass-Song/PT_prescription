-- Migration 021: Hip (엉덩 관절) Techniques
-- 엉덩 관절 29개 기법: JM 6 + Mulligan 2 + MFR 5 + ART 4 + CTM 3 + DFM 3 + TrP 6
-- sw-db-architect | 2026-04-28

BEGIN;

-- =============================================================
-- SECTION 1: category_joint_mobilization — 6 techniques
-- =============================================================

-- ────────────────────────────────
-- HIP-JM-TRACT: 엉덩 관절 장축 견인
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
  'Maitland — HJ',
  '엉덩 관절 장축 견인', 'Hip Long-axis Traction', 'HIP-JM-TRACT',
  'hip'::body_region, 'HJ 관절강 전반',
  '바로 눕기, 팔 몸통 옆에 이완',
  '환자 발쪽, 양 손으로 대퇴 원위부 파지',
  '대퇴 원위부 (양 손 파지)',
  '장축 하방 견인 (Distraction)',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 팔이 몸통 옆에서 편안하게 이완되도록 한다. 치료 테이블 위에서 전신이 이완된 상태인지 확인한다."},{"step":2,"instruction":"치료사는 환자 발쪽에 서서 양 손으로 대퇴 원위부(슬개골 직상방 약 5–8 cm)를 확실히 파지한다. 손목과 전완이 견인 방향(장축)에 일직선이 되도록 자세를 잡는다."},{"step":3,"instruction":"Grade I–II 통증 조절 목적 시 관절 저항이 느껴지기 전 범위에서 부드럽고 리드미컬하게 견인을 적용하고 해제를 반복한다. Grade III–IV ROM 개선 목적 시 관절 끝 저항이 느껴지는 범위까지 서서히 견인 강도를 높인다."},{"step":4,"instruction":"장축 방향(환자 머리 반대쪽)으로 리듬감 있게 견인을 가하며 관절 내압 감소와 관절낭 이완을 유도한다. 시술 중 환자의 엉덩이 통증 또는 사타구니 통증의 변화를 지속적으로 확인한다."},{"step":5,"instruction":"30초–1분 시술 후 엉덩이 굽히기·벌리기 범위를 재평가한다. 통증 감소 또는 ROM 증가가 확인되면 Grade를 유지하거나 상향하여 2–3세트 반복한다."}]'::jsonb,
  '{"pain_relief","joint_decompression"}',
  '{"subacute","chronic"}',
  '{"hip_pain","rest_pain","movement_pain"}',
  '{"fracture","joint_infection","malignancy","hip_replacement"}',
  'level_2b'::evidence_level,
  '엉덩 관절 장축 견인은 관절 내압 감소와 통증 억제에 효과적일 수 있다. Grade I–II로 급성~아급성 통증 조절, Grade III–IV로 관절가동범위 개선에 활용 가능성이 있다. 엉덩 관절 치환술 후에는 절대 시행하지 않는다.',
  'fracture, joint_infection, malignancy, total_hip_replacement',
  'inferior_instability, acute_inflammation, severe_osteoporosis',
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
-- HIP-JM-AP: 엉덩 관절 전방 AP 글라이드
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
  'Maitland — HJ',
  '엉덩 관절 전방 AP 글라이드', 'Hip Anterior AP Glide', 'HIP-JM-AP',
  'hip'::body_region, 'HJ 전방 관절낭',
  '엎드려 눕기, 무릎 약간 굽힌 위치',
  '환자 환측 옆, 한 손 대퇴 하부 고정, 한 손 대퇴골두 후방면 접촉',
  '대퇴골두 후방면 (손바닥 근위부 또는 두상골)',
  '전방 AP 글라이드',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 치료 측 무릎을 약간 굽힌 위치로 편안하게 이완시킨다. 무릎 아래에 작은 쿠션을 받쳐 대퇴골두의 전방 접근성을 높일 수 있다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 한 손을 대퇴 원위부 하부(무릎 바로 위)에 가볍게 올려 대퇴를 안정화한다. 반대 손의 손바닥 근위부 또는 두상골을 대퇴골두 후방면(둔부 표면 깊은 부위)에 부드럽게 접촉한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade I–II는 관절 저항이 느껴지기 전 범위에서 소진폭 리듬 가동, Grade III–IV는 관절 끝 범위에서 대진폭 또는 소진폭 가동을 적용한다."},{"step":4,"instruction":"대퇴골두 후방면에서 전방 방향으로 리듬감 있게 밀어주며 전방 관절낭의 이완을 유도한다. 시술 중 환자의 사타구니 또는 엉덩이 앞쪽 통증 변화를 확인한다."},{"step":5,"instruction":"30초–1분 시술 후 엉덩이 안쪽으로 돌리기 및 뒤로 젖히기 범위를 재평가한다. ROM 증가 또는 통증 감소가 확인되면 Grade를 유지하거나 상향하여 2–3세트 반복한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"hip_pain","internal_rotation_restriction","extension_restriction"}',
  '{"fracture","joint_infection","malignancy","hip_replacement"}',
  'level_2b'::evidence_level,
  '엉덩 관절 전방 AP 글라이드는 엉덩 관절 안쪽으로 돌리기·뒤로 젖히기 제한 및 전방 관절낭 단축에 효과적일 수 있다. 전방 관절낭 긴장이 의심될 때 우선적으로 적용 가능성이 높다.',
  'fracture, joint_infection, malignancy, total_hip_replacement',
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
-- HIP-JM-INF: 엉덩 관절 하방·외측 견인
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
  'Maitland — HJ',
  '엉덩 관절 하방·외측 견인', 'Hip Inferior-lateral Traction', 'HIP-JM-INF',
  'hip'::body_region, 'HJ 하방·외측 관절낭',
  '바로 눕기, 엉덩이 약간 굽히기·바깥쪽으로 벌리기 위치',
  '환자 환측 옆 발쪽, 대퇴 원위부를 하방·외측 방향으로 견인',
  '대퇴 원위부 내측 (양 손 파지)',
  '하방·외측 견인 (Inferior-lateral distraction)',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 치료 측 엉덩이를 약 20–30도 굽히고 약간 바깥쪽으로 벌린 위치(편안한 안정 자세)로 이완시킨다. 이 자세는 엉덩 관절 하방 관절낭에 접근하기 좋은 시작 위치다."},{"step":2,"instruction":"치료사는 환자 환측 옆 발쪽에 위치하여 양 손으로 대퇴 원위부 내측(슬개골 직상방 5–8 cm)을 확실히 파지한다. 몸통이 견인 방향에 맞게 정렬되어 있는지 확인한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade I–II는 관절 저항 이전 범위에서 부드러운 리듬 견인, Grade III–IV는 관절 끝 저항 범위까지 견인 강도를 높인다."},{"step":4,"instruction":"대퇴 원위부를 하방·외측 방향(발쪽이면서 몸 바깥쪽)으로 리듬감 있게 견인하며 관절강 내 공간 확보와 관절낭 이완을 유도한다. 대퇴비구 충돌증후군(FAI) 증상 완화를 위해 활용할 때는 통증이 없는 범위에서만 시행한다."},{"step":5,"instruction":"30초–1분 시술 후 엉덩이 굽히기·바깥으로 돌리기 범위를 재평가하고 사타구니 충돌 증상의 변화를 확인한다. 증상 완화가 확인되면 Grade를 유지하거나 조정하여 2–3세트 반복한다."}]'::jsonb,
  '{"pain_relief","joint_decompression","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"hip_pain","fai_symptoms","groin_pain"}',
  '{"fracture","joint_infection","malignancy","hip_replacement"}',
  'level_2b'::evidence_level,
  '하방·외측 견인은 관절강 내 공간 확보와 관절낭 전반 이완에 도움이 될 수 있다. FAI(대퇴비구 충돌증후군) 환자에서 증상 완화 보조로 활용될 수 있으며, 엉덩이를 굽힐 때 사타구니 쪽 충돌감이 있는 경우 우선적으로 고려 가능성이 있다.',
  'fracture, joint_infection, malignancy, total_hip_replacement',
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
-- HIP-JM-IR: 엉덩 관절 내회전 증진 가동술
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
  'Maitland — HJ',
  '엉덩 관절 내회전 증진 가동술', 'Hip Internal Rotation Mobilization', 'HIP-JM-IR',
  'hip'::body_region, 'HJ 후방 관절낭',
  '엎드려 눕기, 무릎 90도 굽힌 위치',
  '환자 환측 옆, 한 손 골반 안정화, 한 손 하퇴 원위부 파지',
  '하퇴 원위부 (한 손 파지)',
  '하퇴를 외측으로 움직여 대퇴골 내회전 유도',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 치료 측 무릎을 90도로 굽혀 하퇴가 수직으로 세워지도록 한다. 골반이 테이블에 밀착되어 있는지 확인한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 한 손의 손바닥을 장골 후방(PSIS 근처)에 가볍게 올려 골반이 들리지 않도록 안정화한다. 반대 손으로 하퇴 원위부(발목 위 5–8 cm)를 파지한다."},{"step":3,"instruction":"Grade에 따라 가동 범위를 조절한다. Grade I–II는 내회전 저항이 느껴지기 전 범위에서 리듬 가동, Grade III–IV는 후방 관절낭 끝 저항이 느껴지는 범위까지 적용한다."},{"step":4,"instruction":"하퇴를 외측 방향으로 부드럽게 움직여 대퇴골 내회전을 유도한다. 골반이 들리거나 요추가 회전하는 보상 동작이 발생하지 않도록 안정화 손으로 지속 확인한다."},{"step":5,"instruction":"30초–1분 시술 후 엎드려 눕기 상태에서 내회전 범위를 재평가하거나 앉은 자세에서 걷기 패턴을 확인한다. ROM 증가가 확인되면 Grade를 유지하거나 상향하여 2–3세트 반복한다."}]'::jsonb,
  '{"rom_improvement","pain_relief"}',
  '{"subacute","chronic"}',
  '{"hip_internal_rotation_restriction","hip_pain","low_back_pain_associated"}',
  '{"fracture","joint_infection","malignancy","hip_replacement"}',
  'level_2b'::evidence_level,
  '엉덩 관절 안쪽으로 돌리기 제한은 요추·천장관절 보상 이동 패턴을 유발할 수 있다. 후방 관절낭 단축 개선에 도움이 될 수 있으며, 걸을 때 발이 안쪽으로 향하거나 요통이 함께 있는 경우 안쪽으로 돌리기 기능 회복이 중요할 수 있다.',
  'fracture, joint_infection, malignancy, total_hip_replacement',
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

-- ────────────────────────────────
-- HIP-JM-SIJ-ANT: 천장관절 전방 전단력 가동술
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
  'Maitland — SIJ',
  '천장관절 전방 전단력 가동술', 'SIJ Anterior Shear Mobilization', 'HIP-JM-SIJ-ANT',
  'hip'::body_region, '천장관절 전방',
  '옆으로 눕기(환측 위), 무릎 굽힌 위치',
  '환자 뒤쪽, 한 손 장골 후방면 접촉, 한 손 무릎 전방 지지',
  '장골 후상극(PSIS) 후방면',
  '전방 전단력 (PSIS를 전방으로 밀기)',
  '[{"step":1,"instruction":"환자를 치료 측이 위로 향하도록 옆으로 눕기 자세로 위치시킨다. 위쪽 무릎과 엉덩이를 약 45–60도 굽힌 편안한 위치로 이완시키고, 아래쪽 다리는 펴거나 약간 굽혀 안정적 기저를 만든다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 서서 한 손 손바닥을 장골 후상극(PSIS) 후방면에 접촉한다. 반대 손은 환자의 위쪽 무릎 전방에 가볍게 지지하여 골반이 과도하게 앞으로 구르지 않도록 한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade I–II는 저항이 느껴지기 전 범위에서 부드러운 리듬 가동, Grade III–IV는 인대 끝 저항이 느껴지는 범위까지 전단력을 적용한다."},{"step":4,"instruction":"PSIS를 전방(복측) 방향으로 리듬감 있게 밀어주며 천장관절 전방 이동을 유도한다. 요추 전반이 과도하게 회전하지 않도록 시술 범위를 천장관절에 국한한다."},{"step":5,"instruction":"30초–1분 시술 후 서 있는 자세에서 후방 골반통의 변화를 확인하거나 앉거나 일어서기 동작 시 통증 변화를 평가한다. 증상 완화가 확인되면 2–3세트 반복한다."}]'::jsonb,
  '{"pain_relief","sij_mobility"}',
  '{"subacute","chronic"}',
  '{"posterior_pelvic_pain","sij_dysfunction","low_back_pain"}',
  '{"fracture","malignancy","sij_fusion","ankylosing_spondylitis"}',
  'level_2b'::evidence_level,
  '천장관절 전방 가동술은 SIJ 기능장애 관련 후방 골반통 완화에 도움이 될 수 있다. 산후 골반통 및 요통과 연관된 SIJ 기능장애에서 보조적 치료로 활용될 수 있으며, 한 발 서기 또는 계단 오르기 시 후방 골반통이 유발되는 경우에 적용 가능성이 있다.',
  'fracture, malignancy, SIJ_fusion, severe_ankylosing_spondylitis',
  'acute_inflammation, pregnancy_third_trimester, anticoagulant_therapy',
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
-- HIP-JM-SIJ-POST: 천장관절 후방 압박 가동술
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
  'Maitland — SIJ',
  '천장관절 후방 압박 가동술', 'SIJ Posterior Compression Mobilization', 'HIP-JM-SIJ-POST',
  'hip'::body_region, '천장관절 후방 인대 복합체',
  '옆으로 눕기(환측 위), 엉덩이와 무릎 굽힌 위치',
  '환자 뒤쪽, 장골릉 후방면에 양 손 접촉',
  '장골릉 후방면 (양 손바닥 중첩)',
  '내측·전방 압박 (SIJ를 닫는 방향)',
  '[{"step":1,"instruction":"환자를 치료 측이 위로 향하도록 옆으로 눕기 자세로 위치시킨다. 위쪽 엉덩이와 무릎을 약 60–80도 굽혀 안정적인 위치로 이완시키고, 아래쪽 다리는 약간 굽혀 자세 안정성을 높인다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 서서 양 손바닥을 중첩하여 위쪽 장골릉 후방면에 부드럽게 접촉한다. 손 위치는 장골 후상극(PSIS)과 장골릉 후방 사이 어깨넓이로 유지한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade I–II는 SIJ 인대 저항이 느껴지기 전 범위에서 리듬 가동, Grade III–IV는 끝 저항 범위까지 압박을 가한다. 시술 전 능동 직다리들기(ASLR) 양성 여부를 확인하면 적용 방향 결정에 도움이 된다."},{"step":4,"instruction":"장골릉을 내측·전방(천골 쪽) 방향으로 리듬감 있게 압박하며 SIJ를 닫는 방향으로 인대 긴장을 유도한다. 시술 중 후방 골반통의 변화를 지속 확인하고, 통증이 증가하면 즉시 힘을 줄인다."},{"step":5,"instruction":"30초–1분 시술 후 능동 직다리들기(ASLR) 또는 서 있는 자세에서 후방 골반통을 재평가한다. 증상 완화가 확인되면 Grade를 유지하거나 상향하여 2–3세트 반복한다."}]'::jsonb,
  '{"pain_relief","stability_improvement"}',
  '{"subacute","chronic"}',
  '{"posterior_pelvic_pain","sij_dysfunction","postpartum_pelvic_pain"}',
  '{"fracture","malignancy","sij_fusion","acute_inflammation"}',
  'level_2b'::evidence_level,
  '천장관절 후방 압박 가동술은 SIJ 인대 긴장 감소와 후방 골반 안정성 회복에 도움이 될 수 있다. 산후 골반통에서 능동 직다리들기(ASLR) 양성 소견이 있을 때 보조적으로 활용될 수 있으며, 닫힘력(force closure) 부족이 의심되는 경우에 적용 가능성이 있다.',
  'fracture, malignancy, SIJ_fusion',
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
-- SECTION 2: category_mulligan — 2 techniques
-- =============================================================

-- ────────────────────────────────
-- HIP-MUL-FLEX: 엉덩 관절 굽히기 MWM
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
  'Mulligan MWM — 엉덩 관절',
  '엉덩 관절 굽히기 MWM', 'Hip Flexion MWM', 'HIP-MUL-FLEX',
  'hip'::body_region, 'HJ 대퇴골두',
  '바로 눕기 또는 서 있는 자세',
  '환자 환측 옆, 양 손으로 대퇴골두에 외측 글라이드 유지',
  '대퇴골두 내측면 (양 손 파지)',
  '외측 글라이드 유지하며 환자 능동 엉덩이 굽히기',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 서 있는 자세로 위치시킨다. 처음 시도 시 바로 눕기가 더 안정적이며, 기능적 접근이 필요한 경우 서 있는 자세로 전환할 수 있다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 양 손을 대퇴 근위부 내측면에 접촉하여 대퇴골두에 외측 글라이드를 가할 준비를 한다. 글라이드 방향은 대퇴골두를 관절와에서 외측(바깥쪽)으로 이동시키는 방향이다."},{"step":3,"instruction":"치료사가 외측 글라이드를 유지한 채로 환자에게 천천히 엉덩이 굽히기 동작을 능동적으로 수행하도록 지시한다. 통증이 없는 범위에서만 움직임을 진행한다."},{"step":4,"instruction":"글라이드 방향과 강도가 통증 없는 움직임 범위를 극대화하는 위치를 찾는다. 글라이드가 효과적이면 이전에 통증이 유발되던 범위에서도 통증 없이 움직임이 가능해진다. 글라이드 방향 미세 조정이 효과에 큰 영향을 줄 수 있다."},{"step":5,"instruction":"3–5회 반복 후 글라이드를 해제하고 능동 굽히기 범위와 통증을 재평가한다. 즉각적인 ROM 증가 또는 통증 감소가 확인되면 같은 조건으로 3세트 반복한다. 효과가 없으면 글라이드 방향을 재조정한다."}]'::jsonb,
  '{"pain_relief","rom_improvement","functional_improvement"}',
  '{"subacute","chronic"}',
  '{"hip_flexion_restriction","groin_pain","hip_pain"}',
  '{"fracture","joint_infection","malignancy","hip_replacement"}',
  'level_2b'::evidence_level,
  '엉덩 관절 굽히기 MWM은 무통 범위 내 즉각적인 굽히기 ROM 개선을 기대할 수 있다. 관절 포지션 오류(positional fault)가 있는 경우 효과적일 수 있으며, 시술 중 통증이 발생하면 즉시 중단하고 글라이드 방향을 재평가하는 것이 중요할 수 있다.',
  'fracture, joint_infection, malignancy, total_hip_replacement',
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
-- HIP-MUL-IR: 엉덩 관절 내회전 MWM
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
  'Mulligan MWM — 엉덩 관절',
  '엉덩 관절 내회전 MWM', 'Hip Internal Rotation MWM', 'HIP-MUL-IR',
  'hip'::body_region, 'HJ 후방 관절낭',
  '엎드려 눕기, 무릎 90도 굽힌 위치',
  '환자 환측 옆, 한 손 대퇴골두 후방 외측 글라이드 유지',
  '대퇴골두 후방면',
  '후방 글라이드 유지하며 환자 능동 안쪽으로 돌리기',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 치료 측 무릎을 90도로 굽혀 하퇴가 수직으로 세워지도록 한다. 골반이 테이블에 밀착된 안정적인 위치인지 확인한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 한 손을 대퇴골두 후방면(둔부 중앙부 깊이)에 접촉하여 후방·외측 방향 글라이드를 준비한다. 반대 손은 필요 시 골반 안정화에 활용한다."},{"step":3,"instruction":"치료사가 대퇴골두 후방 외측 글라이드를 유지한 채로 환자에게 하퇴를 외측으로 천천히 이동(대퇴골 안쪽으로 돌리기)하도록 지시한다. 통증이 발생하지 않는 범위에서만 동작을 진행한다."},{"step":4,"instruction":"글라이드 강도와 방향을 미세 조정하며 가장 통증 없이 안쪽으로 돌리기 범위가 최대화되는 위치를 찾는다. 대퇴비구 충돌증후군(FAI) 환자에서 충돌 증상 없이 안쪽으로 돌리기 범위가 늘어나면 효과적인 적용으로 볼 수 있다."},{"step":5,"instruction":"3–5회 반복 후 글라이드를 해제하고 능동 안쪽으로 돌리기 범위와 통증을 재평가한다. 즉각적인 ROM 증가가 확인되면 같은 조건으로 3세트 반복한다. 효과가 없으면 글라이드 방향(후방, 외측, 후방-외측 조합)을 재조정한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"hip_internal_rotation_restriction","hip_pain","fai_symptoms"}',
  '{"fracture","joint_infection","malignancy","hip_replacement"}',
  'level_2b'::evidence_level,
  '엉덩 관절 안쪽으로 돌리기 MWM은 안쪽으로 돌리기 제한 환자에서 무통 범위 즉각 개선에 효과적일 수 있다. 엉덩이 안쪽으로 돌리기 제한이 있는 FAI 환자에서 보조적으로 활용될 수 있으며, 시술 중 사타구니 충돌감이 발생하면 즉시 중단하고 글라이드 방향을 재조정하는 것이 중요할 수 있다.',
  'fracture, joint_infection, malignancy, total_hip_replacement',
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
-- Migration 021 (Part 2): Hip — MFR + ART (9 techniques)
-- sw-db-architect | 2026-04-28
--
-- 수록 기법:
--   SECTION 3: category_mfr (5개) — 고관절 근막이완
--     [1]  장요근 근막이완                            HIP-MFR-Psoas
--     [2]  이상근 근막이완                            HIP-MFR-Pir
--     [3]  대퇴근막장근 근막이완                       HIP-MFR-TFL
--     [4]  내전근군 근막이완                           HIP-MFR-Add
--     [5]  중둔근·소둔근 근막이완                      HIP-MFR-GluMed
--   SECTION 4: category_art (4개) — 고관절 능동적 이완기법
--     [6]  장요근 능동적 이완기법                      ART-PsoasHip
--     [7]  이상근 능동적 이완기법                      ART-PirHip
--     [8]  대퇴근막장근 능동적 이완기법                 ART-TFLHip
--     [9]  내전근군 능동적 이완기법                    ART-AddHip
--
-- 전제:
--   - body_region 'hip' 존재
--   - category_mfr, category_art enum 존재

-- =============================================================
-- SECTION 3: category_mfr — 고관절 근막이완 기법 5개
-- =============================================================

-- ────────────────────────────────
-- HIP-MFR-Psoas: 장요근 근막이완
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
  'MFR — 엉덩 굴근',
  '장요근 근막이완', 'Psoas MFR', 'HIP-MFR-Psoas',
  'hip'::body_region, '장요근(요추 횡돌기·장골와 → 대퇴골 소전자)',
  '바로 눕기, 치료 반대측 무릎 굽혀 발 바닥에 지지',
  '환자 환측 옆, 하복부 외측에서 장요근 근복 깊이 접촉',
  '배꼽 외측 3–5cm, 복직근 외측연을 통한 장요근 근복 (손가락 끝 — 복부 대동맥 방향 주의)',
  '복직근 외측연 경유 심부 압박·지속 이완',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 치료 반대측 무릎을 굽혀 발바닥을 테이블에 지지하게 한다. 이 자세는 복부 근육의 이완을 유도하고 장요근 접근을 용이하게 한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 배꼽 외측 3–5cm, 복직근 외측연 바로 안쪽에 손가락 끝을 부드럽게 접촉한다. 복부 대동맥의 박동을 감지하며 박동이 느껴지면 접촉 방향을 약간 외측으로 수정한다."},{"step":3,"instruction":"호흡 주기에 맞춰 환자가 숨을 내쉴 때마다 손가락을 서서히 깊이 진입시켜 장요근 근복 표면에 접촉한다. 조직이 저항하는 지점에서 멈추고 90초~2분간 지속 압박을 유지한다."},{"step":4,"instruction":"근막 이완 반응(조직의 부드러운 흐름 또는 온기 증가)이 느껴지면 압박 방향을 근위(요추) → 원위(소전자) 방향으로 천천히 이동하며 장요근 주행 방향을 따라 시술한다."},{"step":5,"instruction":"시술 후 엉덩 굽히기 범위와 엎드려 눕기 자세에서 복부 긴장도를 재평가한다. 필요 시 1~2회 반복하고, 시술 후 환자에게 어지럼증 또는 복부 불편감 유무를 확인한다."}]'::jsonb,
  '{"tissue_release","postural_correction","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"hip_flexion_restriction","low_back_pain","anterior_hip_pain"}',
  '{"abdominal_aortic_aneurysm","malignancy","active_infection","pregnancy"}',
  'level_4'::evidence_level,
  '장요근 근막 단축은 골반 전방 경사와 요추 과전만을 유발할 수 있으며, 장시간 앉아 있는 생활 패턴에서 빈번히 관찰됨. 엉덩 굽히기 제한과 허리 통증의 주요 연관 근육 중 하나로 평가될 수 있다.',
  'abdominal_aortic_aneurysm, malignancy, active_infection, pregnancy',
  'bowel_inflammation, anticoagulant_therapy, recent_abdominal_surgery',
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
-- HIP-MFR-Pir: 이상근 근막이완
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
  'MFR — 심부 외회전근',
  '이상근 근막이완', 'Piriformis MFR', 'HIP-MFR-Pir',
  'hip'::body_region, '이상근(천골 전면 → 대퇴골 대전자)',
  '옆으로 눕기(환측 위) 또는 엎드려 눕기',
  '환자 뒤쪽, 대전자와 천골 중간 지점에서 이상근 접촉',
  '대전자와 천골 중간 지점 이상근 근복 (엄지 또는 손가락 끝)',
  '이상근 주행 방향 지속 압박·이완',
  '[{"step":1,"instruction":"환자를 옆으로 눕기(환측 위) 자세로 위치시키고 엉덩이와 무릎을 약 60–90도 굽혀 이상근 접근이 용이한 자세를 만든다. 엎드려 눕기 자세도 가능하며, 환자 편안함에 따라 선택한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 서서 대전자와 천골 중간 지점(이상근 근복 위치)에 엄지 또는 손가락 끝으로 부드럽게 접촉한다. 좌골신경 주행 경로를 피하여 접촉 위치를 확인한다."},{"step":3,"instruction":"조직이 저항하는 깊이까지 서서히 압박하고, 이완 반응이 나타날 때까지 90초~2분간 지속 압박을 유지한다. 환자가 느끼는 통증이 4/10 이하가 되도록 압박 강도를 조절한다."},{"step":4,"instruction":"이완 반응이 느껴지면 천골 부착부에서 대전자 방향으로 이상근 주행을 따라 압박 방향을 천천히 이동하며 근복 전체를 다룬다."},{"step":5,"instruction":"시술 후 엉덩 바깥쪽 돌리기 범위와 엉덩이 심부 통증 변화를 재평가한다. 필요 시 1~2회 반복하고, 좌골신경 방사 증상 변화 여부를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","neural_decompression"}',
  '{"subacute","chronic"}',
  '{"deep_buttock_pain","piriformis_syndrome","sciatica_like"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '이상근 긴장은 좌골신경 자극과 엉덩이 심부 통증의 원인이 될 수 있다. 이상근 증후군과 엉덩이 통증의 감별진단이 필요하며 근막이완으로 증상 완화가 가능할 수 있다.',
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
-- HIP-MFR-TFL: 대퇴근막장근 근막이완
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
  'MFR — 외측 엉덩이',
  '대퇴근막장근 근막이완', 'TFL MFR', 'HIP-MFR-TFL',
  'hip'::body_region, '대퇴근막장근(전상장골극 → 장경인대)',
  '옆으로 눕기(환측 위)',
  '환자 뒤쪽, 전상장골극 하방 TFL 근복 접촉',
  '전상장골극 하방 TFL 근복 (손바닥 또는 전완)',
  'TFL 근복 지속 압박·이완',
  '[{"step":1,"instruction":"환자를 옆으로 눕기(환측 위) 자세로 위치시키고 엉덩이와 무릎을 약간 굽혀 TFL 접근이 용이한 자세를 만든다. 시술 측 하지가 테이블 위에서 이완되도록 한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 서서 전상장골극 하방 TFL 근복 위에 손바닥 또는 전완을 부드럽게 접촉한다. 조직이 저항하는 깊이까지 서서히 압박을 가한다."},{"step":3,"instruction":"저항이 느껴지는 지점에서 멈추고 이완 반응이 나타날 때까지 90초~2분간 지속 압박을 유지한다. 환자의 통증 반응이 4/10 이하가 되도록 압박 강도를 조절한다."},{"step":4,"instruction":"이완 반응이 느껴지면 전상장골극에서 대퇴 외측 장경인대 방향으로 TFL 주행을 따라 압박 방향을 천천히 이동한다."},{"step":5,"instruction":"시술 후 엉덩이 외측 통증 변화와 엉덩 벌리기 범위를 재평가한다. 필요 시 1~2회 반복하고, 장경인대 긴장 변화 여부도 함께 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief"}',
  '{"subacute","chronic"}',
  '{"lateral_hip_pain","itb_syndrome","trochanteric_pain"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  'TFL 긴장은 장경인대 증후군 및 외측 엉덩이 통증의 원인이 될 수 있다. 달리기 선수와 자전거 이용자에서 빈번히 관찰될 수 있으며, 근막이완 후 스트레칭과 병행하면 효과가 높아질 수 있다.',
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
-- HIP-MFR-Add: 내전근군 근막이완
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
  'MFR — 내측 대퇴',
  '내전근군 근막이완', 'Adductor Complex MFR', 'HIP-MFR-Add',
  'hip'::body_region, '장·단내전근·대내전근·박근 복합체(치골·좌골 → 대퇴 내측)',
  '바로 눕기, 환측 무릎 약간 굽힌 위치',
  '환자 환측 옆, 내측 대퇴 내전근군 접촉',
  '내측 대퇴 내전근군 (손바닥 또는 전완)',
  '근위부(치골·좌골 부착부)에서 원위부 방향 지속 압박·이완',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 환측 무릎을 약간 굽혀 발바닥을 테이블에 지지하게 한다. 이 자세는 내전근을 이완시키고 내측 대퇴 접근을 용이하게 한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 손바닥 또는 전완을 내측 대퇴 내전근군 근위부(치골 결합 아래)에 부드럽게 접촉한다. 대퇴 신경혈관 구조물(대퇴동맥·정맥·신경)을 피해 내측 근육군에 접촉한다."},{"step":3,"instruction":"조직이 저항하는 깊이까지 서서히 압박하고, 이완 반응이 나타날 때까지 90초~2분간 지속 압박을 유지한다. 환자의 통증 반응이 4/10 이하가 되도록 압박 강도를 조절한다."},{"step":4,"instruction":"이완 반응이 느껴지면 치골·좌골 부착부에서 대퇴 내측 원위부 방향으로 내전근 주행을 따라 압박 방향을 천천히 이동한다."},{"step":5,"instruction":"시술 후 엉덩 벌리기 범위와 서혜부 통증 변화를 재평가한다. 필요 시 1~2회 반복하고, 대퇴 내측 혈관 압박 증상(저림, 맥박 변화) 유무를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"groin_pain","adductor_tightness","abduction_restriction"}',
  '{"fracture","malignancy","active_infection","femoral_hernia"}',
  'level_4'::evidence_level,
  '내전근 긴장은 서혜부 통증 및 엉덩 관절 외전 제한의 원인이 될 수 있다. 스포츠 관련 서혜부 통증과 고관절 관절증에서 빈번히 동반될 수 있으며, 내측 대퇴 시술 시 대퇴 신경혈관 구조물 위치 숙지가 필요하다.',
  'fracture, malignancy, active_infection, femoral_hernia',
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
-- HIP-MFR-GluMed: 중둔근·소둔근 근막이완
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
  'MFR — 외측 둔근',
  '중둔근·소둔근 근막이완', 'Gluteus Medius / Minimus MFR', 'HIP-MFR-GluMed',
  'hip'::body_region, '중둔근·소둔근(장골릉 외면 → 대전자)',
  '옆으로 눕기(환측 위) 또는 엎드려 눕기',
  '환자 뒤쪽, 장골릉 외면에서 대전자 사이 중·소둔근 접촉',
  '장골릉 외면 ~ 대전자 사이 중·소둔근 근복 (손바닥 또는 전완)',
  '장골릉 부착부에서 대전자 방향 지속 압박·이완',
  '[{"step":1,"instruction":"환자를 옆으로 눕기(환측 위) 또는 엎드려 눕기 자세로 위치시키고 시술 측 하지가 테이블 위에서 편안하게 이완되도록 한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 서서 손바닥 또는 전완을 장골릉 외면 하방 중·소둔근 근복에 부드럽게 접촉한다. 조직이 저항하는 깊이까지 서서히 압박을 가한다."},{"step":3,"instruction":"저항이 느껴지는 지점에서 멈추고, 이완 반응이 나타날 때까지 90초~2분간 지속 압박을 유지한다. 환자의 통증 반응이 4/10 이하가 되도록 압박 강도를 조절한다."},{"step":4,"instruction":"이완 반응이 느껴지면 장골릉 부착부에서 대전자 방향으로 중·소둔근 주행을 따라 압박 방향을 천천히 이동한다."},{"step":5,"instruction":"시술 후 외측 엉덩이 통증 변화와 엉덩 벌리기 근력 및 범위를 재평가한다. 필요 시 1~2회 반복하고, 대전자 주위 압통 감소 여부를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","stability_improvement"}',
  '{"subacute","chronic"}',
  '{"lateral_hip_pain","trochanteric_bursitis","gait_dysfunction"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '중둔근·소둔근 긴장 또는 약화는 대전자 부위 통증과 보행 시 트렌델렌버그 양상을 유발할 수 있다. 근막이완 후 중둔근 강화 운동을 병행하면 안정성 개선 효과가 높아질 수 있다.',
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
-- SECTION 4: category_art — 고관절 능동적 이완기법 4개
-- =============================================================

-- ────────────────────────────────
-- ART-PsoasHip: 장요근 능동적 이완기법
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
  'ART — 엉덩 굴근',
  '장요근 능동적 이완기법', 'Psoas Active Release Technique', 'ART-PsoasHip',
  'hip'::body_region, '장요근 근복(하복부 외측 접근)',
  '바로 눕기',
  '환자 환측 옆, 하복부 외측에서 장요근 근복에 접촉 압박 유지',
  '배꼽 외측 장요근 근복 (손가락 끝)',
  '접촉 유지하며 환자가 엉덩이를 굽히기에서 펴기로 능동 이동',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 치료 측 무릎을 약간 굽힌 상태에서 시작한다. 복부 근육이 이완되도록 편안한 자세를 유지하게 한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 배꼽 외측 3–5cm 장요근 근복에 손가락 끝으로 접촉하고, 조직이 저항하는 깊이까지 서서히 압박을 유지한다. 복부 대동맥 박동이 감지되면 접촉 방향을 외측으로 조정한다."},{"step":3,"instruction":"압박을 유지한 상태에서 환자에게 천천히 무릎을 가슴 방향으로 당겨 엉덩이를 굽히도록 지시한다."},{"step":4,"instruction":"엉덩이 굽히기 최대 범위에서 치료사는 접촉점의 압박을 유지하며, 환자에게 다시 다리를 천천히 테이블로 내려 엉덩이를 펴도록 지시한다. 이 능동 이동 과정에서 유착 분리가 일어날 수 있다. 시술 중 통증이 4/10 이하로 유지되도록 압박 강도를 조절한다."},{"step":5,"instruction":"1세트당 4~6회 반복하며, 재평가 후 필요 시 2~3세트 시행한다. 시술 후 엉덩 굽히기 범위 및 전방 엉덩이 통증 변화를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"hip_flexion_restriction","anterior_hip_pain","low_back_pain"}',
  '{"abdominal_aortic_aneurysm","malignancy","active_infection","pregnancy"}',
  'level_4'::evidence_level,
  '장요근 ART는 과사용 또는 자세 불량으로 인한 근막 유착 해소에 도움이 될 수 있다. 복부 접근이 필요하므로 해부학적 구조물 숙지가 필수이며, 능동 운동 요소가 수동 이완에 비해 유착 분리 효율을 높일 수 있다는 임상적 관찰이 있다.',
  'abdominal_aortic_aneurysm, malignancy, active_infection, pregnancy',
  'bowel_inflammation, anticoagulant_therapy, recent_abdominal_surgery',
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
-- ART-PirHip: 이상근 능동적 이완기법
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
  'ART — 심부 외회전근',
  '이상근 능동적 이완기법', 'Piriformis Active Release Technique', 'ART-PirHip',
  'hip'::body_region, '이상근(천골 전면 ~ 대전자)',
  '옆으로 눕기(환측 위), 엉덩이·무릎 굽힌 위치',
  '환자 뒤쪽, 이상근 근복에 접촉 압박 유지',
  '대전자와 천골 중간 이상근 근복 (엄지 또는 손가락 끝)',
  '접촉 유지하며 환자가 엉덩이를 안쪽으로 돌리기에서 바깥쪽으로 돌리기로 능동 이동',
  '[{"step":1,"instruction":"환자를 옆으로 눕기(환측 위) 자세로 위치시키고 엉덩이와 무릎을 약 60–90도 굽힌 상태에서 시작한다. 이 자세는 이상근이 이완된 상태에서 시작할 수 있도록 한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 서서 대전자와 천골 중간 지점 이상근 근복에 엄지 또는 손가락 끝으로 접촉하고, 조직이 저항하는 깊이까지 압박을 유지한다. 좌골신경 경로를 피하도록 접촉 위치를 확인한다."},{"step":3,"instruction":"압박을 유지한 상태에서 환자에게 엉덩이를 천천히 안쪽으로 돌려(내회전) 발이 천장 방향으로 올라오도록 능동 이동을 지시한다."},{"step":4,"instruction":"내회전 최대 범위에서 치료사는 압박을 유지하며, 환자에게 다시 엉덩이를 바깥쪽으로 돌려(외회전) 시작 자세로 돌아오도록 지시한다. 이 능동 이동 과정에서 이상근 유착 분리가 일어날 수 있다. 통증이 4/10 이하로 유지되도록 조절한다."},{"step":5,"instruction":"1세트당 4~6회 반복하며, 재평가 후 필요 시 2~3세트 시행한다. 시술 후 엉덩이 심부 통증 및 좌골신경 방사 증상 변화를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","neural_decompression"}',
  '{"subacute","chronic"}',
  '{"deep_buttock_pain","piriformis_syndrome","sciatica_like"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '이상근 ART는 이상근 증후군 및 좌골신경 포착 증상 완화에 도움이 될 수 있다. 능동 회전 운동 요소가 정적 이완보다 이상근 내 유착 분리에 더 효과적일 수 있다는 임상적 관찰이 있으나, 고수준 근거는 아직 제한적이다.',
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
-- ART-TFLHip: 대퇴근막장근 능동적 이완기법
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
  'ART — 외측 엉덩이',
  '대퇴근막장근 능동적 이완기법', 'TFL Active Release Technique', 'ART-TFLHip',
  'hip'::body_region, 'TFL 근복(전상장골극 하방)',
  '옆으로 눕기(환측 위)',
  '환자 뒤쪽, TFL 근복 접촉 압박 유지',
  '전상장골극 하방 TFL 근복 (엄지 또는 손가락 끝)',
  '접촉 유지하며 환자가 엉덩이를 굽히기에서 펴기·모으기 방향으로 능동 이동',
  '[{"step":1,"instruction":"환자를 옆으로 눕기(환측 위) 자세로 위치시키고 엉덩이를 약 30–45도 굽힌 상태에서 시작한다. TFL 근복이 이완된 상태에서 초기 접촉을 시작한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 서서 전상장골극 하방 TFL 근복에 엄지 또는 손가락 끝으로 접촉하고, 조직이 저항하는 깊이까지 압박을 유지한다."},{"step":3,"instruction":"압박을 유지한 상태에서 환자에게 천천히 다리를 뒤로 펴고 아래쪽(모으기 방향)으로 이동하도록 능동 운동을 지시한다. 이 움직임은 TFL을 신장시키면서 유착 분리를 유도한다."},{"step":4,"instruction":"엉덩이 펴기·모으기 최대 범위에서 치료사는 압박을 유지하며 잠시 멈춘 후, 환자에게 다시 시작 자세로 돌아오도록 지시한다. 통증이 4/10 이하로 유지되도록 압박 강도를 조절한다."},{"step":5,"instruction":"1세트당 4~6회 반복하며, 재평가 후 필요 시 2~3세트 시행한다. 시술 후 외측 엉덩이 통증 및 장경인대 긴장 변화를 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief"}',
  '{"subacute","chronic"}',
  '{"lateral_hip_pain","itb_syndrome","trochanteric_pain"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  'TFL ART는 장경인대 증후군 및 외측 엉덩이 통증에서 TFL 근막 유착 해소에 도움이 될 수 있다. 능동 신장 운동 요소를 통한 유착 분리가 정적 이완보다 효율적일 수 있다는 임상적 관찰이 있으나, 고수준 근거는 아직 제한적이다.',
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
-- ART-AddHip: 내전근군 능동적 이완기법
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
  'ART — 내측 대퇴',
  '내전근군 능동적 이완기법', 'Adductor Complex Active Release Technique', 'ART-AddHip',
  'hip'::body_region, '장·단내전근·박근 근복(내측 대퇴 근위부)',
  '바로 눕기, 환측 무릎 굽힌 위치',
  '환자 환측 옆, 내측 대퇴 근위부 내전근 근복 접촉 유지',
  '내측 대퇴 내전근 근복 (엄지 또는 손가락 끝)',
  '접촉 유지하며 환자가 엉덩이를 모으기에서 벌리기 방향으로 능동 이동',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 환측 무릎을 약 45–60도 굽힌 상태에서 시작한다. 이 자세는 내전근이 이완된 초기 접촉 위치를 제공한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 내측 대퇴 근위부 내전근 근복에 엄지 또는 손가락 끝으로 접촉하고, 조직이 저항하는 깊이까지 압박을 유지한다. 대퇴 신경혈관 구조물을 피해 내전근 근복에 접촉한다."},{"step":3,"instruction":"압박을 유지한 상태에서 환자에게 천천히 다리를 바깥쪽으로 벌리도록(외전) 능동 운동을 지시한다. 이 움직임은 내전근을 신장시키면서 근막 유착 분리를 유도한다."},{"step":4,"instruction":"엉덩이 벌리기 최대 편안한 범위에서 치료사는 압박을 유지하며 잠시 멈춘 후, 환자에게 다시 시작 자세로 돌아오도록 지시한다. 통증이 4/10 이하로 유지되도록 압박 강도를 조절한다."},{"step":5,"instruction":"1세트당 4~6회 반복하며, 재평가 후 필요 시 2~3세트 시행한다. 시술 후 서혜부 통증 및 엉덩 벌리기 범위 변화를 확인하고, 내전근 완전 파열이 의심되는 경우 즉시 시술을 중단한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"groin_pain","adductor_tightness","abduction_restriction"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '내전근군 ART는 서혜부 통증 및 엉덩 관절 외전 제한에서 근막 유착 해소에 효과적일 수 있다. 능동 벌리기 운동 요소가 수동 이완보다 내전근 유착 분리에 더 효율적일 수 있다는 임상적 관찰이 있으나, 고수준 근거는 아직 제한적이다.',
  'fracture, malignancy, active_infection',
  'adductor_complete_tear, acute_inflammation, anticoagulant_therapy',
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
-- Migration 021 (Part 3): Hip — CTM + DFM + TrP (12 techniques)
-- 엉덩 관절 연부조직: CTM 3 + DFM 3 + TrP 6
-- sw-db-architect | 2026-04-28

-- =============================================================
-- SECTION 5: category_ctm — 3 techniques (evidence_level = level_4)
-- =============================================================

-- ────────────────────────────────
-- CTM-HipAnterior: 엉덩 관절 전방 결합조직 마사지
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
  'CTM — 엉덩 관절 전방',
  '엉덩 관절 전방 결합조직 마사지', 'Anterior Hip Connective Tissue Massage', 'CTM-HipAnterior',
  'hip'::body_region, '서혜부·전방 엉덩이 피하결합조직',
  '바로 눕기, 환측 무릎 약간 굽혀 이완',
  '환자 환측 옆, 서혜부 ~ 전방 엉덩이 피하결합조직 접촉',
  '서혜부·전방 엉덩이 피하결합조직 (손가락 끝 긁기 기법)',
  '피부 접힘이 형성되는 방향으로 短파 긁기 스트로크',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고, 환측 무릎 아래에 베개를 받쳐 무릎을 약간 굽혀 이완된 위치를 만든다. 이 자세는 서혜부 및 전방 엉덩이 피하결합조직에 접근하기 좋은 시작 위치다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 위치하여 검지·중지·약지 손가락 끝을 서혜인대 하방 또는 전방 엉덩이 경계의 피하결합조직에 가볍게 접촉한다."},{"step":3,"instruction":"손가락을 피부에 밀착시킨 채 짧고 리듬감 있는 긁기 스트로크(CTM 특유의 short stroke)를 서혜부에서 전방 엉덩이 방향으로 반복 적용한다. 피부가 움직이되 미끄러지지 않도록 압박 깊이를 유지한다."},{"step":4,"instruction":"서혜인대 하방, 전방 관절낭 투영 구역, 전상장골극 주변 순서로 체계적으로 시술하며, 각 구역에서 1~2분씩 시행한다. 자율신경 반응(피부 홍조, 소름)은 정상 반응일 수 있다."},{"step":5,"instruction":"시술 후 서혜부 긴장감 변화 및 엉덩 관절 굽히기 범위를 재평가하고, 필요 시 2~3회 반복한다."}]'::jsonb,
  '{"tissue_release","pain_relief","circulation_improvement"}',
  '{"subacute","chronic"}',
  '{"groin_pain","hip_flexion_restriction","anterior_hip_pain"}',
  '{"fracture","malignancy","skin_infection_in_area"}',
  'level_4'::evidence_level,
  '전방 엉덩이 결합조직 마사지는 서혜부 긴장 완화와 국소 순환 개선에 도움이 될 수 있다. CTM의 반사적 자율신경 효과를 통한 통증 조절 가능성도 제안되고 있으나, 엉덩 관절에 특화된 고수준 근거는 아직 제한적이다.',
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
-- CTM-HipLateral: 엉덩 관절 외측 결합조직 마사지
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
  'CTM — 엉덩 관절 외측',
  '엉덩 관절 외측 결합조직 마사지', 'Lateral Hip Connective Tissue Massage', 'CTM-HipLateral',
  'hip'::body_region, '대전자 주변·장경인대 상부 피하결합조직',
  '옆으로 눕기(환측 위)',
  '환자 뒤쪽, 대전자 주변 외측 피하결합조직 접촉',
  '대전자 주변·외측 엉덩이 피하결합조직 (손가락 끝 긁기 기법)',
  '피부 접힘이 형성되는 방향으로 短파 긁기 스트로크',
  '[{"step":1,"instruction":"환자를 환측이 위로 향하는 옆으로 눕기 자세로 위치시키고, 상부 다리가 편안하게 이완되도록 두 다리 사이에 베개를 넣는다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 위치하여 검지·중지·약지 손가락 끝을 대전자 상방 또는 주변 외측 피하결합조직에 가볍게 접촉한다."},{"step":3,"instruction":"손가락을 피부에 밀착시킨 채 짧고 리듬감 있는 긁기 스트로크(CTM 특유의 short stroke)를 대전자 주변과 장경인대 상부 방향으로 반복 적용한다. 피부가 움직이되 미끄러지지 않도록 압박 깊이를 유지한다."},{"step":4,"instruction":"대전자 상방, 전방, 후방 순서로 체계적으로 시술하며 장경인대 상부까지 포함하여 각 구역에서 1~2분씩 시행한다. 자율신경 반응(피부 홍조, 소름)은 정상 반응일 수 있다."},{"step":5,"instruction":"시술 후 대전자 주변 통증 변화 및 엉덩 관절 외전 범위를 재평가하고, 필요 시 2~3회 반복한다."}]'::jsonb,
  '{"tissue_release","pain_relief","circulation_improvement"}',
  '{"subacute","chronic"}',
  '{"lateral_hip_pain","greater_trochanteric_pain","iliotibial_band_tightness"}',
  '{"fracture","malignancy","skin_infection_in_area"}',
  'level_4'::evidence_level,
  '외측 엉덩이 결합조직 마사지는 대전자 통증 및 장경인대 상부 긴장 완화에 도움이 될 수 있다. 대전자 통증 증후군(GTPS) 보존 치료 시 보조적으로 적용할 수 있으나, 고수준 근거는 아직 제한적이다.',
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
-- CTM-Gluteal: 둔근 구역 결합조직 마사지
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
  'CTM — 둔근 구역',
  '둔근 구역 결합조직 마사지', 'Gluteal Region Connective Tissue Massage', 'CTM-Gluteal',
  'hip'::body_region, '대·중·소둔근 피하결합조직(후방 골반~엉덩이 전반)',
  '엎드려 눕기',
  '환자 환측 옆, 둔근 구역 피하결합조직 전반 접촉',
  '둔근 구역 피하결합조직 (손가락 끝 긁기 기법)',
  '피부 접힘이 형성되는 방향으로 短파 긁기 스트로크',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고, 발목 아래에 타올을 받쳐 무릎이 자연스럽게 이완된 위치를 만든다. 엉덩이 근육이 충분히 이완될 수 있는 편안한 자세인지 확인한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 위치하여 검지·중지·약지 손가락 끝을 후방 장골릉 하방 둔근 구역 피하결합조직에 가볍게 접촉한다."},{"step":3,"instruction":"손가락을 피부에 밀착시킨 채 짧고 리듬감 있는 긁기 스트로크(CTM 특유의 short stroke)를 후방 골반에서 엉덩이 전반 방향으로 반복 적용한다. 피부가 움직이되 미끄러지지 않도록 압박 깊이를 유지한다."},{"step":4,"instruction":"장골릉 하방, 대둔근 상부·중부·하부, 중둔근 구역 순서로 체계적으로 시술하며 각 구역에서 1~2분씩 시행한다. 자율신경 반응(피부 홍조, 소름)은 정상 반응일 수 있다."},{"step":5,"instruction":"시술 후 후방 엉덩이 통증 변화 및 엉덩 관절 내회전·굴곡 범위를 재평가하고, 필요 시 2~3회 반복한다."}]'::jsonb,
  '{"tissue_release","pain_relief","circulation_improvement"}',
  '{"subacute","chronic"}',
  '{"gluteal_pain","posterior_hip_pain","hip_stiffness"}',
  '{"fracture","malignancy","skin_infection_in_area"}',
  'level_4'::evidence_level,
  '둔근 구역 결합조직 마사지는 후방 엉덩이 통증 완화와 조직 이동성 회복에 도움이 될 수 있다. CTM의 반사적 자율신경 효과를 통한 통증 조절 가능성도 제안되고 있으나, 고수준 근거는 아직 제한적이다.',
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

-- =============================================================
-- SECTION 6: category_deep_friction — 3 techniques (evidence_level = level_3)
-- =============================================================

-- ────────────────────────────────
-- DFM-GTBursa: 대전자 점액낭 주변 심부마찰 마사지
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
  'DFM — 대전자 구역',
  '대전자 점액낭 주변 심부마찰 마사지', 'Greater Trochanteric Bursa Deep Friction Massage', 'DFM-GTBursa',
  'hip'::body_region, '대전자 상방·후방 점액낭 구역',
  '옆으로 눕기(환측 위)',
  '환자 뒤쪽, 대전자 상방·후방 접촉',
  '대전자 상방 및 후방 점액낭 구역 (엄지 또는 검지·중지)',
  '점액낭 경계부에서 횡마찰',
  '[{"step":1,"instruction":"환자를 환측이 위로 향하는 옆으로 눕기 자세로 위치시키고, 두 다리 사이에 베개를 넣어 엉덩이 근육이 이완되도록 한다. 대전자가 손가락으로 접근하기 용이한 위치인지 확인한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 위치하여 엄지 또는 검지·중지로 대전자 상방 및 후방 경계를 촉진하여 압통 최대점을 확인한다. 점액낭 구역은 대전자 가장 돌출된 부위의 바로 상방 및 후방에 위치한다."},{"step":3,"instruction":"손가락 끝이 점액낭 경계부 조직에 충분히 밀착되도록 피부를 약간 이동시켜 접촉 위치를 잡는다. 대전자 표면에 수직으로 압박하지 않고 경계부를 따라 횡방향으로 접근한다."},{"step":4,"instruction":"점액낭 경계부 조직 방향에 수직으로 횡마찰을 리듬감 있게 시행한다. 압력은 조직 저항이 느껴지는 수준으로 유지하며 매 왕복 시 동일한 범위와 속도를 유지한다."},{"step":5,"instruction":"3~5분 시행 후 대전자 압통 변화 및 외측 엉덩이 통증 변화를 재평가한다. 시술 후 경미한 불편감은 정상 반응일 수 있으나 급성 점액낭염이 의심되면 즉시 중단한다."}]'::jsonb,
  '{"pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"greater_trochanteric_pain","lateral_hip_pain","GTPS"}',
  '{"fracture","malignancy","acute_bursitis","acute_inflammation"}',
  'level_3'::evidence_level,
  '대전자 점액낭 주변 마찰은 만성 대전자 통증 증후군(GTPS)에서 조직 긴장 완화와 국소 혈류 촉진에 도움이 될 수 있다. 급성 점액낭염은 절대 금기이며, 만성 단계(수주 이상 경과)에서만 고려하는 것이 안전할 수 있다.',
  'fracture, malignancy, active_infection, acute_bursitis',
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
-- DFM-HipCapAnt: 엉덩 관절 전방 관절낭 심부마찰 마사지
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
  'DFM — 엉덩 관절 전방',
  '엉덩 관절 전방 관절낭 심부마찰 마사지', 'Hip Anterior Capsule Deep Friction Massage', 'DFM-HipCapAnt',
  'hip'::body_region, '엉덩 관절 전방 관절낭(서혜부 심부)',
  '바로 눕기, 무릎 약간 굽힌 위치',
  '환자 환측 옆, 서혜인대 하방 전방 관절낭 접근',
  '서혜부 심부 전방 관절낭 (손가락 끝)',
  '관절낭 방향에 수직으로 횡마찰',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 무릎 아래에 롤 타월을 받쳐 무릎을 약간 굽혀 서혜부가 이완된 자세를 만든다. 이 자세는 전방 관절낭에 접근하기 좋은 시작 위치다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 서혜인대를 촉진하여 그 하방에 위치한 전방 관절낭 투영 구역(대퇴동맥 외측)을 확인한다. 신경혈관 구조물을 피해 외측에서 접근한다."},{"step":3,"instruction":"손가락 끝이 관절낭 조직에 충분히 밀착되도록 서서히 압박하여 접촉 위치를 잡는다. 조직 저항이 느껴지는 깊이까지 부드럽게 접근하며, 환자의 편안한 통증 수준(4/10 이하)을 유지한다."},{"step":4,"instruction":"관절낭 섬유 방향에 수직으로 횡마찰을 리듬감 있게 시행한다. 압력은 저항이 느껴지는 수준으로 유지하며 동일한 범위와 속도로 반복한다."},{"step":5,"instruction":"3~5분 시행 후 엉덩 관절 굽히기·내회전 범위 및 서혜부 통증 변화를 재평가한다. 관절가동술과 병행 적용 시 시술 전 또는 후에 순서를 정해 일관되게 적용한다."}]'::jsonb,
  '{"pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"groin_pain","hip_flexion_restriction","anterior_hip_impingement"}',
  '{"fracture","malignancy","acute_inflammation","hip_joint_infection"}',
  'level_3'::evidence_level,
  '엉덩 관절 전방 관절낭 마찰은 관절낭 유착 및 섬유화 감소에 도움이 될 수 있다. 엉덩 관절 관절증 또는 유착성 관절낭염에서 관절가동술의 보조 치료로 활용될 수 있다. 서혜부 신경혈관 구조물을 피해 외측에서 접근하는 것이 안전할 수 있다.',
  'fracture, malignancy, active_infection, hip_joint_infection',
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
-- DFM-SacrTub: 천결절인대 심부마찰 마사지
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
  'DFM — 후방 골반 인대',
  '천결절인대 심부마찰 마사지', 'Sacrotuberous Ligament Deep Friction Massage', 'DFM-SacrTub',
  'hip'::body_region, '천결절인대(천골 외측 → 좌골결절)',
  '엎드려 눕기 또는 옆으로 눕기(환측 위)',
  '환자 뒤쪽, 좌골결절 내측 천결절인대 접촉',
  '천결절인대 (엄지 또는 검지·중지 중첩)',
  '인대 주행 방향에 수직으로 횡마찰',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 또는 환측이 위로 향하는 옆으로 눕기 자세로 위치시키고, 엉덩이 근육이 충분히 이완되도록 편안한 위치를 확보한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 위치하여 엄지 또는 검지·중지로 좌골결절을 촉진하고, 그 내측에서 천골 외측 방향으로 주행하는 천결절인대를 따라 압통 최대점을 확인한다."},{"step":3,"instruction":"손가락 끝이 인대 조직에 충분히 밀착되도록 피부를 약간 이동시켜 접촉 위치를 잡는다. 인대 특정 부착부(좌골결절 또는 천골 외측) 병변이 의심되면 해당 부위에 집중한다."},{"step":4,"instruction":"인대 섬유 방향에 수직으로 횡마찰을 리듬감 있게 시행한다. 압력은 저항이 느껴지는 수준으로 유지하며 동일한 범위와 속도로 반복한다."},{"step":5,"instruction":"3~5분 시행 후 후방 골반 통증 및 좌골결절 주변 압통 변화를 재평가한다. SIJ 가동술과 병행 적용 시 시술 전 또는 후에 순서를 정해 일관되게 적용한다."}]'::jsonb,
  '{"pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"posterior_pelvic_pain","SIJ_dysfunction","sacrotuberous_ligament_pain"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_3'::evidence_level,
  '천결절인대 마찰은 SIJ 기능장애와 후방 골반통에서 인대 긴장 완화에 도움이 될 수 있다. 산후 골반통 환자에서 SIJ 가동술과 병행 시 효과적일 수 있다. 좌골신경 주행 경로와 인접하므로 좌골신경통 증상이 동반되면 신경 압박 가능성을 감별하는 것이 중요할 수 있다.',
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
-- SECTION 7: category_trigger_point — 6 techniques (evidence_level = level_4)
-- =============================================================

-- ────────────────────────────────
-- HIP-TrP-Psoas: 장요근 트리거포인트 이완
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
  'TrP — 엉덩 굴근',
  '장요근 트리거포인트 이완', 'Psoas Trigger Point Release', 'HIP-TrP-Psoas',
  'hip'::body_region, '장요근 근복(하복부 외측) (연관통: 요추~서혜부~전방 대퇴)',
  '바로 눕기, 무릎 굽혀 발바닥을 테이블에 대고 이완',
  '환자 환측 옆, 하복부 외측 장요근 압통점 촉진',
  '장요근 근복 (손가락 끝)',
  '수직 허혈성 압박',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 무릎을 굽혀 발바닥을 테이블에 댄다. 이 자세는 복근과 장요근을 이완시켜 접근성을 높여준다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 배꼽 외측 2~3cm 지점에서 손가락 끝을 복벽에 부드럽게 접촉하고, 복강 내용물을 외측으로 밀어내듯 서서히 후방으로 압박하여 장요근 근복에 접근한다."},{"step":3,"instruction":"장요근 근복에서 단단한 띠(taut band)와 압통 결절(tender nodule)을 촉진하여 트리거포인트를 확인한다. 압박 후 연관통이 요추, 서혜부, 또는 전방 대퇴로 퍼지는지 확인한다."},{"step":4,"instruction":"트리거포인트에 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압통이 50~70% 감소할 때까지 7~10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 2~3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 장요근 신장 운동(런지 자세에서 전방 굴곡 제한)으로 치료 효과를 강화한다. 요추 통증 및 엉덩 관절 굽히기 범위 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"hip_flexor_pain","groin_pain","lumbar_pain","anterior_thigh_pain"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '장요근 트리거포인트는 요추 전방과 서혜부, 전방 대퇴로 퍼지는 연관통을 유발할 수 있다. 복강 내 구조물과 인접하므로 복부 압박 시 환자 반응을 면밀히 확인하며 서서히 접근하는 것이 안전할 수 있다. 최근 복부 수술 병력이 있는 경우 시술에 주의가 필요하다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, anticoagulant_therapy, recent_abdominal_surgery',
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
-- HIP-TrP-Pir: 이상근 트리거포인트 이완
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
  'TrP — 심부 외회전근',
  '이상근 트리거포인트 이완', 'Piriformis Trigger Point Release', 'HIP-TrP-Pir',
  'hip'::body_region, '이상근 근복(천골~대전자 중간) (연관통: 엉덩이 심부~후방 대퇴)',
  '엎드려 눕기 또는 옆으로 눕기(환측 위)',
  '환자 환측 옆, 후방 엉덩이 심부 이상근 압통점 촉진',
  '이상근 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 또는 환측이 위로 향하는 옆으로 눕기 자세로 위치시키고, 엉덩이 근육이 이완될 수 있도록 편안한 위치를 확보한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 천골과 대전자 사이의 중간점을 기준으로 이상근 근복을 촉진한다. 엄지 또는 검지·중지로 단단한 띠와 압통 결절을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 엉덩이 심부 또는 후방 대퇴로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50~70% 감소할 때까지 7~10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 이상근 주변 조직을 가볍게 이완 마사지한다. 2~3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 이상근 신장 운동(바로 눕기에서 무릎 굽히고 내회전) 또는 비둘기 자세로 치료 효과를 강화한다. 엉덩이 심부 통증 및 후방 대퇴 연관통 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"deep_gluteal_pain","posterior_thigh_pain","piriformis_syndrome","sciatic_like_pain"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '이상근 트리거포인트는 엉덩이 심부와 후방 대퇴로 퍼지는 연관통을 유발할 수 있다. 좌골신경통과 유사 증상을 보일 수 있어 감별진단이 필요하다. 이상근 증후군(piriformis syndrome) 진단 전 신경근 압박(추간판 탈출증 등)을 먼저 배제하는 것이 중요할 수 있다.',
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
-- HIP-TrP-TFL: 대퇴근막장근 트리거포인트 이완
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
  'TrP — 외측 엉덩이',
  '대퇴근막장근 트리거포인트 이완', 'TFL Trigger Point Release', 'HIP-TrP-TFL',
  'hip'::body_region, 'TFL 근복(전상장골극 하방) (연관통: 대전자 주변·외측 엉덩이)',
  '옆으로 눕기(환측 위) 또는 바로 눕기',
  '환자 환측 앞쪽 또는 옆쪽, 전상장골극 하방 TFL 압통점 촉진',
  'TFL 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 환측이 위로 향하는 옆으로 눕기 또는 바로 눕기 자세로 위치시키고 TFL 근복이 이완될 수 있도록 편안한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 앞쪽 또는 옆쪽에 서서 전상장골극 바로 하방의 TFL 근복을 촉진하여 단단한 띠와 압통 결절을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 대전자 주변 또는 외측 엉덩이로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50~70% 감소할 때까지 7~10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 TFL 주변 조직을 가볍게 이완 마사지한다. 2~3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 TFL 신장 운동(서 있는 자세에서 교차 발 옆으로 기울이기) 또는 엉덩이 외전 운동으로 치료 효과를 강화한다. 외측 엉덩이 통증 및 대전자 주변 압통 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"lateral_hip_pain","greater_trochanteric_pain","TFL_tightness"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  'TFL 트리거포인트는 대전자 주변과 외측 엉덩이로 퍼지는 연관통을 유발할 수 있다. 대전자 통증 증후군(GTPS) 및 장경인대 증후군과 연관된 경우가 많을 수 있어 함께 평가하는 것이 도움이 될 수 있다.',
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
-- HIP-TrP-GluMed: 중둔근 트리거포인트 이완
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
  'TrP — 외측 둔근',
  '중둔근 트리거포인트 이완', 'Gluteus Medius Trigger Point Release', 'HIP-TrP-GluMed',
  'hip'::body_region, '중둔근 근복(장골릉 외면~대전자 상방) (연관통: 외측 둔부~천장관절 구역)',
  '옆으로 눕기(환측 위) 또는 엎드려 눕기',
  '환자 환측 옆 또는 뒤쪽, 장골릉 하방 외면 중둔근 압통점 촉진',
  '중둔근 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 환측이 위로 향하는 옆으로 눕기 또는 엎드려 눕기 자세로 위치시키고 외측 엉덩이 근육이 이완될 수 있도록 편안한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 옆 또는 뒤쪽에 서서 장골릉 하방 외면을 따라 중둔근 근복을 촉진하여 단단한 띠와 압통 결절을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 외측 둔부 또는 천장관절 구역으로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50~70% 감소할 때까지 7~10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 중둔근 주변 조직을 가볍게 이완 마사지한다. 2~3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 중둔근 강화 운동(옆으로 눕기에서 다리 들어올리기, 클램 셸)으로 치료 효과를 강화한다. 외측 둔부 통증 및 천장관절 구역 압통 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"lateral_gluteal_pain","SIJ_pain","hip_abductor_weakness"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '중둔근 트리거포인트는 외측 둔부와 천장관절 구역으로 퍼지는 연관통을 유발할 수 있다. 만성 요통과 연관된 경우가 많아 요추 치료와 병행 평가가 필요할 수 있다. 중둔근 약화는 보행 시 트렌델렌버그 징후와 연관될 수 있어 근력 강화와 병행하는 것이 효과적일 수 있다.',
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
-- HIP-TrP-GluMax: 대둔근 트리거포인트 이완
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
  'TrP — 후방 둔근',
  '대둔근 트리거포인트 이완', 'Gluteus Maximus Trigger Point Release', 'HIP-TrP-GluMax',
  'hip'::body_region, '대둔근 근복(후방 장골~천골~좌골결절) (연관통: 후방 둔부 전반·미골 주변)',
  '엎드려 눕기',
  '환자 환측 옆, 후방 엉덩이 대둔근 근복 압통점 촉진',
  '대둔근 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고, 발목 아래에 타올을 받쳐 엉덩이 근육이 충분히 이완될 수 있는 편안한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 후방 장골릉에서 천골·좌골결절 방향으로 대둔근 근복을 촉진하여 단단한 띠와 압통 결절을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 후방 둔부 전반 또는 미골 주변으로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50~70% 감소할 때까지 7~10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 대둔근 주변 조직을 가볍게 이완 마사지한다. 2~3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 대둔근 신장 운동(바로 눕기에서 무릎을 가슴 방향으로 당기기) 및 강화 운동(브리지)으로 치료 효과를 강화한다. 후방 둔부 통증 및 앉기 시 통증 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"posterior_gluteal_pain","coccyx_pain","sitting_pain"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '대둔근 트리거포인트는 후방 둔부 전반과 미골 주변으로 퍼지는 연관통을 유발할 수 있다. 앉기 시 통증이 특징적이며 좌골 점액낭염과 감별이 필요할 수 있다. 오래 앉아서 일하는 환자에서 자주 발생할 수 있어 앉은 자세 교정 및 규칙적인 자세 변환 지도가 도움이 될 수 있다.',
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
-- HIP-TrP-Add: 내전근 트리거포인트 이완
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
  'TrP — 내측 대퇴',
  '내전근 트리거포인트 이완', 'Adductor Trigger Point Release', 'HIP-TrP-Add',
  'hip'::body_region, '장·단내전근 근복(치골~내측 대퇴 상부) (연관통: 서혜부·내측 대퇴·무릎 내측)',
  '바로 눕기, 환측 엉덩이 외전·외회전(개구리 다리)',
  '환자 환측 내측, 내전근 근복 압통점 촉진',
  '장·단내전근 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 환측 엉덩이를 외전·외회전하여 발바닥이 반대측 다리에 닿는 개구리 다리 자세를 만든다. 이 자세는 내전근에 접근하기 용이한 시작 위치다."},{"step":2,"instruction":"치료사는 환자 환측 내측에 서서 치골 하방에서 내측 대퇴 상부 방향으로 내전근 근복을 촉진하여 단단한 띠와 압통 결절을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 서혜부, 내측 대퇴, 또는 무릎 내측으로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50~70% 감소할 때까지 7~10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 내전근 주변 조직을 가볍게 이완 마사지한다. 2~3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 내전근 신장 운동(앉은 자세에서 나비 자세 또는 서 있는 자세에서 옆 런지)으로 치료 효과를 강화한다. 서혜부 통증 및 내측 대퇴 연관통 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"groin_pain","medial_thigh_pain","medial_knee_pain","adductor_tightness"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '내전근 트리거포인트는 서혜부와 내측 대퇴, 무릎 내측까지 퍼지는 연관통을 유발할 수 있다. 스포츠 서혜부 통증과 감별진단이 필요하다. 내전근 트리거포인트와 스포츠 서혜부 통증(운동 서혜통)이 공존하는 경우 내전근 강화 운동과 병행하는 것이 증상 관리에 도움이 될 수 있다.',
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
