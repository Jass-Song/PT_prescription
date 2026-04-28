-- ============================================================
-- Migration 032 — 견관절 운동 처방 (7기법)
-- shoulder body_region: 근력 저항(3) + 자체중량(2) + 신경근 훈련(2)
-- category_ex_resistance (3): SH-EX-RES-RC-Diag, SH-EX-RES-ScapRetract, SH-EX-RES-ER
-- category_ex_bodyweight (2): SH-EX-BW-Pendulum, SH-EX-BW-WallSlide
-- category_ex_neuromuscular (2): SH-EX-NM-PNF-D2, SH-EX-NM-Proprio
-- K-Movement Optimism / PT 처방 도우미
-- 생성일: 2026-04-29
-- 작성자: sw-db-architect
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

BEGIN;

-- ────────────────────── [1] 회전근개 사선 강화 ──────────────────────
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
  '운동 처방 — 어깨 근력 강화',
  '회전근개 사선 강화', 'Diagonal Rotator Cuff Strengthening', 'SH-EX-RES-RC-Diag',
  'shoulder'::body_region, '회전근개 (극상근·극하근·견갑하근)',
  '선 자세 또는 앉은 자세, 운동 측 팔을 몸통 옆에 이완',
  '환자 옆에서 동작 가이드 및 저항 강도 확인',
  '탄성 밴드 또는 덤벨 — 손목 원위부',
  'PNF D2 굴곡 패턴 대각선 방향 (허리 아래에서 머리 위 반대편으로)',
  '[
    {"step":1,"instruction":"선 자세 또는 앉은 자세에서 환측 팔을 몸통 앞에 내려 탄성 밴드 또는 가벼운 덤벨을 준비한다. 탄성 밴드는 반대측 발로 고정하거나 낮은 고리에 연결한다. 시작 자세는 팔꿈치를 가볍게 펴고 손목을 굴곡·회내한 상태(손바닥이 뒤를 향함)에서 허리 반대 방향 아래에 위치시킨다."},
    {"step":2,"instruction":"팔을 어깨 굴곡·외전·외회전 방향(D2 굴곡 패턴)으로 들어올리기 시작한다. 동작 중 손목을 서서히 신전·회외(손바닥이 위를 향하도록)하면서 팔이 머리 위 반대편을 향해 대각선으로 이동한다. 끝 범위에서 어깨가 완전 외전·외회전된 상태를 확인한다."},
    {"step":3,"instruction":"끝 범위에서 1–2초 유지 후 시작 위치로 천천히 되돌아간다. 복귀 시 D2 신전 패턴(어깨 신전·내전·내회전, 손목 굴곡·회내)으로 조절하며 내린다. 한 세트에 10–15회 반복하며, 2–3세트 시행한다."},
    {"step":4,"instruction":"저항 강도는 10–15회 반복 시 마지막 2–3회에서 약간의 피로감이 느껴지는 수준으로 설정한다. 보상 동작(어깨 으쓱, 몸통 회전 과다)이 나타나면 저항을 낮추거나 가동 범위를 줄인다."},
    {"step":5,"instruction":"세션 후 어깨 굴곡 및 외전 ROM 변화, 통증 강도(VAS) 변화를 재평가한다. 통증 없이 정확한 패턴 수행이 확인되면 2주마다 저항을 점진적으로 증가시키도록 교육한다."}
  ]'::jsonb,
  '{"strengthening","rom_improvement","stabilization"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","rotator_cuff_weakness","overhead_difficulty","scapular_dyskinesis"}',
  '{"fracture","acute_rotator_cuff_tear","joint_infection","malignancy"}',
  'level_2b'::evidence_level,
  'PNF D2 굴곡 패턴은 회전근개 복합체를 기능적 대각선 방향으로 활성화할 수 있어 스포츠 및 일상 동작과의 연계 가능성이 있다. 탄성 밴드 저항이 가동 범위 전체에 걸쳐 점진적으로 증가하므로 근력 강화 효과를 기대할 수 있다. 보상 동작 없이 정확한 패턴 수행이 선행되어야 저항 증가를 고려할 수 있다.',
  'fracture, acute_rotator_cuff_tear_full_thickness, joint_infection, malignancy',
  'acute_inflammation, severe_impingement, shoulder_instability',
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

