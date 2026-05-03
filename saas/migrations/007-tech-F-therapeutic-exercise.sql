-- ============================================================
-- K-Movement Optimism — Migration 007
-- 치료적 운동 (category_f_therapeutic_exercise) 9개
-- 생성일: 2026-04-25
-- 항목: tech-F-001 ~ tech-F-009
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- ⚠️  실행 순서 필수:
--     1단계: 007a-therapeutic-exercise-enum.sql 먼저 실행 (ENUM 확장 커밋)
--     2단계: 이 파일 실행 (카테고리 + 테크닉 9개 INSERT)
-- ============================================================

-- ============================================================
-- STEP 1: 카테고리 INSERT
-- ============================================================

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_f_therapeutic_exercise',
  '치료적 운동',
  'Therapeutic Exercise',
  '근거기반 운동치료 프로토콜',
  '[
    {"icon":"🎯","title_ko":"방향성 선호 우선","desc_ko":"MDT 원칙에 따라 증상 집중화 방향을 먼저 파악하고 운동 방향을 결정합니다."},
    {"icon":"🧠","title_ko":"신경운동 조절 재훈련","desc_ko":"심부 안정화 근육(복횡근, 다열근)의 선택적 활성화부터 시작하여 기능적 통합으로 진행합니다."},
    {"icon":"📈","title_ko":"점진적 과부하","desc_ko":"통증 신호가 아닌 기능 목표(Quota)를 기반으로 활동량을 단계적으로 증가시킵니다."},
    {"icon":"🔄","title_ko":"자가관리 교육","desc_ko":"환자 스스로 재발 시 처방 가능하도록 독립적 운동 역량을 키우는 것이 궁극적 목표입니다."},
    {"icon":"💬","title_ko":"통증 신경과학 통합","desc_ko":"통증은 손상 신호가 아닌 위협 신호임을 교육하여 두려움-회피 행동을 개선합니다."}
  ]'::jsonb,
  6,
  true,
  'group_exercise'
)
ON CONFLICT (category_key) DO NOTHING;

-- ============================================================
-- STEP 2: 테크닉 INSERT (9개)
-- ============================================================

-- ────────────────────────────────
-- tech-F-001: 경추 고유감각 운동
-- ────────────────────────────────
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  description,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  key_references,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_f_therapeutic_exercise',
  (SELECT id FROM technique_categories WHERE category_key = 'category_f_therapeutic_exercise'),
  'Neuromuscular Training',
  '경추 고유감각 운동', 'Cervical Proprioceptive Exercise', 'CervProp-Ex',
  'cervical'::body_region, 'C1-C7 전체',
  '좌위(앉은 자세), 머리/경추 중립, 등받이 없는 의자, 팔 무릎 위에 자연스럽게, 레이저 포인터 헤드밴드(선택)', '환자 옆 또는 앞에 서서 움직임 관찰, 직접 접촉 없음(관찰 및 언어 피드백 제공)', '해당 없음 (능동 운동)', '해당 없음 (능동 운동)',
  '경추 고유감각 운동은 목의 위치 감각(고유감각, proprioception)을 회복시키기 위한 치료적 운동입니다. 신경계는 목 주변 관절과 근육에서 위치 정보를 끊임없이 수집하는데, 오랜 통증이나 비활동으로 이 감각 처리 능력이 둔해질 수 있습니다. 이 운동은 눈을 감거나 레이저 포인터를 이용해 머리의 움직임을 정확하게 조절하는 훈련을 포함하며, 뇌와 목 근육 사이의 소통을 되살리는 것이 목적입니다.',
  '[{"step":1,"instruction":"기준 위치 설정: 환자가 눈을 뜬 상태에서 편안한 중립 자세를 취하게 한다. 벽의 타겟 포인트를 정면에 설정하거나 레이저 포인터를 헤드밴드에 부착한다."},{"step":2,"instruction":"머리 재위치 훈련: 환자가 눈을 감은 후, 고개를 좌 또는 우로 15-30도 회전하게 한다. 그 후 천천히 중립으로 돌아오도록 지시한다. 눈을 뜨고 실제 중립과 비교하여 오차를 확인한다."},{"step":3,"instruction":"레이저 포인터 추적 훈련: 레이저 포인터를 사용할 경우, 벽의 타겟 원(직경 2-5cm)에서 시작하여 주어진 패턴(원, 숫자, 알파벳)을 천천히 따라 그리게 한다."},{"step":4,"instruction":"반복 및 점진적 난이도 증가: 처음에는 간단한 회전, 이후 굴곡/신전, 측방 굴곡, 복합 운동으로 난이도를 높인다. 눈 감기 -> 불안정 표면 사용 -> 이중 과제(숫자 세기) 순서로 진행."},{"step":5,"instruction":"재평가: 10세션 후 머리 재위치 정확도(HRA) 및 NRS, CROM 재측정. 개선 확인 후 다음 단계 진행."}]'::jsonb,
  '{"pain_relief","proprioception_training","rom_improvement"}', '{"subacute","chronic","office_worker"}', '{"neck_pain_nonspecific","neck_pain_chronic","movement_pain","cervical_stiffness"}', '{"fracture","malignancy","instability","vbi_risk","neurological_deficit"}',
  'level_1b'::evidence_level,
  '[{"pmid":"33047944","title":"Efficacy of a proprioceptive exercise program in nonspecific neck pain (Espi-Lopez 2020)","year":2020},{"pmid":"32723399","title":"Manual therapy versus therapeutic exercise in non-specific chronic neck pain (2020)","year":2020}]'::jsonb,
  '즉각적인 피드백이 핵심 - 눈을 뜨고 실제 위치와 비교하는 과정이 신경 재학습의 핵심. 오류를 확인하는 과정 자체가 치료임. 레이저 포인터 없이도 거울 앞에서 동일한 훈련 가능. 하루 2-3회, 5분씩 홈프로그램 권장.',
  '골절(확인 또는 의심), 종양/악성 질환(경추), 척추 불안정성, 신경학적 결손, 척추동맥 혈액순환 장애(VBI) 위험, 중증 어지럼증/현훈(미감별)', '급성 염증기, 심한 어지럼증 병력, 골다공증',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko                    = EXCLUDED.name_ko,
  name_en                    = EXCLUDED.name_en,
  body_region                = EXCLUDED.body_region,
  body_segment               = EXCLUDED.body_segment,
  subcategory                = EXCLUDED.subcategory,
  description                = EXCLUDED.description,
  technique_steps            = EXCLUDED.technique_steps,
  patient_position           = EXCLUDED.patient_position,
  therapist_position         = EXCLUDED.therapist_position,
  contact_point              = EXCLUDED.contact_point,
  direction                  = EXCLUDED.direction,
  purpose_tags               = EXCLUDED.purpose_tags,
  target_tags                = EXCLUDED.target_tags,
  symptom_tags               = EXCLUDED.symptom_tags,
  contraindication_tags      = EXCLUDED.contraindication_tags,
  evidence_level             = EXCLUDED.evidence_level,
  key_references             = EXCLUDED.key_references,
  clinical_notes             = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at                 = NOW();

