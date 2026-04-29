-- ============================================================
-- Migration 038 — PNE 4개 + 경추 관절가동술 4개 + 경추 Mulligan 3개
-- 총 11개 신규 기법 INSERT
--
-- [PNE 1] PNE-Basic     — 기본 통증 신경과학 교육         / NULL (범용)
-- [PNE 2] PNE-Metaphor  — 신경계 비유 교육               / NULL (범용)
-- [PNE 3] PNE-GradExp   — 점진적 노출 + 공포회피 교육      / NULL (범용)
-- [PNE 4] PNE-Lifestyle — 수면·스트레스·활동량 교육        / NULL (범용)
-- [JM  1] JM-CX-PA-C   — 경추 중앙 PA 가동술 (Maitland)  / cervical
-- [JM  2] JM-CX-PA-U   — 경추 단측 PA 가동술 (Maitland)  / cervical
-- [JM  3] JM-CX-Rot    — 경추 회전 가동술 (Maitland)     / cervical
-- [JM  4] JM-CX-LatFx  — 경추 측방굴곡 가동술 (Maitland) / cervical
-- [MUL 1] MUL-CX-SNAG-Rot  — 경추 회전 SNAG (Mulligan)  / cervical
-- [MUL 2] MUL-CX-SNAG-Ext  — 경추 신전 SNAG (Mulligan)  / cervical
-- [MUL 3] MUL-CX-SNAG-HA   — 두통 C1-C2 SNAG (Mulligan) / cervical
--
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- sw-db-architect | 2026-04-29
-- ============================================================

BEGIN;

-- ═══════════════════════════════════════════════════════
-- PART 1: PNE (통증 신경과학 교육) — 4개
-- body_region NULL (모든 부위 범용)
-- ═══════════════════════════════════════════════════════