-- ────────────────────── [2] 견갑 후인·하강 강화 ──────────────────────
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
  '운동 처방 — 견갑 안정화',
  '견갑 후인·하강 강화', 'Scapular Retraction and Depression Strengthening', 'SH-EX-RES-ScapRetract',
  'shoulder'::body_region, '능형근, 하부 승모근',
  '앉은 자세 또는 선 자세, 양 팔을 앞으로 뻗은 시작 자세',
  '환자 옆에서 견갑골 움직임 관찰 및 동작 가이드',
  '탄성 밴드 또는 케이블 머신 — 양 손목 원위부',
  '견갑골 후인(뒤로 모으기) + 하강(아래로 내리기) 복합 방향',
  '[
    {"step":1,"instruction":"앉은 자세 또는 선 자세에서 탄성 밴드 또는 케이블 머신을 양손에 잡고 시작 자세를 준비한다. 팔꿈치를 약 90도 굽혀 양 팔을 앞으로 뻗은 자세에서 출발한다. 어깨가 귀 방향으로 올라가지 않도록 처음부터 이완된 중립 자세를 확인한다."},
    {"step":2,"instruction":"팔꿈치를 구부리며 양팔을 몸통 방향으로 당기는 로우(Row) 동작을 시작한다. 이때 견갑골을 뒤로 모으는(후인) 동작을 의식적으로 동반한다. 팔꿈치가 몸통 뒤쪽까지 충분히 당겨진 끝 범위에서 견갑골이 확실히 모인 상태를 확인한다."},
    {"step":3,"instruction":"끝 범위에서 추가로 어깨를 아래로 내리는(하강) 동작을 1–2초 유지하며 강조한다. 이 단계에서 하부 승모근 활성화를 목표로 한다. 귀에서 어깨가 멀어지는 느낌을 환자에게 안내한다."},
    {"step":4,"instruction":"천천히 시작 자세로 복귀하며 견갑골을 전인(앞으로 내밀기) 방향으로 되돌린다. 복귀 시 어깨가 다시 귀 방향으로 올라가지 않도록 조절한다. 10–15회 반복, 2–3세트 시행한다."},
    {"step":5,"instruction":"세션 후 견갑골 운동 조절 능력과 어깨 전방 통증 변화를 재평가한다. 보상 동작(상부 승모근 과활성, 경추 신전)이 반복될 경우 저항을 낮추고 정확한 패턴 습득에 집중하도록 교육한다."}
  ]'::jsonb,
  '{"strengthening","stabilization","scapular_control"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","scapular_dyskinesis","anterior_shoulder_pain","overhead_difficulty"}',
  '{"fracture","joint_infection","malignancy","acute_rotator_cuff_tear"}',
  'level_2b'::evidence_level,
  '하부 승모근과 능형근의 선택적 강화는 견갑골 운동이상(scapular dyskinesis)이 동반된 어깨 통증에서 증상 개선 가능성이 있다. 상부 승모근의 보상적 과활성이 없는 상태에서 시행될 때 효과를 기대할 수 있다. 저항 증가보다 정확한 하강·후인 패턴 획득이 선행되어야 한다.',
  'fracture, joint_infection, malignancy, acute_rotator_cuff_tear_full_thickness',
  'acute_inflammation, severe_shoulder_instability, acromioclavicular_joint_injury_acute',
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

