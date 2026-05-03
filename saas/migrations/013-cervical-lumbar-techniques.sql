-- Migration 013: Cervical + Lumbar Soft Tissue Techniques
-- 경추 22개 + 요추 18개 = 40개 신규 기법 INSERT
-- sw-db-architect | 2026-04-26
-- is_published = true (all records)

BEGIN;

-- ============================================================
-- CERVICAL (경추) — 22 techniques
-- ============================================================

-- [1] ART-CervMultifidus
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
  'ART — 경추 심부 근육',
  '경추 다열근 능동적 이완기법', 'Active Release Technique — Cervical Multifidus', 'ART-CervMultifidus',
  'cervical'::body_region, 'C2–C7 극돌기 외측 1–2cm 심부',
  '앙와위 (바로 누운 자세) — 머리 치료사 손으로 지지, 경추 중립', '환자 머리 쪽 앉거나 서서 양손으로 머리 지지, 접촉 손: 두 번째·세 번째 손가락 끝, 목표 분절 극돌기 외측 1–2cm', '두 번째·세 번째 손가락 끝 — 극돌기 외측 1–2cm 심부', '수직 하방 접촉 유지 + 경추 굴곡 방향으로 능동 이동',
  '[{"step":1,"instruction":"목표 분절(C4–C6 빈도 높음) 확인 — 극돌기 촉진 후 외측 1–2cm에서 다열근 과민점 탐색"},{"step":2,"instruction":"손가락 끝으로 목표 트리거포인트 또는 단단한 결절에 접촉, 환자에게 연관통 재현 여부 확인"},{"step":3,"instruction":"경추를 신전 자세에서 시작, 접촉 유지하며 환자가 천천히 경추를 굴곡"},{"step":4,"instruction":"굴곡 끝 범위에서 접촉 해제, 자세 복귀 후 2–4회 반복"},{"step":5,"instruction":"시술 후 경추 모든 방향 ROM 재평가, 특히 굴곡·회전 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_4'::evidence_level,
  '경추 다열근은 분절 안정성 핵심 근육 — 압박 후 반드시 신경근 조절 운동(버드독 변형 등) 병행 권고. 극돌기 위 직접 압박 금지 — 반드시 외측 1–2cm 근육 부위 확인.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk',
  'osteoporosis, acute_inflammation, anticoagulant_therapy',
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

-- [2] ART-LevScap
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
  'ART — 경추 측방 근육',
  '견갑거근 능동적 이완기법', 'Active Release Technique — Levator Scapulae', 'ART-LevScap',
  'cervical'::body_region, 'C1–C4 횡돌기 ~ 견갑골 상각',
  '앙와위 또는 좌위 — 경추 중립, 치료 측 어깨 이완', '환자 옆쪽 또는 머리 쪽, 접촉 손: 엄지 또는 두 번째 손가락 끝, 근복(경추 측방 ~ 견갑골 상각 사이)', '엄지 끝 — 견갑거근 근복(경추 측방 하부 ~ 견갑골 상각 사이 중간)', '접촉 유지 + 경추 반대쪽 측굴 + 견갑골 하강 방향 복합 이동',
  '[{"step":1,"instruction":"견갑거근 근복(경추 C4 수준 외측 ~ 견갑골 상각) 촉진, 단단한 결절·압통점 탐색"},{"step":2,"instruction":"엄지 끝으로 목표 압통점에 접촉, 환자에게 어깨·목으로 퍼지는 연관통 재현 여부 확인"},{"step":3,"instruction":"경추를 동측 측굴 자세에서 시작(견갑거근 단축 자세), 접촉 유지하며 환자가 경추를 반대쪽으로 측굴"},{"step":4,"instruction":"동시에 치료사 또는 환자가 견갑골을 하강시켜 견갑거근 원위부도 신장"},{"step":5,"instruction":"시술 후 경추 측굴·회전 ROM 재평가, 어깨 높이 비대칭 변화 관찰"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_4'::evidence_level,
  '견갑거근은 경추 측방 통증과 어깨 결림의 가장 흔한 원인 근육 중 하나. ART는 동적 이완으로 정적 스트레칭보다 단단한 근육 유착에 효과적. 견갑골 각도(전방 경사)가 심한 경우 경추 상부 접근에 주의.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk',
  'osteoporosis, acute_inflammation, anticoagulant_therapy',
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

-- [3] ART-Scalenes
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
  'ART — 경추 전방 근육',
  '사각근 능동적 이완기법', 'Active Release Technique — Scalenes', 'ART-Scalenes',
  'cervical'::body_region, 'C3–C6 횡돌기 ~ 1·2번 갈비뼈',
  '앙와위 — 경추 중립, 치료 측 어깨 약간 외전', '환자 머리 쪽 — 접촉 손: 두 번째·세 번째 손가락 끝, 흉쇄유돌근 후방 사각근 근복', '두 번째·세 번째 손가락 끝 — 흉쇄유돌근 후방, 사각근 근복', '접촉 유지 + 경추 반대쪽 측굴 + 흡기(호흡) 복합 이동',
  '[{"step":1,"instruction":"흉쇄유돌근 후방에서 사각근 근복 촉진 — 전·중·후 사각근 순서로 탐색, 압통·단단한 결절 확인"},{"step":2,"instruction":"목표 압통점에 접촉, 팔·어깨·엄지·검지로 퍼지는 연관통 재현 여부 확인 (흉곽출구증후군 유사 증상)"},{"step":3,"instruction":"경추를 동측 측굴(사각근 단축 자세)에서 시작, 접촉 유지하며 반대쪽 측굴"},{"step":4,"instruction":"호흡 연동 — 내쉬면서 반대쪽 측굴, 사각근 신장 효과 극대화"},{"step":5,"instruction":"시술 후 경추 측굴 ROM 및 팔·손 저림 증상 변화 재평가"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_3'::evidence_level,
  '사각근은 흉곽출구증후군(TOS) 보존 치료에서 핵심 타겟 — 경동맥·내경정맥이 인근을 지나므로 접촉 위치를 흉쇄유돌근 후방으로 정확히 설정. 경동맥 위 직접 압박 절대 금지.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk, carotid_pathology',
  'osteoporosis, acute_inflammation, anticoagulant_therapy',
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

-- [4] ART-Splenius
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
  'ART — 경추 후방 근육',
  '두판상근·경판상근 능동적 이완기법', 'Active Release Technique — Splenius Capitis & Cervicis', 'ART-Splenius',
  'cervical'::body_region, 'C3–C7 후방, 유양돌기 ~ 상항선',
  '앙와위 또는 좌위 — 경추 약간 굴곡', '환자 머리 쪽 또는 옆쪽, 접촉 손: 엄지 또는 두 번째 손가락 끝, 경추 후외측 판상근 근복', '엄지 끝 — 경추 후외측 판상근 근복(C3–C6 수준)', '접촉 유지 + 경추 굴곡 + 반대쪽 회전 복합 이동',
  '[{"step":1,"instruction":"경추 후외측(흉쇄유돌근 후방, 승모근 전방 경계 사이)에서 판상근 근복 촉진, 단단한 결절·압통점 탐색"},{"step":2,"instruction":"목표 압통점에 엄지 접촉, 두통·목 후방으로 퍼지는 연관통 재현 여부 확인"},{"step":3,"instruction":"경추를 동측 회전(판상근 단축 자세)에서 시작, 접촉 유지하며 반대쪽으로 회전"},{"step":4,"instruction":"동시에 경추 굴곡 성분 추가하여 판상근 최대 신장"},{"step":5,"instruction":"시술 후 경추 회전·측굴 ROM 재평가, 두통 강도 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_4'::evidence_level,
  '두판상근·경판상근은 경추 회전 제한과 경추성 두통의 주요 원인 근육. ART 시 경추 과굴곡 방지 — 판상근 신장 시 척추동맥 자극 주의. VBI 스크리닝 필수.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk',
  'osteoporosis, acute_inflammation, anticoagulant_therapy',
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

-- [5] CTM-CTJ
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
  'Connective Tissue Massage (CTM) — 경추-흉추 이행부',
  '경추-흉추 이행부 결합조직 마사지', 'Cervicothoracic Junction Connective Tissue Massage', 'CTM-CTJ',
  'cervical'::body_region, 'C7–T3 이행부, 견갑골 내측상연',
  '좌위 — 치료대 모서리에 앉아 척추 중립, 팔은 허벅지 위. 대안: 복와위', '환자 뒤쪽, C7–T3 수준에서, 접촉 손: 세 번째·네 번째 손가락 지문면(pad)', '세 번째·네 번째 손가락 지문면 — C7–T3 이행부 피부·피하층 경계', 'Zuggriff — 피부·피하층 경계를 진행 방향으로 당기기 (척추 외측 방향으로)',
  '[{"step":1,"instruction":"C7–T3 이행부 피하 결합 조직 상태 평가 — 집어보기로 조직 두께·유착 여부 확인"},{"step":2,"instruction":"기저 스트로크(Grundaufbau) — C7 수준에서 T3 방향으로 가볍게 Zuggriff 3–5회"},{"step":3,"instruction":"집중 치료 — C7–T1 구역에서 Zuggriff 5–8회, 피부·피하층을 당기는 방식 유지"},{"step":4,"instruction":"견갑골 내측상연 구역으로 이동하여 추가 Zuggriff, 조직 반응(붉어짐) 확인"},{"step":5,"instruction":"시술 후 경추 굴곡·신전 ROM 재평가, 조직 상태 대칭성 개선 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","skin_lesion"}',
  'level_5'::evidence_level,
  'CTM 시작 전 기저 스트로크 필수 — 준비 없이 강한 자극 금지. Zuggriff는 피부를 문지르는 것이 아닌 "당기는" 기법 — 손가락이 피부 위에서 미끄러지면 안 됨. 자율신경 반응(피로감·어지러움) 시술 후 5–10분 안정 권고.',
  'fracture, instability, malignancy, neurological_deficit, open_wound, skin_infection',
  'osteoporosis, diabetes_neuropathy, high_skin_sensitivity',
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

