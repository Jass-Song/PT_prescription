-- ============================================================
-- Migration 031 — 갭 카테고리 추가 (18기법)
-- SCS 어깨(3) + SCS 무릎(3) + 신경가동술 어깨(3) + 신경가동술 발목(3) + MDT 어깨(3) + MDT 엉덩(3)
-- body_region: shoulder, knee, ankle_foot, hip
-- K-Movement Optimism / PT 처방 도우미
-- 생성일: 2026-04-28
-- 작성자: sw-db-architect
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

BEGIN;

-- ────────────────────── SCS-SH-Supra ──────────────────────
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
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS — 어깨 관절',
  '극상근 스트레인-카운터스트레인', 'Supraspinatus SCS', 'SCS-SH-Supra',
  'shoulder'::body_region, '극상근 근복',
  '앉은 자세, 치료 측 팔 몸통 옆에 이완',
  '환자 환측 뒤쪽에 서서 압통점 촉진',
  '극상근 압통점 (견봉 내측 근복부)',
  '압통점 압력 70% 감소 포지션 유지',
  '[
    {"step":1,"instruction":"엄지 또는 검지로 견봉 내측 극상근 근복부를 촉진하여 압통점을 확인하고 기준 통증 강도(VAS)를 기록한다."},
    {"step":2,"instruction":"환자 팔을 수동으로 외전 20–30°, 약간의 굴곡 및 외회전 방향으로 유도하여 압통점 통증이 70% 이상 감소하는 편안한 위치를 탐색한다."},
    {"step":3,"instruction":"편안한 위치를 유지한 채 90초간 정지한다. 치료사는 압통점에 가벼운 모니터링 압력을 유지하고 환자는 완전 이완 상태를 유지한다."},
    {"step":4,"instruction":"90초 후 팔을 매우 천천히(10초 이상) 중립 위치로 복귀시킨다. 급격한 복귀는 반사를 재활성화할 수 있으므로 피한다."},
    {"step":5,"instruction":"압통점을 재촉진하여 통증 강도 변화를 확인한다. 70% 이상 감소가 확인되면 치료 성공으로 판단하고, 필요 시 인접 압통점에 1–2회 추가 적용한다."}
  ]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","rotator_cuff_pain","overhead_difficulty"}',
  '{"fracture","joint_infection","malignancy"}',
  'level_4'::evidence_level,
  '극상근 압통점에 70% 이상 통증 감소가 확인되는 체위를 찾아 90초 유지하는 방식으로 적용 가능성이 있다. 회전근개 병증 초기 통증 조절에 활용될 수 있으며, 급성기 침범에도 적용 가능성이 있다.',
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

-- ────────────────────── SCS-SH-Infra ──────────────────────
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
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS — 어깨 관절',
  '극하근 스트레인-카운터스트레인', 'Infraspinatus SCS', 'SCS-SH-Infra',
  'shoulder'::body_region, '극하근 근복',
  '엎드려 눕기, 치료 측 팔 옆에 이완',
  '환자 환측에 서서 견갑골 후방 극하와 압통점 촉진',
  '극하근 압통점 (견갑극 하방 근복)',
  '외회전·신전 방향 단축 포지션',
  '[
    {"step":1,"instruction":"엎드려 눕기 자세에서 견갑골 극하와 중앙부를 촉진하여 극하근 압통점을 확인하고 기준 통증 강도를 기록한다."},
    {"step":2,"instruction":"환자 팔을 수동으로 외회전하고 약간 신전하여 극하와의 압통점 통증이 70% 이상 감소하는 편안한 위치를 탐색한다. 어깨 높이 미세 조정으로 최적 포지션을 찾는다."},
    {"step":3,"instruction":"편안한 위치에서 90초간 정지하며 치료사는 압통점에 가벼운 모니터링 압력을 유지한다. 환자는 완전 이완 상태를 유지한다."},
    {"step":4,"instruction":"90초 후 팔을 매우 천천히 중립 위치로 복귀시킨다."},
    {"step":5,"instruction":"압통점을 재촉진하여 통증 감소를 확인하고, 외회전 ROM과 후방 어깨 통증 변화를 재평가한다."}
  ]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","external_rotation_restriction","posterior_shoulder_pain"}',
  '{"fracture","joint_infection","malignancy"}',
  'level_4'::evidence_level,
  '극하근 압통점에 70% 통증 감소 포지션을 외회전·신전 방향에서 찾아 90초 유지할 수 있다. 후방 어깨 통증 및 외회전 제한이 있는 경우 적용 가능성이 있다.',
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

-- ────────────────────── SCS-SH-Sub ──────────────────────
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
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS — 어깨 관절',
  '견갑하근 스트레인-카운터스트레인', 'Subscapularis SCS', 'SCS-SH-Sub',
  'shoulder'::body_region, '견갑하근 근복',
  '바로 눕기, 치료 측 팔 외전 약 45도',
  '환자 환측에 서서 겨드랑이 전벽 내측면 압통점 촉진',
  '견갑하근 압통점 (겨드랑이 전벽 내측)',
  '내회전·굴곡 방향 단축 포지션',
  '[
    {"step":1,"instruction":"바로 눕기 자세에서 겨드랑이 내측벽을 통해 견갑골 전면에 접근하여 견갑하근 압통점을 촉진하고 기준 통증을 확인한다."},
    {"step":2,"instruction":"팔을 내회전·내전 방향으로 유도하며 팔꿈치를 굽혀 몸통 쪽으로 가볍게 당겨 견갑하근이 단축되는 편안한 위치를 탐색한다."},
    {"step":3,"instruction":"편안한 위치에서 90초간 정지한다. 치료사는 압통점 모니터링을 유지하며 환자는 완전 이완한다."},
    {"step":4,"instruction":"90초 후 팔을 매우 천천히 중립 위치로 복귀시킨다."},
    {"step":5,"instruction":"압통점을 재촉진하여 통증 감소를 확인하고, 내회전 ROM 및 어깨 전방 통증을 재평가한다."}
  ]'::jsonb,
  '{"pain_relief","trigger_point_release","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","internal_rotation_restriction","frozen_shoulder"}',
  '{"fracture","joint_infection","malignancy"}',
  'level_4'::evidence_level,
  '견갑하근 압통점에서 내회전·굴곡 방향으로 70% 통증 감소 포지션을 찾아 90초 유지할 수 있다. 유착성 관절낭염(오십견) 초기 통증 조절에 활용 가능성이 있다.',
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