-- ────────────────────── [3] 어깨 외회전 강화 ──────────────────────
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
  '운동 처방 — 어깨 근력 강화',
  '어깨 외회전 강화', 'Shoulder External Rotation Strengthening', 'SH-EX-RES-ER',
  'shoulder'::body_region, '극하근, 소원근',
  '선 자세 또는 앉은 자세, 환측 팔꿈치를 몸통 옆에 붙임',
  '환자 옆에서 동작 가이드 및 팔꿈치 고정 여부 확인',
  '탄성 밴드 — 손목 원위부, 팔꿈치 고정용 수건(옵션)',
  '어깨 외회전 방향 (팔꿈치 고정, 전완을 외측으로)',
  '[
    {"step":1,"instruction":"선 자세 또는 앉은 자세에서 환측 팔꿈치를 90도 굽혀 몸통 옆구리에 붙인다. 탄성 밴드를 반대측 방향의 고리 또는 문에 고정하여 시작 자세에서 적절한 초기 긴장이 유지되도록 위치를 조정한다. 팔꿈치와 몸통 사이에 수건을 끼워 팔꿈치 고정을 돕고 어깨 신전 보상을 방지할 수 있다."},
    {"step":2,"instruction":"팔꿈치를 몸통에 고정한 채 전완을 외측(바깥쪽)으로 돌리는 외회전 동작을 천천히 시작한다. 가동 범위 끝(일반적으로 약 45–60° 외회전)까지 이동하며 동작 내내 팔꿈치가 옆구리에서 떨어지지 않도록 유의한다."},
    {"step":3,"instruction":"끝 범위에서 1–2초 유지 후 천천히 시작 위치로 복귀한다. 복귀 시 탄성 밴드의 저항에 저항하며 조절하여 내린다. 빠른 복귀 시 반동을 이용하지 않도록 안내한다."},
    {"step":4,"instruction":"10–15회 반복, 2–3세트 시행한다. 저항 강도는 정확한 패턴 유지 하에 마지막 2–3회에서 가벼운 피로감이 느껴지는 수준으로 설정한다. 몸통 회전이나 어깨 으쓱 보상이 나타나면 저항을 낮춘다."},
    {"step":5,"instruction":"세션 후 어깨 외회전 ROM 변화 및 측면 어깨 통증 변화를 재평가한다. 통증 없이 정확한 동작이 가능해지면 점진적으로 저항을 높이거나 팔꿈치를 약간 외전(15–20°)한 자세로 진행하여 극하근 활성화를 높일 수 있도록 교육한다."}
  ]'::jsonb,
  '{"strengthening","stabilization","rotator_cuff"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","rotator_cuff_weakness","external_rotation_weakness","impingement_syndrome"}',
  '{"fracture","joint_infection","malignancy","acute_rotator_cuff_tear"}',
  'level_2b'::evidence_level,
  '외회전근(극하근·소원근) 강화는 회전근개 기능 개선 및 충돌증후군(impingement) 증상 완화 가능성이 있다. 팔꿈치를 몸통에 고정한 자세는 삼각근 보상 없이 외회전근을 선택적으로 활성화하는 데 유리할 수 있다. 탄성 밴드 외회전 운동이 회전근개 병증에서 단기 통증 감소 효과를 보일 가능성이 있다.',
  'fracture, joint_infection, malignancy, acute_rotator_cuff_tear_full_thickness',
  'acute_inflammation, severe_posterior_capsule_tightness, multidirectional_instability',
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

-- ────────────────────── [4] 진자 운동 (Codman) ──────────────────────
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
  '운동 처방 — 어깨 자가 가동',
  '진자 운동 (Codman)', 'Pendulum Exercise (Codman)', 'SH-EX-BW-Pendulum',
  'shoulder'::body_region, 'GHJ 관절낭, 삼각근 하부',
  '앞으로 기울인 자세, 비환측 손으로 테이블 또는 의자에 기댐',
  '환자 옆에서 자세와 이완 상태 확인',
  '없음 — 중력에 의한 자연스러운 팔 이동',
  '전후·좌우·원형 진자 방향 (능동 보조 없이 몸통의 가벼운 흔들기로 유도)',
  '[
    {"step":1,"instruction":"비환측 손으로 테이블 또는 의자 위에 기대어 상체를 약 45–60° 앞으로 기울인다. 환측 팔을 완전히 이완시켜 중력에 의해 자연스럽게 늘어뜨린다. 어깨와 팔 전체의 힘을 빼는 것이 핵심이며, 팔을 능동적으로 흔들지 않도록 안내한다."},
    {"step":2,"instruction":"상체를 가볍게 전후 방향으로 흔들어 팔이 진자처럼 앞뒤로 움직이도록 유도한다. 몸통의 움직임이 팔의 진자 운동을 만드는 방식이므로 어깨 근육을 사용하지 않도록 주의시킨다. 전후 방향으로 30초–1분 시행한다."},
    {"step":3,"instruction":"동일한 방법으로 상체를 좌우 방향으로 흔들어 팔이 내외측으로 진자 운동하도록 유도한다. 30초–1분 시행 후, 상체의 원형 움직임으로 팔이 시계 방향으로 작은 원을 그리도록 유도한다. 원의 크기는 통증이 없는 범위에서 서서히 키운다."},
    {"step":4,"instruction":"모든 방향 진자 운동이 완료되면 환자가 천천히 직립 자세로 돌아오도록 안내한다. 급격한 직립은 어깨 통증을 유발할 수 있으므로 천천히 시행한다. 전체 세션은 5–10분으로 하루 2–3회 시행 가능하다."},
    {"step":5,"instruction":"세션 후 어깨 통증 강도(VAS) 및 팔 이완감 변화를 재평가한다. 진자 운동 중 통증이 현저히 증가하면 진자 범위를 줄이거나 상체 기울기를 더 깊게 조정하도록 안내한다. 증상이 개선되면 손에 가벼운 무게(0.5–1 kg)를 추가하여 관절 간격 증가를 유도할 수 있다."}
  ]'::jsonb,
  '{"pain_relief","rom_improvement","joint_distraction"}',
  '{"acute","subacute","chronic"}',
  '{"shoulder_pain","adhesive_capsulitis","post_surgical_shoulder","rotator_cuff_pain"}',
  '{"fracture","joint_infection","malignancy","acute_rotator_cuff_repair_post_op_early"}',
  'level_4'::evidence_level,
  '중력을 이용한 관절 자가 신장으로 관절낭 이완과 통증 감소 가능성이 있다. 급성기 및 수술 후 초기 어깨 재활에서 능동 운동이 어려울 때 통증 없이 관절을 움직일 수 있는 첫 단계 운동으로 활용될 수 있다. 능동 근수축 없이 시행하는 것이 핵심이며, 어깨 근육이 이완된 상태에서의 관절 가동이 가장 효과를 기대할 수 있다.',
  'fracture, joint_infection, malignancy',
  'acute_inflammation_severe, early_post_op_instability_repair, severe_osteoporosis',
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

