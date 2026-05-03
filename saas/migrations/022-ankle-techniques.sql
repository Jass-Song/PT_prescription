-- ============================================================
-- Migration 022 — 발목 관절(ankle_foot) 기법 전체 (26개)
-- JM 6 + Mulligan 2 + MFR 4 + ART 3 + CTM 2 + DFM 4 + TrP 5
-- K-Movement Optimism / PT 처방 도우미
-- 생성일: 2026-04-28
-- 작성자: sw-db-architect
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

BEGIN;

-- =============================================================
-- SECTION 1: category_joint_mobilization — 6 techniques
-- =============================================================

-- ────────────────────────────────
-- ANK-JM-TCJ-PA: 거퇴관절 후방 PA 글라이드
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
  'Maitland — TCJ',
  '거퇴관절 후방 PA 글라이드', 'Talocrural Posterior PA Glide', 'ANK-JM-TCJ-PA',
  'ankle_foot'::body_region, 'TCJ 후방 관절낭',
  '엎드려 눕기, 발목 중립 위치',
  '환자 발쪽에 위치하여 한 손으로 경골 원위부를 안정화하고, 반대 손 손바닥 근위부 또는 두상골로 거골 후방면에 접촉 준비',
  '거골 후방면 (손바닥 근위부 또는 두상골)',
  '전방 PA 글라이드 (Grade II–IV)',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 발목이 테이블 끝 너머로 자연스럽게 걸리도록 하거나 발목 아래에 작은 쿠션을 받쳐 접근성을 높인다. 발목은 중립 위치(약 90도)에서 이완된 상태로 준비한다."},{"step":2,"instruction":"치료사는 환자 발쪽에 서서 한 손을 경골 원위부(복숭아뼈 약 5 cm 상방)에 올려 경골을 가볍게 안정화한다. 반대 손의 손바닥 근위부 또는 두상골을 거골 후방면(아킬레스건 바로 앞쪽)에 부드럽게 접촉한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade II는 관절 저항이 느껴지기 전 범위에서 리듬감 있는 소진폭 가동을 적용하고, Grade III–IV는 관절 끝 범위에서 대진폭 또는 소진폭 가동을 적용한다. 배측굴곡 제한이 클수록 Grade III–IV에서 효과를 기대할 수 있다."},{"step":4,"instruction":"거골 후방면에서 전방(복측) 방향으로 리듬감 있게 밀어주며 후방 관절낭의 이완 반응을 유도한다. 시술 중 환자의 발목 앞쪽 통증 또는 뒤쪽 조임 반응의 변화를 지속적으로 확인하여 Grade를 조정한다."},{"step":5,"instruction":"30초–1분 시술 후 발목 배측굴곡(등굽히기) 범위와 통증 정도를 재평가한다. ROM 증가 또는 통증 감소가 확인되면 Grade를 유지하거나 상향하여 2–3세트 반복한다. 필요 시 약간 굽힌 무릎 위치에서 동일 기법을 반복한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"ankle_pain","dorsiflexion_restriction","chronic_ankle_instability"}',
  '{"fracture","joint_infection","malignancy"}',
  'level_2b'::evidence_level,
  '배측굴곡 제한이 있을 때 거골 전방 위치 오류 교정에 효과적일 수 있다. Grade III–IV 적용 시 즉각적인 ROM 개선을 기대할 수 있으며, 만성 발목 불안정 환자에서 재활 중 활용 가능성이 있다. 아킬레스건 병변이 동반된 경우 접촉 위치를 조정하여 건 자극을 최소화하는 것이 안전할 수 있다.',
  'fracture, joint_infection, malignancy',
  'acute_sprain, severe_osteoporosis, anticoagulant_therapy',
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
-- ANK-JM-TCJ-AP: 거퇴관절 전방 AP 글라이드
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
  'Maitland — TCJ',
  '거퇴관절 전방 AP 글라이드', 'Talocrural Anterior AP Glide', 'ANK-JM-TCJ-AP',
  'ankle_foot'::body_region, 'TCJ 전방 관절낭',
  '바로 눕기, 발목 중립 위치',
  '환자 발쪽에 위치하여 한 손으로 경골 원위부를 안정화하고, 반대 손을 거골 전방면에 접촉 준비',
  '거골 전방면 (손바닥 또는 웹 스페이스)',
  '후방 AP 글라이드 (Grade II–IV)',
  '[{"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 발목 아래에 작은 쿠션이나 롤을 받쳐 발목을 약간 높이고 중립 위치(약 90도)에서 이완되도록 한다. 이 자세는 전방 관절낭에 적절한 이완을 제공하면서 거골 전방면 접근에 유리하다."},{"step":2,"instruction":"치료사는 환자 발쪽에 서서 한 손을 경골 원위부(복숭아뼈 5 cm 상방)에 올려 경골을 가볍게 안정화한다. 반대 손의 손바닥 또는 웹 스페이스를 거골 전방면(발등 관절선 바로 위쪽)에 접촉한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade II는 저항이 느껴지기 전 범위에서 리듬 가동, Grade III–IV는 끝 범위에서 대진폭 또는 소진폭 가동을 적용한다. 저측굴곡 제한이 있는 경우 발목을 약간 저측굴곡 방향으로 위치시킨 뒤 시작할 수 있다."},{"step":4,"instruction":"거골 전방면에서 후방(배측) 방향으로 리듬감 있게 밀어주며 전방 관절낭의 이완을 유도한다. 시술 중 환자의 발등 통증 또는 발목 앞쪽 조임 반응의 변화를 확인하여 Grade를 조정한다."},{"step":5,"instruction":"30초–1분 시술 후 발목 저측굴곡(발바닥굽히기) 범위와 종말감을 재평가한다. ROM 증가 또는 통증 감소가 확인되면 Grade를 유지하거나 상향하여 2–3세트 반복한다. 필요 시 저측굴곡 위치에서 동일 기법을 반복한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"ankle_pain","plantarflexion_restriction"}',
  '{"fracture","joint_infection","malignancy"}',
  'level_2b'::evidence_level,
  '저측굴곡 제한 및 전방 관절낭 단축이 의심될 때 적용 가능성이 높다. 발목 완전 펴기(저측굴곡) 제한이 있는 경우 Grade III–IV에서 즉각적인 ROM 개선을 기대할 수 있다. 전방 관절낭 손상이 의심되는 급성기에는 Grade I–II에서 시작하여 조직 반응을 평가하는 것이 안전할 수 있다.',
  'fracture, joint_infection, malignancy',
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
-- ANK-JM-TCJ-TRACT: 거퇴관절 장축 견인
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
  'Maitland — TCJ',
  '거퇴관절 장축 견인', 'Talocrural Long-axis Traction', 'ANK-JM-TCJ-TRACT',
  'ankle_foot'::body_region, 'TCJ 관절강',
  '바로 눕기 또는 앉은 자세, 발목 중립',
  '환자 발쪽에 위치하여 양 손으로 발 전족부를 파지',
  '발 전족부 (양 손 파지)',
  '장축 원위부 견인 (Distraction)',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 앉은 자세로 위치시키고 발목이 중립(약 90도)에서 편안하게 이완되도록 한다. 바로 눕기 자세에서는 발목 아래에 쿠션을 받쳐 치료사의 파지 접근성을 높일 수 있다."},{"step":2,"instruction":"치료사는 환자 발쪽에 서서 양 손으로 발 전족부(중족골 근위부 수준)를 확실히 파지한다. 손목과 전완이 견인 방향(발목 장축)에 일직선이 되도록 자세를 잡는다."},{"step":3,"instruction":"Grade I–II 통증 조절 목적 시 관절 저항이 느껴지기 전 범위에서 부드럽고 리드미컬하게 견인을 가하고 해제를 반복한다. Grade III–IV ROM 개선 목적 시 관절 끝 저항이 느껴지는 범위까지 서서히 견인 강도를 높인다."},{"step":4,"instruction":"발목 장축(원위부) 방향으로 리듬감 있게 견인을 가하며 관절 내압 감소와 관절낭 이완을 유도한다. 시술 중 환자의 발목 통증 또는 묵직한 감각의 변화를 지속적으로 확인한다."},{"step":5,"instruction":"30초–1분 시술 후 발목 굽히기·펴기 범위와 통증 정도를 재평가한다. 통증 감소 또는 ROM 증가가 확인되면 Grade를 유지하거나 상향하여 2–3세트 반복한다. 통증 조절 목적이라면 Grade I–II로 세션 전반에 걸쳐 반복 적용할 수 있다."}]'::jsonb,
  '{"pain_relief","joint_decompression"}',
  '{"subacute","chronic"}',
  '{"ankle_pain","rest_pain","movement_pain"}',
  '{"fracture","joint_infection","malignancy"}',
  'level_2b'::evidence_level,
  '장축 견인은 발목 관절 내압 감소와 통증 억제에 효과적일 수 있다. Grade I–II로 급성~아급성 통증 조절에 활용 가능성이 있으며, Grade III–IV는 관절가동범위 개선 목적에 적합할 수 있다. 발목 염좌 후 초기 통증 조절 단계에서 안전한 첫 번째 선택 기법 중 하나로 고려할 수 있다.',
  'fracture, joint_infection, malignancy',
  'acute_sprain, severe_osteoporosis',
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
-- ANK-JM-STJ-MED: 거종관절 내측 글라이드
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
  '거종관절 내측 글라이드', 'Subtalar Medial Glide', 'ANK-JM-STJ-MED',
  'ankle_foot'::body_region, 'STJ 외측 관절낭',
  '옆으로 눕기(환측 위) 또는 엎드려 눕기',
  '환자 발쪽에 위치하여 한 손으로 경골 원위부를 안정화하고, 반대 손 손바닥 근위부로 종골 외측면에 접촉 준비',
  '종골 외측면 (손바닥 근위부)',
  '내측 글라이드 (Grade II–IV)',
  '[{"step":1,"instruction":"환자를 옆으로 눕기(환측이 위) 자세로 위치시키거나 엎드려 눕기를 선택한다. 옆으로 눕기 자세에서는 발목이 테이블 끝 너머로 자연스럽게 걸리도록 하거나 발 아래에 쿠션을 받쳐 종골 외측면 접근성을 높인다."},{"step":2,"instruction":"치료사는 환자 발쪽에 서서 한 손을 경골 원위부(외측 복숭아뼈 5 cm 상방)에 올려 경골과 거골 관계를 가볍게 고정한다. 반대 손의 손바닥 근위부를 종골 외측면에 확실하게 접촉한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade II는 관절 저항이 느껴지기 전 범위에서 리듬감 있는 소진폭 가동을 적용하고, Grade III–IV는 관절 끝 범위에서 대진폭 또는 소진폭 가동을 적용한다. 후족부 회내 제한이 클수록 Grade III–IV에서 효과를 기대할 수 있다."},{"step":4,"instruction":"종골 외측면에서 내측 방향으로 리듬감 있게 밀어주며 외측 관절낭의 이완 반응을 유도한다. 시술 중 환자의 발목 외측 또는 후족부 통증 변화를 지속적으로 확인하여 Grade를 조정한다."},{"step":5,"instruction":"30초–1분 시술 후 후족부 회내(발 안쪽 돌리기) 범위와 통증 정도를 재평가한다. ROM 증가 또는 통증 감소가 확인되면 Grade를 유지하거나 상향하여 2–3세트 반복한다. 내번 염좌 후 회복 단계에서 조직 반응에 따라 Grade를 조정한다."}]'::jsonb,
  '{"rom_improvement","pain_relief"}',
  '{"subacute","chronic"}',
  '{"subtalar_stiffness","inversion_sprain_recovery","hindfoot_pain"}',
  '{"fracture","joint_infection","malignancy"}',
  'level_2b'::evidence_level,
  '거종관절 내측 글라이드는 후족부 회내 제한 및 내번 발목 염좌 후 회복에 도움이 될 수 있다. 만성 발목 불안정 환자에서 거종관절 가동성 회복을 위한 보조 기법으로 활용 가능성이 있다. 급성 내번 염좌에서는 Grade I–II에서 시작하여 통증 반응을 평가한 후 Grade를 올리는 것이 안전할 수 있다.',
  'fracture, joint_infection, malignancy',
  'acute_sprain, severe_osteoporosis',
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
-- ANK-JM-STJ-LAT: 거종관절 외측 글라이드
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
  '거종관절 외측 글라이드', 'Subtalar Lateral Glide', 'ANK-JM-STJ-LAT',
  'ankle_foot'::body_region, 'STJ 내측 관절낭',
  '바로 눕기 또는 엎드려 눕기',
  '환자 발쪽에 위치하여 한 손으로 경골 원위부를 안정화하고, 반대 손을 종골 내측면에 접촉 준비',
  '종골 내측면 (손바닥 근위부)',
  '외측 글라이드 (Grade II–IV)',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 엎드려 눕기 자세로 위치시키고 발목이 중립 또는 약간 내번된 위치에서 이완되도록 한다. 바로 눕기 자세에서는 발목 아래에 쿠션을 받쳐 종골 내측면 접근성을 확보한다."},{"step":2,"instruction":"치료사는 환자 발쪽에 서서 한 손을 경골 원위부(내측 복숭아뼈 5 cm 상방)에 올려 경골을 가볍게 고정한다. 반대 손의 손바닥 근위부를 종골 내측면에 확실하게 접촉한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade II는 저항이 느껴지기 전 범위에서 리듬 가동, Grade III–IV는 끝 범위에서 대진폭 또는 소진폭 가동을 적용한다. 후족부 회외 제한이 있는 경우 Grade III–IV에서 효과를 기대할 수 있다."},{"step":4,"instruction":"종골 내측면에서 외측 방향으로 리듬감 있게 밀어주며 내측 관절낭의 이완을 유도한다. 시술 중 환자의 발목 내측 또는 후족부 통증 변화를 확인하여 Grade를 조정한다."},{"step":5,"instruction":"30초–1분 시술 후 후족부 회외(발 바깥쪽 돌리기) 범위와 종말감을 재평가한다. ROM 증가 또는 통증 감소가 확인되면 Grade를 유지하거나 상향하여 2–3세트 반복한다. 후족부 내반 변형(hindfoot varus)이 있는 경우 장기적인 가동성 회복 목표로 활용 가능하다."}]'::jsonb,
  '{"rom_improvement","pain_relief"}',
  '{"subacute","chronic"}',
  '{"subtalar_stiffness","hindfoot_varus","hindfoot_pain"}',
  '{"fracture","joint_infection","malignancy"}',
  'level_2b'::evidence_level,
  '거종관절 외측 글라이드는 후족부 회외 제한 및 외번 발목 불안정에서 관절가동성 회복에 도움이 될 수 있다. 후족부 내반 변형이 있는 환자에서 보조적 기법으로 활용 가능성이 있다. 급성기에는 Grade I–II에서 시작하여 조직 반응을 평가한 후 Grade를 올리는 것이 안전할 수 있다.',
  'fracture, joint_infection, malignancy',
  'acute_sprain, severe_osteoporosis',
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
-- ANK-JM-MTJ-DORS: 중족관절 배측 글라이드
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
  'Maitland — MTJ',
  '중족관절 배측 글라이드', 'Midtarsal Dorsal Glide', 'ANK-JM-MTJ-DORS',
  'ankle_foot'::body_region, '중족관절(Chopart) 배측면',
  '바로 눕기 또는 앉은 자세',
  '환자 발쪽에 위치하여 한 손으로 후족부를 고정하고, 반대 손 손바닥 근위부로 중족부 배측면에 접촉 준비',
  '중족부 배측면 (손바닥 근위부)',
  '배측 글라이드 (Grade II–IV)',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 앉은 자세로 위치시키고 발이 중립 위치에서 이완되도록 한다. 바로 눕기 자세에서는 발목 아래에 쿠션을 받쳐 중족부 배측면 접근성을 확보한다. 앉은 자세에서는 치료사 무릎 위에 발을 올려 작업하는 것도 가능하다."},{"step":2,"instruction":"치료사는 환자 발쪽에 서거나 앉아서 한 손으로 종골과 거골 부위(후족부)를 확실하게 고정한다. 반대 손의 손바닥 근위부를 중족부 배측면(Chopart 관절선 직전)에 부드럽게 접촉한다."},{"step":3,"instruction":"Grade에 따라 힘 범위를 조절한다. Grade II는 관절 저항이 느껴지기 전 범위에서 리듬감 있는 소진폭 가동을 적용하고, Grade III–IV는 관절 끝 범위에서 대진폭 또는 소진폭 가동을 적용한다. 중족부 경직이 심할수록 Grade III–IV에서 효과를 기대할 수 있다."},{"step":4,"instruction":"중족부 배측면에서 배측(발등 방향) 글라이드를 리듬감 있게 적용하며 중족관절 배측 관절낭의 이완 반응을 유도한다. 시술 중 환자의 발 중간 부위 통증 또는 발바닥 당기는 감각의 변화를 지속적으로 확인한다."},{"step":5,"instruction":"30초–1분 시술 후 중족부 가동범위(배측굴곡·저측굴곡)와 통증 정도를 재평가한다. ROM 증가 또는 통증 감소가 확인되면 Grade를 유지하거나 상향하여 2–3세트 반복한다. 족저근막염과 연관된 중족부 제한이 있는 경우 족저근막 스트레칭과 병행하면 효과를 높일 수 있다."}]'::jsonb,
  '{"rom_improvement","pain_relief"}',
  '{"subacute","chronic"}',
  '{"midfoot_stiffness","plantar_fasciitis_associated","foot_pain"}',
  '{"fracture","joint_infection","malignancy"}',
  'level_2b'::evidence_level,
  '중족관절 배측 글라이드는 중족부 경직 및 족저근막염과 연관된 중족부 가동성 제한 개선에 도움이 될 수 있다. 장시간 체중 부하로 중족부가 경직된 환자에서 가동성 회복의 보조 기법으로 활용 가능성이 있다. 족저근막염이 동반된 경우 중족부 배측 글라이드와 함께 종골 패딩 및 내재근 강화 운동을 병행하는 것이 효과적일 수 있다.',
  'fracture, joint_infection, malignancy',
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
-- SECTION 2: category_mulligan — 2 techniques
-- =============================================================

