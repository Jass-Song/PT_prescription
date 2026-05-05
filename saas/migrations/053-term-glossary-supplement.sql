-- ============================================================
-- Migration 053 — term_glossary 보충 (audit §6 부록 누락 매핑 + UPDATE 2건)
-- ============================================================
-- Purpose: 마이그 052 적용 후, audit §6 부록은 동음이의어·표준 통일만 정리하여
--          자명한 자세·움직임·검사·깊이 등 일반 매핑이 누락됨.
--          옛 클라이언트 TERM_REPLACEMENTS 24건 및 audit §2 카테고리 항목들 보충.
--
--          INSERT 34 row + UPDATE 2건 (반좌위·외측 매핑 변경).
--
-- Source : 대표님 결정 2026-05-05 후속 (단일 진실 소스 — 본 표 외 추가 금지).
--
-- Author : sw-db-architect
-- Date   : 2026-05-05
-- ============================================================

BEGIN;

-- ----------------------------------------------------------------
-- 1) UPDATE: 052 의 반좌위·외측 매핑 변경
-- ----------------------------------------------------------------

-- 1-1. 반좌위 → "상체를 45도 올린 자세" (반와위와 통일)
UPDATE term_glossary
   SET replacement_ko = '상체를 45도 올린 자세',
       english        = 'Semi-recumbent',
       notes          = '반와위와 통일 — 대표님 결정 2026-05-05'
 WHERE original_ko = '반좌위'
   AND body_region IS NULL;

-- 1-2. 외측 → "바깥쪽" (§6-1 "가쪽" → "바깥쪽" 변경, 측방과 일관성)
UPDATE term_glossary
   SET replacement_ko = '바깥쪽',
       notes          = '"가쪽"(KPTA 표준) → "바깥쪽" 변경 — 대표님 결정 2026-05-05. 측방과 일관성.'
 WHERE original_ko = '외측'
   AND body_region IS NULL;


-- ----------------------------------------------------------------
-- 2) INSERT: A. 자세 (posture) — 11건
-- ----------------------------------------------------------------

INSERT INTO term_glossary
  (original_ko, replacement_ko, english, category, body_region, frequency, notes)
VALUES
  ('앙와위',   '등 대고 눕기',          'Supine',         'posture', NULL, 73,   '옛 TERM_REPLACEMENTS 동일'),
  ('양와위',   '등 대고 눕기',          'Supine',         'posture', NULL, NULL, '앙와위 변형'),
  ('복와위',   '엎드려 눕기',           'Prone',          'posture', NULL, 84,   NULL),
  ('복위',     '엎드려 눕기',           'Prone',          'posture', NULL, NULL, '복와위 변형'),
  ('측와위',   '옆으로 눕기',           'Side-lying',     'posture', NULL, 44,   NULL),
  ('좌위',     '앉은 자세',             'Sitting',        'posture', NULL, 26,   NULL),
  ('입위',     '선 자세',               'Standing',       'posture', NULL, 8,    NULL),
  ('건측',     '안 아픈 쪽',            'Unaffected side','posture', NULL, 5,    '환측 짝'),
  ('양측',     '양쪽',                  'Bilateral',      'posture', NULL, 16,   NULL),
  ('와위',     '누운 자세',             'Recumbent',      'posture', NULL, 201,  '단독 사용 — 와위 변형의 상위 어미'),
  ('반와위',   '상체를 45도 올린 자세', 'Semi-recumbent', 'posture', NULL, NULL, '신규 추가')
ON CONFLICT (original_ko, body_region) DO NOTHING;


-- ----------------------------------------------------------------
-- 3) INSERT: B. 움직임 (movement) — 5건
-- ----------------------------------------------------------------

INSERT INTO term_glossary
  (original_ko, replacement_ko, english, category, body_region, frequency, notes)
VALUES
  ('전굴',     '앞으로 굽히기',  'Forward bending',  'movement', NULL, 6,    '옛 TERM_REPLACEMENTS'),
  ('후굴',     '뒤로 젖히기',    'Backward bending', 'movement', NULL, NULL, '옛 TERM_REPLACEMENTS'),
  ('굽힘근',   '굽히는 근육',    'Flexor',           'movement', NULL, 17,   NULL),
  ('폄근',     '펴는 근육',      'Extensor',         'movement', NULL, 21,   NULL),
  ('내전근',   '모으는 근육',    'Adductor',         'movement', NULL, 40,   '"허벅지 안쪽 근육"도 가능하나 단순화')
ON CONFLICT (original_ko, body_region) DO NOTHING;


-- ----------------------------------------------------------------
-- 4) INSERT: C. 검사 (examination) — 8건
-- ----------------------------------------------------------------

