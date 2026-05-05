-- ============================================================
-- Migration 052 — term_glossary (한국어 PT 용어 표준화)
-- ============================================================
-- Purpose: 한국어 임상 PT 용어 표준화의 단일 진실 소스 (single source of truth).
--          클라이언트 index.html 의 TERM_REPLACEMENTS 하드코딩 24건,
--          서버 LLM 후처리, 미래 임상 가이드 — 모두 이 테이블로 통합한다.
--
-- Source : pt-prescription/docs/clinical-terminology-audit-2026-05-05.md §6
--          (대표님 2026-05-05 결정 사항 — 단일 진실 소스)
--
-- Author : sw-db-architect
-- Date   : 2026-05-05
-- ============================================================


-- ----------------------------------------------------------------
-- 1) TABLE
-- ----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS term_glossary (
  id                       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  original_ko              text NOT NULL,                                  -- 원어 (한자 / 외래어 / 옛 표기)
  replacement_ko           text,                                           -- 한글 표준 풀이 (NULL = 보존 정책)
  english                  text,                                           -- 영문 표기 (괄호 표기용)
  category                 text NOT NULL CHECK (category IN (
                             'posture',     -- 자세
                             'movement',    -- 움직임·방향
                             'examination', -- 검사·평가 (audit §2-C, 본 마이그에서는 §6 외 직접 시드 없음)
                             'anatomy',     -- 해부 구조물
                             'depth',       -- 깊이·층 (audit §2-E)
                             'foreign',     -- 외래어
                             'expression',  -- 임상 표현
                             'preserved'    -- 보존 정책 (약어 등 치환 제외)
                           )),
  body_region              text,                                           -- 동음이의어 구분 (예: forearm, ankle). NULL = 글로벌
  disambiguation_pattern   text,                                           -- 정규식 — 매칭 시 치환 제외
  is_preserved             boolean NOT NULL DEFAULT false,                 -- 약어 등 치환 제외 플래그
  status                   text NOT NULL DEFAULT 'active'
                             CHECK (status IN ('active','review','deprecated')),
  frequency                integer,                                        -- audit 시점 등장 횟수
  evidence_url             text,                                           -- KPTA·논문 등 표준 근거
  notes                    text,
  created_at               timestamptz NOT NULL DEFAULT now(),
  updated_at               timestamptz NOT NULL DEFAULT now(),

  UNIQUE (original_ko, body_region)
);

COMMENT ON TABLE term_glossary IS
  '한국어 PT 용어 표준화 단일 진실 소스. audit §6 결정 기반. 어드민(service_role)만 INSERT/UPDATE/DELETE.';
COMMENT ON COLUMN term_glossary.original_ko IS '원어 (한자/외래어/옛 표기)';
COMMENT ON COLUMN term_glossary.replacement_ko IS '한글 표준 풀이 — NULL이면 보존(치환 제외)';
COMMENT ON COLUMN term_glossary.body_region IS '동음이의어 부위 구분. NULL=글로벌. 예: forearm/ankle (회내/회외)';
COMMENT ON COLUMN term_glossary.disambiguation_pattern IS
  '정규식. original_ko 가 텍스트 내에서 이 패턴과 매칭되는 경우 치환을 건너뛴다 (예: 신장(콩팥), 압박골절).';
COMMENT ON COLUMN term_glossary.is_preserved IS '보존 정책 — 약어·정착어 등 치환 제외';


-- ----------------------------------------------------------------
-- 2) INDEXES
-- ----------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_term_glossary_original_active
  ON term_glossary(original_ko)
  WHERE status = 'active';

CREATE INDEX IF NOT EXISTS idx_term_glossary_category
  ON term_glossary(category);

CREATE INDEX IF NOT EXISTS idx_term_glossary_preserved
  ON term_glossary(is_preserved)
  WHERE is_preserved = true;


-- ----------------------------------------------------------------
-- 3) updated_at 자동 갱신 트리거
-- ----------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_touch_term_glossary_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_term_glossary_updated_at ON term_glossary;
CREATE TRIGGER trg_term_glossary_updated_at
  BEFORE UPDATE ON term_glossary
  FOR EACH ROW EXECUTE FUNCTION fn_touch_term_glossary_updated_at();