-- ────────────────────────────────
-- ANK-MUL-DF: 발목 배측굴곡 MWM
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
  'Mulligan MWM — 발목 관절',
  '발목 배측굴곡 MWM', 'Ankle Dorsiflexion MWM', 'ANK-MUL-DF',
  'ankle_foot'::body_region, 'TCJ 거골',
  '서 있는 자세 또는 앉은 자세 — 치료 발을 앞으로 내밀어 체중 부하 준비',
  '환자 앞쪽 또는 환측 옆에 위치하여 웨빙 벨트 또는 손바닥으로 거골 전방면을 후방으로 글라이드 유지',
  '거골 전방면 (웨빙 벨트 또는 손바닥)',
  '후방 글라이드 유지하며 환자 능동 배측굴곡(앞으로 체중 이동)',
  '[{"step":1,"instruction":"환자를 서 있는 자세 또는 앉은 자세로 위치시킨다. 서 있는 자세를 선호할 경우 치료 발을 한 발 앞으로 내밀고 무릎을 약간 굽힌 채 체중 부하를 준비한다. 앉은 자세라면 발을 바닥에 평평하게 붙이고 앞으로 밀 준비를 한다."},{"step":2,"instruction":"치료사는 웨빙 벨트(Mobilization Belt)를 거골 전방면(발등 관절선 직상부)에 걸어 고정하거나, 양 엄지손가락을 거골 전방면에 접촉한다. 벨트를 사용할 경우 치료사의 허리 또는 어깨에 걸어 장력을 일정하게 유지한다."},{"step":3,"instruction":"거골 전방면에 후방 글라이드(발뒤꿈치 방향)를 지속적으로 유지하면서 환자에게 천천히 무릎을 앞으로 밀거나 앞으로 체중을 이동시켜 능동 배측굴곡 운동을 수행하도록 지시한다. 글라이드는 운동 내내 일정하게 유지해야 한다."},{"step":4,"instruction":"환자가 통증 없이 배측굴곡 가동범위를 수행하는지 확인한다. 통증이 유발되면 글라이드 방향 또는 강도를 미세 조정한다. 일반적으로 10회 반복을 1세트로 하며 재평가 후 2–3세트 반복한다."},{"step":5,"instruction":"시술 후 체중 부하 상태에서 발목 배측굴곡 범위(무릎-벽 검사 등)와 스쿼트 깊이를 재평가한다. 즉각적인 ROM 증가가 확인되면 기법의 적용이 적합한 것으로 판단할 수 있다. 필요 시 홈 프로그램으로 웨빙 벨트 자가 MWM을 교육할 수 있다."}]'::jsonb,
  '{"pain_relief","rom_improvement","functional_improvement"}',
  '{"subacute","chronic"}',
  '{"dorsiflexion_restriction","ankle_stiffness","squat_difficulty"}',
  '{"fracture","joint_infection","malignancy"}',
  'level_2b'::evidence_level,
  '발목 배측굴곡 MWM은 만성 발목 강직 및 배측굴곡 제한에서 즉각적인 ROM 개선을 기대할 수 있다. 거골 전방 위치 오류가 의심되는 경우 특히 효과적일 수 있으며, 체중 부하 기능 동작(스쿼트, 계단 오르기)과 연계하여 적용하면 기능적 전이 효과를 높일 수 있다. 시술 중 통증이 있으면 즉시 멈추고 글라이드 방향을 재평가하는 것이 안전하다.',
  'fracture, joint_infection, malignancy',
  'instability, acute_sprain, acute_inflammation',
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
-- ANK-MUL-INV: 발목 내번 염좌 MWM
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
  'Mulligan MWM — 발목 관절',
  '발목 내번 염좌 MWM', 'Ankle Inversion Sprain MWM', 'ANK-MUL-INV',
  'ankle_foot'::body_region, 'TCJ 외측 인대 복합체',
  '서 있는 자세 또는 앉은 자세',
  '환자 환측 옆에 위치하여 종골을 외측에서 내측으로 글라이드 유지',
  '종골 외측면 (손바닥 또는 웨빙 벨트)',
  '내측 글라이드 유지하며 환자 능동 배측굴곡 또는 기능 동작',
  '[{"step":1,"instruction":"환자를 서 있는 자세 또는 앉은 자세로 위치시킨다. 서 있는 자세에서는 치료 발에 점진적 체중 부하를 준비하고, 앉은 자세에서는 발을 바닥에 평평하게 붙인다. 환자가 내번 염좌 후 체중 부하 시 통증을 호소하는 경우 앉은 자세에서 시작할 수 있다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 위치하여 웨빙 벨트 또는 양 손 손바닥을 종골 외측면에 접촉한다. 종골을 외측에서 내측 방향으로 글라이드가 유지되도록 일정한 장력을 건다."},{"step":3,"instruction":"종골 내측 글라이드를 지속적으로 유지하면서 환자에게 천천히 발목을 배측굴곡하거나 체중 부하 기능 동작(뒤꿈치 들기, 스쿼트 등)을 수행하도록 지시한다. 글라이드는 운동 내내 일정하게 유지해야 한다."},{"step":4,"instruction":"환자가 통증 없이 기능 동작을 수행하는지 확인한다. 통증이 유발되면 글라이드 방향·강도를 미세 조정한다. 일반적으로 10회 반복을 1세트로 하며 재평가 후 2–3세트 반복한다."},{"step":5,"instruction":"시술 후 체중 부하 상태에서 발목 기능 동작(한 발 서기, 계단 오르기 등)과 통증 정도를 재평가한다. 즉각적인 기능 개선이 확인되면 기법의 적용이 적합한 것으로 판단할 수 있다. 만성 발목 불안정이 동반된 경우 균형 및 고유감각 훈련과 병행하는 것이 효과적일 수 있다."}]'::jsonb,
  '{"pain_relief","rom_improvement","stability_improvement"}',
  '{"subacute","chronic"}',
  '{"chronic_ankle_instability","inversion_sprain","lateral_ankle_pain"}',
  '{"fracture","joint_infection","malignancy","grade3_ligament_rupture_acute"}',
  'level_2b'::evidence_level,
  '내번 염좌 후 만성 발목 기능장애에서 MWM은 통증 없는 기능 회복에 도움이 될 수 있다. 아급성~만성 단계에서 체중 부하 기능 동작과 연계하여 적용하면 외측 인대 복합체의 기능적 안정성 회복에 효과적일 수 있다. 급성 2도 이상 인대 파열이 의심되는 경우에는 조직 안정성이 확보된 후 시작하는 것이 안전하다.',
  'fracture, joint_infection, malignancy, grade3_ligament_rupture_acute',
  'acute_sprain_grade2plus, severe_instability, acute_inflammation',
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
-- Migration 022 (Part 2): Ankle — MFR + ART + CTM (9 techniques)
-- category_mfr (4) + category_art (3) + category_ctm (2)
-- body_region = 'ankle_foot', evidence_level = 'level_4'
-- sw-db-architect | 2026-04-28

