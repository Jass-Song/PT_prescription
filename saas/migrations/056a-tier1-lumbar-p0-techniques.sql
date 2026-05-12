-- ============================================================
-- Migration 056a — Tier 1 Lumbar P0 (6 신규 INSERT)
-- ============================================================
-- 목적: 베타 출시 Tier 1 큐레이션 (Item 1, docs/clinical-tier1-curation-list-2026-05-12.md)
--      §4.1 P0 항목 — Lumbar Maitland 3 + Lumbar Mulligan 3 신규 INSERT.
--      마이그 038 (cervical Maitland/Mulligan) 동일 패턴.
--
-- [JM 1] JM-LX-PA-C        — 요추 중앙 후-전방 가동술 (Maitland)
-- [JM 2] JM-LX-PA-U        — 요추 단측 후-전방 가동술 (Maitland)
-- [JM 3] JM-LX-Rot         — 요추 회전 관절가동술 (Maitland side-lying)
-- [MUL 1] MUL-LX-SNAG-Flex — 요추 굴곡 SNAG (Mulligan)
-- [MUL 2] MUL-LX-SNAG-Ext  — 요추 신전 SNAG (Mulligan)
-- [MUL 3] MUL-LX-SLR-MWM   — 요추 SLR-MWM (bent leg raise)
--
-- 근거: APTA Low Back Pain CPG 2021 (JOSPT) + KAOMPT 도수치료 최신 지견 2024.
--      docs/clinical-3axis-tier1-recommendation-research-2026-05-06.md §4.2 (Lumbar 9 시나리오).
--
-- KMO: 통증 ≠ 손상 / 반파국화 / Calm things down — Grade I~II 진정 우선, 두려움 유발 표현 금지.
--
-- 멱등성: ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO NOTHING
--        → 재실행 시 기존 row 변경 없음. 056b 에서 is_published toggle.
-- is_active = true, is_published = false (056b 에서 86 큐레이션 시드 시 toggle).
--
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- Author : sw-db-architect | 2026-05-12
-- ============================================================

BEGIN;

-- ═══════════════════════════════════════════════════════
-- PART 1: 요추 Maitland (관절가동술) — 3개
-- body_region: lumbar
-- ═══════════════════════════════════════════════════════