-- ────────────────────── SCS-KN-RF ──────────────────────
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
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS — 무릎 관절',
  '대퇴직근 스트레인-카운터스트레인', 'Rectus Femoris SCS', 'SCS-KN-RF',
  'knee'::body_region, '대퇴직근 근복·원위부',
  '바로 눕기, 무릎 약간 굽힘',
  '환자 옆에 서서 대퇴 전면 원위부 압통점 촉진',
  '대퇴직근 압통점 (대퇴 전면 원위 1/3)',
  '고관절 굴곡·무릎 굴곡 단축 포지션',
  '[
    {"step":1,"instruction":"바로 눕기 자세에서 대퇴 전면 원위 1/3 또는 슬개골 상방 대퇴직근 근복에서 압통점을 촉진하고 기준 통증을 확인한다."},
    {"step":2,"instruction":"고관절을 가볍게 굴곡하고 무릎도 굴곡 방향으로 유도하여 대퇴직근이 단축되는 편안한 위치를 찾는다. 베개 등으로 고관절 굴곡을 지지한다."},
    {"step":3,"instruction":"편안한 위치에서 90초간 유지하며 압통점을 모니터링한다. 환자는 완전 이완한다."},
    {"step":4,"instruction":"90초 후 고관절과 무릎을 매우 천천히 중립 위치로 복귀시킨다."},
    {"step":5,"instruction":"압통점을 재촉진하여 통증 감소를 확인하고, 무릎 굴곡 ROM 및 전방 무릎 통증을 재평가한다."}
  ]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"knee_pain","anterior_knee_pain","patellofemoral_pain"}',
  '{"fracture","joint_infection","malignancy"}',
  'level_4'::evidence_level,
  '대퇴직근 원위부 압통점에서 고관절 굴곡·무릎 굴곡 포지션으로 70% 통증 감소를 찾아 90초 유지할 수 있다. 전방 무릎 통증 및 슬개대퇴 통증증후군에 적용 가능성이 있다.',
  'fracture, joint_infection, malignancy',
  'acute_inflammation, DVT',
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

-- ────────────────────── SCS-KN-Poplit ──────────────────────
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
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS — 무릎 관절',
  '슬와근 스트레인-카운터스트레인', 'Popliteus SCS', 'SCS-KN-Poplit',
  'knee'::body_region, '슬와근',
  '엎드려 눕기, 무릎 약 30도 굽힘',
  '환자 발목 옆에 서서 슬와부 외측 압통점 촉진',
  '슬와근 압통점 (슬와부 외측 상방)',
  '무릎 굴곡·내회전 단축 포지션',
  '[
    {"step":1,"instruction":"엎드려 눕기 자세에서 슬와 외측 하방(비골두 내측 하방) 또는 경골 후면 내측 상부에서 슬와근 압통점을 촉진하고 기준 통증을 확인한다."},
    {"step":2,"instruction":"무릎을 30–40° 굴곡하고 경골을 약간 내회전하여 슬와근이 단축되는 편안한 위치를 찾는다. 발을 안쪽으로 약간 돌리는 것이 도움이 될 수 있다."},
    {"step":3,"instruction":"편안한 위치에서 90초간 유지하며 압통점을 모니터링한다."},
    {"step":4,"instruction":"90초 후 무릎과 경골을 매우 천천히 중립 위치로 복귀시킨다."},
    {"step":5,"instruction":"압통점을 재촉진하여 통증 감소를 확인하고, 무릎 완전 신전 시 후방 통증 변화를 재평가한다."}
  ]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"posterior_knee_pain","knee_flexion_restriction","knee_locking"}',
  '{"fracture","joint_infection","malignancy","DVT"}',
  'level_4'::evidence_level,
  '슬와근 압통점에서 무릎 굴곡·경골 내회전 방향으로 70% 통증 감소 포지션을 찾아 90초 유지할 수 있다. 후방 무릎 통증 및 무릎 잠김 증상에 적용 가능성이 있다.',
  'fracture, joint_infection, malignancy, DVT',
  'acute_inflammation, posterior_capsule_injury',
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

-- ────────────────────── SCS-KN-GastMed ──────────────────────
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
  'category_scs',
  (SELECT id FROM technique_categories WHERE category_key = 'category_scs'),
  'SCS — 무릎 관절',
  '내측 비복근 스트레인-카운터스트레인', 'Medial Gastrocnemius SCS', 'SCS-KN-GastMed',
  'knee'::body_region, '내측 비복근 근복',
  '엎드려 눕기, 발목 이완',
  '환자 발쪽에서 내측 비복근 근복 압통점 촉진',
  '내측 비복근 압통점 (슬와부 내하방)',
  '무릎 굴곡·족저굴곡 단축 포지션',
  '[
    {"step":1,"instruction":"엎드려 눕기 자세에서 슬와부 내하방 내측 비복근 근복에서 압통점을 촉진하고 기준 통증 강도를 기록한다."},
    {"step":2,"instruction":"무릎을 굴곡하고 발목을 족저굴곡하여 내측 비복근이 단축되는 편안한 위치를 탐색한다. 치료사는 발목을 받쳐 포지션을 안정적으로 유지한다."},
    {"step":3,"instruction":"편안한 위치에서 90초간 유지하며 압통점을 모니터링한다. 환자는 완전 이완한다."},
    {"step":4,"instruction":"90초 후 무릎과 발목을 매우 천천히 중립 위치로 복귀시킨다."},
    {"step":5,"instruction":"압통점을 재촉진하여 통증 감소를 확인하고, 슬와부 통증 및 종아리 긴장 변화를 재평가한다."}
  ]'::jsonb,
  '{"pain_relief","trigger_point_release"}',
  '{"subacute","chronic"}',
  '{"posterior_knee_pain","calf_pain","knee_flexion_restriction"}',
  '{"fracture","joint_infection","DVT"}',
  'level_4'::evidence_level,
  '내측 비복근 압통점에서 무릎 굴곡·족저굴곡 포지션으로 70% 통증 감소를 찾아 90초 유지할 수 있다. 슬와부 통증 및 종아리 경련과 연관된 무릎 후방 통증에 적용 가능성이 있다.',
  'fracture, joint_infection, DVT',
  'acute_inflammation, severe_varicose_veins',
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