-- [6] CTM-CervLateral
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
  'Connective Tissue Massage (CTM) — 경추 측방 구역',
  '경추 측방 결합조직 마사지', 'Cervical Lateral Connective Tissue Massage', 'CTM-CervLateral',
  'cervical'::body_region, 'C2–C7 측방 구역, 흉쇄유돌근 후방',
  '좌위 — 치료대 모서리에 앉아 경추 중립. 대안: 앙와위', '환자 뒤쪽 또는 옆쪽, 경추 측방 수준. 접촉 손: 세 번째·네 번째 손가락 지문면', '세 번째·네 번째 손가락 지문면 — 경추 측방, 흉쇄유돌근 후방 구역', 'Zuggriff — 두개골 방향(상방) 또는 경추 방향(하방)으로 당기기',
  '[{"step":1,"instruction":"경추 측방 피하 결합 조직 상태 평가 — 양측 비교하여 비대칭 부위 우선 치료 계획"},{"step":2,"instruction":"기저 스트로크 — 경추 하부에서 유양돌기 방향으로 가볍게 Zuggriff 3–5회"},{"step":3,"instruction":"흉쇄유돌근 후방 경계에서 C2–C7 순서로 Zuggriff 집중 시행, 5–8회/구역"},{"step":4,"instruction":"조직 반응(붉어짐) 확인하며 강도 조정 — 붉어짐이 없으면 강도 증가"},{"step":5,"instruction":"시술 후 경추 측굴·회전 ROM 재평가, 조직 반응 대칭성 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk","skin_lesion"}',
  'level_5'::evidence_level,
  '경동맥과 내경정맥이 흉쇄유돌근 전방을 지나므로 접촉은 반드시 흉쇄유돌근 후방으로 제한. 경동맥 박동이 느껴지는 위치 직접 접촉 금지.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk, open_wound, skin_infection',
  'osteoporosis, diabetes_neuropathy, high_skin_sensitivity',
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

-- [7] CTM-NO
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
  'Connective Tissue Massage (CTM) — 후두하 구역',
  '후두하 결합조직 마사지', 'Nuchal-Occipital Connective Tissue Massage', 'CTM-NO',
  'cervical'::body_region, '후두골 하연 ~ C2 수준 (후두하 삼각 구역)',
  '앙와위 — 머리 치료사 손으로 지지, 경추 약간 굴곡. 대안: 좌위', '환자 머리 쪽 — 양손으로 머리를 받치며 세 번째·네 번째 손가락 지문면으로 접촉', '세 번째·네 번째 손가락 지문면 — 상항선 아래, 후두하 구역', 'Zuggriff — 두개골에서 경추 방향(하방)으로 당기기',
  '[{"step":1,"instruction":"후두하 구역 결합 조직 상태 평가 — 상항선 아래를 집어보며 두께·유착 확인, 두통 유발점 탐색"},{"step":2,"instruction":"기저 스트로크 — 후두골 하연을 따라 좌우로 가볍게 Zuggriff 3–5회"},{"step":3,"instruction":"집중 치료 — 상항선 바로 아래 구역에서 Zuggriff 5–8회, 후두-경추 방향"},{"step":4,"instruction":"두통 유발점 집중 — 눈 또는 이마 쪽으로 두통이 퍼지는 부위 중점 치료"},{"step":5,"instruction":"시술 후 경추 굴곡·두통 강도 재평가, 두통 위치 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk","skin_lesion"}',
  'level_4'::evidence_level,
  '후두하 CTM은 경추성 두통과 긴장성 두통 모두에 자율신경 조절 경로로 효과 기대. 경추 과신전 금지 — VBI 위험. 시술 후 즉각적인 두통 완화 반응은 자율신경 효과 신호.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk, open_wound, skin_infection',
  'osteoporosis, diabetes_neuropathy, high_skin_sensitivity, pregnancy',
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

-- [8] DFM-CervFacet
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
  'Deep Friction Massage — 경추 관절낭',
  '경추 후관절 관절낭 심부마찰 마사지', 'Deep Friction Massage — Cervical Facet Joint Capsule', 'DFM-CervFacet',
  'cervical'::body_region, 'C2–C7 후관절 (관절기둥 내측)',
  '앙와위 — 머리 치료사 손으로 지지, 경추 중립', '환자 머리 쪽, 접촉 손: 두 번째·세 번째 손가락 끝, 목표 후관절 위치', '두 번째 손가락 끝 — 극돌기 외측 1–1.5cm, 관절기둥 위 관절낭 위치', '횡방향(transverse) 마찰 — 관절 운동 방향에 수직으로',
  '[{"step":1,"instruction":"목표 경추 분절 극돌기 촉진 후 외측 1–1.5cm에서 관절기둥 위치 확인"},{"step":2,"instruction":"두 번째 손가락 끝을 관절낭 위치에 접촉, 수직 방향으로 조직 내 접촉 확보"},{"step":3,"instruction":"횡방향 마찰 시작 — 작은 왕복 동작으로 관절낭 조직에 마찰 가함, 60–90초"},{"step":4,"instruction":"마찰 중 환자 반응(압통 정도) 모니터링 — 목표는 VAS 4–6/10 수준"},{"step":5,"instruction":"시술 후 해당 분절 ROM 재평가, 후관절 부하 검사(경추 신전+회전) 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk","acute_inflammation"}',
  'level_5'::evidence_level,
  '경추 후관절 관절낭 DFM은 Cyriax 기법 기반 — 관절낭 조직에 직접 마찰로 혈류 개선·유착 분리. 극돌기 직접 접촉 금지. 신경근 증상(팔 저림·방사통)이 있는 경우 금지.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk, acute_inflammation, radiculopathy',
  'osteoporosis, anticoagulant_therapy, diabetes_neuropathy',
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

-- [9] DTFM-CTJ
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
  'Deep Friction Massage — 경추-흉추 이행부',
  '경추-흉추 이행부 심부마찰 마사지', 'Deep Transverse Friction Massage — Cervicothoracic Junction', 'DTFM-CTJ',
  'cervical'::body_region, 'C6–T2 이행부 인대·관절낭',
  '좌위 또는 복와위 — 경추-흉추 이행부 노출', '환자 뒤쪽, C7–T2 수준. 접촉 손: 두 번째·세 번째 손가락 끝', '두 번째·세 번째 손가락 끝 — C7–T1 극돌기 간 인대(극간인대) 또는 관절낭 위치', '횡방향 마찰 — 인대 섬유에 수직 방향',
  '[{"step":1,"instruction":"C7–T2 극돌기 간 인대 또는 관절낭 부위를 촉진으로 압통 최대 부위 확인"},{"step":2,"instruction":"손가락 끝을 목표 조직에 수직 접촉 확보 — 조직 표면이 아닌 조직 내 접촉"},{"step":3,"instruction":"횡방향 마찰 시작 — 왕복 동작, 인대/관절낭 섬유에 수직 방향, 60–120초"},{"step":4,"instruction":"마찰 강도 점진적 증가 — VAS 4–6/10 유지, 환자 반응 모니터링"},{"step":5,"instruction":"시술 후 경추-흉추 이행부 굴곡·신전 ROM 재평가, 압통 강도 비교"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","acute_inflammation"}',
  'level_4'::evidence_level,
  'C7–T1 이행부는 경추-흉추 운동 패턴의 전환점 — 이 구역 연부조직 제한이 경추 전체 ROM에 영향. DFM 후 이행부 가동화와 병행 권장.',
  'fracture, instability, malignancy, neurological_deficit, acute_inflammation, radiculopathy',
  'osteoporosis, anticoagulant_therapy',
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

-- [10] IASTM-CLM
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
  'category_iastm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_iastm'),
  'IASTM — 경추 측방 근육',
  '경추 측방 근육 IASTM', 'IASTM — Cervical Lateral Muscles', 'IASTM-CLM',
  'cervical'::body_region, 'C2–C7 측방 (흉쇄유돌근·사각근·견갑거근 구역)',
  '좌위 — 경추 중립, 치료사가 머리 지지 또는 환자 스스로 유지', '환자 옆쪽 또는 뒤쪽, 경추 측방에 도구 접촉 위치. IASTM 도구: 중간 크기 스테인리스 도구', 'IASTM 도구 오목면 또는 날 부분 — 경추 측방 근막·근육 조직', '원위부에서 근위부(하방→상방) 또는 근위부에서 원위부 방향으로 스트로크',
  '[{"step":1,"instruction":"IASTM 크림 또는 윤활제 도포 후 경추 측방 조직 상태 스캐닝 (scanning stroke) — 도구로 조직 질감 확인, 유착·거칠음 느껴지는 부위 표시"},{"step":2,"instruction":"치료 스트로크 시작 — 경추 하부(C7)에서 상부(C2) 방향으로 가볍게 30–45° 각도 스트로크"},{"step":3,"instruction":"유착 부위에서 반복 스트로크 집중 — 국소 붉어짐(petechiae) 확인 시 해당 구역 완료"},{"step":4,"instruction":"흉쇄유돌근 후방 → 사각근 구역 → 견갑거근 순서로 체계적 적용"},{"step":5,"instruction":"시술 후 경추 측굴·회전 ROM 재평가, 근육 조직 질감 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk","skin_lesion","anticoagulant"}',
  'level_2b'::evidence_level,
  'IASTM 시 경동맥·내경정맥 위치 확인 필수 — 흉쇄유돌근 전방 직접 접촉 금지. petechiae(점상출혈) 발생은 정상 반응이나 과도한 경우 강도 감소. 항응고제 복용 환자 절대 금지.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk, open_wound, skin_infection, anticoagulant_therapy',
  'osteoporosis, acute_inflammation, diabetes_neuropathy',
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