-- ────────────────────── JM-LX-PA-C (요추 중앙 PA) ──────────────────────
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
  '요추 관절가동술 — Maitland',
  '요추 중앙 후-전방 가동술', 'Lumbar Central Posterior-Anterior Mobilization (Maitland)', 'JM-LX-PA-C',
  'lumbar'::body_region, 'L1–L5 극돌기',
  '엎드리기 (prone), 복부 아래 베개로 요추 약간 굴곡 중립 (irritable 환자 시 옵션). 양팔 옆에 편안히, 호흡 자유롭게.',
  '환자 측방에 위치 (치료대 높이 무릎 가까이), 양손 piso-pisiform contact 또는 엄지 겹쳐 극돌기에 접촉. 팔꿈치 신전, 어깨·체중을 수직 정렬.',
  '목표 척추 극돌기 (L1–L5 해당 분절) — 손바닥 piso 또는 양 엄지',
  '후방 → 전방 수직, Maitland grade I~IV 리듬 진동 (Grade I~II 진정, III~IV 가동성)',
  '[
    {"step":1,"instruction":"평가: 환자 능동 굴곡·신전 ROM 및 통증 지도를 확인한다. 엎드리기 자세에서 PA pressure 평가로 통증 분절·저항(R1) 분절을 특정한다. red flag (외상·야간통·체중감소·발열·cauda equina) 사전 스크리닝을 마쳤는지 다시 점검한다."},
    {"step":2,"instruction":"기저 자세 설정: 환자 엎드리기, 복부 아래 작은 베개로 요추를 약간 굴곡시켜 신전 자극을 최소화한다(irritable presentation). 호흡을 자연스럽게 유지하도록 안내한다. 치료사는 piso-pisiform 또는 양 엄지 겹친 형태로 목표 극돌기 위에 접촉한다."},
    {"step":3,"instruction":"적용 — Grade I~II (진정 목적): 통증 지배·acute 자극형에서 R1 이전 소진폭 진동을 1~2분 적용한다. Grade III~IV (가동성 향상 목적): subacute·chronic 경직 시 R1 이후 또는 종범위에서 큰 진폭 또는 소진폭으로 30초~1분 적용. 환자가 통증 없이 압박감을 인지하는 강도로 조절한다."},
    {"step":4,"instruction":"모니터: 진동 중 통증 변화·하지 방사 증상 변화를 지속 확인한다. 동측 하지로의 새로운 방사통 또는 centralization 역행이 발생하면 강도를 즉시 줄이거나 분절을 위·아래로 변경한다. ''괜찮으세요?'' 보다는 ''지금 통증이 다리 어디까지 느껴지나요?'' 식 구체 질문으로 모니터."},
    {"step":5,"instruction":"재평가: 능동 굴곡·신전 ROM, PA 통증, SLR 등을 즉시 재검사한다. 통증 감소 또는 ROM 증가가 있으면 긍정 반응으로 동일 분절 1~2 세트 추가 또는 인접 분절로 확장한다. 변화가 없으면 단측 PA(JM-LX-PA-U) 또는 회전(JM-LX-Rot)로 전환 검토. 치료 후 가벼운 walking 또는 코어 활성화(transverse abdominis) 1~2분으로 마무리한다."}
  ]'::jsonb,
  '{"joint_mobilization","pain_relief","ROM_improvement","hypomobility_treatment"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","rest_pain","hypomobile","morning_stiffness","lbp_nonspecific","disc_related"}',
  '{"fracture","malignancy","instability","cauda_equina","progressive_neurological_deficit","severe_osteoporosis","active_infection","anticoagulants"}',
  'level_1a'::evidence_level,
  'APTA Low Back Pain CPG 2021 — acute/subacute LBP 에서 non-thrust joint mobilization 강한 권고 (JOSPT 2021). Maitland grade 는 통증 자극도와 관절 저항에 따라 선택한다. cauda equina (안장 마취·대소변 장애)·진행성 운동 약화·종양/감염 의심 신호는 모두 절대 의뢰. KMO 메시지: 통증 ≠ 손상, 도수 후 일시 압박감은 자연 반응. KAOMPT 임상 표준 — central PA 는 lumbar mobilization 1차 선택.',
  'fracture, cauda_equina, progressive_motor_weakness, malignancy, active_infection, segmental_instability',
  'severe_osteoporosis, anticoagulants, acute_inflammatory_flare, severe_acute_radiculopathy'
,
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO NOTHING;