-- ────────────────────── NEU-SH-Median ──────────────────────
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
  '신경가동술 — 어깨 관절',
  '정중신경 가동술 어깨', 'Median Nerve Neurodynamic Mobilization — Shoulder', 'NEU-SH-Median',
  'shoulder'::body_region, '정중신경 (C5–T1 nerve roots)',
  '바로 눕기, 팔 몸통 옆에 이완',
  '환자 환측에 서서 손목·팔꿈치·어깨 순서로 신경 긴장 유도',
  '손목 신전, 전완 회외, 팔꿈치 신전, 어깨 외전·외회전',
  '정중신경 긴장 순서: 손목 신전 → 전완 회외 → 팔꿈치 신전 → 어깨 외전 → 외회전 → 경추 반대측 측굴',
  '[
    {"step":1,"instruction":"바로 눕기 자세에서 치료사는 환측 손목을 신전하고 전완을 회외한 상태로 가볍게 유지한다. 증상 발생 여부를 확인한다."},
    {"step":2,"instruction":"팔꿈치를 서서히 신전하면서 어깨를 외전 90° 방향으로 유도한다. 각 단계에서 증상(저림, 통증, 긴장감) 변화를 관찰한다."},
    {"step":3,"instruction":"어깨 외회전을 추가하고 마지막으로 경추를 반대측으로 측굴하여 정중신경(ULNT1) 긴장 검사 포지션을 완성한다. 증상 재현 여부를 확인한다."},
    {"step":4,"instruction":"Grade I–II 슬라이딩 기법 적용: 팔꿈치 굴곡·신전을 반복하거나 손목 신전·굴곡을 반복하며 신경을 부드럽게 슬라이딩한다. 10–15회 반복."},
    {"step":5,"instruction":"치료 후 증상 변화를 재평가한다. 증상 감소 시 Grade를 점진적으로 높이고, 증상 악화 시 즉시 중단하고 강도를 낮춘다."}
  ]'::jsonb,
  '{"neurodynamic_mobilization","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","arm_numbness","cervicobrachial_pain","carpal_tunnel"}',
  '{"nerve_root_compression_with_neurological_deficit","fracture","malignancy"}',
  'level_2b'::evidence_level,
  '정중신경 긴장 검사(ULNT1) 양성 소견 시 적용 가능성이 있다. Grade I–II 슬라이딩 기법으로 시작하여 증상 변화를 관찰하면서 Grade를 조정할 수 있다. 목·어깨·팔로 이어지는 신경성 통증 및 감각 이상에 적용 가능성이 있다.',
  'nerve_root_compression_with_neurological_deficit, fracture, malignancy',
  'acute_inflammation, severe_radiculopathy, anticoagulant_therapy',
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

-- ────────────────────── NEU-SH-Radial ──────────────────────
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
  '신경가동술 — 어깨 관절',
  '요골신경 가동술 어깨', 'Radial Nerve Neurodynamic Mobilization — Shoulder', 'NEU-SH-Radial',
  'shoulder'::body_region, '요골신경 (C5–C8 nerve roots)',
  '바로 눕기, 팔 몸통 옆에 이완',
  '환자 환측에 서서 어깨 내회전·내전, 팔꿈치 신전, 손목 굴곡 순서로 긴장 유도',
  '어깨 내회전·내전, 팔꿈치 신전, 손목·손가락 굴곡, 전완 회내',
  '요골신경 긴장 순서: 어깨 내회전·내전 → 팔꿈치 신전 → 전완 회내 → 손목 굴곡 → 경추 반대측 측굴',
  '[
    {"step":1,"instruction":"바로 눕기 자세에서 치료사는 환측 어깨를 내회전하고 내전 방향으로 가볍게 유도한다. 증상 발생 여부를 확인한다."},
    {"step":2,"instruction":"팔꿈치를 서서히 신전하면서 전완을 회내 방향으로 유도한다. 각 단계에서 증상 변화를 관찰한다."},
    {"step":3,"instruction":"손목과 손가락을 굴곡하고 마지막으로 경추를 반대측으로 측굴하여 요골신경(ULNT2b) 긴장 검사 포지션을 완성한다. 증상 재현 여부를 확인한다."},
    {"step":4,"instruction":"Grade I–II 슬라이딩 기법 적용: 손목 굴곡·신전을 반복하거나 팔꿈치 굴곡·신전을 반복하며 요골신경을 부드럽게 슬라이딩한다. 10–15회 반복."},
    {"step":5,"instruction":"치료 후 증상 변화를 재평가한다. 외측 팔꿈치 통증과 후방 팔 감각 이상 변화를 확인하고, 증상 악화 시 즉시 강도를 낮춘다."}
  ]'::jsonb,
  '{"neurodynamic_mobilization","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"lateral_elbow_pain","shoulder_pain","posterior_arm_pain","radial_nerve_entrapment"}',
  '{"nerve_root_compression_with_neurological_deficit","fracture","malignancy"}',
  'level_2b'::evidence_level,
  '요골신경 긴장 검사(ULNT2b) 양성 소견 시 적용 가능성이 있다. 외측 팔꿈치 통증(테니스엘보우 감별)이나 후방 팔·어깨 통증과 감각 이상에 활용될 수 있다.',
  'nerve_root_compression_with_neurological_deficit, fracture, malignancy',
  'acute_inflammation, severe_radiculopathy',
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