-- ────────────────────── [5] 벽 슬라이드 ──────────────────────
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
  '운동 처방 — 견갑 운동 훈련',
  '벽 슬라이드', 'Wall Slide', 'SH-EX-BW-WallSlide',
  'shoulder'::body_region, '전거근, 하부 승모근, 견갑흉곽관절',
  '선 자세, 벽 또는 평평한 면을 등지거나 마주 보고 서기',
  '환자 옆에서 견갑골 움직임과 보상 동작 관찰',
  '전완 또는 손바닥 — 벽면 접촉',
  'W 자세에서 Y 자세로 위쪽 슬라이드 (어깨 굴곡·외전·외회전 복합)',
  '[
    {"step":1,"instruction":"벽을 마주 보고 서서 양 팔꿈치를 약 90도 굽혀 팔뚝을 벽에 댄다. 팔꿈치는 어깨 높이 또는 약간 낮게, 전완은 수직 방향으로 벽에 붙인다. 이 자세가 W 시작 포지션이다. 등과 허리를 벽에서 과도하게 젖히지 않고 중립 자세를 유지한다."},
    {"step":2,"instruction":"전완을 벽에서 미끄러지듯 위로 밀어올리는 동작을 시작한다. 이때 견갑골이 상방 회전·후인·하강되며 팔이 Y 자 형태가 되도록 유도한다. 어깨가 귀 쪽으로 올라가는 상부 승모근 보상이 생기지 않도록 의식적으로 어깨를 내리며 동작을 실시한다."},
    {"step":3,"instruction":"가동 범위 끝(팔이 최대한 올라간 Y 자세)에서 1–2초 유지한다. 이 끝 범위에서 전거근(앞톱니근)이 견갑골을 흉곽에 밀착시키는 느낌을 확인한다. 날개 견갑(견갑골이 들뜨는 현상)이 발생하면 가동 범위를 줄인다."},
    {"step":4,"instruction":"천천히 시작 W 자세로 복귀한다. 1세트에 10–15회 반복, 2–3세트 시행한다. 동작 내내 전완이 벽에 가볍게 밀착된 상태를 유지하며, 벽에서 전완이 떨어지면 올바른 슬라이딩이 이루어지지 않은 것임을 안내한다."},
    {"step":5,"instruction":"세션 후 견갑골 상방 회전 범위 및 어깨 측면 통증 변화를 재평가한다. 정확한 패턴 수행이 가능해지면 폼 롤러를 등에 세로로 대고 실시하거나, 슬라이딩 패드를 사용하여 난이도와 자각 피드백을 높일 수 있도록 교육한다."}
  ]'::jsonb,
  '{"strengthening","stabilization","scapular_control","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","scapular_dyskinesis","overhead_difficulty","impingement_syndrome"}',
  '{"fracture","joint_infection","malignancy","acute_rotator_cuff_tear"}',
  'level_2b'::evidence_level,
  '벽 슬라이드는 전거근과 하부 승모근을 동시에 활성화하여 견갑골 운동 패턴 개선 가능성이 있다. 열린 사슬 환경에서 최소 장비로 어깨 충돌증후군 관련 견갑골 운동이상을 교정하는 데 활용될 수 있다. 상부 승모근 보상 없이 정확한 상방 회전 패턴이 획득된 후 팔을 머리 위로 드는 동작에서도 같은 패턴을 유지할 수 있도록 교육하는 것이 목표가 될 수 있다.',
  'fracture, joint_infection, malignancy, acute_rotator_cuff_tear_full_thickness',
  'acute_inflammation, severe_shoulder_instability, acromioclavicular_joint_injury_acute',
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