-- ────────────────────── PNE-Basic ──────────────────────
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
  '통증 신경과학 교육',
  '기본 통증 신경과학 교육', 'Pain Neuroscience Education — Basic Concepts', 'PNE-Basic',
  NULL, '전신 신경계 (교육적 접근)',
  '앉기 또는 편안한 자세, 치료사와 마주 앉기',
  '환자 정면 또는 옆에 위치, 시각 자료(그림·다이어그램) 활용',
  '해당 없음 (신체 접촉 없음)',
  '해당 없음 (교육적 접근)',
  '[
    {"step":1,"instruction":"환자의 현재 통증에 대한 믿음과 이해를 먼저 확인한다. ''통증이 생기는 이유가 무엇이라고 생각하세요?'' 질문으로 시작한다. 환자가 통증=손상으로 이해하고 있는지 파악한다."},
    {"step":2,"instruction":"통증은 조직 손상의 정확한 척도가 아닌 ''뇌가 위협을 감지할 때 발생하는 보호 반응''임을 설명한다. 예시: ''화재 경보기가 울린다고 항상 실제 불이 난 것은 아닙니다. 경보기가 민감해질 수 있듯이 신경계도 그럴 수 있습니다.''"},
    {"step":3,"instruction":"신경계 민감화(central sensitization) 개념을 쉬운 언어로 설명한다. ''반복적인 통증 경험이 신경계를 더 민감하게 만들어 작은 자극에도 더 강하게 반응할 수 있습니다.'' 이것이 만성 통증의 원인 중 하나임을 전달한다."},
    {"step":4,"instruction":"환자의 통증 경험이 ''진짜''라는 점을 명확히 한다. ''통증이 심리적인 것이라거나 꾀병이라는 뜻이 절대 아닙니다. 통증은 항상 실재하고 항상 뇌가 만들어냅니다—그리고 그 통증은 진짜입니다.'' 환자의 경험을 타당화한다."},
    {"step":5,"instruction":"교육 내용 이해도를 확인한다. ''오늘 이야기한 내용 중 가장 새롭게 느껴진 것이 무엇인가요?'' 질문으로 이해를 점검하고, 다음 세션에서 다룰 내용을 간략히 안내한다. 교육 자료(리플렛·QR 링크)를 제공한다."}
  ]'::jsonb,
  '{"pain_education","sensitization_reduction","catastrophizing_reduction"}',
  '{"subacute","chronic","sensitized"}',
  '{"rest_pain","movement_pain","radicular_pain","referred_pain","lbp_nonspecific","cervicogenic_headache"}',
  '{"acute_crisis","psychiatric_emergency"}',
  'level_1a'::evidence_level,
  '만성 통증 환자에서 통증 신경과학 교육(PNE)은 통증 강도·장애·파국화를 감소시키는 수준 1A 근거를 보유한다(Louw et al., 2016). 수술 전·후 환자, 만성 요통, 만성 경추통 모두에서 효과가 확인됐다. 단독으로도 효과적이나 운동·도수치료와 병행 시 효과가 더 크다.',
  'acute_psychiatric_crisis',
  'cognitive_impairment_severe, language_barrier_severe',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────── PNE-Metaphor ──────────────────────
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
  '통증 신경과학 교육',
  '신경계 비유 교육 (화재경보기·볼륨조절 모델)', 'PNE — Metaphor-Based Neural Education', 'PNE-Metaphor',
  NULL, '전신 신경계 (교육적 접근)',
  '앉기 또는 편안한 자세',
  '환자 정면, 그림·비유 카드 활용',
  '해당 없음',
  '해당 없음',
  '[
    {"step":1,"instruction":"''화재 경보기'' 비유를 사용한다. ''여러분의 통증 시스템을 화재 경보기라고 생각해보세요. 경보기는 실제 불이 났을 때도 울리지만, 작은 연기에도 울릴 수 있습니다. 만성 통증은 경보기가 너무 민감해진 상태입니다.''"},
    {"step":2,"instruction":"''볼륨 조절 다이얼'' 비유를 추가한다. ''신경계에는 통증 볼륨을 조절하는 다이얼이 있습니다. 잠 못 자고, 스트레스 받고, 걱정이 많을 때 볼륨이 올라갑니다. 반대로 좋은 수면, 즐거운 활동, 안전감을 느낄 때 볼륨이 내려갑니다.''"},
    {"step":3,"instruction":"환자 자신의 통증 볼륨을 높이는 요인을 함께 찾는다. ''여러분의 경우 어떤 상황에서 통증이 더 심해지나요?'' 목록을 작성하며 신경계 민감화 요인을 시각화한다."},
    {"step":4,"instruction":"볼륨을 낮추는 요인도 함께 탐색한다. ''반대로 통증이 덜할 때는 어떤 상황이었나요?'' 환자가 이미 가진 조절 전략을 발견하고 강화한다."},
    {"step":5,"instruction":"비유가 환자에게 얼마나 의미 있게 느껴지는지 확인한다. 다른 비유(''경보 시스템 업그레이드'', ''뇌의 보호 본능'')가 더 잘 맞는지 탐색한다. 환자가 선호하는 비유를 기록해두고 이후 세션에서 일관되게 사용한다."}
  ]'::jsonb,
  '{"pain_education","catastrophizing_reduction","self_efficacy"}',
  '{"subacute","chronic","sensitized"}',
  '{"rest_pain","movement_pain","radicular_pain","lbp_nonspecific","cervicogenic_headache"}',
  '{"acute_crisis","psychiatric_emergency"}',
  'level_1a'::evidence_level,
  '비유 기반 PNE는 추상적인 신경과학 개념을 환자가 이해하기 쉽게 전달하는 핵심 전략이다. Moseley & Butler의 Explain Pain 교재에서 다양한 비유가 제시된다. 환자마다 가장 공명하는 비유가 다르므로 탐색이 필요하다.',
  'acute_psychiatric_crisis',
  'cognitive_impairment_severe',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────── PNE-GradExp ──────────────────────
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
  '통증 신경과학 교육',
  '점진적 노출 + 공포-회피 교육', 'PNE — Graded Exposure & Fear-Avoidance Education', 'PNE-GradExp',
  NULL, '전신 신경계 (교육적 접근)',
  '앉기 또는 서기, 회피하는 활동 시연 가능 공간',
  '환자 옆 또는 앞에 위치',
  '해당 없음',
  '해당 없음',
  '[
    {"step":1,"instruction":"공포-회피 모델을 설명한다. ''통증을 느끼면 그 움직임이 위험하다고 느껴져 피하게 됩니다. 피할수록 근육은 약해지고 신경계는 그 움직임을 더 위험하게 인식합니다. 이 악순환이 만성 통증을 유지시킵니다.''"},
    {"step":2,"instruction":"환자가 현재 회피하는 활동 목록을 함께 작성한다. 두려움 정도를 0–10으로 평가하여 두려움 위계(hierarchy)를 만든다. ''가장 덜 무서운 활동''부터 ''가장 무서운 활동''까지 나열한다."},
    {"step":3,"instruction":"두려움 위계 최하단 활동부터 치료사와 함께 시도한다. 시도 전 ''이 움직임이 조직에 손상을 줄 것 같나요?''를 물어 예측을 확인한다. 시도 후 실제 경험과 예측의 차이를 탐색한다."},
    {"step":4,"instruction":"점진적으로 위계를 올라가며 노출을 반복한다. 각 활동 후 ''생각했던 것보다 덜 아팠나요?'' ''몸이 견딜 수 있었나요?'' 질문으로 안전감 경험을 강화한다."},
    {"step":5,"instruction":"홈 프로그램으로 일상 활동에서 점진적 노출을 지속하도록 안내한다. 활동 일지(날짜·활동·두려움 점수·실제 통증)를 기록하게 하고 다음 세션에서 검토한다. 두려움 점수가 낮아지는 추세를 시각화하여 진전을 확인한다."}
  ]'::jsonb,
  '{"pain_education","fear_avoidance_reduction","graded_exposure","self_efficacy"}',
  '{"subacute","chronic","sensitized"}',
  '{"movement_pain","rest_pain","lbp_nonspecific","cervicogenic_headache","radicular_pain"}',
  '{"acute_crisis","severe_neurological_deficit","psychiatric_emergency"}',
  'level_1b'::evidence_level,
  '점진적 노출(Graded Exposure)은 공포-회피 신념이 높은 만성 통증 환자에서 장애 감소와 활동 참여 향상에 효과적이다(Vlaeyen et al., 2001). Tampa Scale for Kinesiophobia(TSK) 점수가 높은 환자에서 특히 중요하다. PNE-Basic 교육 후 적용 시 더 효과적이다.',
  'acute_neurological_emergency',
  'high_distress_acute_phase, severe_PTSD',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  is_published = EXCLUDED.is_published, updated_at = NOW();

