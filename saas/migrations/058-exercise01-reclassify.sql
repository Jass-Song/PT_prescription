-- ============================================================
-- Migration 058 — category_exercise01 → category_ex_neuromuscular 재분류
-- ============================================================
-- 목적: 056b 큐레이션 시드 후 verify-056 결과 카테고리 분배 불일치 보정.
--      verify-056 측정 (production, 2026-05-12):
--        category_ex_neuromuscular : 6   (목표 8, -2)
--        category_exercise01       : 2   (legacy enum, 큐레이션 86 명단에 의도치 않게 포함)
--        총 86 published 카운트는 유지되지만 카테고리 분배 의도와 어긋남.
--
--      대표님 결정 (2026-05-12): "추후가 아니라 지금 neuromuscular 로 재분류" —
--      본 058 즉시 작성·적용. exercise01 enum 자체의 deprecate 는 본 058 범위 외
--      (필요 시 별도 마이그에서 수행).
--
-- 영향 범위:
--   - techniques 테이블의 category 컬럼만 UPDATE
--   - is_published / is_active 등 다른 컬럼은 변경하지 않음 (updated_at 만 NOW())
--   - schema.sql 변경 없음 (enum 정의 변경이 아니라 row UPDATE)
--
-- 트레이서빌리티 — 사전 식별 query (Supabase SQL 에디터에서 별도 실행 권장):
--   SELECT id, abbreviation, name_ko, category, body_region, is_published
--     FROM techniques
--    WHERE category = 'category_exercise01';
--   → 본 마이그 §1 (PRE-CHECK) 가 동일 정보를 NOTICE 로 출력하므로
--     별도 실행 없이도 적용 로그에서 확인 가능.
--
-- 멱등성:
--   - 본 마이그 재실행 시 UPDATE 대상 0 건 → 안전 (POST-CHECK 통과)
--   - PRE-CHECK 의 v_count = 0 이어도 EXCEPTION 아님 — 정상 멱등 경로
--
-- 롤백 (필요 시):
--   UPDATE techniques SET category = 'category_exercise01'
--    WHERE category = 'category_ex_neuromuscular'
--      AND abbreviation IN ('<058 적용 시 NOTICE 로 기록된 2 개>');
--   → 본 마이그 적용 직후 NOTICE 출력의 abbreviation 목록 보존 필요.
--
-- 전제: 056a + 056b production 적용 완료 (2026-05-12)
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- Author : sw-db-architect | 2026-05-12
-- ============================================================

BEGIN;

-- ----------------------------------------------------------------
-- §1) PRE-CHECK — 영향받는 row 식별 + 카운트 출력
-- ----------------------------------------------------------------
DO $$
DECLARE
  v_count   INT;
  v_targets TEXT;
BEGIN
  SELECT COUNT(*) INTO v_count
    FROM techniques
   WHERE category = 'category_exercise01';

  -- abbreviation + name_ko + is_published 트레이서빌리티 (NOTICE 보존)
  SELECT string_agg(
           format('[%s | %s | pub=%s]',
                  COALESCE(abbreviation, '(null)'),
                  COALESCE(name_ko, '(null)'),
                  is_published::text),
           ', '
           ORDER BY abbreviation
         )
    INTO v_targets
    FROM techniques
   WHERE category = 'category_exercise01';

  RAISE NOTICE '058 PRE-CHECK — category_exercise01 row 수 (UPDATE 대상): %', v_count;
  RAISE NOTICE '058 PRE-CHECK — 대상 abbreviation/name_ko: %', COALESCE(v_targets, '(none — 멱등 재실행 경로)');
END $$;


-- ----------------------------------------------------------------
-- §2) 재분류 — category_exercise01 → category_ex_neuromuscular
-- ----------------------------------------------------------------
UPDATE techniques
   SET category   = 'category_ex_neuromuscular',
       updated_at = NOW()
 WHERE category = 'category_exercise01';


-- ----------------------------------------------------------------
-- §3) POST-CHECK — 잔존 0 확인 + NM 카운트 보고 + 무결성 EXCEPTION
-- ----------------------------------------------------------------
DO $$
DECLARE
  v_remain        INT;
  v_nm_pub_count  INT;
  v_total_pub     INT;
BEGIN
  SELECT COUNT(*) INTO v_remain
    FROM techniques
   WHERE category = 'category_exercise01';

  SELECT COUNT(*) INTO v_nm_pub_count
    FROM techniques
   WHERE category     = 'category_ex_neuromuscular'
     AND is_published = true;

  SELECT COUNT(*) INTO v_total_pub
    FROM techniques
   WHERE is_published = true;

  IF v_remain > 0 THEN
    RAISE EXCEPTION '058 POST-CHECK 실패 — category_exercise01 잔존 row: % (기대 0)', v_remain;
  END IF;

  RAISE NOTICE '058 POST-CHECK — exercise01 잔존: 0  ✓';
  RAISE NOTICE '058 POST-CHECK — category_ex_neuromuscular 발행 카운트: % (기대 8)', v_nm_pub_count;
  RAISE NOTICE '058 POST-CHECK — 전체 is_published=true 카운트: % (기대 86 — 056b 유지)', v_total_pub;

  -- 큐레이션 86 카운트 유지 무결성 (재분류는 published 수에 영향 없어야 함)
  IF v_total_pub <> 86 THEN
    RAISE EXCEPTION '058 POST-CHECK 실패 — published 총 카운트 불일치 (기대 86, 실제 %)', v_total_pub;
  END IF;
END $$;

COMMIT;

-- ============================================================
-- END OF MIGRATION 058
-- ============================================================
-- 적용 후: saas/scripts/verify-058.sql §1~§4 실행 → 모두 PASS 확인
-- 참고: technique_categories 테이블의 'category_exercise01' enum 자체 deprecate 는
--      별도 마이그 (행 0 확인 후 안전하게 ALTER TYPE … RENAME 또는 DROP 검토 — 본 058 범위 외).
-- ============================================================
