-- ============================================================
-- verify-term-glossary.sql
-- ============================================================
-- Purpose: 마이그 052-term-glossary.sql 적용 후 검증.
--          시드 데이터 무결성과 동음이의어/보존 정책 적용 여부 확인.
-- Usage  : psql -h <host> -U <user> -d <db> -f saas/scripts/verify-term-glossary.sql
-- Author : sw-db-architect
-- Date   : 2026-05-05
-- ============================================================


-- ----------------------------------------------------------------
-- 1) 테이블 / 인덱스 / 트리거 / RLS 존재 확인
-- ----------------------------------------------------------------

SELECT '1. 테이블 존재' AS check_label,
       (SELECT to_regclass('public.term_glossary')) AS regclass;

SELECT '1a. 인덱스 존재' AS check_label,
       indexname
FROM   pg_indexes
WHERE  schemaname = 'public'
  AND  tablename  = 'term_glossary'
ORDER  BY indexname;

SELECT '1b. 트리거 존재' AS check_label,
       tgname
FROM   pg_trigger
WHERE  tgrelid = 'public.term_glossary'::regclass
  AND  NOT tgisinternal;

SELECT '1c. RLS 활성화 확인' AS check_label,
       relrowsecurity
FROM   pg_class
WHERE  oid = 'public.term_glossary'::regclass;

SELECT '1d. RLS 정책' AS check_label,
       policyname, cmd, qual
FROM   pg_policies
WHERE  schemaname = 'public'
  AND  tablename  = 'term_glossary';


-- ----------------------------------------------------------------
-- 2) 카테고리별 row 카운트 (audit §6 기준)
-- ----------------------------------------------------------------
-- 기대 분포 (마이그 052 시드):
--   posture     :  9   (§6-4 preemptive 8 + 4점지지/사점지지 분리 1 + §6-1 환측 1 = 10)
--                  실제 row: 환측(§6-1) 1 + §6-4 preemptive 9 (4점지지/사점지지 분리) = 10
--   movement    : 22+α (§6-1 movement 행 + §6-2 14행, ON CONFLICT 로 중복 신전·회내·회외 skip)
--   examination :  1   (§6-1 종말감)
--   anatomy     : 14   (§6-1 회전근개 1 + §6-3 13)
--   expression  : 11   (§6-1 expression 9 + 활주·압박·신장·이완·트리거포인트·견인·가동성·가동범위·오십견·동결견)
--   preserved   : 22   (§6-7 보존 정책 22건)
--
-- 마이그 적용 후 정확한 분포는 아래 SELECT 결과로 확정.

SELECT '2. 카테고리별 카운트' AS check_label,
       category,
       COUNT(*) AS row_count
FROM   term_glossary
GROUP  BY category
ORDER  BY category;


-- ----------------------------------------------------------------
-- 3) 보존 정책 확인 — is_preserved=true 카운트는 정확히 22 이어야 함
-- ----------------------------------------------------------------

SELECT '3. is_preserved=true 카운트 (기대 22)' AS check_label,
       COUNT(*) AS row_count
FROM   term_glossary
WHERE  is_preserved = true;

SELECT '3a. 보존 약어 목록' AS check_label,
       original_ko, english, frequency, notes
FROM   term_glossary
WHERE  is_preserved = true
ORDER  BY notes, original_ko;


-- ----------------------------------------------------------------
-- 4) 동음이의어 처리 — disambiguation_pattern 등록 row
-- ----------------------------------------------------------------
-- 기대: 활주, 압박, 신장, 이완 — 4건

SELECT '4. disambiguation_pattern 등록 카운트 (기대 4)' AS check_label,
       COUNT(*) AS row_count
FROM   term_glossary
WHERE  disambiguation_pattern IS NOT NULL;

SELECT '4a. 동음이의어 패턴 상세' AS check_label,
       original_ko, replacement_ko, english, disambiguation_pattern, notes
FROM   term_glossary
WHERE  disambiguation_pattern IS NOT NULL
ORDER  BY original_ko;


-- ----------------------------------------------------------------
-- 5) body_region 분기 — 회내/회외 row 확인
-- ----------------------------------------------------------------

SELECT '5. body_region 분기 (회내/회외)' AS check_label,
       original_ko, body_region, replacement_ko, english, notes
FROM   term_glossary
WHERE  original_ko IN ('회내','회외')
ORDER  BY original_ko, body_region NULLS FIRST;


-- ----------------------------------------------------------------
-- 6) 샘플 SELECT — audit §2-A "앙와위" 등 자세 시드는 본 마이그에 미포함 확인
--                 (audit §6-4 preemptive 만 포함)
-- ----------------------------------------------------------------