-- ----------------------------------------------------------------
-- 4) RLS — SELECT 모두 허용 / INSERT·UPDATE·DELETE 는 service_role 전용
-- ----------------------------------------------------------------

ALTER TABLE term_glossary ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "term_glossary_select_all" ON term_glossary;
CREATE POLICY "term_glossary_select_all"
  ON term_glossary FOR SELECT
  USING (true);

-- INSERT/UPDATE/DELETE 정책 미설정 → RLS 우회 권한(service_role)만 가능


-- ============================================================
-- 5) SEED DATA  (audit §6 — 단일 진실 소스 그대로 변환, 추측 금지)
-- ============================================================

-- ----------------------------------------------------------------
-- §6-1. 핵심 술어 (한글표준(영어))
-- ----------------------------------------------------------------
-- 회내/회외는 동음이의어 (전완 vs 발) — body_region 으로 분리 row 생성

INSERT INTO term_glossary
  (original_ko, replacement_ko, english, category, body_region, disambiguation_pattern, frequency, notes)
VALUES
  ('회내',     '엎침',                    'Pronation',           'movement',   'forearm',   NULL, 20,  '동음이의어 — 전완(아래팔)'),
  ('회내',     '안쪽 돌리기',             'Pronation',           'movement',   'ankle',     NULL, NULL,'동음이의어 — 발'),
  ('회외',     '뒤침',                    'Supination',          'movement',   'forearm',   NULL, 15,  '동음이의어 — 전완(아래팔)'),
  ('회외',     '바깥 돌리기',             'Supination',          'movement',   'ankle',     NULL, NULL,'동음이의어 — 발'),
  ('활주',     '미끄러짐',                'Gliding',             'expression', NULL,        '혈관\s*활주', 29,  '§6-5 — 비-PT 맥락(혈관 활주 등) 치환 제외'),
  ('압박',     '압박',                    'Compression',         'expression', NULL,        '압박\s*골절', 473, '§6-5 — 압박골절 등 병태 표현은 치환 제외'),
  ('신전',     '폄',                      'Extension',           'movement',   NULL,        NULL, 293, '"신전 = 늘리기" 혼동 가능 — 표준은 폄'),
  ('신장',     '늘리기',                  'Stretching',          'expression', NULL,        '신장\s*\(콩팥\)|신장\s*통증', 100, '§6-5 — 신장(콩팥) 의미는 치환 제외'),
  ('종말감',   '관절 끝 느낌',            'end feel',            'examination', NULL,       NULL, 5,   NULL),
  ('견인',     '견인',                    'Traction',            'expression', NULL,        NULL, 54,  '§6-1 — 한글 그대로 보존'),
  ('트리거포인트','통증유발점',           'trigger point',       'expression', NULL,        NULL, 262, NULL),
  ('이완',     '풀림',                    'relaxation',          'expression', NULL,        '이완\s*대기|이완\s*효과', 764, '§6-5 — 시술 흐름 표현은 자연스러운 한국어 유지(치환 제외)'),
  ('가동성',   '가동범위',                'ROM',                 'expression', NULL,        NULL, NULL,'§6-1 — 가동성/가동범위 통일'),
  ('가동범위', '가동범위',                'ROM',                 'expression', NULL,        NULL, 71,  '§6-1 — 통일 (자기 자신, 표준)'),
  ('회전근개', '회전근개',                'rotator cuff',        'anatomy',    NULL,        NULL, 47,  '§6-1 — 정착어 보존'),
  ('오십견',   '오십견',                  'Frozen shoulder',     'expression', NULL,        NULL, 5,   '§6-1 — 보존 (KMO 두려움 회피 평가 별도 보류)'),
  ('동결견',   '오십견',                  'Frozen shoulder',     'expression', NULL,        NULL, 1,   '§6-1 — 동의어 통일 → 오십견'),
  ('환측',     '아픈 쪽',                 'painful side',        'posture',    NULL,        NULL, 208, NULL),
  ('두측',     '머리 쪽',                 'cranial',             'movement',   NULL,        NULL, 12,  NULL),
  ('미측',     '꼬리 쪽',                 'caudal',              'movement',   NULL,        NULL, 15,  NULL),
  ('근위',     '몸쪽',                    'proximal',            'movement',   NULL,        NULL, 81,  NULL),
  ('원위',     '먼쪽',                    'distal',              'movement',   NULL,        NULL, 78,  NULL),
  ('상측',     '위쪽',                    'Superior',            'movement',   NULL,        NULL, NULL,NULL),
  ('하측',     '아래쪽',                  'Inferior',            'movement',   NULL,        NULL, NULL,NULL),
  ('내측',     '안쪽',                    'Medial',              'movement',   NULL,        NULL, 359, NULL),
  ('외측',     '가쪽',                    'Lateral',             'movement',   NULL,        NULL, 527, NULL),
  ('전측',     '앞쪽',                    'Anterior',            'movement',   NULL,        NULL, NULL,'§6-1 — 전측/전방 두 표기 모두 매핑'),
  ('전방',     '앞쪽',                    'Anterior',            'movement',   NULL,        NULL, 369, '§6-1 — 전측/전방 두 표기 모두 매핑'),
  ('후측',     '뒤쪽',                    'Posterior',           'movement',   NULL,        NULL, NULL,'§6-1 — 후측/후방 두 표기 모두 매핑'),
  ('후방',     '뒤쪽',                    'Posterior',           'movement',   NULL,        NULL, 364, '§6-1 — 후측/후방 두 표기 모두 매핑')