-- ────────────────────── PNE-Lifestyle ──────────────────────
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
  '통증 신경과학 교육',
  '생활습관 교육 (수면·스트레스·활동)', 'PNE — Lifestyle Factors Education (Sleep, Stress, Activity)', 'PNE-Lifestyle',
  NULL, '전신 신경계 (교육적 접근)',
  '앉기 편안한 자세',
  '환자 옆 또는 정면, 생활습관 체크리스트 활용',
  '해당 없음',
  '해당 없음',
  '[
    {"step":1,"instruction":"통증 볼륨에 영향을 주는 생활습관 요인 4가지(수면·스트레스·신체활동·사회적 연결)를 소개한다. ''이 4가지는 통증 신경계의 ''볼륨 조절 다이얼''에 직접 영향을 줍니다.''"},
    {"step":2,"instruction":"수면에 대해 교육한다. ''수면 부족은 통증 민감도를 직접 높입니다. 7–8시간 수면이 권장되며 규칙적인 취침·기상 시간이 중요합니다.'' 현재 수면 상태를 파악하고 수면 위생 전략을 제안한다."},
    {"step":3,"instruction":"스트레스 관련 교육한다. ''심리적 스트레스는 코르티솔을 높여 신경계를 더 민감하게 만듭니다. 스트레스를 줄이는 것이 통증 관리의 일부입니다.'' 현재 스트레스 요인을 함께 탐색한다."},
    {"step":4,"instruction":"신체활동의 역할을 설명한다. ''움직임은 통증 완화 물질(엔돌핀·세로토닌)을 분비합니다. 완전 휴식보다 통증 범위 내 점진적 활동이 더 효과적입니다.'' 활동 페이싱(pacing) 전략을 간략히 소개한다."},
    {"step":5,"instruction":"환자가 가장 실천 가능한 생활습관 변화 1–2가지를 선택하도록 돕는다. ''이번 주에 가장 실천할 수 있을 것 같은 한 가지를 골라봅시다.'' 작은 성공 경험을 쌓도록 현실적인 목표를 설정한다."}
  ]'::jsonb,
  '{"pain_education","lifestyle_modification","self_efficacy","sensitization_reduction"}',
  '{"subacute","chronic","sensitized"}',
  '{"rest_pain","movement_pain","lbp_nonspecific","cervicogenic_headache"}',
  '{"acute_crisis"}',
  'level_1b'::evidence_level,
  '수면장애, 심리적 스트레스, 신체 비활동은 만성 통증의 주요 유지 요인이다. 생활습관 교육은 PNE의 필수 구성 요소이며, 단독으로도 통증 강도와 장애에 의미 있는 효과를 보인다. 사회적 고립도 통증 민감화 요인이므로 사회적 연결도 함께 다룬다.',
  '',
  'severe_psychiatric_comorbidity',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  is_published = EXCLUDED.is_published, updated_at = NOW();


-- ═══════════════════════════════════════════════════════
-- PART 2: 경추 관절가동술 (Maitland) — 4개
-- body_region: cervical
-- ═══════════════════════════════════════════════════════