-- ────────────────────── NEU-SH-Ulnar ──────────────────────
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
  '신경가동술 — 어깨 관절',
  '척골신경 가동술 어깨', 'Ulnar Nerve Neurodynamic Mobilization — Shoulder', 'NEU-SH-Ulnar',
  'shoulder'::body_region, '척골신경 (C8–T1 nerve roots)',
  '바로 눕기, 팔 몸통 옆에 이완',
  '환자 환측에 서서 손목 신전, 팔꿈치 굴곡, 어깨 외전·외회전 순서로 긴장 유도',
  '손목 신전·요측편위, 팔꿈치 굴곡, 어깨 외전·외회전',
  '척골신경 긴장 순서: 손목 신전 → 팔꿈치 굴곡 → 어깨 외전 → 외회전 → 경추 반대측 측굴',
  '[
    {"step":1,"instruction":"바로 눕기 자세에서 치료사는 환측 손목을 신전하고 요측편위 방향으로 가볍게 유지한다. 증상 발생 여부를 확인한다."},
    {"step":2,"instruction":"팔꿈치를 서서히 굴곡하면서 어깨를 외전 방향으로 유도한다. 각 단계에서 증상 변화를 관찰한다."},
    {"step":3,"instruction":"어깨 외회전을 추가하고 마지막으로 경추를 반대측으로 측굴하여 척골신경(ULNT3) 긴장 검사 포지션을 완성한다. 약지·소지 저림 등 증상 재현 여부를 확인한다."},
    {"step":4,"instruction":"Grade I–II 슬라이딩 기법 적용: 팔꿈치 굴곡·신전을 반복하거나 손목 신전·굴곡을 반복하며 척골신경을 부드럽게 슬라이딩한다. 10–15회 반복."},
    {"step":5,"instruction":"치료 후 증상 변화를 재평가한다. 내측 팔꿈치 통증 및 약지·소지 감각 이상 변화를 확인하고, 증상 악화 시 즉시 강도를 낮춘다."}
  ]'::jsonb,
  '{"neurodynamic_mobilization","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"medial_elbow_pain","shoulder_pain","ulnar_nerve_entrapment","ring_little_finger_numbness"}',
  '{"nerve_root_compression_with_neurological_deficit","fracture","malignancy"}',
  'level_2b'::evidence_level,
  '척골신경 긴장 검사(ULNT3) 양성 소견 시 적용 가능성이 있다. 내측 팔꿈치 통증 및 약지·소지 감각 이상과 연관된 어깨-팔 신경성 증상에 활용될 수 있다.',
  'nerve_root_compression_with_neurological_deficit, fracture, malignancy',
  'acute_inflammation, severe_cubital_tunnel_syndrome',
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
-- Migration 031 (Part 2): 갭 카테고리 — 신경가동술 발목(3) + MDT 어깨(3) + MDT 엉덩(3)
-- body_region: ankle_foot, shoulder, hip
-- sw-db-architect | 2026-04-28

-- ============================================================
-- SECTION 4 — category_d_neural (신경가동술)
-- body_region: ankle_foot | evidence_level: level_2b
-- ============================================================

-- ────────────────────── NEU-ANK-Sural ──────────────────────
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
  '신경가동술 — 발목 관절',
  '비복신경 가동술 발목', 'Sural Nerve Neurodynamic Mobilization — Ankle', 'NEU-ANK-Sural',
  'ankle_foot'::body_region, '비복신경 (S1–S2 nerve roots)',
  '옆으로 눕기(환측 위), 무릎 약간 굽힘',
  '환자 발쪽에 위치, 발목 내번·족저굴곡으로 신경 긴장 유도',
  '발목 내번·족저굴곡, 무릎 신전',
  '비복신경 긴장 순서: 무릎 신전 → 발목 배측굴곡 → 내번 → 고관절 굴곡',
  '[
    {"step":1,"instruction":"환자를 환측이 위로 향하는 옆으로 눕기 자세로 위치시킨다. 아래 다리는 편안하게 굽히고, 위 다리(환측)는 무릎을 약간 굽힌 채 이완시킨다. 치료사는 환자 발쪽에 위치하여 발목과 무릎에 접촉 준비를 한다."},
    {"step":2,"instruction":"한 손으로 환자의 발꿈치와 발목을 잡고, 무릎을 서서히 신전시켜 슬와부(오금)에 긴장감이 느껴지는 지점까지 유도한다. 이 상태에서 발목을 배측굴곡(등굽히기) 방향으로 부드럽게 추가하여 신경 긴장을 형성한다."},
    {"step":3,"instruction":"발목 내번(안쪽 방향으로 뒤집기)을 천천히 추가하여 비복신경 경로(발목 외측 및 발 외측)에 긴장이 증가하는지 확인한다. 환자에게 외측 발목 또는 발 외측으로의 당김감·감각 이상이 유발되는지 확인한다."},
    {"step":4,"instruction":"신경 긴장이 형성된 상태에서 발목을 배측굴곡과 족저굴곡 사이에서 리듬감 있게 반복 가동(슬라이더 기법)하거나, 긴장을 추가·해제하는 방식으로 신경 가동을 실시한다. 통증이 아닌 ''당김감'' 수준에서 조절한다."},
    {"step":5,"instruction":"10–15회 반복 후 발목 외측 감각 이상 변화 및 통증 강도 변화를 재평가한다. 신경 증상이 악화되면 즉시 긴장을 해제하고 시술을 중단한다. 증상 경감이 확인되면 홈 프로그램으로 슬라이더 기법을 교육한다."}
  ]'::jsonb,
  '{"neurodynamic_mobilization","pain_relief"}',
  '{"subacute","chronic"}',
  '{"lateral_ankle_pain","lateral_foot_numbness","sural_nerve_entrapment","chronic_ankle_sprain"}',
  '{"nerve_root_compression_with_neurological_deficit","fracture","malignancy"}',
  'level_2b'::evidence_level,
  '외측 발목 및 발 외측 감각 이상이 있을 때 비복신경 긴장 검사 후 양성 소견 시 적용 가능성이 있다. 만성 발목 불안정성 또는 반복 염좌 후 신경성 통증에 활용될 수 있다.',
  'nerve_root_compression_with_neurological_deficit, fracture, malignancy',
  'acute_ankle_sprain, DVT, severe_peripheral_neuropathy',
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

