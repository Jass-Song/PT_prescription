-- ============================================================
-- K-Movement Optimism — Migration 002b
-- 연부조직 기법 (IASTM 9개, MFR 17개) 26개
-- 생성일: 2026-04-25
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- ⚠️  실행 순서 필수:
--     1단계: 002a-soft-tissue-enum.sql 먼저 실행 (ENUM 확장 커밋)
--     2단계: 이 파일 실행 (카테고리 + 테크닉 26개 INSERT)
-- ============================================================

-- STEP 2: 카테고리 INSERT (이미 있으면 스킵)
INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active)
VALUES (
  'category_e_soft_tissue',
  '연부조직 기법',
  'Soft Tissue Techniques',
  'MFR / IASTM 기반 접근법',
  '[
    {"icon":"🤲","title_ko":"부드럽고 지속적인 압력","desc_ko":"강한 힘이 아닌 부드럽고 지속적인 압력으로 근막과 연부조직을 이완합니다. 탄성 끝(elastic barrier)을 찾아 조직이 반응할 때까지 기다립니다."},
    {"icon":"⏱️","title_ko":"충분한 시간 투자","desc_ko":"근막 이완은 최소 90초~2분 이상 기다려야 시작됩니다. 빠르게 움직이면 조직이 반응할 시간이 없습니다."},
    {"icon":"🔍","title_ko":"이완 신호 인식","desc_ko":"치료사 손 아래에서 조직이 따뜻해지거나 부드러워지는 느낌이 이완 반응의 신호입니다."},
    {"icon":"🛠️","title_ko":"IASTM 도구 각도와 방향","desc_ko":"30~45° 각도로 피부에 대고 일정한 속도로 쓸어내립니다. 반드시 오일을 바른 후 시행합니다."},
    {"icon":"🚫","title_ko":"절대 금기 준수","desc_ko":"골절, DVT, 악성 종양, 개방성 상처에는 절대 시행하지 않습니다. 경추 기법 시 VBI 위험 사전 확인 필수."}
  ]'::jsonb,
  3,
  true
)
ON CONFLICT (category_key) DO NOTHING;

-- STEP 3: 테크닉 INSERT (26개)

-- ────────────────────────────────
-- IASTM 기법 9개
-- ────────────────────────────────

