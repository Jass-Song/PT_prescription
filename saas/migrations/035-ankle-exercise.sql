-- ============================================================
-- Migration 035 — 족관절 운동 처방 (7기법)
-- ankle_foot body_region: 근력 저항(3) + 자체중량(2) + 신경근 훈련(2)
-- K-Movement Optimism / PT 처방 도우미
-- 생성일: 2026-04-29
-- 작성자: sw-db-architect
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

BEGIN;

-- ============================================================
-- SECTION 1 — category_ex_resistance (근력·저항성 운동)
-- body_region: ankle_foot
-- ============================================================

-- ────────────────────────────────
-- [1] 종아리 들기 운동 (Calf Raise)
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
  'category_ex_resistance',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_resistance'),
  '운동 처방 — 족관절 저측굴곡 강화',
  '종아리 들기 운동', 'Calf Raise — Gastrocnemius/Soleus', 'ANK-EX-RES-CalfRaise',
  'ankle_foot'::body_region, '비복근, 가자미근, 아킬레스건',
  '선 자세, 발 어깨 너비로 벌리고 발끝을 벽 또는 계단 끝 모서리에 걸거나 평평한 바닥에 서기. 한 손 또는 양손으로 벽이나 난간을 가볍게 잡아 균형 보조 가능',
  '환자 옆에서 발목 움직임 패턴과 하강 속도를 관찰. 직접 접촉 없음(능동 운동)',
  '해당 없음 (능동 운동)',
  '족저굴곡 — 발뒤꿈치를 위로 들어올리는 방향',
  '[{"step":1,"instruction":"선 자세에서 양발을 어깨 너비로 벌리고 두 손으로 벽 또는 난간을 가볍게 잡는다. 발목 중립 위치(발가락이 정면을 향함)에서 시작한다. 양발 수행으로 시작하여 익숙해지면 한 발 수행으로 진행한다."},{"step":2,"instruction":"발뒤꿈치를 천천히 최대한 높이 들어올리는 족저굴곡 동작을 2초에 걸쳐 수행한다. 끝 범위(발뒤꿈치가 가장 높은 위치)에서 1초 유지한다. 무릎을 구부리지 않고 곧게 편 상태를 유지하면 비복근을, 약간 굽히면 가자미근을 더 많이 자극할 수 있다."},{"step":3,"instruction":"편심성(eccentric) 하강 단계를 천천히 4초에 걸쳐 수행한다. 발뒤꿈치가 시작 위치(또는 계단을 이용할 경우 시작 위치 아래)까지 내려오도록 조절한다. 편심성 부하가 아킬레스건 강화에 핵심 자극이 될 수 있다."},{"step":4,"instruction":"15회 3세트를 목표로 시작한다. 통증 없이 양발 수행이 안정되면 한 발 수행으로 전환하며 세트당 반복 횟수를 8–12회로 조정한다. 세트 간 60–90초 휴식을 유지한다."},{"step":5,"instruction":"4–6주 후 한 발 까치발 들기 횟수(단순 근지구력 지표) 및 주관적 통증 강도(NRS)를 재평가한다. 통증 없이 25회 이상 수행 가능하면 난이도를 높이거나(무게 추가, 경사면 활용) 다음 단계 운동으로 전환한다."}]'::jsonb,
  '{"pain_relief","strength_training","functional_recovery"}',
  '{"subacute","chronic","sport_return"}',
  '{"ankle_pain_general","achilles_tendinopathy","calf_weakness","plantar_heel_pain"}',
  '{"fracture","acute_achilles_rupture","malignancy"}',
  'level_1b'::evidence_level,
  '편심성 하강 단계가 핵심 자극이 될 수 있다. 계단 모서리를 이용하면 발뒤꿈치를 중립 아래로 내릴 수 있어 더 큰 범위의 편심성 부하를 기대할 수 있다. 아킬레스건 병증 초기 통증 허용 범위 내에서 적용 가능성이 있으며, 급성 파열 또는 수술 직후에는 절대 금기이다. 무릎을 편 상태(비복근)와 굽힌 상태(가자미근)를 교대로 시행하면 두 근육을 균형 있게 강화할 수 있다.',
  'fracture, acute_achilles_rupture, malignancy',
  'acute_ankle_sprain, severe_osteoporosis, DVT',
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
-- [2] 발목 배측굴곡 강화 (Ankle Dorsiflexion Strengthening)
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
  'category_ex_resistance',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_resistance'),
  '운동 처방 — 족관절 배측굴곡 강화',
  '발목 배측굴곡 강화', 'Ankle Dorsiflexion Strengthening', 'ANK-EX-RES-DF',
  'ankle_foot'::body_region, '전경골근, 장지신근',
  '앉은 자세, 무릎을 약 90도 굽혀 발바닥이 바닥 또는 발판에 닿도록 하거나 다리를 앞으로 뻗어 탄성 밴드를 발등에 걸기',
  '환자 맞은편 또는 옆에서 발목 움직임 관찰 및 밴드 저항 방향 안내. 직접 접촉 없음(능동 운동)',
  '해당 없음 (능동 운동)',
  '배측굴곡 — 발등을 정강이 방향으로 당기는 방향',
  '[{"step":1,"instruction":"앉은 자세에서 환측 다리를 앞으로 편안하게 뻗는다. 탄성 밴드를 발등 중앙(신발 끈 부위)에 걸고 반대쪽 끝을 치료 테이블 다리 또는 무거운 물체에 고정하거나 치료사가 잡아 저항을 제공한다. 발목은 자연스러운 족저굴곡 위치(약 20도)에서 시작한다."},{"step":2,"instruction":"발등을 정강이 방향으로 최대한 당기는 배측굴곡 동작을 2초에 걸쳐 수행한다. 발가락을 위로 젖히되 무릎을 구부리거나 다리 전체를 들어올리는 보상 동작을 방지한다. 끝 범위에서 1초 유지한다."},{"step":3,"instruction":"천천히 시작 위치로 돌아가며 저항을 제어하면서 근육을 편심성으로 이완한다. 3초에 걸쳐 천천히 내리는 것이 근력 강화에 더 유리할 수 있다. 이 과정을 15회 반복한다."},{"step":4,"instruction":"15회 3세트를 목표로 한다. 통증 없이 수행 가능하면 밴드 저항 강도를 단계적으로 높인다. 저항 강도: 가벼운(노랑) → 중간(빨강) → 강한(파랑/검정) 순서로 진행한다. 세트 간 60초 휴식을 유지한다."},{"step":5,"instruction":"4주 후 배측굴곡 근력(도수 근력 검사 또는 동적 근력 측정)과 발목 통증(NRS)을 재평가한다. 근력이 정상 수준에 도달하면 선 자세 배측굴곡 저항 운동 또는 기능적 훈련으로 전환을 고려한다."}]'::jsonb,
  '{"strength_training","functional_recovery","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"ankle_pain_general","dorsiflexion_restriction","anterior_shin_weakness","chronic_ankle_instability"}',
  '{"fracture","acute_compartment_syndrome","malignancy"}',
  'level_2b'::evidence_level,
  '전경골근 약화는 발목 불안정성 및 보행 이상과 연관될 수 있으며, 배측굴곡 강화가 기능 회복에 기여할 가능성이 있다. 탄성 밴드 색상·길이·고정 위치에 따라 저항이 달라지므로 초기에 치료사가 저항 강도를 직접 확인하는 것이 안전할 수 있다. 만성 발목 불안정성 환자에서 배측굴곡 근력 부족이 재손상 위험과 연관될 수 있어 재활 프로그램에 포함하는 것을 고려할 수 있다.',
  'fracture, acute_compartment_syndrome, malignancy',
  'acute_ankle_sprain, anterior_tibial_tendinopathy, severe_peripheral_neuropathy',
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
-- [3] 비골근 강화 (Peroneal Strengthening)
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
  'category_ex_resistance',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_resistance'),
  '운동 처방 — 족관절 외번 강화',
  '비골근 강화', 'Peroneal Strengthening', 'ANK-EX-RES-Peron',
  'ankle_foot'::body_region, '장비골근, 단비골근',
  '앉은 자세, 무릎을 약 90도 굽혀 발바닥이 바닥에 닿도록 하거나 다리를 앞으로 뻗어 탄성 밴드를 발 외측부에 걸기',
  '환자 맞은편 또는 옆에서 발 외번 동작 관찰. 직접 접촉 없음(능동 운동)',
  '해당 없음 (능동 운동)',
  '외번 — 발 외측을 위로 들어올리는(발바닥이 바깥쪽을 향하는) 방향',
  '[{"step":1,"instruction":"앉은 자세에서 환측 다리를 앞으로 편안하게 뻗는다. 탄성 밴드를 발 외측(복숭아뼈 아래 발 외측부)에 걸고 반대쪽 끝을 반대측 발에 걸거나 무거운 물체에 고정하여 안쪽(내번) 방향 저항을 만든다. 발목은 자연스러운 중립 위치에서 시작한다."},{"step":2,"instruction":"발 외측을 위로 들어올리는 외번 동작을 2초에 걸쳐 수행한다. 발목이 배측굴곡 방향으로 함께 움직이면서 비골근이 최대 수축하도록 유도한다. 무릎이나 고관절이 회전하는 보상 동작을 방지한다. 끝 범위에서 1초 유지한다."},{"step":3,"instruction":"천천히 3초에 걸쳐 시작 위치로 돌아가며 편심성으로 조절한다. 15회를 1세트로 하며 양발을 교대로 시행한다."},{"step":4,"instruction":"15회 3세트를 목표로 시작한다. 통증 없이 수행 가능하면 밴드 저항 강도를 단계적으로 높인다. 4주 후 선 자세에서 비골근 저항 운동 또는 기능적 방향 전환 훈련으로 진행을 고려한다."},{"step":5,"instruction":"4–6주 후 발목 외번 근력(도수 근력 검사)과 기능적 수행 능력(FAAM 등)을 재평가한다. 만성 발목 불안정성이 있다면 신경근 훈련(SEBT, 발란스 보드)과 병행하는 것이 상호 보완적으로 효과를 기대할 수 있다."}]'::jsonb,
  '{"strength_training","pain_relief","functional_recovery"}',
  '{"subacute","chronic","sport_return"}',
  '{"chronic_ankle_instability","lateral_ankle_pain","ankle_sprain_recurrence","peroneal_weakness"}',
  '{"fracture","peroneal_tendon_rupture","malignancy"}',
  'level_2b'::evidence_level,
  '외측 인대 손상 후 재활에서 비골근 강화는 동적 안정화 기능 회복에 핵심 역할을 할 가능성이 있다. 비골근 강화만으로는 만성 불안정성 개선에 한계가 있을 수 있으며, 신경근 훈련(고유감각 훈련)과 함께 적용할 때 상호 보완적인 효과를 기대할 수 있다. 급성 외측 인대 손상(RICE 단계) 이후 통증이 허용되는 범위에서 조기 적용이 재활 기간 단축에 기여할 수 있다.',
  'fracture, peroneal_tendon_rupture, malignancy',
  'acute_lateral_ankle_sprain, fibula_stress_fracture, severe_peripheral_neuropathy',
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
-- SECTION 2 — category_ex_bodyweight (자체중량·방향성 운동)
-- body_region: ankle_foot
-- ============================================================