-- ────────────────────── NEU-ANK-TibPost ──────────────────────
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
  '신경가동술 — 발목 관절',
  '후경골신경 가동술 발목', 'Posterior Tibial Nerve Neurodynamic Mobilization — Ankle', 'NEU-ANK-TibPost',
  'ankle_foot'::body_region, '후경골신경 (L4–S3 nerve roots)',
  '바로 눕기, 무릎 신전',
  '환자 발쪽에 위치, 발목 배측굴곡·외번으로 신경 긴장 유도',
  '발목 배측굴곡·외번, 고관절 굴곡·외회전',
  '후경골신경 긴장 순서: 발목 배측굴곡 → 외번 → 무릎 신전 → 고관절 굴곡',
  '[
    {"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 환측 다리를 무릎 신전 상태로 이완시킨다. 치료사는 환자 발쪽에 서서 한 손으로 발꿈치를 잡고 다른 손으로 발등을 가볍게 지지한다."},
    {"step":2,"instruction":"발목을 배측굴곡(등굽히기) 방향으로 서서히 유도하고, 동시에 발을 외번(바깥쪽으로 돌리기) 방향으로 추가하여 내측 발목 아래(족근관 부위)와 발바닥 경로에 긴장을 형성한다."},
    {"step":3,"instruction":"발목 긴장이 형성된 상태에서 고관절을 굴곡·외회전 방향으로 추가하여 후경골신경 전체 경로에 긴장을 증폭시킨다. 환자에게 발바닥·발꿈치·내측 발목 부위의 당김감이나 감각 변화가 유발되는지 확인한다."},
    {"step":4,"instruction":"신경 긴장이 확인된 상태에서 발목 배측굴곡·족저굴곡 사이에서 리듬감 있게 슬라이더 방식으로 가동하거나, 고관절 굴곡 추가·해제 방식으로 텐셔너 기법을 적용한다. 통증이 아닌 당김감 수준에서 조절한다."},
    {"step":5,"instruction":"10–15회 반복 후 발바닥 감각 이상 변화, 족저 통증 강도, 발꿈치 통증 변화를 재평가한다. 신경 증상 악화 시 즉시 중단하고 텐션을 해제한다. 자가 관리를 위해 앉은 자세에서의 슬라이더 기법을 교육한다."}
  ]'::jsonb,
  '{"neurodynamic_mobilization","pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"plantar_heel_pain","tarsal_tunnel_syndrome","plantar_numbness","medial_ankle_pain"}',
  '{"nerve_root_compression_with_neurological_deficit","fracture","malignancy"}',
  'level_2b'::evidence_level,
  '족저 감각 이상 및 발꿈치 통증이 신경성으로 의심될 때 적용 가능성이 있다. 족근관증후군(tarsal tunnel syndrome) 감별 및 보존 치료에 활용될 수 있다. 족저근막염과 감별이 필요할 수 있다.',
  'nerve_root_compression_with_neurological_deficit, fracture, malignancy',
  'acute_inflammation, DVT, severe_peripheral_neuropathy',
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

-- ────────────────────── NEU-ANK-Peron ──────────────────────
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
  '신경가동술 — 발목 관절',
  '비골신경 가동술 발목', 'Peroneal Nerve Neurodynamic Mobilization — Ankle', 'NEU-ANK-Peron',
  'ankle_foot'::body_region, '비골신경 (L4–S2 nerve roots)',
  '옆으로 눕기(환측 아래), 무릎 약간 굽힘',
  '환자 발쪽에 위치, 발목 족저굴곡·내번으로 신경 긴장 유도',
  '발목 족저굴곡·내번, 무릎 굴곡',
  '비골신경 긴장 순서: 발목 족저굴곡 → 내번 → 무릎 굴곡 → 고관절 내회전',
  '[
    {"step":1,"instruction":"환자를 환측이 아래를 향하는 옆으로 눕기 자세로 위치시킨다. 위 다리(비환측)는 구부려 안정적으로 지지하고, 아래 다리(환측)는 무릎을 약간 굽힌 채 이완시킨다. 치료사는 환자 발쪽에 위치한다."},
    {"step":2,"instruction":"한 손으로 환자의 발꿈치를 잡고 발을 족저굴곡(발목을 발바닥 방향으로 굽히기) 방향으로 서서히 유도한다. 동시에 발을 내번(안쪽으로 뒤집기) 방향으로 추가하여 비골두(종아리 바깥 위쪽) 주변 및 전외측 하퇴부에 긴장이 유도되는지 확인한다."},
    {"step":3,"instruction":"발목 긴장이 형성된 상태에서 무릎을 굴곡 방향으로 추가하여 비골신경 경로를 따라 긴장을 증폭시킨다. 환자에게 발 외측·전외측 하퇴·비골두 주변으로 당김감이나 감각 이상이 유발되는지 확인한다."},
    {"step":4,"instruction":"신경 긴장이 확인된 상태에서 발목 족저굴곡·내번의 추가·해제 또는 무릎 굴곡·신전 반복으로 슬라이더 기법을 적용한다. 발 처짐(foot drop) 위험 요인이 있는 환자는 긴장 강도를 더욱 신중하게 조절한다."},
    {"step":5,"instruction":"10–15회 반복 후 전외측 하퇴 및 발 외측 감각 이상 변화와 통증 강도를 재평가한다. 신경 증상 악화 또는 근력 약화 징후 시 즉시 중단한다. 증상 경감이 확인되면 앉은 자세 또는 서 있는 자세에서의 자가 슬라이더 기법을 교육한다."}
  ]'::jsonb,
  '{"neurodynamic_mobilization","pain_relief"}',
  '{"subacute","chronic"}',
  '{"lateral_leg_pain","foot_drop_risk","anterior_ankle_pain","peroneal_nerve_entrapment"}',
  '{"nerve_root_compression_with_foot_drop","fracture","malignancy"}',
  'level_2b'::evidence_level,
  '발 외측·전방 감각 이상이 있거나 비골두 주변 압통이 있을 때 적용 가능성이 있다. 발목 내번 염좌 후 비골신경 포착이 의심되는 경우에 활용될 수 있다.',
  'nerve_root_compression_with_foot_drop, fracture, malignancy',
  'acute_inflammation, DVT, fibular_head_fracture',
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
-- SECTION 5 — category_mdt (맥켄지 방법)
-- body_region: shoulder | evidence_level: level_2b
-- ============================================================