-- ────────────────────────────────
-- tech-F-002: 경추·견갑 저항성 운동
-- ────────────────────────────────
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  description,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  key_references,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_f_therapeutic_exercise',
  (SELECT id FROM technique_categories WHERE category_key = 'category_f_therapeutic_exercise'),
  'Resistance Training',
  '경추·견갑 저항성 운동', 'Cervical and Scapular Resistance Exercise', 'CervScap-RT',
  'cervical'::body_region, '경추 전체 + 견갑대',
  '좌위 또는 입위(운동 종류에 따라), 머리/경추 중립, 척추 중립, 탄성 밴드·경량 덤벨(1-3kg)·의자', '환자 옆에서 자세 및 운동 패턴 관찰, 필요 시 자세 교정 목적으로 가볍게 접촉', '해당 없음 (능동 운동)', '해당 없음 (능동 운동)',
  '경추·견갑 저항성 운동은 목과 어깨 주변 근육(특히 경부 심층 근육과 상부 승모근, 능형근, 전거근 등 견갑대 근육)을 점진적 부하로 강화하는 치료적 운동입니다. 고무 밴드, 탄성 밴드, 자체 저항, 또는 경량 덤벨을 이용하며, 주 3-5회, 4주 이상 꾸준히 시행할 때 통증 강도, 가동범위, 근육 긴장도, 삶의 질 모두에서 유의미한 개선이 보고됩니다.',
  '[{"step":1,"instruction":"워밍업: 5분간 경추 능동 가동 운동(굴곡/신전/회전/측방굴곡 각 10회). 목적: 관절 윤활 및 혈류 증가."},{"step":2,"instruction":"경추 굴곡 저항 운동: 앉은 자세에서 이마에 손을 대거나 밴드를 이마에 걸고, 고개 앞으로 숙이는 방향으로 저항을 가한다. 5초 등척성 수축 후 이완. 10회 3세트. 목적: 심층 경부 굴곡근 활성화."},{"step":3,"instruction":"견갑대 운동: 탄성 밴드를 이용한 견갑 후인, 밴드 로우, 외회전 운동 각 10-15회 2-3세트. 어깨 높이 또는 가슴 높이에서 수행."},{"step":4,"instruction":"점진적 부하 증가: 초기 2주 낮은 저항 고반복(15-20회), 이후 2주 저항 증가 저반복(8-12회)으로 전환."},{"step":5,"instruction":"재평가: 4주 후 VAS, CROM, NDI 재측정. 개선 확인 후 강도 조정."}]'::jsonb,
  '{"pain_relief","strength_training","rom_improvement"}', '{"subacute","chronic","office_worker"}', '{"neck_pain_chronic","cervical_stiffness","movement_pain"}', '{"fracture","malignancy","instability","vbi_risk","neurological_deficit"}',
  'level_1b'::evidence_level,
  '[{"pmid":"36181044","title":"Cervical and scapula-focused resistance exercise vs trapezius massage in chronic neck pain (Kang & Kim 2022)","year":2022},{"pmid":"32657531","title":"Strength training and workplace modifications may reduce neck pain in office workers (2020)","year":2020}]'::jsonb,
  '견갑 운동을 경추 운동과 함께 적용해야 효과적 - 경부 운동만 하면 효과 절반. 초기에는 등척성 운동으로 안전하게 시작, 통증 적응 후 등장성 운동으로 진행. 상부 승모근 과활성화(어깨 올라감) 보상 동작 모니터링 필수.',
  '골절(확인 또는 의심), 종양/악성 질환(경추), 척추 불안정성, 신경학적 결손, 척추동맥 혈액순환 장애(VBI) 위험, 급성 근육 파열/인대 손상', '급성 염증기, 골다공증, 심한 어깨 병변 동반',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko                    = EXCLUDED.name_ko,
  name_en                    = EXCLUDED.name_en,
  body_region                = EXCLUDED.body_region,
  body_segment               = EXCLUDED.body_segment,
  subcategory                = EXCLUDED.subcategory,
  description                = EXCLUDED.description,
  technique_steps            = EXCLUDED.technique_steps,
  patient_position           = EXCLUDED.patient_position,
  therapist_position         = EXCLUDED.therapist_position,
  contact_point              = EXCLUDED.contact_point,
  direction                  = EXCLUDED.direction,
  purpose_tags               = EXCLUDED.purpose_tags,
  target_tags                = EXCLUDED.target_tags,
  symptom_tags               = EXCLUDED.symptom_tags,
  contraindication_tags      = EXCLUDED.contraindication_tags,
  evidence_level             = EXCLUDED.evidence_level,
  key_references             = EXCLUDED.key_references,
  clinical_notes             = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at                 = NOW();