-- ────────────────────── [6] 어깨 PNF D2 패턴 ──────────────────────
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
  '운동 처방 — 신경근 조절',
  '어깨 PNF D2 패턴', 'Shoulder PNF D2 Pattern', 'SH-EX-NM-PNF-D2',
  'shoulder'::body_region, '회전근개 복합체, 삼각근, 견갑 안정화근',
  '바로 눕기 또는 앉은 자세, 환측 팔을 치료사가 유도 가능한 위치',
  '환측에 서서 환자 손목과 팔꿈치에 손 접촉, 대각선 방향 유도 제공',
  '환자 손목 원위부(한 손) + 팔꿈치 근위부(다른 손)',
  'D2 굴곡 패턴: 허리 반대편 아래에서 머리 위 반대편으로 대각선 / D2 신전 패턴: 반대 방향',
  '[
    {"step":1,"instruction":"바로 눕기 자세에서 환측 팔의 D2 시작 포지션을 설정한다. 치료사는 환자의 손목 원위부와 팔꿈치 근위부에 손을 대고 팔을 어깨 신전·내전·내회전 방향(손바닥이 뒤를 향하고 팔이 허리 반대편 아래에 위치한 D2 신전 끝 자세)으로 유도한다. 이 자세가 D2 굴곡 패턴의 시작 위치이다."},
    {"step":2,"instruction":"치료사의 언어적 지시와 손 유도에 따라 환자가 어깨 굴곡·외전·외회전 방향(손바닥이 앞을 향하며 팔이 머리 위 반대편으로 이동하는 D2 굴곡 끝 자세)으로 팔을 능동적으로 움직이도록 안내한다. 치료사는 적절한 저항(촉진 저항)을 제공하여 신경근 활성화를 강화한다."},
    {"step":3,"instruction":"D2 굴곡 끝 범위에서 잠시 유지 후, 이번에는 D2 신전 패턴(어깨 신전·내전·내회전, 손바닥이 뒤를 향하며 아래로 이동)으로 되돌아온다. 동작 내내 치료사는 일정한 저항을 유지하며 부드럽고 유연한 대각선 궤적으로 팔을 유도한다."},
    {"step":4,"instruction":"D2 굴곡·신전 패턴을 5–10회 반복한다. 충분한 패턴 학습 후 치료사 유도 없이 환자 스스로 수행하는 단계로 전환한다. 탄성 밴드를 이용한 저항 D2 운동으로 가정 운동으로 연결할 수 있다."},
    {"step":5,"instruction":"세션 후 어깨 굴곡·외전 ROM 및 상지 협응 능력 변화를 재평가한다. 정확한 대각선 궤적 수행이 어렵거나 보상 동작이 심할 경우, 가동 범위를 줄이거나 치료사 유도 비율을 높여 패턴 습득에 집중하도록 교육한다."}
  ]'::jsonb,
  '{"neuromuscular_control","strengthening","rom_improvement","coordination"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","rotator_cuff_weakness","overhead_difficulty","post_surgical_shoulder","scapular_dyskinesis"}',
  '{"fracture","joint_infection","malignancy","acute_rotator_cuff_repair_post_op_early"}',
  'level_2b'::evidence_level,
  'PNF D2 패턴은 어깨 복합체의 기능적 대각선 방향 움직임을 신경근 수준에서 재훈련할 가능성이 있다. 치료사의 촉진 저항과 언어적 지시를 통해 약화된 근육군의 선택적 활성화를 유도하는 데 활용될 수 있다. 스포츠나 작업 동작에서 요구되는 머리 위 움직임 패턴 재획득에 도움이 될 가능성이 있다.',
  'fracture, joint_infection, malignancy, acute_rotator_cuff_repair_post_op_early',
  'acute_inflammation, severe_shoulder_instability, multidirectional_instability',
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