-- ────────────────────── JM-CX-PA-C (중앙 PA 가동술) ──────────────────────
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
  'category_joint_mobilization',
  (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
  '경추 관절가동술 — Maitland',
  '경추 중앙 후-전방 가동술', 'Cervical Central Posterior-Anterior Mobilization (Maitland)', 'JM-CX-PA-C',
  'cervical'::body_region, 'C2–C7 극돌기',
  '엎드리기, 이마 패드 위에 머리 위치, 경추 중립',
  '환자 머리 쪽에 위치, 엄지손가락 극돌기에 접촉',
  '목표 척추 극돌기 (C2–C7 해당 분절)',
  '후방 → 전방 방향, 리듬감 있는 진동 (Maitland grade I–IV)',
  '[
    {"step":1,"instruction":"엎드리기 자세에서 환자 이마를 패드에 위치시키고 경추를 중립으로 유지한다. 치료할 분절을 촉진으로 확인한다: C2는 후두골 직하방, 이후 각 극돌기를 아래로 촉진한다."},
    {"step":2,"instruction":"양측 엄지손가락을 겹쳐(one on top of other) 목표 극돌기 위에 위치시킨다. 체중을 활용한 직접 접촉보다 팔꿈치를 신전한 자세에서 몸 전체 무게를 이용하는 것이 효율적이다."},
    {"step":3,"instruction":"Grade I–II (통증 완화 목적): 리듬감 있는 소진폭·낮은 저항 진동을 2–3분 적용한다. 환자가 약간의 압박감은 느끼되 통증이 심하지 않아야 한다. 아급성 통증 또는 검사 초기에 사용한다."},
    {"step":4,"instruction":"Grade III–IV (가동성 향상 목적): 가동 범위 끝(end range)에서 큰 진폭 또는 소진폭으로 적용한다. ROM 제한이 있거나 만성 경직이 있는 경우 사용한다. 환자가 통증 없이 압박감·신장감을 느끼는 강도에서 조절한다."},
    {"step":5,"instruction":"치료 후 경추 ROM(굴곡·신전·회전·측굴)을 재평가하고 시작 전과 비교한다. 긍정적 반응(ROM 증가, 통증 감소)이 있으면 분절별로 계속 진행하거나 반복 횟수를 늘린다. 가동 후 단기 증상 악화(post-treatment soreness)는 정상적인 반응임을 설명한다."}
  ]'::jsonb,
  '{"joint_mobilization","pain_relief","ROM_improvement","hypomobility_treatment"}',
  '{"acute","subacute","chronic","muscle_hypertonicity"}',
  '{"movement_pain","hypomobile","morning_stiffness","disc_related","cervicogenic_headache"}',
  '{"fracture","malignancy","instability","neurological_deficit","vbi","upper_cervical_instability","osteoporosis","active_infection","anticoagulants"}',
  'level_1a'::evidence_level,
  '경추 PA 가동술은 경추통 및 경추성 두통에 수준 1A 근거를 보유한다(Gross et al., Cochrane 2015). Maitland grade는 통증 강도와 관절 저항에 따라 선택한다. 상부 경추(C1-C2) 가동 전 VBI(추골동맥 부전) 선별 검사가 필수적이다.',
  'fracture, VBI, upper_cervical_instability, malignancy, neurological_deficit',
  'osteoporosis, anticoagulants, acute_inflammation, hypermobility',
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