-- ────────────────────────────────
-- tech-F-003: 경추 운동·도수치료 병행 프로그램
-- ────────────────────────────────
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  description,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  key_references,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_f_therapeutic_exercise',
  (SELECT id FROM technique_categories WHERE category_key = 'category_f_therapeutic_exercise'),
  'Resistance Training',
  '경추 운동·도수치료 병행 프로그램', 'Cervical Exercise Combined with Manual Therapy Program', 'CervEx-MT-Combo',
  'cervical'::body_region, 'C1-C7, 상부 경추 기능 이상 포함',
  '좌위(운동), 복와위 또는 앙와위(도수치료), 등받이 없는 의자 또는 치료 베드', '운동 시 환자 옆/앞(관찰), 도수치료 시 해당 분절 접근 포지션, 도수치료 부분에 따라 접촉', '도수치료 적용 분절 (PA 가동술 또는 SNAG에 따라 결정)', '도수치료 기법에 따라 결정 (PA 방향 또는 SNAG 활주 방향)',
  '경추 운동·도수치료 병행 프로그램은 경추 가동 운동, 근력 강화 운동, 가정 운동 처방과 도수치료(관절 가동술, MWM 등)를 함께 적용하는 복합 재활 접근법입니다. 단독 운동이나 단독 도수치료보다 병행 시 더 빠르고 지속적인 효과를 보입니다. 주 1회 20분 클리닉 세션 + 매일 가정 운동 처방 구성이 표준 프로토콜입니다.',
  '[{"step":1,"instruction":"평가: FRT(굴곡-회전 검사), CROM, CCFT, VAS, NDI 초기 평가. 가장 제한/통증이 있는 분절 확인."},{"step":2,"instruction":"도수치료 적용: 확인된 분절에 대해 PA 가동술(Maitland Grade III-IV) 또는 SNAG(Mulligan) 적용. 통증 없이 3-5세트, 6-10회 반복."},{"step":3,"instruction":"능동 가동 운동: 도수치료 직후, 개선된 범위에서 능동 운동(굴곡/신전/회전) 수행. 새로운 범위를 신경계에 등록시키는 과정. 각 방향 10회."},{"step":4,"instruction":"근력 강화 운동: CCFT 기반 심층 경부 굴곡근 강화 운동. 탄성 밴드를 이용한 경추·견갑 저항성 운동. 각 2-3세트."},{"step":5,"instruction":"가정 운동 처방: 클리닉 운동을 단순화한 가정 운동 처방. 매일 10-15분, 2-3회. 처방 시 그림 또는 동영상 자료 제공."}]'::jsonb,
  '{"pain_relief","rom_improvement","strength_training"}', '{"subacute","chronic"}', '{"neck_pain_chronic","cervical_stiffness","movement_pain","upper_cervical_dysfunction"}', '{"fracture","malignancy","instability","vbi_risk","neurological_deficit"}',
  'level_1b'::evidence_level,
  '[{"pmid":"32927858","title":"Manual therapy + exercise vs exercise alone for chronic neck pain with upper cervical dysfunction (Rodriguez-Sanz 2020)","year":2020},{"pmid":"38284367","title":"Dry needling vs manual therapy for mechanical neck pain (Pandya 2024)","year":2024}]'::jsonb,
  '도수치료 직후 능동 운동이 핵심 - 새로운 가동 범위를 신경계에 저장하기 위해 즉시 능동 운동 수행. 가정 운동 순응도 매 세션 확인. 상부 경추 기능 이상 동반 시 FRT 먼저 평가.',
  '골절(확인 또는 의심), 종양/악성 질환(경추), 척추 불안정성, 신경학적 결손, 척추동맥 혈액순환 장애(VBI) 위험, 류마티스 경추 침범(C1-C2 불안정)', '극심한 급성 통증(NRS 8 이상), 골다공증, 임신',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko                    = EXCLUDED.name_ko,
  name_en                    = EXCLUDED.name_en,
  body_region                = EXCLUDED.body_region,
  body_segment               = EXCLUDED.body_segment,
  subcategory                = EXCLUDED.subcategory,
  description                = EXCLUDED.description,
  technique_steps            = EXCLUDED.technique_steps,
  patient_position           = EXCLUDED.patient_position,
  therapist_position         = EXCLUDED.therapist_position,
  contact_point              = EXCLUDED.contact_point,
  direction                  = EXCLUDED.direction,
  purpose_tags               = EXCLUDED.purpose_tags,
  target_tags                = EXCLUDED.target_tags,
  symptom_tags               = EXCLUDED.symptom_tags,
  contraindication_tags      = EXCLUDED.contraindication_tags,
  evidence_level             = EXCLUDED.evidence_level,
  key_references             = EXCLUDED.key_references,
  clinical_notes             = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at                 = NOW();