-- ────────────────────── MDT-SH-RetExt ──────────────────────
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
  'MDT — 어깨 관절',
  '어깨 후인·신전 반복 운동', 'Shoulder Retraction-Extension Repeated Movement — MDT', 'MDT-SH-RetExt',
  'shoulder'::body_region, '견갑흉곽관절·GHJ 전방 구조물',
  '앉은 자세, 양손을 허리 뒤에 가볍게 깍지',
  '환자 옆에서 동작 가이드 및 반응 관찰',
  '어깨 후인·하강 방향 능동 운동',
  '견갑골 후인·하강 + 어깨 신전 반복',
  '[
    {"step":1,"instruction":"환자를 앉은 자세로 위치시키고 양손을 허리 뒤에 가볍게 깍지 끼우도록 안내한다. 치료사는 환자 옆에 서서 자세와 동작을 관찰할 준비를 한다."},
    {"step":2,"instruction":"환자에게 가슴을 펴고 어깨를 뒤로 당기면서(후인) 동시에 아래로 내리는(하강) 동작을 천천히 실시하도록 안내한다. 동작 끝 범위에서 1–2초 유지 후 이완하는 방식으로 10회 반복한다."},
    {"step":3,"instruction":"10회 반복 후 어깨 전방 통증 또는 팔 저림 증상이 감소하였는지(집중화 반응), 증가하였는지(말초화 반응) 환자에게 확인한다. 통증이 어깨 또는 척추 쪽으로 집중되거나 감소하면 방향성 선호로 판단한다."},
    {"step":4,"instruction":"방향성 선호가 확인되면 동일 방향으로 추가 10회 반복하고, 과압(overpressure)이 필요하면 치료사가 양 견갑골을 가볍게 모아주는 방향으로 보조 압력을 적용한다. 말초화가 발생하면 즉시 운동을 중단한다."},
    {"step":5,"instruction":"세션 후 어깨 전방 통증, 팔 거상 범위, 일상 동작 능력 변화를 재평가한다. 방향성 선호가 확인된 경우 홈 프로그램으로 동일 운동을 1–2시간마다 10회씩 자가 실시하도록 교육한다."}
  ]'::jsonb,
  '{"pain_relief","rom_improvement","directional_preference"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","anterior_shoulder_pain","overhead_difficulty","scapular_dyskinesis"}',
  '{"fracture","joint_infection","malignancy","acute_rotator_cuff_tear"}',
  'level_2b'::evidence_level,
  '전방 어깨 통증 또는 견갑골 운동이상이 있을 때 후인·신전 방향으로 통증 감소(방향성 선호) 반응을 확인 후 적용 가능성이 있다. 10회 반복 후 증상 변화를 평가하여 방향성 선호가 확인되면 홈 프로그램으로 연결할 수 있다.',
  'fracture, joint_infection, malignancy, acute_rotator_cuff_tear',
  'acute_inflammation, severe_instability',
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

-- ────────────────────── MDT-SH-ER ──────────────────────
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
  'MDT — 어깨 관절',
  '어깨 외회전 반복 운동', 'Shoulder External Rotation Repeated Movement — MDT', 'MDT-SH-ER',
  'shoulder'::body_region, 'GHJ 전방 관절낭·내회전근',
  '앉은 자세, 팔꿈치 90도 굽힘, 몸통 옆에 붙임',
  '환자 옆에서 동작 가이드 및 반응 관찰',
  '팔꿈치 고정, 전완 외회전 방향 반복 운동',
  '어깨 외회전 반복 (팔꿈치 고정, 전완 외측으로)',
  '[
    {"step":1,"instruction":"환자를 앉은 자세로 위치시키고 환측 팔꿈치를 90도 굽혀 몸통 옆에 가볍게 붙이도록 안내한다. 이 자세에서 전완이 정면을 향하도록 하고, 치료사는 환자 옆에서 동작을 관찰한다."},
    {"step":2,"instruction":"환자에게 팔꿈치를 몸통에 고정한 채 전완을 외측(바깥쪽)으로 돌리는 외회전 동작을 천천히 실시하도록 안내한다. 가능한 끝 범위까지 이동한 후 1–2초 유지하고 시작 위치로 돌아오는 방식으로 10회 반복한다."},
    {"step":3,"instruction":"10회 반복 후 어깨 통증 또는 팔꿈치 내측 통증이 감소하였는지(집중화), 증가하였는지(말초화) 환자에게 확인한다. 외회전 ROM 변화도 함께 평가한다."},
    {"step":4,"instruction":"방향성 선호가 확인되면 동일 방향으로 추가 10회 반복한다. 필요 시 치료사가 환측 팔꿈치를 가볍게 고정하여 안정성을 높이거나, 끝 범위에서 가벼운 과압을 적용한다. 말초화가 발생하면 즉시 중단한다."},
    {"step":5,"instruction":"세션 후 어깨 외회전 ROM, 내회전 제한 증상, 일상 동작(머리 빗기, 등 긁기 등) 변화를 재평가한다. 방향성 선호가 확인된 경우 홈 프로그램으로 동일 운동을 자가 실시하도록 교육한다."}
  ]'::jsonb,
  '{"pain_relief","rom_improvement","directional_preference"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","internal_rotation_restriction","frozen_shoulder","rotator_cuff_pain"}',
  '{"fracture","joint_infection","malignancy","anterior_instability"}',
  'level_2b'::evidence_level,
  '어깨 내회전 제한 또는 후방 관절낭 단축이 의심될 때 외회전 방향성 선호 반응을 확인 후 적용 가능성이 있다. 유착성 관절낭염 아급성기에 자가 운동 프로그램으로 활용될 수 있다.',
  'fracture, joint_infection, malignancy, anterior_instability',
  'acute_inflammation, severe_anterior_laxity',
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