-- IASTM-01: 종아리·아킬레스건 IASTM (도구 이용 연부조직 가동술)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'IASTM',
  '종아리·아킬레스건 IASTM (도구 이용 연부조직 가동술)', 'IASTM for Calf & Achilles Tendon', 'IASTM-CA',
  'ankle_foot'::body_region, '장딴지근(비복근)·가자미근 근복 ~ 아킬레스건 ~ 발꿈치뼈(종골) 부착부',
  NULL, NULL,
  NULL, NULL,
  '[{"step":1,"instruction":"종아리 전체(무릎 아래~발꿈치)에 오일을 얇게 바름. 아킬레스건 부위도 함께 도포."},{"step":2,"instruction":"무릎 아래(종아리 위쪽)에 넓은 볼록면 도구를 45도로 대고, 발꿈치 방향으로 내려오는 스트로크 5~7회 실시 (근육 결 방향). 이어서 발꿈치 쪽에서 무릎 쪽으로 올라오는 반대 방향 스트로크 5~7회. 안쪽·가운데·바깥쪽 세 구역으로 나눠 반복."},{"step":3,"instruction":"좁고 오목한 엣지로 전환. 발꿈치뼈(종골) 부착 부위 바로 위에서 시작해 종아리 근육 합류 부위(장딴지근·가자미근이 건과 합쳐지는 곳)까지 건을 따라 위아래로 스트로크 5~7회 실시 (45~60도 각도)."},{"step":4,"instruction":"건 주변에서 저항감·결절이 느껴지는 부위에 건과 직각 방향으로 짧은 가로 스트로크 8~10회 추가. 압력은 가벼움~중간으로, 건 위에서 과도한 압력 금지."},{"step":5,"instruction":"시술 후 환자가 발목을 위로 꺾는 동작(발등굽힘)을 해보게 하고 종아리 당김·아킬레스건 통증 변화를 확인. 걷기 시 발뒤꿈치 통증 변화를 간단히 물어봄."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: > 3줄 이내, 가장 중요한 포인트만: | 1. 아킬레스건 파열이 의심되거나 발뒤꿈치에 심한 부종·열감이 있으면 IASTM은 절대 금기 — 시술 전 반드시 확인. | 2. 종아리 근육 → 아킬레스건 순서로 시술하면 조직이 점진적으로 이완되어 아킬레스건 접근이 더 용이해진다. | 3. 시술 후 종아리 스트레칭(무릎을 펴고 발목 위로 꺾기)을 연결하면 발목 발등굽힘 범위 개선 효과가 높아진다. | -- || 좋은 반응: 시술 후 발목을 위로 꺾는 동작(발등굽힘) 시 종아리 당김이 줄어들고 가동 범위가 늘어남 | 아킬레스건 주변 뻣뻣함이 감소하고 가볍게 발뒤꿈치를 들어 올리는 동작이 편해짐 | 종아리 근육 전반의 긴장감(뻣뻣함)이 줄었다고 표현 | 시술 후 걷기 시작했을 때 발뒤꿈치 착지 통증이 감소',
  '척추동맥 혈액순환 장애 위험, 골절 (발꿈치뼈 피로골절, 아킬레스건 파열 의심 포함), 불안정성 (아킬레스건 파열 확인된 경우), 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증 (발뒤꿈치 심한 부종·열감 동반 시), 발뒤꿈치·종아리 피부 상처·개방성 병변',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- IASTM-02: 발바닥 근막 IASTM (도구 이용 연부조직 가동술)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'IASTM',
  '발바닥 근막 IASTM (도구 이용 연부조직 가동술)', 'IASTM for Plantar Fascia', 'IASTM-PF',
  'ankle_foot'::body_region, '발꿈치뼈(종골) 내측 결절 ~ 발가락 기저부',
  NULL, NULL,
  NULL, NULL,
  '[{"step":1,"instruction":"발바닥 전체에 IASTM 전용 크림 또는 마사지 오일을 얇게 펴 바름. 크림이 과하면 도구 저항 감지가 어려우므로 최소량 사용."},{"step":2,"instruction":"발꿈치뼈(종골) 내측 결절 바로 앞쪽, 발바닥 근막이 시작되는 부위에 도구의 엣지를 45~60도 각도로 가볍게 댐. 뼈 위에 직접 올려놓지 않도록 주의."},{"step":3,"instruction":"발꿈치에서 발가락 방향(앞쪽)으로 천천히 밀어나가는 스트로크를 5~7회 실시. 저항감이 강하거나 뭉친 느낌이 있는 부위를 탐색하며 발바닥 전체 조직 상태를 파악함."},{"step":4,"instruction":"저항감이 느껴지는 부위를 찾으면 그 지점에서 발의 긴 방향과 직각으로 짧은 가로 스트로크(횡마찰)를 8~10회 추가. 전체 발바닥을 안쪽 아치에서 바깥쪽 아치 순으로 구역을 나눠 반복. 압력은 환자 반응에 따라 가볍게~중간으로 조절."},{"step":5,"instruction":"시술 후 환자가 발바닥 통증의 변화를 느끼는지 확인. 발꿈치 부착 부위(발꿈치뼈 앞쪽)의 국소 압통이 감소했는지, 발목 발등굽힘(위로 꺾기) 가동 범위가 개선됐는지 간단히 재평가."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: > 3줄 이내, 가장 중요한 포인트만: | 1. 발바닥은 신경이 매우 풍부하여 통증에 예민하므로, 첫 세션에서는 무조건 가벼운 압력으로 시작하고 환자 반응을 보며 점진적으로 조절한다. | 2. IASTM 시술 직후 종아리 스트레칭 또는 발바닥 근막 스트레칭을 연결하면 가동 범위 개선 효과를 높일 수 있다. | 3. 발바닥 근막병증은 통증이 곧 손상이나 악화를 의미하지 않는다는 것을 환자에게 미리 설명하여 시술 중 불안과 과도한 긴장을 줄인다. | -- || 좋은 반응: 시술 중 또는 직후 발바닥 내측(발꿈치 쪽) 뻣뻣함이 감소하고 발바닥이 좀 더 부드럽게 느껴진다고 표현 | 발목을 위로 꺾는 동작(발등굽힘) 시 발바닥 당김이 줄어든다 | 발꿈치 부착 부위의 국소 압통 점수(VAS 또는 NRS)가 시술 전보다 1~2점 감소 | 시술 직후 걷기 시작했을 때 발바닥 뻣뻣함이 감소되었다고 표현',
  '척추동맥 혈액순환 장애 위험, 골절 (발꿈치뼈 피로골절 의심 포함), 불안정성, 종양 / 악성 질환, 신경학적 결손', '골다공증 (특히 노인, 강한 압력 주의), 급성 염증 (발바닥 심한 부종·열감 동반 시), 발바닥 피부 상처·개방성 상처·수포',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- IASTM-03: 아래팔·손목 굽힘근·폄근 IASTM
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'IASTM',
  '아래팔·손목 굽힘근·폄근 IASTM', 'IASTM — Forearm & Wrist Flexor / Extensor Group', 'IASTM-FWE',
  'wrist_hand'::body_region, '팔꿈치 가쪽 위관절융기(외측상과, lateral epicondyle) ~ 손목, 팔꿈치 안쪽 위관절융기(내측상과, medial epicondyle) ~ 손목',
  '앉은 자세. 팔꿈치를 테이블 위에 올려놓고 손목은 테이블 끝 밖으로 살짝 내밀어 아래팔(전완)이 안정적으로 지지되도록 함. 손바닥을 아래로(폄근 시술 시) 또는 위로(굽힘근 시술 시) 향하도록 자세 조절', '환자 맞은편 또는 옆에 앉아 아래팔이 눈높이에 오도록 위치',
  '폄근군(팔꿈치 가쪽·아래팔 등쪽), 굽힘근군(팔꿈치 안쪽·아래팔 배쪽)', '팔꿈치 → 손목 방향(위아래), 저항 부위에서 가로 방향 추가',
  '[{"step":1,"instruction":"(준비) 아래팔 전체(앞·뒤)에 오일을 바릅니다. 손바닥 방향에 따라 폄근 시술 → 굽힘근 시술 순서로 진행합니다."},{"step":2,"instruction":"(폄근군 접촉) 손바닥을 아래로. 팔꿈치 가쪽 뼈(가쪽 위관절융기, lateral epicondyle) 바로 아래에서 도구를 45~60도 각도로 댑니다. 뼈 위 직접 자극 금지 — 뼈 아래쪽 근육 시작 부위부터 적용."},{"step":3,"instruction":"(폄근군 스트로크) 손목 방향(손끝쪽)으로 스트로크 5~7회, 반대로 손목에서 팔꿈치 방향으로 5~7회. 저항이 강한 부위에서 가로 스트로크 8~10회 추가."},{"step":4,"instruction":"(굽힘근군) 손바닥을 위로. 팔꿈치 안쪽 뼈(안쪽 위관절융기, medial epicondyle) 바로 아래에서 손목 방향으로 스트로크 5~7회, 반대 방향도 반복. 안쪽 팔꿈치는 자신경(척골신경, ulnar nerve)이 지나므로 매우 가볍게 시작."},{"step":5,"instruction":"(능동 운동 연결·평가) 저항이 강한 부위에서 도구를 가볍게 댄 채 환자에게 손목을 위아래로 천천히 움직이게 하며(능동 보조 운동) 3~5회 반복. 시술 후 손목 굽히기·펴기 범위와 통증 변화 확인."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: 1. 테니스엘보(팔꿈치 가쪽 통증) 환자는 폄근군 시술 후 손목 폄(extension) 능동 운동을 연결하면 힘줄 부착 부위 자극과 재생을 돕습니다. | 2. 아래팔 안쪽(굽힘근군) 시술 시 항상 자신경 주행 경로(팔꿈치 안쪽 → 손 4~5번째 손가락 방향)를 의식하고 가볍게 접근하세요. | 3. 반복적 타이핑·마우스 사용으로 인한 아래팔 과부하 환자는 IASTM 후 작업 환경 개선(인체공학적 배치)을 함께 안내하는 것이 재발 방지에 효과적입니다. | -- || 좋은 반응: 시술 후 손목 굽히기·펴기 범위가 이전보다 증가하거나 뻑뻑함이 감소 | 팔꿈치 가쪽 또는 안쪽의 압통이 시술 전보다 경감됨 (VAS 1~2점 감소) | 환자가 "아래팔이 좀 가벼워진 것 같다" 또는 "팔꿈치 쪽이 덜 당긴다"고 보고',
  '척추동맥 혈액순환 장애 위험 (아래팔에는 해당 없음), 골절 (의심 포함), 불안정성, 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증, 팔꿈치 안쪽(내측상과) 뼈 위 직접 강한 자극 — 자신경(척골신경) 주행 경로',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- IASTM-04: 허리 근육 IASTM (도구 이용 연부조직 가동술)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'IASTM',
  '허리 근육 IASTM (도구 이용 연부조직 가동술)', 'IASTM for Lumbar Paraspinal Muscles', 'IASTM-LBM',
  'lumbar'::body_region, '허리 척추(요추) L1~L5 양쪽 척추세움근(erector spinae)·다열근(multifidus) 근복',
  NULL, NULL,
  NULL, NULL,
  '[{"step":1,"instruction":"허리 양쪽에 오일을 얇게 바름. 엉치뼈(천골, 골반 뒤 삼각형 뼈) 위에서 갈비뼈 아래쪽까지 충분히 도포. 척추 가운데 뼈 돌기(가시돌기) 위에는 도포하지 않아도 무방."},{"step":2,"instruction":"척추뼈 가시돌기(등 가운데를 따라 만져지는 뼈 돌기)에서 바깥쪽으로 1~2cm 떨어진 위치에 도구를 댐. 뼈 위를 직접 자극하지 않도록 항상 확인. 도구를 가볍게 대어 척추 옆 근육(척추세움근·다열근)의 결 방향을 확인."},{"step":3,"instruction":"엉치뼈(천골) 위, 허리 아래쪽에서 시작해 넓은 볼록면을 45도로 대고 갈비뼈 아래 방향(위쪽, 등 방향)으로 올라가는 스트로크 5~7회 실시. 이어서 위에서 아래로 내려오는 스트로크 5~7회. 저항이 강한 부위와 근육 경결 부위 탐색."},{"step":4,"instruction":"저항이 강한 부위에서 짧은 가로 스트로크(횡마찰) 8~10회 추가. 허리 양쪽을 각각 시술. 한쪽씩 완료 후 반대쪽으로 이동. 척추 가운데 뼈 돌기에서 벗어나지 않도록 항상 위치 확인."},{"step":5,"instruction":"시술 후 환자에게 서도록 하고 허리를 앞으로 굽히는 동작(전굴 forward flexion) 및 옆으로 기울이는 동작(측굴)을 해보게 하여 허리 움직임과 통증 변화 확인. 시술 전과 비교하여 동작 범위 변화를 간단히 기록."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: > 3줄 이내, 가장 중요한 포인트만: | 1. 척추뼈 가시돌기(허리 가운데 만져지는 뼈 돌기) 위를 직접 자극하는 것은 절대 금지 — 모든 스트로크는 뼈에서 1~2cm 바깥쪽 근육에서만 실시한다. | 2. 다리 저림·방사통이 있는 급성기 환자에게는 IASTM을 적용하지 않으며, 아급성·만성기에도 시술 중 다리 저림이 발생하면 즉시 중단한다. | 3. IASTM 시술 후 허리 근육 이완 체조 또는 무릎 가슴으로 당기기(knee-to-chest) 스트레칭을 연결하면 유연성 향상 효과가 높아진다. | -- || 좋은 반응: 시술 후 허리를 앞으로 굽히는 동작(전굴)이 편해지고 손이 바닥에 더 가까이 닿는다고 표현 | 허리 양쪽 근육의 뻣뻣함이 줄었다고 표현 | 허리 옆으로 기울이는 동작(측굴)이나 허리를 돌리는 동작(회전)이 더 자유로워짐 | 허리 근육을 눌렀을 때 국소 압통이 시술 전보다 감소',
  '척추동맥 혈액순환 장애 위험, 골절 (허리 척추 압박골절·피로골절 의심 포함), 불안정성 (허리 척추 분리증·전방 전위증 포함), 종양 / 악성 질환, 신경학적 결손 (다리 근력 저하·반사 소실·방광·장 기능 이상)', '골다공증 (특히 노인, 강한 압력 주의), 급성 염증 (허리 급성 통증 발병 2주 이내, 염증 징후 동반 시), 허리 수술 후 완전히 치유되지 않은 시기 / 임신 중 허리 시술 (주의)',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- IASTM-05: 목 옆 근육 IASTM (목빗근·위등세모근·머리반가시근)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'IASTM',
  '목 옆 근육 IASTM (목빗근·위등세모근·머리반가시근)', 'IASTM — Cervical Lateral Muscles (SCM, Upper Trapezius, Semispinalis Capitis)', 'IASTM-CLM',
  'cervical'::body_region, 'C1-C7 주변 연부조직',
  '앉은 자세 (등을 편 채 앉기) 또는 등 대고 누운 자세에서 고개를 반대쪽으로 살짝 돌림. 목 근육이 이완되도록 어깨에 힘을 빼도록 안내', '환자 옆 또는 뒤에 위치. 시술 부위가 눈높이에 오도록 의자 높이 조절',
  '목 옆면 연부조직 — 목빗근(복장빗장꼭지근, sternocleidomastoid), 위등세모근(상부 승모근, upper trapezius), 머리반가시근(semispinalis capitis)', '근육 결 방향 따라 위아래, 저항 부위에서 가로 방향 추가',
  '[{"step":1,"instruction":"(준비) 시술 부위에 오일을 소량 바릅니다. 목은 면적이 작으므로 소량으로 충분합니다."},{"step":2,"instruction":"(목빗근 접촉) 귀 뒤 유양돌기(귀 뒤 뼈 돌기) 아래에 도구를 30~45도 각도로 댑니다."},{"step":3,"instruction":"(목빗근 스트로크) 빗장뼈(쇄골) 방향으로 아래쪽으로 스트로크 5~7회, 이어서 반대 방향(아래→위)으로 5~7회. 경동맥(목 앞 중앙·앞쪽 옆)을 피해 목빗근 근육 위에만 자극합니다."},{"step":4,"instruction":"(위등세모근) 목 아래(C7 주변)에서 어깨 봉우리(견봉) 방향으로 스트로크 5~7회. 저항이 강한 부위에서 근육 결과 직각 방향으로 짧은 가로 스트로크 8~10회 추가."},{"step":5,"instruction":"(머리반가시근·평가) 뒤통수뼈 아래에서 목 척추(경추) 방향으로 아래쪽 스트로크 5~7회. 시술 후 환자에게 고개 돌리기·앞뒤 기울이기를 해보도록 해 가동 범위 변화 확인."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['vbi_risk', 'fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: 1. 목은 도구 압력보다 스트로크 방향의 정확성이 더 중요합니다. 경동맥·척추동맥 주행 경로를 머릿속에 그리면서 시술하세요. | 2. 첫 세션에서는 1분 이내로 짧게 시작해 환자 반응을 확인한 뒤 점진적으로 시간을 늘리세요. | 3. IASTM 시술 후 바로 목 스트레칭 또는 가벼운 능동 운동을 연결하면 효과가 높아집니다. | -- || 좋은 반응: 시술 후 고개를 돌릴 때 이전보다 덜 뻑뻑하거나 범위가 늘어남 | 목 옆 근육의 압통이 시술 전보다 경감됨 (VAS 1~2점 감소) | 환자가 "목이 좀 가벼워진 것 같다"고 주관적으로 보고',
  '척추동맥 혈액순환 장애 위험 (목 테크닉 시 필수 확인), 골절 (의심 포함), 불안정성, 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증, 경동맥(목 앞 옆 혈관) 부위 직접 압박 금지',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- IASTM-06: 어깨 회전근개 IASTM (가시위근·가시아래근·작은원근)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'IASTM',
  '어깨 회전근개 IASTM (가시위근·가시아래근·작은원근)', 'IASTM — Shoulder Rotator Cuff (Supraspinatus, Infraspinatus, Teres Minor)', 'IASTM-SRC',
  'shoulder'::body_region, '날개뼈(견갑골) 위·뒤 연부조직, 가시위오목(supraspinous fossa), 가시아래오목(infraspinous fossa)',
  '', '환자 뒤 또는 옆에 서서 날개뼈 주변이 잘 보이는 위치. 시술 부위에 직각으로 도구를 접근할 수 있도록 서는 방향 조절',
  '날개뼈 위쪽 능선 위(가시위근), 날개뼈 뒤쪽 아래 넓은 면(가시아래근), 날개뼈 바깥쪽 테두리(작은원근)', '근육 결 방향 (가로·세로 혼합), 저항 부위에서 가로 방향 추가',
  '[{"step":1,"instruction":"(준비) 시술 부위(가시위근→가시아래근→작은원근 순서)에 오일을 바릅니다."},{"step":2,"instruction":"(가시위근 접촉) 날개뼈 위쪽 능선 바로 위, 안쪽(척추 쪽)에서 시작해 도구를 45도로 댑니다."},{"step":3,"instruction":"(가시위근 스트로크) 안쪽에서 바깥쪽(어깨 봉우리 방향)으로 스트로크 5~7회, 반대 방향도 반복. 날개뼈 뼈 능선 위는 시술 금지 — 뼈에서 살짝 떨어진 근육 부분만 자극합니다."},{"step":4,"instruction":"(가시아래근·작은원근) 날개뼈 뒤쪽 아래 넓은 면에서 안쪽(척추 쪽)에서 바깥쪽(어깨 방향)으로 스트로크 5~7회, 위아래 방향으로도 5~7회. 날개뼈 바깥쪽 테두리를 따라 작은원근 방향으로 위아래 5~7회 추가."},{"step":5,"instruction":"(평가) 저항이 심한 부위에서 가로 스트로크 추가. 시술 후 환자에게 팔 들어올리기를 해보도록 해 가동 범위·통증 변화 확인."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic', 'post_surgical'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: 1. 어깨 근육은 날개뼈 위에 붙어 있어 생각보다 얕습니다. 45도 이하의 낮은 각도로 근육만 자극하고 뼈에 닿지 않도록 주의하세요. | 2. 가시아래근은 어깨를 가쪽으로 돌리는(외회전) 근육이므로, 시술 후 어깨 바깥 돌리기 능동 운동을 2~3회 연결하면 효과가 높아집니다. | 3. 어깨 충돌증후군(회전근개 충돌) 환자는 IASTM 단독보다 이후 어깨 안정화 운동과 병행할 때 더 나은 결과를 보입니다. | -- || 좋은 반응: 시술 후 팔 들어올리기 범위가 이전보다 증가하거나 걸리는 느낌이 감소 | 날개뼈 주변 압통이 시술 전보다 경감됨 (VAS 1~2점 감소) | 환자가 "어깨가 좀 가벼워진 것 같다" 또는 "걸리던 느낌이 줄었다"고 보고',
  '척추동맥 혈액순환 장애 위험 (어깨에는 해당 없음), 골절 (의심 포함), 불안정성 (어깨 탈구 이력이 있는 급성기), 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증 (급성기 어깨 충돌증후군, 힘줄 파열 확인된 경우), 어깨 회전근개 완전 파열 확인된 경우',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- IASTM-07: 햄스트링 IASTM (도구 이용 연부조직 가동술)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'IASTM',
  '햄스트링 IASTM (도구 이용 연부조직 가동술)', 'IASTM for Hamstrings (Thigh Posterior)', 'IASTM-HS',
  'hip'::body_region, '좌골결절(ischial tuberosity) ~ 넙다리두갈래근·반힘줄근·반막근 근복 ~ 무릎 뒤 오금(슬와부) 위 힘줄',
  NULL, NULL,
  NULL, NULL,
  '[{"step":1,"instruction":"허벅지 뒤쪽 전체에 오일을 얇게 바름. 무릎 뒤 오금(슬와부) 위 5cm부터 엉덩이 아래 좌골결절 부위까지 충분히 도포."},{"step":2,"instruction":"무릎 위(오금 위 5cm)에서 넓은 볼록면 도구를 45도로 대고 좌골결절(엉덩이 아래 앉을 때 닿는 뼈 부위) 방향으로 올라가는 스트로크 5~7회 실시 (근육 결 방향). 이어서 좌골결절에서 무릎 방향으로 내려오는 스트로크 5~7회. 저항이 강한 결절 부위 탐색."},{"step":3,"instruction":"허벅지 뒤를 안쪽(반힘줄근·반막근 semimembranosus·semitendinosus)·바깥쪽(넙다리두갈래근 biceps femoris)으로 나눠 각각 위아래 스트로크 5~7회씩 반복. 가운데 중앙 부위도 포함."},{"step":4,"instruction":"단단한 결절이 느껴지는 부위에서 짧은 가로 스트로크(횡마찰) 8~10회 추가. 좌골결절 주변 햄스트링 시작 부위는 압통이 강할 수 있으므로 특히 부드럽게 접근."},{"step":5,"instruction":"시술 후 환자가 등 대고 누운 자세(천장을 바라보고 누운 자세)로 바꾸어 한쪽 다리를 무릎을 편 채 들어 올리는 동작(능동 직다리 올리기 active SLR)을 해보게 하고 허벅지 뒤 당김 변화 확인. 각도 증가 여부를 간단히 기록."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: > 3줄 이내, 가장 중요한 포인트만: | 1. 오금(무릎 뒤 접히는 부분) 바로 뒤는 혈관·신경이 밀집한 부위이므로 절대 직접 강하게 자극하지 않는다. | 2. 좌골신경(허벅지 뒤 중앙을 내려가는 굵은 신경)이 지나는 경로 위에 과도한 압력을 주면 신경 자극 증상이 발생할 수 있으므로 허벅지 뒤 중앙 깊은 부위는 가볍게 접근한다. | 3. 시술 후 노르딕 햄스트링 운동 또는 스티프레그 데드리프트 같은 편심성(eccentric) 부하 운동을 연결하면 햄스트링 기능 회복에 효과적이다. | -- || 좋은 반응: 시술 후 무릎을 편 채 다리를 들어 올릴 때(능동 직다리 올리기) 허벅지 뒤 당김이 줄고 각도가 증가 | 앉았다 일어날 때 허벅지 뒤 당기는 느낌이 감소했다고 표현 | 허벅지 뒤 전반의 뻣뻣함이 줄었다고 표현 | 좌골결절 주변의 국소 압통이 시술 전보다 감소',
  '척추동맥 혈액순환 장애 위험, 골절 (대퇴골 피로골절, 좌골결절 견열골절 의심 포함), 불안정성, 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증 (허벅지 뒤 심한 부종·열감 동반 시), 허벅지 뒤 피부 상처·개방성 병변',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- IASTM-08: IT밴드(허벅지 바깥쪽 띠) IASTM (도구 이용 연부조직 가동술)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'IASTM',
  'IT밴드(허벅지 바깥쪽 띠) IASTM (도구 이용 연부조직 가동술)', 'IASTM for IT Band (Iliotibial Band)', 'IASTM-ITB',
  'hip'::body_region, '엉덩이 옆(대전자 부위) ~ 정강뼈 바깥쪽 결절(Gerdy''s tubercle)',
  NULL, NULL,
  NULL, NULL,
  '[{"step":1,"instruction":"허벅지 바깥쪽 전체에 오일을 얇게 바름. 엉덩이 옆(대전자 바로 아래)부터 무릎 바깥쪽(Gerdy''s tubercle 위쪽)까지 충분히 도포."},{"step":2,"instruction":"엉덩이 옆(대전자 부위) 바로 아래에서 시작해 넓은 편평 엣지를 45도로 대고 무릎 바깥쪽 방향으로 내려오는 스트로크 5~7회 실시. 이어서 무릎 위에서 엉덩이 방향으로 올라오는 스트로크 5~7회. 전체 IT밴드 경로 따라 저항이 강한 부위 탐색."},{"step":3,"instruction":"저항이 심한 부위를 찾으면 IT밴드 방향과 직각으로 짧은 가로 스트로크 8~10회 추가 (횡마찰). 위아래 방향과 가로 방향을 번갈아 반복하며 저항 부위 집중 시술."},{"step":4,"instruction":"환자에게 무릎을 천천히 굽혔다 펴게 하면서 동시에 위아래 스트로크를 실시. 무릎 각도 변화에 따라 IT밴드가 대전자(엉덩이 옆 뼈 돌출부) 위를 미끄러지므로 동적 자극이 가능."},{"step":5,"instruction":"시술 후 환자가 옆으로 누운 상태에서 위쪽 다리를 들어 올리는 동작을 해보게 하고 허벅지 바깥쪽 당김 변화 확인. 선다음 한쪽 다리로 서서 무릎 약간 굽힘 시 바깥쪽 불편감 변화도 확인."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: > 3줄 이내, 가장 중요한 포인트만: | 1. IT밴드(허벅지 바깥쪽 띠)는 근육이 아닌 두꺼운 결합조직 띠이므로, 강하게 오래 눌러도 즉각 "풀린다"는 느낌이 없는 것이 정상 — 환자에게 미리 설명하여 기대치를 현실적으로 조정한다. | 2. IASTM 시술 후 엉덩관절(고관절) 벌림 근력 운동(옆으로 누워 다리 들기 등)을 연결하면 IT밴드 과부하 원인 해결에 도움이 된다. | 3. 무릎 바깥쪽(Gerdy''s tubercle) 바로 위는 과도한 압력을 피하고, 무릎에서 최소 5cm 이상 위쪽부터 접근한다. | -- || 좋은 반응: 시술 후 허벅지 바깥쪽 뻣뻣함이 감소하고 다리가 좀 더 자유롭게 느껴진다고 표현 | 무릎 굽힘 각도가 증가하거나 스쿼트 동작이 좀 더 편해짐 | 달리기 후 무릎 바깥쪽 당기는 느낌이 줄었다고 표현 (다음 운동 후 확인) | 옆으로 누워 다리를 들어 올릴 때 허벅지 바깥쪽 저항감이 감소',
  '척추동맥 혈액순환 장애 위험, 골절 (대퇴골 피로골절 의심 포함), 불안정성, 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증 (무릎 바깥쪽 심한 부종·열감 동반 시), 허벅지 바깥쪽 피부 상처·개방성 병변',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- IASTM-09: 넙다리네갈래근 IASTM (도구 이용 연부조직 가동술)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'IASTM',
  '넙다리네갈래근 IASTM (도구 이용 연부조직 가동술)', 'IASTM for Quadriceps (Thigh Anterior)', 'IASTM-QF',
  'hip'::body_region, '넙다리네갈래근(quadriceps femoris) 근복 ~ 무릎뼈(슬개골) 위 힘줄',
  NULL, NULL,
  NULL, NULL,
  '[{"step":1,"instruction":"허벅지 앞쪽 전체에 오일을 얇게 바름. 무릎뼈(슬개골)에서 서혜부(사타구니 접힘 부위)까지 충분히 도포."},{"step":2,"instruction":"무릎뼈(슬개골) 바로 위 2~3cm에서 시작해, 넓은 볼록면 도구를 45도로 대고 서혜부 방향으로 올라가는 스트로크 5~7회 실시 (근육 결 방향). 이어서 서혜부에서 무릎뼈 방향으로 내려오는 스트로크 5~7회. 전체 조직 상태와 저항 부위를 탐색."},{"step":3,"instruction":"허벅지 앞쪽을 안쪽(안쪽넓은근 vastus medialis)·중간(넙다리곧은근 rectus femoris)·바깥쪽(가쪽넓은근 vastus lateralis) 세 구역으로 나누어 각각 위아래 스트로크 5~7회씩 반복. 바깥쪽 구역은 IT밴드(허벅지 바깥쪽 띠)와 경계에 주의하여 구분."},{"step":4,"instruction":"저항이 강하게 느껴지는 부위를 찾으면 도구를 그 위치에 멈추고, 환자에게 발목을 위아래로 구부렸다 펴게 하는 능동 운동을 5~10회 실시. 이를 통해 조직 이완 효과를 높임."},{"step":5,"instruction":"시술 후 환자가 무릎을 굽히는 동작을 해보게 하고 허벅지 앞쪽 당김·무릎 앞 통증 변화를 확인. 무릎뼈 위쪽 힘줄(무릎넙다리인대 부위) 압통 변화도 간단히 확인."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: > 3줄 이내, 가장 중요한 포인트만: | 1. 허벅지 안쪽(대퇴동맥이 지나는 서혜부~허벅지 안쪽 라인)에 강한 압력을 절대 주지 않는다. | 2. 시술 중 능동 무릎 굽힘·폄 운동을 결합하면 조직 이완과 신경근 재교육 효과가 높아진다. | 3. 넙다리네갈래근은 앞무릎 통증과 밀접한 관련이 있으나, 통증이 곧 손상 악화를 의미하지 않는다는 점을 환자에게 설명하여 시술 거부감을 줄인다. | -- || 좋은 반응: 시술 후 무릎 굽힘 각도가 증가하고 허벅지 앞쪽 당김이 줄어들었다고 표현 | 무릎뼈 위쪽 부위를 눌렀을 때 국소 압통이 시술 전보다 감소 | 계단을 오르내릴 때 또는 스쿼트 동작 시 앞무릎 불편감이 줄었다고 표현 | 허벅지 앞쪽 전반의 뻣뻣함이 감소하고 다리가 더 가볍게 느껴진다고 표현',
  '척추동맥 혈액순환 장애 위험, 골절 (대퇴골 피로골절 의심 포함), 불안정성, 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증 (무릎 앞쪽 부종·열감 동반 시), 허벅지 피부 상처·개방성 병변',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- ────────────────────────────────