-- ────────────────────────────────
-- tech-F-004: 비특이적 만성 경부통 운동 처방 (노시플라스틱 통증 고려)
-- ────────────────────────────────
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  description,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  key_references,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_f_therapeutic_exercise',
  (SELECT id FROM technique_categories WHERE category_key = 'category_f_therapeutic_exercise'),
  'Aerobic Exercise',
  '비특이적 만성 경부통 운동 처방 (노시플라스틱 통증 고려)', 'Exercise Prescription for Nociplastic Chronic Neck Pain', 'CervEx-Nociplastic',
  'cervical'::body_region, '경추 전체 (전신 운동 포함)',
  '운동 형태에 따라 다양(서기, 앉기, 눕기), 편안한 자세, 탄성 밴드·의자·매트', '초기 교육 및 자세 가이드 역할, 이후 독립적 수행 지원, 필요 시 자세 교정', '해당 없음 (능동 운동)', '해당 없음 (능동 운동)',
  '만성 비특이적 경부통 중 일부는 통증 자체가 신경계에서 지속·증폭되는 노시플라스틱 통증 기전을 가집니다. 이 경우 국소 경추 운동보다 전신적인 운동 접근이 더 효과적일 수 있습니다. 핵심은 환자가 즐기고 지속할 수 있는 운동 형태를 선택하는 것이며, 주 2-3회, 30-60분, 7-12주 지속이 표준 권고입니다.',
  '[{"step":1,"instruction":"통증 교육: 1-2분 간단한 통증 신경과학 교육. 통증이 조직 손상의 직접적 지표가 아님을 설명. 운동이 왜 도움이 되는지 이유 제공."},{"step":2,"instruction":"운동 선택: 환자가 즐기거나 친숙한 운동 형태를 선택. 걷기, 수영, 자전거, 근력 강화, 스트레칭, 요가 등 모두 가능. 강요하지 않음."},{"step":3,"instruction":"초기 강도 설정: 현재 통증/기능 수준의 50-60% 강도에서 시작. 약간 힘들지만 대화할 수 있는 수준(Borg 스케일 11-13)."},{"step":4,"instruction":"점진적 증량: 매 1-2주마다 5-10% 강도 또는 시간 증가. 통증 악화 없이 진행. 할당량(quota) 방식 참고."},{"step":5,"instruction":"재평가: 4주, 8주, 12주 시점에 NRS, NDI, 신체 기능 재평가. 운동 참여 일지 활용 권장."}]'::jsonb,
  '{"pain_relief","functional_recovery","central_sensitization"}', '{"chronic"}', '{"neck_pain_chronic","whiplash_associated","widespread_pain"}', '{"fracture","malignancy","instability","cardiovascular_risk","neurological_deficit"}',
  'level_1a'::evidence_level,
  '[{"pmid":"32976664","title":"Prescription of exercises for chronic pain along nociplastic pain continuum (Ferro Moura Franco 2020)","year":2020},{"pmid":"36598342","title":"Global Postural Re-education vs neck-specific exercise in chronic neck pain (2022)","year":2022}]'::jsonb,
  '어떤 운동이든 좋다가 핵심 메시지 - 특정 운동 강요 대신 환자가 즐길 수 있는 운동 선택. 순응도가 효과를 결정. 통증 교육 먼저 - 운동을 왜 하는지, 통증이 왜 운동 시 나빠도 위험하지 않은지 교육 선행 필수.',
  '골절(확인 또는 의심), 종양/악성 질환, 척추 불안정성, 심각한 심혈관 질환, 급성 신경학적 결손', '심한 두려움-회피 행동(인지행동 접근 병행), 우울/불안 동반, 심한 피로',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko                    = EXCLUDED.name_ko,
  name_en                    = EXCLUDED.name_en,
  body_region                = EXCLUDED.body_region,
  body_segment               = EXCLUDED.body_segment,
  subcategory                = EXCLUDED.subcategory,
  description                = EXCLUDED.description,
  technique_steps            = EXCLUDED.technique_steps,
  patient_position           = EXCLUDED.patient_position,
  therapist_position         = EXCLUDED.therapist_position,
  contact_point              = EXCLUDED.contact_point,
  direction                  = EXCLUDED.direction,
  purpose_tags               = EXCLUDED.purpose_tags,
  target_tags                = EXCLUDED.target_tags,
  symptom_tags               = EXCLUDED.symptom_tags,
  contraindication_tags      = EXCLUDED.contraindication_tags,
  evidence_level             = EXCLUDED.evidence_level,
  key_references             = EXCLUDED.key_references,
  clinical_notes             = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at                 = NOW();