-- =============================================================
-- SECTION 3: category_mfr — 4 techniques
-- =============================================================

-- ────────────────────────────────
-- ANK-MFR-GastSol: 비복근·가자미근 근막이완
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
  '비복근·가자미근 근막이완', 'Gastrocnemius-Soleus Complex MFR', 'ANK-MFR-GastSol',
  'ankle_foot'::body_region, '비복근·가자미근 복합체(후방 하퇴 ~ 아킬레스건)',
  '엎드려 눕기 또는 바로 눕기',
  '환자 발쪽, 후방 하퇴 전반 접촉',
  '비복근·가자미근 복합체 (손바닥 또는 전완)',
  '조직 제한 방향으로 지속 압박 후 이완',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 또는 바로 눕기 자세로 위치시키고 발목이 테이블 끝에 걸쳐 자연스럽게 이완되도록 한다. 비복근과 가자미근이 모두 이완된 상태인지 확인한다."},{"step":2,"instruction":"치료사는 환자 발쪽에 서서 손바닥 또는 전완을 비복근·가자미근 복합체(오금에서 아킬레스건 부착부 방향) 근복에 부드럽게 접촉한다. 접촉 면적을 최대화하여 조직에 균일한 압박을 가한다."},{"step":3,"instruction":"지속적이고 부드러운 압박을 가하며 조직이 이완되는 느낌을 기다린다. 90–120초 동안 조직 제한 방향으로 서서히 압박을 심화하되, 환자가 통증이 아닌 늘어나는 느낌을 경험하도록 강도를 조절한다."},{"step":4,"instruction":"근막 이완이 느껴지면 그 방향으로 접촉을 따라가며(follow) 추가 이완을 유도한다. 비복근 상부에서 가자미근 하부 방향으로, 또는 역방향으로 이동하며 조직 전반의 이동성을 개선한다."},{"step":5,"instruction":"시술 후 발목 능동 배측굴곡 범위를 재평가한다. 범위 개선이 확인되면 해당 부위 또는 인접 제한 구역에 추가 시술을 진행하고, 가정 운동으로 종아리 스트레칭을 지도한다."}]'::jsonb,
  '{"tissue_release","rom_improvement","pain_relief"}',
  '{"subacute","chronic"}',
  '{"dorsiflexion_restriction","calf_tightness","plantar_fasciitis"}',
  '{"fracture","malignancy","active_infection","DVT"}',
  'level_4'::evidence_level,
  '비복근·가자미근 근막 단축은 발목 배측굴곡 제한의 주요 원인이 될 수 있다. 스쿼트 및 계단 오르기 동작 제한과 직결되며 족저근막염과도 연관될 수 있음.',
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