-- [11] IASTM-LevScap
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
  'category_iastm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_iastm'),
  'IASTM — 견갑거근',
  '견갑거근 IASTM', 'IASTM — Levator Scapulae', 'IASTM-LevScap',
  'cervical'::body_region, 'C1–C4 횡돌기 ~ 견갑골 상각 (견갑거근 전체 주행)',
  '좌위 또는 복와위 — 치료 측 어깨 이완', '환자 옆쪽 또는 뒤쪽, IASTM 도구: 중간 크기 도구', 'IASTM 도구 날 부분 — 견갑거근 근복(경추 하부~견갑골 상각)', '견갑골 상각 → 경추 방향(원위부→근위부) 스트로크',
  '[{"step":1,"instruction":"견갑거근 주행 경로(경추 C4 외측 ~ 견갑골 상각) 스캐닝 스트로크로 유착 부위 확인"},{"step":2,"instruction":"견갑골 상각부터 경추 방향으로 치료 스트로크 시작 — 30–45° 도구 각도 유지"},{"step":3,"instruction":"유착 부위(가장 흔히 경추 C3–C4 수준 근복) 집중 반복 스트로크"},{"step":4,"instruction":"petechiae 형성 확인 후 해당 구역 완료, 다음 구역으로 이동"},{"step":5,"instruction":"시술 후 경추 측굴·견갑골 거상 ROM 재평가"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","skin_lesion","anticoagulant"}',
  'level_3'::evidence_level,
  '견갑거근 IASTM 후 경추 측굴 스트레칭 즉시 병행 권장 — IASTM으로 근막 이동성 회복 후 스트레칭으로 길이 회복. 경추 극돌기 위 도구 접촉 금지.',
  'fracture, instability, malignancy, neurological_deficit, open_wound, skin_infection, anticoagulant_therapy',
  'osteoporosis, acute_inflammation',
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

-- [12] IASTM-CervPost
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
  'category_iastm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_iastm'),
  'IASTM — 경추 후방 근육군',
  '경추 후방 근육군 IASTM', 'IASTM — Cervical Posterior Muscles', 'IASTM-CervPost',
  'cervical'::body_region, 'C2–T1 후방 (반극근·판상근·다열근 표재층)',
  '복와위 또는 좌위 — 경추 약간 굴곡', '환자 머리 쪽 또는 뒤쪽, IASTM 도구: 중간 크기 도구', 'IASTM 도구 날 또는 오목면 — 경추 후방 근막층', '두개골 방향(상방) 또는 흉추 방향(하방) 스트로크',
  '[{"step":1,"instruction":"경추 후방 근막 전체 스캐닝 스트로크 — 항인대·반극근·판상근 구역 순서로 유착 부위 탐색"},{"step":2,"instruction":"흉추-경추 이행부(C7–T1)에서 두개골 방향으로 치료 스트로크 시작"},{"step":3,"instruction":"극돌기 외측 1–2cm 구역(다열근·반극근 층)에 집중 스트로크"},{"step":4,"instruction":"두통 연관 부위(C2–C4 수준 후방) 집중 반복"},{"step":5,"instruction":"시술 후 경추 굴곡·신전 ROM 재평가, 두통 강도 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk","skin_lesion","anticoagulant"}',
  'level_3'::evidence_level,
  '경추 후방 IASTM은 경추성 두통 보존 치료에서 중요한 위치. 극돌기 직접 접촉 금지 — 외측 1–2cm 근육 구역만. VBI 위험 고려하여 경추 과신전 자세 금지.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk, open_wound, skin_infection, anticoagulant_therapy',
  'osteoporosis, acute_inflammation, diabetes_neuropathy',
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

-- [13] MFR-LevScap
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
  'Myofascial Release (MFR) — 경추 측방 근육',
  '견갑거근 근막이완 기법', 'Levator Scapulae Myofascial Release', 'MFR-LevScap',
  'cervical'::body_region, 'C1–C4 횡돌기 ~ 견갑골 상각',
  '앙와위 또는 좌위 — 치료 측 어깨 이완', '환자 옆쪽 또는 머리 쪽, 손바닥 또는 엄지로 견갑거근 근복에 접촉', '손바닥 또는 엄지 지문면 — 견갑거근 근복 중간 부위', '부드러운 지속 압박 — 조직이 이완될 때까지 기다리기',
  '[{"step":1,"instruction":"견갑거근 근복에 손바닥 전체 또는 엄지로 가볍게 접촉, 표재층(피하 조직) 수준에서 이동 제한 방향 탐색"},{"step":2,"instruction":"제한된 방향으로 부드럽게 견인하며 3–5분 대기 — 조직이 이완되는 느낌 확인"},{"step":3,"instruction":"표재층 이완 후 심부층(견갑거근 근막)으로 접촉 깊이 조정"},{"step":4,"instruction":"같은 방식으로 심부층 탐색 및 이완 대기"},{"step":5,"instruction":"시술 후 경추 측굴·회전 ROM 재평가, 어깨 높이 비대칭 변화 관찰"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_4'::evidence_level,
  'MFR은 트리거포인트 압박보다 부드러운 기법 — 통증 민감성이 높은 환자에게 우선 적용. "기다리는 기법"으로 억지로 밀지 않기. 최소 3–5분/레이어 대기 필수.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk',
  'osteoporosis, acute_inflammation, anticoagulant_therapy',
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

-- [14] Neck Posterior MFR
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
  'Myofascial Release (MFR) — 경추 후방 사슬',
  '경추 후방 사슬 근막이완 기법', 'Neck Posterior Chain Myofascial Release', 'Neck Posterior MFR',
  'cervical'::body_region, 'C2–T1 후방 전체 (두판상근·반극근·다열근·항인대)',
  '앙와위 — 머리 치료사 손으로 지지, 경추 중립', '환자 머리 쪽 — 양손으로 머리를 받치거나 손바닥으로 경추 후방 접촉', '양 손바닥 또는 손가락 끝 — 경추 후방 근막층', '두 손이 반대 방향으로 부드럽게 견인 (크로스핸드 또는 종방향)',
  '[{"step":1,"instruction":"한 손은 후두골 아래, 다른 손은 C7–T1 수준에 접촉, 표재층 근막 이동 제한 탐색"},{"step":2,"instruction":"두 손을 반대 방향(두측·미측)으로 부드럽게 견인 — 경추 후방 전체 근막 신장, 3–5분 대기"},{"step":3,"instruction":"표재층 이완 후 중간층(반극근·판상근)으로 접촉 깊이 조정, 반복"},{"step":4,"instruction":"심부층(다열근)까지 순차 접근 — 각 레이어에서 이완 대기"},{"step":5,"instruction":"시술 후 경추 굴곡 ROM 재평가, 두통 강도 변화 및 경추 후방 긴장도 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_4'::evidence_level,
  '경추 후방 사슬 MFR은 경추성 두통 치료에서 약물 없이 증상을 완화하는 중요한 도수치료 기법. 크로스핸드 기법이 경추 전체 후방 근막을 동시에 다루는 핵심 접근.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk',
  'osteoporosis, acute_inflammation, anticoagulant_therapy',
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

-- [15] MFR-Scalenes
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
  'Myofascial Release (MFR) — 경추 전방 근육',
  '사각근 근막이완 기법', 'Scalene Myofascial Release', 'MFR-Scalenes',
  'cervical'::body_region, 'C3–C6 횡돌기 ~ 1·2번 갈비뼈 (전·중·후 사각근)',
  '앙와위 — 경추 중립, 치료 측 어깨 이완', '환자 머리 쪽 또는 옆쪽 — 접촉 손: 손가락 끝, 흉쇄유돌근 후방 사각근 위치', '손가락 끝 — 흉쇄유돌근 후방, 사각근 근막', '부드러운 지속 압박 + 경추 반대쪽 측굴 유도',
  '[{"step":1,"instruction":"흉쇄유돌근 후방에서 사각근 근막에 손가락 끝 가볍게 접촉, 표재층 이동 제한 탐색"},{"step":2,"instruction":"제한 방향으로 부드럽게 견인 — 3–5분 대기, 조직 이완 느낌 확인"},{"step":3,"instruction":"이완이 일어나면 경추를 반대쪽으로 약간 측굴하여 사각근 신장 성분 추가"},{"step":4,"instruction":"호흡 연동 — 내쉬는 순간 접촉 깊이 약간 증가, 들이쉬는 순간 유지"},{"step":5,"instruction":"시술 후 경추 측굴 ROM 및 팔·손 저림 증상 변화 재평가"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_4'::evidence_level,
  '경동맥 박동 위치 확인 필수 — 흉쇄유돌근 전방 직접 압박 절대 금지. 팔 저림 악화 시 즉시 접촉 위치 조정. 흉곽출구증후군 환자에게 적합.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk, carotid_pathology',
  'osteoporosis, acute_inflammation',
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