SELECT '6a. §6-4 preemptive 자세 (기대 9 row)' AS check_label,
       original_ko, replacement_ko, english
FROM   term_glossary
WHERE  category = 'posture'
ORDER  BY original_ko;

-- 참고: "앙와위 → 등 대고 눕기" 등 audit §2-A 표는 본 마이그(052)에 미포함.
-- §2-A 시드 추가는 별도 결정 후 마이그 053+ 에서 처리.


-- ----------------------------------------------------------------
-- 7) §6-2 움직임 계열 통일 확인 — 굴곡→굽힘 등
-- ----------------------------------------------------------------

SELECT '7. §6-2 움직임 통일 (기대 14종 모두 존재)' AS check_label,
       original_ko, replacement_ko, english
FROM   term_glossary
WHERE  original_ko IN
       ('굴곡','신전','외전','내전','외회전','내회전','측굴','거상',
        '회선','신연','회내','회외','배측굴곡','족저굴곡')
  AND  body_region IS NULL
ORDER  BY original_ko;


-- ----------------------------------------------------------------
-- 8) §6-3 한글 해부 표준 확인 — 한자 → 한글 매핑
-- ----------------------------------------------------------------

SELECT '8. §6-3 한글 해부 표준' AS check_label,
       original_ko, replacement_ko, english
FROM   term_glossary
WHERE  category = 'anatomy'
  AND  original_ko IN
       ('극상근','극하근','비복근','슬개골','종골','늑골','이상근','장요근',
        '요방형근','척골신경','대퇴근막장근','슬와','극돌기')
ORDER  BY original_ko;


-- ----------------------------------------------------------------
-- 9) status 분포
-- ----------------------------------------------------------------

SELECT '9. status 분포 (기대: active 100%)' AS check_label,
       status, COUNT(*) AS row_count
FROM   term_glossary
GROUP  BY status
ORDER  BY status;


-- ----------------------------------------------------------------
-- 10) 전체 row 카운트
-- ----------------------------------------------------------------

SELECT '10. 전체 row 카운트' AS check_label,
       COUNT(*) AS total_rows
FROM   term_glossary;


-- ============================================================
-- 마이그 053 보충 검증 (053-term-glossary-supplement.sql 적용 후)
-- ============================================================


-- ----------------------------------------------------------------
-- 11) phrase 매핑 존재 확인 — "신장 자세" / "단축 자세"
-- ----------------------------------------------------------------
-- 기대: 2 row. "신장 자세"는 "신장(→ 늘리기)"과 prefix 충돌 — applyGlossary
-- 길이 내림차순 정렬 보강(sw-backend-dev) 후에야 정확 매칭됨.

SELECT '11. phrase 매핑 (신장 자세 / 단축 자세, 기대 2 row)' AS check_label,
       original_ko, replacement_ko, english, category, notes
FROM   term_glossary
WHERE  original_ko IN ('신장 자세','단축 자세')
  AND  body_region IS NULL
ORDER  BY original_ko;


-- ----------------------------------------------------------------
-- 12) 외측 매핑 = '바깥쪽' 확인 (053 UPDATE — §6-1 "가쪽" → "바깥쪽")
-- ----------------------------------------------------------------

SELECT '12. 외측 매핑 (기대 replacement_ko=바깥쪽)' AS check_label,
       original_ko, replacement_ko, english, notes
FROM   term_glossary
WHERE  original_ko = '외측'
  AND  body_region IS NULL;


-- ----------------------------------------------------------------
-- 13) 반좌위 매핑 = '상체를 45도 올린 자세' 확인 (053 UPDATE — 반와위와 통일)
-- ----------------------------------------------------------------

SELECT '13. 반좌위 매핑 (기대 replacement_ko=상체를 45도 올린 자세)' AS check_label,
       original_ko, replacement_ko, english, notes
FROM   term_glossary
WHERE  original_ko = '반좌위'
  AND  body_region IS NULL;


-- ----------------------------------------------------------------
-- 14) 전체 row 카운트 (마이그 053 적용 후)
-- ----------------------------------------------------------------
-- 기대: 89 (052) + 34 (053 INSERT) = 123.
-- 053 UPDATE 2건은 row 수에 영향 없음.

SELECT '14. 전체 row 카운트 (053 적용 후, 기대 123)' AS check_label,
       COUNT(*) AS total_rows
FROM   term_glossary;


-- ============================================================
-- END OF VERIFICATION
-- ============================================================