-- ────────────────────── JM-CX-PA-U (단측 PA 가동술) ──────────────────────
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
  'category_joint_mobilization',
  (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
  '경추 관절가동술 — Maitland',
  '경추 단측 후-전방 가동술', 'Cervical Unilateral Posterior-Anterior Mobilization (Maitland)', 'JM-CX-PA-U',
  'cervical'::body_region, 'C2–C7 관절기둥 (편측)',
  '엎드리기, 이마 패드 위에 머리 위치, 경추 중립',
  '환자 머리 쪽 또는 측방에 위치, 엄지손가락 관절기둥에 접촉',
  '목표 척추 관절기둥(articular pillar) — 극돌기 옆 1–2cm',
  '후방 → 전방, 약간 내측 방향; 리듬감 있는 진동',
  '[
    {"step":1,"instruction":"증상이 있는 쪽(또는 ROM 제한이 큰 쪽) 관절기둥을 목표로 설정한다. 관절기둥은 극돌기에서 약 1–2cm 측방에 위치한 관절돌기 기둥이다. 촉진으로 압통 또는 조직 저항 증가 부위를 확인한다."},
    {"step":2,"instruction":"엄지손가락 또는 피지(pisiform)를 관절기둥에 접촉한다. 반대 손으로 반대측 관절기둥을 지지하거나 환자 머리를 가볍게 고정한다."},
    {"step":3,"instruction":"후방에서 전방(약간 내측) 방향으로 리듬감 있는 진동을 적용한다. Grade I–II는 통증 완화, Grade III–IV는 경직 해소에 사용한다. 단측 가동술은 편측 증상, 편측 ROM 제한에 특히 유효하다."},
    {"step":4,"instruction":"가동 중 증상 변화를 지속 모니터링한다. 동측 상지로의 방사통이 새로 발생하면 즉시 강도를 줄이거나 중단한다. 증상이 경추 쪽으로 집중화(centralization)되면 긍정적 반응이다."},
    {"step":5,"instruction":"치료 후 좌우 회전 ROM 비교 재평가. 치료 측 회전이 증가하면 성공적인 반응이다. 3–5회 세션 후 반응이 없으면 다른 기법(중앙 PA, 회전 가동술)으로 전환을 고려한다."}
  ]'::jsonb,
  '{"joint_mobilization","pain_relief","ROM_improvement","unilateral_treatment"}',
  '{"acute","subacute","chronic","muscle_hypertonicity"}',
  '{"movement_pain","hypomobile","morning_stiffness","cervicogenic_headache","radicular_pain"}',
  '{"fracture","malignancy","instability","neurological_deficit","vbi","upper_cervical_instability","osteoporosis","active_infection","anticoagulants"}',
  'level_1a'::evidence_level,
  '단측 PA 가동술은 편측 경추통, 편측 회전 제한, 편측 방사통(중등도 이하)에 특히 효과적이다. 중앙 PA에 비해 특정 분절 및 측면을 더 정밀하게 치료할 수 있다. 상부 경추(C1-C2) 단측 가동술은 VBI 선별 후 적용한다.',
  'fracture, VBI, upper_cervical_instability, malignancy, neurological_deficit',
  'osteoporosis, anticoagulants, acute_radiculopathy_severe',
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

-- ────────────────────── JM-CX-Rot (경추 회전 가동술) ──────────────────────
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
  'category_joint_mobilization',
  (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
  '경추 관절가동술 — Maitland',
  '경추 회전 관절가동술', 'Cervical Rotation Mobilization (Maitland)', 'JM-CX-Rot',
  'cervical'::body_region, 'C0–C7 전 경추 분절',
  '바로 눕기, 머리 치료대 가장자리 또는 베개에 위치, 경추 중립',
  '환자 머리 쪽에 위치, 양손으로 두개골과 하악 지지',
  '두개골 후방 및 하악 지지 (양손)',
  '제한된 방향으로의 회전, 리듬감 있는 진동 또는 Grade IV stretch',
  '[
    {"step":1,"instruction":"능동 ROM 검사에서 제한된 회전 방향을 확인한다. 바로 누운 자세에서 치료사가 양손으로 환자 머리를 지지한다: 한 손은 후두골, 다른 손은 하악부 또는 이마에 위치한다."},
    {"step":2,"instruction":"제한된 방향으로 서서히 수동 회전을 시작한다. 첫 회전에서 저항 느껴지는 지점(R1)을 파악한다. Grade I–II: R1 이전에서 진동. Grade III: R1을 넘어 진동. Grade IV: 종범위(end range)에서 소진폭 진동."},
    {"step":3,"instruction":"Grade I–II 적용 시 통증 완화를 목표로 1–2분 리듬감 있게 진동한다. 치료 중 통증이 7/10을 초과하면 강도를 줄인다. 급성·아급성 환자에서 시작 grade로 사용한다."},
    {"step":4,"instruction":"Grade III–IV 적용 시 가동성 향상을 목표로 종범위 저항을 느끼며 30초–1분 적용한다. 만성 경직, ROM 제한이 주 증상일 때 사용한다. 경추 회전 제한 + 두통 조합에서 특히 유효하다."},
    {"step":5,"instruction":"치료 후 능동 회전 ROM 재평가 및 통증 변화 확인. 즉각적인 ROM 증가가 없더라도 통증 감소가 있으면 긍정적 반응이다. 3회 연속 세션 후 반응을 평가하고 grade 조정을 계획한다."}
  ]'::jsonb,
  '{"joint_mobilization","ROM_improvement","pain_relief","rotation_restriction"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","hypomobile","morning_stiffness","cervicogenic_headache","disc_related"}',
  '{"fracture","malignancy","instability","neurological_deficit","vbi","upper_cervical_instability","osteoporosis","anticoagulants"}',
  'level_1a'::evidence_level,
  '경추 회전 가동술은 회전 ROM 제한과 경추성 두통에 특히 효과적이다. Maitland(2005) grade 체계로 급성(I-II)부터 만성(III-IV)까지 단계적 적용이 가능하다. 회전 가동술 전 VBI 선별이 필수이며, 상부 경추 회전 시 더욱 주의가 필요하다.',
  'fracture, VBI confirmed, upper_cervical_instability, malignancy',
  'osteoporosis, anticoagulants, severe_acute_pain',
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