-- ────────────────────────────────
-- tech-F-005: 요추 안정화 운동 (모터 컨트롤 운동)
-- ────────────────────────────────
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  description,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  key_references,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_f_therapeutic_exercise',
  (SELECT id FROM technique_categories WHERE category_key = 'category_f_therapeutic_exercise'),
  'Neuromuscular Training',
  '요추 안정화 운동 (모터 컨트롤 운동)', 'Lumbar Stabilization Exercise / Motor Control Exercise', 'LumbStab-MCE',
  'lumbar'::body_region, 'L1-S1 전체, 요천추 이행부 포함',
  '앙와위(무릎 굽혀 발바닥 바닥) → 4발 자세(손목·무릎 정렬) → 좌위 → 입위, 매트·안정화 볼(선택)·바이오피드백 기기(선택)', '환자 옆에서 자세 및 운동 패턴 관찰, 필요 시 복벽 촉진으로 TrA 수축 확인 또는 요추 중립 자세 교정', '해당 없음 (능동 운동)', '해당 없음 (능동 운동)',
  '요추 안정화 운동은 척추 심층 근육(multifidus, transversus abdominis 등)의 활성화 및 조절 능력을 회복시키는 치료적 운동입니다. 코어 운동이라고도 불리며, 단순히 복근을 조이는 것이 아니라 신체가 움직이는 동안 척추를 동적으로 지지하는 능력을 재교육하는 과정입니다. 네트워크 메타분석에서 안정화/모터 컨트롤 운동은 만성 요통의 신체 기능 개선에 가장 효과적인 운동 유형 중 하나로 평가됩니다.',
  '[{"step":1,"instruction":"TrA 활성화 학습: 앙와위에서 복부 드로우인(abdominal draw-in) 교육. 배꼽을 척추 방향으로 가볍게 당기고, 복부 전체가 얕게 수축하는 감각 학습. 10초 유지 10회."},{"step":2,"instruction":"1단계(앙와위 운동): TrA 수축을 유지하면서 한쪽 다리 들기(heel slide, bent knee fallout). 척추 중립 유지가 핵심. 각 10-15회 2-3세트."},{"step":3,"instruction":"2단계(4발 자세): Bird-dog(대각선 팔-다리 들기). TrA + multifidus 동시 활성화. 10초 유지 10회/양쪽."},{"step":4,"instruction":"3단계(기능적 자세): 좌위 → 입위에서 척추 중립 유지 연습. 일상 동작(물건 들기, 앉았다 일어서기)에 코어 활성화 적용."},{"step":5,"instruction":"재평가: 6주 후 기능 검사(plank 유지 시간, 기능적 동작 통증 NRS), Oswestry Disability Index 재측정."}]'::jsonb,
  '{"pain_relief","motor_control","functional_recovery"}', '{"subacute","chronic"}', '{"low_back_pain_chronic","low_back_pain_nonspecific","lumbar_radiculopathy"}', '{"fracture","malignancy","cauda_equina","progressive_neurological_deficit","severe_stenosis"}',
  'level_1a'::evidence_level,
  '[{"pmid":"31666220","title":"Which specific modes of exercise are most effective for NSCLBP? NMA (Owen 2019)","year":2019},{"pmid":"34538747","title":"Some types of exercise more effective in CLBP: NMA (Hayden 2021)","year":2021},{"pmid":"38035307","title":"Exercise intervention for CLBP: SR + NMA (2023)","year":2023}]'::jsonb,
  '세게 조이기가 아님 - TrA는 최대 수축의 20-30%만 필요. 척추 중립 먼저 코어 다음 순서로 교육. 앙와위 → 4발 → 좌위 → 입위 → 기능적 동작 단계적 진행 필수. 호흡 정상화(숨 멈추지 않기) 지속 교육.',
  '골절(확인 또는 의심), 종양/악성 질환(요추), 마미증후군(응급 수술), 진행성 신경학적 결손, 불안정성 척추 골절, 중증 척추관 협착', '요추 추간판 탈출증(단순 방사통), 골다공증, 임신, 급성 통증 악화(NRS 8 이상)',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko                    = EXCLUDED.name_ko,
  name_en                    = EXCLUDED.name_en,
  body_region                = EXCLUDED.body_region,
  body_segment               = EXCLUDED.body_segment,
  subcategory                = EXCLUDED.subcategory,
  description                = EXCLUDED.description,
  technique_steps            = EXCLUDED.technique_steps,
  patient_position           = EXCLUDED.patient_position,
  therapist_position         = EXCLUDED.therapist_position,
  contact_point              = EXCLUDED.contact_point,
  direction                  = EXCLUDED.direction,
  purpose_tags               = EXCLUDED.purpose_tags,
  target_tags                = EXCLUDED.target_tags,
  symptom_tags               = EXCLUDED.symptom_tags,
  contraindication_tags      = EXCLUDED.contraindication_tags,
  evidence_level             = EXCLUDED.evidence_level,
  key_references             = EXCLUDED.key_references,
  clinical_notes             = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at                 = NOW();

-- ────────────────────────────────
-- tech-F-006: 요추 재활을 위한 필라테스 운동
-- ────────────────────────────────
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  description,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  key_references,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_f_therapeutic_exercise',
  (SELECT id FROM technique_categories WHERE category_key = 'category_f_therapeutic_exercise'),
  'Body Weight Exercise',
  '요추 재활을 위한 필라테스 운동', 'Pilates Exercise for Lumbar Rehabilitation', 'LumbPilates',
  'lumbar'::body_region, '요추 전체, 고관절 포함',
  '앙와위 → 측와위 → 좌위 → 입위(운동 종류에 따라), 매트(필수)·볼·링·스트랩(선택)', '환자 옆에서 관찰, 척추 위치·골반 중립·늑골 위치 교정 시 가볍게 접촉', '해당 없음 (능동 운동)', '해당 없음 (능동 운동)',
  '필라테스는 조절된 호흡, 코어 근육 활성화, 척추의 점진적 움직임을 결합한 운동 방식으로, 만성 요통 재활에 광범위하게 사용됩니다. 여러 네트워크 메타분석에서 필라테스가 만성 요통의 통증 감소와 기능 개선에서 일반 운동보다 효과적이거나 동등함을 보여줍니다. 개인 선호도와 그룹 형식 모두에서 높은 순응도를 보이는 장점이 있습니다.',
  '[{"step":1,"instruction":"기초 호흡 교육: 흉식 호흡(lateral breathing) - 숨을 들이쉴 때 흉곽이 옆으로 확장, 내쉴 때 복횡근 가볍게 수축. 10회 연습."},{"step":2,"instruction":"척추 중립 찾기: 앙와위에서 골반 기울기(posterior/anterior pelvic tilt) 각각 수행 후 중간 위치 찾기."},{"step":3,"instruction":"기초 운동 적용: Hundred(수정), Roll-up(수정 버전), Single Leg Stretch, Spine Stretch 등 기초 동작 순서대로 적용. 각 동작 6-10회."},{"step":4,"instruction":"점진적 운동 진행: 2주마다 난이도 평가. 기초 → 중급 → 고급 순서 진행. Side Lying Series, Swimming 등 배부 근육 운동 추가."},{"step":5,"instruction":"재평가: 8-12주 후 VAS, ODI, 기능 동작 재평가. 그룹 또는 독립 수행으로 전환 결정."}]'::jsonb,
  '{"pain_relief","core_stability","flexibility"}', '{"subacute","chronic"}', '{"low_back_pain_chronic","low_back_pain_nonspecific"}', '{"fracture","malignancy","cauda_equina","progressive_neurological_deficit","severe_stenosis"}',
  'level_1a'::evidence_level,
  '[{"pmid":"31666220","title":"Which modes of exercise most effective for NSCLBP? NMA - Pilates SUCRA 100% (Owen 2019)","year":2019},{"pmid":"34538747","title":"Some exercise types more effective in CLBP: NMA - Pilates top ranked (Hayden 2021)","year":2021},{"pmid":"37632387","title":"Effectiveness of Pilates on low back pain: SR + Meta (Patti 2023)","year":2023}]'::jsonb,
  '호흡이 운동보다 먼저 - 필라테스 운동 전 올바른 호흡 패턴 충분히 교육. 수정 버전 사용 - 요통 환자에게 척추 중립 유지 가능한 범위로 수정. 그룹 클래스 활용 시 사회적 지지와 동기부여 향상. 8-12주 후 독립 유지 계획 수립.',
  '골절(확인 또는 의심), 종양/악성 질환, 마미증후군, 진행성 신경학적 결손, 심한 척추관 협착', '추간판 탈출증(급성기), 골다공증, 임신, 심한 운동 공포증',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko                    = EXCLUDED.name_ko,
  name_en                    = EXCLUDED.name_en,
  body_region                = EXCLUDED.body_region,
  body_segment               = EXCLUDED.body_segment,
  subcategory                = EXCLUDED.subcategory,
  description                = EXCLUDED.description,
  technique_steps            = EXCLUDED.technique_steps,
  patient_position           = EXCLUDED.patient_position,
  therapist_position         = EXCLUDED.therapist_position,
  contact_point              = EXCLUDED.contact_point,
  direction                  = EXCLUDED.direction,
  purpose_tags               = EXCLUDED.purpose_tags,
  target_tags                = EXCLUDED.target_tags,
  symptom_tags               = EXCLUDED.symptom_tags,
  contraindication_tags      = EXCLUDED.contraindication_tags,
  evidence_level             = EXCLUDED.evidence_level,
  key_references             = EXCLUDED.key_references,
  clinical_notes             = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at                 = NOW();

