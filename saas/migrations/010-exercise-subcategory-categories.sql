-- ============================================================
-- Migration 010 — 운동 처방 세부 카테고리 생성 + 기법 재분류
-- K-Movement Optimism
-- 생성일: 2026-04-25
-- ============================================================
-- ⚠️  실행 순서 필수:
--     1단계: 010a-exercise-subcategory-enum.sql 먼저 실행 (ENUM 확장 커밋)
--     2단계: 이 파일 실행 (카테고리 생성 + 기법 category 업데이트)
-- ============================================================
-- 배경:
--   기존 category_f_therapeutic_exercise 하나에 subcategory TEXT 레이블만 있어
--   모든 운동 카드가 동일한 basic_principles를 표시하는 문제.
--   운동 유형별 독립 카테고리를 생성하고 기법을 재분류.
--
-- 분류 체계:
--   category_ex_neuromuscular — 신경근·운동조절 훈련 (F-001, F-005)
--   category_ex_resistance    — 근력·저항성 운동      (F-002, F-003, F-009)
--   category_ex_aerobic       — 유산소·활동성 운동    (F-004, F-008)
--   category_ex_bodyweight    — 자체중량·방향성 운동  (F-006, F-007)
-- ============================================================

-- ============================================================
-- STEP 1: 세부 카테고리 4개 생성
-- ============================================================

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_ex_neuromuscular',
  '신경근·운동조절 훈련',
  'Neuromuscular & Motor Control Training',
  '고유감각 재훈련 및 심부 안정화 근육 활성화',
  '[
    {"icon":"🎯","title_ko":"모터 컨트롤 우선","desc_ko":"큰 근육 이전에 심부 안정화 근육(복횡근, 다열근)의 선택적 활성화부터 재교육합니다. 순서가 결과를 결정합니다."},
    {"icon":"🔍","title_ko":"고유감각 재훈련","desc_ko":"관절 위치 감각과 움직임 감지 능력 회복이 기능 회복의 핵심입니다. 뇌와 근육 사이의 소통을 되살리는 과정입니다."},
    {"icon":"📊","title_ko":"오류 피드백 필수","desc_ko":"눈 감기, 거울, 레이저 포인터, 바이오피드백으로 동작 정확도를 실시간 확인합니다. 오류를 인식하는 과정 자체가 치료입니다."},
    {"icon":"🔄","title_ko":"점진적 난이도","desc_ko":"안정된 표면 → 불안정 표면 → 이중 과제(숫자 세기) 순서로 신경계 부하를 단계적으로 높입니다."},
    {"icon":"💡","title_ko":"일상 통합","desc_ko":"치료실 운동을 걷기·앉기·물건 들기 등 일상 동작에 통합하는 전이 훈련이 최종 목표입니다."}
  ]'::jsonb,
  7, true, 'group_exercise'
)
ON CONFLICT (category_key) DO UPDATE SET
  name_ko          = EXCLUDED.name_ko,
  name_en          = EXCLUDED.name_en,
  subtitle_ko      = EXCLUDED.subtitle_ko,
  basic_principles = EXCLUDED.basic_principles,
  is_active        = EXCLUDED.is_active;

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_ex_resistance',
  '근력·저항성 운동',
  'Resistance & Strength Training',
  '점진적 부하를 통한 경추·요추 주변 근육 강화',
  '[
    {"icon":"📈","title_ko":"점진적 과부하","desc_ko":"처음 2주 고반복·저저항(15-20회), 이후 저반복·고저항(8-12회)으로 단계적 강도 증가가 핵심입니다."},
    {"icon":"🎯","title_ko":"등척성 우선 시작","desc_ko":"급성기 또는 통증 회피 시 등척성 수축(5초 유지)으로 안전하게 시작합니다. 통증 없이 근육을 활성화하는 첫 단계입니다."},
    {"icon":"💪","title_ko":"근육 협응 패턴","desc_ko":"단일 근육이 아닌 기능적 협응 패턴(경추+견갑, 요추+고관절)으로 훈련합니다. 협응이 힘보다 중요합니다."},
    {"icon":"⏱️","title_ko":"충분한 회복","desc_ko":"세트 간 60-90초 휴식으로 근육 회복을 보장하고 보상 동작을 방지합니다."},
    {"icon":"📋","title_ko":"기록과 순응도","desc_ko":"세트·반복·저항을 매 세션 기록하여 점진성을 추적합니다. 기록하면 순응도가 높아집니다."}
  ]'::jsonb,
  8, true, 'group_exercise'
)
ON CONFLICT (category_key) DO UPDATE SET
  name_ko          = EXCLUDED.name_ko,
  name_en          = EXCLUDED.name_en,
  subtitle_ko      = EXCLUDED.subtitle_ko,
  basic_principles = EXCLUDED.basic_principles,
  is_active        = EXCLUDED.is_active;

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_ex_aerobic',
  '유산소·활동성 운동',
  'Aerobic & General Activity Exercise',
  '만성 통증 조절을 위한 전신 활동량 증가',
  '[
    {"icon":"🏃","title_ko":"운동 선택 자율성","desc_ko":"환자가 즐길 수 있는 운동을 함께 선택합니다. 어떤 운동이든 좋습니다. 순응도가 효과를 결정합니다."},
    {"icon":"🟢","title_ko":"낮은 강도로 시작","desc_ko":"현재 내성의 50-60%에서 시작합니다. 약간 숨이 차지만 대화 가능한 강도(Borg 11-13)가 적절합니다."},
    {"icon":"📅","title_ko":"규칙적 빈도","desc_ko":"주 3-5회, 30-60분이 목표입니다. 주 2회도 통증과 기능에 유의미한 효과가 있으므로 완벽한 계획보다 꾸준함이 중요합니다."},
    {"icon":"💬","title_ko":"통증 교육 병행","desc_ko":"운동 중 통증 증가가 위험 신호가 아님을 사전 교육합니다. 이 교육이 없으면 두려움-회피 행동으로 중도 포기할 수 있습니다."},
    {"icon":"🔄","title_ko":"일상 통합","desc_ko":"엘리베이터 대신 계단, 짧은 거리 걷기 등 일상에서 활동량을 늘리는 습관 형성이 장기 목표입니다."}
  ]'::jsonb,
  9, true, 'group_exercise'
)
ON CONFLICT (category_key) DO UPDATE SET
  name_ko          = EXCLUDED.name_ko,
  name_en          = EXCLUDED.name_en,
  subtitle_ko      = EXCLUDED.subtitle_ko,
  basic_principles = EXCLUDED.basic_principles,
  is_active        = EXCLUDED.is_active;

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  'category_ex_bodyweight',
  '자체중량·방향성 운동',
  'Body Weight & Directional Exercise',
  'MDT 방향성 선호 + 자체중량 기반 척추 재활',
  '[
    {"icon":"🔍","title_ko":"방향성 평가 우선","desc_ko":"MDT 원칙에 따라 증상 집중화(Centralization) 방향을 먼저 파악합니다. 방향이 틀리면 운동이 효과 없습니다."},
    {"icon":"✅","title_ko":"집중화 현상 확인","desc_ko":"방사통이 근위부로 이동하면 운동 방향이 맞는 것입니다. 집중화 없으면 방향을 재평가합니다. 디스크가 들어간다는 표현은 금지합니다."},
    {"icon":"🧘","title_ko":"척추 중립 유지","desc_ko":"운동 중 요추 전만·후만 과도한 변화 없이 중립 자세를 일관되게 유지합니다. 중립이 힘보다 먼저입니다."},
    {"icon":"🏠","title_ko":"자가 처방 능력","desc_ko":"하루 여러 세트(McKenzie 6-8세트/일 권고)의 가정 운동 처방으로 환자 스스로 재발에 대처하는 독립성을 높입니다."},
    {"icon":"📈","title_ko":"단계적 진행","desc_ko":"기초 동작 숙달 후 난이도를 단계적으로 증가합니다. 통증 반응을 기준으로 속도를 결정합니다."}
  ]'::jsonb,
  10, true, 'group_exercise'
)
ON CONFLICT (category_key) DO UPDATE SET
  name_ko          = EXCLUDED.name_ko,
  name_en          = EXCLUDED.name_en,
  subtitle_ko      = EXCLUDED.subtitle_ko,
  basic_principles = EXCLUDED.basic_principles,
  is_active        = EXCLUDED.is_active;

