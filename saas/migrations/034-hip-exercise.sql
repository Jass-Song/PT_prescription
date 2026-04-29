-- ============================================================
-- Migration 034 — 고관절 운동 처방 (7기법)
-- hip body_region: 근력 저항(3) + 자체중량(2) + 신경근 훈련(2)
-- sw-db-architect | 2026-04-29
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

BEGIN;

-- ────────────────────────────────
-- [1] 중둔근 저항 강화
-- category_ex_resistance | body_region: hip
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
  '운동 처방 — 고관절 외전근 강화',
  '중둔근 저항 강화', 'Gluteus Medius Resistance Training', 'HIP-EX-RES-GluMed',
  'hip'::body_region, '중둔근, 소둔근',
  '옆으로 눕기 또는 선 자세, 탄성 밴드를 무릎 위 또는 발목 위에 착용, 신체 정렬 중립 유지',
  '환자 옆에서 골반 수평 유지 및 보상 동작(골반 회전·과측굴) 관찰, 직접 접촉 없음(관찰 및 언어 피드백)',
  '해당 없음 (능동 운동)',
  '고관절 외전 방향',
  '[
    {"step":1,"instruction":"탄성 밴드를 무릎 바로 위 또는 발목 위에 착용하고, 옆으로 눕거나 선 자세에서 신체 중립 정렬을 확인한다. 치료사는 골반이 수평을 유지하는지 관찰한다."},
    {"step":2,"instruction":"옆으로 눕기의 경우, 아래쪽 무릎을 약간 구부려 지지하고 위쪽 다리를 무릎 편 채로 천천히 외전(위로 들어올리기)한다. 동작 끝 범위에서 1–2초 유지 후 천천히 내린다."},
    {"step":3,"instruction":"선 자세의 경우, 한 발로 서서 균형을 잡고 밴드를 착용한 다리를 외측으로 천천히 들어올린다. 골반이 지지 다리 쪽으로 기울거나 반대쪽 골반이 과하게 올라가지 않도록 주의한다."},
    {"step":4,"instruction":"외전 동작 중 허리가 옆으로 굽거나 골반이 회전하는 보상 동작이 발생하면 동작 범위를 줄이고 올바른 패턴이 유지되는 범위에서 반복한다. 15회 2–3세트를 기준으로 시작하고, 적응되면 밴드 저항을 단계적으로 높인다."},
    {"step":5,"instruction":"4주 후 고관절 외전 근력 검사(MMT) 및 단일 하지 서기 시 트렌델렌버그 징후 변화를 재평가한다. 개선이 확인되면 선 자세 또는 기능적 동작으로 진행한다."}
  ]'::jsonb,
  '{"strength_training","hip_stability","pain_relief"}',
  '{"subacute","chronic"}',
  '{"hip_pain","lateral_hip_pain","patellofemoral_pain","knee_pain"}',
  '{"fracture","joint_infection","malignancy","total_hip_arthroplasty_early"}',
  'level_2b'::evidence_level,
  '중둔근 약화는 트렌델렌버그 보행, 무릎 외반 증가, 고관절·슬관절 통증과 연관될 가능성이 있다. 옆으로 눕기 자세 외전으로 시작하여 선 자세 외전으로 진행할 때 기능적 전이 효과를 기대할 수 있다. 골반 안정화 불량 시 보상 동작이 나타날 수 있으므로 관찰이 중요하다.',
  'fracture, joint_infection, malignancy, total_hip_arthroplasty_early',
  'acute_inflammation, severe_hip_osteoarthritis, hip_labral_tear_acute',
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
-- [2] 고관절 신전 강화 (대둔근)
-- category_ex_resistance | body_region: hip
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
  '운동 처방 — 고관절 신전근 강화',
  '고관절 신전 강화 (대둔근)', 'Hip Extension Resistance Training — Glute Max', 'HIP-EX-RES-GluMax',
  'hip'::body_region, '대둔근, 슬굴곡근',
  '선 자세(킥백) 또는 엎드려 눕기, 탄성 밴드를 발목 위에 착용, 요추·골반 중립 유지',
  '환자 옆에서 요추 과신전 및 골반 전방 경사 보상 동작 관찰, 직접 접촉 없음(관찰 및 언어 피드백)',
  '해당 없음 (능동 운동)',
  '고관절 신전 방향',
  '[
    {"step":1,"instruction":"선 자세 킥백의 경우, 한 손으로 벽이나 의자 등받이를 잡아 균형을 유지하고, 탄성 밴드를 착용한 다리를 뒤쪽으로 천천히 들어올리는 고관절 신전 동작을 준비한다. 요추가 과도하게 젖혀지지 않도록 복부를 가볍게 활성화한다."},
    {"step":2,"instruction":"다리를 천천히 뒤로 들어올려 고관절 신전 끝 범위에서 1–2초 유지 후 천천히 시작 위치로 돌아온다. 골반이 옆으로 기울거나 허리가 지나치게 젖혀지는 보상 동작이 없는 범위에서 수행한다."},
    {"step":3,"instruction":"엎드려 눕기 자세의 경우, 배 아래 얇은 수건을 받쳐 요추 중립을 확보하고, 무릎을 편 채로 다리를 천천히 들어올린다. 엉덩이 근육이 수축하는 감각에 집중하도록 안내한다."},
    {"step":4,"instruction":"각 자세에서 15회 2–3세트로 시작하고, 4주 후 밴드 저항을 단계적으로 높인다. 양쪽 모두 수행하되 약한 쪽을 먼저 실시하고 강한 쪽과 동일한 횟수로 맞춘다."},
    {"step":5,"instruction":"4–6주 후 고관절 신전 근력 검사(MMT) 및 브릿지 유지 능력, 보행 시 추진력 변화를 재평가한다. 기능적 동작(스쿼트, 계단 오르기)에서 대둔근 활성화가 증가하는지 확인한다."}
  ]'::jsonb,
  '{"strength_training","hip_stability","functional_recovery"}',
  '{"subacute","chronic"}',
  '{"hip_pain","low_back_pain_nonspecific","buttock_pain","hip_extension_restriction"}',
  '{"fracture","joint_infection","malignancy","total_hip_arthroplasty_early"}',
  'level_2b'::evidence_level,
  '대둔근 약화는 요통 및 고관절 통증과 관련될 가능성이 있으며, 보행 시 추진력 감소 및 요추 과부하 증가로 이어질 수 있다. 엎드려 눕기 자세에서 시작하여 선 자세 킥백, 이후 스쿼트·런지 등 복합 패턴으로 진행할 때 기능적 전이를 기대할 수 있다. 슬굴곡근의 과활성화로 인한 보상 동작(무릎 굴곡 증가)이 나타날 수 있으므로 관찰이 필요하다.',
  'fracture, joint_infection, malignancy, total_hip_arthroplasty_early',
  'acute_inflammation, severe_lumbar_instability, proximal_hamstring_tear_acute',
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
-- [3] 고관절 내전근 강화
-- category_ex_resistance | body_region: hip
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
  '운동 처방 — 고관절 내전근 강화',
  '고관절 내전근 강화', 'Hip Adductor Strengthening', 'HIP-EX-RES-Add',
  'hip'::body_region, '내전근군 (장내전근·단내전근·대내전근)',
  '옆으로 눕기(아래 다리 내전) 또는 바로 눕기(볼 스퀴즈), 신체 정렬 중립 유지',
  '환자 옆에서 골반 안정성 및 보상 동작 관찰, 직접 접촉 없음(관찰 및 언어 피드백)',
  '해당 없음 (능동 운동)',
  '고관절 내전 방향',
  '[
    {"step":1,"instruction":"옆으로 눕기 자세에서 위쪽 다리를 의자나 베개로 받쳐 고정하고, 아래쪽 다리(내전 훈련 대상)를 천천히 위로 들어올리는 고관절 내전 동작을 준비한다. 탄성 밴드를 아래쪽 발목에 착용하여 저항을 추가할 수 있다."},
    {"step":2,"instruction":"아래쪽 다리를 천천히 위쪽 다리 방향으로 들어올려 내전 끝 범위에서 1–2초 유지 후 천천히 내린다. 골반이 앞뒤로 회전하거나 요추가 움직이지 않도록 복부를 가볍게 활성화한다. 15회 2–3세트 수행한다."},
    {"step":3,"instruction":"볼 스퀴즈의 경우, 바로 눕기 자세에서 무릎을 구부리고 무릎 사이에 소프트 볼(또는 작은 베개)을 끼운다. 양 무릎으로 볼을 서서히 조이면서 내전근을 등척성으로 수축한다. 5–10초 유지 10–15회 반복한다."},
    {"step":4,"instruction":"두 가지 방법 모두 적용하되, 급성 서혜부 통증이 있는 경우 볼 스퀴즈 등척성 방법으로 먼저 시작한다. 통증 없이 수행 가능해지면 동적 내전 운동으로 진행한다."},
    {"step":5,"instruction":"4–6주 후 고관절 내전 근력 검사(MMT 또는 덴마크 내전 짜기 검사) 및 서혜부 통증 NRS 변화를 재평가한다. 기능적 동작(방향 전환, 킥 동작)에서 통증 감소 여부를 함께 확인한다."}
  ]'::jsonb,
  '{"strength_training","hip_stability","pain_relief"}',
  '{"subacute","chronic"}',
  '{"hip_pain","groin_pain","adductor_strain","hip_adductor_weakness"}',
  '{"fracture","joint_infection","malignancy","acute_adductor_rupture"}',
  'level_2b'::evidence_level,
  '내전근 강화 운동은 서혜부 통증 및 내전근 손상 재활에 활용될 가능성이 있다. 등척성 볼 스퀴즈는 통증 억제 효과를 기대할 수 있어 급성기 이후 초기 개입에 적합할 수 있다. 선수 서혜부 통증(athletic pubalgia)에서는 내전근 강화와 코어 안정화를 병행하는 것이 효과적일 수 있다.',
  'fracture, joint_infection, malignancy, acute_adductor_rupture',
  'acute_groin_strain_grade3, osteitis_pubis_acute, hip_labral_tear_acute',
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
-- [4] 클램셸 운동
-- category_ex_bodyweight | body_region: hip
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
  '운동 처방 — 고관절 외전·외회전',
  '클램셸 운동', 'Clamshell Exercise', 'HIP-EX-BW-Clam',
  'hip'::body_region, '중둔근, 이상근',
  '옆으로 눕기, 엉덩이와 무릎을 각각 45–60도 구부린 자세, 발은 모아서 겹치기, 신체 중립 정렬 유지',
  '환자 등 뒤에서 골반 회전 보상 동작 관찰 및 언어 피드백, 직접 접촉 없음',
  '해당 없음 (능동 운동)',
  '고관절 외전·외회전 방향 (조개처럼 열기)',
  '[
    {"step":1,"instruction":"옆으로 눕기 자세에서 엉덩이를 45–60도, 무릎을 45–90도 구부리고 발은 모아서 겹친다. 아래쪽 팔을 베개처럼 머리 아래 받치고, 위쪽 손은 앞 바닥을 가볍게 짚어 균형을 보조한다."},
    {"step":2,"instruction":"발을 모은 채로 위쪽 무릎만 천장 방향으로 천천히 들어올린다. 마치 조개껍데기가 열리듯이 고관절이 외전·외회전되도록 한다. 골반이 뒤로 회전하는 보상 동작이 나타나지 않도록 유의한다."},
    {"step":3,"instruction":"무릎을 올릴 수 있는 최대 범위까지 들어올린 후 1–2초 유지하고 천천히 시작 위치로 내린다. 고관절 외측(중둔근)에 수축 감각이 느껴지는지 확인한다. 허리나 골반이 움직이면 동작 범위를 줄인다."},
    {"step":4,"instruction":"15–20회 2–3세트를 기준으로 수행하고, 쉬워지면 무릎 위에 탄성 밴드를 착용하여 저항을 추가한다. 양쪽 모두 수행하되 약한 쪽에 더 집중한다."},
    {"step":5,"instruction":"2–4주 후 중둔근 근력 변화, 단일 하지 서기 시 골반 수평 유지 능력, 고관절 외측 통증 NRS를 재평가한다. 클램셸이 쉬워지면 선 자세 외전 또는 사이드 스텝 운동으로 진행한다."}
  ]'::jsonb,
  '{"hip_stability","strength_training","pain_relief"}',
  '{"subacute","chronic","deconditioned"}',
  '{"lateral_hip_pain","hip_pain","patellofemoral_pain","gluteal_tendinopathy"}',
  '{"fracture","joint_infection","malignancy","total_hip_arthroplasty_early"}',
  'level_2b'::evidence_level,
  '클램셸은 중둔근 후방 섬유와 이상근을 선택적으로 활성화할 가능성이 있어 고관절 외측 통증 및 슬개대퇴 통증증후군 재활 초기에 활용될 수 있다. 골반 회전 보상 동작이 흔히 나타날 수 있으므로 치료사 관찰이 중요하다. 탄성 밴드 저항 추가 시 중둔근 활성도가 증가할 수 있다.',
  'fracture, joint_infection, malignancy, total_hip_arthroplasty_early',
  'acute_hip_inflammation, severe_hip_osteoarthritis, acute_labral_tear',
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
-- [5] 브릿지 운동
-- category_ex_bodyweight | body_region: hip
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
  '운동 처방 — 고관절 신전·골반 안정화',
  '브릿지 운동', 'Glute Bridge', 'HIP-EX-BW-Bridge',
  'hip'::body_region, '대둔근, 슬굴곡근, 척추기립근, 복횡근',
  '바로 눕기, 무릎을 구부려 발바닥이 바닥에 닿는 자세, 발은 엉덩이 너비, 팔은 몸통 옆에 이완',
  '환자 옆에서 골반 수평 유지 및 요추 과신전 관찰, 직접 접촉 없음(관찰 및 언어 피드백)',
  '해당 없음 (능동 운동)',
  '고관절 신전·골반 상승 방향',
  '[
    {"step":1,"instruction":"바로 눕기 자세에서 무릎을 구부리고 발바닥이 바닥에 닿도록 위치시킨다. 발은 엉덩이 너비로 벌리고, 발꿈치가 무릎 바로 아래 오도록 거리를 조정한다. 팔은 몸통 옆에 자연스럽게 이완한다."},
    {"step":2,"instruction":"복부를 가볍게 활성화한 뒤(배꼽을 척추 방향으로 살짝 당기기), 발꿈치로 바닥을 밀어내듯 엉덩이를 천천히 들어올린다. 어깨·골반·무릎이 일직선이 되는 지점에서 멈추고 엉덩이 근육의 수축 감각을 확인한다."},
    {"step":3,"instruction":"정점 자세에서 1–2초 유지한 후 척추 한 분절씩 내리듯 천천히 바닥으로 돌아온다. 한쪽 골반이 더 높거나 낮지 않도록 좌우 수평을 유지한다. 허리를 지나치게 젖히거나 엉덩이를 너무 높이 올리지 않도록 주의한다."},
    {"step":4,"instruction":"15회 2–3세트로 시작한다. 적응되면 단일 하지 브릿지(한 발로 수행), 무릎 사이 밴드 착용 브릿지, 발을 불안정 면 위에 올리는 방식 등으로 난이도를 점진적으로 높인다."},
    {"step":5,"instruction":"4–6주 후 고관절 신전 근력 검사, 요통 NRS, 브릿지 자세 유지 시간 변화를 재평가한다. 통증 없이 양측 대칭적으로 수행 가능해지면 스쿼트·데드리프트 등 기능적 패턴으로 진행한다."}
  ]'::jsonb,
  '{"hip_stability","strength_training","core_stability","pain_relief"}',
  '{"subacute","chronic","deconditioned"}',
  '{"hip_pain","low_back_pain_nonspecific","buttock_pain","hip_extension_restriction"}',
  '{"fracture","joint_infection","malignancy","total_hip_arthroplasty_early"}',
  'level_2b'::evidence_level,
  '브릿지는 대둔근과 슬굴곡근을 동시에 활성화할 수 있어 요추-골반 복합체 안정화 훈련의 기초로 활용될 수 있다. 거의 모든 수준의 환자에게 적용 가능한 안전한 운동으로, 낮은 강도에서 시작하여 단계적으로 난이도를 높이는 것이 적절할 수 있다. 슬굴곡근 과활성화(무릎 아래 경련)가 나타나면 발 위치를 앞으로 조정한다.',
  'fracture, joint_infection, malignancy, total_hip_arthroplasty_early',
  'acute_hip_inflammation, severe_knee_pain_during_bridge, acute_lumbar_disc_herniation',
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
-- [6] 단일 하지 스쿼트
-- category_ex_neuromuscular | body_region: hip
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
  '운동 처방 — 고관절 신경근 조절',
  '단일 하지 스쿼트', 'Single Leg Squat', 'HIP-EX-NM-SLS',
  'hip'::body_region, '고관절, 슬관절, 골반 안정화 복합체',
  '선 자세, 한쪽 발로 서고 반대쪽 발은 약간 들어올리거나 앞으로 내밀기, 벽이나 의자로 가볍게 지지 가능(초기)',
  '환자 정면 또는 앞쪽에서 무릎 정렬(외반·내반), 골반 수평, 체간 과도 측굴 관찰, 언어 피드백 제공',
  '해당 없음 (능동 운동)',
  '고관절·슬관절 굴곡 방향 (단일 하지 하강)',
  '[
    {"step":1,"instruction":"선 자세에서 한쪽 발로 서고 반대쪽 발을 살짝 들어올린다. 초기에는 한 손으로 벽이나 의자를 가볍게 짚어 균형을 보조한다. 골반이 수평을 유지하는지, 지지 무릎이 발 두 번째 발가락 방향을 향하는지 확인한다."},
    {"step":2,"instruction":"무릎을 천천히 20–30도 정도 구부리며 몸을 낮춘다. 이때 무릎이 안쪽으로 무너지거나(외반), 골반이 비지지 쪽으로 처지지(트렌델렌버그)않도록 집중한다. 체간을 약간 앞으로 기울이는 것은 허용된다."},
    {"step":3,"instruction":"낮춘 자세에서 1–2초 유지 후 천천히 처음 자세로 돌아온다. 무릎이 발 중심 방향을 유지하는지, 골반이 수평으로 돌아오는지 치료사가 관찰하며 언어 피드백을 제공한다."},
    {"step":4,"instruction":"10회 2–3세트로 시작한다. 정렬이 안정적으로 유지되면 굴곡 각도를 점진적으로 늘리고(30–45도), 지지 없는 자세로 진행한다. 이후 눈 감기, 불안정 면(밸런스 패드) 추가로 난이도를 높인다."},
    {"step":5,"instruction":"4–6주 후 단일 하지 스쿼트 시 무릎 외반 각도 변화, 균형 능력(단일 하지 서기 시간), 기능적 동작 통증 NRS를 재평가한다. 정렬 조절이 충분히 개선되면 스포츠 복귀 또는 고강도 기능 훈련으로 연결한다."}
  ]'::jsonb,
  '{"motor_control","hip_stability","functional_recovery","proprioception_training"}',
  '{"subacute","chronic"}',
  '{"hip_pain","patellofemoral_pain","knee_pain","lateral_hip_pain","sport_return"}',
  '{"fracture","joint_infection","malignancy","acute_ligament_rupture_knee"}',
  'level_2b'::evidence_level,
  '단일 하지 스쿼트는 고관절·슬관절 신경근 조절 능력을 평가하고 훈련하는 복합 운동으로, 스포츠 복귀 전 기능적 준비도 평가에 활용될 수 있다. 무릎 외반 조절 능력 향상을 통해 전방십자인대 재손상 예방에도 기여할 가능성이 있다. 초기 굴곡 각도를 작게(20–30도) 시작하여 안전한 정렬을 확보한 후 점진적으로 깊이를 늘리는 것이 적절할 수 있다.',
  'fracture, joint_infection, malignancy, acute_ligament_rupture_knee',
  'severe_knee_osteoarthritis, acute_hip_pain, severe_balance_disorder',
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
-- [7] 골반 안정화 훈련
-- category_ex_neuromuscular | body_region: hip
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
  '운동 처방 — 골반대 신경근 조절',
  '골반 안정화 훈련', 'Pelvic Stability Training', 'HIP-EX-NM-PelvStab',
  'hip'::body_region, '골반저근, 복횡근, 중둔근, 요방형근',
  '선 자세, 양발 어깨 너비, 직립 중립 자세, 벽 또는 의자로 가볍게 지지 가능(초기)',
  '환자 정면 또는 앞쪽에서 골반 수평 유지, 체간 과도 측굴, 어깨 보상 동작 관찰, 언어 피드백 제공',
  '해당 없음 (능동 운동)',
  '골반 수평 유지 방향 (단측 하지 들기)',
  '[
    {"step":1,"instruction":"선 자세에서 양발을 어깨 너비로 벌리고 직립 중립 자세를 취한다. 복부를 가볍게 활성화하고 골반이 좌우 수평을 유지하는지 확인한다. 초기에는 한 손으로 벽을 가볍게 짚어 균형 보조가 가능하다."},
    {"step":2,"instruction":"한쪽 발을 천천히 바닥에서 들어올린다. 마치 발이 진흙에서 천천히 떼어지듯 천천히 들어올려 지면 접촉을 잃는 순간 골반이 수평을 유지하도록 집중한다. 지지하는 다리의 중둔근이 수축하는 감각을 확인한다."},
    {"step":3,"instruction":"들어올린 발을 지면에서 약 5–10cm 유지하며 5–10초간 정지한다. 이때 골반이 들어올린 다리 쪽으로 처지지 않도록(트렌델렌버그 방지) 지지 다리 측 중둔근으로 골반을 수평으로 유지한다. 어깨가 한쪽으로 기울거나 체간이 옆으로 굽지 않도록 주의한다."},
    {"step":4,"instruction":"10회 양쪽 교대로 수행하여 1–2세트 완료한다. 적응되면 지지를 제거하고 눈을 감거나 불안정 면(밸런스 패드)에서 수행하는 방식으로 난이도를 높인다. 이후 한 발 서기를 유지하며 팔 동작을 추가(이중 과제)하는 방식으로 진행한다."},
    {"step":5,"instruction":"4–6주 후 단일 하지 서기 시간, 골반 수평 유지 능력(트렌델렌버그 징후), 보행 시 골반 안정성 변화를 재평가한다. 기능적 보행 훈련 또는 스포츠 복귀 프로그램으로 연결 가능한지 판단한다."}
  ]'::jsonb,
  '{"motor_control","hip_stability","proprioception_training","functional_recovery"}',
  '{"subacute","chronic"}',
  '{"hip_pain","low_back_pain_nonspecific","lateral_hip_pain","balance_disorder","sport_return"}',
  '{"fracture","joint_infection","malignancy","severe_balance_disorder_vestibular"}',
  'level_2b'::evidence_level,
  '골반 안정화 훈련은 중둔근·복횡근·요방형근의 협응 능력을 향상시킬 가능성이 있어, 요통·고관절 통증·보행 이상 재활에 활용될 수 있다. 단일 하지 서기 시 트렌델렌버그 징후가 확인되는 환자에게 우선적으로 적용을 고려할 수 있다. 어깨 보상 동작(반대측 어깨 올리기) 및 체간 측굴 보상이 흔히 나타날 수 있으므로 치료사 관찰이 필요하다.',
  'fracture, joint_infection, malignancy, severe_balance_disorder_vestibular',
  'severe_hip_osteoarthritis, acute_hip_pain, severe_peripheral_neuropathy_lower_limb',
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
  'HIP-EX-RES-GluMed',
  'HIP-EX-RES-GluMax',
  'HIP-EX-RES-Add',
  'HIP-EX-BW-Clam',
  'HIP-EX-BW-Bridge',
  'HIP-EX-NM-SLS',
  'HIP-EX-NM-PelvStab'
)
ON CONFLICT (technique_id) DO NOTHING;

COMMIT;

-- ============================================================
-- 검증 쿼리 (실행 후 확인용)
-- SELECT abbreviation, name_ko, category, evidence_level
-- FROM techniques
-- WHERE abbreviation IN (
--   'HIP-EX-RES-GluMed','HIP-EX-RES-GluMax','HIP-EX-RES-Add',
--   'HIP-EX-BW-Clam','HIP-EX-BW-Bridge',
--   'HIP-EX-NM-SLS','HIP-EX-NM-PelvStab'
-- )
-- ORDER BY abbreviation;
-- 기대값: 7개 모두 level_2b, body_region='hip'
-- ============================================================