ON CONFLICT (original_ko, body_region) DO NOTHING;


-- ----------------------------------------------------------------
-- §6-2. 움직임 계열 통일 (확정)
-- ----------------------------------------------------------------
-- 신전·회내·회외는 §6-1 에서 이미 등록 — 중복 시 ON CONFLICT 로 skip

INSERT INTO term_glossary
  (original_ko, replacement_ko, english, category, body_region, frequency, notes)
VALUES
  ('굴곡',       '굽힘',          'Flexion',            'movement', NULL, 493,  NULL),
  ('신전',       '폄',            'Extension',          'movement', NULL, 293,  NULL),
  ('외전',       '벌림',          'Abduction',          'movement', NULL, 115,  NULL),
  ('내전',       '모음',          'Adduction',          'movement', NULL, 103,  NULL),
  ('외회전',     '가쪽돌림',      'External rotation',  'movement', NULL, 107,  NULL),
  ('내회전',     '안쪽돌림',      'Internal rotation',  'movement', NULL, 89,   NULL),
  ('측굴',       '옆굽힘',        'Lateral flexion',    'movement', NULL, 180,  NULL),
  ('거상',       '들어올림',      'Elevation',          'movement', NULL, 11,   NULL),
  ('회선',       '휘돌림',        'Circumduction',      'movement', NULL, 0,    NULL),
  ('신연',       '늘임',          'Distraction',        'movement', NULL, NULL, NULL),
  ('회내',       '엎침',          'Pronation',          'movement', NULL, 20,   '§6-2 글로벌. body_region 별도(forearm/ankle) 는 §6-1 에서 등록.'),
  ('회외',       '뒤침',          'Supination',         'movement', NULL, 15,   '§6-2 글로벌. body_region 별도(forearm/ankle) 는 §6-1 에서 등록.'),
  ('배측굴곡',   '발등굽힘',      'Dorsiflexion',       'movement', NULL, 69,   NULL),
  ('족저굴곡',   '발바닥굽힘',    'Plantarflexion',     'movement', NULL, 23,   NULL)
ON CONFLICT (original_ko, body_region) DO NOTHING;


-- ----------------------------------------------------------------
-- §6-3. 한글 해부 표준 12쌍 (한자 → 한글 채택)
-- ----------------------------------------------------------------

INSERT INTO term_glossary
  (original_ko, replacement_ko, english, category, frequency, notes)
