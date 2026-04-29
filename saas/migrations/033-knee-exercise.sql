-- Migration 033 — 슬관절 운동 처방 (7기법)
-- knee body_region: 근력 저항(3) + 자체중량(2) + 신경근 훈련(2)
-- sw-db-architect | 2026-04-29

BEGIN;

-- ────────────────────────────────
-- [1] 터미널 무릎 신전 (VMO 강화)
-- category: category_ex_resistance
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
  '운동 처방 — 슬관절 근력 강화',
  '터미널 무릎 신전 (VMO 강화)', 'Terminal Knee Extension (VMO Strengthening)', 'KN-EX-RES-TKE',
  'knee'::body_region, '내측광근(VMO), 대퇴사두근',
  '선 자세, 밴드를 슬와부(무릎 뒤쪽)에 걸고 한발로 서거나 양발 어깨 너비로 선다. 무릎은 약 20~30° 굴곡 시작 위치.',
  '환자 옆에서 무릎 정렬 및 발 외전·내전 보상 동작 관찰, 직접 접촉 없음(언어·시각 피드백 제공)',
  '탄성 밴드 — 슬와부(무릎 뒤쪽) 접촉',
  '슬관절 완전 신전 방향 (-10°~0°)',
  '[{"step":1,"instruction":"탄성 밴드를 슬와부(무릎 오금 부위)에 걸고 저항을 앞쪽에서 고정한다. 선 자세에서 무릎을 약 20~30° 구부린 상태를 시작 자세로 한다."},{"step":2,"instruction":"천천히 무릎을 완전히 펴는 방향으로 신전한다(-10°~0°). 이때 대퇴 내측(VMO)의 수축이 느껴지도록 의식적으로 집중한다."},{"step":3,"instruction":"완전 신전 위치에서 2~3초 등장성 수축을 유지하고, 통증이 없는 범위에서 천천히 시작 위치로 돌아온다."},{"step":4,"instruction":"10~15회 3세트 수행한다. 세트 간 30~60초 휴식. 무릎이 안쪽으로 쏠리거나 발이 외회전되는 보상 동작이 생기면 즉시 교정한다."},{"step":5,"instruction":"2주마다 밴드 저항을 한 단계씩 높여 점진적 과부하를 적용한다. 가정 운동 처방으로 하루 2세트, 좌우 각각 수행하도록 안내한다."}]'::jsonb,
  '{"vmo_strengthening","pain_relief","patellofemoral_stability"}',
  '{"subacute","chronic","post_op_acl","patellofemoral_pain"}',
  '{"knee_pain","patellofemoral_pain","anterior_knee_pain","post_acl_rehab"}',
  '{"fracture","acute_hemarthrosis","severe_ligament_instability","wound_not_healed"}',
  'level_2b'::evidence_level,
  'VMO 선택적 강화 효과를 기대할 수 있으나, 내측광근만 독립적으로 분리 훈련하는 것은 해부학적으로 제한이 있을 수 있다. 종말 범위(-10°~0°) 집중으로 내측광근 활성화 비율이 높아질 가능성이 있다. 슬개대퇴통증증후군 환자에게 초기 단계 처방으로 적용할 수 있다.',
  '골절(확인 또는 의심), 급성 관절혈증, 중증 인대 불안정성, 수술 후 봉합 부위 미회복',
  '급성 염증기, 슬개건 파열 직후, 전방십자인대 재건술 후 6주 이내(프로토콜 확인 필요)',
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
-- [2] 슬굴곡근 컬
-- category: category_ex_resistance
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
  '운동 처방 — 슬관절 근력 강화',
  '슬굴곡근 컬', 'Hamstring Curl', 'KN-EX-RES-HamCurl',
  'knee'::body_region, '대퇴이두근, 반건양근, 반막양근',
  '엎드려 눕기 또는 선 자세(밴드 컬). 엎드려 눕기 시 발목 위쪽에 밴드를 고정하고 양손은 머리 아래 또는 옆에 자연스럽게 위치한다.',
  '환자 옆 또는 발 쪽에서 고관절이 바닥에서 들리는 보상 동작 관찰, 직접 접촉 없음',
  '탄성 밴드 — 발목 위쪽 접촉',
  '슬관절 굴곡 방향 (0°→90°)',
  '[{"step":1,"instruction":"엎드려 눕기 자세에서 탄성 밴드 한쪽을 발목 위에 고정하고, 반대쪽을 고정된 물체(침대 다리, 문 하단 등)에 연결한다. 선 자세라면 한쪽 발에 밴드를 걸고 안정적인 물체를 손으로 잡는다."},{"step":2,"instruction":"무릎을 천천히 굴곡하여 90° 방향으로 당긴다. 굴곡 동작 내내 고관절이 들리거나 골반이 회전하지 않도록 복부를 가볍게 긴장시켜 유지한다."},{"step":3,"instruction":"90° 굴곡 위치에서 1~2초 유지 후 천천히 시작 위치로 되돌린다. 편심성(eccentric) 단계를 의식적으로 느리게 수행한다."},{"step":4,"instruction":"10~15회 3세트 수행한다. 세트 간 30~60초 휴식. 양쪽 모두 동일하게 수행하며, 좌우 근력 차이가 있는 경우 약한 쪽을 먼저 수행한다."},{"step":5,"instruction":"2~3주 후 밴드 저항을 높이거나 머신 레그 컬(leg curl machine)로 전환하여 점진적 과부하를 적용한다. 재평가 시 양측 슬굴곡근·대퇴사두근 근력 비(H:Q ratio) 확인을 권장한다."}]'::jsonb,
  '{"hamstring_strengthening","pain_relief","hq_ratio_balance"}',
  '{"subacute","chronic","post_op_acl","hamstring_strain_recovery"}',
  '{"knee_pain","posterior_knee_pain","hamstring_weakness","post_acl_rehab"}',
  '{"fracture","acute_hamstring_rupture","wound_not_healed","dvt_suspected"}',
  'level_2b'::evidence_level,
  '슬굴곡근 강화는 슬관절 전후방 안정성 향상에 기여할 가능성이 있다. 전방십자인대 재건술 후 재활에서 H:Q ratio 0.6 이상 회복을 목표로 할 수 있으나, 수술 프로토콜별 허용 시기를 반드시 확인해야 한다. 편심성 단계를 강조하면 건·근 복합체의 적응을 기대할 수 있다.',
  '골절(확인 또는 의심), 슬굴곡근 완전 파열(수술 전), 수술 후 봉합 미회복, 심부정맥혈전증 의심',
  '급성 슬굴곡근 염좌(1주 이내), 전방십자인대 재건술 초기 6주(수술팀 프로토콜 우선)',
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
-- [3] 스텝업 운동
-- category: category_ex_resistance
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
  '운동 처방 — 기능적 하지 강화',
  '스텝업 운동', 'Step-Up Exercise', 'KN-EX-RES-StepUp',
  'knee'::body_region, '대퇴사두근, 중둔근, 슬굴곡근',
  '선 자세, 10~20cm 높이의 안정적인 스텝(계단, 스텝 박스) 앞에 선다. 상체는 곧게 세우고 양팔은 자연스럽게 내리거나 균형을 위해 가볍게 벌린다.',
  '환자 옆에서 무릎 정렬(knee valgus 방지), 골반 기울기, 상체 과도한 전방 경사 관찰. 필요 시 손으로 가볍게 안정 지지.',
  '해당 없음 (자체중량 능동 운동)',
  '상방 스텝업 방향 (전방 또는 측방)',
  '[{"step":1,"instruction":"10cm 스텝 앞에 선 자세로 서고, 한쪽 발을 스텝 위에 올린다(전방 스텝업). 체중을 스텝 위의 발로 완전히 이동하면서 무릎을 펴고 반대 발을 스텝 위로 가져온다."},{"step":2,"instruction":"스텝 위에서 양발이 모인 자세를 잠깐 유지한 후, 내려오는 발을 천천히 바닥으로 내린다(편심성 단계). 내려올 때 무릎이 안쪽으로 쏠리지 않도록 의식적으로 외측 정렬을 유지한다."},{"step":3,"instruction":"한쪽 다리 10~15회 2~3세트 수행한다. 측방 스텝업(lateral step-up)을 추가하여 중둔근 활성화를 높일 수 있다. 세트 간 30~60초 휴식."},{"step":4,"instruction":"2~3주 후 스텝 높이를 15~20cm로 높이거나 손에 가벼운 덤벨을 쥐고 수행하여 점진적 과부하를 적용한다."},{"step":5,"instruction":"재평가 시 30초 스텝업 횟수, 무릎 통증 NRS, 기능적 동작 관찰을 통해 진행 여부를 결정한다. 근력 향상 후 단일 하지 스쿼트 등 고급 운동으로 전환을 고려할 수 있다."}]'::jsonb,
  '{"functional_strengthening","quadriceps_strengthening","hip_abductor_strengthening"}',
  '{"subacute","chronic","post_op_tkr","post_op_acl","patellofemoral_pain"}',
  '{"knee_pain","patellofemoral_pain","functional_weakness","post_surgical_rehab"}',
  '{"fracture","acute_hemarthrosis","severe_balance_deficit","wound_not_healed"}',
  'level_2b'::evidence_level,
  '스텝업은 기능적 일상 동작(계단 오르기)과 직접 연관된 운동으로 환자 동기부여에 유리할 수 있다. 슬개대퇴통증증후군 환자에서 무릎 통증 없이 수행 가능한 스텝 높이에서 시작하는 것이 중요하다. 전방 스텝업과 측방 스텝업을 병행하면 대퇴사두근과 중둔근을 함께 강화할 가능성이 있다.',
  '골절(확인 또는 의심), 급성 관절혈증, 중증 균형 장애(낙상 위험), 수술 후 봉합 미회복',
  '급성 염증기, 슬관절 치환술 후 초기 단계(8~12주 이후 프로토콜 확인), 심한 어지럼증',
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
-- [4] 미니 스쿼트 (벽 스쿼트)
-- category: category_ex_bodyweight
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
  '운동 처방 — 하지 자체중량 강화',
  '미니 스쿼트 (벽 스쿼트)', 'Mini Squat / Wall Squat', 'KN-EX-BW-MiniSquat',
  'knee'::body_region, '대퇴사두근, 슬개대퇴관절',
  '선 자세, 등을 벽에 기대고 발을 벽에서 30~40cm 앞으로 위치시킨다. 발은 어깨 너비로 벌리고 발끝은 약간 외회전(10~15°)한다.',
  '환자 정면 또는 옆에서 무릎이 발끝 방향으로 정렬되는지, 무릎 내측 쏠림(valgus) 관찰. 필요 시 언어 피드백 제공.',
  '해당 없음 (자체중량 능동 운동 / 벽 접촉)',
  '슬관절 굴곡 방향 (0°~45°)',
  '[{"step":1,"instruction":"등을 벽에 기대고 선 자세에서 발을 벽에서 30~40cm 앞에 어깨 너비로 놓는다. 편안한 자세로 체중을 균등하게 양발에 분산한다."},{"step":2,"instruction":"등이 벽에서 떨어지지 않도록 유지하면서 무릎을 서서히 구부려 0°에서 45° 범위까지 내려간다. 무릎이 발끝 방향과 일치하도록 정렬을 유지한다."},{"step":3,"instruction":"45° 굴곡 위치에서 2~3초 등장성 유지 후 천천히 시작 위치로 돌아온다. 통증이 없는 범위에서만 수행하며, 통증 발생 시 굴곡 각도를 줄인다."},{"step":4,"instruction":"15~20회 2~3세트 수행한다. 통증 없이 45° 수행이 안정화되면 60°, 이후 90°로 범위를 점진적으로 늘린다."},{"step":5,"instruction":"2~3주 후 벽 지지 없이 자유 스쿼트로 전환하거나, 양발 스쿼트에서 단일 하지 미니 스쿼트로 난이도를 높인다. 재평가 시 무릎 통증 NRS 및 스쿼트 깊이를 기록한다."}]'::jsonb,
  '{"quadriceps_strengthening","patellofemoral_loading","functional_recovery"}',
  '{"subacute","chronic","patellofemoral_pain","osteoarthritis_mild"}',
  '{"knee_pain","patellofemoral_pain","anterior_knee_pain","mild_knee_oa"}',
  '{"fracture","acute_hemarthrosis","severe_patellofemoral_degeneration","wound_not_healed"}',
  'level_2b'::evidence_level,
  '벽 지지는 초기 단계에서 슬개대퇴관절 압력을 줄이면서 대퇴사두근 강화를 시작할 수 있는 방법으로 고려할 수 있다. 슬관절 45° 이내에서는 슬개대퇴관절 압력이 상대적으로 낮아 통증이 있는 환자도 수행 가능성이 있다. 무릎 통증 위치와 각도를 기록하여 맞춤형 범위를 설정하는 것이 중요하다.',
  '골절(확인 또는 의심), 급성 관절혈증, 중증 슬개대퇴관절 퇴행(심한 마찰음·잠김 동반), 수술 후 봉합 미회복',
  '급성 염증기(통증 NRS 7 이상), 슬관절 전치환술 후 초기 단계, 심한 균형 장애',
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
-- [5] 슬개건 강화 운동 (편심성 경사판 스쿼트)
-- category: category_ex_bodyweight
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
  '운동 처방 — 슬개건 편심성 강화',
  '슬개건 강화 운동 (편심성 경사판 스쿼트)', 'Eccentric Patellar Tendon Loading (Decline Squat)', 'KN-EX-BW-EccDecline',
  'knee'::body_region, '슬개건, 대퇴사두근',
  '선 자세, 25° 경사판(decline board) 위에 단일 하지로 서거나 양발로 선다. 발꿈치가 높고 발끝이 낮은 방향으로 경사. 상체는 가능한 곧게 유지한다.',
  '환자 옆에서 슬개건 부위 통증 반응(NRS), 무릎 정렬, 상체 전방 경사 보상 관찰. 초기에는 안전을 위해 손잡이 근처에서 진행.',
  '해당 없음 (자체중량 능동 운동 / 경사판 접촉)',
  '슬관절 굴곡 방향 (편심성 하강 강조)',
  '[{"step":1,"instruction":"25° 경사판 위에 양발(초기) 또는 한발(진행)로 선다. 손잡이나 벽을 가볍게 잡아 균형을 보조한다. 경사판이 없는 경우 두꺼운 판이나 쐐기 모양 도구로 대체할 수 있다."},{"step":2,"instruction":"천천히 무릎을 구부려 60~70° 굴곡 위치까지 내려간다(편심성 단계 — 3~4초). 이 과정에서 슬개건에 부하가 집중된다. 통증이 NRS 3~5 범위라면 진행 가능하나, NRS 6 이상이면 중단한다."},{"step":3,"instruction":"양발을 이용하여 시작 위치로 돌아온다(구심성 단계는 가볍게). 편심성 하강이 핵심이므로 올라올 때는 양발을 함께 사용해도 된다."},{"step":4,"instruction":"10~15회 3세트 수행한다. 처음 1~2주는 양발로, 이후 단일 하지로 전환한다. 세트 간 1~2분 휴식."},{"step":5,"instruction":"6~12주 프로그램으로 운영한다. 12주 후 슬개건 통증 NRS, VISA-P 점수(슬개건병증 기능 평가) 재평가를 권장한다. 운동 직후 일시적인 통증 증가는 허용 범위일 수 있으나, 다음 날까지 지속되는 통증 악화는 부하를 줄여야 한다는 신호로 고려한다."}]'::jsonb,
  '{"eccentric_loading","patellar_tendon_loading","tendinopathy_rehab"}',
  '{"subacute","chronic","patellar_tendinopathy","jumping_athletes"}',
  '{"patellar_tendinopathy","anterior_knee_pain","jumping_knee","tendon_pain"}',
  '{"fracture","patellar_tendon_rupture","acute_tendon_tear","wound_not_healed"}',
  'level_1b'::evidence_level,
  '경사판 편심성 스쿼트는 슬개건병증(점퍼스 니)의 보존적 치료에서 가장 강력한 근거를 가진 운동 중 하나로 고려된다. 편심성 수축 시 슬개건 내 콜라겐 재형성을 촉진할 가능성이 있으며, 6~12주 지속이 권장된다. 운동 시 어느 정도의 통증(NRS 3~5)은 허용될 수 있으나 환자에게 이를 미리 설명하는 것이 중요하다. 경사판 없이 수행하면 대퇴사두근보다 슬굴곡근·종아리 근육 부하가 증가할 수 있어 경사판 사용이 권장된다.',
  '골절(확인 또는 의심), 슬개건 완전 파열, 급성 건 파열, 수술 후 봉합 미회복',
  '급성 슬개건 염증기(열감·부종 동반), 심한 균형 장애, 고령+골다공증(낙상 위험)',
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
-- [6] 단일 하지 균형 훈련
-- category: category_ex_neuromuscular
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
  '운동 처방 — 슬관절 고유감각 훈련',
  '단일 하지 균형 훈련', 'Single Leg Balance Training', 'KN-EX-NM-SLB',
  'knee'::body_region, '슬관절 관절낭, 십자인대 고유감각 수용체',
  '선 자세, 안정적인 바닥에서 시작. 지지 발은 어깨 너비 간격으로 자연스럽게 선 후 한쪽 발을 바닥에서 들어 단일 하지 선 자세를 취한다. 균형 초기 단계에서는 손잡이나 벽 근처에서 수행한다.',
  '환자 정면 또는 옆에서 균형 유지 능력, 무릎·골반 보상 동작, 상체 흔들림 정도 관찰. 낙상 방지를 위해 근처에 대기.',
  '해당 없음 (능동 균형 운동)',
  '해당 없음 (다방향 균형 유지)',
  '[{"step":1,"instruction":"단단한 바닥에서 한 발로 서는 자세를 취한다. 눈을 뜬 상태에서 30초 유지를 목표로 한다. 30초 달성 전 발이 바닥에 닿으면 다시 시도한다. 양쪽 각각 3회 수행한다."},{"step":2,"instruction":"30초 유지가 안정되면 눈을 감고 수행하여 시각 의존도를 줄인다. 눈을 감으면 고유감각 의존도가 높아진다. 처음에는 10~15초부터 시작한다."},{"step":3,"instruction":"안정화 후 폼 패드(foam pad) 또는 밸런스 보드 위에서 단일 하지 서기를 수행한다. 불안정 표면은 고유감각 수용체 자극을 증가시킬 가능성이 있다."},{"step":4,"instruction":"이중 과제(dual-task) 추가: 균형을 유지하면서 숫자 세기, 공 받기, 팔 운동 등을 병행한다. 실제 스포츠·일상 동작에서 균형과 인지 과제가 동시에 요구되기 때문이다."},{"step":5,"instruction":"6주 후 Y-balance test(또는 Star excursion balance test) 재평가를 통해 전·후방·내측 도달 거리 변화를 확인할 것을 권장한다. 스포츠 복귀 단계에서는 동적 균형 훈련(hop test)으로 진행할 수 있다."}]'::jsonb,
  '{"proprioception_training","balance_training","neuromuscular_control"}',
  '{"subacute","chronic","post_op_acl","post_ankle_sprain","functional_instability"}',
  '{"knee_instability","proprioceptive_deficit","post_acl_rehab","functional_instability"}',
  '{"fracture","severe_ligament_instability","wound_not_healed","severe_vestibular_disorder"}',
  'level_2b'::evidence_level,
  '슬관절 손상 및 수술 후 고유감각 기능 저하가 관찰될 수 있으며, 단일 하지 균형 훈련을 통해 고유감각 회복을 기대할 수 있다. 눈뜨기 → 눈감기 → 불안정 표면 → 이중 과제 순서의 단계적 진행이 신경근 재학습에 유리할 가능성이 있다. 전방십자인대 재건술 후 재활에서 고유감각 훈련은 스포츠 복귀 전 필수 요소로 고려된다.',
  '골절(확인 또는 의심), 중증 인대 불안정성(무릎이 접히는 반응), 수술 후 봉합 미회복, 심한 전정기관 장애',
  '급성 염증기, 중증 균형 장애(보조기구 없이 서기 불가), 심한 어지럼증',
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
-- [7] 착지 역학 재훈련
-- category: category_ex_neuromuscular
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
  '운동 처방 — 슬관절 신경근 조절',
  '착지 역학 재훈련', 'Landing Mechanics Retraining', 'KN-EX-NM-Landing',
  'knee'::body_region, '슬관절, 고관절, 발목 복합 운동 사슬',
  '선 자세, 안전한 바닥(매트 또는 스프링 바닥 권장). 초기에는 낮은 높이(10~15cm)에서 시작하고, 충분한 공간을 확보한다.',
  '환자 정면 및 옆에서 착지 시 무릎 내반/외반, 고관절 굴곡·외전 부족, 발목 흡수 패턴 관찰. 슬로우 모션 피드백 또는 언어 피드백 제공. 초기에는 안전을 위해 근처에 대기.',
  '해당 없음 (능동 착지 운동)',
  '충격 흡수 착지 방향 (양발 → 단일 하지 순서)',
  '[{"step":1,"instruction":"양발 착지 연습(bilateral landing): 낮은 박스(10~15cm)에서 내려오거나 제자리에서 양발 점프 후 착지한다. 착지 시 무릎과 고관절을 동시에 구부려 충격을 흡수하는 ''연착지'' 패턴을 만든다. 뒤꿈치가 아닌 발볼(앞발) 먼저 닿도록 유도한다."},{"step":2,"instruction":"착지 체크포인트 교육: 착지 직전·후 무릎이 발끝 방향으로 정렬(knee valgus 없음), 고관절 적절한 굴곡, 상체 과도한 전방 경사 없음. 거울 또는 치료사의 피드백으로 본인 착지 패턴을 확인한다."},{"step":3,"instruction":"점프 착지(jump-landing) 연습: 양발 점프 후 ''조용한'' 착지를 목표로 한다(소리가 작을수록 충격 흡수가 양호). 5~10회 3세트. 착지 소리를 피드백으로 활용할 수 있다."},{"step":4,"instruction":"단일 하지 착지(single-leg landing)로 전환: 양발 착지가 안정되면 한 발로 착지하는 훈련을 시작한다. 처음에는 낮은 높이, 이후 높이와 거리를 점진적으로 늘린다. 방향성 착지(전방·측방·대각선) 추가."},{"step":5,"instruction":"스포츠 특이적 동작 통합: 달리기 중 방향 전환, 커팅 동작, 디셀러레이션(감속) 훈련으로 진행한다. 6~8주 후 drop-jump 착지 영상 분석 또는 기능적 동작 스크리닝(FMS)으로 재평가를 권장한다."}]'::jsonb,
  '{"landing_mechanics","neuromuscular_control","acl_injury_prevention","dynamic_balance"}',
  '{"subacute","chronic","post_op_acl","return_to_sport","jumping_athletes"}',
  '{"knee_instability","acl_injury_prevention","post_acl_rehab","dynamic_valgus"}',
  '{"fracture","severe_ligament_instability","wound_not_healed","severe_pain_on_weight_bearing"}',
  'level_2b'::evidence_level,
  '전방십자인대 손상의 주요 기전 중 하나가 착지 시 동적 외반(dynamic valgus)이며, 착지 역학 재훈련을 통해 재손상 위험을 줄일 가능성이 있다. 양발 착지에서 단일 하지 착지로의 단계적 진행이 안전성 측면에서 권장된다. ''조용한 착지''라는 목표 제시가 환자의 충격 흡수 패턴 개선에 유용한 피드백이 될 수 있다. 스포츠 복귀 전 착지 역학 재훈련을 포함한 신경근 훈련 프로그램이 ACL 재파열 위험 감소에 기여할 가능성이 있다.',
  '골절(확인 또는 의심), 중증 인대 불안정성(체중 부하 불가), 수술 후 봉합 미회복, 체중 부하 시 심한 통증',
  '전방십자인대 재건술 후 4~6개월 이전(수술팀 복귀 허가 필요), 급성 염증기, 심한 균형 장애',
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
-- technique_stats 초기 레코드 생성 (7개 기법)
-- ============================================================
INSERT INTO technique_stats (technique_id, recommendation_weight)
SELECT id, 0.7
FROM techniques
WHERE abbreviation IN (
  'KN-EX-RES-TKE',
  'KN-EX-RES-HamCurl',
  'KN-EX-RES-StepUp',
  'KN-EX-BW-MiniSquat',
  'KN-EX-BW-EccDecline',
  'KN-EX-NM-SLB',
  'KN-EX-NM-Landing'
)
ON CONFLICT (technique_id) DO NOTHING;

COMMIT;

-- ============================================================
-- 검증 쿼리 (실행 후 확인용)
-- SELECT abbreviation, name_ko, category, evidence_level, is_published
--   FROM techniques
--   WHERE abbreviation IN (
--     'KN-EX-RES-TKE', 'KN-EX-RES-HamCurl', 'KN-EX-RES-StepUp',
--     'KN-EX-BW-MiniSquat', 'KN-EX-BW-EccDecline',
--     'KN-EX-NM-SLB', 'KN-EX-NM-Landing'
--   )
--   ORDER BY category, abbreviation;
-- 기대값: 7개 rows
-- ============================================================