-- ────────────────────── MDT-SH-Flex ──────────────────────
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
  'MDT — 어깨 관절',
  '어깨 굴곡 반복 운동', 'Shoulder Flexion Repeated Movement — MDT', 'MDT-SH-Flex',
  'shoulder'::body_region, 'GHJ 하방 관절낭·회전근개',
  '바로 눕기, 팔 몸통 옆에 이완',
  '환자 옆에서 동작 가이드 및 반응 관찰',
  '어깨 굴곡 방향 능동 반복 운동 (중력 제거 자세)',
  '어깨 굴곡 반복 (천장 방향으로 팔 들어올리기)',
  '[
    {"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 환측 팔을 몸통 옆에 자연스럽게 이완시킨다. 이 자세는 중력이 최소화된 상태이므로 심한 굴곡 제한이 있는 환자에게 초기 적용에 유리하다. 치료사는 환자 옆에서 관찰한다."},
    {"step":2,"instruction":"환자에게 팔을 천장 방향으로 천천히 들어올리는 어깨 굴곡 동작을 가능한 범위까지 실시하도록 안내한다. 끝 범위에서 1–2초 유지 후 천천히 내리는 방식으로 10회 반복한다."},
    {"step":3,"instruction":"10회 반복 후 어깨 통증 위치 변화(집중화 또는 말초화)와 굴곡 가동 범위 변화를 확인한다. 통증이 어깨 근위부로 집중되거나 감소하면 방향성 선호로 판단한다."},
    {"step":4,"instruction":"방향성 선호가 확인되면 동일 방향으로 추가 10회 반복한다. 바로 눕기 자세에서 충분한 ROM 개선이 확인되면 앉은 자세 또는 선 자세로 진행하며 중력 부하를 추가한다. 말초화가 발생하면 즉시 중단한다."},
    {"step":5,"instruction":"세션 후 어깨 굴곡 ROM, 일상 동작(선반 위 물건 집기, 머리 위 동작) 수행 능력 변화를 재평가한다. 방향성 선호가 확인된 경우 앉은 자세 또는 선 자세에서의 굴곡 반복 운동을 홈 프로그램으로 교육한다."}
  ]'::jsonb,
  '{"pain_relief","rom_improvement","directional_preference"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","flexion_restriction","overhead_difficulty","adhesive_capsulitis"}',
  '{"fracture","joint_infection","malignancy","acute_rotator_cuff_tear"}',
  'level_2b'::evidence_level,
  '어깨 굴곡 방향으로 통증 감소 반응이 확인될 때 적용 가능성이 있다. 유착성 관절낭염 아급성기 또는 굴곡 제한이 주 증상인 경우 자가 운동 프로그램으로 연결할 수 있다.',
  'fracture, joint_infection, malignancy, acute_rotator_cuff_tear',
  'acute_inflammation, severe_impingement',
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
-- SECTION 6 — category_mdt (맥켄지 방법)
-- body_region: hip | evidence_level: level_2b
-- ============================================================

-- ────────────────────── MDT-HIP-Ext ──────────────────────
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
  'MDT — 엉덩 관절',
  '고관절 신전 반복 운동', 'Hip Extension Repeated Movement — MDT', 'MDT-HIP-Ext',
  'hip'::body_region, 'GHJ 전방 관절낭·장요근',
  '엎드려 눕기, 양 팔 몸통 옆에 이완',
  '환자 옆에서 동작 가이드 및 반응 관찰',
  '고관절 신전 방향 능동 반복 운동',
  '고관절 신전 반복 (무릎 신전 유지하며 다리 들어올리기)',
  '[
    {"step":1,"instruction":"환자를 엎드려 눕기 자세로 위치시키고 양 팔을 몸통 옆에 자연스럽게 이완시킨다. 베개 또는 수건을 배 아래 받쳐 요추 과전만 또는 골반 전방 경사를 줄이면 편안한 시작 자세를 만들 수 있다."},
    {"step":2,"instruction":"환자에게 환측 다리를 무릎을 편 채로 천천히 테이블에서 들어올리는 고관절 신전 동작을 실시하도록 안내한다. 가능한 끝 범위까지 이동한 후 1–2초 유지하고 천천히 내리는 방식으로 10회 반복한다."},
    {"step":3,"instruction":"10회 반복 후 서혜부(샅 부위) 또는 전방 고관절 통증이 감소하였는지(집중화), 증가하였는지(말초화) 확인한다. 고관절 굴곡 구축이 의심되는 경우 엎드린 자세의 불편함 자체도 함께 평가한다."},
    {"step":4,"instruction":"방향성 선호가 확인되면 동일 방향으로 추가 10회 반복한다. 엎드린 자세에서 증상 개선이 뚜렷하면 선 자세에서의 고관절 신전 반복 운동(한 발 서기 또는 런지 등)으로 진행하여 중력 부하를 추가한다. 말초화 발생 시 즉시 중단한다."},
    {"step":5,"instruction":"세션 후 고관절 신전 ROM, 전방 고관절 통증, 보행 시 통증 변화를 재평가한다. 방향성 선호가 확인된 경우 엎드린 자세 또는 선 자세에서의 신전 반복 운동을 홈 프로그램으로 교육한다."}
  ]'::jsonb,
  '{"pain_relief","rom_improvement","directional_preference"}',
  '{"subacute","chronic"}',
  '{"hip_pain","anterior_hip_pain","hip_flexion_contracture","groin_pain"}',
  '{"fracture","joint_infection","malignancy","acute_labral_tear"}',
  'level_2b'::evidence_level,
  '전방 고관절 통증 또는 굴곡 구축이 의심될 때 신전 방향성 선호 반응을 확인 후 적용 가능성이 있다. 장요근 단축이 동반된 요통-고관절 복합 증상에 활용될 수 있다.',
  'fracture, joint_infection, malignancy, acute_labral_tear',
  'acute_inflammation, FAI_severe, lumbar_instability',
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