-- ────────────────────── JM-LX-PA-U (요추 단측 PA) ──────────────────────
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
  '요추 관절가동술 — Maitland',
  '요추 단측 후-전방 가동술', 'Lumbar Unilateral Posterior-Anterior Mobilization (Maitland)', 'JM-LX-PA-U',
  'lumbar'::body_region, 'L1–L5 횡돌기/관절기둥 (편측)',
  '엎드리기, 복부 아래 베개로 요추 약간 굴곡. 증상측 또는 ROM 제한측이 위로 오도록 자세 미세 조정 가능.',
  '환자 측방, 엄지 또는 piso-pisiform 으로 목표 분절 횡돌기·관절기둥(극돌기 외측 2~3cm)에 접촉. 팔꿈치 신전.',
  '목표 분절 횡돌기 또는 관절기둥 — 극돌기 외측 2~3cm 편측',
  '후방 → 전방, 약간 내측 벡터; 리듬 진동',
  '[
    {"step":1,"instruction":"평가: 능동 ROM 에서 편측 제한 또는 편측 압통이 있는 분절을 특정한다. 방사통 시 contralateral PA 우선 검토(증상측 신경근 부하 회피, APTA 2021). 엎드리기 자세에서 양측 횡돌기 압통 비교로 표적 측을 확정한다."},
    {"step":2,"instruction":"기저 자세: 환자 엎드리기, 약간 굴곡(irritable 시). 치료사 표적 분절 옆에 위치하고 엄지 겹치거나 piso-pisiform 으로 횡돌기·관절기둥(극돌기 외측 2~3cm) 위에 접촉. 체중을 수직~약간 내측으로 정렬."},
    {"step":3,"instruction":"적용: Grade I~II 진동 — 통증 우세·acute 또는 acute 방사통에서 R1 이전 1~2분. Grade III~IV — subacute/chronic 편측 ROM 제한·morning stiffness 에서 R1 이후 30초~1분. 통증 없는 압박감·신장감 강도 유지."},
    {"step":4,"instruction":"모니터: 동측 하지 방사통 변화를 핵심 신호로 추적한다. 새로운 방사 또는 distal 진행(centralization 역행) 시 즉시 강도 감소·분절 변경 또는 contralateral PA 로 전환. SLR / slump 빠른 spot-check 으로 신경 자극도 추적 가능."},
    {"step":5,"instruction":"재평가: 좌우 측굴·회전 ROM 비교, PA 통증 재평가, SLR. 표적 측 ROM 증가·통증 감소이면 1~2 세트 추가 또는 인접 분절로 확장. 변화 부족 시 회전(JM-LX-Rot) 또는 Mulligan SNAG (MUL-LX-SNAG-Flex/Ext) 으로 전환 검토. 치료 후 통증 한계 내 walking 또는 코어 활성화로 마무리."}
  ]'::jsonb,
  '{"joint_mobilization","pain_relief","ROM_improvement","unilateral_treatment"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","hypomobile","morning_stiffness","lbp_nonspecific","radicular_pain","disc_related"}',
  '{"fracture","malignancy","instability","cauda_equina","progressive_neurological_deficit","severe_osteoporosis","active_infection","anticoagulants"}',
  'level_1a'::evidence_level,
  '단측 PA 는 편측 LBP·편측 ROM 제한·편측 방사통(중등도 이하)에 정밀 적용. APTA LBP 2021 — manipulation/mobilization with exercise 강한 권고. 방사통 환자에서는 contralateral PA 로 시작이 안전(JOSPT 2021). KAOMPT 한국 임상 표준. KMO 톤 — ''디스크 손상'' 표현 회피, ''신경 자극 가라앉을 수 있다'' 식 안심 메시지.',
  'fracture, cauda_equina, progressive_motor_weakness, malignancy, active_infection, segmental_instability',
  'severe_osteoporosis, anticoagulants, severe_acute_radiculopathy_ipsilateral',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO NOTHING;