INSERT INTO term_glossary
  (original_ko, replacement_ko, english, category, body_region, frequency, notes)
VALUES
  ('촉진',     '만져 보기',                  'Palpation',     'examination', NULL, 239, NULL),
  ('압통',     '누를 때 아픔',               'Tenderness',    'examination', NULL, 387, NULL),
  ('압통점',   '누르면 아픈 점',             'Tender point',  'examination', NULL, 148, NULL),
  ('통점',     '아픈 점',                    'Pain point',    'examination', NULL, 148, NULL),
  ('결절',     '덩어리 또는 뭉친 곳',        'Nodule',        'examination', NULL, 137, NULL),
  ('경결',     '굳어진 부분',                'Induration',    'examination', NULL, 10,  NULL),
  ('등척성',   '길이 변화 없이 힘 주기',     'Isometric',     'examination', NULL, 11,  NULL),
  ('등장성',   '움직이면서',                 'Isotonic',      'examination', NULL, 3,   NULL)
ON CONFLICT (original_ko, body_region) DO NOTHING;


-- ----------------------------------------------------------------
-- 5) INSERT: D. 깊이 (depth) — 6건
-- ----------------------------------------------------------------

INSERT INTO term_glossary
  (original_ko, replacement_ko, english, category, body_region, frequency, notes)
VALUES
  ('표재',     '얕은',          'Superficial',         'depth', NULL, 35,   NULL),
  ('표재층',   '얕은 층',       'Superficial layer',   'depth', NULL, 25,   NULL),
  ('심부',     '깊은 부위',     'Deep',                'depth', NULL, 175,  NULL),
  ('심층',     '깊은 층',       'Deep layer',          'depth', NULL, 26,   NULL),
  ('피하층',   '피부 아래 층',  'Subcutaneous layer',  'depth', NULL, NULL, NULL),
  ('중간층',   '가운데 층',     'Middle layer',        'depth', NULL, NULL, NULL)
ON CONFLICT (original_ko, body_region) DO NOTHING;


-- ----------------------------------------------------------------
-- 6) INSERT: E. 표현 (expression) — 3건
-- ----------------------------------------------------------------

INSERT INTO term_glossary
  (original_ko, replacement_ko, english, category, body_region, frequency, notes)
VALUES
  ('횡마찰',     '가로 비비기',   'Cross friction',      'expression', NULL, 44,   NULL),
  ('단축 자세',  '짧아진 자세',   'Shortened position',  'expression', NULL, NULL, '신규 — phrase 길이 우선 정렬 필요'),
  ('신장 자세',  '늘어난 자세',   'Lengthened position', 'expression', NULL, NULL, '신규 — "신장(→ 늘리기)"과 prefix 충돌 — phrase 우선 정렬 필요')
ON CONFLICT (original_ko, body_region) DO NOTHING;


-- ----------------------------------------------------------------
-- 7) INSERT: F. 위치 (movement) — 1건
-- ----------------------------------------------------------------

INSERT INTO term_glossary
  (original_ko, replacement_ko, english, category, body_region, frequency, notes)
VALUES
  ('측방',     '바깥쪽',        'Lateral',     'movement', NULL, 50,   '외측과 일관성 위해 바깥쪽 (대표님 결정 2026-05-05)')
ON CONFLICT (original_ko, body_region) DO NOTHING;


COMMIT;


-- ============================================================
-- ROLLBACK (필요 시 수동 실행)
-- ============================================================
-- BEGIN;
-- -- UPDATE 되돌리기
-- UPDATE term_glossary
--    SET replacement_ko = '등받이 세워 앉기',
--        english        = 'Semi-Fowler',
--        notes          = '§6-4 preemptive'
--  WHERE original_ko = '반좌위' AND body_region IS NULL;
--
-- UPDATE term_glossary
--    SET replacement_ko = '가쪽',
--        notes          = NULL
--  WHERE original_ko = '외측' AND body_region IS NULL;
--
-- -- INSERT 삭제
-- DELETE FROM term_glossary
--  WHERE body_region IS NULL
--    AND original_ko IN (
--      -- A. 자세 11
--      '앙와위','양와위','복와위','복위','측와위','좌위','입위','건측','양측','와위','반와위',
--      -- B. 움직임 5
--      '전굴','후굴','굽힘근','폄근','내전근',
--      -- C. 검사 8
--      '촉진','압통','압통점','통점','결절','경결','등척성','등장성',
--      -- D. 깊이 6
--      '표재','표재층','심부','심층','피하층','중간층',
--      -- E. 표현 3
--      '횡마찰','단축 자세','신장 자세',
--      -- F. 위치 1
--      '측방'
--    );
-- COMMIT;
-- ============================================================
-- END OF MIGRATION 053
-- ============================================================