VALUES
  ('극상근',         '가시위근',         'Supraspinatus',          'anatomy', 60,  NULL),
  ('극하근',         '가시아래근',       'Infraspinatus',          'anatomy', 64,  NULL),
  ('비복근',         '장딴지근',         'Gastrocnemius',          'anatomy', 76,  NULL),
  ('슬개골',         '무릎뼈',           'Patella',                'anatomy', 79,  NULL),
  ('종골',           '발꿈치뼈',         'Calcaneus',              'anatomy', 68,  NULL),
  ('늑골',           '갈비뼈',           'Rib',                    'anatomy', 46,  NULL),
  ('이상근',         '궁둥구멍근',       'Piriformis',             'anatomy', 98,  NULL),
  ('장요근',         '엉덩허리근',       'Iliopsoas',              'anatomy', 77,  NULL),
  ('요방형근',       '허리네모근',       'Quadratus lumborum',     'anatomy', 15,  NULL),
  ('척골신경',       '자신경',           'Ulnar nerve',            'anatomy', 16,  NULL),
  ('대퇴근막장근',   '넙다리근막긴장근', 'Tensor fasciae latae',   'anatomy', 16,  NULL),
  ('슬와',           '오금',             'Popliteal fossa',        'anatomy', 95,  NULL),
  ('극돌기',         '가시돌기',         'Spinous process',        'anatomy', 95,  NULL)
ON CONFLICT (original_ko, body_region) DO NOTHING;
-- 주: §6-3 표는 12쌍이지만 audit §6-3 본문은 13행(극돌기 포함). audit 본문 그대로 13건 등록.


-- ----------------------------------------------------------------
-- §6-4. 자세 추가 등록 (preemptive — 현재 DB에 없으나 PT 임상 표준)
-- ----------------------------------------------------------------

INSERT INTO term_glossary
  (original_ko, replacement_ko, english, category, frequency, notes)
VALUES
  ('슬흉위',         '무릎-가슴 자세',   'Knee-chest',     'posture', NULL, '§6-4 preemptive'),
  ('반좌위',         '등받이 세워 앉기', 'Semi-Fowler',    'posture', NULL, '§6-4 preemptive'),
  ('장좌위',         '다리 뻗고 앉기',   'Long sitting',   'posture', NULL, '§6-4 preemptive'),
  ('단좌위',         '걸터앉기',         'Short sitting',  'posture', NULL, '§6-4 preemptive'),
  ('사위',           '사선 옆 누움',     'Sims',           'posture', NULL, '§6-4 preemptive'),
  ('부복위',         '기대 누움',        '(Recumbent)',    'posture', NULL, '§6-4 preemptive'),
  ('4점지지',        '네발기기',         'Quadruped',      'posture', NULL, '§6-4 preemptive (사점지지와 동의어)'),
  ('사점지지',       '네발기기',         'Quadruped',      'posture', NULL, '§6-4 preemptive (4점지지와 동의어)'),
  ('굴슬위',         '무릎 굽혀 누움',   'Hook lying',     'posture', NULL, '§6-4 preemptive')
ON CONFLICT (original_ko, body_region) DO NOTHING;
-- 주: audit §6-4 표는 8행이지만 "4점지지 / 사점지지" 가 한 행에 두 표기로 명기되어 있어,
--      각각 별도 row 로 등록 (총 9 row). 표기형태 둘 다 매칭 가능하도록.


-- ----------------------------------------------------------------
-- §6-7. 보존 정책 (is_preserved=true, replacement_ko=NULL)
-- ----------------------------------------------------------------
-- 기법 약어 14종 + 표준 영어 약어 8종 = 22 row
-- audit §3 본문 — "ASIS / PSIS", "MRI / CT", "VAS / NRS" 는 슬래시 묶음 표기지만,
-- 실제 매칭/보존을 위해 각 약어를 개별 row 로 분리 등록 (총 보존 22 row).

INSERT INTO term_glossary
  (original_ko, replacement_ko, english, category, is_preserved, frequency, notes)