-- ────────────────────── [7] 어깨 고유감각 재훈련 ──────────────────────
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
  '운동 처방 — 신경근 조절',
  '어깨 고유감각 재훈련', 'Shoulder Proprioception Retraining', 'SH-EX-NM-Proprio',
  'shoulder'::body_region, 'GHJ 관절낭, 회전근개 신경말단',
  '선 자세 또는 네발기기 자세, 안정면에서 불안정면 순서로 진행',
  '환자 옆에서 낙상 방지 및 동작 정확도 관찰',
  '폼 롤러 또는 보수볼 — 환측 손바닥 (체중 부하 버전) / 없음 (눈 감고 위치 재현 버전)',
  '어깨 안정화 유지 방향 (환측 상지 체중 부하 또는 능동 위치 재현)',
  '[
    {"step":1,"instruction":"위치 재현 훈련 — 기준 설정: 앉은 자세 또는 선 자세에서 치료사가 환측 팔을 임의의 각도(예: 굴곡 60°, 외전 45°)로 수동 유도한 후 환자가 위치를 기억하도록 안내한다. 이후 팔을 중립으로 되돌리고 환자에게 눈을 감고 동일한 각도로 능동 재현하도록 요청한다. 재현 오차(각도 차이)를 확인하여 기준값으로 기록한다."},
    {"step":2,"instruction":"체중 부하 고유감각 훈련 — 안정면: 네발기기 자세에서 환측 손을 폼 롤러 위에 올려 체중을 부분적으로 부하한다. 비환측 팔을 들어 올려 환측 팔에 더 많은 체중이 실리도록 조절한다. 어깨가 흔들리지 않도록 안정화를 유지하면서 30–60초간 버티는 훈련을 2–3세트 시행한다."},
    {"step":3,"instruction":"체중 부하 고유감각 훈련 — 불안정면: 안정면 훈련이 가능해지면 폼 롤러를 보수볼로 교체하거나, 선 자세에서 환측 팔을 벽에 대고 체중을 부하한 상태에서 눈을 감아 시각 피드백을 제거한다. 어깨 안정화 유지 시간을 점진적으로 늘린다."},
    {"step":4,"instruction":"위치 재현 난이도 증가: 눈을 감고 시행하는 위치 재현 훈련을 여러 각도(굴곡, 외전, 내외회전 조합)로 확장한다. 치료사가 목표 각도를 무작위로 제시하여 환자가 매번 정확히 재현하도록 유도한다. 10–15회 반복한다."},
    {"step":5,"instruction":"세션 후 위치 재현 오차 변화를 재평가하여 고유감각 개선 정도를 확인한다. 안정화 유지 시간 및 오차 감소가 확인되면 공을 던지고 받는 동적 활동으로 훈련을 진행하는 방향을 교육한다. 일상 동작에서 어깨 위치 인식을 높이는 가정 훈련을 처방한다."}
  ]'::jsonb,
  '{"proprioception","neuromuscular_control","stabilization","joint_position_sense"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","shoulder_instability","post_surgical_shoulder","rotator_cuff_repair_rehabilitation"}',
  '{"fracture","joint_infection","malignancy","acute_rotator_cuff_repair_post_op_early"}',
  'level_3'::evidence_level,
  '어깨 불안정성이나 반복 탈구 과거력이 있는 경우 고유감각 저하가 재발 위험과 연관될 가능성이 있다. 체중 부하 안정화 훈련과 눈 감기 위치 재현 훈련의 병합이 관절 위치 감각 재훈련에 활용될 수 있다. 수술 후 재활 후기 단계에서 스포츠 복귀 전 고유감각 훈련이 기능적 안정성 향상에 도움이 될 가능성이 있다.',
  'fracture, joint_infection, malignancy, acute_shoulder_dislocation_unreduced',
  'acute_inflammation, severe_rotator_cuff_tear_unrepaired, severe_multidirectional_instability',
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