-- ────────────────────────────────
-- tech-F-007: 요추 McKenzie 신전 기반 운동
-- ────────────────────────────────
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  description,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  key_references,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_f_therapeutic_exercise',
  (SELECT id FROM technique_categories WHERE category_key = 'category_f_therapeutic_exercise'),
  'Body Weight Exercise',
  '요추 McKenzie 신전 기반 운동', 'McKenzie Extension-Based Exercise for Lumbar Spine', 'LumbMcK-Ext',
  'lumbar'::body_region, 'L4-L5, L5-S1 (가장 흔한 추간판 탈출 분절)',
  '복와위(주요 시작 자세), 머리 한쪽으로 돌리거나 이마 바닥, 팔 어깨 넓이 손바닥 가슴 옆, 다리 자연스럽게 펴기, 매트', '환자 옆에서 관찰, 신전 범위 및 통증 반응 관찰, 필요 시 허리 위치 가이드 위해 경량 접촉', '해당 없음 (능동 운동)', '해당 없음 (능동 운동 - 신전 방향)',
  'McKenzie 방법(MDT)은 환자의 움직임에 대한 반응을 평가하여 통증이 감소하는 방향(directional preference)을 찾아 운동하는 방식입니다. 요통 환자의 약 70%가 신전 방향에서 증상이 줄어드는 신전 선호를 보입니다. 복와위 신전, 엎드려 팔 뻗기(prone press-up) 등이 대표적이며, 추간판 탈출 동반 좌골신경통 환자에서도 장기 효과가 확인됩니다.',
  '[{"step":1,"instruction":"방향성 평가: 복와위로 1-2분 편안하게 눕기. 그 자체로 통증 변화 확인. 이후 복와위 신전 유지하며 통증 집중화 여부 확인."},{"step":2,"instruction":"복와위 신전 1단계(Prone Lying): 엎드린 자세에서 10분 유지. 요추 자연 신전을 허용하면서 증상 변화 관찰. 방사통 집중화 확인."},{"step":3,"instruction":"복와위 신전 2단계(Prone Press-up): 팔꿈치로 상체 지탱(Sphinx 자세). 호흡을 이용하여 5-10회. 골반이 바닥에 닿아 있어야 함."},{"step":4,"instruction":"복와위 신전 3단계(Standing Extension): 입위에서 양손을 요추 뒤에 두고 상체를 뒤로 천천히 젖히기. 10회. 증상 집중화 지속 확인."},{"step":5,"instruction":"재평가: 집중화 현상 있으면 지속. 없으면 굴곡 방향성 검사로 전환. 증상 악화 시 즉시 중단, 원인 재평가."}]'::jsonb,
  '{"pain_relief","centralization","rom_improvement"}', '{"subacute","chronic"}', '{"low_back_pain_chronic","low_back_pain_nonspecific","lumbar_radiculopathy","disc_herniation"}', '{"fracture","malignancy","cauda_equina","progressive_neurological_deficit","severe_spondylolisthesis"}',
  'level_1b'::evidence_level,
  '[{"pmid":"34538747","title":"Some exercise types more effective in CLBP: NMA - McKenzie moderate-high effect (Hayden 2021)","year":2021},{"pmid":"36039973","title":"Flexion vs extension-based exercises after lumbar discectomy (Abdi 2022)","year":2022},{"pmid":"37605454","title":"McKenzie Method vs guideline-based advice for sciatica 24-month (Kilpikoski 2023)","year":2023}]'::jsonb,
  '집중화 현상이 핵심 지표 - 방사통이 발끝에서 무릎, 허리로 올라오면 진행. 집중화 없으면 이 운동이 이 환자에게 맞지 않는 것. 하루 6-8세트 가정 운동이 McKenzie 방법의 핵심. 디스크가 들어가야 한다는 표현 사용 금지.',
  '골절(확인 또는 의심), 종양/악성 질환, 마미증후군, 진행성 신경학적 결손, 척추전방전위증(심한 경우)', '척추관 협착(신전보다 굴곡 선호 가능 - 방향성 평가 우선), 노인 골다공증, 임신 후기',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko                    = EXCLUDED.name_ko,
  name_en                    = EXCLUDED.name_en,
  body_region                = EXCLUDED.body_region,
  body_segment               = EXCLUDED.body_segment,
  subcategory                = EXCLUDED.subcategory,
  description                = EXCLUDED.description,
  technique_steps            = EXCLUDED.technique_steps,
  patient_position           = EXCLUDED.patient_position,
  therapist_position         = EXCLUDED.therapist_position,
  contact_point              = EXCLUDED.contact_point,
  direction                  = EXCLUDED.direction,
  purpose_tags               = EXCLUDED.purpose_tags,
  target_tags                = EXCLUDED.target_tags,
  symptom_tags               = EXCLUDED.symptom_tags,
  contraindication_tags      = EXCLUDED.contraindication_tags,
  evidence_level             = EXCLUDED.evidence_level,
  key_references             = EXCLUDED.key_references,
  clinical_notes             = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at                 = NOW();