-- ────────────────────── JM-LX-Rot (요추 회전 가동술) ──────────────────────
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
  '요추 관절가동술 — Maitland',
  '요추 회전 관절가동술 (옆누운 자세)', 'Lumbar Rotation Mobilization, Side-lying (Maitland)', 'JM-LX-Rot',
  'lumbar'::body_region, 'L1–L5 회전 분절',
  '옆누운 자세 (side-lying), 치료측이 위. 아래 다리 신전, 위 다리 굴곡하여 목표 분절에 잠금(locking) 유도. 골반 위쪽으로 회전, 흉부 아래쪽으로 회전 — 분절별 ''locking'' 위치.',
  '환자 정면, 한 손 환자 어깨/흉곽 위쪽 접촉, 다른 손 골반(장골능) 접촉. 치료사 체중을 분리된 두 방향으로 분산.',
  '위쪽 손은 환자 어깨/흉곽 전상부, 아래쪽 손은 환자 골반(장골능) 외측',
  '체간 회전(흉부는 후방, 골반은 전방) — 표적 분절에서 회전 분리; 리듬 진동 또는 Grade IV 종범위 유지',
  '[
    {"step":1,"instruction":"평가: 능동 회전 ROM 좌우 비교. 옆누운 회전 PPIVM(passive physiological intervertebral motion)으로 hypomobile 분절을 특정한다. red flag 재확인 (특히 진행성 신경 증상)."},
    {"step":2,"instruction":"기저 자세: 환자 옆누운 자세, 제한 방향에 따라 측 결정 (예: 우측 회전 제한 → 좌측 측와위). 아래 다리 신전, 위 다리 굴곡하여 목표 분절 위로 ''locking''. 환자 위쪽 팔을 가슴 앞으로 두어 흉추 회전을 유도. 치료사 한 손은 환자 어깨/흉곽 전상부, 다른 손은 골반 외측에 접촉."},
    {"step":3,"instruction":"적용: Grade I~II — 흉부·골반을 부드럽게 반대 방향으로 회전 진동 (R1 이전), acute·자극형. Grade III~IV — 종범위(R2)까지 회전 후 소진폭 진동 또는 sustained 30초~1분, subacute/chronic 회전 제한. HVLA thrust 와 구분 — 본 기법은 non-thrust mobilization 만."},
    {"step":4,"instruction":"모니터: 회전 중 통증·방사 증상 변화 추적. 동측 하지 방사 발생·악화 시 즉시 강도 감소·분절 잠금 위치 재조정. 환자 호흡 협응 — 호기 시 회전 점진 적용으로 자율 신경 진정."},
    {"step":5,"instruction":"재평가: 좌우 회전 ROM 즉시 비교, PA 통증 재검사. 표적 측 회전 증가이면 1~2 세트 추가. 변화 부족 시 central PA(JM-LX-PA-C) 또는 Mulligan SNAG 으로 전환 검토. 회전 후 코어 활성화(bird-dog 변형) + walking 으로 운동 통합 마무리."}
  ]'::jsonb,
  '{"joint_mobilization","ROM_improvement","pain_relief","rotation_restriction"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","hypomobile","morning_stiffness","lbp_nonspecific","disc_related"}',
  '{"fracture","malignancy","instability","cauda_equina","progressive_neurological_deficit","severe_osteoporosis","active_infection","spondylolisthesis_high_grade"}',
  'level_2a'::evidence_level,
  'Side-lying lumbar rotation 은 KAOMPT 한국 임상 표준 mobilization 으로, APTA 2021 manipulation/mobilization 권고 범주에 속한다(non-thrust grade III~IV). 회전은 굴곡·신전 단독 PA 에 반응하지 않는 ROM 제한 또는 disc-related 패턴 보조에 유효. 본 기법은 thrust HVLA 가 아니며, HVLA 적용 결정은 별도 임상 의사결정 흐름을 따른다 (베타 범위 외).',
  'fracture, cauda_equina, progressive_motor_weakness, malignancy, high_grade_spondylolisthesis',
  'severe_osteoporosis, anticoagulants, severe_acute_radiculopathy',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO NOTHING;


-- ═══════════════════════════════════════════════════════
-- PART 2: 요추 Mulligan (SNAG / SLR-MWM) — 3개
-- body_region: lumbar
-- ═══════════════════════════════════════════════════════