-- ────────────────────────────────
-- ANK-MFR-PlantFas: 족저근막 이완
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
  'MFR — 족저 구역',
  '족저근막 이완', 'Plantar Fascia MFR', 'ANK-MFR-PlantFas',
  'ankle_foot'::body_region, '족저근막(종골 내측결절 → 중족골두 족저면)',
  '엎드려 눕기 또는 앉은 자세',
  '환자 발쪽, 발바닥 족저근막 접촉',
  '족저근막 (엄지 또는 손가락 끝, 종골 ~ 중족골두 방향)',
  '종골 내측결절에서 중족골두 방향으로 지속 압박 후 이완',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 또는 앉은 자세로 위치시키고 발이 편안하게 이완되도록 한다. 엎드려 눕기 시 발목 아래에 작은 쿠션을 받쳐 족저면에 접근성을 높인다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 한 손으로 발뒤꿈치를 가볍게 고정하고, 반대 손의 엄지 또는 손가락 끝을 종골 내측결절(아킬레스건 부착부 바로 앞)에 접촉한다. 조직에 균일하고 부드러운 압박을 가한다."},{"step":3,"instruction":"종골 내측결절에서 중족골두 방향으로 서서히 압박을 심화하며 족저근막 조직이 이완되는 느낌을 기다린다. 90–120초 동안 지속 압박을 유지하되, 환자가 통증이 아닌 당기는 느낌을 경험하도록 강도를 조절한다."},{"step":4,"instruction":"근막 이완이 느껴지면 그 방향으로 접촉을 따라가며 추가 이완을 유도한다. 종골 내측에서 족저근막 내측·중간·외측 띠를 순서대로 이동하며 족저 전반의 이동성을 개선한다."},{"step":5,"instruction":"시술 후 발가락을 위로 들어올렸을 때 족저 긴장도와 통증을 재평가한다. 아침 첫 발걸음 통증 패턴 환자에게는 기상 전 발가락 능동 신전 운동과 종아리 스트레칭을 가정 운동으로 지도한다."}]'::jsonb,
  '{"tissue_release","pain_relief"}',
  '{"subacute","chronic"}',
  '{"plantar_fasciitis","heel_pain","morning_pain"}',
  '{"fracture","malignancy","active_infection","plantar_fascia_rupture"}',
  'level_4'::evidence_level,
  '족저근막 이완은 족저근막염의 통증 완화와 조직 이동성 개선에 도움이 될 수 있다. 아침 첫 발걸음 통증이 특징적인 환자에서 운동치료와 병행 시 효과적일 수 있음.',
  'fracture, malignancy, active_infection, plantar_fascia_rupture',
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
-- ANK-MFR-Achilles: 아킬레스건 주변 근막이완
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
  'MFR — 아킬레스건',
  '아킬레스건 주변 근막이완', 'Achilles Peritendinous MFR', 'ANK-MFR-Achilles',
  'ankle_foot'::body_region, '아킬레스건 및 주변 건막(하퇴 원위부 ~ 종골 부착부)',
  '엎드려 눕기, 발목 중립 위치',
  '환자 발쪽, 아킬레스건 양측 건막 접촉',
  '아킬레스건 내측·외측 건막 (엄지와 검지로 양측 집기)',
  '건 양측 건막에 지속 압박 후 미끄러짐 유도',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 발목을 중립 위치(저측굴곡도 배측굴곡도 아닌 위치)로 이완한다. 발목 아래에 작은 쿠션을 받쳐 아킬레스건에 대한 접근성을 확보한다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 엄지와 검지(또는 양손 엄지)를 아킬레스건 내측과 외측 건막에 각각 접촉한다. 건 자체를 직접 압박하지 않고 건 양측 건막 조직에 부드럽게 접촉하는 것이 중요하다."},{"step":3,"instruction":"양측 건막에 지속적이고 부드러운 압박을 가하며 조직이 이완되기를 기다린다. 건막 조직이 손가락 사이에서 서서히 부드러워지는 느낌이 날 때까지 90–120초 동안 압박을 유지한다."},{"step":4,"instruction":"건막 이완이 느껴지면 건의 장축 방향(상하)으로 가볍게 미끄러짐을 유도하여 건과 주변 건막 사이의 유착을 완화한다. 종골 부착부에서 근건 이행부 방향으로 이동하며 전 구간을 시술한다."},{"step":5,"instruction":"시술 후 발꿈치 들기(힐레이즈)와 발목 배측굴곡 범위를 재평가한다. 건 자체에 압박이 가해지지 않도록 주의하며, 아급성 이후 단계에서만 시행하고 편심성 수축 운동과 병행을 권장한다."}]'::jsonb,
  '{"tissue_release","pain_relief","tendon_rehabilitation"}',
  '{"subacute","chronic"}',
  '{"achilles_tendinopathy","posterior_ankle_pain","calf_tightness"}',
  '{"fracture","malignancy","active_infection","achilles_complete_rupture"}',
  'level_4'::evidence_level,
  '아킬레스건 주변 근막이완은 건막 유착 감소와 건 미끄러짐 개선에 도움이 될 수 있다. 아킬레스 건병증의 보존적 치료 보조로 활용될 수 있음.',
  'fracture, malignancy, active_infection, achilles_complete_rupture',
  'acute_tendinitis, anticoagulant_therapy',
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
-- ANK-MFR-Peron: 비골근 근막이완
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
  'MFR — 외측 하퇴',
  '비골근 근막이완', 'Peroneal MFR', 'ANK-MFR-Peron',
  'ankle_foot'::body_region, '장·단비골근(비골 외측면 → 제5중족골 기저부·내측 설상골)',
  '옆으로 눕기(환측 위) 또는 앉은 자세',
  '환자 뒤쪽 또는 옆쪽, 외측 하퇴 비골근 접촉',
  '외측 하퇴 장·단비골근 근복 (손바닥 또는 전완)',
  '조직 제한 방향으로 지속 압박 후 이완',
  '[{"step":1,"instruction":"환자를 옆으로 눕기(환측 위) 또는 앉은 자세로 위치시키고 외측 하퇴 비골근 구역이 충분히 노출되도록 한다. 옆으로 눕기 시 머리 아래 베개를 받치고 위쪽 다리(환측)의 발목이 자연스럽게 이완되도록 조정한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽 또는 옆쪽에 위치하여 손바닥 또는 전완을 비골 외측면을 따라 장·단비골근 근복에 접촉한다. 비골 자체에 직접 압박이 가해지지 않도록 근복 쪽으로 접촉 위치를 조정한다."},{"step":3,"instruction":"지속적이고 부드러운 압박을 가하며 외측 하퇴 비골근 조직이 이완되는 느낌을 기다린다. 90–120초 동안 조직 제한 방향으로 서서히 압박을 심화하되, 환자가 통증이 아닌 압박감을 경험하도록 강도를 조절한다."},{"step":4,"instruction":"근막 이완이 느껴지면 그 방향으로 접촉을 따라가며 추가 이완을 유도한다. 비골 원위부(외과 근처)에서 비골 근위부(비골두 근처) 방향으로 이동하며 근막 전반의 이동성을 개선한다."},{"step":5,"instruction":"시술 후 발목 능동 외번 범위와 외측 발목 통증 정도를 재평가한다. 만성 발목 불안정 환자에게는 비골근 강화 및 고유감각 훈련과 병행을 권장하며, 내번 염좌 후 반사적 경련 지속 시 초기 단계로 활용 가능성이 있다."}]'::jsonb,
  '{"tissue_release","pain_relief","stability_improvement"}',
  '{"subacute","chronic"}',
  '{"lateral_ankle_pain","peroneal_tightness","chronic_ankle_instability"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '비골근 근막 긴장은 외측 발목 통증 및 만성 발목 불안정의 원인이 될 수 있다. 내번 염좌 후 반사적 비골근 경련이 지속되는 경우에서 빈번히 관찰됨.',
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
-- SECTION 4: category_art — 3 techniques
-- =============================================================