-- ────────────────────────────────
-- tech-F-008: 만성 요통에 대한 걷기 및 유산소 운동
-- ────────────────────────────────
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  description,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  key_references,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_f_therapeutic_exercise',
  (SELECT id FROM technique_categories WHERE category_key = 'category_f_therapeutic_exercise'),
  'Aerobic Exercise',
  '만성 요통에 대한 걷기 및 유산소 운동', 'Walking and Aerobic Exercise for Chronic Low Back Pain', 'LumbWalk-Aero',
  'lumbar'::body_region, '요추 전반 (전신 운동)',
  '입위(보행), 자연스러운 직립 자세, 과도한 바른 자세 강요 불필요, 쿠션 있는 운동화 권장, 노르딕 워킹 스틱(선택)', '초기 교육 및 보행 패턴 관찰, 직접 접촉 없음', '해당 없음 (능동 운동)', '해당 없음 (능동 운동)',
  '걷기는 만성 요통 환자에게 가장 접근하기 쉽고 비용 효율적인 운동 처방입니다. 특별한 장비 없이 일상생활에 통합할 수 있으며, 체계적 고찰 및 메타분석에서 걷기와 다른 운동 치료가 통증, 장애, 삶의 질, 두려움-회피 행동 개선에서 유사한 효과를 보임을 확인했습니다. 특히 고령, 운동 공포증, 사회경제적 제약이 있는 환자에게 최우선 추천 운동입니다.',
  '[{"step":1,"instruction":"기준 평가: 현재 하루 평균 보행 시간/거리 확인. 통증 유발 보행 거리(walking tolerance) 파악. 스마트폰 만보기 앱 또는 보수계 활용."},{"step":2,"instruction":"초기 처방: 현재 운동 내성의 50-60% 강도로 시작. 예: 하루 10분 2회 또는 1,000-2,000보/일. 약간 숨이 차지만 대화 가능한 수준."},{"step":3,"instruction":"점진적 증량: 매 1-2주마다 5-10분씩 증가. 목표: 30분 연속 보행, 주 3-5회. 또는 10,000보/일(장기 목표)."},{"step":4,"instruction":"보행 방법 교육: 팔을 자연스럽게 흔들기. 보폭을 억지로 크게 하지 않기. 경사면, 불규칙 지형 점진적 추가(난이도 증가)."},{"step":5,"instruction":"재평가: 4주, 8주 시점에 NRS, ODI, 보행 거리/시간 재측정. 목표 달성 및 다음 단계 설정."}]'::jsonb,
  '{"pain_relief","aerobic_exercise","functional_recovery","fear_avoidance"}', '{"chronic","elderly","deconditioned"}', '{"low_back_pain_chronic","low_back_pain_nonspecific"}', '{"cauda_equina","progressive_neurological_deficit","cardiovascular_risk","vascular_claudication"}',
  'level_1a'::evidence_level,
  '[{"pmid":"29207885","title":"Effectiveness of walking vs exercise in CLBP: SR + Meta (Vanti 2017)","year":2017},{"pmid":"31261549","title":"Lumbar stabilization vs walking exercises in CLBP: RCT (Suh 2019)","year":2019},{"pmid":"35996124","title":"Summarizing effects of different exercise types in CLBP (2022)","year":2022}]'::jsonb,
  '지금 당장 시작이 최고의 처방 - 완벽한 운동 계획보다 10분 걷기를 오늘 시작하는 게 더 중요. 허리 펴고 걸어야 한다 강조 금지 - 과도한 과신전 자세 유도. 노르딕 워킹 고려 - 폴 사용 시 요추 하중 10-15% 감소. 척추관 협착 감별 필수.',
  '마미증후군, 진행성 신경학적 결손, 심각한 심혈관 질환, 하지 허혈(혈관성 파행)', '척추관 협착(신경성 파행 - 자전거 등 굴곡 자세 유산소로 대체), 고도 비만(수중 보행 고려), 심한 무릎·고관절 통증',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko                    = EXCLUDED.name_ko,
  name_en                    = EXCLUDED.name_en,
  body_region                = EXCLUDED.body_region,
  body_segment               = EXCLUDED.body_segment,
  subcategory                = EXCLUDED.subcategory,
  description                = EXCLUDED.description,
  technique_steps            = EXCLUDED.technique_steps,
  patient_position           = EXCLUDED.patient_position,
  therapist_position         = EXCLUDED.therapist_position,
  contact_point              = EXCLUDED.contact_point,
  direction                  = EXCLUDED.direction,
  purpose_tags               = EXCLUDED.purpose_tags,
  target_tags                = EXCLUDED.target_tags,
  symptom_tags               = EXCLUDED.symptom_tags,
  contraindication_tags      = EXCLUDED.contraindication_tags,
  evidence_level             = EXCLUDED.evidence_level,
  key_references             = EXCLUDED.key_references,
  clinical_notes             = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at                 = NOW();