-- [16] Suboccipital MFR
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
  'Myofascial Release (MFR) — 후두하 근육',
  '후두하 근막이완 기법', 'Suboccipital Myofascial Release', 'Suboccipital MFR',
  'cervical'::body_region, '후두하 삼각 (상·하 두후두직근, 상·하 두사근)',
  '앙와위 — 머리 치료사 손으로 지지, 경추 중립', '환자 머리 쪽 — 양손으로 머리를 받치며 손가락 끝이 후두하 삼각에 접촉', '두 번째·세 번째 손가락 끝 — 후두골 하연 바로 아래 후두하 삼각', '부드러운 수직 압박 + 두개골 미세 견인 방향',
  '[{"step":1,"instruction":"후두하 삼각 위치 확인 — 후두골 하연 바로 아래, C1·C2 극돌기 외측, 손가락 끝으로 부드럽게 접촉"},{"step":2,"instruction":"표재층(후두하 근막)에 가볍게 접촉, 이동 제한 방향 탐색 — 두개골 방향으로 부드럽게 견인 시작"},{"step":3,"instruction":"3–5분 대기 — 조직이 이완되면서 손가락이 자연스럽게 깊어지는 느낌 확인"},{"step":4,"instruction":"심부층(후두하 근육)으로 접촉 깊이 조정 — 억지로 밀지 않고 조직이 허락하는 방향으로"},{"step":5,"instruction":"시술 후 경추 굴곡 ROM 및 두통 강도 재평가, 눈 주변 긴장감 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_4'::evidence_level,
  '후두하 MFR은 경추성 두통·긴장성 두통에 가장 효과적인 연부조직 기법 중 하나. 두개골 미세 견인 기법(cranial traction)과 병행하면 효과 상승. 치료사 손목 피로 주의 — 손가락이 아닌 손 전체로 머리 무게 지지.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk',
  'osteoporosis, acute_inflammation',
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

-- [17] CervMult-TrP
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
  'Trigger Point Release — 경추 심부 근육',
  '경추 다열근 트리거포인트 압박', 'Cervical Multifidus Trigger Point Release', 'CervMult-TrP',
  'cervical'::body_region, 'C2–C7 극돌기 외측 1–2cm (다열근 근복)',
  '앙와위 또는 좌위 — 경추 중립', '환자 머리 쪽 또는 옆쪽, 접촉 손: 두 번째·세 번째 손가락 끝, 극돌기 외측 1–2cm', '두 번째·세 번째 손가락 끝 — 경추 극돌기 외측 1–2cm 심부', '수직 하방 지속 압박',
  '[{"step":1,"instruction":"통증 호소 분절 확인 후 극돌기 외측 1–2cm에서 단단한 결절·압통점 탐색"},{"step":2,"instruction":"목표 압통점에 손가락 끝 접촉, 연관통(목 깊은 곳·어깨·두통) 재현 여부 확인"},{"step":3,"instruction":"VAS 5–7/10 수준 압박 유지, 환자에게 숨 내쉬면서 근육 힘 빼도록 지시"},{"step":4,"instruction":"30–90초 압박 유지 후 압통 감소 확인, 인접 분절로 이동"},{"step":5,"instruction":"시술 후 경추 ROM 재평가, 다열근 활성화 운동 처방"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk","acute_inflammation"}',
  'level_4'::evidence_level,
  '경추 다열근 트리거포인트 압박 후 반드시 신경근 조절 운동 병행. 극돌기 직접 압박 금지 — 외측 1–2cm 근육 부위만. VAS 8 이상 통증 호소 시 즉시 중단.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk, acute_inflammation',
  'osteoporosis, anticoagulant_therapy',
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

-- [18] LevScap-TrP
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
  'Trigger Point Release — 경추 측방 근육',
  '견갑거근 트리거포인트 압박', 'Levator Scapulae Trigger Point Release', 'LevScap-TrP',
  'cervical'::body_region, 'C1–C4 횡돌기 ~ 견갑골 상각 (견갑거근 근복)',
  '앙와위 또는 좌위 — 치료 측 어깨 이완', '환자 옆쪽 또는 머리 쪽, 접촉 손: 엄지 끝 — 견갑거근 근복', '엄지 지문면 — 견갑거근 근복 (C4 수준 외측 ~ 견갑골 상각 중간)', '수직 하방 지속 압박',
  '[{"step":1,"instruction":"견갑거근 주행(C4 외측 ~ 견갑골 상각)을 따라 가장 단단한 결절·압통점 탐색, 어깨·목으로 퍼지는 연관통 재현 확인"},{"step":2,"instruction":"엄지 끝으로 목표 압통점에 접촉, VAS 5–7/10 압박"},{"step":3,"instruction":"숨 내쉬면서 근육 힘 빼도록 지시, 30–90초 압박 유지"},{"step":4,"instruction":"압통 감소 후 인접 부위로 이동, 2–3개 트리거포인트 탐색"},{"step":5,"instruction":"시술 후 경추 측굴 ROM 재평가, 경추 측굴 스트레칭 처방"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_4'::evidence_level,
  '견갑거근은 목-어깨 통증의 가장 흔한 원인 근육 — 임상에서 높은 유병률. 압박 후 경추 측굴 스트레칭 즉시 병행 권장. 견갑골 상각 위는 견갑골 골막이므로 뼈 위 직접 압박 금지.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk',
  'osteoporosis, anticoagulant_therapy, acute_inflammation',
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

-- [19] Scalenes-TrP
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
  'Trigger Point Release — 경추 전방 근육',
  '사각근 트리거포인트 압박', 'Scalenes Trigger Point Release', 'Scalenes-TrP',
  'cervical'::body_region, 'C3–C6 횡돌기 ~ 1·2번 갈비뼈 (전·중·후 사각근)',
  '앙와위 — 경추 중립, 치료 측 어깨 약간 외전', '환자 머리 쪽 또는 옆쪽 — 접촉 손: 두 번째·세 번째 손가락 끝, 흉쇄유돌근 후방', '두 번째·세 번째 손가락 끝 — 흉쇄유돌근 후방 사각근 근복', '수직 내방 지속 압박',
  '[{"step":1,"instruction":"흉쇄유돌근 후방에서 전·중·후 사각근 순서로 압통점 탐색, 팔·어깨·검지·엄지 쪽으로 퍼지는 연관통 재현 확인"},{"step":2,"instruction":"손가락 끝으로 목표 압통점에 접촉 — 경동맥 박동 위치 확인 후 반드시 흉쇄유돌근 후방 유지"},{"step":3,"instruction":"VAS 5–7/10 압박 유지, 30–90초, 숨 내쉬면서 힘 빼도록 지시"},{"step":4,"instruction":"압통 감소 후 인접 부위 탐색, 2–3개 트리거포인트"},{"step":5,"instruction":"시술 후 경추 측굴 ROM 재평가, 팔 저림 증상 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement","neurodynamics"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_4'::evidence_level,
  '사각근 트리거포인트 압박 시 경동맥·내경정맥 위치 확인이 최우선 안전 조치. 흉쇄유돌근 전방 접촉 절대 금지. 팔 저림·전기 느낌 발생 즉시 위치 조정.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk, carotid_pathology',
  'osteoporosis, anticoagulant_therapy, acute_inflammation',
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

-- [20] SCM-TrP
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
  'Trigger Point Release — 경추 전방 근육',
  '흉쇄유돌근 트리거포인트 압박', 'Sternocleidomastoid Trigger Point Release', 'SCM-TrP',
  'cervical'::body_region, '흉쇄유돌근 전체 주행 (흉골·쇄골 ~ 유양돌기)',
  '앙와위 — 경추 중립, 치료 측 반대쪽으로 약간 회전', '환자 머리 쪽 또는 옆쪽, 접촉 손: 엄지·검지 핀서 그립(pincer grip)', '엄지·검지 핀서 그립 — 흉쇄유돌근 근복을 가볍게 집기', '핀서 그립으로 근복을 들어올려 압박',
  '[{"step":1,"instruction":"흉쇄유돌근 근복을 엄지·검지로 가볍게 집어 들어올림 — 근육을 혈관에서 분리한 후 압박 (경동맥 위 접촉 방지)"},{"step":2,"instruction":"근복 내 단단한 결절·압통점 탐색, 이마·눈·귀 방향 두통, 또는 현기증 연관통 재현 여부 확인"},{"step":3,"instruction":"VAS 5–7/10 핀서 그립 압박 유지, 30–60초, 숨 내쉬면서 힘 빼도록 지시"},{"step":4,"instruction":"흉골 부착부 → 쇄골 부착부 → 유양돌기 부착부 순으로 이동하며 탐색"},{"step":5,"instruction":"시술 후 경추 회전·측굴 ROM 재평가, 두통·현기증 강도 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_3'::evidence_level,
  '핀서 그립으로 SCM을 들어올려 경동맥에서 분리하는 것이 핵심 안전 기술. 경동맥 위를 압박하지 않도록 반드시 근육만 집기. SCM 트리거포인트는 이마·눈 두통과 현기증의 흔하지만 간과되는 원인.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk, carotid_pathology',
  'osteoporosis, anticoagulant_therapy, acute_inflammation',
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