-- ────────────────────── MUL-LX-SNAG-Flex (요추 굴곡 SNAG) ──────────────────────
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
  'Mulligan SNAG — 요추',
  '요추 굴곡 SNAG', 'Lumbar Flexion SNAG (Sustained Natural Apophyseal Glide)', 'MUL-LX-SNAG-Flex',
  'lumbar'::body_region, 'L1–L5 극돌기',
  '앉은 자세 (치료대 가장자리), 양발 바닥 지지, 골반 중립. 또는 standing.',
  '환자 뒤에 위치. 한 손의 자기 무지측(thenar) 또는 손바닥 측 부위를 환자 표적 분절 극돌기에 접촉, 다른 손은 환자 골반/장골능 안정 지지.',
  '표적 분절 극돌기 (앉은 자세에서 가장 통증·제한 분절)',
  '두측(cranial) 방향 sustained glide 유지 + 환자 능동 굴곡',
  '[
    {"step":1,"instruction":"평가: 앉은 자세 능동 굴곡 ROM·통증 지점·방사 양상 확인. 굴곡 시 통증 발생 ROM 범위를 기록(예: 30° 까지 통증 없음, 그 이상 sharp). 표적 분절은 통증 발생 직전 분절로 가정 후 trial."},
    {"step":2,"instruction":"기저 자세: 환자 치료대 가장자리 앉기, 양발 바닥 안정, 골반 중립. 치료사 환자 뒤 약간 측방. 한 손 thenar (또는 손바닥 척측) 부위를 표적 극돌기 바로 위에 둔다 (예: L3 시작). 다른 손 골반 안정."},
    {"step":3,"instruction":"적용: 표적 극돌기에 두측(머리쪽) 방향 sustained glide 를 부드럽게 적용한다. Glide 유지한 채 환자에게 천천히 능동 굴곡 하도록 지시한다. Mulligan 핵심 — glide 유지 중 굴곡이 ''통증 없이'' 더 증가해야 한다(PILL 원칙: Pain-free, Instant, Long-lasting)."},
    {"step":4,"instruction":"모니터·분절 탐색: 통증이 그대로 또는 악화면 표적 분절이 틀렸다는 신호 — 한 분절 위·아래로 이동(L4, L2 trial) 또는 glide 방향·강도 미세 조정. 통증 없는 굴곡이 확인되면 그 분절·glide 가 정확하다. 6~10회 반복 (반복 사이 짧은 휴식)."},
    {"step":5,"instruction":"재평가: glide 없이 능동 굴곡 ROM 재검사. 즉각 ROM 증가 (5° 이상) 또는 통증 임계점 후방 이동이면 긍정 반응. 자가 SNAG (belt 또는 환자 자가 손) 홈 프로그램 1세트 8~10회 일 2회 처방 검토. 반응 없으면 신전 SNAG(MUL-LX-SNAG-Ext) 또는 PA mobilization 으로 전환."}
  ]'::jsonb,
  '{"snag","mulligan_concept","pain_free_movement","ROM_improvement","flexion_restriction"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","hypomobile","morning_stiffness","lbp_nonspecific","disc_related"}',
  '{"fracture","malignancy","instability","cauda_equina","progressive_neurological_deficit","severe_osteoporosis","active_infection"}',
  'level_1b'::evidence_level,
  'Mulligan Concept SNAG 은 즉시 효과(instant effect)와 PILL 원칙(Pain-free·Instant·Long-lasting)으로 한국 임상에서 선호도가 높다. APTA LBP CPG 2021 — manipulation/mobilization with exercise 강한 권고 범주. Hidalgo 등(2015), Hall 등(2008) 외 cervical SNAG 근거 + Cochrane Mulligan 2025 lumbar 적응. 통증 없이 glide 가 작동하면 정확한 분절이다 — 통증이 있으면 분절·방향을 변경하라는 명확한 임상 신호.',
  'fracture, cauda_equina, progressive_motor_weakness, malignancy, active_infection',
  'severe_osteoporosis, anticoagulants, severe_acute_radiculopathy',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO NOTHING;