-- ────────────────────────────────
-- ART-GastAnkle: 비복근 능동적 이완기법
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
  'ART — 하퇴 후방',
  '비복근 능동적 이완기법', 'Gastrocnemius Active Release Technique', 'ART-GastAnkle',
  'ankle_foot'::body_region, '비복근 근복(후방 하퇴 상부)',
  '엎드려 눕기',
  '환자 발쪽, 비복근 근복 접촉 압박 유지',
  '비복근 근복 (엄지 또는 검지·중지)',
  '접촉 유지하며 발목을 저측굴곡에서 배측굴곡으로 능동 이동',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 치료 측 발이 테이블 밖으로 자유롭게 움직일 수 있도록 발목 부분을 테이블 끝에 위치시킨다. 발목을 저측굴곡(발끝 내리기) 시작 위치로 세팅한다."},{"step":2,"instruction":"치료사는 환자 발쪽에 서서 엄지 또는 검지·중지를 비복근 근복(오금 바로 아래 ~ 비복근 근복 중간) 단축 조직에 충분한 접촉 압박을 가한다. 조직 장력이 느껴지는 지점까지 압박을 심화한 뒤 그 위치를 유지한다."},{"step":3,"instruction":"치료사가 접촉 압박을 유지하는 상태에서 환자에게 발목을 저측굴곡 위치에서 최대 배측굴곡 위치까지 천천히 능동적으로 이동하도록 지시한다. 이 과정에서 근막이 접촉점 아래로 미끄러지며 유착이 해소된다."},{"step":4,"instruction":"발목이 최대 배측굴곡에 도달하면 치료사가 접촉을 유지한 채 환자에게 다시 저측굴곡으로 천천히 돌아오도록 지시한다. 접촉 위치를 비복근 근복 전체에 걸쳐 이동하며 2–3회 반복한다."},{"step":5,"instruction":"시술 후 능동 발목 배측굴곡 범위와 비복근 촉진 압통 정도를 재평가한다. 과사용 부위 또는 유착이 심한 구역에는 접촉 위치를 변경하여 추가 시술하고, 달리기 선수의 경우 점진적 부하 복귀 프로그램과 병행을 권장한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"calf_pain","dorsiflexion_restriction","achilles_tightness"}',
  '{"fracture","malignancy","active_infection","DVT"}',
  'level_4'::evidence_level,
  '비복근 ART는 과사용 또는 반복적 달리기로 인한 근막 유착 해소에 효과적일 수 있다.',
  'fracture, malignancy, active_infection, DVT',
  'achilles_complete_rupture, acute_inflammation, anticoagulant_therapy',
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
-- ART-PeronAnkle: 비골근 능동적 이완기법
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
  'ART — 외측 하퇴',
  '비골근 능동적 이완기법', 'Peroneals Active Release Technique', 'ART-PeronAnkle',
  'ankle_foot'::body_region, '장·단비골근 근복(외측 하퇴 중간)',
  '옆으로 눕기(환측 위)',
  '환자 뒤쪽, 외측 하퇴 비골근 근복 접촉 압박 유지',
  '장·단비골근 근복 (엄지 또는 검지·중지)',
  '접촉 유지하며 발목을 외번에서 내번 방향으로 능동 이동',
  '[{"step":1,"instruction":"환자를 옆으로 눕기(환측 위) 자세로 위치시키고 머리 아래 베개를 받친다. 치료 측 발목이 테이블 끝에 걸쳐 자유롭게 움직일 수 있도록 위치를 조정하고, 발목을 외번(발바닥 바깥쪽 들기) 시작 위치로 세팅한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 서서 엄지 또는 검지·중지를 외측 하퇴 장·단비골근 근복(비골 중간 ~ 원위부)의 단축 조직에 충분한 접촉 압박을 가한다. 비골 자체에 직접 압박이 가해지지 않도록 근복 쪽에 접촉한다."},{"step":3,"instruction":"치료사가 접촉 압박을 유지하는 상태에서 환자에게 발목을 외번 위치에서 내번 방향으로 천천히 능동적으로 이동하도록 지시한다. 이 과정에서 비골근 근막이 접촉점 아래로 미끄러지며 유착이 해소된다."},{"step":4,"instruction":"발목이 내번 위치에 도달하면 치료사가 접촉을 유지한 채 환자에게 다시 외번 위치로 천천히 돌아오도록 지시한다. 접촉 위치를 장비골근 근복에서 단비골근 근복으로 이동하며 2–3회 반복한다."},{"step":5,"instruction":"시술 후 능동 발목 외번 범위와 외측 하퇴 촉진 압통 정도를 재평가한다. 내번 염좌 후 비골근 경련이 지속되는 경우 초기 치료로 활용 가능성이 있으며, 고유감각 및 균형 훈련과 병행을 권장한다."}]'::jsonb,
  '{"tissue_release","pain_relief","stability_improvement"}',
  '{"subacute","chronic"}',
  '{"lateral_ankle_pain","peroneal_tightness","chronic_instability"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '비골근 ART는 내번 염좌 후 비골근 경련과 외측 하퇴 유착 해소에 도움이 될 수 있다.',
  'fracture, malignancy, active_infection',
  'peroneal_complete_tear, acute_inflammation, anticoagulant_therapy',
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
-- ART-TibAnt: 전경골근 능동적 이완기법
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
  'ART — 전방 하퇴',
  '전경골근 능동적 이완기법', 'Tibialis Anterior Active Release Technique', 'ART-TibAnt',
  'ankle_foot'::body_region, '전경골근 근복(경골 외측면 ~ 내측 설상골·제1중족골 기저부)',
  '바로 눕기 또는 앉은 자세',
  '환자 환측 옆, 전방 하퇴 전경골근 근복 접촉 압박 유지',
  '전경골근 근복 (엄지 또는 검지·중지)',
  '접촉 유지하며 발목을 배측굴곡에서 저측굴곡으로 능동 이동',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 앉은 자세로 위치시키고 치료 측 발이 자유롭게 움직일 수 있도록 발목 부분을 테이블 끝에 위치시킨다. 발목을 배측굴곡(발끝 위로 당기기) 시작 위치로 세팅한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 서서 엄지 또는 검지·중지를 전방 하퇴 전경골근 근복(경골 외측면)의 단축 조직에 충분한 접촉 압박을 가한다. 경골 능선(tibial crest)에 직접 압박이 가해지지 않도록 외측 근복에 접촉한다."},{"step":3,"instruction":"치료사가 접촉 압박을 유지하는 상태에서 환자에게 발목을 배측굴곡 위치에서 최대 저측굴곡 위치까지 천천히 능동적으로 이동하도록 지시한다. 이 과정에서 전경골근 근막이 접촉점 아래로 미끄러지며 유착이 해소된다."},{"step":4,"instruction":"발목이 최대 저측굴곡에 도달하면 치료사가 접촉을 유지한 채 환자에게 다시 배측굴곡으로 천천히 돌아오도록 지시한다. 접촉 위치를 전경골근 근복 상부에서 하부(발목 수준)까지 이동하며 2–3회 반복한다."},{"step":5,"instruction":"시술 후 능동 발목 배측굴곡 범위와 전방 하퇴 촉진 압통 정도를 재평가한다. 경골 스트레스 증후군(shin splints) 환자에게는 훈련량 조절과 점진적 부하 프로그램을 병행하도록 권장한다."}]'::jsonb,
  '{"tissue_release","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"anterior_shin_pain","dorsiflexion_restriction","shin_splints"}',
  '{"fracture","malignancy","active_infection"}',
  'level_4'::evidence_level,
  '전경골근 ART는 발목 배측굴곡 제한 및 전방 하퇴 통증의 원인이 될 수 있는 근막 유착 해소에 효과적일 수 있다.',
  'fracture, malignancy, active_infection',
  'acute_inflammation, compartment_syndrome_concern, anticoagulant_therapy',
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
-- SECTION 5: category_ctm — 2 techniques
-- =============================================================