-- [21] SubOcc-TrP
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
  'Trigger Point Release — 후두하 근육',
  '후두하 근육군 트리거포인트 압박', 'Suboccipital Trigger Point Release', 'SubOcc-TrP',
  'cervical'::body_region, '후두하 삼각 (상·하 두후두직근, 상·하 두사근)',
  '앙와위 — 머리 치료사 손으로 지지, 경추 약간 굴곡', '환자 머리 쪽 — 양손으로 머리를 받치며 손가락 끝이 후두하 삼각에 접촉', '두 번째·세 번째 손가락 끝 — 후두골 하연 바로 아래, 후두하 삼각', '수직 상방 압박 (두개골 방향으로)',
  '[{"step":1,"instruction":"후두골 하연 촉진 후 바로 아래 C1 수준에서 후두하 근육 탐색, 압통 최강 부위 확인"},{"step":2,"instruction":"손가락 끝으로 목표 압통점에 접촉, 이마·눈 쪽 두통 또는 경추 깊은 곳 통증 연관통 재현 확인"},{"step":3,"instruction":"VAS 5–7/10 압박 유지, 30–60초, 후두하 근육 이완 느낌 기다리기"},{"step":4,"instruction":"C1·C2 수준 양측 후두하 삼각 체계적 탐색, 2–4개 부위"},{"step":5,"instruction":"시술 후 경추 굴곡 ROM 재평가, 두통 강도 및 위치 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","vbi_risk"}',
  'level_3'::evidence_level,
  '후두하 트리거포인트는 경추성 두통의 가장 흔한 원인 중 하나 — 이마·눈 주변 두통이 특징적. 경추 과신전 금지 (VBI 위험). 시술 후 5분 안정 권고.',
  'fracture, instability, malignancy, neurological_deficit, vbi_risk',
  'osteoporosis, anticoagulant_therapy, acute_inflammation',
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

-- [22] UT-TrP
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
  'Trigger Point Release — 경추 후방 근육',
  '상부 승모근 트리거포인트 압박', 'Upper Trapezius Trigger Point Release', 'UT-TrP',
  'cervical'::body_region, '상부 승모근 (후두골 ~ 어깨 능형선 중간 부위)',
  '앙와위 또는 좌위 — 치료 측 어깨 이완, 경추 약간 반대쪽 측굴', '환자 옆쪽 또는 머리 쪽, 접촉 손: 엄지 끝 또는 핀서 그립', '엄지 끝 또는 핀서 그립 — 상부 승모근 근복 중간 (경추~어깨 능형선 중간)', '수직 하방 또는 핀서 그립 압박',
  '[{"step":1,"instruction":"상부 승모근 근복(경추~어깨 능형선 중간 부위)에서 가장 단단한 결절·압통점 탐색, 측두부·눈·턱 방향 두통 연관통 재현 확인"},{"step":2,"instruction":"엄지 끝 또는 핀서 그립으로 목표 압통점에 접촉"},{"step":3,"instruction":"VAS 5–7/10 압박 유지, 30–90초, 숨 내쉬면서 어깨 힘 빼도록 지시"},{"step":4,"instruction":"압통 감소 후 인접 부위(내측 섬유·외측 섬유) 탐색, 2–4개 부위"},{"step":5,"instruction":"시술 후 경추 측굴 ROM 재평가, 어깨 높이 비대칭 변화 관찰"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"acute","subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_2b'::evidence_level,
  '상부 승모근 트리거포인트는 임상에서 가장 흔하게 발견되는 연관통 원인. 측두부·귀 주변 두통이 특징적. 압박 후 경추 측굴 스트레칭(귀→어깨 방향) 즉시 병행 권장.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, anticoagulant_therapy, acute_inflammation',
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
-- LUMBAR (요추) — 18 techniques
-- ============================================================

-- [23] LumbART-ES
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
  'ART — 요추 척추세움근',
  '요추 척추세움근 능동적 이완기법', 'Active Release Technique — Lumbar Erector Spinae', 'LumbART-ES',
  'lumbar'::body_region, 'L1–L5 척추세움근 (장늑근·최장근)',
  '복와위 (엎드린 자세) — 배 아래 얇은 베개 선택적', '환자 옆쪽, 요추 수준 — 접촉 손: 엄지 또는 두 번째·세 번째 손가락 끝, 척추세움근 근복', '엄지 끝 — 극돌기 외측 2–4cm 척추세움근 근복', '접촉 유지 + 요추 굴곡 방향 능동 이동 (무릎 당기기 또는 상체 들기)',
  '[{"step":1,"instruction":"요추 척추세움근 촉진으로 가장 단단한 결절·압통점 탐색 (L3–L5 수준 빈도 높음)"},{"step":2,"instruction":"엄지 끝으로 목표 압통점에 접촉, 요추 신전 자세에서 시작"},{"step":3,"instruction":"접촉 유지하며 환자가 천천히 무릎을 가슴 쪽으로 당겨 요추 굴곡 (복와위에서 측와위로 전환 또는 슬관절 굴곡)"},{"step":4,"instruction":"요추 굴곡 끝 범위에서 접촉 해제, 자세 복귀 후 2–4회 반복"},{"step":5,"instruction":"시술 후 요추 굴곡·신전 ROM 재평가"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_4'::evidence_level,
  '척추세움근 ART 시 요추 과굴곡 주의 — 척추전방전위증 환자는 굴곡 범위 제한. 신경근 증상(다리 방사통) 유발 시 즉시 중단.',
  'fracture, instability, malignancy, neurological_deficit, acute_disc_herniation',
  'osteoporosis, spondylolisthesis_grade_2_above, anticoagulant_therapy',
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

-- [24] LumbART-MF
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
  'ART — 요추 심부 근육',
  '요추 다열근 능동적 이완기법', 'Active Release Technique — Lumbar Multifidus', 'LumbART-MF',
  'lumbar'::body_region, 'L1–L5 극돌기 외측 1–2cm (다열근 근복)',
  '복와위 또는 측와위 — 치료할 쪽이 위로', '환자 옆쪽, 요추 수준 — 접촉 손: 두 번째·세 번째 손가락 끝, 극돌기 외측 1–2cm 심부', '두 번째·세 번째 손가락 끝 — 극돌기 외측 1–2cm 심부 다열근', '접촉 유지 + 요추 분절 굴곡 방향 능동 이동',
  '[{"step":1,"instruction":"목표 분절 극돌기 외측 1–2cm에서 다열근 과민점·단단한 결절 탐색"},{"step":2,"instruction":"손가락 끝으로 목표 압통점 접촉, 요추 신전 자세에서 시작"},{"step":3,"instruction":"접촉 유지하며 환자가 천천히 요추 굴곡 (무릎 가슴 방향)"},{"step":4,"instruction":"굴곡 끝 범위에서 접촉 해제, 2–4회 반복"},{"step":5,"instruction":"시술 후 요추 ROM 재평가, 다열근 활성화 운동(버드독) 처방"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_5'::evidence_level,
  '요추 다열근 ART 후 반드시 신경근 조절 운동 병행 — 다열근은 압박만으로 기능 회복 불충분. 극돌기 직접 접촉 금지.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, spondylolisthesis_grade_2_above, anticoagulant_therapy',
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

-- [25] LumbCTM-LHJ
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
  'Connective Tissue Massage (CTM) — 요추-골반-고관절 이행부',
  '요추-고관절 이행부 결합조직 마사지', 'Lumbopelvic Connective Tissue Massage', 'LumbCTM-LHJ',
  'lumbar'::body_region, '장골능~천골~대전자 구역 (요추-골반-고관절 이행부)',
  '측와위 — 치료할 쪽이 위로, 무릎 약간 굴곡. 대안: 복와위', '환자 뒤쪽, 골반 수준 — 접촉 손: 세 번째·네 번째 손가락 지문면', '세 번째·네 번째 손가락 지문면 — 장골능 아래 → 천골 외측 → 대전자 주변 순서', 'Zuggriff — 장골능 따라 전방·후방, 천골 방향 하행, 대전자 방향 원위',
  '[{"step":1,"instruction":"장골능~천골 외측~대전자 구역 집어보기 평가 — 두터움·유착 부위 확인, 양측 비교"},{"step":2,"instruction":"장골능 구역 기저 스트로크 — 전방에서 후방으로 Zuggriff 5–8회"},{"step":3,"instruction":"천골 외측 구역 — 상방에서 하방으로 Zuggriff 5–8회, 천결절인대 부착부 근처 포함"},{"step":4,"instruction":"대전자 주변 구역 — 대전자 위쪽~외측 Zuggriff 5–8회 (대전자 중앙 점액낭 위치 피하기)"},{"step":5,"instruction":"시술 후 요추 측굴·고관절 외전 ROM 재평가, 조직 대칭성 개선 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","skin_lesion"}',
  'level_5'::evidence_level,
  '3개 구역(장골능→천골 외측→대전자)을 하나의 연속 치료로 — 분리하지 않고 흐르듯 이어서 치료. 대전자 외측면 중앙(점액낭 위치) 직접 접촉 금지. CTM은 6–10회 연속 세션에서 효과 누적.',
  'fracture, malignancy, neurological_deficit, open_wound, skin_infection, acute_trochanteric_bursitis',
  'osteoporosis, pregnancy, diabetes_neuropathy, high_skin_sensitivity',
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