-- ────────────────────── MUL-LX-SNAG-Ext (요추 신전 SNAG) ──────────────────────
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
  'Mulligan SNAG — 요추',
  '요추 신전 SNAG', 'Lumbar Extension SNAG (Sustained Natural Apophyseal Glide)', 'MUL-LX-SNAG-Ext',
  'lumbar'::body_region, 'L1–L5 극돌기',
  '앉은 자세 또는 서기. 골반 중립, 양발 안정.',
  '환자 뒤에 위치, thenar 부위로 표적 극돌기에 접촉, 다른 손 골반 지지.',
  '표적 분절 극돌기 (신전 시 통증 발생 분절)',
  '두측(cranial) 방향 sustained glide + 환자 능동 신전',
  '[
    {"step":1,"instruction":"평가: 앉기 또는 서기 능동 신전 ROM·통증 지점 확인. 신전 시 통증 발생 ROM 기록 (예: 10° 까지 OK, 그 이상 sharp 또는 ''방사 자극''). McKenzie directional preference 평가와 결합 검토 — centralization 패턴 환자에 특히 적합."},
    {"step":2,"instruction":"기저 자세: 환자 앉기/서기, 골반 중립, 양발 안정. 치료사 환자 뒤. thenar (또는 손바닥 척측)을 표적 극돌기에 둔다. 다른 손 환자 골반/장골능에 가볍게 안정 접촉."},
    {"step":3,"instruction":"적용: 두측 방향 sustained glide 유지, 환자에게 천천히 능동 신전 지시. Glide 유지 중 신전이 통증 없이 증가하는지 확인. 통증 있으면 분절(L4↔L3↔L2)·glide 방향 미세 조정. PILL 원칙 — pain-free 우선."},
    {"step":4,"instruction":"반복·홈 프로그램: 통증 없는 SNAG 확인 후 6~10회 반복. 신전 말기에 가벼운 over-pressure (환자 본인이 추가 신전) 가능. 자가 SNAG (벨트 또는 자기 손 접촉) 홈 프로그램 — 단, McKenzie centralization 양성 패턴 환자에서만 신전 반복 처방. stenosis 환자에는 신전 신중 (통증 패턴 반대)."},
    {"step":5,"instruction":"재평가: glide 없이 능동 신전 ROM, 방사 증상 변화. 신전 ROM 증가 + 방사 centralization 이면 강력 긍정 반응. peripheralization (다리 쪽으로 새 방사) 발생 시 즉시 중단·분절·방향 재검토. 반응 없으면 굴곡 SNAG 또는 PA mobilization 로 전환."}
  ]'::jsonb,
  '{"snag","mulligan_concept","pain_free_movement","extension_restriction"}',
  '{"acute","subacute","chronic"}',
  '{"movement_pain","hypomobile","disc_related","morning_stiffness","lbp_nonspecific"}',
  '{"fracture","malignancy","instability","cauda_equina","progressive_neurological_deficit","severe_osteoporosis","spinal_stenosis_severe"}',
  'level_1b'::evidence_level,
  '신전 SNAG 은 McKenzie directional preference (신전 선호) 환자에서 특히 효과적이다. APTA LBP 2021 + JOSPT 2016 (McKenzie chronic LBP). PILL 원칙 — pain-free 가 분절 정확성의 임상 지표. spinal stenosis 환자는 신전 통증 패턴 반대이므로 신중. KMO 톤 — ''디스크가 망가졌다'' 식 표현 피하고 ''신경 자극이 가라앉을 수 있다'' 식 안심 메시지 유지.',
  'fracture, cauda_equina, progressive_motor_weakness, malignancy, severe_spinal_stenosis_with_neurogenic_claudication',
  'severe_osteoporosis, anticoagulants, severe_acute_radiculopathy',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO NOTHING;