VALUES
  -- 기법 약어 14종 (§6-7)
  ('CTM',      NULL, 'Connective Tissue Massage',                          'preserved', true, 92,  '기법 약어 — 보존'),
  ('MFR',      NULL, 'Myofascial Release',                                 'preserved', true, 179, '기법 약어 — 보존'),
  ('SNAG',     NULL, 'Sustained Natural Apophyseal Glide (Mulligan)',      'preserved', true, 44,  '기법 약어 — 보존'),
  ('NAG',      NULL, 'Natural Apophyseal Glide (Mulligan)',                'preserved', true, 44,  '기법 약어 — 보존'),
  ('Mulligan', NULL, 'Mulligan Concept',                                   'preserved', true, 25,  '기법 약어 — 보존'),
  ('Maitland', NULL, 'Maitland Concept',                                   'preserved', true, 44,  '기법 약어 — 보존'),
  ('Cyriax',   NULL, 'Cyriax (DTFM 등)',                                   'preserved', true, 10,  '기법 약어 — 보존'),
  ('ART',      NULL, 'Active Release Technique',                           'preserved', true, 144, '기법 약어 — 보존'),
  ('MDT',      NULL, 'Mechanical Diagnosis & Therapy (McKenzie)',          'preserved', true, 56,  '기법 약어 — 보존'),
  ('IASTM',    NULL, 'Instrument-Assisted Soft Tissue Mobilization',       'preserved', true, 110, '기법 약어 — 보존'),
  ('TrP',      NULL, 'Trigger Point',                                      'preserved', true, NULL,'기법 약어 — 보존'),
  ('SCS',      NULL, 'Strain-Counterstrain',                               'preserved', true, NULL,'기법 약어 — 보존'),
  ('DTFM',     NULL, 'Deep Transverse Friction Massage',                   'preserved', true, NULL,'기법 약어 — 보존'),
  ('DFM',      NULL, 'Deep Friction Massage',                              'preserved', true, NULL,'기법 약어 — 보존'),

  -- 표준 영어 약어 8종 (§6-7)
  ('ROM',      NULL, 'Range of Motion',                                    'preserved', true, NULL,'표준 영어 약어 — 보존'),
  ('SLR',      NULL, 'Straight Leg Raise',                                 'preserved', true, 18,  '표준 영어 약어 — 보존'),
  ('ASIS',     NULL, 'Anterior Superior Iliac Spine',                      'preserved', true, NULL,'표준 영어 약어 — 보존 (골반 표지점)'),
  ('PSIS',     NULL, 'Posterior Superior Iliac Spine',                     'preserved', true, NULL,'표준 영어 약어 — 보존 (골반 표지점)'),
  ('MRI',      NULL, 'Magnetic Resonance Imaging',                         'preserved', true, NULL,'표준 영어 약어 — 보존'),
  ('CT',       NULL, 'Computed Tomography',                                'preserved', true, NULL,'표준 영어 약어 — 보존'),
  ('VAS',      NULL, 'Visual Analogue Scale',                              'preserved', true, NULL,'표준 영어 약어 — 보존 (통증 척도)'),
  ('NRS',      NULL, 'Numeric Rating Scale',                               'preserved', true, NULL,'표준 영어 약어 — 보존 (통증 척도)'),
  ('TMJ',      NULL, 'Temporomandibular Joint',                            'preserved', true, NULL,'표준 영어 약어 — 보존')
ON CONFLICT (original_ko, body_region) DO NOTHING;


-- ============================================================
-- ROLLBACK (필요 시 수동 실행)
-- ============================================================
-- DROP TRIGGER IF EXISTS trg_term_glossary_updated_at ON term_glossary;
-- DROP FUNCTION IF EXISTS fn_touch_term_glossary_updated_at();
-- DROP INDEX IF EXISTS idx_term_glossary_preserved;
-- DROP INDEX IF EXISTS idx_term_glossary_category;
-- DROP INDEX IF EXISTS idx_term_glossary_original_active;
-- DROP TABLE IF EXISTS term_glossary;
-- ============================================================
-- END OF MIGRATION 052
-- ============================================================