-- [26] LumbCTM-Lat
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
  'Connective Tissue Massage (CTM) — 요추 측방 구역',
  '요추 측방 결합조직 마사지', 'Lumbar Lateral Connective Tissue Massage', 'LumbCTM-Lat',
  'lumbar'::body_region, 'L1–L5 측방 구역, 장골능 위쪽 측방',
  '측와위 — 치료할 쪽이 위로. 대안: 좌위', '환자 뒤쪽, 요추 측방 수준 — 접촉 손: 세 번째·네 번째 손가락 지문면', '세 번째·네 번째 손가락 지문면 — 요추 측방, 장골능 위쪽 ~ L1 수준 측방', 'Zuggriff — 피부·피하층 경계를 진행 방향으로 당기기 (하행 또는 상행)',
  '[{"step":1,"instruction":"요추 측방 결합 조직 상태 평가 — 집어보기로 유착·두께 확인"},{"step":2,"instruction":"기저 스트로크 — 척추 중앙에서 외측 방향으로 가볍게 Zuggriff 3–5회"},{"step":3,"instruction":"L1에서 장골능 방향(하행) Zuggriff 집중, 10–20 스트로크"},{"step":4,"instruction":"장골능에서 L1 방향(상행) 스트로크로 반복, 조직 반응(붉어짐) 확인"},{"step":5,"instruction":"시술 후 요추 측굴 ROM 재평가, 조직 상태 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","skin_lesion"}',
  'level_3'::evidence_level,
  'Zuggriff는 피부를 문지르는 것이 아닌 "당기는" 기법 — 손가락이 피부 위에서 미끄러지면 CTM이 아닌 일반 마찰 마사지가 됨. 자율신경 반응 모니터링 필수.',
  'fracture, instability, malignancy, neurological_deficit, open_wound, skin_infection',
  'osteoporosis, diabetes_neuropathy, high_skin_sensitivity, pregnancy',
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

-- [27] CTM-SL
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
  'Connective Tissue Massage (CTM) — 요추-천골 구역',
  '요추-천골 구역 결합조직 마사지', 'Sacral-Lumbar Connective Tissue Massage', 'CTM-SL',
  'lumbar'::body_region, 'L4–S2 구역 (요추-천골 이행부, 천골 후면)',
  '복와위 (엎드린 자세) — 기본 권장. 대안: 측와위', '환자 옆쪽, 요천부 수준 — 접촉 손: 세 번째·네 번째 손가락 지문면', '세 번째·네 번째 손가락 지문면 — L4–S2 구역 피하층', 'Zuggriff — 요추 방향(두측) 또는 천골 미측 방향으로 당기기',
  '[{"step":1,"instruction":"L4–S2 구역 결합 조직 상태 집어보기 평가 — 천골 후면 유착·두께 확인"},{"step":2,"instruction":"기저 스트로크 — L4 수준에서 천골 방향(하방)으로 가볍게 3–5회"},{"step":3,"instruction":"요천 이행부(L5–S1) 구역 집중 Zuggriff 5–8회"},{"step":4,"instruction":"천골 외측연으로 이동하여 추가 스트로크, 조직 반응 확인"},{"step":5,"instruction":"시술 후 요추 굴곡·신전 ROM 재평가, 천장관절 증상 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","skin_lesion"}',
  'level_4'::evidence_level,
  '요천부 CTM은 천장관절 기능 이상 동반 만성 요통에서 유용. 피부 반사구역(L1–S2 분절)을 통한 자율신경 조절 효과 기대. 세션 간 48–72시간 간격 필수.',
  'fracture, malignancy, neurological_deficit, open_wound, skin_infection',
  'osteoporosis, pregnancy, diabetes_neuropathy, high_skin_sensitivity',
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

-- [28] LumbDFM-ILL
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
  'Deep Friction Massage — 요추 인대',
  '장골요추 인대 심부마찰 마사지', 'Deep Friction Massage — Iliolumbar Ligament', 'LumbDFM-ILL',
  'lumbar'::body_region, 'L4–L5 횡돌기 ~ 장골능 내측 (장골요추 인대 주행)',
  '측와위 — 치료할 쪽이 위로. 대안: 복와위', '환자 뒤쪽 또는 옆쪽, L4–L5 횡돌기 수준 — 접촉 손: 두 번째 손가락 끝', '두 번째 손가락 끝 — 장골능 내측연에서 L4–L5 횡돌기 방향 인대 부착부', '횡방향(transverse) 마찰 — 인대 섬유에 수직',
  '[{"step":1,"instruction":"장골능 내측연에서 L4–L5 횡돌기 방향으로 장골요추 인대 부착부 촉진, 압통 최강 부위 확인"},{"step":2,"instruction":"손가락 끝으로 목표 부위에 수직 접촉 확보 — 조직 표면 접촉이 아닌 조직 내 접촉"},{"step":3,"instruction":"횡방향 마찰 시작 — 왕복 동작, 인대 섬유에 수직 방향, 60–120초"},{"step":4,"instruction":"마찰 강도 점진적 증가 — VAS 4–6/10 유지, 환자 반응 모니터링"},{"step":5,"instruction":"시술 후 요추 굴곡·측굴 ROM 재평가, 장골요추 인대 압통 강도 비교"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","acute_inflammation"}',
  'level_3'::evidence_level,
  '장골요추 인대는 L4–L5 전위 방지의 핵심 구조물 — 압통 시 불안정성 여부 먼저 평가 후 적용. Cyriax 기반 횡방향 마찰은 인대 섬유 재정렬 및 혈류 개선에 작용.',
  'fracture, instability, malignancy, neurological_deficit, acute_inflammation',
  'osteoporosis, anticoagulant_therapy',
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

-- [29] LumbIASTM-ES
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
  'category_iastm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_iastm'),
  'IASTM — 요추 척추세움근',
  '요추 척추세움근 IASTM', 'IASTM — Lumbar Erector Spinae', 'LumbIASTM-ES',
  'lumbar'::body_region, 'L1–L5 척추세움근 (극돌기 외측 2–5cm)',
  '복와위 — 배 아래 얇은 베개 선택적', '환자 옆쪽, 요추 수준 — IASTM 도구: 대형 또는 중형 도구', 'IASTM 도구 날 또는 오목면 — 척추세움근 근막층 (극돌기 외측 2–5cm)', '두측→미측(상방→하방) 또는 미측→두측 방향 스트로크',
  '[{"step":1,"instruction":"요추 척추세움근 전체 스캐닝 스트로크 — 유착·거칠음 느껴지는 구역 표시"},{"step":2,"instruction":"흉요 이행부(T12–L2)에서 장골능 방향으로 치료 스트로크 시작, 30–45° 도구 각도"},{"step":3,"instruction":"유착 집중 구역에서 반복 스트로크, 국소 붉어짐(petechiae) 확인"},{"step":4,"instruction":"극돌기 외측 2–5cm 구역만 접촉 — 척추 뼈 직접 접촉 금지"},{"step":5,"instruction":"시술 후 요추 굴곡·신전 ROM 재평가, 척추세움근 촉감 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","skin_lesion","anticoagulant"}',
  'level_3'::evidence_level,
  '요추 IASTM 시 극돌기 및 신장 위치(신장 부위)는 피하여 요추 옆 근육 구역만 접촉. 항응고제 복용 환자 절대 금지. petechiae는 정상 반응이나 과도한 경우 강도 감소.',
  'fracture, instability, malignancy, neurological_deficit, open_wound, skin_infection, anticoagulant_therapy',
  'osteoporosis, acute_inflammation, diabetes_neuropathy',
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

-- [30] LumbIASTM-MF
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
  'category_iastm',
  (SELECT id FROM technique_categories WHERE category_key = 'category_iastm'),
  'IASTM — 요추 심부 근육',
  '요추 다열근 IASTM', 'IASTM — Lumbar Multifidus', 'LumbIASTM-MF',
  'lumbar'::body_region, 'L1–L5 극돌기 외측 1–2cm (다열근 근막층)',
  '복와위 또는 측와위 — 치료할 쪽이 위로', '환자 옆쪽, 요추 수준 — IASTM 도구: 소형 또는 중형 날카로운 도구', 'IASTM 도구 날 부분 — 극돌기 외측 1–2cm 다열근 표재 근막', '두측→미측 방향 스트로크 (짧은 스트로크 반복)',
  '[{"step":1,"instruction":"극돌기 외측 1–2cm에서 다열근 표재 근막 스캐닝 — 유착 구역 확인"},{"step":2,"instruction":"소형 도구 날로 극돌기 외측 1–2cm 구역 집중 스트로크, 짧은 왕복 동작"},{"step":3,"instruction":"유착 부위 집중 반복 — petechiae 확인"},{"step":4,"instruction":"L3–L5 (빈도 높은 분절) 우선 치료 후 상위 분절로 이동"},{"step":5,"instruction":"시술 후 요추 ROM 재평가, 다열근 활성화 운동 처방"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit","skin_lesion","anticoagulant"}',
  'level_5'::evidence_level,
  '다열근 IASTM 후 반드시 신경근 조절 운동 병행 — IASTM은 근막 이동성 회복이 목적, 근육 기능 회복은 운동이 담당. 극돌기 직접 접촉 절대 금지.',
  'fracture, instability, malignancy, neurological_deficit, open_wound, skin_infection, anticoagulant_therapy',
  'osteoporosis, acute_inflammation',
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

