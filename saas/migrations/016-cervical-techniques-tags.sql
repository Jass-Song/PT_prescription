-- ============================================================
-- Migration 016: Cervical Techniques Tags + 11 New Technique INSERTs
--
-- Part 1: 기존 기법 카테고리별 태그 일괄 UPDATE (13개 카테고리)
-- Part 2: 신규 기법 11개 INSERT
--   [1]  흉쇄유돌근 능동 이완 기법                 category_art              / cervical
--   [2]  상부 승모근 능동 이완 기법                 category_art              / cervical
--   [3]  견갑거근 능동 이완 기법                   category_art              / cervical
--   [4]  경추 후관절 관절낭 심부 마찰 마사지          category_deep_friction    / cervical
--   [5]  후두하근 심부 마찰 마사지                  category_deep_friction    / cervical
--   [6]  SBL 근막경선 이완 — 경추·후두하 세그먼트    category_anatomy_trains   / NULL
--   [7]  SBAL/SBL 근막경선 이완 — 상지·경추 연결     category_anatomy_trains   / NULL
--   [8]  후두하근 트리거포인트 치료                  category_trigger_point    / cervical
--   [9]  상부 승모근 트리거포인트 치료               category_trigger_point    / cervical
--   [10] 요방형근 트리거포인트 치료                  category_trigger_point    / lumbar
--   [11] 이상근 트리거포인트 치료                   category_trigger_point    / lumbar
--
-- 전제 조건:
--   - 015-exercise-neural-lumbar-cervical.sql 실행 완료
--   - category_art, category_deep_friction, category_anatomy_trains,
--     category_trigger_point enum 존재
--
-- sw-db-architect | 2026-04-27
-- ============================================================

BEGIN;

-- ============================================================
-- PART 1: 기존 기법 카테고리별 symptom_tags / target_tags / contraindication_tags 일괄 UPDATE
-- ============================================================

-- category_mfr
UPDATE techniques SET
  symptom_tags = ARRAY['movement_pain','morning_stiffness','rest_pain','lbp_nonspecific','referred_pain'],
  target_tags = ARRAY['subacute','chronic','muscle_hypertonicity','sensitized'],
  contraindication_tags = ARRAY['fracture','malignancy','instability','neurological_deficit','active_infection','anticoagulants','vbi','upper_cervical_instability']
WHERE category = 'category_mfr';

-- category_art (요추)
UPDATE techniques SET
  symptom_tags = ARRAY['movement_pain','hypomobile','morning_stiffness','rest_pain','referred_pain','radicular_pain'],
  target_tags = ARRAY['subacute','chronic','muscle_hypertonicity'],
  contraindication_tags = ARRAY['fracture','malignancy','instability','neurological_deficit','active_infection','anticoagulants','osteoporosis']
WHERE category = 'category_art' AND body_region = 'lumbar';

-- category_art (경추)
UPDATE techniques SET
  symptom_tags = ARRAY['movement_pain','hypomobile','morning_stiffness','rest_pain','referred_pain','radicular_pain'],
  target_tags = ARRAY['subacute','chronic','muscle_hypertonicity'],
  contraindication_tags = ARRAY['fracture','malignancy','instability','neurological_deficit','active_infection','anticoagulants','osteoporosis','vbi','upper_cervical_instability']
WHERE category = 'category_art' AND body_region = 'cervical';

-- category_ctm
UPDATE techniques SET
  symptom_tags = ARRAY['movement_pain','rest_pain','lbp_nonspecific','cervicogenic_headache','morning_stiffness'],
  target_tags = ARRAY['acute','subacute','chronic','muscle_hypertonicity','sensitized'],
  contraindication_tags = ARRAY['fracture','malignancy','active_infection','anticoagulants','osteoporosis']
WHERE category = 'category_ctm';

-- category_deep_friction
UPDATE techniques SET
  symptom_tags = ARRAY['movement_pain','hypomobile','morning_stiffness','disc_related'],
  target_tags = ARRAY['subacute','chronic','muscle_hypertonicity'],
  contraindication_tags = ARRAY['fracture','malignancy','instability','neurological_deficit','osteoporosis','active_infection','anticoagulants']
WHERE category = 'category_deep_friction';

-- category_trigger_point
UPDATE techniques SET
  symptom_tags = ARRAY['movement_pain','hypomobile','rest_pain','referred_pain','cervicogenic_headache','lbp_nonspecific'],
  target_tags = ARRAY['acute','subacute','chronic','muscle_hypertonicity','sensitized'],
  contraindication_tags = ARRAY['fracture','malignancy','neurological_deficit','active_infection','anticoagulants']
WHERE category = 'category_trigger_point';

-- category_anatomy_trains
UPDATE techniques SET
  symptom_tags = ARRAY['movement_pain','hypomobile','morning_stiffness','lbp_nonspecific','cervicogenic_headache'],
  target_tags = ARRAY['subacute','chronic','muscle_hypertonicity'],
  contraindication_tags = ARRAY['fracture','malignancy','instability','neurological_deficit','active_infection']
WHERE category = 'category_anatomy_trains';

-- category_d_neural
UPDATE techniques SET
  symptom_tags = ARRAY['radicular_pain','movement_pain','disc_related'],
  target_tags = ARRAY['acute','subacute','chronic','sensitized'],
  contraindication_tags = ARRAY['fracture','malignancy','instability','neurological_deficit','active_infection']
WHERE category = 'category_d_neural';

-- category_mdt
UPDATE techniques SET
  symptom_tags = ARRAY['movement_pain','disc_related','radicular_pain','hypomobile','morning_stiffness'],
  target_tags = ARRAY['acute','subacute','chronic'],
  contraindication_tags = ARRAY['fracture','malignancy','instability','neurological_deficit','active_infection','vbi','upper_cervical_instability']
WHERE category = 'category_mdt';

-- category_scs
UPDATE techniques SET
  symptom_tags = ARRAY['rest_pain','movement_pain','muscle_hypertonicity'],
  target_tags = ARRAY['acute','subacute','chronic','sensitized'],
  contraindication_tags = ARRAY['fracture','malignancy','instability','neurological_deficit','active_infection','anticoagulants','vbi','upper_cervical_instability']
WHERE category = 'category_scs';

-- category_pne
UPDATE techniques SET
  symptom_tags = ARRAY['movement_pain','rest_pain','lbp_nonspecific','cervicogenic_headache','referred_pain'],
  target_tags = ARRAY['chronic','subacute','acute','sensitized','muscle_hypertonicity'],
  contraindication_tags = ARRAY['fracture','malignancy','instability','neurological_deficit']