-- ────────────────────── JM-CX-LatFx (경추 측방굴곡 가동술) ──────────────────────
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
  'category_joint_mobilization',
  (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
  '경추 관절가동술 — Maitland',
  '경추 측방굴곡 관절가동술', 'Cervical Lateral Flexion Mobilization (Maitland)', 'JM-CX-LatFx',
  'cervical'::body_region, 'C0–C7 경추 측방 관절',
  '바로 눕기 또는 앉기, 경추 중립',
  '환자 머리 쪽(누운 자세) 또는 옆(앉은 자세)',
  '두개골 측방 + 경추 측방 지지',
  '제한된 방향으로의 측방굴곡; 리듬감 있는 진동',
  '[
    {"step":1,"instruction":"능동 ROM 검사에서 제한된 측굴 방향을 확인한다. 바로 눕기 자세에서 치료사가 양손으로 머리를 지지하거나, 앉은 자세에서 한 손으로 반대측 어깨를 고정하고 다른 손으로 머리를 지지한다."},
    {"step":2,"instruction":"제한된 방향(예: 우측 측굴 제한 → 우측 방향)으로 서서히 측굴을 유도한다. R1(첫 저항 지점)을 파악하고 치료 grade를 결정한다. 측굴 과정에서 증상 변화를 관찰한다."},
    {"step":3,"instruction":"Grade I–II 진동: 통증 완화 목적. 가동 범위 초반에서 리듬감 있게 1–2분 적용. 급성 경추통, 근경련 동반 시 먼저 적용한다."},
    {"step":4,"instruction":"Grade III–IV 진동: 가동성 향상 목적. 종범위 저항에서 30초–1분 적용. 만성 측굴 제한, 목-어깨 당김 증상에 효과적이다. 동측 방사통이 없는 경우에만 적용한다."},
    {"step":5,"instruction":"치료 후 양측 측굴 ROM 비교 재평가. 치료 측 ROM이 증가하고 통증이 감소하면 성공적인 반응이다. 측굴 가동술 후 가능하면 치료 측 회전 ROM도 확인한다(측굴-회전 coupling으로 함께 개선되는 경우가 많다)."}
  ]'::jsonb,
  '{"joint_mobilization","ROM_improvement","pain_relief","lateral_flexion_restriction"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","hypomobile","morning_stiffness","cervicogenic_headache"}',
  '{"fracture","malignancy","instability","neurological_deficit","vbi","upper_cervical_instability","osteoporosis","anticoagulants"}',
  'level_2a'::evidence_level,
  '경추 측방굴곡 가동술은 편측 경추통, 목-어깨 긴장, 경추성 두통에 적용한다. 측굴과 회전은 하부 경추(C2-C7)에서 coupled movement(coupling pattern)로 함께 발생하므로, 측굴 가동 후 회전 ROM도 함께 개선되는 경우가 많다.',
  'fracture, VBI, upper_cervical_instability, malignancy',
  'osteoporosis, anticoagulants, ipsilateral_radiculopathy_severe',
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


-- ═══════════════════════════════════════════════════════
-- PART 3: 경추 Mulligan (SNAG) — 3개
-- body_region: cervical
-- ═══════════════════════════════════════════════════════