-- MFR 기법 17개
-- ────────────────────────────────

-- MFR-01: 종아리 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '종아리 이완', 'Gastrocnemius / Soleus Myofascial Release', 'Calf MFR',
  'ankle_foot'::body_region, '장딴지근 (비복근 — gastrocnemius), 가자미근 (soleus) 전체',
  '등 대고 누운 자세. 치료할 다리를 치료사 무릎 위에 올려 종아리가 공중에 뜬 상태로 유지 (치료사가 다리 무게를 받쳐줌)', '발 쪽에 낮은 의자에 앉아 환자 다리를 무릎 위에 올려 받침',
  '양손으로 종아리를 감싸듯 잡음 (한 손은 안쪽, 다른 손은 바깥쪽)', '두 손을 서로 반대 방향으로 비틀어 (한 손은 시계 방향, 다른 손은 반시계 방향) 종아리 근막 탄성 끝을 찾음',
  '[{"step":1,"instruction":"(준비 단계) 환자를 등 대고 누운 자세로 눕히고, 치료사가 발 쪽에 앉아 환자 다리를 무릎 위에 올려 받친다. 종아리가 편안히 이완된 상태를 만든다."},{"step":2,"instruction":"(접촉 단계) 한 손을 종아리 안쪽, 다른 손을 바깥쪽에 놓아 종아리 전체를 감싸듯 잡는다."},{"step":3,"instruction":"(시행 단계) 두 손을 서로 반대 방향으로 천천히 비틀어 근막의 탄성 끝 (elastic barrier)을 찾는다. 저항이 느껴지는 방향으로 계속 비틀고 탄성 끝에서 멈춰 90초~2분 기다린다."},{"step":4,"instruction":"(반복 / 조정 단계) 이완 반응이 오면 비트는 방향을 반대로도 시도하여 양방향 이완을 유도한다. 무릎 아래~발목 위까지 약 3구역으로 나누어 이동하며 반복한다."},{"step":5,"instruction":"(평가 단계) 시술 후 발목을 위로 올려보게 하거나 (배측굴곡) 발꿈치를 들어보게 하여 종아리 유연성 변화를 확인한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: 1. 심부정맥혈전증 (DVT — 다리 혈관 속 혈전)이 의심되면 절대 시행하지 마세요. 종아리가 붓고 단단하며 강하게 누를 때 극심한 통증이 있으면 즉시 중단하고 의뢰하세요. | 2. 비트는 방향은 조직이 더 잘 따라오는 방향으로 합니다. 두 방향을 모두 시도하고 저항이 적은 방향으로 먼저 시행하세요. | 3. 발목 올리기 (배측굴곡) 제한이 있는 환자에게 특히 유용합니다. 시술 전후 발목 올리기 범위를 측정해 변화를 확인하세요. | -- || 좋은 반응: 환자가 "종아리가 시원하다" 또는 "뭔가 풀리는 것 같다"고 표현 | 치료사 손 아래 조직이 따뜻해지고 부드러워지는 감각 | 시술 후 발목 올리기 (배측굴곡) 범위 증가 | 종아리 뭉친 느낌이 줄었다고 보고',
  '골절 (의심 포함, 발목뼈·정강이뼈 포함), 불안정성 (발목 인대 파열 급성기), 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증 (발목 염좌 급성기, 종아리 근육 파열 후 4주 이내), 심부정맥혈전증 (DVT — 다리 혈관 속 혈전) 의심 시 절대 금지, 말초혈관질환 (발이 차고 색이 변하는 경우)',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-02: 발바닥 근막 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '발바닥 근막 이완', 'Plantar Fascia Myofascial Release', 'Plantar MFR',
  'ankle_foot'::body_region, '발바닥 근막 (족저근막) 전체 — 발꿈치뼈 (종골) 부착부에서 발가락 관절까지',
  '엎드린 자세 (발이 침대 끝에 걸치도록 하여 발목이 자유롭게 움직일 수 있게) 또는 등 대고 누운 자세 (치료사가 발을 들고 지지)', '발 끝에 서거나 앉음. 한 손으로 발등을 받쳐 발목을 안정화',
  '엄지 끝 또는 엄지 두덩 (엄지 아랫부분)을 발바닥 중앙에 댐. 다른 손은 발등을 받침', '발꿈치 쪽을 향해 살짝 밀거나 발가락 쪽을 향해 당기며 탄성 끝을 찾음',
  '[{"step":1,"instruction":"(준비 단계) 환자를 엎드린 자세로 눕히고 발이 침대 끝에 걸치도록 위치를 잡는다. 치료사는 발 끝에 서서 한 손으로 발등을 받쳐 발을 안정화한다."},{"step":2,"instruction":"(접촉 단계) 엄지 끝 또는 엄지 두덩을 발바닥 가운데 (발꿈치와 발가락 뿌리 사이 중간 지점)에 댄다. 압력은 매우 가볍게 시작한다."},{"step":3,"instruction":"(시행 단계) 엄지를 발꿈치 쪽을 향해 살짝 밀어 근막의 탄성 끝 (elastic barrier)을 찾는다. 탄성 끝에서 멈추고 90초 기다린다. 조직이 이완되면 조금 더 밀고 다시 기다린다."},{"step":4,"instruction":"(반복 / 조정 단계) 발꿈치 바로 앞 (발바닥 근막 부착부)→발바닥 가운데→발가락 뿌리 방향으로 3~4구역으로 나누어 이동하며 반복한다. 발꿈치 부착부는 통증에 민감할 수 있어 더 가볍게 시행한다."},{"step":5,"instruction":"(평가 단계) 시술 후 발가락을 위로 들어올려 (배측굴곡) 발바닥 근막이 늘어나는 범위 변화와 통증 변화를 확인한다. 서서 첫 발 딛기를 시험해보도록 한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: 1. 발바닥 근막 (족저근막)은 종아리 근육, 아킬레스건과 연속선상에 있습니다. 발바닥만 이완하면 효과가 제한적일 수 있어 종아리 이완 (calf-gastrocnemius-release.md)을 함께 시행하세요. | 2. 당뇨 환자처럼 발 감각이 저하된 경우 압력 피드백이 정확하지 않을 수 있어 특히 주의가 필요합니다. | 3. 아침 첫 발 딛기 통증이 있는 환자는 취침 전 시행하거나, 시술 후 즉시 걷게 하여 변화를 확인하세요. 첫 발 딛기 통증 감소 여부가 효과를 판단하는 좋은 지표입니다. | -- || 좋은 반응: 환자가 "발바닥이 시원하다" 또는 "당기는 게 줄었다"고 표현 | 치료사 엄지 아래 발바닥 조직이 미세하게 부드러워지는 감각 | 시술 후 발가락 들어올리기 범위 증가 | 아침 첫 발 딛기 통증이 줄었다고 보고',
  '골절 (발뼈 골절 — 스트레스 골절 포함), 불안정성, 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증 (발바닥 근막염 급성기 — 발꿈치 부분에 심한 통증), 발바닥 개방성 상처 또는 피부 감염, 말초혈관질환, 당뇨병성 말초신경병증 (발 감각 저하 환자 — 압력 피드백 부정확)',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-03: 아래팔(전완) 폄근(신전근) 근막 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '아래팔(전완) 폄근(신전근) 근막 이완', 'Forearm Extensor Myofascial Release', 'Forearm Extensor MFR',
  'wrist_hand'::body_region, '아래팔 바깥쪽 (손등 방향) — 팔꿈치 바깥쪽 ~ 손목',
  '앉은 자세 또는 등 대고 누운 자세. 팔을 테이블 위에 올리거나 치료사 무릎 위에 받침. 손등이 위를 향하도록 (손목 엎침, 회내)', '환자 옆에 앉거나 서서 팔을 마주보는 방향',
  '한 손 엄지와 나머지 손가락으로 아래팔 바깥쪽을 감싸듯 잡음 (팔꿈치 아래 5cm ~ 손목 위 5cm 사이)', '팔꿈치 방향(위쪽) 또는 손목 방향(아래쪽)으로 피부·근막을 밀어 탄성 끝 찾기',
  '[{"step":1,"instruction":"환자 팔을 테이블 또는 치료사 무릎 위에 편안히 받치고, 손등이 위를 향하도록 위치시킨다. 어깨와 팔꿈치에 힘을 빼도록 안내한다."},{"step":2,"instruction":"한 손 엄지와 나머지 손가락으로 아래팔 바깥쪽(폄근 부위)을 감싸듯 가볍게 잡는다. 안쪽(굽힘근)보다 더 강하게 접촉해도 괜찮으나 환자 반응을 확인한다."},{"step":3,"instruction":"피부를 팔꿈치 방향으로 살짝 밀어 근막의 탄성 끝을 찾는다. 탄성 끝에서 멈추고 60~90초 기다린다."},{"step":4,"instruction":"이완되면 손목 방향으로 3~4cm 이동하며 반복한다. 팔꿈치 아래부터 손목 위까지 전체를 커버한다 (3~4개 지점)."},{"step":5,"instruction":"시술 전후 손목 아래로 굽히기(장굴) 범위와 팔꿈치 바깥쪽 압통 정도를 비교한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['inflammation_acute'],
  'level_3'::evidence_level,
  '핵심 팁: 1. 외측 상과염(테니스 엘보) 환자에게는 팔꿈치 바로 아래 폄근 공통 힘줄 시작 부위를 중심으로 시행하되, 급성기에는 가볍게 접근할 것. | 2. 아래팔 바깥쪽은 안쪽보다 혈관·신경이 적어 상대적으로 안전하게 중간 압력을 사용할 수 있다. | 3. 굽힘근(안쪽) MFR과 세트로 시행하면 손목 전체 기능 회복이 더 빠르다. | -- || 좋은 반응: 팔꿈치 바깥쪽이 시원해지거나 가벼워지는 느낌 | 환자가 "아래팔 바깥쪽이 풀리는 것 같다"고 표현 | 시술 후 손목 아래로 굽히기(장굴) 범위 증가 | 외측 상과염 환자의 경우 악수 또는 물건 잡기 통증 감소',
  '척추동맥 위험, 골절, 불안정성, 종양, 신경학적 결손', '골다공증, 급성 염증 (급성 외측 상과염 초기 2주), 아래팔 바깥쪽 피부 상처, 최근 팔꿈치 수술',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-04: 아래팔(전완) 굽힘근(굴곡근) 근막 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '아래팔(전완) 굽힘근(굴곡근) 근막 이완', 'Forearm Flexor Myofascial Release', 'Forearm Flexor MFR',
  'wrist_hand'::body_region, '아래팔 안쪽 (손바닥 방향) — 팔꿈치 안쪽 ~ 손목',
  '앉은 자세 또는 등 대고 누운 자세. 팔을 테이블 위에 올리거나 치료사 무릎 위에 편안히 받침. 손바닥이 위를 향하도록', '환자 옆에 앉거나 서서 팔을 마주보는 방향',
  '한 손 엄지와 나머지 손가락으로 아래팔 안쪽을 감싸듯 잡음 (팔꿈치 아래 5cm ~ 손목 위 5cm 사이)', '팔꿈치 방향(위쪽) 또는 손목 방향(아래쪽)으로 피부·근막을 밀어 탄성 끝 찾기',
  '[{"step":1,"instruction":"환자 팔을 테이블 또는 치료사 무릎 위에 편안히 받치고, 손바닥이 위를 향하도록(손목 뒤침, 회외) 위치시킨다. 어깨와 팔꿈치에 힘을 빼도록 안내한다."},{"step":2,"instruction":"한 손 엄지와 나머지 손가락으로 아래팔 안쪽(굽힘근 부위)을 감싸듯 가볍게 잡는다. 강하게 쥐지 않고 손가락으로 조직을 \"감싸는\" 느낌."},{"step":3,"instruction":"피부를 팔꿈치 방향으로 살짝 밀어 근막의 탄성 끝을 찾는다. 탄성 끝에서 멈추고 60~90초 기다린다."},{"step":4,"instruction":"이완되면 손의 위치를 손목 쪽으로 3~4cm 이동하며 반복한다. 팔꿈치 아래부터 손목 위까지 전체를 커버한다 (3~4개 지점)."},{"step":5,"instruction":"시술 전후 손목 위로 젖히기(배굴) 범위와 아래팔 안쪽 압통 정도를 비교한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['inflammation_acute'],
  'level_4'::evidence_level,
  '핵심 팁: 1. 아래팔 안쪽(손바닥 방향)은 정중신경과 요골동맥이 지나므로 항상 가벼운 압력을 유지하고 신경학적 증상을 즉시 확인해야 한다. | 2. 타이핑·마우스 과다 사용 환자에게는 굽힘근(안쪽)과 폄근(바깥쪽) MFR을 함께 시행하면 손목 전반적인 기능이 빠르게 개선된다. | 3. 손가락 끝이 아닌 손바닥·손 두덩으로 접촉면을 넓게 잡으면 환자 불편감 없이 충분한 압력을 유지할 수 있다. | -- || 좋은 반응: 손목이 시원해지거나 손가락이 가벼워지는 느낌 | 환자가 "아래팔 안쪽이 풀리는 것 같다"고 표현 | 시술 후 손목 위로 젖히기(배굴) 범위 증가 | 치료사 손 아래 조직이 부드러워지는 느낌',
  '척추동맥 위험, 골절, 불안정성, 종양, 신경학적 결손', '골다공증, 급성 염증 (급성 건염, 활액낭염), 아래팔 안쪽 피부 상처, 혈관 이식 수술 후',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-05: 엉덩이 근막 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '엉덩이 근막 이완', 'Gluteal Myofascial Release — Sustained Pressure', 'Gluteal MFR',
  'hip'::body_region, '큰볼기근 (대둔근), 중간볼기근 (중둔근) 전체',
  '엎드린 자세. 발끝이 안쪽으로 향하도록 (내회전 자세) 하면 볼기근이 더 이완된 상태가 됨', '환자 옆에 서서 봄. 팔꿈치를 펴 체중을 활용할 수 있는 위치',
  '손 두덩 (엄지 아랫부분의 두툼한 부분) 또는 손바닥 전체를 엉덩이 근육 가운데에 댐', '수직으로 아래쪽 (조직 속으로 가라앉히는 방향). 밀지 않고 기다림',
  '[{"step":1,"instruction":"(준비 단계 — 자세 잡기) 환자를 엎드린 자세로 눕히고 발끝이 안쪽을 향하도록 유도한다. 이렇게 하면 볼기근이 약간 이완되어 접근이 쉬워진다."},{"step":2,"instruction":"(접촉 단계 — 손 위치) 손 두덩 또는 손바닥 전체를 엉덩이 근육의 가운데 부위에 부드럽게 올려놓는다. 치료사 팔꿈치는 펴서 체중을 활용할 준비를 한다."},{"step":3,"instruction":"(시행 단계 — 힘 전달) 팔에 힘을 주어 밀지 않고, 팔꿈치를 점점 펴면서 치료사 체중이 손을 통해 조직 속으로 서서히 가라앉히도록 한다. 조직이 \"수락\"하는 느낌 (조직이 부드러워지며 손이 조금씩 더 들어가는 느낌)이 올 때까지 기다린다."},{"step":4,"instruction":"(반복 / 조정 단계) 90초~2분 유지 후 이완 반응을 확인하고, 엉덩이 위쪽(엉덩이뼈 근처)→가운데→아래쪽(다리 뒤쪽 경계) 순으로 이동하며 반복한다. 총 3구역을 나누어 시행한다."},{"step":5,"instruction":"(평가 단계 — 반응 확인) 시술 후 환자에게 다리 들어올리기 (엎드린 상태에서 무릎을 펴고 다리 뒤로 들기) 또는 일어서서 엉덩이 움직임을 확인한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: > 3줄 이내, 가장 중요한 포인트만: | 1. 엉덩이는 근육이 두꺼워 충분한 체중 활용이 필요합니다. 하지만 팔 근육으로 밀면 조직이 오히려 저항합니다. 팔꿈치를 펴며 몸무게를 서서히 실으세요. | 2. 좌골신경 (엉덩이 가운데~아래쪽을 지나는 굵은 신경)이 지나는 경로를 사전에 파악하고, 해당 부위 직접 압박은 피하세요. | 3. 다리 뒤쪽으로 퍼지는 느낌을 환자가 호소하면 즉시 손 위치를 조정하거나 압력을 줄이세요. | -- || 좋은 반응: 환자가 "묵직한 느낌이 줄어들고 편해진다"고 표현 | 치료사 손 아래 조직이 따뜻해지고 부드러워짐 | 시술 후 엉덩이 부위 누르는 통증 (압통)이 감소 | 앉거나 일어설 때 엉덩이 불편감이 줄었다고 보고',
  '척추동맥 혈액순환 장애 위험 (경추 테크닉 시 필수 확인), 골절 (의심 포함, 고관절 골절 포함), 불안정성 (고관절 탈구 이력, 인공관절 등), 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증 (감염, 점액낭염 급성기), 좌골신경통 급성 악화기, 엉덩이 주사 후 24시간 이내',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-06: 골반 바깥쪽 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '골반 바깥쪽 이완', 'Proximal Iliotibial Band / Tensor Fasciae Latae Myofascial Release', 'Proximal ITB / TFL MFR',
  'hip'::body_region, '넙다리근막긴장근 (TFL — 골반 앞 바깥쪽 근육) 및 IT밴드 (허벅지 바깥쪽 띠) 근위부',
  '옆으로 누운 자세. 치료할 다리(위쪽 다리)가 위로 오도록 눕힘. 아래쪽 무릎을 살짝 구부려 안정성 확보', '환자 등 쪽에 서서 엉덩이 옆면이 잘 보이는 위치',
  '한 손은 엉덩이뼈 (장골능 — 골반 위쪽 능선) 바로 아래 바깥쪽, 다른 손은 허벅지 바깥쪽 상단부 (넙다리근막긴장근이 IT밴드로 이어지는 부위)', '두 손이 서로 반대 방향으로 (한 손은 머리 쪽, 다른 손은 발 쪽) 피부·근막을 가볍게 당겨 늘림',
  '[{"step":1,"instruction":"(준비 단계 — 자세 잡기) 환자를 옆으로 누운 자세로 안정되게 눕힌다. 위쪽 다리는 아래쪽 다리 위에 자연스럽게 올려놓거나 치료대 위에 두 다리를 살짝 벌린 상태로 유지한다."},{"step":2,"instruction":"(접촉 단계 — 손 위치) 한 손을 엉덩이뼈 (장골능) 바로 아래 골반 바깥쪽 면에, 다른 손을 허벅지 바깥쪽 상단부 (넙다리근막긴장근 — TFL — 위치)에 놓는다."},{"step":3,"instruction":"(시행 단계 — 힘 전달) 두 손을 서로 반대 방향으로 (머리 쪽과 발 쪽) 피부와 근막을 가볍게 당겨 탄성 끝 (elastic barrier)을 찾는다. 탄성 끝에서 멈추고 2~3분 기다린다."},{"step":4,"instruction":"(반복 / 조정 단계) 이완 반응 (따뜻해짐, 조직이 부드러워짐)이 오면 손을 조금씩 아래로 이동하여 IT밴드 중간부로 이동하며 반복한다."},{"step":5,"instruction":"(평가 단계 — 반응 확인) 시술 후 옆으로 누운 상태에서 위쪽 다리를 들어 올려보게 하거나 서서 골반 옆 불편감 변화를 확인한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_3'::evidence_level,
  '핵심 팁: > 3줄 이내, 가장 중요한 포인트만: | 1. 넙다리근막긴장근 (TFL — 골반 앞 바깥쪽의 작은 근육)은 IT밴드 (허벅지 바깥쪽 띠)와 직접 연결되어 있어, 이 부위 이완이 IT밴드 전체 긴장도에 영향을 줍니다. | 2. 엉덩이뼈 (대전자 — 골반 바깥쪽에 툭 튀어나온 뼈) 위를 직접 압박하지 않도록 주의하세요. 점액낭 (뼈와 근막 사이 충격 흡수 조직)이 있어 자극하기 쉽습니다. | 3. 달리기 선수나 하이킹을 즐기는 환자처럼 반복적인 골반 움직임이 많은 경우에 특히 유용합니다. | -- || 좋은 반응: 환자가 "골반 옆이 시원하다" 또는 "뭔가 늘어나는 것 같다"고 표현 | 치료사 손 아래 단단하던 조직이 부드러워지는 감각 | 시술 후 위쪽 다리 들어올리기가 더 수월해짐 | 달리기 또는 보행 시 골반 옆 당기는 느낌 감소',
  '척추동맥 혈액순환 장애 위험, 골절 (의심 포함), 불안정성 (고관절 탈구 이력), 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증 (점액낭염 — 엉덩이뼈 부위 물집처럼 부어오른 경우 — 급성기), 엉덩이뼈 (대전자 — 골반 바깥쪽 툭 튀어나온 뼈) 주변 점액낭염 급성기',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-07: 허리 근막 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '허리 근막 이완', 'Lumbar Myofascial Release — Cross-Hand Technique', 'Lumbar MFR',
  'lumbar'::body_region, 'L1–L5 전체 요부 근막',
  '엎드린 자세 (배 아래 얇은 베개로 허리 앞 굽음 — 요부 전만 — 유지)', '환자 옆에 서서 머리 방향을 보고 섬. 팔꿈치는 펴거나 약간 구부린 상태로 체중 활용 준비',
  '한 손은 허리 아래쪽 (엉덩이뼈 — 장골능 — 바로 위), 다른 손은 등 아래쪽 (허리 윗부분, 대략 흉요추 이행부 — 등과 허리가 만나는 지점)', '두 손이 서로 반대 방향으로 (한 손은 발 쪽, 다른 손은 머리 쪽) 피부·근막을 가볍게 당겨 늘림',
  '[{"step":1,"instruction":"(준비 단계 — 자세 잡기) 환자가 엎드린 자세로 편안히 눕고, 배 아래 얇은 베개를 받쳐 허리 전만을 유지시킨다. 치료사는 환자 옆에 서서 안정된 자세를 취한다."},{"step":2,"instruction":"(접촉 단계 — 손 위치) 한 손 손바닥 전체를 허리 아래쪽 (엉덩이뼈 위)에 놓고, 다른 손을 허리 위쪽 (등·허리 경계)에 교차 방향으로 놓는다. 손은 피부에 부드럽게 밀착시킨다."},{"step":3,"instruction":"(시행 단계 — 힘 전달) 두 손을 서로 멀어지는 방향으로 피부와 근막을 살짝 당겨 조직의 탄성 끝 (elastic barrier)을 찾는다. 당기는 힘은 매우 가벼워야 하며 피부가 팽팽해지는 느낌에서 멈춘다. 그 지점에서 힘을 유지하며 조직이 이완되기를 기다린다."},{"step":4,"instruction":"(반복 / 조정 단계) 2~4분을 기다리며 조직이 이완되는 느낌 (따뜻해짐, 손이 조금 더 들어가는 느낌)이 오면 추가로 조금 더 당겨 새로운 탄성 끝을 찾고 다시 기다린다. 이완이 충분히 일어난 것으로 판단되면 부드럽게 손을 뗀다."},{"step":5,"instruction":"(평가 단계 — 반응 확인) 시술 후 환자에게 허리 움직임(앞으로 굽히기, 옆으로 굽히기 등)을 해보도록 하여 가동 범위 변화와 통증 변화를 확인한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: > 3줄 이내, 가장 중요한 포인트만: | 1. 허리 근막은 인체에서 가장 두꺼운 근막 중 하나입니다. 충분한 시간(최소 2분)이 없으면 이완 반응이 오지 않습니다. | 2. 환자가 "아프다"고 느끼는 압력은 너무 강한 것입니다. 이완을 유도하려면 환자의 몸이 긴장하지 않는 수준의 압력을 유지해야 합니다. | 3. 시술 후 허리 움직임을 즉시 재평가하여 변화를 환자와 함께 확인하면 치료 동맹 형성에 도움이 됩니다. | -- || 좋은 반응: 환자가 "시원하다", "뭔가 풀리는 것 같다"고 표현한다 | 치료사 손 아래 조직이 따뜻해지고 부드러워지는 느낌이 온다 | 시술 후 허리 앞으로 굽히기(전굴) 또는 옆으로 굽히기 범위가 늘어난다 | 앉았다 일어날 때 뻣뻣한 느낌이 줄어들었다고 보고한다',
  '척추동맥 혈액순환 장애 위험 (경추 테크닉 시 필수 확인), 골절 (의심 포함), 불안정성 (인대 파열, 척추 불안정 포함), 종양 / 악성 질환, 신경학적 결손 (근력 저하, 반사 소실, 방광·장 기능 이상)', '골다공증, 급성 염증 (감염, 류마티스 급성기), 개방성 상처 또는 피부 감염 부위',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-08: 허리-등 연결 근막 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '허리-등 연결 근막 이완', 'Thoracolumbar Fascia Myofascial Release', 'TLF MFR',
  'thoracic'::body_region, 'T12–L2 흉요추 이행부 (등 척추와 허리 척추가 만나는 지점)',
  '엎드린 자세. 이마 아래 얇은 베개를 받쳐 목을 편안하게 유지', '환자 옆에 서서 머리 방향을 바라봄. 양손이 대각선 방향으로 놓일 수 있는 위치',
  '한 손 손바닥은 등 아래쪽 (흉요추 이행부 — 등과 허리가 만나는 경계, 대략 마지막 갈비뼈 아래), 다른 손 손바닥은 허리 아래쪽 (엉덩이뼈 위)에 대각선으로 배치', '양 손이 대각선으로 서로 반대 방향을 향해 (한 손은 머리 쪽, 다른 손은 발 쪽으로) 피부·근막을 부드럽게 늘림',
  '[{"step":1,"instruction":"(준비 단계 — 자세 잡기) 환자를 엎드린 자세로 안정되게 눕히고 이마 아래 베개를 받친다. 치료사는 환자 옆에 서서 양손을 흉요추 이행부에 대각선 방향으로 배치할 수 있는 위치를 잡는다."},{"step":2,"instruction":"(접촉 단계 — 손 위치) 한 손을 마지막 갈비뼈 (12번 갈비뼈) 바로 아래 척추 옆에, 다른 손을 엉덩이뼈 (장골능) 바로 위에 대각선으로 놓는다. 두 손이 서로 교차되는 방향을 향하게 배치한다."},{"step":3,"instruction":"(시행 단계 — 힘 전달) 두 손을 서로 멀어지는 방향으로 피부와 근막을 가볍게 당겨 탄성 끝 (elastic barrier)을 찾는다. 탄성 끝에 도달하면 그 지점에서 멈추고 조직이 이완되기를 기다린다."},{"step":4,"instruction":"(반복 / 조정 단계) 2~3분 기다리며 조직이 이완되는 신호 (따뜻해짐, 조직이 부드러워짐)가 오면 양손을 조금 더 반대 방향으로 이동해 새로운 탄성 끝을 찾고 다시 기다린다."},{"step":5,"instruction":"(평가 단계 — 반응 확인) 시술 후 환자에게 몸통 돌림 (회전)과 옆으로 굽히기를 시켜보고 가동 범위 및 불편감 변화를 확인한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_3'::evidence_level,
  '핵심 팁: > 3줄 이내, 가장 중요한 포인트만: | 1. 흉요추 근막 (TLF — 등과 허리를 연결하는 넓은 근막)은 다열근, 광배근, 엉덩이 근육 등 여러 근육과 연결되어 있어 이 부위 이완이 허리와 엉덩이 모두에 영향을 줄 수 있습니다. | 2. 갈비뼈에 직접 닿지 않도록 손 위치를 항상 갈비뼈 아래쪽 연조직(살) 위에 배치하세요. | 3. 몸통 돌림이 제한된 만성 허리 통증 환자에게 특히 유용합니다. | -- || 좋은 반응: 환자가 "등과 허리 사이가 풀리는 것 같다"고 표현 | 치료사 손 아래 조직이 따뜻해지고 부드러워지는 감각 | 시술 후 몸통 돌림 범위가 늘어남 | 허리 옆 굽히기 시 뻣뻣함이 감소했다고 보고',
  '척추동맥 혈액순환 장애 위험 (경추 테크닉 시 필수 확인), 골절 (의심 포함), 불안정성 (인대 파열, 척추 불안정 포함), 종양 / 악성 질환, 신경학적 결손 (근력 저하, 반사 소실, 방광·장 기능 이상)', '골다공증, 급성 염증 (감염, 류마티스 급성기), 최근 척추 수술 후 6주 이내',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-09: 목 뒤쪽 근막 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '목 뒤쪽 근막 이완', 'Cervical Posterior Chain Myofascial Release', 'Neck Posterior MFR',
  'cervical'::body_region, 'C1-C7 (목 뒤쪽 전체, 주로 C2-C6)',
  '등 대고 누운 자세 (앙와위), 머리 아래 베개 없이 또는 얇은 수건 사용', '환자 머리 쪽 의자에 앉거나 서서, 팔꿈치를 몸통에 붙여 안정적으로 지지',
  '양손 2~4번째 손가락 끝을 모아 목 뒤(뒤통수 바로 아래~어깨 위쪽 사이)에 댐', '수직 압박 후 머리 쪽으로 가벼운 견인(당기기) 추가',
  '[{"step":1,"instruction":"환자를 등 대고 누운 자세로 눕히고, 베개를 제거하거나 얇은 수건으로 대체한다. 환자가 어깨와 목에 긴장을 풀도록 심호흡 1~2회 유도한다."},{"step":2,"instruction":"양손 손가락 끝을 목 뒤(목 척추 양옆 근육)에 부드럽게 댄다. 손가락을 펴지 않고 살짝 구부린 상태로 조직을 \"받치듯\" 위치시킨다."},{"step":3,"instruction":"손가락이 조직 속으로 서서히 가라앉도록 기다린다. 밀거나 누르는 것이 아니라 환자 머리의 무게를 활용해 자연스럽게 압력이 생기도록 한다. 조직이 \"수락\"하는 느낌이 오면 머리를 살짝 머리 쪽으로 당기듯 가벼운 견인(2~3cm)을 추가한다."},{"step":4,"instruction":"그 상태로 90초~2분 유지한다. 이완이 느껴지면 손가락 위치를 목 위쪽(뒤통수 가까이)으로 이동하거나 아래쪽(어깨 쪽)으로 이동하며 반복한다."},{"step":5,"instruction":"시술 전후 목 돌림(회전) 범위와 통증 강도를 비교한다. 환자에게 어깨나 팔에 저림이 생겼는지 확인한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['vbi_risk'],
  'level_4'::evidence_level,
  '핵심 팁: 1. 손가락으로 "누른다"는 생각보다 "받친다"는 느낌으로 접근하면 힘 조절이 훨씬 쉬워진다. | 2. 환자 머리의 무게(약 4~5kg)를 활용하면 팔 근육을 쓰지 않아도 충분한 압력이 자연스럽게 생긴다. | 3. 경추는 혈관·신경이 밀집된 부위이므로 치료 전 VBI(척추동맥 기능 부전) 스크리닝을 반드시 수행할 것. | -- || 좋은 반응: 환자가 "시원하다", "뭔가 풀리는 것 같다"고 표현 | 치료사 손 아래 조직이 부드러워지고 따뜻해지는 느낌 | 시술 후 목 돌림 범위가 약간 늘어남 (5~10도 이상) | 환자 호흡이 느려지고 전신이 이완되는 모습',
  '척추동맥 혈액순환 장애 위험 (경추 테크닉 시 필수 확인), 골절 (의심 포함), 불안정성, 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증, 급성 경추 편타성 손상(whiplash) 초기 2주',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-10: 머리-목 연결 부위 이완 (후두하근 근막 이완)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '머리-목 연결 부위 이완 (후두하근 근막 이완)', 'Suboccipital Myofascial Release', 'Suboccipital MFR',
  'cervical'::body_region, 'C0-C1-C2 (두개경추 연결부, 후두하 삼각)',
  '등 대고 누운 자세 (앙와위), 베개 없이 또는 얇은 수건. 어깨와 턱에 힘을 완전히 뺀 상태', '환자 머리 쪽 의자에 앉아 팔꿈치를 테이블 또는 허벅지에 안정적으로 지지',
  '양손 2~3번째 손가락 끝을 뒤통수뼈(후두골) 바로 아래, 목 척추 1번(C1) 가로돌기 근처에 댐', '수직 압박 + 머리 쪽으로 가벼운 견인(당기기)',
  '[{"step":1,"instruction":"환자를 등 대고 눕히고 베개를 제거한다. 환자에게 눈을 감고 턱과 어깨를 완전히 이완하도록 안내한다."},{"step":2,"instruction":"양손 손가락 끝을 뒤통수뼈 아래 오목한 부분(후두하 삼각)에 부드럽게 위치시킨다. 뼈에 닿는 게 아니라 뼈 바로 아래 근육에 댄다."},{"step":3,"instruction":"손가락이 조직 속으로 서서히 가라앉도록 기다린다. 조직이 \"수락\"하면 머리를 머리 쪽으로 1~2cm 가볍게 당기는 견인을 추가한다. 밀거나 강하게 누르지 않는다."},{"step":4,"instruction":"90초~2분 유지한다. 이완 후 손가락을 뒤통수뼈 바로 아래에서 살짝 옆(귀 방향)으로 이동해 후두하 삼각 전체를 커버한다."},{"step":5,"instruction":"시술 전후 두통 강도(NRS)와 목 고개 끄덕임 범위를 비교한다. 어지럼증 유무를 반드시 확인한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['vbi_risk', 'instability', 'inflammation_acute'],
  'level_4'::evidence_level,
  '핵심 팁: 1. 후두하 삼각은 경추 고유감각(proprioception) 수용기가 밀집된 부위로, 느리고 부드러운 접근이 빠른 기법보다 효과적이다. | 2. 두통 환자에게는 시술 전에 어지럼증 스크리닝(VBI 테스트)을 반드시 먼저 수행할 것. | 3. 환자 머리의 무게를 활용하면 팔 근육을 쓰지 않아도 충분한 압력이 생긴다 — 치료사 피로 없이 지속 가능. | -- || 좋은 반응: 두통이 치료 중 줄어들거나 사라지는 느낌 | 눈 뒤쪽 압박감이 감소 | 환자가 "뒤통수가 시원하다", "머리가 가벼워진다"고 표현 | 목 고개 끄덕임 범위가 약간 증가',
  '척추동맥 혈액순환 장애 위험 (필수 스크리닝), 골절, 불안정성 (C1-C2 불안정 포함, 다운증후군·류마티스 관절염 주의), 종양, 신경학적 결손', '골다공증, 급성 염증, 급성 편타성 손상 초기 2주, 고혈압 조절 안 되는 환자',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-11: 어깨 앞쪽 근막 이완 (가슴·어깨 연결부)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '어깨 앞쪽 근막 이완 (가슴·어깨 연결부)', 'Anterior Shoulder Myofascial Release', 'Anterior Shoulder MFR',
  'shoulder'::body_region, '어깨 앞쪽 관절 부위 + 큰가슴근(대흉근) 외측',
  '등 대고 누운 자세 (앙와위), 팔을 옆에 편안히 놓음. 팔꿈치를 살짝 구부려 어깨 긴장 감소', '치료할 어깨 쪽에 서서 환자 쪽을 봄. 양손을 사용할 준비',
  '한 손 손바닥은 가슴 바깥쪽 큰가슴근(대흉근) 위, 다른 손 손바닥은 어깨 앞쪽 관절(작은가슴근, 오구돌기 주변)', '두 손이 서로 멀어지는 방향으로 피부·근막을 당김',
  '[{"step":1,"instruction":"환자를 등 대고 눕힌다. 치료할 팔을 옆에 놓고 팔꿈치를 살짝 구부려 어깨 앞쪽 근육이 이완된 상태를 만든다."},{"step":2,"instruction":"한 손을 가슴 바깥쪽 큰가슴근 위에, 다른 손을 어깨 앞쪽 관절 부위에 부드럽게 놓는다. 쇄골(빗장뼈) 위나 목 앞쪽은 피한다."},{"step":3,"instruction":"두 손을 서로 멀어지는 방향으로 살짝 당겨 근막의 탄성 끝을 찾는다. 탄성 끝에서 멈추고 2분 기다린다."},{"step":4,"instruction":"이완되면 조금 더 당기고 다시 기다린다. 어깨 앞쪽 전체를 커버하기 위해 한 손 위치를 어깨 위쪽으로 이동하며 반복한다."},{"step":5,"instruction":"시술 전후 팔 수평 벌리기(외전) 범위와 어깨 앞쪽 통증 강도를 비교한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['inflammation_acute'],
  'level_3'::evidence_level,
  '핵심 팁: 1. 어깨 앞쪽 이완은 가슴 근육(큰가슴근)과 어깨 앞쪽 관절낭을 함께 커버하는 것이 효과적이다. | 2. 쇄골 위나 겨드랑이 앞쪽은 혈관·신경이 집중된 부위 — 그 부위는 피하고 가슴 근육 중간 부위에만 집중할 것. | 3. 팔 들기 제한이 있는 오십견(동결견) 환자에게는 어깨 앞쪽과 후쪽 MFR을 세트로 시행하면 효과적이다. | -- || 좋은 반응: 가슴 앞쪽이 시원하게 늘어나는 느낌 | 환자가 "어깨 앞쪽이 가벼워진다"고 표현 | 팔 들기(굴곡) 범위가 시술 후 증가 | 치료사 손 아래 가슴·어깨 근막이 부드러워지는 느낌',
  '척추동맥 위험, 골절, 불안정성, 종양, 신경학적 결손', '골다공증, 급성 염증, 어깨 수술(회전근개 수술 등) 후 초기 6주, 어깨 탈구 급성기',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-12: 어깨 뒤쪽 근막 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '어깨 뒤쪽 근막 이완', 'Posterior Shoulder Myofascial Release', 'Posterior Shoulder MFR',
  'shoulder'::body_region, '어깨 뒤쪽 관절낭 + 가시아래근(극하근) + 작은원근(소원근)',
  '등 대고 누운 자세 (앙와위), 치료할 팔을 옆에 편안히 놓음. 또는 옆으로 누운 자세 (측와위)로 치료할 어깨를 위로 올려 접근성 향상 가능', '치료할 어깨 쪽에 서서 환자 쪽을 봄',
  '양손 손바닥 또는 한 손으로 어깨 뒤쪽 (날개뼈 아래 부위 ~ 어깨 뒤쪽 관절)을 감싸듯 접촉', '어깨 뒤쪽 근막을 바깥쪽(팔 방향) 또는 위쪽으로 살짝 당겨 탄성 끝 찾기',
  '[{"step":1,"instruction":"환자를 등 대고 눕히거나 옆으로 눕힌다. 치료할 팔의 긴장을 완전히 빼도록 안내한다."},{"step":2,"instruction":"한 손 또는 양손을 어깨 뒤쪽(가시아래오목, 극하와)과 어깨 뒤쪽 관절 부위에 부드럽게 놓는다."},{"step":3,"instruction":"피부를 팔 방향(바깥쪽)으로 살짝 당겨 근막의 탄성 끝을 찾는다. 탄성 끝에서 멈추고 90초~2분 기다린다."},{"step":4,"instruction":"이완이 느껴지면 조금 더 당기고 다시 기다린다. 어깨 뒤쪽 전체를 위쪽에서 아래쪽으로 이동하며 커버한다."},{"step":5,"instruction":"시술 전후 팔 안쪽 돌리기(내회전) 범위와 어깨 뒤쪽 통증 강도를 비교한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['inflammation_acute'],
  'level_3'::evidence_level,
  '핵심 팁: 1. 어깨 뒤쪽 이완은 앞쪽 이완과 세트로 시행할 때 가장 효과적 — 한쪽만 하면 효과가 제한적일 수 있다. | 2. 가시아래근(극하근)과 작은원근(소원근)이 팔 바깥 돌리기(외회전)를 담당하므로, 이 부위 이완 후 어깨 돌림 범위가 동시에 개선되는 경우가 많다. | 3. 옆으로 누운 자세에서 치료하면 치료사가 접근하기 쉽고 환자도 편안함을 느끼는 경우가 많다. | -- || 좋은 반응: 어깨 뒤쪽이 시원하게 풀리는 느낌 | 팔 안쪽 돌리기(내회전) 범위 증가 (예: 팔 뒤로 돌리기가 더 쉬워짐) | 환자가 "어깨 뒤쪽이 부드러워진다"고 표현 | 치료사 손 아래 조직이 따뜻해지고 부드러워지는 느낌',
  '척추동맥 위험, 골절, 불안정성, 종양, 신경학적 결손', '골다공증, 급성 염증, 어깨 수술 후 초기 6주, 회전근개 완전 파열 급성기',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-13: 허벅지 뒤쪽 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '허벅지 뒤쪽 이완', 'Hamstring Myofascial Release', 'Hamstring MFR',
  'hip'::body_region, '반힘줄근 (반건양근), 반막근 (반막양근), 넙다리두갈래근 (대퇴이두근)',
  '엎드린 자세. 발목 아래 작은 베개를 받쳐 무릎이 약간 구부러지게 하면 허벅지 뒤쪽 근육이 이완됨', '환자 다리 옆에 서서 봄',
  '양손을 허벅지 뒤쪽 근육 위에 나란히 놓음. 한 손은 엉덩이 바로 아래, 다른 손은 허벅지 중간', '피부·근막을 엉덩이 쪽으로 살짝 당기는 방향',
  '[{"step":1,"instruction":"(준비 단계) 환자를 엎드린 자세로 눕히고 발목 아래 작은 베개를 받쳐 허벅지 뒤쪽 근육을 이완시킨다."},{"step":2,"instruction":"(접촉 단계) 양손을 허벅지 뒤쪽 근육 위에 부드럽게 올려놓는다. 무릎 뒤 오금 (무릎 접히는 부분)은 피하고 최소 5cm 이상 위에서 시작한다."},{"step":3,"instruction":"(시행 단계) 피부를 엉덩이 쪽으로 살짝 당겨 탄성 끝 (elastic barrier)을 찾는다. 그 지점에서 멈추고 90초~2분 기다린다."},{"step":4,"instruction":"(반복 / 조정 단계) 이완 반응이 오면 엉덩이 아래에서 무릎 위쪽 오금까지 약 3구역으로 나누어 순서대로 이동하며 반복한다. 무릎 오금에 가까울수록 압력을 더 가볍게 유지한다."},{"step":5,"instruction":"(평가 단계) 시술 후 엎드린 상태에서 무릎을 구부려보게 하거나 (발꿈치를 엉덩이 쪽으로 당기기) 등 대고 누워 다리를 들어올려 허벅지 뒤쪽 유연성 변화를 확인한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: 1. 무릎 뒤 오금 (무릎 접히는 부분) 은 혈관과 신경이 지나는 부위입니다. 강한 압박은 절대 금지이며 오금 위 5cm 이상에서만 시행하세요. | 2. 허벅지 뒤쪽 당김이 신경성 (좌골신경통)인지 근막성인지 구분이 중요합니다. 다리를 들어올릴 때 발끝을 당기면 더 심해지는 경우 신경 증상 가능성, 이때는 신경 가동성 기법으로 전환을 고려하세요. | 3. 발목 아래 베개로 무릎을 살짝 구부려 시작하면 허벅지 뒤쪽 긴장이 줄어 접근이 훨씬 쉬워집니다. | -- || 좋은 반응: 환자가 "허벅지 뒤가 시원하다" 또는 "뭔가 풀리는 것 같다"고 표현 | 치료사 손 아래 조직이 따뜻해지고 부드러워지는 감각 | 시술 후 다리 들어올리기 (직다리 올리기) 범위 증가 | 앉을 때 허벅지 뒤 눌리는 불편감 감소',
  '골절 (의심 포함), 불안정성, 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증, 허벅지 뒤쪽 근육 파열 (2도 이상) 후 6주 이내, 좌골신경통 급성 악화기',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-14: IT밴드 이완 (허벅지 바깥쪽 띠 이완)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  'IT밴드 이완 (허벅지 바깥쪽 띠 이완)', 'Iliotibial Band Myofascial Release', 'ITB MFR',
  'hip'::body_region, '장경인대 (IT밴드) 전체 — 골반 바깥쪽에서 정강이뼈 바깥쪽 (거디결절)까지',
  '옆으로 누운 자세. 치료할 다리(위쪽 다리)가 위로 오도록 눕힘. 아래쪽 무릎을 살짝 구부려 안정성 확보. 위쪽 다리는 자연스럽게 펴거나 앞쪽으로 살짝 이동', '환자 등 쪽에 서거나 다리 쪽에 서서 허벅지 바깥쪽이 잘 보이는 위치',
  '한 손은 엉덩이 옆 (엉덩이뼈 — 대전자 — 바로 위 또는 앞), 다른 손은 허벅지 바깥쪽 중간 부위', '두 손이 서로 반대 방향으로 (한 손은 머리 쪽, 다른 손은 발 쪽) 피부와 IT밴드를 가볍게 당겨 늘림',
  '[{"step":1,"instruction":"(준비 단계) 환자를 옆으로 누운 자세로 안정되게 눕힌다. 위쪽 다리가 이완된 상태를 유지하도록 자세를 잡는다."},{"step":2,"instruction":"(접촉 단계) 한 손을 엉덩이뼈 (대전자) 바로 위 앞쪽, 다른 손을 허벅지 바깥쪽 중간 부위에 놓는다. 두 손이 서로 반대 방향을 향하도록 배치한다."},{"step":3,"instruction":"(시행 단계) 두 손을 서로 멀어지는 방향으로 피부와 IT밴드 근막을 가볍게 당겨 탄성 끝 (elastic barrier)을 찾는다. IT밴드는 매우 두꺼워 탄성 끝이 바로 느껴지지 않을 수 있다. 그 지점에서 3~5분 기다린다."},{"step":4,"instruction":"(반복 / 조정 단계) 이완 반응이 오면 (매우 미세하게 느껴질 수 있음) 손의 위치를 조금씩 아래로 이동하여 무릎 바깥쪽 방향으로 진행한다. 각 구역마다 최소 3분 기다린다."},{"step":5,"instruction":"(평가 단계) 시술 후 서서 허벅지 바깥쪽 당김 변화를 확인하거나 무릎 굽히기 범위 변화를 측정한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_3'::evidence_level,
  '핵심 팁: 1. IT밴드 (장경인대 — 허벅지 바깥쪽 띠)는 구조적으로 매우 두껍고 단단합니다. 실제로 충분히 이완되려면 단일 세션에 최소 5분 이상이 필요하며, 단기간에 강하게 하면 오히려 반응이 없습니다. | 2. IT밴드 자체보다 그것과 연결된 넙다리근막긴장근 (TFL) 이완을 함께 시행하면 효과가 더 좋습니다. 골반 바깥쪽 이완 파일 (hip-iliotibial-proximal.md) 병행을 권장합니다. | 3. 달리기·자전거 선수처럼 반복적인 무릎 굽힘-폄이 많은 환자에게 특히 적합합니다. | -- || 좋은 반응: 환자가 "허벅지 바깥쪽이 조금 느슨해진 것 같다"고 표현 | 치료사 손 아래 조직이 미세하게 따뜻해지는 감각 (IT밴드는 이완이 매우 미세함) | 시술 후 허벅지 바깥쪽 당기는 느낌이 감소 | 달리기 또는 걷기 시 무릎 바깥쪽 불편감이 줄었다고 보고',
  '골절 (의심 포함), 불안정성, 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증, IT밴드 증후군 (러너즈 니) 급성 악화기 (무릎 바깥쪽에 심한 통증 있는 경우), 무릎 바깥쪽 관절 손상 급성기',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-15: 허벅지 앞쪽 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '허벅지 앞쪽 이완', 'Quadriceps Myofascial Release', 'Quad MFR',
  'hip'::body_region, '넙다리곧은근 (대퇴직근), 가쪽넓은근 (외측광근), 안쪽넓은근 (내측광근), 중간넓은근 (중간광근)',
  '등 대고 누운 자세. 다리를 편안히 펴거나 무릎 아래 작은 베개를 받쳐 허벅지 앞쪽 근육을 이완 상태로 유지', '환자 다리 옆에 서서 봄. 양손을 자연스럽게 허벅지 위에 놓을 수 있는 위치',
  '양손을 허벅지 앞쪽 근육 (넙다리네갈래근 — 허벅지 앞 4개 근육) 위에 나란히 또는 교차하여 놓음', '피부·근막을 무릎 쪽으로 살짝 당기거나 교차 방향으로 늘림',
  '[{"step":1,"instruction":"(준비 단계 — 자세 잡기) 환자를 등 대고 누운 자세로 눕히고 무릎 아래 작은 베개를 받쳐 허벅지 앞쪽 근육을 이완시킨다."},{"step":2,"instruction":"(접촉 단계 — 손 위치) 양손을 허벅지 앞쪽 근육 위에 놓는다. 한 손은 허벅지 위쪽 (엉덩이 바로 아래), 다른 손은 허벅지 중간 부위에 배치한다."},{"step":3,"instruction":"(시행 단계 — 힘 전달) 피부를 무릎 쪽으로 살짝 당겨 탄성 끝 (elastic barrier)을 찾는다. 탄성 끝에서 멈추고 90초~2분 기다린다. 조직이 이완되는 느낌이 오면 조금 더 당기고 다시 기다린다."},{"step":4,"instruction":"(반복 / 조정 단계) 허벅지를 위쪽~무릎 바로 위까지 약 3구역으로 나누어 순서대로 이동하며 반복한다. 각 구역마다 90초 이상 기다린다."},{"step":5,"instruction":"(평가 단계 — 반응 확인) 시술 후 무릎을 구부려보게 하고 (등 대고 누운 상태에서 발꿈치를 엉덩이 쪽으로 당기기) 굴곡 범위와 허벅지 앞쪽 당김 감각 변화를 확인한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['fracture', 'instability', 'malignancy', 'neurological_deficit', 'osteoporosis', 'inflammation_acute'],
  'level_2b'::evidence_level,
  '핵심 팁: > 3줄 이내, 가장 중요한 포인트만: | 1. 허벅지 앞쪽 근육 (넙다리네갈래근)은 인체에서 가장 큰 근육 중 하나입니다. 두꺼운 만큼 이완에 시간이 걸립니다. 2분 이상 기다리세요. | 2. 무릎 앞쪽 통증이 있는 환자는 무릎뼈 (슬개골) 주변을 직접 압박하지 말고 허벅지 근육 부위만 시행하세요. | 3. 시술 후 무릎 굽히기 범위를 즉시 측정해 변화를 환자와 함께 확인하면 치료 효과를 실감하게 됩니다. | -- || 좋은 반응: 환자가 "허벅지 앞이 시원하다" 또는 "늘어나는 것 같다"고 표현 | 치료사 손 아래 조직이 따뜻해지고 부드러워지는 감각 | 시술 후 무릎 굽히기 범위가 늘어남 | 쪼그려 앉기 또는 계단 내려가기 시 허벅지 앞쪽 당김 감소',
  '척추동맥 혈액순환 장애 위험, 골절 (허벅지뼈 — 대퇴골 — 골절 의심 포함), 불안정성, 종양 / 악성 질환, 신경학적 결손', '골다공증, 급성 염증 (무릎 앞쪽 점액낭염 급성기), 무릎뼈 (슬개골) 건염 급성기, 허벅지 근육 파열 후 6주 이내',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-16: 날개뼈(견갑골) 주변 근막 이완
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '날개뼈(견갑골) 주변 근막 이완', 'Scapular Myofascial Release', 'Scapular MFR',
  'thoracic'::body_region, '날개뼈(견갑골) 안쪽 가장자리(내측연) T2-T7 높이',
  '엎드린 자세 (복와위), 이마 아래 베개. 치료할 쪽 팔은 옆에 편안히 놓거나 손을 아래 등에 올려 날개뼈를 살짝 벌어지게 함', '환자 치료할 쪽에 서서 머리 방향을 봄. 팔꿈치를 펴고 엄지 또는 손 두덩을 사용할 준비',
  '엄지 끝 또는 손 두덩을 날개뼈 안쪽 가장자리(척추와 날개뼈 사이 근육)에 댐. 날개뼈 뼈 자체가 아닌 뼈 옆 근육', '날개뼈 방향(바깥쪽)으로 살짝 밀어 탄성 끝 찾기',
  '[{"step":1,"instruction":"환자를 엎드린 자세로 눕힌다. 치료할 쪽 팔을 등 위에 올려 손을 아래 등에 가져다 놓으면 날개뼈가 척추에서 벌어져 접근이 쉬워진다 (선택 사항)."},{"step":2,"instruction":"엄지 끝을 날개뼈 안쪽 가장자리 바로 옆 근육(능형근, 척추세움근 부위)에 위치시킨다. 날개뼈 뼈 위가 아닌, 뼈와 척추 사이 살에 댄다."},{"step":3,"instruction":"피부를 날개뼈 방향(바깥쪽)으로 살짝 밀어 근막의 탄성 끝을 찾는다. 탄성 끝에서 멈추고 압력을 유지하며 90초 기다린다."},{"step":4,"instruction":"이완되면 날개뼈 가장자리를 따라 위쪽에서 아래쪽으로 이동하며 반복한다 (날개뼈 위 모서리 → 날개뼈 아래 모서리 순서로 3~4개 지점)."},{"step":5,"instruction":"시술 전후 팔 들기 범위와 날개뼈 안쪽 통증 강도를 비교한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['osteoporosis', 'inflammation_acute'],
  'level_3'::evidence_level,
  '핵심 팁: 1. 환자가 치료할 쪽 손을 등 뒤로 올리면 날개뼈가 척추에서 벌어져 접근이 훨씬 쉬워진다. | 2. 날개뼈 안쪽은 능형근(rhomboid)과 척추세움근(erector spinae)이 겹치는 부위 — 두 근육 모두 이완 대상임을 인식하고 접근. | 3. 어깨 통증 환자에게 날개뼈 주변 이완을 선행하면 이후 어깨 테크닉의 효과가 높아지는 경향이 있다. | -- || 좋은 반응: 날개뼈 안쪽이 시원해지는 느낌 | 환자가 "등 안쪽이 풀리는 것 같다"고 표현 | 팔 들기나 팔 앞으로 뻗기가 치료 후 더 편해짐 | 치료사 엄지 아래 조직이 부드러워지며 살짝 더 밀려드는 느낌',
  '척추동맥 위험, 골절, 불안정성, 종양, 신경학적 결손', '골다공증 (압력 감소 필요), 급성 염증, 최근 어깨 수술 후 초기 회복 중',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();

