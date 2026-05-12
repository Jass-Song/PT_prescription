-- ============================================================
-- Migration 057 — term_glossary 동의어 6쌍 보충 (한자어 → 한글 표준)
-- ============================================================
-- Purpose: techniques 마이그 002~055 전수 조사 결과, term_glossary 에
--          매핑이 누락된 신체 부위 6쌍을 추가한다.
--          매핑 누락 시 frontend `applyGlossary` 후처리가 한자어를 그대로
--          노출시켜 KMO 표준 한국어 통일이 무너진다.
--
--          052/053 와 동일한 패턴 (INSERT … ON CONFLICT DO NOTHING) 으로
--          멱등 처리. body_region=NULL (글로벌), status='active'.
--
--          | 한자어   | 한글 표준    | 영문              | 등장 횟수 |
--          |----------|--------------|-------------------|-----------|
--          | 승모근   | 등세모근     | trapezius         | 52        |
--          | 중둔근   | 중간볼기근   | gluteus medius    | 44        |
--          | 소원근   | 작은원근     | teres minor       | 28        |
--          | 능형근   | 마름근       | rhomboid          | 26        |
--          | 대둔근   | 큰볼기근     | gluteus maximus   | 23        |
--          | 대흉근   | 큰가슴근     | pectoralis major  | 12        |
--
--          외래어 2건 (Zuggriff/Grundaufbau) 은 본 마이그 범위 외 —
--          대표님 CTM 원전 검토 후 별도 결정 (백로그 5/5 항목).
--
-- Source : techniques 마이그 002~055 전수 조사 보고서 (2026-05-12).
--          매핑 누락 원인 — 052 §6-3 (한글 해부 표준 12쌍) 에 어깨·둔부·흉부
--          주요 근육 6쌍이 누락된 채로 적용되었음.
--
-- Author : sw-db-architect
-- Date   : 2026-05-12
-- ============================================================

BEGIN;

-- ----------------------------------------------------------------
-- 1) INSERT: 한글 해부 표준 동의어 6쌍 (anatomy)
-- ----------------------------------------------------------------
-- 052 §6-3 동일 컬럼 순서·인용 부호 스타일 유지.
-- body_region = NULL  → 글로벌 매핑 (동음이의어 아님)
-- status      = 'active' (DEFAULT) → 명시적 기입 없이 기본값 사용
-- notes       = 마이그 057 출처 명시

INSERT INTO term_glossary
  (original_ko, replacement_ko, english,            category,   body_region, frequency, status,   notes)
VALUES
  ('승모근',   '등세모근',     'Trapezius',        'anatomy',  NULL,        52,        'active', '마이그 057 — 동의어 표준화 보충 (techniques 마이그 002~055 전수조사 누락분)'),
  ('중둔근',   '중간볼기근',   'Gluteus medius',   'anatomy',  NULL,        44,        'active', '마이그 057 — 동의어 표준화 보충 (techniques 마이그 002~055 전수조사 누락분)'),
  ('소원근',   '작은원근',     'Teres minor',      'anatomy',  NULL,        28,        'active', '마이그 057 — 동의어 표준화 보충 (techniques 마이그 002~055 전수조사 누락분)'),
  ('능형근',   '마름근',       'Rhomboid',         'anatomy',  NULL,        26,        'active', '마이그 057 — 동의어 표준화 보충 (techniques 마이그 002~055 전수조사 누락분)'),
  ('대둔근',   '큰볼기근',     'Gluteus maximus',  'anatomy',  NULL,        23,        'active', '마이그 057 — 동의어 표준화 보충 (techniques 마이그 002~055 전수조사 누락분)'),
  ('대흉근',   '큰가슴근',     'Pectoralis major', 'anatomy',  NULL,        12,        'active', '마이그 057 — 동의어 표준화 보충 (techniques 마이그 002~055 전수조사 누락분)')
ON CONFLICT (original_ko, body_region) DO NOTHING;


-- ----------------------------------------------------------------
-- 2) 적용 확인 NOTICE — 6 row 가 active 상태로 존재하는지 확인
-- ----------------------------------------------------------------

DO $$
DECLARE
  v_count INT;
BEGIN
  SELECT COUNT(*)
    INTO v_count
    FROM term_glossary
   WHERE original_ko IN ('승모근','중둔근','소원근','능형근','대둔근','대흉근')
     AND body_region IS NULL
     AND status      = 'active';

  RAISE NOTICE '마이그 057 — 동의어 매핑 active row 수: % / 6 (예상 6)', v_count;

  IF v_count <> 6 THEN
    RAISE WARNING '마이그 057 — 6 row 미만 적용됨. 052 §6-3 시드에 동일 한자어가 이미 등록되어 있는지 확인하세요.';
  END IF;
END $$;


COMMIT;


-- ============================================================
-- ROLLBACK (필요 시 수동 실행)
-- ============================================================
-- BEGIN;
-- DELETE FROM term_glossary
--  WHERE body_region IS NULL
--    AND original_ko IN ('승모근','중둔근','소원근','능형근','대둔근','대흉근')
--    AND notes LIKE '마이그 057%';
-- COMMIT;
-- ============================================================
-- 캐시 무효화 (마이그 적용 후 반드시 실행)
-- ============================================================
-- POST http://<host>/api/admin/term-glossary-invalidate
--   → frontend applyGlossary 캐시 무효화 후 새로 적용된 매핑이 노출됨.
-- ============================================================
-- END OF MIGRATION 057
-- ============================================================