-- ============================================================
-- STEP 2: 기법 category + category_id 업데이트
-- ============================================================

-- 신경근·운동조절: F-001 (경추 고유감각), F-005 (요추 안정화)
UPDATE techniques
SET
  category    = 'category_ex_neuromuscular',
  category_id = (SELECT id FROM technique_categories WHERE category_key = 'category_ex_neuromuscular'),
  updated_at  = NOW()
WHERE abbreviation IN ('CervProp-Ex', 'LumbStab-MCE');

-- 근력·저항성: F-002 (경추·견갑 저항), F-003 (경추 운동+도수 병행), F-009 (요추 저항+코어)
UPDATE techniques
SET
  category    = 'category_ex_resistance',
  category_id = (SELECT id FROM technique_categories WHERE category_key = 'category_ex_resistance'),
  updated_at  = NOW()
WHERE abbreviation IN ('CervScap-RT', 'CervEx-MT-Combo', 'LumbRT-CoreHip');

-- 유산소·활동성: F-004 (노시플라스틱 운동), F-008 (걷기·유산소)
UPDATE techniques
SET
  category    = 'category_ex_aerobic',
  category_id = (SELECT id FROM technique_categories WHERE category_key = 'category_ex_aerobic'),
  updated_at  = NOW()
WHERE abbreviation IN ('CervEx-Nociplastic', 'LumbWalk-Aero');

-- 자체중량·방향성: F-006 (필라테스), F-007 (McKenzie 신전)
UPDATE techniques
SET
  category    = 'category_ex_bodyweight',
  category_id = (SELECT id FROM technique_categories WHERE category_key = 'category_ex_bodyweight'),
  updated_at  = NOW()
WHERE abbreviation IN ('LumbPilates', 'LumbMcK-Ext');

-- ============================================================
-- 검증 쿼리 (실행 후 확인)
-- SELECT t.abbreviation, t.category, tc.name_ko
-- FROM techniques t
-- JOIN technique_categories tc ON tc.category_key = t.category
-- WHERE t.category LIKE 'category_ex_%'
-- ORDER BY t.category, t.abbreviation;
-- 기대: 9개 기법, 각각 올바른 category_ex_* 카테고리에 배치
-- ============================================================