WHERE category = 'category_pne';

-- category_joint_mobilization
UPDATE techniques SET
  symptom_tags = ARRAY['movement_pain','hypomobile','morning_stiffness','disc_related','lbp_nonspecific'],
  target_tags = ARRAY['acute','subacute','chronic','muscle_hypertonicity','sensitized'],
  contraindication_tags = ARRAY['fracture','malignancy','instability','neurological_deficit','osteoporosis','anticoagulants','active_infection','vbi','upper_cervical_instability']
WHERE category = 'category_joint_mobilization';

-- category_mulligan
UPDATE techniques SET
  symptom_tags = ARRAY['movement_pain','hypomobile','morning_stiffness','radicular_pain','cervicogenic_headache','disc_related'],
  target_tags = ARRAY['acute','subacute','chronic','muscle_hypertonicity','sensitized'],
  contraindication_tags = ARRAY['fracture','malignancy','instability','neurological_deficit','osteoporosis','active_infection','vbi','upper_cervical_instability']
WHERE category = 'category_mulligan';

-- ============================================================
-- PART 2: 신규 기법 11개 INSERT
-- ============================================================

-- ============================================================
-- [1] 흉쇄유돌근 능동 이완 기법 (ART)
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
  'ART — 경추부 연부조직',
  '흉쇄유돌근 능동 이완 기법', 'Active Release Technique — Sternocleidomastoid', 'CervART-SCM',
  'cervical'::body_region, '흉골(sternum)·쇄골(clavicle)에서 측두골 유양돌기(mastoid process)까지',
  '등 대고 누운 자세 — 치료 방향으로 10~15° 측굴하여 SCM 이완',
  '환자 머리 쪽 또는 치료할 쪽 어깨 수준; 핀칭 그립(엄지·검지) 또는 검지·중지 끝으로 SCM 근복 접촉',
  '엄지·검지 핀칭 — 경동맥 외측 SCM 근복 (유양돌기 하단~흉골·쇄골 부착부 구간)',
  'SCM 주행 방향과 수직 압박 유지 + 경추 회전 또는 측굴 반대 방향 능동 이동',
  '[{"step":1,"instruction":"안전 확인 및 촉진 단계: 환자 목을 치료 방향으로 10~15° 측굴시켜 SCM을 약간 이완. 유양돌기에서 흉골·쇄골 부착부까지 SCM 전체 주행 경로 촉진. 단단하거나 압통 있는 구간 확인. SCM 바로 앞 경동맥 박동 위치 확인 후 접촉 위치 결정."},{"step":2,"instruction":"접촉 고정 단계: 핀칭 그립 또는 두 손가락 끝으로 목표 구간 SCM에 가볍게 접촉. 경동맥에서 외측으로 충분히 벗어나 있는지 재확인. 통증 NRS 기준점 확인."},{"step":3,"instruction":"능동 신전 시행 단계: 접촉 유지 상태에서 환자에게 고개를 천천히 반대쪽으로 돌리거나 반대쪽으로 기울이도록 지시. 5~8초에 걸쳐 천천히 이동하며 SCM 신장. 최대 신장 위치에서 2~3초 유지 후 시작 자세로 복귀."},{"step":4,"instruction":"반복/조정 단계: 1회 완료 후 시작 자세로 복귀. 2~3회 반복 후 접촉 위치를 1~2cm씩 이동하며 SCM 전체 주행 경로 탐색. 흉골두(sternal head)와 쇄골두(clavicular head) 분리 탐색 가능. 각 부위 2~3회 반복."},{"step":5,"instruction":"이상 반응 확인 및 재평가 단계: 시술 중 어지러움·오심·시야 변화·귀울림 발생 시 즉시 접촉 해제. 시술 후 앉은 자세에서 경추 회전 ROM 재측정. 통증 NRS 재측정."}]'::jsonb,
  '{"pain_relief","rom_improvement","soft_tissue"}',
  '{"subacute","chronic","muscle_hypertonicity"}',
  '{"movement_pain","hypomobile","morning_stiffness","rest_pain","referred_pain","cervicogenic_headache"}',
  '{"fracture","malignancy","instability","neurological_deficit","active_infection","anticoagulants","osteoporosis","vbi","upper_cervical_instability"}',
  'level_4'::evidence_level,
  '경동맥 위치 먼저 확인 필수 — 엄지로 SCM 앞 경계를 따라가면 박동 지점이 경동맥. 이 지점을 피해 SCM 근복(근육 살)만 접촉. 시술 중 어지러움은 경동맥동 자극 반응일 수 있으므로 즉시 접촉 해제 후 안정. 두통 환자에는 유양돌기 하단 1/3 구간 우선 탐색 — 두통 관련 트리거포인트가 가장 흔히 존재.',
  'carotid_artery_disease, fracture, malignancy, neurological_deficit, vbi',
  'osteoporosis, anticoagulants, inflammation_acute, thyroid_enlargement',
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
-- [2] 상부 승모근 능동 이완 기법 (ART)
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
  'ART — 경추부 연부조직',
  '상부 승모근 능동 이완 기법', 'Active Release Technique — Upper Trapezius', 'CervART-UT',
  'cervical'::body_region, '후두골·경추 극돌기(C1-C5)에서 쇄골 외측 1/3·견봉(acromion)까지',
  '앉은 자세 또는 등 대고 누운 자세 — 치료 쪽으로 10~15° 측굴하여 근육 약간 이완',
  '환자 뒤 또는 치료할 쪽 옆; 핀칭 그립 또는 세 손가락 끝으로 상부 승모근 근복 접촉',
  '핀칭 그립 또는 손가락 끝 — 경추 후외측에서 쇄골 외측까지 전체 근복',
  '상부 승모근 주행 방향(경추-견갑)과 수직 압박 유지 + 경추 반대측 측굴 또는 견갑 하강 능동 이동',
  '[{"step":1,"instruction":"촉진 단계: 경추 후외측에서 쇄골 외측까지 상부 승모근 전체 주행 경로 촉진. 다른 부위보다 단단한 띠 형태의 경결(taut band) 구간 확인. 특히 근복 중간부(C3-C4 높이 외측)와 근·건 이행부 집중 탐색. 연관통 패턴(어깨나 머리 쪽 퍼짐) 확인."},{"step":2,"instruction":"접촉 고정 단계: 핀칭 그립 또는 손가락 끝으로 목표 구간에 가볍게 접촉. 연관통 재현 여부 확인. 통증 NRS 기준점 확인."},{"step":3,"instruction":"능동 신전 시행 단계: 접촉 유지 상태에서 경추 반대측 측굴(고개를 반대쪽으로 천천히 기울이기) 또는 견갑 하강(어깨를 천천히 아래로 내리기), 또는 두 움직임 동시 수행. 치료사 손 아래 긴장 증가 확인. 최대 신장 위치에서 2~3초 유지."},{"step":4,"instruction":"반복/조정 단계: 1회 완료 후 시작 자세로 복귀. 3~5회 반복 후 접촉 위치를 1~2cm씩 이동하며 근복 전체 탐색. 근·건 이행부(쇄골 부착 직상방)는 별도 탐색."},{"step":5,"instruction":"재평가 단계: 시술 후 경추 측굴 ROM 재측정, 어깨 거상(들어올리기) 시 불편감 재평가. 통증 NRS 재측정. 목과 어깨 무거운 느낌 변화 확인."}]'::jsonb,
  '{"pain_relief","rom_improvement","soft_tissue"}',
  '{"subacute","chronic","muscle_hypertonicity"}',
  '{"movement_pain","hypomobile","morning_stiffness","rest_pain","referred_pain","cervicogenic_headache"}',
  '{"fracture","malignancy","instability","neurological_deficit","active_infection","anticoagulants","osteoporosis","vbi","upper_cervical_instability"}',
  'level_2b'::evidence_level,
  '압박 강도 NRS 3~4 수준(시원하게 아픈 느낌)이 적절 — 너무 강한 압박은 근방어 반응을 오히려 증가시킴. 경추 측굴 + 견갑 하강 조합이 상부 승모근 전체 길이의 최대 신장을 유도. 근·건 이행부(쇄골 직상방)는 쇄골하혈관 인근이므로 깊은 압박 금지.',
  'fracture, malignancy, instability, neurological_deficit, vbi',
  'osteoporosis, inflammation_acute, pregnancy, TOS',
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
-- [3] 견갑거근 능동 이완 기법 (ART)
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
  'ART — 경추부 연부조직',
  '견갑거근 능동 이완 기법', 'Active Release Technique — Levator Scapulae', 'CervART-LS',
  'cervical'::body_region, '경추 횡돌기(C1-C4)에서 견갑골 상각(superior angle of scapula)까지',
  '앉은 자세 또는 등 대고 누운 자세 — 치료 쪽으로 10~15° 측굴하여 근육 약간 이완',
  '환자 머리 쪽(앙와위) 또는 치료할 쪽 뒤(좌위); 검지·중지 두 손가락 끝으로 경추 후외측(C2-C4 횡돌기 외측)에서 견갑골 상각 방향 접촉',
  '검지·중지 끝 — 상부 승모근 전방 경계 내측·후방의 견갑거근 근복 (C2-C4 횡돌기 외측~견갑골 상각)',
  '견갑거근 주행 방향(경추-견갑 대각선)과 수직 압박 유지 + 경추 반대측 굴곡+회전 또는 견갑 하강 능동 이동',
  '[{"step":1,"instruction":"촉진 단계: 경추 C2-C4 횡돌기 외측에서 견갑골 상각까지 견갑거근 주행 경로 촉진. 상부 승모근 전방 경계를 확인하고 그 내측·후방에서 더 깊이 위치한 견갑거근 근복 탐색. 단단한 띠(taut band)나 압통 있는 구간, 특히 C3-C4 수준에서 견갑골 상각 직상방 구간 집중 탐색."},{"step":2,"instruction":"접촉 고정 단계: 두 손가락 끝으로 목표 구간에 가볍게 접촉 후 서서히 깊이 증가. 어깨 위쪽이나 목 옆쪽으로 당기는 연관통 패턴 확인. 통증 NRS 기준점 확인."},{"step":3,"instruction":"능동 신전 시행 단계: 접촉 유지 상태에서 경추 반대측 굴곡+회전 조합(고개를 반대쪽으로 돌리면서 동시에 아래로 숙이기) 또는 견갑 하강(어깨를 아래로 천천히 내리기) 수행. 최대 신장 위치에서 2~3초 유지."},{"step":4,"instruction":"반복/조정 단계: 1회 완료 후 시작 자세로 복귀. 3~5회 반복 후 접촉 위치를 상하로 1~2cm 이동하며 전체 근복 탐색. C2-C3 수준(상부)과 C4-견갑골 상각 수준(하부) 구간을 각각 탐색."},{"step":5,"instruction":"재평가 단계: 시술 후 경추 반대측 회전 ROM 재측정. 고개 돌릴 때 목 옆쪽 당기는 느낌 변화 확인. 통증 NRS 재측정."}]'::jsonb,
  '{"pain_relief","rom_improvement","soft_tissue"}',
  '{"subacute","chronic","muscle_hypertonicity"}',
  '{"movement_pain","hypomobile","morning_stiffness","rest_pain","referred_pain","radicular_pain"}',
  '{"fracture","malignancy","instability","neurological_deficit","active_infection","anticoagulants","osteoporosis","vbi","upper_cervical_instability"}',
  'level_4'::evidence_level,
  '최대 신장 = 경추 반대측 굴곡+회전 — 단순 측굴보다 이 조합이 견갑거근 전체 길이의 최대 신장을 유도. 상부 승모근 전방 경계 확인 후 그 내측으로 진입해야 견갑거근에 도달 — 표층만 접촉하면 상부 승모근 처리에 그침. 급성 사경(wry neck) 급성기는 근방어 반응이 강하므로 통증 NRS 5 이하로 감소 후 시작.',
  'fracture, malignancy, instability, neurological_deficit, vbi, rheumatoid_cervical',
  'osteoporosis, acute_wry_neck, cervical_disc_herniation_with_neuro',
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
-- [4] 경추 후관절 관절낭 심부 마찰 마사지
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
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'Cyriax 심부 마찰 — 경추 후관절 관절낭',
  '경추 후관절 관절낭 심부 마찰 마사지', 'Deep Friction Massage — Cervical Facet Joint Capsule', 'CervDF-FC',
  'cervical'::body_region, 'C2-C7 후관절(zygapophyseal joint) 관절낭 — 증상 분절 기준',
  '엎드린 자세(복와위) 또는 앉은 자세 — 이마를 치료대 머리 받침에 올리거나 타월 롤 지지',
  '환자 머리 쪽 또는 치료할 쪽 옆; 강화 검지 끝(검지 위에 중지 겹침) 또는 엄지로 후관절 관절낭 위치 접촉',
  '강화 검지 끝 또는 엄지 — 극돌기에서 외측 약 1.5~2cm 지점 (후관절 관절낭 위)',
  '관절낭 위에서 수직 압박 후 관절면 주행 방향(두-미측)과 수직인 내-외측 방향으로 왕복 마찰',
  '[{"step":1,"instruction":"분절 및 관절낭 위치 확인 단계: 증상 분절 극돌기 촉진 후 극돌기 외측 1.5~2cm 지점을 검지 끝으로 가볍게 눌러 압통 재현 여부 확인. 편측 압통이 명확히 재현되는 지점이 목표 후관절 관절낭 위치."},{"step":2,"instruction":"피부 밀착 및 깊이 확보 단계: 목표 부위에 손가락 끝을 밀착시킨 후 환자가 숨을 내쉬는 순간 경추 후면 방향으로 서서히 깊이 증가. 피부와 함께 움직이는 것이 핵심 — 윤활제 사용 금지. 관절낭의 단단하거나 두꺼운 질감이 느껴지는 깊이까지 도달."},{"step":3,"instruction":"수직 마찰 시행 단계: 적절한 깊이에서 관절낭 주행 방향(두-미측)과 수직인 내-외측 방향으로 짧고 규칙적인 왕복 마찰 시작. 마찰 폭 약 1cm 이내. 속도 분당 약 60~80회. 손가락이 피부 위에서 미끄러지지 않도록 피부와 함께 왕복."},{"step":4,"instruction":"강도 조절 및 지속 단계: 처음 2~3분은 비교적 가볍게 시작. 환자 반응 확인하며 점차 압박 깊이와 마찰 강도 증가. 총 5~10분 지속. 팔 저림·전기 느낌 발생 시 즉시 중단."},{"step":5,"instruction":"재평가 단계: 시술 후 해당 분절 압통 재측정. 경추 회전 또는 신전 ROM 재측정. 시술 직후 일시적 통증 증가(반응성 통증)는 정상이나 24시간 이내 완화 예상. 통증 NRS 재측정."}]'::jsonb,
  '{"pain_relief","soft_tissue"}',
  '{"subacute","chronic","muscle_hypertonicity"}',
  '{"movement_pain","hypomobile","morning_stiffness","disc_related"}',
  '{"fracture","malignancy","instability","neurological_deficit","osteoporosis","active_infection","anticoagulants","vbi","upper_cervical_instability"}',
  'level_4'::evidence_level,
  '피부와 함께 움직이는 것이 DFM의 핵심 원칙 — 손가락 끝이 피부 위에서 미끄러지면 표층만 자극되어 효과 없음. 극돌기 외측 1.5~2cm가 일반적 목표 위치 — 이 구간에서 압통이 가장 강한 지점이 목표. 시술 후 Maitland PA 또는 SNAG 병행 시 가동범위 개선 효과 증대. 반응성 통증(24시간 악화)은 정상이나 48시간 이상 지속 시 강도 조절 필요.',
  'fracture, malignancy, neurological_deficit, vbi, inflammation_acute, rheumatoid_cervical, facet_injection_4wk',
  'osteoporosis, anticoagulants, skin_lesion, severe_acute_pain_NRS7',
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
-- [5] 후두하근 심부 마찰 마사지
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
  'category_deep_friction',
  (SELECT id FROM technique_categories WHERE category_key = 'category_deep_friction'),
  'Cyriax 심부 마찰 — 경추-두개 접합부',
  '후두하근 심부 마찰 마사지', 'Deep Friction Massage — Suboccipital Muscles', 'CervDF-SOC',
  'cervical'::body_region, '경추-두개 접합부(craniocervical junction) — C0-C1-C2 후면',
  '등 대고 누운 자세 — 머리를 치료사 손 또는 치료대 끝에 올려 경추 약 10~15° 굴곡',
  '환자 머리 쪽; 양손 검지·중지를 후두골 하연 아래 공간으로 삽입하여 C1-C2 후면 접촉',
  '양손 검지·중지 끝 — 후두골 하연에서 하방 1~2cm, 정중선 외측 1~2cm 구간',
  '후두하 구간에서 수직(전방) 압박 후 근육 주행 방향과 수직인 내-외측 방향으로 왕복 마찰',
  '[{"step":1,"instruction":"후두하 공간 확보 및 촉진 단계: 환자 머리를 치료사 손 위에 올려 후두하 공간 확보. 후두골 하연(뒤통수 뼈 아래 경계)을 촉진 후 바로 아래로 손가락 끝을 부드럽게 삽입. C1 후궁 및 C1-C2 사이 공간에서 압통 있는 구간 탐색. 좌우 각각 탐색 후 더 민감한 쪽 먼저 시작."},{"step":2,"instruction":"접촉 고정 단계: 목표 구간에 손가락 끝을 밀착. 환자 머리 무게로 자연스럽게 압박이 가해지도록 조절(치료사가 강한 힘으로 밀지 않음). 뒤통수나 눈 뒤쪽으로 퍼지는 느낌 확인. 통증 NRS 기준점 확인."},{"step":3,"instruction":"수직 마찰 시행 단계: 적절한 깊이에서 근육 주행 방향(경추 장축)과 수직인 내-외측 방향으로 짧고 규칙적인 왕복 마찰 시작. 마찰 폭 약 1cm 이내. 속도 분당 약 50~70회 왕복. 손가락이 피부 위에서 미끄러지지 않도록 주의."},{"step":4,"instruction":"강도 조절 및 지속 단계: 처음 2~3분은 가볍게 시작. 환자 반응 확인하며 점진적으로 깊이 조절. 총 5~8분 지속. 시술 중 어지러움·오심·시야 변화 발생 시 즉시 중단. 양측 모두 시행 시 한쪽 먼저 완료 후 다른 쪽 진행."},{"step":5,"instruction":"재평가 단계: 시술 후 후두하 압통 재측정. 경추 굴곡 ROM 재측정. 두통이나 뒤통수 무거운 느낌 변화 확인. 통증 NRS 재측정."}]'::jsonb,
  '{"pain_relief","soft_tissue"}',
  '{"subacute","chronic","muscle_hypertonicity"}',
  '{"movement_pain","hypomobile","morning_stiffness","disc_related","cervicogenic_headache"}',
  '{"fracture","malignancy","instability","neurological_deficit","osteoporosis","active_infection","anticoagulants","vbi","upper_cervical_instability"}',
  'level_2b'::evidence_level,
  '머리 무게를 이용한 자연 압박이 원칙 — 환자 머리 무게(약 5kg) 자체가 적절한 압박력을 제공하므로 치료사가 별도로 힘을 가할 필요 없음. 눈 뒤쪽 퍼짐 = 후두하근 확인 신호. C1 횡돌기 외측(유양돌기 아래-안쪽)에서 추골동맥이 주행 — 해당 부위 심부 압박 절대 금지. DFM 후 경추 굴곡 ROM 즉시 확인.',
  'fracture, malignancy, neurological_deficit, vbi, rheumatoid_cervical_C1C2, Chiari_malformation, inflammation_acute',
  'osteoporosis, anticoagulants, acute_migraine, occipital_neuralgia_acute',
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
-- [6] SBL 근막경선 이완 — 경추·후두하 세그먼트
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
  'category_anatomy_trains',
  (SELECT id FROM technique_categories WHERE category_key = 'category_anatomy_trains'),
  'Anatomy Trains — SBL 경추·후두하 세그먼트',
  'SBL 근막경선 이완 — 경추·후두하 세그먼트', 'Anatomy Trains — Superficial Back Line Release (Cervical / Suboccipital Segment)', 'AT-SBL-Cerv',
  'cervical', 'SBL 경추·후두하 구간 — 후두하근(suboccipital muscles), 두판상근(splenius capitis), 경추 신전근(cervical extensors), 경추-흉추 이행부(C7-T4)',
  '엎드린 자세 — 이마를 치료대 머리 받침(face hole)에 올리거나 타월 롤로 지지, 경추 중립',
  '환자 머리 쪽 또는 옆; 손가락 끝(국소 이완) 또는 전완 척골 면(광범위 경선 이완)으로 경추 후면 SBL 경선 접촉',
  '손가락 끝 또는 전완 — 경추 극돌기 외측 양쪽 SBL 경선 위 근육',
  'SBL 주행 방향(두-미측 또는 미-두측)으로 매우 느린 근막 신장(1cm/30초)',
  '[{"step":1,"instruction":"SBL 경선 평가 단계: 경추 굴곡 ROM 확인(턱을 가슴 쪽으로 당기기). 경추 후면에서 흉추 상부까지 손바닥으로 쓸어내리며 SBL 경선을 따라 조직 긴장·유착·온도 차이 구간 탐색. 후두하 구간(C0-C2), 경추 중부(C3-C5), 경추-흉추 이행부(C6-T2) 중 가장 긴장이 높은 SBL 구간 확인."},{"step":2,"instruction":"초기 접촉 및 압박 단계: SBL 경선 위 목표 구간에 손가락 끝 또는 전완부를 접촉. 조직이 저항을 느끼는 깊이까지 천천히 압박 증가(급격히 밀지 않음). 조직의 장벽(barrier)이 느껴지는 지점에서 정지."},{"step":3,"instruction":"지속 압박 및 SBL 경선 방향 신장 단계: 장벽에서 압박을 유지하며 SBL 주행 방향(미측 — 흉추 방향)으로 매우 느리게(1cm/30초 속도) 조직 신장. SBL 경선을 따라 조직이 이완되는 느낌(release)이 올 때까지 기다림. 성급하게 힘으로 밀지 않음."},{"step":4,"instruction":"SBL 경선 이완 추적 및 이동 단계: 이완 느낌이 오면 SBL을 따라 조금씩 더 미측으로 이동. 새로운 장벽에서 다시 정지 후 이완 대기. SBL 경추·후두하 세그먼트(C0-C2)에서 경추-흉추 이행부(C7-T4)까지 전체 구간 따라 이동."},{"step":5,"instruction":"재평가 단계: 시술 후 경추 굴곡 ROM 재측정. SBL 경선 이완 전후 굴곡 시 뒤통수-등 상부 당김 감소 여부 확인. 통증 NRS 재측정."}]'::jsonb,
  '{"pain_relief","rom_improvement","soft_tissue"}',
  '{"subacute","chronic","muscle_hypertonicity"}',
  '{"movement_pain","hypomobile","morning_stiffness","lbp_nonspecific","cervicogenic_headache"}',
  '{"fracture","malignancy","instability","neurological_deficit","active_infection","vbi","upper_cervical_instability"}',
  'level_2b'::evidence_level,
  'SBL 허리 통증의 실마리는 발바닥에 있을 수 있다 — 경추 세그먼트만 보지 않고 SBL이 발뒤꿈치부터 두개골까지 연결되어 있음을 인식. 장벽에서 기다리기가 핵심 — 힘으로 밀지 않고 조직이 스스로 이완될 때까지 장벽에서 기다림. 경추-흉추 이행부(C7-T1)가 SBL 주요 제한 구간 — 충분한 시간 투자가 경추 세그먼트 전체 이완 효율을 높임.',
  'fracture, malignancy, instability, neurological_deficit, vbi, rheumatoid_cervical',
  'osteoporosis, pregnancy (복와위 금지 → 측와위 변형), skin_lesion',
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
-- [7] SBAL/SBL 근막경선 이완 — 상지·경추 연결 세그먼트
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
  'category_anatomy_trains',
  (SELECT id FROM technique_categories WHERE category_key = 'category_anatomy_trains'),
  'Anatomy Trains — SBAL/SPL 경추-견갑 세그먼트',
  'SBAL/SBL 근막경선 이완 — 상지·경추 연결 세그먼트', 'Anatomy Trains — Superficial Back Arm Line / Spiral Line Release (Cervical-Shoulder Segment)', 'AT-SBAL-Cerv',
  'cervical', 'SBAL 경추-견갑 구간 — 상부 승모근(upper trapezius), 능형근(rhomboids), 흉추 신전근(thoracic extensors), 두판상근(splenius capitis)',
  '엎드린 자세(복와위) 또는 옆으로 누운 자세(측와위) — 복와위 시 face hole 또는 타월 롤로 이마 지지',
  '환자 머리 쪽 또는 치료할 쪽 옆; SBAL/SPL 경선 주행 방향(경추-견갑 대각선)을 따라 서기; 손가락 끝 또는 전완부로 접촉',
  '손가락 끝 또는 전완 — 경추 C2-C6 후외측 두판상근 / 견갑골 내측연(능형근 부착부)',
  'SBAL/SPL 각 경선 주행 방향으로 느린 지속 신장(1cm/30초 이하)',
  '[{"step":1,"instruction":"SBAL/SPL 경선 평가 단계: 경추 회전 ROM 확인. 회전 시 견갑부 통증 유발 여부 확인(SPL 긴장 패턴). 경추 후외측에서 견갑 내측연까지 손바닥으로 쓸어내리며 SBAL·SPL 경선 위의 조직 긴장 구간 탐색."},{"step":2,"instruction":"SPL 경추부 — 두판상근 이완 단계: SPL 경선 위 경추 C2-C5 후외측에서 두판상근에 접촉. 장벽이 느껴지는 깊이까지 천천히 압박. SPL 경선 방향인 대각선 하외측(반대쪽 견갑 방향)으로 매우 느리게 근막 신장. 이완 느낌이 올 때까지 기다림."},{"step":3,"instruction":"경추-견갑 이행부 연결 이완 단계: SPL/SBAL 경선을 따라 경추 후외측에서 견갑 상각·능형근 구간으로 손을 이동하며 연속적으로 이완. 한 손을 경추에, 다른 손을 능형근에 올려 두 경선 구간을 동시에 신장하는 투-핸드 기법 활용."},{"step":4,"instruction":"SBAL 능형근-상부 승모근 이완 단계: 견갑골 내측연(능형근 부착부)에 손가락 끝 또는 전완부 접촉. SBAL 경선 방향인 C7-T5 방향으로 근막 신장. 견갑골이 외전 방향으로 자연스럽게 이동하는 느낌 확인."},{"step":5,"instruction":"통합 신장 및 재평가 단계: 환자에게 천천히 고개를 치료받는 반대쪽으로 돌리도록 지시하여 능동 움직임 추가. 치료사가 두판상근 접촉을 유지한 상태에서 환자가 능동 회전하면 SPL 전체 경선의 통합 신장 효과. 시술 후 경추 회전 ROM 재측정, SBAL·SPL 경선 이완 전후 회전 시 견갑부 통증 감소 확인."}]'::jsonb,
  '{"pain_relief","rom_improvement","soft_tissue"}',
  '{"subacute","chronic","muscle_hypertonicity"}',
  '{"movement_pain","hypomobile","morning_stiffness","lbp_nonspecific","cervicogenic_headache"}',
  '{"fracture","malignancy","instability","neurological_deficit","active_infection","vbi","upper_cervical_instability"}',
  'level_4'::evidence_level,
  'SPL은 경추에서 반대측 견갑으로 교차 연결 — 경추 우회전 제한 시 왼쪽 두판상근 + 오른쪽 능형근 구간을 함께 평가·이완. 투-핸드 기법으로 SBAL 경선 연속성 확인 — 한 손을 경추 두판상근, 다른 손을 능형근에 올려 두 구간 사이에서 근막의 연속적 긴장을 느끼면 SBAL 경선 패턴이 명확히 확인됨. 능동 회전 통합 신장이 SPL 전체 경선 동시 신장에 효과적.',
  'fracture, malignancy, instability, neurological_deficit, vbi, rheumatoid_cervical',
  'osteoporosis, pregnancy (복와위 금지 → 측와위 변형), rotator_cuff_tear_acute, TOS',
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
-- [8] 후두하근 트리거포인트 치료
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
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'Trigger Point Therapy — 경추-두개 접합부',
  '후두하근 트리거포인트 치료', 'Trigger Point Therapy — Suboccipital Muscles', 'CervTP-SOC',
  'cervical'::body_region, '경추-두개 접합부 후면 — C0-C1-C2 구간 (대후두직근·소후두직근·상두사근·하두사근)',
  '등 대고 누운 자세 — 머리를 치료사 손 또는 작은 베개 위에 올려 경추 약 10~15° 굴곡',
  '환자 머리 쪽; 양손 검지·중지 끝을 후두골 하연 아래로 삽입하여 후두하근 트리거포인트 위치에 접촉',
  '양손 검지·중지 끝 — 후두골 하연에서 하방 1~2cm, 정중선 외측 1~2cm 구간',
  '수직(전방) 압박 유지 — 강하게 누르지 않고 조직 장벽에서 기다림 (환자 머리 무게 이용)',
  '[{"step":1,"instruction":"트리거포인트 탐색 단계: 후두골 하연 아래로 양손 검지·중지를 부드럽게 삽입. 대후두직근·소후두직근·상두사근·하두사근 위치를 확인하며 가볍게 촉진. 압통이 가장 강한 지점, 또는 두통·눈 뒤 통증을 재현하는 지점(활성 트리거포인트) 찾기. 좌우 각각 탐색 후 더 활성화된 쪽 먼저 시작."},{"step":2,"instruction":"연관통 확인 단계: 의심 트리거포인트에 가벼운 압박 적용 후 눈 뒤나 관자놀이 쪽으로 퍼지는 느낌이 있는지 확인. 환자의 평소 두통 패턴과 일치하는 연관통이 재현되면 활성 트리거포인트 확인 → 치료 타겟."},{"step":3,"instruction":"허혈성 압박 시행 단계: 트리거포인트 위에 손가락 끝을 고정. 환자 머리 무게를 이용한 자연 압박이 트리거포인트에 가해지도록 손 위치 조절. 추가 압박이 필요하면 손가락 끝으로 전방으로 경미하게 증가. 통증 NRS 6~7 이하 유지."},{"step":4,"instruction":"압박 유지 및 이완 대기 단계: 트리거포인트에서 압박 유지 60~90초. 트리거포인트가 비활성화되면 통증이 점진적으로 감소하고 조직이 부드러워지는 느낌이 옴. 30초마다 눈 뒤 퍼지는 느낌 변화 확인."},{"step":5,"instruction":"압박 해제 및 재평가 단계: 압박 서서히 해제 후 동일 근육의 다른 트리거포인트로 이동하거나 반대쪽 시행. 시술 후 트리거포인트 재촉진 시 연관통 소실 여부 확인. 경추 굴곡 ROM 재측정, 두통 NRS 재측정."}]'::jsonb,
  '{"pain_relief","soft_tissue"}',
  '{"acute","subacute","chronic","muscle_hypertonicity","sensitized"}',
  '{"movement_pain","hypomobile","rest_pain","referred_pain","cervicogenic_headache","lbp_nonspecific"}',
  '{"fracture","malignancy","neurological_deficit","active_infection","anticoagulants","vbi","upper_cervical_instability"}',
  'level_2b'::evidence_level,
  '연관통 재현이 활성 트리거포인트 확인의 핵심 신호 — 눌렀을 때 눈 뒤, 관자놀이, 이마로 퍼지는 친숙한 두통 패턴이 재현되면 활성 트리거포인트. 머리 무게(약 5kg)로 충분 — 치료사가 강한 힘을 가할 필요 없음. C1 횡돌기 외측(유양돌기 아래-안쪽) 심부 압박 금지 — 추골동맥 주행 구간. 60~90초 기다리기가 원칙 — 20~30초 만에 해제하면 효과 부족.',
  'fracture, malignancy, neurological_deficit, vbi, rheumatoid_cervical_C1C2, Chiari_malformation, acute_meningitis',
  'osteoporosis, anticoagulants, acute_migraine, occipital_neuralgia_acute',
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
-- [9] 상부 승모근 트리거포인트 치료
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
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'Trigger Point Therapy — 경추부',
  '상부 승모근 트리거포인트 치료', 'Trigger Point Therapy — Upper Trapezius', 'CervTP-UT',
  'cervical'::body_region, '상부 승모근 근복 — 후두골·C1-C5 극돌기 외측에서 쇄골 외측 1/3·견봉까지',
  '앉은 자세 또는 등 대고 누운 자세 — 치료할 쪽으로 10~15° 측굴하여 근육 약간 이완',
  '환자 뒤 또는 치료할 쪽 옆(좌위) 또는 머리 쪽(앙와위); 엄지와 검지·중지로 근복 핀칭(집기)',
  '핀칭 그립 — 엄지(근육 후면) + 검지·중지(근육 전면); taut band 내 최대 압통점(트리거포인트)',
  '트리거포인트에 집중된 직접 압박 — 근육 전체가 아닌 경결점만 타겟',
  '[{"step":1,"instruction":"taut band 및 트리거포인트 탐색 단계: 상부 승모근 근복을 핀칭 그립으로 가볍게 굴리듯 탐색. 다른 부위보다 단단하게 느껴지는 띠(taut band) 구간 확인. taut band 내에서 가장 압통이 강한 지점(spot tenderness) 찾기. jump sign 유무 확인."},{"step":2,"instruction":"연관통 확인 단계: 의심 트리거포인트에 가벼운 압박 후 관자놀이나 귀 뒤쪽으로 퍼지는 느낌이 있는지 확인. 환자의 평소 두통 패턴과 일치하는 연관통이 재현되면 활성 트리거포인트 확인 → 치료 타겟."},{"step":3,"instruction":"핀칭 압박 시작 단계: 활성 트리거포인트를 엄지와 검지·중지 사이에 고정. 점진적으로 핀칭 압박 증가. 환자가 NRS 6~7 수준(시원하게 아픈 느낌)이 될 때까지 증가. 8 이상이면 압박 경감."},{"step":4,"instruction":"압박 유지 및 이완 대기 단계: 트리거포인트에서 압박 유지 60~90초. 초기에는 연관통이 강하게 느껴지다가 점진적으로 감소. 30초마다 관자놀이 쪽 퍼지는 느낌 변화 확인. 통증이 NRS 2~3 이하로 감소하거나 조직이 부드러워지면 해제."},{"step":5,"instruction":"스트레칭 통합 및 재평가 단계: 트리거포인트 치료 후 상부 승모근 수동 신장 추가. 치료 쪽 어깨를 아래로 고정한 상태에서 경추를 반대쪽으로 측굴·회전, 20~30초 × 3회. 시술 후 경추 측굴·회전 ROM 재측정, 두통 NRS 재측정."}]'::jsonb,
  '{"pain_relief","soft_tissue"}',
  '{"acute","subacute","chronic","muscle_hypertonicity","sensitized"}',
  '{"movement_pain","hypomobile","rest_pain","referred_pain","cervicogenic_headache","lbp_nonspecific"}',
  '{"fracture","malignancy","neurological_deficit","active_infection","anticoagulants","vbi","upper_cervical_instability"}',
  'level_1b'::evidence_level,
  'taut band을 먼저 찾아야 트리거포인트에 도달 — 핀칭 그립으로 상부 승모근을 굴리듯 탐색하면 다른 부위보다 단단하게 느껴지는 줄기가 느껴짐. 이 taut band 내 spot tenderness가 치료 타겟. 스트레칭 통합이 효과 지속에 중요 — 트리거포인트 비활성화 후 바로 상부 승모근 스트레칭을 추가하면 재활성화를 방지. 연관통 재현 없는 단순 압통은 잠재 트리거포인트 — 치료 효과 낮음.',
  'fracture, malignancy, instability, neurological_deficit, vbi, clavicle_fracture_acute',
  'osteoporosis, inflammation_acute, anticoagulants, TOS',
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
-- [10] 요방형근 트리거포인트 치료
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
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'Trigger Point Therapy — 요추부',
  '요방형근 트리거포인트 치료', 'Trigger Point Therapy — Quadratus Lumborum', 'LumbTP-QL',
  'lumbar'::body_region, '요추 측면 — 12번 갈비뼈 하연에서 장골능 상연까지, 척추 외측 2~3cm',
  '측와위(치료할 쪽이 위로) — 허리 아래 롤 타월로 요방형근 접근 공간 확보; 또는 복와위',
  '환자 뒤쪽(측와위) 또는 환자 옆(복와위); 엄지 첨부 또는 팔꿈치 올레크라논으로 12번 갈비뼈-장골능 사이 심층 접근',
  '엄지 끝 또는 팔꿈치 올레크라논 — 척추 외측 2~3cm, 12번 갈비뼈 하연~장골능 상연 사이 심층',
  '수직(전방 또는 내측) 방향 압박 — 갑작스러운 강한 힘 금지',
  '[{"step":1,"instruction":"랜드마크 확인 및 자세 세팅 단계: 12번 갈비뼈와 장골능 위치 촉진으로 확인. 환자를 측와위(치료 측 위)로 세팅. 허리 아래 롤 타월로 요방형근 접근 공간 확보."},{"step":2,"instruction":"트리거포인트 탐색 단계: 12번 갈비뼈-장골능 사이 구간을 위에서 아래로 탐색. 척추 외측 2~3cm에서 표층 근육을 부드럽게 밀어내며 심층 접근. 압통 강도가 가장 강한 지점 확인."},{"step":3,"instruction":"연관통 확인 단계: 의심 트리거포인트에 가벼운 압박 후 엉덩이나 사타구니 쪽으로 퍼지는 느낌이 있는지 확인. 환자의 평소 통증 패턴과 일치하는 연관통 재현 = 활성 트리거포인트 확인 → 치료 타겟."},{"step":4,"instruction":"직접 압박 시행 단계: 엄지 또는 팔꿈치로 활성 트리거포인트에 직접 압박 적용. 강도 NRS 6~7 수준으로 점진적 증가. 압박 방향은 수직(전방 또는 약간 내측)."},{"step":5,"instruction":"압박 유지 및 재평가 단계: 60~90초 압박 유지. 30초마다 엉덩이 쪽으로 퍼지는 느낌 변화 확인. 통증이 NRS 2~3 이하로 감소하거나 조직이 부드러워지면 해제. 압박 해제 후 트리거포인트 재촉진 연관통 소실 확인. 요추 측굴·신전 ROM 재측정."}]'::jsonb,
  '{"pain_relief","soft_tissue"}',
  '{"acute","subacute","chronic","muscle_hypertonicity","sensitized"}',
  '{"movement_pain","hypomobile","rest_pain","referred_pain","cervicogenic_headache","lbp_nonspecific"}',
  '{"fracture","malignancy","neurological_deficit","active_infection","anticoagulants"}',
  'level_2b'::evidence_level,
  '기침·재채기 시 통증 악화는 요방형근의 특징적 패턴 — 이 패턴이 있으면 QL 트리거포인트를 우선 확인. 측와위가 접근성 최적 — 복와위보다 12번 갈비뼈-장골능 사이 공간이 더 넓게 열려 심층 접근이 쉬움. 신장(kidney) 위치(12번 갈비뼈 상방 내측) 직접 심부 압박 금지. 팔꿈치 사용 시 강도 조절 주의 — 엄지로 먼저 위치 확인 후 팔꿈치로 전환.',
  'fracture, malignancy, neurological_deficit, kidney_disease, aortic_aneurysm, osteoporotic_compression_fracture',
  'osteoporosis, pregnancy, anticoagulants, acute_disc_herniation_with_neuro',
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
-- [11] 이상근 트리거포인트 치료
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
  'category_trigger_point',
  (SELECT id FROM technique_categories WHERE category_key = 'category_trigger_point'),
  'Trigger Point Therapy — 둔부·요추부',
  '이상근 트리거포인트 치료', 'Trigger Point Therapy — Piriformis', 'LumbTP-PIR',
  'lumbar'::body_region, '둔부 심층 — 천골(sacrum)과 대전자(greater trochanter) 사이 이상근 주행 구간',
  '복와위 — 치료 측 고관절 약간 내회전(발끝을 안쪽으로); 또는 측와위(치료할 쪽이 위, 위쪽 다리 고관절·무릎 90° 굴곡)',
  '환자 치료 측 옆(복와위) 또는 환자 뒤쪽(측와위); 팔꿈치 올레크라논 첨부로 이상근 트리거포인트 위치에 직접 압박',
  '팔꿈치 올레크라논 또는 엄지 끝 — PSIS-미골 중간점에서 대전자 방향 1/3 지점(근복 중앙)',
  '수직(하방 또는 약간 전내측) — 이상근 주행과 수직 방향',
  '[{"step":1,"instruction":"랜드마크 확인 및 자세 세팅 단계: 후상장골극(PSIS), 미골, 대전자 위치 촉진으로 확인. 이상근 주행선(PSIS-미골 중간점 → 대전자) 추정. 환자를 복와위 또는 측와위로 세팅, 치료 측 고관절 약간 내회전."},{"step":2,"instruction":"심층 접근 및 트리거포인트 탐색 단계: 이상근 주행선의 대전자 쪽 1/3 지점(트리거포인트1 위치)에 팔꿈치 올레크라논 위치. 체중 이동으로 점진적으로 심층 압박. 표면 대둔근 통과 후 더 단단한 조직(이상근)에 도달 확인."},{"step":3,"instruction":"연관통 확인 단계: 가벼운 압박 후 허벅지 뒤나 종아리 쪽으로 퍼지는 느낌이 있는지 확인. 환자의 평소 증상 패턴과 일치하는 연관통 재현 = 활성 트리거포인트 확인 → 치료 타겟. 강한 찌릿한 신경 증상이면 위치 미세 조정."},{"step":4,"instruction":"직접 압박 시행 단계: 활성 트리거포인트에서 팔꿈치 또는 엄지로 NRS 6~7 수준 압박 유지. 압박 방향은 수직(하방). 환자 반응 지속 모니터링."},{"step":5,"instruction":"압박 유지, 스트레칭 통합 및 재평가 단계: 60~90초 압박 유지. 30초마다 허벅지 쪽 퍼지는 느낌 변화 확인. 통증이 NRS 2~3 이하로 감소하면 해제. 압박 해제 후 이상근 스트레칭 추가(앙와위에서 치료 측 무릎을 구부려 반대쪽 어깨 방향으로 당기기, 20~30초 × 3회). 엉덩이 통증 NRS 재측정, 고관절 내회전 ROM 재측정."}]'::jsonb,
  '{"pain_relief","soft_tissue"}',
  '{"subacute","chronic","muscle_hypertonicity","sensitized"}',
  '{"movement_pain","hypomobile","rest_pain","referred_pain","cervicogenic_headache","lbp_nonspecific"}',
  '{"fracture","malignancy","neurological_deficit","active_infection","anticoagulants"}',
  'level_2b'::evidence_level,
  '묵직한 연관통 vs 찌릿한 신경 증상 구별이 핵심 — 이상근 트리거포인트 압박 시 허벅지 후면으로 묵직하게 퍼지는 연관통이 정상. 찌릿하고 전기 오는 강한 신경 증상이 나타나면 좌골신경 직접 자극 가능 → 위치를 내측 또는 외측으로 약간 이동. 좌골신경통 감별이 먼저 — 신경학적 결손(근력 저하, 반사 소실, 감각 이상)이 있으면 요추 신경근 병변 감별 필요. 스트레칭 통합 필수 — 치료 후 고관절 굴곡+내회전 스트레칭이 이상근 재활성화 방지에 효과적.',
  'fracture, malignancy, neurological_deficit, pelvic_fracture, hip_arthroplasty, sacroiliac_infection',
  'osteoporosis, pregnancy, anticoagulants, trochanteric_bursitis',
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