-- [31] Lumbar MFR
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
  'Myofascial Release (MFR) — 요추 전체',
  '요추 근막이완 기법', 'Lumbar Myofascial Release', 'Lumbar MFR',
  'lumbar'::body_region, 'L1–L5 요추 전체 (흉요근막·척추세움근·다열근 근막층)',
  '복와위 — 배 아래 얇은 베개 선택적. 대안: 측와위', '환자 옆쪽, 요추 수준 — 손바닥 전체 또는 전완 접촉', '손바닥 전체 또는 전완 — 흉요근막 표재층', '부드러운 지속 압박 + 두측 또는 미측 방향 견인',
  '[{"step":1,"instruction":"손바닥 전체로 요추 후방(흉요근막) 표재층에 가볍게 접촉, 이동 제한 방향 탐색"},{"step":2,"instruction":"제한 방향으로 부드럽게 견인하며 3–5분 대기 — 조직 이완 느낌 확인"},{"step":3,"instruction":"표재층 이완 후 중간층(척추세움근 근막)으로 접촉 깊이 조정"},{"step":4,"instruction":"크로스핸드 기법 — 한 손은 흉요 이행부, 다른 손은 천골에 위치, 반대 방향 견인 5–7분"},{"step":5,"instruction":"시술 후 요추 전방향 ROM 재평가, 하지직거상(SLR) 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_2b'::evidence_level,
  'MFR은 각 레이어에서 최소 3–5분 기다려야 효과 — 강하게 빠르게 하면 MFR이 아님. 크로스핸드 기법이 요추 전체 근막을 한 번에 다루는 가장 효율적 접근. ASLR test로 효과 전후 평가.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, pregnancy_second_third_trimester, acute_sacroiliac_inflammation',
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

-- [32] TLF MFR
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
  'Myofascial Release (MFR) — 흉요근막',
  '흉요근막 이완 기법', 'Thoracolumbar Fascia Myofascial Release', 'TLF MFR',
  'lumbar'::body_region, 'T12–L5 흉요근막 전체 (후층·중층)',
  '복와위 — 기본 권장. 대안: 측와위', '환자 옆쪽, 흉요 이행부 수준 — 전완 또는 손바닥 전체 접촉', '전완(forearm) 또는 손바닥 전체 — 흉요근막 후층', '두측↔미측 교차 방향 견인 (흉요근막 전체 신장)',
  '[{"step":1,"instruction":"전완 또는 손바닥으로 흉요근막 표재층(T12–L5) 전체에 가볍게 접촉, 긴장 패턴 탐색"},{"step":2,"instruction":"두측 방향으로 부드럽게 견인 — 흉요근막 두측 부착부(T12 수준) 신장, 3–5분"},{"step":3,"instruction":"미측 방향으로 견인 방향 변경 — 흉요근막 미측 부착부(천골·장골) 신장"},{"step":4,"instruction":"크로스핸드 기법 — 두 손을 대각선 방향으로 견인하여 흉요근막 전체 균일 신장"},{"step":5,"instruction":"시술 후 요추 굴곡·신전 ROM 재평가, 체간 회전 변화 확인"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_3'::evidence_level,
  '흉요근막은 광배근·복횡근·둔근과 연결 — TLF MFR은 요추뿐만 아니라 체간·골반 전체 운동 패턴에 영향. 전완 접촉이 넓은 면적의 흉요근막을 효율적으로 다룸.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, pregnancy_second_third_trimester, acute_inflammation',
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

-- [33] LumbMFR-LPJ
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
  'Myofascial Release (MFR) — 요추-골반 이행부',
  '요추-골반 이행부 근막이완 기법', 'Lumbopelvic Junction Myofascial Release', 'LumbMFR-LPJ',
  'lumbar'::body_region, 'L4–S1 이행부, 장골능~천골 구간',
  '복와위 — 기본 권장. 대안: 측와위', '환자 옆쪽, L4–S1 수준 — 손바닥 전체 또는 손끝 다층 접근', '손바닥 전체 → 손끝 → 엄지 (레이어별 순차 접근)', '크로스핸드 — 한 손 L4 두측, 다른 손 천골 미측으로 반대 방향 견인',
  '[{"step":1,"instruction":"손바닥 전체로 L4–S1 표재층(흉요근막 후층) 접촉, 이동 제한 탐색, 3–5분 대기"},{"step":2,"instruction":"표재층 이완 후 손끝으로 중간층(척추세움근 근막) 진입, 같은 방식 이완 대기"},{"step":3,"instruction":"크로스핸드 견인 — 한 손 L4, 다른 손 천골, 반대 방향으로 부드럽게 5–7분 유지"},{"step":4,"instruction":"장골능 내측(장요인대 부착부) 추가 탐색 및 견인"},{"step":5,"instruction":"시술 후 요추 전방향 ROM 재평가, ASLR test 재검사"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_5'::evidence_level,
  'ASLR test(능동 직거상검사)로 시술 전후 효과 평가. 레이어당 최소 3–5분 대기 필수. 크로스핸드 기법이 요추-천골 이행부 전체 근막을 한 번에 다루는 핵심 접근.',
  'fracture, instability, malignancy, neurological_deficit, acute_sacroiliac_inflammation',
  'osteoporosis, pregnancy_second_third_trimester, sacroiliac_instability',
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

-- [34] LumbMFR-Pir
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
  'Myofascial Release (MFR) — 골반 심부 외회전근',
  '이상근 근막이완 기법', 'Piriformis Myofascial Release', 'LumbMFR-Pir',
  'lumbar'::body_region, '천골 외측면 ~ 대전자 (이상근 주행 경로)',
  '측와위 — 치료할 쪽이 위로, 고관절 60–90° 굴곡. 대안: 복와위', '환자 뒤쪽, 고관절 수준 — 손바닥 전체 또는 엄지, 이상근 근복 접촉', '손바닥 전체 또는 엄지 지문면 — 천골 외측연과 대전자 중간 (이상근 근복)', '수직 하방 부드러운 지속 압박 — 조직이 이완될 때까지 기다리기',
  '[{"step":1,"instruction":"이상근 위치 확인 (대전자와 천골 외측연 중간), 손바닥 또는 엄지로 표재층(대둔근) 접촉"},{"step":2,"instruction":"호흡에 맞춰 내쉬는 순간마다 서서히 깊이 진입 — 대둔근 통과하여 이상근 수준까지"},{"step":3,"instruction":"이상근 근막 접촉 확인 후 3–5분 이완 대기 — 조직이 허락하는 방향으로만 이동"},{"step":4,"instruction":"이상근 주행 방향을 따라 천골 부착부 → 대전자 부착부 방향으로 순서대로 탐색"},{"step":5,"instruction":"시술 후 고관절 내회전 ROM 재평가, 이상근 스트레칭(피겨4) 처방"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_5'::evidence_level,
  'MFR 중 찌릿·전기 느낌 발생 즉시 접촉 조정 또는 중단. 신경학적 결손 확인이 전제 조건. 트리거포인트 압박보다 부드러운 기법으로 통증 민감성 높은 환자에게 우선 적용.',
  'fracture, malignancy, neurological_deficit, hip_dislocation, early_hip_replacement',
  'osteoporosis, pregnancy, acute_trochanteric_bursitis, anticoagulant_therapy',
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

-- [35] LumbMFR-Psoas
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
  'Myofascial Release (MFR) — 요추·골반 심부 근육',
  '장요근 근막이완 기법', 'Psoas Myofascial Release', 'LumbMFR-Psoas',
  'lumbar'::body_region, 'L1–L5 전방, 장골와 (장요근 전체 주행 경로)',
  '앙와위 — 무릎 아래 볼스터로 완전 이완 자세', '환자 옆쪽, 복부 전방 접근 — 손가락 끝으로 복직근 외측연 안쪽 접근', '두 번째·세 번째·네 번째 손가락 끝 — 배꼽 외측 3–5cm, 복직근 외측연 안쪽', '수직 하방 서서히 — 복부 내용물 밀어내며 장요근 근막에 도달',
  '[{"step":1,"instruction":"환자 완전 이완 확인, 무릎 아래 볼스터 위치, 2–3회 깊은 호흡 유도"},{"step":2,"instruction":"배꼽 외측 3–5cm, 복직근 외측연에 손가락 끝 가볍게 접촉, 호흡에 맞춰 내쉬는 순간마다 0.5–1cm씩 서서히 진입"},{"step":3,"instruction":"장요근 근막 접촉 확인 (단단한 저항감) — 허리 앞쪽 깊은 곳 당기는 느낌이 적절한 반응, 4–5분 이완 대기"},{"step":4,"instruction":"조직이 이완되면서 손가락이 자연스럽게 깊어지는 느낌 확인 — 억지로 밀지 않기"},{"step":5,"instruction":"시술 후 고관절 신전 ROM(Thomas test) 재평가, 런지 자세 스트레칭 처방"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_5'::evidence_level,
  '복부 대동맥류(AAA) 스크리닝 필수 — 배꼽 주변 박동성 덩어리 시 즉시 중단. 임신 모든 시기 절대 금지. 복부 수술 6개월 이내 금지. 억지로 밀지 않기 — "기다리는 기법".',
  'fracture, malignancy, neurological_deficit, abdominal_aortic_aneurysm, pregnancy, abdominal_surgery_within_6months, peritonitis',
  'osteoporosis, irritable_bowel_syndrome, active_kidney_stones',
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