-- ────────────────────── MDT-HIP-Flex ──────────────────────
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
  'MDT — 엉덩 관절',
  '고관절 굴곡 반복 운동', 'Hip Flexion Repeated Movement — MDT', 'MDT-HIP-Flex',
  'hip'::body_region, 'GHJ 후방 관절낭·후방 근육군',
  '바로 눕기, 무릎 굽힘',
  '환자 옆에서 동작 가이드 및 반응 관찰',
  '고관절 굴곡 방향 능동 반복 운동',
  '고관절 굴곡 반복 (무릎을 가슴 쪽으로 끌어당기기)',
  '[
    {"step":1,"instruction":"환자를 바로 눕기 자세로 위치시키고 환측 무릎을 자연스럽게 굽혀 발바닥이 테이블에 닿도록 준비한다. 치료사는 환자 옆에서 동작을 관찰한다."},
    {"step":2,"instruction":"환자에게 양손 또는 한 손으로 환측 무릎 아래를 잡고 무릎을 가슴 쪽으로 천천히 끌어당기는 고관절 굴곡 동작을 실시하도록 안내한다. 끝 범위에서 1–2초 유지 후 시작 위치로 돌아오는 방식으로 10회 반복한다."},
    {"step":3,"instruction":"10회 반복 후 후방 고관절 또는 둔부 통증이 감소하였는지(집중화), 증가하였는지(말초화) 확인한다. 고관절 신전 제한 변화도 함께 평가한다."},
    {"step":4,"instruction":"방향성 선호가 확인되면 동일 방향으로 추가 10회 반복한다. 바로 눕기 자세에서 충분한 개선이 확인되면 앉은 자세에서 몸을 앞으로 숙이는 방향으로 진행하며 중력 부하를 추가할 수 있다. 말초화 발생 시 즉시 중단한다."},
    {"step":5,"instruction":"세션 후 후방 고관절 통증, 앉기 불편감, 보행 시 둔부 통증 변화를 재평가한다. 방향성 선호가 확인된 경우 바로 눕기 또는 앉은 자세에서의 굴곡 반복 운동을 홈 프로그램으로 교육한다."}
  ]'::jsonb,
  '{"pain_relief","rom_improvement","directional_preference"}',
  '{"subacute","chronic"}',
  '{"hip_pain","posterior_hip_pain","hip_extension_restriction","buttock_pain"}',
  '{"fracture","joint_infection","malignancy","total_hip_arthroplasty"}',
  'level_2b'::evidence_level,
  '후방 고관절 통증 또는 신전 제한이 있을 때 굴곡 방향성 선호 반응을 확인 후 적용 가능성이 있다. 이상근 증후군 또는 고관절 관절증에서의 통증 조절에 활용될 수 있다.',
  'fracture, joint_infection, malignancy, total_hip_arthroplasty',
  'acute_inflammation, severe_FAI, acute_labral_tear',
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

-- ────────────────────── MDT-HIP-IR ──────────────────────
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
  'MDT — 엉덩 관절',
  '고관절 내회전 반복 운동', 'Hip Internal Rotation Repeated Movement — MDT', 'MDT-HIP-IR',
  'hip'::body_region, 'GHJ 후외측 관절낭·외회전근',
  '앉은 자세, 무릎 90도 굽힘, 발 바닥에 닿음',
  '환자 옆에서 동작 가이드 및 반응 관찰',
  '고관절 내회전 방향 능동 반복 운동 (발을 바깥쪽으로)',
  '고관절 내회전 반복 (발을 외측으로 벌리며 무릎 내측으로)',
  '[
    {"step":1,"instruction":"환자를 앉은 자세로 위치시키고 환측 무릎을 90도 굽혀 발바닥이 바닥에 닿도록 준비한다. 치료사는 환자 옆에서 자세와 동작을 관찰한다. 골반이 한쪽으로 기울지 않도록 균형 잡힌 앉은 자세를 먼저 확인한다."},
    {"step":2,"instruction":"환자에게 무릎 위치를 유지한 채 발을 외측(바깥쪽)으로 천천히 벌리는 동작을 실시하도록 안내한다. 이 동작은 고관절 내회전에 해당한다. 끝 범위에서 1–2초 유지 후 시작 위치로 돌아오는 방식으로 10회 반복한다."},
    {"step":3,"instruction":"10회 반복 후 외측 고관절 통증 또는 서혜부 통증이 감소하였는지(집중화), 증가하였는지(말초화) 확인한다. 고관절 내회전 ROM 변화도 함께 평가한다."},
    {"step":4,"instruction":"방향성 선호가 확인되면 동일 방향으로 추가 10회 반복한다. 필요 시 치료사가 환자 발목 외측에 가벼운 저항을 제공하여 내회전 끝 범위에서 과압 효과를 유도할 수 있다. 말초화 발생 시 즉시 중단한다."},
    {"step":5,"instruction":"세션 후 고관절 내회전 ROM, 외측 고관절 통증, 앉기·보행 시 불편감 변화를 재평가한다. 방향성 선호가 확인된 경우 앉은 자세에서의 내회전 반복 운동을 홈 프로그램으로 교육한다."}
  ]'::jsonb,
  '{"pain_relief","rom_improvement","directional_preference"}',
  '{"subacute","chronic"}',
  '{"hip_pain","hip_internal_rotation_restriction","FAI","lateral_hip_pain"}',
  '{"fracture","joint_infection","malignancy","total_hip_arthroplasty"}',
  'level_2b'::evidence_level,
  '고관절 내회전 제한이 주 소견일 때(FAI 등) 내회전 방향성 선호 반응을 확인 후 적용 가능성이 있다. 외측 고관절 통증이나 내회전 제한이 동반된 고관절 관절증에 활용될 수 있다.',
  'fracture, joint_infection, malignancy, total_hip_arthroplasty',
  'acute_inflammation, severe_FAI, posterior_hip_instability',
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
