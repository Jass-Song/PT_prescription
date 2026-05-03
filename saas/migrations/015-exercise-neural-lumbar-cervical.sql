-- ============================================================
-- Migration 015: Exercise / Neural / MDT / PNE / ART / AnatomyTrains / DeepFriction
-- 요추 + 경추 운동치료·신경가동·교육·연부조직 기법 14개 INSERT
--
-- 포함 기법 (14개):
--   [그룹 1 — research/techniques/ 10개]
--   [1]  맥켄지 기계적 진단 및 치료 (요추)       category_mdt       / lumbar
--   [2]  신경운동 조절 운동 (심부 코어 재활성화)   category_ex_neuromuscular / lumbar
--   [3]  코어 안정화 훈련 (맥길 빅 쓰리)         category_ex_bodyweight    / lumbar
--   [4]  점진적 활동 (행동주의적 재활)            category_ex_bodyweight    / lumbar
--   [5]  신경 가동술 (좌골신경 적용)             category_d_neural         / lumbar
--   [6]  심부 경추 굴곡근 훈련                  category_ex_neuromuscular / cervical
--   [7]  경추 맥켄지 (후퇴+신전 시퀀스)          category_mdt              / cervical
--   [8]  경추 고유감각 재훈련                   category_ex_neuromuscular / cervical
--   [9]  경추 주변근 강화 훈련                  category_ex_resistance    / cervical
--   [10] 통증 신경과학 교육 병합 접근            category_pne              / cervical
--
--   [그룹 2 — research/techniques_research/ 4개 (draft, 8필드 검증 통과)]
--   [11] 장요근 능동 이완 기법                  category_art              / lumbar
--   [12] 허리네모근 능동 이완 기법               category_art              / lumbar
--   [13] SBL+DFL 근막경선 임상 적용 (요추 세그먼트) category_anatomy_trains   / NULL (범용 — 경선은 부위 불문)
--   [14] 요추 인대 심부 마찰 마사지              category_deep_friction    / lumbar
--
-- SKIP된 기법: 없음 (14개 전체 8-필드 검증 통과)
--
-- 전제 조건:
--   - 003a-exercise-enum.sql      (category_c_exercise, category_d_neural)
--   - 008a-new-categories-enum.sql (category_art, category_mdt, category_pne,
--                                   category_anatomy_trains, category_deep_friction 등)
--   - 010a-exercise-subcategory-enum.sql (category_ex_neuromuscular,
--                                         category_ex_resistance, category_ex_bodyweight)
--   위 마이그레이션이 먼저 실행·커밋되어 있어야 합니다.
--
-- sw-db-architect | 2026-04-26
-- ============================================================

BEGIN;