-- [36] QL-TPR
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
  'Trigger Point Release — 요추부 측방 심부 근육',
  '허리네모근 트리거포인트 압박', 'Quadratus Lumborum Trigger Point Release', 'QL-TPR',
  'lumbar'::body_region, 'L1–L4 외측, 12번 갈비뼈 ~ 장골능 (허리네모근)',
  '측와위 — 치료할 쪽이 위로. 대안: 복와위', '환자 뒤쪽, 엄지 끝 또는 팔꿈치 올레크라논 — 척추 외측 4–5cm 지점', '엄지 끝 또는 팔꿈치 올레크라논 — 장골능 바로 위, 척추 외측 4–5cm', '수직 하방 또는 약간 내측·상측 방향 지속 압박',
  '[{"step":1,"instruction":"장골능 위 1–2횡지 지점, 척추 외측 4–5cm에서 단단한 근육 띠·압통점 탐색 — 엉덩이·허벅지 방향 연관통 재현 확인"},{"step":2,"instruction":"엄지 또는 팔꿈치로 목표 압통점에 수직 접촉, VAS 5–7/10 압박"},{"step":3,"instruction":"숨 내쉬면서 근육 힘 빼도록 지시, 30–90초 압박 유지"},{"step":4,"instruction":"압통 감소 후 2–3cm 이동하며 2–3개 트리거포인트 추가 탐색"},{"step":5,"instruction":"시술 후 요추 측굴 ROM 재평가, 반대쪽 측굴 스트레칭 처방"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_3'::evidence_level,
  '신장(콩팥) 통증과 감별 필수 — QL 통증은 움직임에 따라 변하나 신장 통증은 지속·발열·혈뇨 동반. 팔꿈치 압박이 치료사 손 부담 감소에 효과적. 척추 극돌기에서 3–5cm 외측 근육 구역만 접촉.',
  'fracture, instability, malignancy, neurological_deficit',
  'osteoporosis, acute_inflammation, pregnancy, anticoagulant_therapy',
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

-- [37] LumbTrP-GluMed
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
  'Trigger Point Release — 요통 연관 둔부 근육',
  '중둔근 트리거포인트 압박', 'Gluteus Medius Trigger Point Release', 'LumbTrP-GluMed',
  'lumbar'::body_region, '장골능 아래, 대전자 위쪽 — 중둔근 전·중·후부',
  '측와위 — 치료할 쪽이 위로. 대안: 복와위', '환자 뒤쪽, 엉덩이 외측 — 엄지 또는 팔꿈치 올레크라논', '엄지 지문면 또는 팔꿈치 올레크라논 — 장골능 아래 ~ 대전자 위쪽 중간 (중둔근 전·중·후부)', '수직 하방 또는 대전자 방향으로 약간 기울여',
  '[{"step":1,"instruction":"장골능 아래에서 대전자 방향으로 중둔근 전·중·후부를 순서대로 촉진, 단단한 근육 띠·압통점 탐색 — 허리·엉덩이·허벅지 연관통 재현 확인"},{"step":2,"instruction":"엄지 또는 팔꿈치로 활성 트리거포인트에 수직 접촉"},{"step":3,"instruction":"VAS 5–7/10 압박 유지, 30–90초, 숨 내쉬면서 엉덩이 힘 빼도록 지시"},{"step":4,"instruction":"중둔근 후부(요통 연관통 주요 원인) 중점 탐색, 총 2–4개 부위"},{"step":5,"instruction":"시술 후 요추·고관절 ROM 재평가, 한 발 서기 안정성 변화 관찰, 강화 운동 처방"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_4'::evidence_level,
  '중둔근 TrP 연관통은 좌골신경통과 혼동되기 쉬움 — 신경학적 결손(근력·반사·감각) 없는 경우만 적용. 대전자(뼈 돌기) 위 직접 압박 금지. 중둔근 후부 섬유가 요통 연관통의 주요 원인.',
  'fracture, malignancy, neurological_deficit, confirmed_sciatica_with_deficit, early_hip_dislocation',
  'osteoporosis, acute_trochanteric_bursitis, pregnancy, anticoagulant_therapy',
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

-- [38] LumbTrP-IL
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
  'Trigger Point Release — 요추부 척추세움근',
  '장늑근 트리거포인트 압박', 'Iliocostalis Lumborum Trigger Point Release', 'LumbTrP-IL',
  'lumbar'::body_region, 'L1–L5 외측, 척추세움근 최외측 열',
  '복와위 — 기본 권장. 대안: 측와위', '환자 옆쪽, 요추 수준 — 엄지 끝 또는 팔꿈치 올레크라논', '엄지 끝 또는 팔꿈치 올레크라논 — 극돌기 외측 3–5cm (장늑근 근복)', '수직 하방 지속 압박',
  '[{"step":1,"instruction":"극돌기 외측 3–5cm에서 장늑근 근복 촉진, 단단한 결절·압통점 탐색 — 엉덩이·복부·사타구니 연관통 재현 확인"},{"step":2,"instruction":"엄지 또는 팔꿈치로 목표 압통점에 수직 접촉"},{"step":3,"instruction":"VAS 5–7/10 압박, 30–90초, 숨 내쉬면서 힘 빼도록 지시"},{"step":4,"instruction":"L1–L5 범위에서 2–4개 부위 탐색, 12번 갈비뼈 부착부 근처도 확인"},{"step":5,"instruction":"시술 후 요추 신전·측굴 ROM 재평가, 반대쪽 측굴 스트레칭 처방"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_5'::evidence_level,
  '신장 통증과 감별 필수. 복부 연관통을 내장 문제로 혼동하지 않도록 사전 설명. 극돌기 극측 1–2cm는 다열근 영역 — 장늑근은 반드시 극돌기 외측 3–5cm에서 접근.',
  'fracture, instability, malignancy, neurological_deficit, acute_kidney_disease',
  'osteoporosis, acute_inflammation, pregnancy, anticoagulant_therapy',
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

-- [39] LumbTrP-MF
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
  'Trigger Point Release — 요추부 심부 근육',
  '요추 다열근 트리거포인트 압박', 'Lumbar Multifidus Trigger Point Release', 'LumbTrP-MF',
  'lumbar'::body_region, 'L1–L5, 척추 극돌기 외측 1–2cm 심부',
  '복와위 — 기본 권장. 대안: 측와위', '환자 옆쪽, 요추 수준 — 엄지 또는 두 번째·세 번째 손가락 끝', '엄지 지문면 또는 두 번째·세 번째 손가락 끝 — 극돌기 외측 1–2cm 다열근 근복', '수직 하방, 또는 척추 방향으로 약간 기울여 (15° 이내)',
  '[{"step":1,"instruction":"극돌기 외측 1–2cm에서 단단한 결절·압통점 탐색 (L3–L5 빈도 높음), 엉덩이·허벅지 연관통 재현 확인"},{"step":2,"instruction":"엄지 끝으로 목표 압통점에 접촉, 환자에게 연관통 패턴 사전 설명"},{"step":3,"instruction":"VAS 5–7/10 압박, 30–90초, 숨 내쉬면서 힘 빼도록 지시"},{"step":4,"instruction":"압통 감소 후 인접 분절 탐색, 총 2–4개 부위"},{"step":5,"instruction":"시술 후 요추 ROM 재평가, 다열근 활성화 운동(버드독·데드버그) 처방"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic","hypomobile"}',
  '{"movement_pain","rest_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_4'::evidence_level,
  '다열근은 압박만으로 기능 회복 불충분 — 압박 후 반드시 버드독·데드버그 등 신경근 조절 운동 병행. 극돌기 직접 압박 금지. 호흡 연동으로 점진적 접촉 효과적.',
  'fracture, instability, malignancy, neurological_deficit, spinal_stenosis_severe',
  'osteoporosis, acute_inflammation, pregnancy, spondylolisthesis_grade_1',
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

-- [40] LumbTrP-Pir
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
  'Trigger Point Release — 요통 연관 심부 외회전근',
  '이상근 트리거포인트 압박', 'Piriformis Trigger Point Release', 'LumbTrP-Pir',
  'lumbar'::body_region, '천골(sacrum) 앞면 ~ 대전자 (이상근 주행 경로)',
  '측와위 — 치료할 쪽이 위로, 고관절 60–90° 굴곡. 대안: 복와위', '환자 뒤쪽 또는 옆쪽, 고관절 수준 — 엄지 또는 팔꿈치 올레크라논', '엄지 끝 또는 팔꿈치 올레크라논 — 천골 외측연과 대전자 중간 지점 (이상근 근복)', '수직 하방, 천골 방향으로 약간 기울여',
  '[{"step":1,"instruction":"대전자와 천골 외측연 중간 선상에서 이상근 근복 탐색, 단단한 결절·압통점 확인 — 엉덩이·허벅지 후측 연관통 재현 확인"},{"step":2,"instruction":"엄지 또는 팔꿈치로 목표 압통점에 접촉 — 대둔근 통과하여 이상근 수준까지 점진적 접근"},{"step":3,"instruction":"VAS 5–7/10 압박, 30–90초, 숨 내쉬면서 엉덩이 힘 완전히 빼도록 지시"},{"step":4,"instruction":"이상근 주행 방향을 따라 천골 부착부 ~ 대전자 부착부 2–3개 부위 탐색"},{"step":5,"instruction":"시술 후 고관절 내회전 ROM 재평가, 이상근 스트레칭(피겨4) 처방"}]'::jsonb,
  '{"pain_relief","rom_improvement"}', '{"subacute","chronic"}',
  '{"movement_pain","rest_pain","radicular_pain"}', '{"fracture","instability","malignancy","neurological_deficit"}',
  'level_4'::evidence_level,
  '신경학적 결손 먼저 스크리닝 필수. 표재층만 압박하고 이상근에 미도달하는 것이 가장 흔한 실수 — 대둔근 통과 확인. 좌골신경 주행 부위(좌골 결절 내측) 직접 압박 금지.',
  'fracture, malignancy, neurological_deficit, hip_dislocation, early_hip_replacement',
  'osteoporosis, pregnancy, acute_deep_gluteal_bursitis, anticoagulant_therapy',
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
-- END: 경추 22개 + 요추 18개 = 총 40개 INSERT 완료
-- ============================================================

COMMIT;