-- ────────────────────────────────
-- [4] 발목 알파벳 운동 (Ankle ABC Exercise)
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
  'category_ex_bodyweight',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_bodyweight'),
  '운동 처방 — 발목 자가 가동',
  '발목 알파벳 운동', 'Ankle ABC Exercise', 'ANK-EX-BW-ABC',
  'ankle_foot'::body_region, '거퇴관절, 거종관절',
  '앉은 자세, 무릎을 편안하게 굽혀 발이 바닥에서 자유롭게 움직일 수 있는 높이에 위치. 의자에 앉거나 침대/치료 테이블 끝에 앉아 발을 허공에 띄우기',
  '환자 옆 또는 맞은편에서 동작 관찰. 직접 접촉 없음(능동 운동)',
  '해당 없음 (능동 운동)',
  '발목의 전 방향 — 배측굴곡, 족저굴곡, 내번, 외번, 사선 복합 방향',
  '[{"step":1,"instruction":"앉은 자세에서 환측 다리를 들어 발이 바닥에서 자유롭게 움직일 수 있도록 한다. 무릎은 편안하게 굽히거나 앞으로 뻗어 발이 허공에 뜬 상태를 유지한다. 발목 아래에 손을 받쳐 경골을 안정화하면 발목 움직임에만 집중할 수 있다."},{"step":2,"instruction":"발끝(발가락 끝)을 연필 끝이라고 상상하며 알파벳 A 모양을 공중에 천천히 그린다. A를 완성한 뒤 잠시 멈추고 B를 이어서 그린다. 각 글자의 모양을 정확하게 그리면서 발목의 전체 가동 범위를 사용한다."},{"step":3,"instruction":"A부터 Z까지 순서대로 한 글자씩 천천히 그린다. 커다란 글자를 그리는 것이 핵심이며, 자신이 낼 수 있는 최대 범위를 활용하도록 안내한다. 통증이 없는 범위 내에서 수행한다."},{"step":4,"instruction":"A–Z를 1회 완성한 뒤 30초–1분 휴식한다. 초기에는 1–2세트에서 시작하여 3–5세트로 늘린다. 발목 가동성 회복 목적이면 하루 3–4회 시행이 가능하다."},{"step":5,"instruction":"2–4주 후 발목 가동 범위(배측굴곡·족저굴곡·내번·외번 각도) 변화 및 주관적 경직감(NRS)을 재평가한다. 불편감 없이 수행 가능하면 체중 부하 가동성 운동(체중 부하 배측굴곡 런지 등)으로 발전시킬 수 있다."}]'::jsonb,
  '{"rom_improvement","pain_relief","edema_reduction"}',
  '{"subacute","chronic","elderly"}',
  '{"ankle_pain_general","ankle_stiffness","post_immobilization","dorsiflexion_restriction"}',
  '{"fracture","deep_wound","active_infection"}',
  'level_4'::evidence_level,
  '발목 알파벳 운동은 전 방향 가동 범위를 단순하고 안전하게 자가 적용할 수 있는 가정 운동으로 활용 가능성이 있다. 석고 고정 제거 후 또는 급성 염좌 후 조기 가동에 적합할 수 있으며, 부종 감소와 관절 가동성 회복에 도움이 될 가능성이 있다. 큰 글자를 그리도록 유도하는 것이 최대 가동 범위 달성에 핵심적일 수 있다. 고령 환자나 재활 초기 환자에게도 비교적 쉽게 적용할 수 있다.',
  'fracture, deep_wound, active_infection',
  'acute_ankle_sprain_with_severe_swelling, DVT, unstable_fracture',
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
-- [5] 발 내재근 강화 운동 — Short Foot
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
  'category_ex_bodyweight',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_bodyweight'),
  '운동 처방 — 족저 내재근 강화',
  '발 내재근 강화 운동', 'Foot Intrinsic Strengthening — Short Foot', 'ANK-EX-BW-ShortFoot',
  'ankle_foot'::body_region, '족저 내재근, 발 아치 지지 구조',
  '앉은 자세(초기) 또는 선 자세(진행), 발바닥 전체가 바닥에 고르게 닿도록 위치. 양발 또는 한 발로 시행 가능',
  '환자 앞 또는 옆에서 발가락 움직임과 아치 형성 여부 관찰. 필요 시 발 내측 아치 부위에 가볍게 접촉하여 피드백 제공',
  '족저 내재근 활성화 시 발 내측 아치 하방에 가볍게 접촉하여 피드백 제공 가능',
  '족저 내재근 수축 — 발가락을 굽히지 않고 발 앞쪽을 뒤꿈치 방향으로 당기는 방향',
  '[{"step":1,"instruction":"앉은 자세에서 발바닥 전체를 바닥에 고르게 내려놓는다. 발가락을 모두 바닥에 닿게 한 채 이완된 상태에서 시작한다. 치료사는 발의 내측 아치(엄지발가락 뿌리 뒤쪽)를 가볍게 만져 시작 위치를 확인한다."},{"step":2,"instruction":"발가락을 굽히지 않으면서 엄지발가락 뿌리 부분(발 앞쪽 볼)을 발뒤꿈치 방향으로 당기는 동작을 시도한다. 이 동작은 발의 내측 세로 아치가 올라가는 모양을 만드는 것이 목표이다. 처음에는 아치가 거의 올라가지 않아도 의도적으로 수축 감각을 느끼는 것이 중요하다."},{"step":3,"instruction":"수축 상태를 5–10초 유지한 뒤 천천히 이완한다. 10회를 1세트로 한다. 처음에는 아치가 잘 올라가지 않을 수 있으며, 거울이나 치료사의 언어 피드백을 활용하여 정확한 수축 감각을 학습한다."},{"step":4,"instruction":"앉은 자세에서 안정적으로 수행 가능하면 선 자세(체중 부하)로 전환한다. 선 자세에서는 더 큰 내재근 활성화가 요구되므로 처음에는 양발로 시작하여 한 발 수행으로 진행한다."},{"step":5,"instruction":"4–6주 후 발 아치 높이(navicular drop test) 및 발바닥 통증(NRS)을 재평가한다. 선 자세에서 안정적으로 수행 가능하면 보행 중 또는 달리기 중 아치 유지 훈련으로 전환하는 것을 고려한다."}]'::jsonb,
  '{"strength_training","functional_recovery","pain_relief"}',
  '{"subacute","chronic"}',
  '{"plantar_heel_pain","flat_foot","medial_arch_collapse","plantar_fasciitis"}',
  '{"fracture","active_infection","malignancy"}',
  'level_2b'::evidence_level,
  '발 내재근 강화는 족저 아치 지지 기능 회복에 기여할 가능성이 있으며, 족저근막염 또는 평발과 관련된 통증 재활에 보조적으로 활용될 수 있다. 발가락을 구부리는 동작(발가락 컬)과 구별하여 발 내재근만 선택적으로 수축하는 것이 핵심이며, 처음에는 습득에 시간이 걸릴 수 있다. 앉은 자세에서 충분히 숙달된 후 선 자세로 진행하는 단계적 접근이 더 효과적일 수 있다.',
  'fracture, active_infection, malignancy',
  'acute_plantar_fascia_rupture, severe_peripheral_neuropathy, DVT',
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
-- SECTION 3 — category_ex_neuromuscular (신경근·운동조절 훈련)
-- body_region: ankle_foot
-- ============================================================