-- ────────────────────────────────
-- CTM-AnkleAnterior: 발목 전방 결합조직 마사지
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
  'CTM — 발목 전방',
  '발목 전방 결합조직 마사지', 'Anterior Ankle Connective Tissue Massage', 'CTM-AnkleAnterior',
  'ankle_foot'::body_region, '발목 전방 신근 지지띠·발등 피하결합조직',
  '바로 눕기 또는 앉은 자세',
  '환자 발쪽, 발목 전방·발등 피하결합조직 접촉',
  '발목 전방 신근 지지띠 구역 피하결합조직 (손가락 끝 긁기 기법)',
  '발목 전방에서 발등 방향으로 피하결합조직 긁기',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 앉은 자세로 위치시키고 치료 측 발목이 편안하게 이완되도록 한다. 발목 아래에 작은 쿠션을 받쳐 발목 전방 구역에 대한 접근성을 확보한다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 검지와 중지 끝(또는 중지 하나)을 발목 전방 신근 지지띠 구역(발목 앞 주름 바로 위)의 피하결합조직에 접촉한다. 너무 깊이 압박하지 않고 피부와 근막 사이 피하층에 머무는 것이 핵심이다."},{"step":3,"instruction":"피부를 밀거나 미끄러뜨리지 않고 피하결합조직을 함께 이동시키는 긁기(hook) 기법으로 발목 전방에서 발등 방향으로 천천히 이동한다. 조직 저항이 느껴지는 방향으로 5–10초간 지속하다가 이완이 느껴지면 다음 구역으로 이동한다."},{"step":4,"instruction":"발목 전방 내측(내과 근처)에서 시작하여 발등 중앙, 외측(외과 근처) 순서로 이동하며 전방 발목 전반의 피하결합조직 이동성을 개선한다. 각 구역에서 2–3회 반복한다."},{"step":5,"instruction":"시술 후 발목 능동 배측굴곡 범위와 발등 부종·압통 정도를 재평가한다. 발목 전방 충돌 증후군 환자에게는 발목 관절 가동술과 병행을 권장하며, 부종이 있는 경우 거상과 냉찜질을 병행한다."}]'::jsonb,
  '{"tissue_release","pain_relief","circulation_improvement"}',
  '{"subacute","chronic"}',
  '{"anterior_ankle_pain","ankle_stiffness","dorsum_swelling"}',
  '{"fracture","malignancy","skin_infection_in_area"}',
  'level_4'::evidence_level,
  '발목 전방 결합조직 마사지는 전방 발목 충돌 증후군 및 발등 부종에서 조직 이동성 회복에 도움이 될 수 있다.',
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
-- CTM-AnklePosterior: 발목 후방·아킬레스 결합조직 마사지
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
  'CTM — 발목 후방',
  '발목 후방·아킬레스 결합조직 마사지', 'Posterior Ankle and Achilles Connective Tissue Massage', 'CTM-AnklePosterior',
  'ankle_foot'::body_region, '아킬레스건 주변·후방 발목 피하결합조직',
  '엎드려 눕기',
  '환자 발쪽, 아킬레스건 주변 피하결합조직 접촉',
  '아킬레스건 내측·외측 피하결합조직 (손가락 끝 긁기 기법)',
  '아킬레스건 양측에서 종골 방향으로 피하결합조직 긁기',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 발목 아래에 작은 쿠션을 받쳐 아킬레스건 후방 구역이 편안하게 노출되도록 한다. 발목은 중립에서 약간 저측굴곡 위치로 이완시킨다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 검지와 중지 끝을 아킬레스건 내측 피하결합조직(내과와 아킬레스건 사이 구역)에 먼저 접촉한다. 건 자체에 직접 압박하지 않고 건 주변 피하층에 머무는 것이 핵심이다."},{"step":3,"instruction":"피하결합조직을 함께 이동시키는 긁기(hook) 기법으로 아킬레스건 내측 구역에서 종골 방향으로 천천히 이동한다. 조직 저항이 느껴지는 방향으로 5–10초간 지속하다가 이완이 느껴지면 다음 구역으로 이동한다."},{"step":4,"instruction":"아킬레스건 내측 구역 시술 후 외측(외과와 아킬레스건 사이 구역)으로 이동하여 동일하게 시술한다. 이후 하퇴 원위부 ~ 아킬레스건 부착부(종골) 방향으로 상하를 이동하며 후방 발목 전반의 피하결합조직 이동성을 개선한다."},{"step":5,"instruction":"시술 후 발꿈치 들기(힐레이즈)와 후방 발목 압통 정도를 재평가한다. 아킬레스 건병증 환자에게는 편심성 수축 운동(heel drop)과 병행을 권장하며, 건 자체에 압박이 가해졌는지 시술 중 지속적으로 확인한다."}]'::jsonb,
  '{"tissue_release","pain_relief","tendon_rehabilitation"}',
  '{"subacute","chronic"}',
  '{"achilles_tendinopathy","posterior_ankle_pain","ankle_stiffness"}',
  '{"fracture","malignancy","skin_infection_in_area","achilles_complete_rupture"}',
  'level_4'::evidence_level,
  '후방 발목 결합조직 마사지는 아킬레스 건병증 및 후방 발목 충돌 증후군에서 건 주변 조직 유착 감소에 도움이 될 수 있다.',
  'fracture, malignancy, skin_infection_in_area, achilles_complete_rupture',
  'acute_tendinitis, anticoagulant_therapy',
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
-- Migration 022 (Part 3): Ankle — DFM + TrP (9 techniques)
-- 발목/발 심부마찰 마사지 4개 + 트리거포인트 이완 5개
-- sw-db-architect | 2026-04-28

-- =============================================================
-- SECTION 6: category_deep_friction — 4 techniques (level_3)
-- =============================================================

