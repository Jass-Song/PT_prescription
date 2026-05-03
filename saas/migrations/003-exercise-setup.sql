-- ============================================================
-- K-Movement Optimism — Migration 003
-- 운동처방 (category_exercise01) + 신경가동술 (category_d_neural) 카테고리 등록
-- 신규 symptom 태그 29개 + target 태그 1개
-- 생성일: 2026-04-25
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- ⚠️  실행 순서 필수:
--     1단계: 003a-exercise-enum.sql 먼저 실행 (ENUM 확장 커밋)
--     2단계: 이 파일 실행 (카테고리 + 태그 INSERT)
-- ============================================================

-- ============================================================
-- STEP 1: 카테고리 INSERT
-- ============================================================

-- category_exercise01: 운동처방
INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active)
VALUES (
  'category_exercise01',
  '운동처방',
  'Exercise Prescription',
  '근거기반 운동치료 프로토콜',
  '[
    {"icon":"🎯","title_ko":"방향성 선호 우선","desc_ko":"MDT 원칙에 따라 증상 집중화 방향을 먼저 파악하고 운동 방향을 결정합니다."},
    {"icon":"🧠","title_ko":"신경운동 조절 재훈련","desc_ko":"심부 안정화 근육(복횡근, 다열근)의 선택적 활성화부터 시작하여 기능적 통합으로 진행합니다."},
    {"icon":"📈","title_ko":"점진적 과부하","desc_ko":"통증 신호가 아닌 기능 목표(Quota)를 기반으로 활동량을 단계적으로 증가시킵니다."},
    {"icon":"🔄","title_ko":"자가관리 교육","desc_ko":"환자 스스로 재발 시 처방 가능하도록 독립적 운동 역량을 키우는 것이 궁극적 목표입니다."},
    {"icon":"💬","title_ko":"통증 신경과학 통합","desc_ko":"통증은 손상 신호가 아닌 위협 신호임을 교육하여 두려움-회피 행동을 개선합니다."}
  ]'::jsonb,
  3,
  true
)
ON CONFLICT (category_key) DO NOTHING;

-- category_d_neural: 신경가동술
INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active)
VALUES (
  'category_d_neural',
  '신경가동술',
  'Neurodynamic Mobilization',
  '신경조직 슬라이더·텐셔너 기법',
  '[
    {"icon":"⚡","title_ko":"Slider 우선","desc_ko":"신경을 스트레칭하는 것이 아니라 미끄러뜨리는 개념입니다. Tensioner보다 신경계 부담이 적어 먼저 적용합니다."},
    {"icon":"🔍","title_ko":"신경 긴장 평가 선행","desc_ko":"SLR, Slump 검사로 신경 긴장 유발 위치와 방향을 먼저 파악한 후 기법을 선택합니다."},
    {"icon":"📏","title_ko":"범위 점진 증가","desc_ko":"날카로운 통증 없이 약한 당기는 느낌 내에서 범위를 점진적으로 넓혀갑니다."},
    {"icon":"🔄","title_ko":"리드미컬한 반복","desc_ko":"느린 정적 스트레칭보다 리드미컬한 반복 운동이 신경 슬라이딩 효과를 높입니다."},
    {"icon":"🏠","title_ko":"가정 운동 처방","desc_ko":"임상 적용 후 반드시 가정 운동으로 전환하여 치료 효과를 유지합니다."}
  ]'::jsonb,
  4,
  true
)
ON CONFLICT (category_key) DO NOTHING;

-- ============================================================
-- STEP 2: 신규 technique_tags INSERT
-- ============================================================

-- ────────────────────────────────
-- symptom 태그 신규 29개
-- ────────────────────────────────
INSERT INTO technique_tags (tag_type, tag_key, label_ko, label_en, sort_order) VALUES
('symptom', 'movement_pain',              '움직일 때 통증',     'Movement Pain',              11),
('symptom', 'centralization_phenomenon',  '집중화 현상',        'Centralization Phenomenon',  12),
('symptom', 'recurrent_lbp',             '재발성 요통',        'Recurrent LBP',              13),
('symptom', 'movement_control_deficit',  '움직임 조절 결함',   'Movement Control Deficit',   14),
('symptom', 'chronic_lbp',              '만성 요통',          'Chronic LBP',                15),
('symptom', 'fear_avoidance',           '두려움-회피',        'Fear Avoidance',             16),
('symptom', 'kinesiophobia',            '운동 공포증',        'Kinesiophobia',               17),
('symptom', 'pain_catastrophizing',     '통증 파국화',        'Pain Catastrophizing',        18),
('symptom', 'central_sensitization',    '중추 감작화',        'Central Sensitization',       19),
('symptom', 'disability_high',          '기능장애(높음)',     'High Disability',             20),
('symptom', 'rest_pain',                '안정시 통증',        'Rest Pain',                   21),
('symptom', 'sciatic_pain',             '좌골신경통',         'Sciatic Pain',                22),
('symptom', 'neural_tension',           '신경 긴장',          'Neural Tension',              23),
('symptom', 'neck_pain',                '경추통',             'Neck Pain',                   24),
('symptom', 'neck_pain_chronic',        '만성 경추통',        'Chronic Neck Pain',           25),
('symptom', 'cervical_derangement',     '경추 내장장애',      'Cervical Derangement',        26),
('symptom', 'whiplash',                 '편타손상',           'Whiplash',                    27),
('symptom', 'cervical_spondylosis',     '경추 척추증',        'Cervical Spondylosis',        28),
('symptom', 'occupational_neck_pain',   '직업성 경추통',      'Occupational Neck Pain',      29),
('symptom', 'forward_head_posture',     '전두부 자세',        'Forward Head Posture',        30),
('symptom', 'dizziness_cervicogenic',   '경추성 어지럼증',    'Cervicogenic Dizziness',      31),
('symptom', 'balance_disorder',         '균형 장애',          'Balance Disorder',            32),
('symptom', 'sport_return',             '스포츠 복귀',        'Sport Return',                33),
('symptom', 'elbow_pain',               '팔꿈치 통증',        'Elbow Pain',                  34),
('symptom', 'wrist_pain',               '손목 통증',          'Wrist Pain',                  35),
('symptom', 'hand_finger_pain',         '손/손가락 통증',     'Hand/Finger Pain',            36),
('symptom', 'rib_pain',                 '늑골 통증',          'Rib Pain',                    37),
('symptom', 'ankle_pain_general',       '발목/발 통증',       'Ankle/Foot Pain',             38),
('symptom', 'tibiofibular_dysfunction', '경비관절 기능장애',  'Tibiofibular Dysfunction',    39)
ON CONFLICT (tag_type, tag_key) DO NOTHING;

-- ────────────────────────────────
-- target 태그 신규 1개
-- ────────────────────────────────
INSERT INTO technique_tags (tag_type, tag_key, label_ko, label_en, sort_order) VALUES
('target', 'hypomobile', '저가동성', 'Hypomobile', 8)
ON CONFLICT (tag_type, tag_key) DO NOTHING;