-- ────────────────────────────────
-- [6] 별 균형 도달 검사 훈련 (SEBT)
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
  'category_ex_neuromuscular',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_neuromuscular'),
  '운동 처방 — 발목 고유감각 훈련',
  '별 균형 도달 검사 훈련', 'Star Excursion Balance Training', 'ANK-EX-NM-SEBT',
  'ankle_foot'::body_region, '거퇴관절, 비골근, 전경골근, 족저 고유감각 수용체',
  '선 자세, 바닥에 중심점을 두고 8방향으로 선(또는 테이프)을 표시. 환측 한 발로 중심에 서서 반대 발로 각 방향에 최대한 도달',
  '환자 주변에서 균형 상실 및 보상 동작 관찰. 낙상 위험 방지를 위해 필요 시 환자 가까이에 대기',
  '해당 없음 (능동 균형 운동)',
  '8방향(전방, 전내방, 내방, 후내방, 후방, 후외방, 외방, 전외방) 순환 도달',
  '[{"step":1,"instruction":"바닥에 중심점에서 8방향으로 각 45도 간격의 선(또는 테이프)을 붙여 별 모양을 만든다. 환측 발을 중심에 위치시키고 한 발로 선다. 처음에는 필요 시 한 손 지지를 허용한다. 치료사는 환자 옆에서 균형 상실 위험에 대비한다."},{"step":2,"instruction":"반대 발을 들어 전방 방향으로 가능한 최대한 멀리 도달하도록 안내한다. 도달 후 발이 바닥에 살짝 닿으면 바로 들어올려 시작 위치로 돌아온다. 이때 지지 발(환측)은 바닥에 고정된 채 무릎이 굽혀지고 체중이 이동하는 것이 정상 반응이다."},{"step":3,"instruction":"8방향을 순서대로 모두 수행한다. 전방 → 전내방 → 내방 → 후내방 → 후방 → 후외방 → 외방 → 전외방 순서. 각 방향에서 최대 도달 거리를 측정하거나 표시하여 이후 세션과 비교할 수 있다."},{"step":4,"instruction":"초기에는 3방향(전방, 후내방, 후외방 — SEBT 표준 측정 방향)만으로 시작하여 안정성이 확인되면 8방향 전체로 확대한다. 3세트(세트 간 30–60초 휴식)를 목표로 점진적으로 진행한다."},{"step":5,"instruction":"4–6주 후 도달 거리(각 방향별 정규화 도달 거리 = 도달 거리/다리 길이 × 100)와 균형 능력(동적 균형 검사)을 재평가한다. 건측 대비 85% 이상 도달 가능하면 스포츠 복귀 기준의 하나로 활용할 수 있다."}]'::jsonb,
  '{"proprioception_training","functional_recovery","sport_return","pain_relief"}',
  '{"subacute","chronic","sport_return"}',
  '{"chronic_ankle_instability","ankle_sprain_recurrence","balance_disorder","sport_return"}',
  '{"fracture","severe_ankle_instability_unable_to_weightbear","malignancy"}',
  'level_2b'::evidence_level,
  'SEBT 훈련은 동적 균형 및 고유감각 향상에 효과를 기대할 수 있으며, 만성 발목 불안정성 환자의 재손상 예방 및 기능 회복에 활용 가능성이 있다. 도달 거리를 매 세션 기록하여 환자 본인이 향상을 확인하도록 하는 것이 동기부여에 효과적일 수 있다. 처음에는 균형 상실이 잦을 수 있으므로 치료사가 낙상 위험에 대비하고, 손 지지를 점진적으로 줄이는 방식으로 진행하는 것이 안전할 수 있다.',
  'fracture, severe_ankle_instability_unable_to_weightbear, malignancy',
  'acute_ankle_sprain, severe_pain_with_weightbearing, DVT',
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
-- [7] 불안정 표면 균형 훈련 (Wobble Board Balance Training)
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
  'category_ex_neuromuscular',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_neuromuscular'),
  '운동 처방 — 발목 신경근 재훈련',
  '불안정 표면 균형 훈련', 'Wobble Board Balance Training', 'ANK-EX-NM-Wobble',
  'ankle_foot'::body_region, '발목 관절낭, 인대 고유감각 수용체, 비골근',
  '선 자세, 발란스 보드(wobble board) 또는 에어 쿠션 위에 양발 또는 한 발로 서기. 초기에는 손 지지 가능',
  '환자 가까이에 서서 낙상 방지. 필요 시 팔꿈치 또는 손을 잡아 안전 지지. 균형 상실 패턴 관찰',
  '해당 없음 (능동 균형 운동)',
  '전방향 불안정 균형 조절 — 발목 고유감각 수용체 자극',
  '[{"step":1,"instruction":"발란스 보드 위에 양발을 어깨 너비로 벌리고 선다. 초기에는 벽 또는 치료사의 도움을 받아 균형을 유지하며 보드의 흔들림에 익숙해진다. 1분간 양발로 서 있기를 목표로 하며, 이때 보드가 바닥에 닿지 않도록 발목으로 조절하는 감각을 익힌다."},{"step":2,"instruction":"양발 균형이 안정되면 손 지지를 점진적으로 줄인다. 치료사 손 잡기 → 벽 손끝 터치 → 손 지지 없이 순서로 진행한다. 각 단계에서 1–2분간 유지하여 안정성을 확인한 후 다음 단계로 진행한다."},{"step":3,"instruction":"양발 균형이 충분히 안정되면 한 발 서기로 전환한다. 환측 한 발로 보드 위에 서서 균형을 유지한다. 처음에는 눈을 뜨고 시행하며, 익숙해지면 눈을 감고 시행하여 시각 의존도를 낮춘다."},{"step":4,"instruction":"한 발 서기가 안정되면 난이도를 점진적으로 높인다. 눈 감기 → 공 주고받기(이중 과제) → 발란스 보드 위에서 상지 운동 추가 순서로 진행한다. 세션당 3–5세트, 세트당 30–60초를 목표로 한다."},{"step":5,"instruction":"4–6주 후 한 발 서기 시간(눈 뜨기·감기), 동적 균형 검사(Y-Balance Test), 발목 기능 설문지(FAAM 또는 CAIT) 점수를 재평가한다. 기능적 회복이 확인되면 스포츠별 특이적 훈련(점프, 방향 전환 등)으로 전환을 고려한다."}]'::jsonb,
  '{"proprioception_training","functional_recovery","sport_return","pain_relief"}',
  '{"subacute","chronic","sport_return"}',
  '{"chronic_ankle_instability","ankle_sprain_recurrence","balance_disorder","peroneal_weakness"}',
  '{"fracture","severe_pain_with_weightbearing","malignancy"}',
  'level_1b'::evidence_level,
  '불안정 표면 균형 훈련은 발목 인대 손상 후 고유감각 수용체 기능 회복에 효과를 기대할 수 있으며, 만성 발목 불안정성의 재손상 예방에 활용 가능성이 있다. 눈 감기 단계는 시각 보상 감소로 발목 고유감각에 대한 의존도를 높이는 핵심 진행 방법이 될 수 있다. 낙상 위험이 있으므로 치료사가 항상 가까이 대기하는 것이 안전하며, 특히 고령 환자에서는 양발 수행 단계를 충분히 연습한 후 한 발로 진행하는 것이 바람직할 수 있다.',
  'fracture, severe_pain_with_weightbearing, malignancy',
  'acute_ankle_sprain, severe_osteoporosis, DVT',
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
-- technique_stats 초기 레코드 생성
-- ============================================================
INSERT INTO technique_stats (technique_id, recommendation_weight)
SELECT id, 0.7
FROM techniques
WHERE abbreviation IN (
  'ANK-EX-RES-CalfRaise',
  'ANK-EX-RES-DF',
  'ANK-EX-RES-Peron',
  'ANK-EX-BW-ABC',
  'ANK-EX-BW-ShortFoot',
  'ANK-EX-NM-SEBT',
  'ANK-EX-NM-Wobble'
)
ON CONFLICT (technique_id) DO NOTHING;

COMMIT;

-- ============================================================
-- 검증 쿼리 (실행 후 확인용)
-- SELECT abbreviation, name_ko, category, evidence_level
-- FROM techniques
-- WHERE abbreviation IN (
--   'ANK-EX-RES-CalfRaise','ANK-EX-RES-DF','ANK-EX-RES-Peron',
--   'ANK-EX-BW-ABC','ANK-EX-BW-ShortFoot',
--   'ANK-EX-NM-SEBT','ANK-EX-NM-Wobble'
-- )
-- ORDER BY category, abbreviation;
-- 기대값: 7개 (category_ex_resistance 3 + category_ex_bodyweight 2 + category_ex_neuromuscular 2)
-- ============================================================
