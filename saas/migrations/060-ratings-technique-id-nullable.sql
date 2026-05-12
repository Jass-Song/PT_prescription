-- ============================================================
-- Migration 060 — ratings.technique_id NOT NULL 제약 제거 (HOTFIX)
-- ============================================================
-- 배경 (대표님 E2E 2026-05-12 production 에러):
--   ratings INSERT 400:
--     {"code":"23502",
--      "message":"null value in column \"technique_id\" of relation
--                 \"ratings\" violates not-null constraint"}
--   technique: "허리네모근(Quadratus lumborum) 통증유발점(trigger point)"
--
--   api/feedback.js L83~102 의 본 의도:
--     - techniques.name_ko=eq.<technique> 조회 시도
--     - 매치 실패 시 technique_id = null 폴백
--       (코드 주석: "Anatomy Trains·LLM 의역 등")
--     - payload.technique_id = techniqueId (null 가능)
--   그러나 DB ratings.technique_id 가 UUID NOT NULL → null INSERT 거부.
--
--   악화 원인:
--     - 마이그 057 (term_glossary 6쌍 추가) + applyGlossary 후처리 활성화
--     - frontend 가 변환된 이름 (예: "요방형근" →
--       "허리네모근(Quadratus lumborum)") 을 feedback 에 전달
--     - 변환된 이름은 techniques.name_ko 와 매치 안 됨 → null 폴백
--     - NOT NULL 위반으로 ratings INSERT 차단 → 평가 학습 신호 전체 손실
--
-- 수정 방침:
--   ALTER TABLE ratings ALTER COLUMN technique_id DROP NOT NULL
--
-- 근거:
--   1. feedback.js 본 의도대로 동작 회복 (코드 주석에 명시된 폴백 경로)
--   2. ratings.technique_label TEXT 컬럼이 이미 원본 이름 보존 →
--      FK 끊겨도 식별·집계·조회 가능 (사후 매핑 여지)
--   3. 기존 schema.sql L444~447 의 fn_refresh_technique_stats() 가
--      v_tech_id IS NULL 케이스 RETURN NULL 로 스킵 (이미 NULL 대비됨)
--   4. FK 자체는 유지 (technique_id 가 NOT NULL 이 아니어도
--      REFERENCES techniques(id) ON DELETE CASCADE 그대로) — NULL 허용 +
--      값이 있을 땐 FK 검증
--
-- 영향 범위:
--   - ratings.technique_id NULL 허용 (단일 컬럼 제약 변경)
--   - FK 제약 / 인덱스 / RLS / 트리거 0 변경
--   - 기존 row 데이터 0 변경
--   - schema.sql L173 동기화 별도 커밋
--
-- 멱등성:
--   - 이미 NULLABLE 인 경우 ALTER 는 no-op 처리 (DO 블록 가드)
--   - 본 마이그 재실행 시 POST-CHECK 만 다시 출력
--
-- 롤백 (필요 시 — 현 시점 비권장):
--   ALTER TABLE ratings ALTER COLUMN technique_id SET NOT NULL;
--   (단, 본 마이그 후 INSERT 된 NULL row 존재 시 실패 — 사전 정리 필요)
--
-- 전제: migration 049 (ratings 본체) production 적용 완료
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- Author : sw-db-architect | 2026-05-12
-- ============================================================

BEGIN;


-- ----------------------------------------------------------------
-- 1) ratings.technique_id NOT NULL 제거 (멱등)
-- ----------------------------------------------------------------

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM   information_schema.columns
    WHERE  table_schema = 'public'
      AND  table_name   = 'ratings'
      AND  column_name  = 'technique_id'
      AND  is_nullable  = 'NO'
  ) THEN
    EXECUTE 'ALTER TABLE public.ratings ALTER COLUMN technique_id DROP NOT NULL';
    RAISE NOTICE 'ratings.technique_id NOT NULL 제거 완료';
  ELSE
    RAISE NOTICE 'ratings.technique_id 이미 NULLABLE — 변경 없음 (멱등)';
  END IF;
END $$;


-- ----------------------------------------------------------------
-- 2) COMMENT 갱신 — NULL 허용 이유 명시
-- ----------------------------------------------------------------