-- ────────────────────────────────
-- DFM-AchillesTend: 아킬레스건 심부마찰 마사지
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
  'DFM — 아킬레스건',
  '아킬레스건 심부마찰 마사지', 'Achilles Tendon Deep Friction Massage', 'DFM-AchillesTend',
  'ankle_foot'::body_region, '아킬레스건 중간부(종골 부착부 상방 2–6cm)',
  '엎드려 눕기, 발목 약간 배측굴곡(수건 받침)',
  '환자 발쪽, 검지·중지로 아킬레스건 중간부 접촉',
  '아킬레스건 중간부 (검지·중지 중첩)',
  '건 주행 방향(세로)에 수직으로 횡마찰',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 발목 아래(발등 아래)에 수건이나 쿠션을 받쳐 발목이 약간 배측굴곡된 편안한 자세를 만든다. 이 자세는 아킬레스건 중간부 접근성을 높이고 건 조직을 적당히 이완시킨다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 검지와 중지를 중첩하고 아킬레스건 중간부(종골 부착부 상방 2–6cm 구간)의 압통 최대점을 촉진하여 시술 위치를 확인한다."},{"step":3,"instruction":"손가락 끝이 건 조직에 충분히 밀착되도록 피부를 약간 이동시켜 접촉 위치를 잡는다. 아킬레스건 좌우 경계를 손가락으로 확인하여 건 조직 위에 정확히 위치한다."},{"step":4,"instruction":"건 주행 방향(세로 방향)에 수직으로, 즉 가로 방향으로 횡마찰을 리듬감 있게 시행한다. 압력은 조직 저항이 느껴지는 수준으로 유지하며 매 왕복 시 동일한 범위와 속도를 유지한다."},{"step":5,"instruction":"1회당 3–5분 시행 후 아킬레스건 압통 변화 및 발목 배측굴곡 범위를 재평가한다. 시술 직후 경미한 불편감은 정상 반응일 수 있으며 통상 24시간 내 소실 가능하다."}]'::jsonb,
  '{"pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"achilles_tendinopathy","posterior_ankle_pain"}',
  '{"fracture","malignancy","acute_inflammation","achilles_rupture","open_wound"}',
  'level_3'::evidence_level,
  '아킬레스건 Cyriax 마찰 마사지는 건 조직의 교원질 재배열과 혈류 촉진에 도움이 될 수 있다. 아킬레스 건병증의 보존적 치료 보조로 활용될 수 있으나 급성 파열은 절대 금기다.',
  'fracture, malignancy, active_infection, achilles_complete_rupture',
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
-- DFM-PlantFasDFM: 족저근막 심부마찰 마사지
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
  'DFM — 족저근막',
  '족저근막 심부마찰 마사지', 'Plantar Fascia Deep Friction Massage', 'DFM-PlantFasDFM',
  'ankle_foot'::body_region, '족저근막 내측띠(종골 내측결절 부착부 ~ 중족부)',
  '엎드려 눕기 또는 앉은 자세',
  '환자 발쪽, 엄지로 족저근막 부착부 접촉',
  '종골 내측결절 족저근막 부착부 (엄지 끝)',
  '근막 주행 방향에 수직으로 횡마찰',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 또는 앉은 자세로 위치시키고 발이 치료 테이블 끝에서 자유롭게 접근 가능하도록 한다. 엎드려 눕기에서는 발목 아래에 쿠션을 받쳐 편안한 자세를 유지한다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 엄지 끝으로 종골 내측결절(발뒤꿈치 내측 아래)에서 족저근막 내측띠 부착부를 촉진하여 압통 최대점을 확인한다."},{"step":3,"instruction":"엄지 끝이 근막 조직에 충분히 밀착되도록 피부를 약간 이동시켜 접촉 위치를 잡는다. 종골 내측결절 부착부는 족저근막염에서 가장 흔한 병변 부위로 정확한 위치 확인이 중요하다."},{"step":4,"instruction":"근막 주행 방향(발꿈치에서 발가락 방향, 세로)에 수직으로 횡마찰을 리듬감 있게 시행한다. 엄지에 가해지는 압력을 일정하게 유지하면서 동일한 범위와 속도로 반복한다."},{"step":5,"instruction":"3–5분 시행 후 족저근막 압통 및 기상 직후 첫 발걸음 통증 변화를 재평가한다. 스트레칭 및 근력 강화 운동과 병행 시 효과가 더 클 수 있다."}]'::jsonb,
  '{"pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"plantar_heel_pain","plantar_fasciitis","morning_foot_pain"}',
  '{"fracture","malignancy","acute_inflammation","open_wound"}',
  'level_3'::evidence_level,
  '족저근막 마찰 마사지는 족저근막 부착부 주변 유착 감소와 통증 완화에 도움이 될 수 있다. 스트레칭 및 근력 강화와 병행 시 효과적일 수 있음',
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
-- DFM-ATFL: 전거비인대 심부마찰 마사지
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
  'DFM — 외측 발목 인대',
  '전거비인대 심부마찰 마사지', 'ATFL Deep Friction Massage', 'DFM-ATFL',
  'ankle_foot'::body_region, '전거비인대(비골 전방면 ~ 거골 경부 외측)',
  '바로 눕기 또는 앉은 자세, 발목 약간 내번 위치',
  '환자 환측 옆, 비골 전방 하단과 거골 경부 사이 ATFL 접촉',
  'ATFL 주행 선상 (엄지 또는 검지)',
  '인대 주행 방향에 수직으로 횡마찰',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 앉은 자세로 위치시키고 발목을 약간 내번 위치로 놓아 ATFL 접근이 용이한 자세를 만든다. 이 위치는 전거비인대를 표면으로 드러나게 하여 촉진을 용이하게 한다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 위치하여 비골 전방 하단(외측 복사뼈 전방면)에서 거골 경부 외측 방향으로 ATFL 주행 경로를 촉진하여 압통 최대점을 확인한다."},{"step":3,"instruction":"엄지 또는 검지 끝이 인대 조직에 충분히 밀착되도록 피부를 약간 이동시켜 접촉 위치를 잡는다. 단지신근 건과의 해부학적 관계를 고려하여 ATFL 위치를 정확히 확인한다."},{"step":4,"instruction":"인대 섬유 방향에 수직으로 횡마찰을 리듬감 있게 시행한다. 압력은 조직 저항이 느껴지는 수준으로 유지하며 동일한 범위와 속도로 반복한다."},{"step":5,"instruction":"3–5분 시행 후 외측 발목 압통 및 전방 당김 검사(anterior drawer test) 반응 변화를 재평가한다. 급성 파열 단계에서는 적용하지 않으며 아급성 이후 단계(손상 후 6주 이상)에서 고려한다."}]'::jsonb,
  '{"pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"lateral_ankle_pain","chronic_ankle_instability","atfl_sprain"}',
  '{"fracture","malignancy","acute_inflammation","atfl_complete_rupture","open_wound"}',
  'level_3'::evidence_level,
  'ATFL 마찰 마사지는 만성 발목 불안정에서 인대 유착 감소와 조직 리모델링에 도움이 될 수 있다. 급성 파열 단계는 금기이며 아급성 이후 단계에서 적용 가능성이 있다.',
  'fracture, malignancy, active_infection, atfl_complete_rupture',
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
-- DFM-CFL: 종비인대 심부마찰 마사지
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
  'DFM — 외측 발목 인대',
  '종비인대 심부마찰 마사지', 'CFL Deep Friction Massage', 'DFM-CFL',
  'ankle_foot'::body_region, '종비인대(비골 끝 ~ 종골 외측면)',
  '바로 눕기 또는 앉은 자세, 발목 약간 배측굴곡',
  '환자 환측 옆, 비골 끝 하방에서 종골 외측 방향 CFL 접촉',
  'CFL 주행 선상 (엄지 또는 검지)',
  '인대 주행 방향에 수직으로 횡마찰',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 앉은 자세로 위치시키고 발목을 약간 배측굴곡 위치로 놓아 CFL 접근이 용이한 자세를 만든다. CFL은 비골 끝에서 종골 외측면으로 아래쪽으로 주행하므로 이 위치에서 촉진이 용이하다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 위치하여 비골 끝(외측 복사뼈 하방) 하방에서 종골 외측면 방향으로 CFL 주행 경로를 촉진하여 압통 최대점을 확인한다."},{"step":3,"instruction":"엄지 또는 검지 끝이 인대 조직에 충분히 밀착되도록 피부를 약간 이동시켜 접촉 위치를 잡는다. 단비골근건이 CFL과 교차하므로 해부학적 위치를 정확히 확인한다."},{"step":4,"instruction":"인대 섬유 방향에 수직으로 횡마찰을 리듬감 있게 시행한다. 압력은 조직 저항이 느껴지는 수준으로 유지하며 동일한 범위와 속도로 반복한다."},{"step":5,"instruction":"3–5분 시행 후 외측 발목 압통 및 거골 경사 검사(talar tilt test) 반응 변화를 재평가한다. ATFL 마찰 마사지와 함께 발목 내번 염좌 후 만성화 예방 목적으로 활용될 수 있다."}]'::jsonb,
  '{"pain_relief","tissue_remodeling"}',
  '{"subacute","chronic"}',
  '{"lateral_ankle_pain","chronic_ankle_instability","cfl_sprain"}',
  '{"fracture","malignancy","acute_inflammation","cfl_complete_rupture","open_wound"}',
  'level_3'::evidence_level,
  '종비인대 마찰 마사지는 만성 발목 불안정에서 CFL 유착 해소와 조직 유연성 개선에 도움이 될 수 있다. ATFL과 함께 발목 내번 염좌 후 만성화 예방 목적으로 활용될 수 있음',
  'fracture, malignancy, active_infection, cfl_complete_rupture',
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
-- ANK-TrP-Gast: 비복근 트리거포인트 이완
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
  'TrP — 후방 하퇴',
  '비복근 트리거포인트 이완', 'Gastrocnemius Trigger Point Release', 'ANK-TrP-Gast',
  'ankle_foot'::body_region, '비복근 내측두·외측두 근복 (연관통: 발바닥~발목 뒤쪽~무릎 뒤쪽)',
  '엎드려 눕기',
  '환자 발쪽, 후방 하퇴 비복근 압통점 촉진',
  '비복근 내측두 또는 외측두 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 후방 하퇴 근육이 이완될 수 있도록 발목 아래에 작은 쿠션을 받쳐 편안한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 엄지 또는 검지·중지로 후방 하퇴 비복근 내측두 또는 외측두 근복을 촉진하여 단단한 띠(taut band)와 그 안의 압통 결절(tender nodule)을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 발바닥, 발목 뒤쪽, 또는 무릎 뒤쪽으로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50–70% 감소할 때까지 7–10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 주변 근육을 가볍게 이완 마사지한다. 2–3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 비복근 신장 운동(선 자세 발뒤꿈치 내리기 또는 벽 스트레칭)으로 치료 효과를 강화한다. 발바닥 통증 및 야간 종아리 경련 증상 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"calf_pain","plantar_pain","nocturnal_cramps"}',
  '{"fracture","malignancy","acute_inflammation","dvt"}',
  'level_4'::evidence_level,
  '비복근 트리거포인트는 발바닥, 발목 뒤쪽, 무릎 뒤쪽으로 퍼지는 연관통을 유발할 수 있다. 야간 종아리 경련(쥐나는 증상)의 주요 원인이 될 수 있음',
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