-- MFR-17: 등 위쪽 근막 이완 (흉부 근막 크로스핸드)
INSERT INTO techniques (
  category,
  category_id,
  subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level,
  clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_e_soft_tissue',
  (SELECT id FROM technique_categories WHERE category_key = 'category_e_soft_tissue'),
  'MFR',
  '등 위쪽 근막 이완 (흉부 근막 크로스핸드)', 'Thoracic Myofascial Release — Cross-Hand Stretch', 'Thoracic MFR',
  'thoracic'::body_region, 'T1-T8 (등 위쪽 전체)',
  '엎드린 자세 (복와위), 이마 아래 얇은 베개 또는 치료 테이블 구멍 사용. 팔은 옆에 편안히 놓음', '환자 옆에 서서 몸통 방향을 바라봄. 팔꿈치를 펴고 체중을 활용할 준비',
  '한 손 손바닥은 어깨뼈 안쪽(척추와 날개뼈 사이), 다른 손 손바닥은 반대쪽 등 아래~허리 경계 부위', '두 손이 서로 대각선 반대 방향으로 피부·근막을 당김',
  '[{"step":1,"instruction":"환자를 엎드린 자세로 눕히고 어깨와 등에 힘을 빼도록 안내한다. 이마 아래 베개로 목이 편안한지 확인한다."},{"step":2,"instruction":"한 손을 어깨뼈 안쪽(척추와 날개뼈 사이 근육)에, 다른 손을 반대쪽 등 아래 부위에 교차하는 방향으로 놓는다."},{"step":3,"instruction":"피부를 살짝 서로 반대 방향으로 당겨 근막의 탄성 끝(elastic barrier)을 찾는다. 탄성 끝에서 멈추고 밀거나 힘을 더 가하지 않는다. 조직이 이완되기를 기다린다."},{"step":4,"instruction":"100~150초(약 2분) 유지한다. 조직이 이완되어 따뜻해지거나 부드러워지는 느낌이 오면 조금 더 당기고 다시 기다린다. 반대쪽(손 위치 바꿔서)도 동일하게 시행한다."},{"step":5,"instruction":"시술 전후 등 돌림(회전) 범위와 팔 들기 편안함을 비교한다. 갈비뼈 주변 통증 유무를 확인한다."}]'::jsonb,
  ARRAY['pain_relief', 'rom_improvement'], ARRAY['subacute', 'chronic'],
  ARRAY['movement_pain'], ARRAY['osteoporosis', 'inflammation_acute'],
  'level_3'::evidence_level,
  '핵심 팁: 1. 손을 밀거나 당기는 것이 아니라 피부·근막이 이완되기를 "기다리는" 것이 핵심 — 서두르면 효과가 없다. | 2. 골다공증 환자에게는 체중을 싣지 않고 손바닥 전체로 가볍게 접촉만 유지하는 수준으로 시행할 것. | 3. 등 뻣뻣함이 심한 만성 환자는 첫 세션에 이완이 느리게 나타날 수 있음 — 2~3세션 이후 효과가 누적된다. | -- || 좋은 반응: 등이 따뜻해지는 느낌 | 환자가 "뭔가 늘어나는 것 같다", "등이 편해진다"고 표현 | 치료사 손 아래 조직이 부드러워지고 손이 조금 더 당겨지는 느낌 | 시술 후 팔 들기나 등 돌림이 더 편해짐',
  '척추동맥 위험, 골절, 불안정성, 종양, 신경학적 결손', '골다공증 (압력 감소 필요), 급성 염증, 늑골(갈비뼈) 골절 또는 타박 후 회복 중, 최근 흉부 수술',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko            = EXCLUDED.name_ko,
  name_en            = EXCLUDED.name_en,
  body_region        = EXCLUDED.body_region,
  technique_steps    = EXCLUDED.technique_steps,
  purpose_tags       = EXCLUDED.purpose_tags,
  target_tags        = EXCLUDED.target_tags,
  symptom_tags       = EXCLUDED.symptom_tags,
  contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level     = EXCLUDED.evidence_level,
  clinical_notes     = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  updated_at         = NOW();