COMMENT ON COLUMN public.ratings.technique_id IS
  'techniques.id FK (NULLABLE — 마이그 060). Anatomy Trains·LLM 의역·용어집(term_glossary) 후처리로 인해 techniques.name_ko 와 매치 안 되는 케이스에서 NULL 폴백 (api/feedback.js L83~102 본 의도). 원본 이름은 technique_label TEXT 에 보존. 트리거 fn_refresh_technique_stats() 는 NULL 케이스 스킵 (schema.sql L444~447).';


-- ----------------------------------------------------------------
-- POST-CHECK §1 — technique_id NULLABLE 확인
-- ----------------------------------------------------------------

DO $$
DECLARE
  v_nullable TEXT;
BEGIN
  SELECT is_nullable
    INTO v_nullable
  FROM   information_schema.columns
  WHERE  table_schema = 'public'
    AND  table_name   = 'ratings'
    AND  column_name  = 'technique_id';

  RAISE NOTICE '[POST-CHECK §1] ratings.technique_id is_nullable: %', v_nullable;

  IF v_nullable IS NULL THEN
    RAISE EXCEPTION '[POST-CHECK §1 FAIL] ratings.technique_id 컬럼이 존재하지 않음';
  END IF;

  IF v_nullable <> 'YES' THEN
    RAISE EXCEPTION '[POST-CHECK §1 FAIL] NOT NULL 제거 실패 — is_nullable=%', v_nullable;
  END IF;

  RAISE NOTICE '[POST-CHECK §1 PASS] ratings.technique_id NULLABLE 확인';
END $$;


-- ----------------------------------------------------------------
-- POST-CHECK §2 — FK 제약 유지 확인
-- ----------------------------------------------------------------
-- ratings.technique_id → techniques(id) ON DELETE CASCADE 가 그대로인지 확인.
-- ALTER COLUMN DROP NOT NULL 은 FK 에 영향 없지만 안전망으로 검증.

DO $$
DECLARE
  v_fk_count INTEGER;
  v_delete_action TEXT;
BEGIN
  SELECT COUNT(*), MAX(c.confdeltype::TEXT)
    INTO v_fk_count, v_delete_action
  FROM   pg_constraint c
  JOIN   pg_class      t  ON t.oid  = c.conrelid
  JOIN   pg_namespace  n  ON n.oid  = t.relnamespace
  JOIN   pg_class      rt ON rt.oid = c.confrelid
  WHERE  n.nspname  = 'public'
    AND  t.relname  = 'ratings'
    AND  rt.relname = 'techniques'
    AND  c.contype  = 'f'
    AND  (
      SELECT array_agg(att.attname::text ORDER BY att.attname::text)
      FROM   unnest(c.conkey) AS k(attnum)
      JOIN   pg_attribute att
        ON   att.attrelid = c.conrelid AND att.attnum = k.attnum
    ) = ARRAY['technique_id']::text[];

  RAISE NOTICE '[POST-CHECK §2] FK count: %, ON DELETE: %', v_fk_count, v_delete_action;

  IF v_fk_count <> 1 THEN
    RAISE EXCEPTION '[POST-CHECK §2 FAIL] FK 제약 손실 — count=%', v_fk_count;
  END IF;

  -- confdeltype: 'c' = CASCADE
  IF v_delete_action <> 'c' THEN
    RAISE EXCEPTION '[POST-CHECK §2 FAIL] ON DELETE 정책 변경 감지 (기대: c=CASCADE, 실제: %)', v_delete_action;
  END IF;

  RAISE NOTICE '[POST-CHECK §2 PASS] FK technique_id → techniques(id) ON DELETE CASCADE 유지';
END $$;


COMMIT;


-- ============================================================
-- 적용 후 권장 후속:
--   1) saas/scripts/verify-060.sql 실행 → §1~§4 PASS 확인
--   2) 대표님 E2E 재시도 — "허리네모근(Quadratus lumborum)" 등
--      변환된 이름으로 feedback 제출 → ratings INSERT 200 OK
--   3) (별도 PR / 본 핫픽스 범위 외) feedback.js technique lookup 개선 —
--      괄호 () 제거 후 retry, 또는 frontend 가 원본 name_ko 보존 →
--      matched 률 ↑ → NULL FK 발생 빈도 ↓
-- ============================================================