-- ────────────────────────────────
-- ANK-TrP-Sol: 가자미근 트리거포인트 이완
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
  'TrP — 후방 하퇴 심부',
  '가자미근 트리거포인트 이완', 'Soleus Trigger Point Release', 'ANK-TrP-Sol',
  'ankle_foot'::body_region, '가자미근 근복(후방 하퇴 심층) (연관통: 종골~발뒤꿈치~발바닥)',
  '엎드려 눕기, 무릎 약간 굽힌 위치',
  '환자 발쪽, 비복근 내측 경계에서 심층 가자미근 접촉',
  '비복근 내측 경계를 통한 가자미근 근복 (엄지 또는 손가락 끝)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 무릎 아래에 쿠션을 받쳐 무릎을 약간 굽혀(20–30도) 가자미근이 비복근보다 접근하기 쉬운 자세를 만든다. 무릎을 굽히면 비복근이 이완되어 심층의 가자미근 접근이 용이해진다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 비복근 내측 경계를 촉진한다. 비복근 내측 경계를 따라 손가락 끝을 심층으로 밀어 넣어 가자미근 근복을 촉진하여 단단한 띠와 압통 결절을 찾는다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 종골, 발뒤꿈치, 또는 발바닥으로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50–70% 감소할 때까지 7–10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 주변 근육을 가볍게 이완 마사지한다. 2–3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 가자미근 신장 운동(무릎 굽힌 자세 발뒤꿈치 내리기)으로 치료 효과를 강화한다. 발뒤꿈치 통증 및 족저근막염 유사 증상 변화를 재평가하고 족저근막염과의 감별을 고려한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"heel_pain","plantar_pain","calf_tightness"}',
  '{"fracture","malignancy","acute_inflammation","dvt"}',
  'level_4'::evidence_level,
  '가자미근 트리거포인트는 종골과 발뒤꿈치로 퍼지는 연관통을 유발할 수 있다. 족저근막염과 유사한 발뒤꿈치 통증 패턴을 보일 수 있어 감별진단이 필요할 수 있음',
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

-- ────────────────────────────────
-- ANK-TrP-Peron: 비골근 트리거포인트 이완
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
  'TrP — 외측 하퇴',
  '비골근 트리거포인트 이완', 'Peroneal Trigger Point Release', 'ANK-TrP-Peron',
  'ankle_foot'::body_region, '장·단비골근 근복(외측 하퇴) (연관통: 외측 발목~외측 발등~외측 종골)',
  '옆으로 눕기(환측 위)',
  '환자 뒤쪽, 외측 하퇴 비골근 압통점 촉진',
  '장·단비골근 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 환측이 위로 향하는 옆으로 눕기 자세로 위치시키고 외측 하퇴 근육이 이완될 수 있도록 편안한 자세를 만든다. 발목 아래에 쿠션을 받쳐 안정적인 위치를 유지한다."},{"step":2,"instruction":"치료사는 환자 뒤쪽에 위치하여 엄지 또는 검지·중지로 외측 하퇴(비골두 하방에서 외측 복사뼈 상방까지)를 촉진하여 장·단비골근 근복의 단단한 띠와 압통 결절을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 외측 발목, 외측 발등, 또는 외측 종골로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50–70% 감소할 때까지 7–10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 주변 근육을 가볍게 이완 마사지한다. 2–3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 비골근 신장 운동(발목 내번 신장)으로 치료 효과를 강화한다. 외측 발목 통증 및 발목 불안정 증상 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"lateral_ankle_pain","lateral_foot_pain","chronic_instability"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '비골근 트리거포인트는 외측 발목과 발등으로 퍼지는 연관통을 유발할 수 있다. 만성 발목 불안정 환자에서 비골근 반응 지연과 함께 빈번히 관찰될 수 있음',
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
-- ANK-TrP-TibAnt: 전경골근 트리거포인트 이완
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
  'TrP — 전방 하퇴',
  '전경골근 트리거포인트 이완', 'Tibialis Anterior Trigger Point Release', 'ANK-TrP-TibAnt',
  'ankle_foot'::body_region, '전경골근 근복(전방 하퇴 상부) (연관통: 발등~엄지발가락 내측)',
  '바로 눕기 또는 앉은 자세',
  '환자 환측 옆, 전방 하퇴 전경골근 압통점 촉진',
  '전경골근 근복 (엄지 또는 검지·중지)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 바로 눕기 또는 앉은 자세로 위치시키고 전방 하퇴 근육이 이완될 수 있도록 편안한 자세를 만든다."},{"step":2,"instruction":"치료사는 환자 환측 옆에 위치하여 엄지 또는 검지·중지로 전방 하퇴(경골 외측 경계에서 외측 방향 1–2cm) 전경골근 근복을 촉진하여 단단한 띠와 압통 결절을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 발등 또는 엄지발가락 내측으로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50–70% 감소할 때까지 7–10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 주변 근육을 가볍게 이완 마사지한다. 2–3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 전경골근 신장 운동(발목 족저굴곡·내번 스트레칭)으로 치료 효과를 강화한다. 발등 통증 및 정강이 앞쪽 통증(shin splints 유사) 증상 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"dorsal_foot_pain","big_toe_pain","shin_pain"}',
  '{"fracture","malignancy","acute_inflammation","compartment_syndrome"}',
  'level_4'::evidence_level,
  '전경골근 트리거포인트는 발등과 엄지발가락 내측으로 퍼지는 연관통을 유발할 수 있다. 과도한 달리기나 경사로 보행 후 전방 하퇴 통증과 함께 빈번히 발생할 수 있음',
  'fracture, malignancy, active_infection',
  'acute_inflammation, compartment_syndrome_concern, anticoagulant_therapy',
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
-- ANK-TrP-Plantar: 족저 내재근 트리거포인트 이완
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
  'TrP — 족저 내재근',
  '족저 내재근 트리거포인트 이완', 'Plantar Intrinsic Muscle Trigger Point Release', 'ANK-TrP-Plantar',
  'ankle_foot'::body_region, '단족지굴근·무지외전근·족저방형근 (연관통: 발바닥 전반)',
  '엎드려 눕기 또는 앉은 자세',
  '환자 발쪽, 발바닥 내재근 압통점 촉진',
  '발바닥 내재근 (엄지 끝 또는 손가락 끝)',
  '수직 허혈성 압박 또는 핀처 그립 마사지',
  '[{"step":1,"instruction":"환자를 엎드려 눕기 또는 앉은 자세로 위치시키고 발바닥이 편안하게 접근 가능한 자세를 만든다. 엎드려 눕기에서는 발목 아래에 쿠션을 받쳐 발바닥 면이 위를 향하도록 한다."},{"step":2,"instruction":"치료사는 환자 발쪽에 위치하여 엄지 끝 또는 손가락 끝으로 발바닥 전반(종골 내측결절 ~ 중족골두 방향)을 체계적으로 촉진하여 단족지굴근, 무지외전근, 족저방형근 내 단단한 띠와 압통 결절을 찾아 트리거포인트를 확인한다."},{"step":3,"instruction":"트리거포인트에 엄지 또는 손가락 끝을 수직으로 대고 조직 저항이 느껴지는 수준의 압력으로 허혈성 압박을 시작한다. 압박 후 연관통이 발바닥 전반으로 퍼지는지 확인하여 활성 트리거포인트임을 확인한다."},{"step":4,"instruction":"압통이 50–70% 감소할 때까지 7–10초간 압박을 유지한다. 이후 압력을 서서히 해제하고 주변 근육을 가볍게 이완 마사지한다. 여러 트리거포인트가 있을 경우 압통이 가장 강한 곳부터 순서대로 처리한다. 각 지점에서 2–3회 반복할 수 있다."},{"step":5,"instruction":"시술 후 족저 내재근 강화 운동(발가락 발 안쪽으로 모으기, 타월 잡아당기기)으로 치료 효과를 강화한다. 족저근막 마찰 마사지와 병행 시 효과적일 수 있으며 발바닥 통증 및 발 피로 증상 변화를 재평가한다."}]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"plantar_pain","plantar_fasciitis_like","foot_fatigue"}',
  '{"fracture","malignancy","acute_inflammation"}',
  'level_4'::evidence_level,
  '족저 내재근 트리거포인트는 발바닥 전반의 통증 및 족저근막염 유사 증상을 유발할 수 있다. 족저근막 마찰 마사지와 병행 시 효과적일 수 있음',
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