-- ────────────────────── MUL-LX-SLR-MWM (요추 SLR-MWM, bent leg raise) ──────────────────────
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
  'Mulligan MWM — 요추 신경 동원',
  '요추 SLR-MWM (Bent Leg Raise)', 'Lumbar Straight Leg Raise — Mobilization with Movement (Bent Leg Raise)', 'MUL-LX-SLR-MWM',
  'lumbar'::body_region, '요추-좌골 신경 경로 (Sciatic nerve track)',
  '바로 누운 자세 (supine), 양다리 신전.',
  '환자 증상측 옆. 환자 굴곡 무릎을 치료사 어깨 위에 올려 hip flexion 자세 유지. 한 손 환자 무릎 위, 다른 손 발 또는 발목 지지.',
  '증상측 하지 — 환자 무릎 굴곡, 고관절 굴곡 → 치료사 어깨 지지',
  '환자 능동 무릎 신전 (knee extension) 시도 — 치료사는 hip flexion 한계 내에서 부드러운 traction/glide 추가',
  '[
    {"step":1,"instruction":"평가: 양측 SLR baseline 측정 (저항 시작 각도와 증상 재현 각도, 증상 distribution). 통증·저림이 다리 어디까지(허벅지·종아리·발)·어떤 패턴(burning, tingling, sharp)인지 기록. red flag 재확인 — 진행성 운동 약화·cauda equina 신호 절대 의뢰."},
    {"step":2,"instruction":"기저 자세: 환자 supine, 증상측 무릎·고관절 굴곡하여 치료사 어깨 위에 무릎을 올린다 (bent leg raise 자세). 환자 hip flexion 90° 부근, 무릎 굴곡 90° 부근 (증상 임계점 ''안쪽'' 시작). 치료사 한 손 환자 무릎 위, 다른 손 발/발목 지지."},
    {"step":3,"instruction":"적용: hip flexion 자세를 유지한 채 환자에게 ''천천히 무릎을 펴 보세요'' 능동 신전 지시. 치료사는 hip flexion 을 통증 없는 한계 내로 유지하면서 어깨로 가벼운 longitudinal traction 또는 부드러운 hip flexion glide 를 추가한다. 핵심 — 환자가 능동 신전하는 동안 ''통증 없는 추가 ROM'' 이 생겨야 한다 (PILL: pain-free)."},
    {"step":4,"instruction":"모니터: 환자에게 다리 증상 변화를 실시간 질문 — ''저림이 줄었나요, 그대로인가요, 더 멀리 가나요?''. centralization (다리 → 허리 쪽으로 후퇴) = 긍정. peripheralization (허리 → 다리 distal 진행) = 즉시 중단. 6~10회 반복 (각 반복 사이 짧은 휴식)."},
    {"step":5,"instruction":"재평가: bent leg raise 없이 supine SLR 재측정. SLR 각도 증가 (>10°) 또는 통증 임계 distal 이동이면 강력 긍정 반응. 자가 SLR-MWM (towel·strap 활용 home program) 8~10회 일 2회 처방 검토. 반응 없으면 neural slider 운동 또는 PA mobilization (JM-LX-PA-U contralateral) 으로 전환."}
  ]'::jsonb,
  '{"mwm","mulligan_concept","neural_mobilization","pain_free_movement","radicular_pain_treatment"}',
  '{"acute","subacute","chronic"}',
  '{"radicular_pain","movement_pain","disc_related","sciatica","lbp_nonspecific"}',
  '{"fracture","malignancy","cauda_equina","progressive_neurological_deficit","severe_osteoporosis","active_infection"}',
  'level_2a'::evidence_level,
  'SLR-MWM (Bent Leg Raise) 은 신경 자극·요추 디스크 양상 방사통 환자에서 ''통증 없는 점진 동원''을 가능하게 하는 Mulligan 기법이다. Cochrane neural mobilization 2023 (PMC 2023) lower-quarter mobilization 권장과 APTA LBP 2021 acute/subacute radiating pain 권고 범주에 부합. PILL 원칙 — pain-free 가 분절·방향·강도 정확성의 임상 지표. KMO 메시지: ''신경이 손상됐다'' 식 표현 회피, ''신경이 점차 자유롭게 움직일 수 있다'' 식 안심 표현 유지.',
  'fracture, cauda_equina, progressive_motor_weakness (foot_drop 등), malignancy',
  'severe_osteoporosis, anticoagulants, severe_acute_radiculopathy_with_motor_loss',
  true, false
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO NOTHING;


-- ═══════════════════════════════════════════════════════
-- 검증: 6 신규 abbreviation 존재 확인 (NOTICE 출력)
-- ═══════════════════════════════════════════════════════
DO $$
DECLARE
  v_count INT;
BEGIN
  SELECT COUNT(*)
    INTO v_count
    FROM techniques
   WHERE abbreviation IN (
     'JM-LX-PA-C','JM-LX-PA-U','JM-LX-Rot',
     'MUL-LX-SNAG-Flex','MUL-LX-SNAG-Ext','MUL-LX-SLR-MWM'
   );
  RAISE NOTICE '056a 결과 — Tier 1 Lumbar P0 abbreviation 카운트: %', v_count;
  IF v_count <> 6 THEN
    RAISE EXCEPTION '056a 실패 — 기대 6, 실제 %', v_count;
  END IF;
END $$;

COMMIT;

-- ============================================================
-- END OF MIGRATION 056a
-- ============================================================