-- ============================================================
-- [1] 맥켄지 기계적 진단 및 치료 (요추)
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
  'category_mdt',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mdt'),
  'MDT — 요추 방향성 운동',
  '맥켄지 기계적 진단 및 치료 (요추)', 'McKenzie Mechanical Diagnosis and Therapy — Lumbar Spine', 'MDT-Lumbar',
  'lumbar'::body_region, 'L1–S1 (전반적 요추 적용)',
  '복와위(엎드린 자세) 또는 앉은 자세',
  '환자 옆에 서서 관찰 위치 유지; 과압 적용 시 요추 분절에 손 접촉',
  '관찰 위주; 필요 시 요추 분절에 과압 적용',
  '방향성 선호에 따라 결정 (주로 신전 방향)',
  '[{"step":1,"instruction":"평가 단계: 굴곡, 신전, 측방 이동 방향별 반복 운동 검사 시행. 각 방향으로 10회 반복 후 증상 반응(집중화 또는 말초화) 관찰"},{"step":2,"instruction":"방향성 선호 결정: 집중화 현상(말초 증상이 척추 중앙으로 이동·소멸)이 유도되는 방향을 방향성 선호로 결정. 주로 신전 선호가 많음"},{"step":3,"instruction":"운동 처방: 방향성 선호 방향으로 반복 운동 처방. 신전 선호 시 복와위 팔굽혀펴기 변형(Prone Press-Up) 10회/세트, 1~2시간마다 반복"},{"step":4,"instruction":"진행 조정: 집중화 확인 후 하중 추가 순서로 진행. 복와위 → 선 자세 신전 → 체중 부하 반복 운동 순. 가정 운동으로 전환"},{"step":5,"instruction":"재평가: 세션마다 집중화 유지 여부 확인. 말초화 발생 시 즉시 방향 전환 또는 강도 조절"}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","radicular_pain","lbp_nonspecific","disc_herniation"}',
  '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_1a'::evidence_level,
  '집중화 현상은 MDT의 핵심 예측 지표 — 첫 평가에서 집중화가 유도되면 예후 양호로 해석. 환자 자가관리 능력 훈련이 목표 — 치료사 의존도를 낮추고 재발 시 스스로 처방 가능하도록 교육. 통증이 말초(다리)로 퍼지면 방향을 바꾸거나 중단이라는 명확한 기준을 환자에게 설명.',
  'fracture, instability, malignancy, neurological_deficit (마미증후군 의심 포함)',
  'osteoporosis, inflammation_acute',
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
-- [2] 신경운동 조절 운동 (심부 코어 재활성화 / MCE)
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
  'category_ex_neuromuscular',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_neuromuscular'),
  '운동 조절 — 심부 코어 활성화',
  '신경운동 조절 운동 (심부 코어 재활성화)', 'Motor Control Exercise', 'MCE',
  'lumbar'::body_region, 'L4-L5, L5-S1 (심부 안정화근 주요 작용 분절)',
  '누운 자세 (훅 라잉: 무릎 굽힌 앙와위) 또는 네발기기 자세',
  '환자 옆; 요추 및 복부 촉진 위치',
  '하복부(복횡근 촉진), 요추 다열근 분절 촉진',
  '해당 없음 (근수축 활성화 훈련)',
  '[{"step":1,"instruction":"평가 단계: 압력 바이오피드백 유닛(PBU) 요추 아래에 설치, 기준값 70 mmHg. 복횡근 단독 수축 시 압력 변화 관찰 (2~4 mmHg 감소가 정상)"},{"step":2,"instruction":"독립 활성화 단계: 복부 드로-인(Abdominal Draw-In). 천장 호흡 유지하면서 배꼽 아래를 척추 방향으로 살짝 당기기. 발살바(숨 참기) 없이 10초 유지"},{"step":3,"instruction":"다열근 활성화: 요추 분절 수준에서 치료사 촉진 피드백과 함께 분절 다열근 등척성 수축 유도. 10초 유지 × 10회"},{"step":4,"instruction":"공동 수축 통합: 복횡근 활성화 상태에서 팔·다리 움직임 추가. 버드독(Bird Dog), 데드버그(Dead Bug) 순서로 진행"},{"step":5,"instruction":"기능 통합 재평가: 서기·걷기·직업 동작에서 심부 근육 활성화 유지 여부 확인. 매 4~6주마다 PBU 재평가 실시"}]'::jsonb,
  '{"pain_relief","stabilization","proprioception"}',
  '{"subacute","chronic","post_surgical"}',
  '{"movement_pain","lbp_nonspecific"}',
  '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_1a'::evidence_level,
  '큰 근육(복직근, 척추기립근)으로 버티는 것이 아니라 심부에서 세밀하게 조절하는 것이 핵심 — 강도보다 선택성이 우선. 움직임 조절 결함이 확인된 환자에게 가장 효과적 — 단순 통증 감소 목적만으로는 다른 운동 대비 우위 없음. 수술 후 재활에서 복횡근 선행 활성화(Feedforward) 패턴 회복이 핵심 목표.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
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
-- [3] 코어 안정화 훈련 (맥길 빅 쓰리)
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
  'category_ex_bodyweight',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_bodyweight'),
  '코어 안정화 — 맥길 Big 3',
  '코어 안정화 훈련 (맥길 빅 쓰리)', 'Core Stability Training — McGill Big 3', 'McGill-Big3',
  'lumbar'::body_region, '전반적 요추·흉요추 이행부',
  '매트 위 누운 자세 또는 엎드린 자세',
  '관찰 및 교정 위치; 필요 시 요추 중립 자세 확인 위해 손을 요추 아래에 위치',
  '필요 시 요추 아래 손 위치 (중립 자세 확인)',
  '해당 없음 (운동 기반)',
  '[{"step":1,"instruction":"자세 평가 + 중립 척추 교육: 요추 중립 자세(Neutral Spine) 교육. 과도한 전만 또는 후만 없이 자연스러운 S자 곡선 유지. 통증 유발 동작 확인 후 범위 조절"},{"step":2,"instruction":"버드독(Bird Dog): 네발기기 자세에서 반대팔-다리 동시 신전. 요추 회전 없이 중립 유지가 핵심. 8~10회/측, 2~3세트"},{"step":3,"instruction":"수정 컬업(Modified Curl-Up): 무릎 굽힌 누운 자세, 한 손을 요추 아래에 대고 상부 흉추만 살짝 들기. 경추 중립 유지. 5→3→1 하강 피라미드, 각 8~10초 홀드"},{"step":4,"instruction":"사이드 플랭크(Side Plank): 무릎 구부린 자세부터 시작 → 발 지지 자세로 진행. 엉덩이 들림 유지 10~30초. 3세트/측"},{"step":5,"instruction":"진행 및 기능 통합 재평가: 데드버그, 플랭크 추가 후 스쿼트·힌지 등 기능 동작으로 이행. 매 4주 전체 재평가"}]'::jsonb,
  '{"pain_relief","rom_improvement","stabilization"}',
  '{"subacute","chronic","post_surgical"}',
  '{"movement_pain","lbp_nonspecific"}',
  '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_1a'::evidence_level,
  '횟수보다 "정확한 조절과 느린 속도"가 우선 — 잘못된 자세로 100회보다 바른 자세로 10회가 효과적. McGill Big 3는 척추 부하를 최소화하면서 안정화를 훈련하도록 설계된 순서 — 반드시 이 3개를 기본으로. 급성기 통증이 일부 조절된 후(NPRS ≤ 5) 시작 — 급성 강한 통증 시기에는 MCE 단계부터.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
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
-- [4] 점진적 활동 (행동주의적 재활 / Graded Activity)
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
  'category_ex_bodyweight',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_bodyweight'),
  '기능 재활 — 행동주의적 접근',
  '점진적 활동 (행동주의적 재활)', 'Graded Activity', 'GradedActivity',
  'lumbar'::body_region, '해당 없음 (전신 기능 기반 접근)',
  '앉은 자세 (초기 면담); 이후 활동 종류에 따라 다양',
  '면담·코칭 위치',
  '해당 없음 (행동주의적 접근)',
  '해당 없음',
  '[{"step":1,"instruction":"기초선 설정: FABQ(두려움-회피 믿음 설문), TSK(Tampa Scale of Kinesiophobia) 평가. 환자와 함께 구체적 기능 목표 설정(걷기 10분, 계단 오르기, 직장 복귀 등). 현재 가능한 활동 수준(베이스라인) 측정"},{"step":2,"instruction":"할당량 결정: 통증 한계점 이하에서 시작 활동량 결정. 시간 기반(Time-Contingent) 원칙 — 통증 유무와 상관없이 미리 정한 할당량에 따라 진행"},{"step":3,"instruction":"점진적 증가: 세션마다 활동량 소량 증가(5~10%/세션). 통증이 있어도 할당량 달성 시 긍정적 강화. 페이싱(Pacing) 전략 교육 — 좋은 날 과하게 하고 나쁜 날 아무것도 안 하는 패턴 예방"},{"step":4,"instruction":"PNE 병합: 매 세션 통증 신경과학 교육 5~10분 병합. 통증=위협 신호이지 손상 신호가 아님을 반복 교육"},{"step":5,"instruction":"기능 목표 달성 확인: 설정한 기능 목표 달성률 평가. 자가 관리 전략 교육 후 독립적 유지 계획 수립"}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"chronic"}',
  '{"movement_pain","rest_pain","lbp_nonspecific"}',
  '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_1b'::evidence_level,
  'KMO 핵심 철학 "Calm things down, Build things back up"과 가장 직결되는 접근 — 기능 회복이 통증 소멸보다 먼저. 황색 깃발(Yellow Flags: 두려움-회피, 파국화, 사회적 고립)이 다수인 만성 요통에서 가장 강력한 선택. PNE와 병합할 때 효과가 배가됨 — 단독 사용보다 운동치료+인지행동치료 요소 통합 권장.',
  'fracture, instability, malignancy, neurological_deficit',
  'major_depression (주요 우울증 동반 시 심리치료사 협진 필요)',
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
-- [5] 신경 가동술 (좌골신경 — Neurodynamic Mobilization)
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
  'category_d_neural',
  (SELECT id FROM technique_categories WHERE category_key = 'category_d_neural'),
  '신경 가동술 — 좌골신경 Slider',
  '신경 가동술 (좌골신경 적용)', 'Neurodynamic Mobilization — Sciatic Nerve', 'NM-Sciatic',
  'lumbar'::body_region, 'L4-L5, L5-S1 (좌골신경 기시 분절)',
  '누운 자세(앙와위) — SLR Slider; 앉은 자세 — Slump Slider',
  '환자 발 쪽; 고관절·슬관절 지지 위치',
  '발뒤꿈치(뒤꿈치 컵 그립) + 슬관절 후면 지지',
  '고관절 굴곡 방향, 경추 굴곡 방향 (Slider: 반대로 교대)',
  '[{"step":1,"instruction":"평가(SLR/Slump): SLR 검사 — 70° 미만에서 방사통 재현 시 양성. Slump 검사 — 앉아서 경추 굴곡+슬관절 신전 조합으로 신경 긴장 확인. 신경 긴장 유발 위치·방향 파악"},{"step":2,"instruction":"Slider 기법 우선 적용: 앙와위 SLR Slider — 고관절 굴곡(슬관절 신전)과 경추 굴곡을 동시에 → 경추를 신전하면서 고관절 낮추기(두 끝을 반대 방향으로 교대). 리드미컬하고 연속적으로 15회/세트"},{"step":3,"instruction":"Slump Slider 적용: 앉은 자세 경추 굴곡 + 슬관절 신전을 반대 방향으로 교대. 양쪽 동시 또는 편측 적용. 15회 × 2세트"},{"step":4,"instruction":"강도·범위 조절: 통증 내성에 따라 고관절 굴곡 범위 점진 증가. Slider → Tensioner 순서로 증상 개선 후 단계 전환"},{"step":5,"instruction":"가정 운동 교육: 누운 자세 또는 앉은 자세 SLR Slider 가정 운동 처방. 일 2회 시행, 매 세션 SLR 범위 재평가"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","radicular_pain","radiculopathy","disc_herniation"}',
  '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_1a'::evidence_level,
  '신경을 "스트레칭"이 아닌 "미끄러뜨리는" 개념으로 교육 — Slider가 Tensioner보다 신경계 부담이 적어 우선 적용. SLR 범위 개선이 치료 효과의 객관적 지표 — 매 세션 측정하여 변화 추적. 통증 없는 신경 이동이 목표 — 날카로운 통증이 유발되면 즉시 범위 축소.',
  'fracture, instability, malignancy, neurological_deficit (진행성 신경 결손, CES 의심 포함)',
  'inflammation_acute (Tensioner 금기, Slider만 조심스럽게 적용)',
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
-- [6] 심부 경추 굴곡근 훈련 (DCF Training)
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
  'category_ex_neuromuscular',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_neuromuscular'),
  '운동 조절 — 심부 경추 굴곡근',
  '심부 경추 굴곡근 훈련', 'Deep Cervical Flexor Training', 'DCFT',
  'cervical'::body_region, 'C1-C4 (두장근·경장근 주요 작용 분절)',
  '누운 자세(앙와위), 목 뒤에 압력 바이오피드백 유닛(PBU) 설치',
  '환자 옆; 흉쇄유돌근·전사각근 촉진 위치',
  '경부 표층 근육(흉쇄유돌근) 촉진 — 과활성 여부 모니터링',
  '두개경추 굴곡 방향 (고개 끄덕임)',
  '[{"step":1,"instruction":"CCFT 평가(Cranio-Cervical Flexion Test): PBU를 목 아래에 설치, 기준값 20 mmHg에서 시작. 22, 24, 26, 28, 30 mmHg 순서로 5단계 고개 끄덕임 각도 조절. 각 단계 10초 유지 가능 여부 + 표층근(흉쇄유돌근) 과활성 여부 촉진 확인. 도달 불가 단계 = 훈련 목표 설정"},{"step":2,"instruction":"독립 활성화 단계: 현재 가능한 mmHg 단계에서 시작. 흉쇄유돌근에 손가락 대고 과활성 없는지 자가 모니터링 지도. 10초 유지 × 10회 × 2~3세트"},{"step":3,"instruction":"단계적 부하 증가: 10초 × 10회 달성 시 다음 단계(+2 mmHg) 상향. 표층근 활성화 없이 목표 단계 유지가 기준"},{"step":4,"instruction":"기능 통합: 앉은 자세 → 선 자세 → 동적 자세 순서로 DCF 활성화 유지 훈련. 경추 후퇴(Retraction) 동작과 통합"},{"step":5,"instruction":"가정 운동 교육: PBU 없이 감각 피드백만으로 고개 끄덕임 훈련 지도. 일 3회, 주 5일 가정 훈련 처방"}]'::jsonb,
  '{"pain_relief","stabilization","proprioception"}',
  '{"subacute","chronic"}',
  '{"movement_pain","cervicogenic_ha"}',
  '{"vbi_risk","fracture","instability","malignancy","neurological_deficit"}',
  'level_1b'::evidence_level,
  'CCFT로 평가한 목표 단계를 벗어나지 않는 것이 핵심 — 너무 강하면 표층근이 보상 수축. 표층근(흉쇄유돌근)이 활성화되지 않는 범위에서만 훈련하는 것이 심부근 선택적 활성화의 핵심. 경추성 두통 환자에서 DCF 훈련이 두통 빈도·강도 모두에 유의한 개선 효과를 보임(Jull et al.).',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, inflammation_acute',
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
-- [7] 경추 맥켄지 (후퇴+신전 시퀀스)
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
  'category_mdt',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mdt'),
  'MDT — 경추 방향성 운동',
  '경추 맥켄지 (후퇴+신전 시퀀스)', 'Cervical McKenzie — Retraction & Extension Sequence', 'CervMDT',
  'cervical'::body_region, 'C3-C7 (후퇴: 전체 경추 / 신전: 하부 경추 주요)',
  '앉은 자세 또는 선 자세',
  '환자 옆·뒤; 과압(Overpressure) 적용 위치',
  '후두부 또는 하악 (과압 적용 시)',
  '수평 후방(후퇴) → 필요 시 신전 추가',
  '[{"step":1,"instruction":"평가 단계: 반복 후퇴(Repeated Retraction) 10회 시행 후 증상 반응 관찰. 필요 시 반복 신전(Repeated Extension) 추가. 집중화(말초 증상이 목으로 이동) 또는 말초화 여부 확인. 방향성 선호 결정 — 후퇴/후퇴+신전/굴곡/측방 이동"},{"step":2,"instruction":"후퇴 운동 처방: 앉거나 선 자세에서 턱을 수평으로 뒤로 당기기(이중턱 만드는 동작). 끝 범위에서 1~2초 유지 후 중립 복귀. 10~15회/세트"},{"step":3,"instruction":"신전 추가(필요 시): 후퇴 끝에서 고개를 뒤로 젖히기 추가. 증상 집중화 지속되면 치료사 과압 적용. 치료사 양손으로 후두부 지지 후 신전 방향으로 부드럽게 과압"},{"step":4,"instruction":"가정 운동 처방: 팔꿈치 아래 증상 시 매 1시간마다 / 팔꿈치 위 증상 시 2~3시간마다 반복. 증상 소멸 후 3일 무증상까지 지속, 이후 빈도 점감"},{"step":5,"instruction":"자세 교육 + 재발 방지: 앉은 자세 경추 중립 교육, 베개 높이 조정. 재발 시 스스로 처방 가능하도록 자가 처방 훈련"}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","radicular_pain","cervicogenic_ha"}',
  '{"vbi_risk","fracture","instability","malignancy","neurological_deficit"}',
  'level_1b'::evidence_level,
  '요추 MDT와 동일 원칙 — 집중화 현상 확인이 예후 예측 핵심 지표. 경추 신전 시 VBI 스크리닝 필수 선행 — 특히 고령 환자·혈관 질환 위험인자 보유자. 후퇴 동작은 "이중턱 만들기"로 간단히 설명하면 환자 수행 정확도가 높아짐.',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit (척수증 의심 포함)',
  'osteoporosis, inflammation_acute',
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
-- [8] 경추 고유감각 재훈련
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
  'category_ex_neuromuscular',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_neuromuscular'),
  '감각운동 재훈련 — 고유감각',
  '경추 고유감각 재훈련', 'Cervical Proprioceptive Retraining', 'CervPropRetraining',
  'cervical'::body_region, 'C0-C2 (후두하근 고유감각 수용체 주요 부위)',
  '앉은 자세 (표준); 이후 선 자세 → 불안정면 순서로 진행',
  '환자 옆; 안전 확보 위치',
  '필요 시 어깨 지지 (낙상 방지)',
  '해당 없음 (감각운동 훈련)',
  '[{"step":1,"instruction":"JPE 평가(Joint Position Error Test): 눈 감고 목표 방향(30° 회전, 25° 굴·신전) 복귀 정확도 측정. 정상 기준 오차 < 4.5°. 오차 > 4.5° = 고유감각 재훈련 적응증 확인"},{"step":2,"instruction":"레이저 포인터 훈련(눈 뜨고): 헤드밴드에 레이저 포인터 장착. 벽에 그린 목표 지점(십자, 원, 숫자) 추적. 8자, 원, 직선 패턴 순서로 10~15분 훈련"},{"step":3,"instruction":"눈 감고 난이도 증가: 동일 패턴을 눈 감고 수행. 목표 지점 기억 후 정확히 레이저 위치시키는 훈련. 위치 도달 후 눈 뜨고 오차 확인"},{"step":4,"instruction":"자세 난이도 증가: 앉기 → 서기 → 폼 패드 위 서기(불안정면) 순서로 진행. 안구 운동+경추 움직임 협응 훈련(Gaze Stabilization) 추가"},{"step":5,"instruction":"가정 운동 교육 + JPE 재평가: 레이저 없이 거울 앞에서 감각 피드백으로 수행 지도. 4주마다 JPE 재측정으로 효과 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","proprioception"}',
  '{"subacute","chronic"}',
  '{"movement_pain","cervicogenic_ha"}',
  '{"vbi_risk","fracture","instability","malignancy","neurological_deficit"}',
  'level_1b'::evidence_level,
  '편타손상(Whiplash) 후 고유감각 결손이 만성화의 핵심 기전 — 조기 평가·훈련이 예후에 중요. BPPV(이석증)와 경추성 어지럼증의 감별이 선행되어야 훈련 효과 극대화. 가정에서는 거울 앞 레이저 없이도 동일 훈련 가능 — 순응도 높은 가정 운동 처방 형태.',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit',
  'BPPV (이석증) 의심 시 먼저 이석정복(Epley) 시행 후 진행',
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
-- [9] 경추 주변근 강화 훈련
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
  'category_ex_resistance',
  (SELECT id FROM technique_categories WHERE category_key = 'category_ex_resistance'),
  '경추 근력 강화 훈련',
  '경추 주변근 강화 훈련', 'Cervical Strengthening Exercise', 'CervStrengthening',
  'cervical'::body_region, 'C1-C7 전반 (굴곡근·신전근·회전근)',
  '앉은 자세 (등척성 단계); 다양한 자세 (등심성·저항 단계)',
  '환자 앞 또는 옆; 저항 제공 위치',
  '이마(굴곡 저항), 후두부(신전 저항), 측두부(측굴 저항)',
  '굴곡, 신전, 측굴, 회전 4방향',
  '[{"step":1,"instruction":"등척성 훈련 단계(통증 억제): 굴곡 — 이마에 손 대고 밀어붙이기(목 움직이지 않음) 5~10초 유지. 신전 — 양손 깍지 끼고 뒤통수 밀기. 측굴·회전 방향 동일 적용. 통증 없는 강도에서 시작 — 5~10회 × 10초 유지"},{"step":2,"instruction":"등심성 훈련 단계: 저항 없이 가동 범위 전체에서 조절된 운동. 굴곡 — 고개 숙임 → 중립 복귀. 신전 — 고개 뒤로 → 중립 복귀. 느린 속도, 통증 없는 전 범위"},{"step":3,"instruction":"저항 훈련 단계: 저항 밴드 또는 기계 저항 사용. 점진적 과부하(Progressive Overload) 원칙 — 2주마다 저항 증가. 3세트 × 10~15회"},{"step":4,"instruction":"DCF 훈련과 병합: 심부 경추 굴곡근(DCF) 활성화 상태에서 표층 근육 강화. 순서 — DCF 활성화 확인 → 등척성 → 등심성 → 저항 단계 통합"},{"step":5,"instruction":"기능 통합 + 재평가: 컴퓨터 작업·운전 등 직업 동작에서 경추 근력 유지 훈련. 6주마다 경추 근력 검사(Dynamometry 또는 도수 근력 검사)로 재평가"}]'::jsonb,
  '{"pain_relief","rom_improvement","stabilization"}',
  '{"subacute","chronic"}',
  '{"movement_pain","radicular_pain","cervicogenic_ha"}',
  '{"vbi_risk","fracture","instability","malignancy","neurological_deficit"}',
  'level_1b'::evidence_level,
  '등척성 6회/일 × 6일/주 × 4주 프로토콜이 경추 척추증(Spondylosis) RCT에서 통증·장애 유의한 개선 — 빈도가 강도보다 중요. 심부 근육(DCF 훈련)이 안정화를 담당하고 표층 근육이 힘을 담당하는 층위 이해 필요 — 항상 DCF 병행. 직업성 경추통(컴퓨터 작업, 고개 숙임 작업) 환자에서 강화 훈련이 가장 효과적인 1차 선택.',
  'vbi_risk, fracture, instability, malignancy, neurological_deficit (척수증 의심 포함)',
  'osteoporosis, inflammation_acute',
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
-- [10] 통증 신경과학 교육 병합 접근 (PNE)
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
  'category_pne',
  (SELECT id FROM technique_categories WHERE category_key = 'category_pne'),
  'PNE — 운동치료 병합',
  '통증 신경과학 교육 병합 접근', 'Pain Neuroscience Education — Combined Approach', 'PNE-Combined',
  'cervical'::body_region, '해당 없음 (교육적 접근, 전신 신경계 대상)',
  '앉은 자세 (면담 및 교육)',
  '환자 맞은편 — 동등한 대화 위치',
  '해당 없음 (언어·시각 교육 중심)',
  '해당 없음',
  '[{"step":1,"instruction":"통증 신념 평가: PCS(통증 파국화 척도), SOPA(통증에 대한 인식 설문) 시행. 개방형 질문 — 파국화, 통제 불능감, 과잉 의료 탐색 패턴 확인"},{"step":2,"instruction":"신경과학 교육 제공: 알람 시스템 비유, 볼륨 조절 비유 등 시각 자료 활용. 강의 형식 지양 — 대화형, 질문-답변 방식으로 15~30분/세션"},{"step":3,"instruction":"재프레이밍 연습: 통증=손상이 아닌 통증=위협 신호 개념 반복 확인. 이전 부적응적 믿음을 환자 스스로 교정하도록 유도. 실제 활동 중 통증에 대한 해석 변화 연습"},{"step":4,"instruction":"운동치료·도수치료와 통합: 매 세션 운동 전후 짧은 PNE 복습 5~10분. Graded Activity 또는 Graded Exposure와 병합"},{"step":5,"instruction":"효과 재평가: PCS 재측정(임상적으로 의미 있는 변화 ≥ 9.1점 감소). TSK 재측정 — 운동 공포증 개선 확인. 운동 처방 순응도 변화 추적"}]'::jsonb,
  '{"pain_relief"}',
  '{"chronic"}',
  '{"movement_pain","rest_pain"}',
  '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_1a'::evidence_level,
  '"통증은 실제이고 진짜입니다 — 다만 조직 손상의 크기를 정확히 반영하지 않습니다"가 핵심 메시지 — KMO 철학과 완전 일치. PNE는 보조 개입으로 가장 효과적 — 운동치료+도수치료와 통합할 때 시너지. 단독 처방은 권장하지 않음. 파국화 점수(PCS > 30)가 높은 환자에서 먼저 PNE 시작하면 이후 운동 순응도가 현저히 높아짐.',
  'fracture, instability, malignancy, neurological_deficit',
  'major_psychiatric_disorder (주요 정신질환 동반 시 심리치료사 협진 선행)',
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
-- [11] 장요근 능동 이완 기법 (ART)
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
  'ART — 요추부 심부 굴곡근',
  '장요근 능동 이완 기법', 'Active Release Technique — Iliopsoas', 'LumbART-IP',
  'lumbar'::body_region, 'L1–L5 전방 및 엉덩관절 전면 (장골와–소전자 구간)',
  '앙와위 — 복벽 이완 필수; 치료할 쪽 무릎 굽혀 발을 치료대에 올려놓음',
  '환자 옆, 치료할 쪽 복부 수준; 검지·중지·약지 세 손가락 끝을 배꼽 외측 3~4cm에서 복벽 안쪽 방향으로 진입',
  '검지·중지·약지 끝 — 배꼽 외측 3~4cm, 복직근 통과 후 장요근 근복',
  '척추 방향(후내측)으로 부드럽게 압박 유지 + 엉덩관절 신전 방향 능동 이동',
  '[{"step":1,"instruction":"안전 확인 및 촉진 단계: 배꼽 외측 3cm 지점에 손가락 끝을 부드럽게 올리고, 환자가 숨을 내쉬는 순간 복벽 안쪽으로 서서히 침투. 복직근이 이완될 때 더 깊이 진입. 장요근 근복의 단단한 질감 확인. 박동성 덩어리 느낌이 없는지 확인 후 계속 진행"},{"step":2,"instruction":"접촉 고정 단계: 장요근 근복 위에서 적절한 압력으로 접촉 유지. 사타구니 방향으로 당기는 느낌으로 위치 확인. 통증 NRS 기준점 확인"},{"step":3,"instruction":"능동 신전 시행 단계: 접촉 유지 상태에서 환자에게 무릎을 천천히 치료대 아래로 내리면서 다리를 뒤로 뻗도록 지시. 5~8초에 걸쳐 천천히 이동하며 장요근 신장"},{"step":4,"instruction":"반복/조정 단계: 1회 완료 후 환자 다리를 다시 굽혀 시작 자세로 복귀. 2~3회 반복 후 접촉 위치를 1~2cm씩 이동하며 장요근 전체 근복 탐색. L3-L4 및 L1-L2 수준 모두 탐색"},{"step":5,"instruction":"재평가 단계: 시술 후 허리 신전(뒤로 젖히기), 보행 시 엉덩관절 신전 자연스러움 재평가. 통증 NRS 재측정"}]'::jsonb,
  '{"pain_relief","rom_improvement","soft_tissue"}',
  '{"subacute","chronic"}',
  '{"movement_pain","rest_pain","lbp_nonspecific"}',
  '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_4'::evidence_level,
  '복부 접근 전 반드시 박동 확인 — 배꼽 바로 좌측은 복부 대동맥 위치. 박동이 계속 느껴지면 시술 금기. 환자 호흡을 이용한 단계적 침투 — 내쉬는 순간 복벽 긴장이 낮아지는 순간 이용. 사타구니 방향 연관통 = 장요근 확인 신호. 신전 움직임 범위 환자마다 조정 — 처음에는 30°부터 시작.',
  'abdominal_aortic_aneurysm (복부 대동맥류 의심), fracture, malignancy, neurological_deficit, pregnancy',
  'osteoporosis, acute_bowel_disease, post_abdominal_surgery_6wk, anticoagulant_therapy',
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
-- [12] 허리네모근 능동 이완 기법 (ART)
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
  'ART — 요추부 외측 근육',
  '허리네모근 능동 이완 기법', 'Active Release Technique — Quadratus Lumborum', 'LumbART-QL',
  'lumbar'::body_region, 'L1–L4 측방, 12번 갈비뼈-장골능 구간',
  '측와위(치료할 쪽이 위로) — 아래쪽 다리 약간 굽힘, 위쪽 다리 신전 위치 시작; 또는 복와위',
  '환자 등쪽, 허리네모근 근복 수준에서 서 있음; 엄지 지문면 또는 검지·중지 끝으로 장골능 바로 위 허리 척추 3~4cm 옆 지점 접촉',
  '엄지 지문면 또는 두 손가락 끝 — 장골능 바로 위, 허리 척추 외측 3~4cm',
  '허리네모근 조직에 수직(척추 방향으로 약간 기울여) 접촉 유지 + 엉덩관절 신전·측굴 방향 능동 이동',
  '[{"step":1,"instruction":"촉진/위치 확인 단계: 장골능 바로 위, 허리 척추에서 3~4cm 외측 지점에서 단단한 근육 띠(taut band)를 촉진으로 확인. 가장 단단하고 압통이 있는 지점을 선택"},{"step":2,"instruction":"접촉 단계: 엄지 또는 두 손가락 끝으로 선택된 조직에 수직 방향으로 압박을 서서히 가하여 접촉 유지. 환자 호흡(내쉬는 순간)을 이용하여 단계적으로 깊이 진입"},{"step":3,"instruction":"능동 움직임 시행 단계: 접촉 유지 상태에서 환자에게 위쪽 다리를 천천히 신전(뒤로 뻗기)하도록 지시. 다리 신전에 따라 허리네모근이 신장. 완전 신전까지 천천히 이동. 대안 — 측굴 또는 내전 방향 이동도 가능"},{"step":4,"instruction":"반복/조정 단계: 1회 완료 후 새로운 조직 부위로 1~2cm 이동하여 재접촉. 같은 방법으로 2~3개 부위 반복. 한 부위당 3~5회 반복"},{"step":5,"instruction":"재평가 단계: 시술 후 허리 측굴, 앞으로 굽히기 재평가. 통증 NRS 재확인. 환자 피드백 청취"}]'::jsonb,
  '{"pain_relief","rom_improvement","soft_tissue"}',
  '{"subacute","chronic"}',
  '{"movement_pain","rest_pain","lbp_nonspecific"}',
  '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_4'::evidence_level,
  '능동 움직임 속도가 핵심 — 환자가 너무 빠르게 움직이면 조직 위 접촉이 미끄러짐. "5초에 걸쳐 천천히" 구두 지시 필수. 엄지보다 팔꿈치 압박이 더 깊고 지속적인 접촉 가능 — 치료사 손 피로도 감소. 신장 중 엉덩이 외측으로 퍼지는 연관통은 좋은 반응 신호. 다리 전체 저림·전기 느낌은 신경 증상으로 구별 후 즉시 중단.',
  'fracture, instability, malignancy, neurological_deficit, acute_renal_disease',
  'osteoporosis, inflammation_acute, pregnancy, anticoagulant_therapy',
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
-- [13] 요추 부위 근막경선 임상 적용 (Anatomy Trains — SBL & DFL)
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
  'Anatomy Trains — SBL+DFL 경선 (요추 세그먼트)',
  'SBL+DFL 근막경선 임상 적용 — 요추 구간', 'Anatomy Trains Application — SBL & DFL (Lumbar Segment)', 'AT-SBL-DFL-Lumbar',
  'lumbar', 'L1–S1 (SBL 요추 구간), L1–L5 전방 (DFL 요추 구간)',
  'SBL: 복와위(엎드린 자세) — 이마 아래 베개, 배 아래 얇은 베개; DFL: 앙와위 — 무릎 구부린 훅 라잉 자세',
  'SBL: 환자 옆, 발바닥-종아리-햄스트링-흉요추 순 접촉; DFL: 환자 옆, 내전근→장요근→횡격막 방향 순',
  'SBL: 손바닥 전체면, 팔뚝, 팔꿈치; DFL: 손가락 끝(장요근), 손바닥(횡격막 부위)',
  'SBL: 경선 방향(발에서 허리 방향)으로 신장 유지; DFL: 호흡 연동 이완',
  '[{"step":1,"instruction":"SBL 긴장 패턴 평가: 전굴 시 종아리 뒤·햄스트링 당김 여부 확인. SLR 60° 이하에서 허리·엉덩이·햄스트링 당김 확인. DFL 패턴: 허리 신전 시 전방 당김, Thomas test로 장요근 단축 여부 확인"},{"step":2,"instruction":"SBL 경선 풀기 — 발바닥·종아리: 발바닥 근막 엄지로 종방향 스트로크 2~3분. 종아리 뒤(비복근·가자미근) 압통 부위 팔뚝 또는 손바닥으로 종방향 이완 2~3분"},{"step":3,"instruction":"SBL 경선 풀기 — 햄스트링·흉요추: 슬와부에서 좌골결절까지 종방향 이완. 엉덩이 상단에서 흉요추 이행부까지 종방향 이완. 발바닥부터 흉요추까지 연속 스트로크 2~3회"},{"step":4,"instruction":"DFL 경선 — 허벅지 안쪽·장요근: 내전근 근복 종방향 이완. 배꼽 외측 3~4cm에서 장요근 근복 접촉 유지 2~3분(MFR 방식). 깊은 호흡 유도하며 횡격막 기시부(T12) 방향으로 이완 이동"},{"step":5,"instruction":"재평가: SBL — 전굴 및 SLR 재측정. DFL — Thomas test 재시행. 허리 신전 가동 범위 재확인. 환자 변화 보고 청취"}]'::jsonb,
  '{"pain_relief","rom_improvement","soft_tissue"}',
  '{"subacute","chronic"}',
  '{"movement_pain","lbp_nonspecific"}',
  '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_5'::evidence_level,
  'SBL 허리 통증의 실마리는 발바닥에 있을 수 있다 — 국소 치료 효과 제한적이면 발바닥 근막·종아리 뒤 먼저 이완 후 재평가. 근막경선 치료는 단독보다 병합이 효과적 — 관절 가동술, MDT, 운동치료와 함께 보조 역할. 경선을 해부학적 사실로 확정적으로 설명하지 말 것 — "연결되어 있는 것 같다"는 임상 관찰 기반 표현 사용. DFL 복부 접근 시 복부 대동맥류 박동 확인 필수.',
  'fracture, malignancy, neurological_deficit, abdominal_aortic_aneurysm (DFL 적용 시), acute_abdominal_condition',
  'osteoporosis, pregnancy (DFL 복부 접근 금지), severe_varicose_veins, post_surgery_6wk',
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
-- [14] 요추 인대 심부 마찰 마사지 (Deep Friction Massage)
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
  'Cyriax 심부 마찰 — 요추 인대',
  '요추 인대 심부 마찰 마사지', 'Deep Friction Massage — Lumbar Interspinous & Iliolumbar Ligament', 'LumbDFM-Lig',
  'lumbar'::body_region, 'L1–L5 극돌기 사이 (가시사이인대), L5-장골능 연결부 (엉덩허리인대)',
  '복와위(엎드린 자세) — 이마 아래 베개, 배 아래 얇은 베개(요추 굴곡 유도); 엉덩허리인대 접근 시 복와위 또는 측와위',
  '환자 옆, 목표 분절 수준에서 서 있음; 강화 검지 끝(검지 위에 중지 겹침) 또는 검지 단독, 보조 손은 시행 손 손목 위에 얹어 체중 전달',
  '강화 검지 끝 — 극돌기 사이 정확한 가시사이인대 위',
  '인대 섬유 방향(상-하)에 수직인 좌-우 횡마찰; 범위 0.5~1cm, 속도 1~2회/초',
  '[{"step":1,"instruction":"목표 분절 확인 단계: 극돌기(가시돌기)를 촉진하여 L1~L5 수준을 확인. 인접 두 극돌기 사이를 손가락으로 눌러 가장 압통이 강한 분절을 선택. 환자에게 평소 아픈 곳과 같은 느낌인지 확인"},{"step":2,"instruction":"정밀 접촉 단계: 강화 검지 끝을 목표 가시사이 공간에 정확히 위치. 피부를 누르는 것이 아니라 인대까지 깊이 침투하는 방향으로 수직 압박 먼저 가하여 정확한 위치 확인"},{"step":3,"instruction":"심부 횡마찰 시행 단계: 인대 섬유 방향에 수직인 좌-우 방향으로 짧고 리드미컬한 마찰 운동 시작. 마찰 범위 0.5~1cm, 속도 1~2회/초. 피부와 함께 움직이는 것이 핵심 — 피부 위를 미끄러지면 표층만 자극됨"},{"step":4,"instruction":"지속 및 조정 단계: 처음 2~3분은 불편감이 증가할 수 있으나 이후 감소하는 것이 정상. 4~5분 지속 후 환자 반응 재확인. 한 분절 완료 후 인접 분절로 이동. 세션당 2~3개 분절 가능"},{"step":5,"instruction":"재평가 단계: 시술 후 즉시 해당 분절 압통 재확인 — 직후 일시적 압통 증가 후 감소가 효과적 시술 신호(Cyriax 원칙). 허리 굴곡/신전 가동 범위 재평가. 통증 NRS 재측정"}]'::jsonb,
  '{"pain_relief","soft_tissue"}',
  '{"subacute","chronic"}',
  '{"movement_pain","rest_pain","lbp_nonspecific"}',
  '{"fracture","instability","malignancy","neurological_deficit","inflammation_acute"}',
  'level_4'::evidence_level,
  '피부와 함께 움직이는 것이 핵심 — 손가락이 피부 위를 미끄러지면 표층만 자극됨. 극돌기 사이 공간은 허리 굴곡 시 더 잘 열림 — 배 아래 베개 활용. 처음 2~3분 불편감은 정상(Counter-irritation 효과) — 환자에게 미리 안내. 엉덩허리인대는 L5 횡돌기에서 장골능으로 향하는 비스듬한 방향에서 접촉. 세션 후 24~48시간 반응 모니터링.',
  'fracture, instability, malignancy, neurological_deficit, inflammation_acute (발병 0~2주 이내)',
  'osteoporosis, skin_lesion, anticoagulant_therapy',
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
