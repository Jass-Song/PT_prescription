-- ============================================================
-- Migration 026 — 경추 신경가동술 기법 추가 (2개)
-- 경추 region에서 d_neural 선택 시 503 오류 해소용
-- body_region: cervical
-- K-Movement Optimism / PT 처방 도우미
-- 생성일: 2026-04-28
-- 작성자: sw-db-architect
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

BEGIN;

-- ────────────────────── NEU-CX-SLR-Slider ──────────────────────
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
  '신경가동술 — 경추 관절',
  '경추 신경근 슬라이더', 'Cervical Nerve Root Slider — Upper Limb Neural Mobilization', 'NEU-CX-Slider',
  'cervical'::body_region, '경추 신경근 (C5–C8)',
  '바로 눕기, 팔 몸통 옆에 이완, 경추 중립',
  '환자 머리 쪽에 위치, 경추 측굴·팔꿈치 신전 교대 조절',
  '경추 반대측 측굴 + 환측 어깨 하강',
  '경추 동측 측굴(신경 이완) ↔ 반대측 측굴(신경 긴장) 교대',
  '[
    {"step":1,"instruction":"바로 눕기 자세에서 환자 머리 쪽에 위치하고 환측 증상(저림·방사통)의 분포를 확인하여 영향받은 신경근 방향을 추정한다. 경추를 중립 위치에서 시작한다."},
    {"step":2,"instruction":"한 손으로 환자 머리를 지지하며 경추를 증상이 있는 쪽(동측)으로 약 20–30° 측굴하여 신경 이완 포지션을 만든다. 이때 반대편 어깨를 약간 하강시켜 신경 긴장을 추가적으로 줄인다."},
    {"step":3,"instruction":"슬라이더 기법 적용: 경추를 동측 측굴(이완)에서 반대측 측굴(긴장)로 천천히 왕복하며 신경근을 부드럽게 슬라이딩한다. 팔꿈치 신전을 반대측 측굴과 함께 조합하면 원위부 긴장을 높일 수 있다. 10–15회 반복."},
    {"step":4,"instruction":"각 반복 후 증상 변화를 관찰한다. 저림감이 감소하거나 통증 위치가 경추 쪽으로 집중되면 긍정적 반응으로 판단한다. 증상 악화(저림 증가, 근력 약화 감각) 시 즉시 중단한다."},
    {"step":5,"instruction":"치료 후 경추 측굴 ROM, 팔 저림 강도 변화를 재평가한다. 증상 경감이 확인되면 앉은 자세에서의 자가 슬라이더(고개 기울이기 + 손목 신전·굴곡 교대) 홈 프로그램을 교육한다."}
  ]'::jsonb,
  '{"neurodynamic_mobilization","pain_relief"}',
  '{"subacute","chronic","sensitized"}',
  '{"radicular_pain","arm_numbness","cervicobrachial_pain","movement_pain"}',
  '{"neurological_deficit","instability","upper_cervical_instability","fracture","malignancy"}',
  'level_2b'::evidence_level,
  '경추 신경근 자극 증상(C5–C8 분포 저림·방사통)이 있을 때 슬라이더 기법으로 신경 유동성을 회복할 수 있다. 경추 움직임 중 증상 집중화 반응이 확인될 때 효과적이다. 급성 신경학적 결손이 있는 경우 적용하지 않는다.',
  'neurological_deficit, upper_cervical_instability, fracture, malignancy',
  'acute_radiculopathy_severe, VBI_risk, anticoagulant_therapy',
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

-- ────────────────────── NEU-CX-Tensioner ──────────────────────
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
  '신경가동술 — 경추 관절',
  '경추 신경근 텐셔너', 'Cervical Nerve Root Tensioner — Sustained Neural Stretch', 'NEU-CX-Tensioner',
  'cervical'::body_region, '경추 신경근 + 상완신경총 (C5–C8)',
  '바로 눕기, 환측 팔 몸통 옆에 이완',
  '환자 환측에 위치, 어깨·팔꿈치·손목 순서로 긴장 유도',
  '어깨 외전·외회전, 팔꿈치 신전, 손목 신전, 경추 반대측 측굴',
  '상완신경총 긴장 순서: 어깨 외전 → 외회전 → 팔꿈치 신전 → 손목 신전 → 경추 반대측 측굴',
  '[
    {"step":1,"instruction":"바로 눕기 자세에서 환측 어깨를 약 90° 외전하고 외회전 방향으로 서서히 유도한다. 이 상태에서 증상(저림·방사통) 발생 여부를 확인한다."},
    {"step":2,"instruction":"팔꿈치를 신전하고 손목을 신전 방향으로 추가하여 상완신경총 및 경추 신경근에 점진적으로 긴장을 형성한다. 각 단계에서 증상 변화를 관찰한다."},
    {"step":3,"instruction":"경추를 반대측(비환측)으로 약 20–30° 측굴하여 신경근 긴장을 완성한다. 환자에게 팔 저림·방사통이 재현되는지 확인한다. 증상 재현 없이 당김감만 있는 강도에서 조절한다."},
    {"step":4,"instruction":"텐셔너 기법: 긴장이 형성된 상태를 10–15초 유지하거나, 경추 측굴 추가·해제를 3–5회 반복하여 신경 조직에 간헐적 긴장을 제공한다. 지속적 악화 없이 증상이 일시적으로 재현되면 양성 반응으로 판단한다."},
    {"step":5,"instruction":"치료 후 팔 저림 강도, 경추 측굴 ROM 변화를 재평가한다. 텐셔너는 슬라이더보다 자극이 강하므로 초기에는 슬라이더를 우선 적용하고 반응을 보며 텐셔너로 진행한다. 홈 프로그램은 앉은 자세 슬라이더를 우선 교육한다."}
  ]'::jsonb,
  '{"neurodynamic_mobilization","pain_relief","sensitization_reduction"}',
  '{"subacute","chronic","sensitized"}',
  '{"radicular_pain","arm_numbness","cervicobrachial_pain","disc_related"}',
  '{"neurological_deficit","instability","upper_cervical_instability","fracture","malignancy","vbi"}',
  'level_2b'::evidence_level,
  '경추 신경근 방사통(C5–C8) 및 상완신경총 증상이 있을 때 텐셔너 기법으로 신경 민감화를 완화할 수 있다. 슬라이더 기법 이후 단계로 적용하거나, 만성 신경 민감화 상태에서 더 유효할 수 있다. 급성 신경학적 결손 시 금기.',
  'neurological_deficit, upper_cervical_instability, VBI, fracture, malignancy',
  'acute_radiculopathy_severe, severe_disc_herniation, anticoagulant_therapy',
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