-- ────────────────────── MUL-CX-SNAG-Rot ──────────────────────
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
  'category_mulligan',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mulligan'),
  'Mulligan SNAG — 경추',
  '경추 회전 SNAG', 'Cervical Rotation SNAG (Sustained Natural Apophyseal Glide)', 'MUL-CX-SNAG-Rot',
  'cervical'::body_region, 'C2–C7 관절돌기 (편측)',
  '앉기, 경추 중립, 발바닥 바닥에 지지',
  '환자 뒤에 위치, 엄지손가락 또는 엄지 척추면을 관절돌기에 접촉',
  '제한된 회전 방향 동측 관절기둥 (관절돌기)',
  '두개골 방향으로 미끄러지기(glide) 유지 + 환자 능동 회전',
  '[
    {"step":1,"instruction":"앉은 자세에서 능동 회전을 평가한다. 통증이 발생하는 분절과 방향을 특정한다. 환자가 회전이 제한되거나 통증이 있는 방향을 치료 방향으로 설정한다."},
    {"step":2,"instruction":"치료사는 환자 뒤에 위치한다. 엄지손가락을 제한된 회전 방향의 동측 관절기둥에 접촉한다. 예: 우측 회전 제한 → 우측 C3 관절기둥에 엄지 접촉."},
    {"step":3,"instruction":"Glide 방향 결정: 두개골 방향(cranial direction)으로 관절기둥을 부드럽게 밀어 glide를 적용한다. Glide를 유지한 채 환자에게 천천히 제한된 방향으로 회전하도록 지시한다."},
    {"step":4,"instruction":"SNAG의 핵심 원칙 확인: 1) Glide 유지 중 회전이 통증 없이 증가해야 한다. 2) 통증이 있으면 glide 방향·강도를 미세 조정하거나 한 분절 위아래로 이동한다. 3) 통증이 있으면 잘못된 분절이거나 잘못된 방향이다."},
    {"step":5,"instruction":"통증 없는 SNAG 확인 후 6–10회 반복한다. 치료 후 능동 회전 ROM 재평가. 즉각적인 ROM 증가(5° 이상)가 없으면 다른 분절을 시도한다. 성공적인 SNAG 분절을 찾으면 자가 SNAG(belt SNAG) 홈 프로그램을 교육한다."}
  ]'::jsonb,
  '{"snag","mulligan_concept","pain_free_movement","ROM_improvement"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","hypomobile","morning_stiffness","cervicogenic_headache","disc_related"}',
  '{"fracture","malignancy","instability","neurological_deficit","vbi","upper_cervical_instability","osteoporosis"}',
  'level_1b'::evidence_level,
  'Cervical SNAG은 Mulligan Concept의 핵심 기법으로 경추 회전 제한 및 경추성 두통에 높은 수준의 근거를 보유한다. Hall et al.(2008), Hidalgo et al.(2015) RCT에서 경추 SNAG의 즉각적·단기 효과가 확인됐다. 통증 없이 glide가 작동하면 정확한 분절이다.',
  'fracture, VBI, upper_cervical_instability, malignancy, acute_neurological_deficit',
  'osteoporosis, anticoagulants, hypermobility',
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

-- ────────────────────── MUL-CX-SNAG-Ext ──────────────────────
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
  'category_mulligan',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mulligan'),
  'Mulligan SNAG — 경추',
  '경추 신전 SNAG', 'Cervical Extension SNAG (Sustained Natural Apophyseal Glide)', 'MUL-CX-SNAG-Ext',
  'cervical'::body_region, 'C2–C7 관절돌기',
  '앉기, 경추 중립',
  '환자 뒤에 위치, 엄지손가락 극돌기 또는 관절기둥에 접촉',
  '목표 분절 극돌기 또는 양측 관절기둥',
  '두개골 방향 glide 유지 + 환자 능동 신전',
  '[
    {"step":1,"instruction":"앉은 자세에서 능동 신전 ROM을 평가한다. 신전 시 통증·제한이 발생하는 분절을 특정한다. 경추 신전 제한이 있거나 신전 시 두통이 발생하는 경우 적응증이다."},
    {"step":2,"instruction":"양측 엄지손가락을 목표 분절 극돌기 또는 양측 관절기둥에 접촉한다. 중앙 glide(bilateral) 또는 편측 glide를 증상에 따라 선택한다."},
    {"step":3,"instruction":"두개골 방향으로 부드럽게 glide를 적용하며 환자에게 천천히 신전하도록 지시한다. Glide 유지 중 신전이 통증 없이 증가해야 한다. 통증이 있으면 분절 또는 glide 방향을 조정한다."},
    {"step":4,"instruction":"통증 없는 신전이 확인되면 6–10회 반복한다. 각 반복 후 신전 ROM 변화를 관찰한다. 신전 말기에 약간의 과압박(overpressure)을 추가하여 범위를 더 확장할 수 있다."},
    {"step":5,"instruction":"치료 후 능동 신전 ROM 재평가. 성공적이면 관련 분절의 자가 SNAG 또는 치료사 SNAG 반복 계획을 수립한다. 신전 SNAG은 추간판 관련 증상(굴곡 시 악화, 신전 시 완화 패턴)에서 특히 효과적이다."}
  ]'::jsonb,
  '{"snag","mulligan_concept","pain_free_movement","extension_restriction"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","hypomobile","disc_related","morning_stiffness"}',
  '{"fracture","malignancy","instability","neurological_deficit","vbi","upper_cervical_instability","osteoporosis"}',
  'level_1b'::evidence_level,
  '경추 신전 SNAG은 신전 제한 및 추간판 관련 경추통(McKenzie directional preference: extension)에 적합하다. Mulligan(2010) 매뉴얼에서 신전 제한의 1차 치료 기법으로 제시된다. 굴곡 방향 McKenzie 반복 운동과 병행 시 상호 보완 효과를 기대할 수 있다.',
  'fracture, VBI, upper_cervical_instability, malignancy, severe_myelopathy',
  'osteoporosis, anticoagulants, acute_severe_disc_herniation',
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