-- ────────────────────────────────
-- tech-F-009: 요추 저항성 운동 및 코어·고관절 복합 운동
-- ────────────────────────────────
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  description,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  key_references,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_f_therapeutic_exercise',
  (SELECT id FROM technique_categories WHERE category_key = 'category_f_therapeutic_exercise'),
  'Resistance Training',
  '요추 저항성 운동 및 코어·고관절 복합 운동', 'Resistance Training with Core and Hip Complex Exercise for Low Back Pain', 'LumbRT-CoreHip',
  'lumbar'::body_region, '요추 전체 + 골반대 + 고관절',
  '앙와위(코어 운동) → 측와위(외전) → 엎드린 자세(신전) → 입위, 매트·탄성 밴드·경량 덤벨(선택)', '환자 옆에서 자세 관찰 및 교정, 골반 중립·요추 위치 교정 시 가볍게 접촉', '해당 없음 (능동 운동)', '해당 없음 (능동 운동)',
  '요통 환자에서 고관절 외전근, 신전근, 코어 근육의 약화 및 유연성 감소가 공통적으로 관찰됩니다. 이 복합 운동 프로그램은 코어 안정화 운동과 고관절 강화·스트레칭을 병행하여 요추-골반 복합체의 기능을 총체적으로 회복시킵니다. 코어 안정화 + 고관절 스트레칭 그룹이 샴 그룹보다 통증 강도, 장애 수준, 균형 능력, 삶의 질 모두에서 유의미한 개선을 보였습니다.',
  '[{"step":1,"instruction":"코어 기초 훈련: 복부 드로우인 + 브리지(bridge) 운동으로 시작. Bridge: 앙와위에서 고관절 신전으로 엉덩이 들기, 2초 유지, 천천히 내리기. 15회 3세트."},{"step":2,"instruction":"고관절 강화 운동: Clamshell(측와위 고관절 외전) - 탄성 밴드 착용, 15회 2세트/양쪽. Side-lying hip abduction: 15회 2세트."},{"step":3,"instruction":"고관절 굴곡근 스트레칭: 반무릎 자세(half-kneeling)에서 고관절 굴곡근 스트레칭. 30초 3회/양쪽."},{"step":4,"instruction":"기능적 복합 운동: Deadbug(앙와위 코어 유지하며 대각선 팔-다리 내리기). Squat(체중 또는 저항): 고관절·무릎·요추 복합 패턴. 각 10-15회 2세트."},{"step":5,"instruction":"재평가: 6주 후 NRS, ODI, 고관절 근력 검사, 균형 능력 재평가. 진행 여부 및 강도 조정."}]'::jsonb,
  '{"pain_relief","strength_training","hip_stability","functional_recovery"}', '{"subacute","chronic"}', '{"low_back_pain_nonspecific","low_back_pain_chronic","hip_related_back_pain"}', '{"fracture","malignancy","cauda_equina","progressive_neurological_deficit"}',
  'level_1b'::evidence_level,
  '[{"pmid":"32669487","title":"Core stability and hip exercises improve function in NSLBP (Kim & Yim 2020)","year":2020},{"pmid":"32675390","title":"Lumbar stabilization and thoracic mobilization for CLBP with radiculopathy (Kostadinovic 2020)","year":2020},{"pmid":"31666220","title":"Which exercise modes most effective for NSCLBP? NMA - resistance training SUCRA 80% (Owen 2019)","year":2019}]'::jsonb,
  '고관절을 빼면 요통 재활이 절반 - 코어 운동만 하고 고관절 강화를 빼면 장기 효과 제한됨. 브리지부터 시작 - 거의 모든 환자가 할 수 있는 안전한 고관절 신전 운동. 측면 근육(gluteus medius) 강화 필수. Clamshell 시 골반 회전 보상 동작 모니터링.',
  '골절(확인 또는 의심), 종양/악성 질환, 마미증후군, 진행성 신경학적 결손, 고관절 치환술 후(초기 6주)', '추간판 탈출증(급성기), 고령+골다공증, 고관절 통증 동반',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko                    = EXCLUDED.name_ko,
  name_en                    = EXCLUDED.name_en,
  body_region                = EXCLUDED.body_region,
  body_segment               = EXCLUDED.body_segment,
  subcategory                = EXCLUDED.subcategory,
  description                = EXCLUDED.description,
  technique_steps            = EXCLUDED.technique_steps,
  patient_position           = EXCLUDED.patient_position,
  therapist_position         = EXCLUDED.therapist_position,
  contact_point              = EXCLUDED.contact_point,
  direction                  = EXCLUDED.direction,
  purpose_tags               = EXCLUDED.purpose_tags,
  target_tags                = EXCLUDED.target_tags,
  symptom_tags               = EXCLUDED.symptom_tags,
  contraindication_tags      = EXCLUDED.contraindication_tags,
  evidence_level             = EXCLUDED.evidence_level,
  key_references             = EXCLUDED.key_references,
  clinical_notes             = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at                 = NOW();

-- ============================================================
-- STEP 3: technique_stats 초기 레코드 생성
-- ============================================================
INSERT INTO technique_stats (technique_id, recommendation_weight)
SELECT id, 0.7
FROM techniques
WHERE category = 'category_f_therapeutic_exercise'
ON CONFLICT (technique_id) DO NOTHING;

-- ============================================================
-- 검증 쿼리 (실행 후 확인용)
-- SELECT abbreviation, name_ko, evidence_level FROM techniques
--   WHERE category = 'category_f_therapeutic_exercise'
--   ORDER BY abbreviation;
-- 기대값: 9개 (CervEx-MT-Combo, CervEx-Nociplastic, CervProp-Ex, CervScap-RT,
--           LumbMcK-Ext, LumbPilates, LumbRT-CoreHip, LumbStab-MCE, LumbWalk-Aero)
-- ============================================================