-- ────────────────────── MUL-CX-SNAG-HA (두통 C1-C2 SNAG) ──────────────────────
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
  'category_mulligan',
  (SELECT id FROM technique_categories WHERE category_key = 'category_mulligan'),
  'Mulligan SNAG — 경추',
  '경추성 두통 C1-C2 SNAG', 'Cervicogenic Headache SNAG — C1-C2 Level', 'MUL-CX-SNAG-HA',
  'cervical'::body_region, 'C1–C2 환추축추 관절',
  '앉기, 경추 중립, 고개 약간 전방으로',
  '환자 뒤에 위치, 엄지손가락을 C1 후궁 또는 C2 극돌기에 접촉',
  'C1 후궁 측방 돌기 또는 C2 극돌기 측방',
  '두개골 방향 glide 유지 + 환자 능동 회전',
  '[
    {"step":1,"instruction":"경추성 두통 환자에서 상부 경추(C1-C2) 제한을 평가한다. 두통 방향과 연관된 회전 제한(일반적으로 두통 방향의 반대측 회전 제한)을 확인한다. 두통이 우측이면 우측 회전 시 C1-C2 level에서 제한이 있는 경우가 많다."},
    {"step":2,"instruction":"C1 후궁 측방 또는 C2 극돌기 측방에 엄지손가락을 접촉한다. 상부 경추 접촉 시 매우 부드럽게 접촉하고 과도한 압박을 피한다. VBI 선별이 이미 완료된 상태여야 한다."},
    {"step":3,"instruction":"두개골 방향으로 가볍게 glide를 적용하면서 환자에게 제한된 방향으로 천천히 회전하도록 지시한다. SNAG 적용 중 두통이 재현되거나 어지럼증이 발생하면 즉시 중단한다."},
    {"step":4,"instruction":"통증 없이 회전 ROM이 증가하면 6–10회 반복한다. 각 반복 후 두통 강도 변화(NRS)를 확인한다. 즉각적인 두통 감소가 없으면 C2-C3 레벨로 이동하여 시도한다."},
    {"step":5,"instruction":"성공적인 SNAG 레벨을 찾으면 자가 SNAG 홈 프로그램을 교육한다. 수건이나 벨트를 사용한 자가 SNAG 방법을 시연하고 확인한다. 경추성 두통은 SNAG와 함께 경추 심부굴근(DCF) 강화 운동을 병행할 때 장기 효과가 가장 크다."}
  ]'::jsonb,
  '{"snag","mulligan_concept","headache_treatment","C1_C2_mobilization"}',
  '{"subacute","chronic"}',
  '{"cervicogenic_headache","movement_pain","hypomobile","rest_pain"}',
  '{"fracture","malignancy","instability","neurological_deficit","vbi","upper_cervical_instability","osteoporosis","anticoagulants"}',
  'level_1b'::evidence_level,
  '경추성 두통에 대한 C1-C2 SNAG는 Hall et al.(2007) RCT에서 단기·장기 두통 감소 효과가 확인됐다. 상부 경추 조작 전 VBI 선별이 필수이다. 경추성 두통 진단 기준(ICHD-3)을 먼저 확인하고 편두통과 감별한다. DCF 강화 운동과 병행 시 1년 추적 효과가 가장 크다.',
  'VBI_confirmed, fracture, upper_cervical_instability, down_syndrome, rheumatoid_arthritis_C1_C2',
  'osteoporosis, anticoagulants, migraine_active_phase, high_BP',
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


-- ═══════════════════════════════════════════════════════
-- 최종 확인
-- ═══════════════════════════════════════════════════════
SELECT category, COUNT(*) as count, array_agg(abbreviation ORDER BY abbreviation) as abbreviations
FROM techniques
WHERE abbreviation IN (
  'PNE-Basic','PNE-Metaphor','PNE-GradExp','PNE-Lifestyle',
  'JM-CX-PA-C','JM-CX-PA-U','JM-CX-Rot','JM-CX-LatFx',
  'MUL-CX-SNAG-Rot','MUL-CX-SNAG-Ext','MUL-CX-SNAG-HA'
)
GROUP BY category
ORDER BY category;

COMMIT;
