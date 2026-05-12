-- ============================================================
-- verify-058.sql
-- ============================================================
-- Purpose: 마이그 058 (category_exercise01 → category_ex_neuromuscular 재분류) 적용 후 검증.
--          §1 ~ §5 항목별 결과 출력 — PASS/FAIL 판정.
-- Usage  : Supabase 대시보드 SQL 에디터에 본 파일 전체 붙여넣고 Run.
--          또는 psql -h <host> -U <user> -d <db> -f saas/scripts/verify-058.sql
-- Author : sw-db-architect
-- Date   : 2026-05-12
-- ============================================================
-- 검증 항목 (총 5):
--   §1. category_exercise01 row 수 = 0 (재분류 완료)
--   §2. category_ex_neuromuscular 발행 카운트 = 8 (NM 의도 분배 달성)
--   §3. 전체 is_published=true 카운트 = 86 (056b 큐레이션 유지)
--   §4. 카테고리별 published 분포 (23/16/12/13/8/7/7)
--   §5. technique_categories 테이블의 category_exercise01 enum 상태 (참고용)
-- ============================================================


-- ----------------------------------------------------------------
-- §1) category_exercise01 row 수 = 0
-- ----------------------------------------------------------------
-- 기대: PASS / 0 / 0

SELECT
  '1. category_exercise01 잔존 row' AS check_label,
  CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS actual,
  0        AS expected
FROM   techniques
WHERE  category = 'category_exercise01';
-- 기대: PASS / 0 / 0


-- ----------------------------------------------------------------
-- §2) category_ex_neuromuscular 발행 카운트 = 8
-- ----------------------------------------------------------------
-- 기대: PASS / 8 / 8
-- 명단 (056b §2.5): DCFT, CervPropRetraining, MCE,
--                   SH-EX-NM-PNF-D2, SH-EX-NM-Proprio,
--                   KN-EX-NM-SLB, HIP-EX-NM-PelvStab, ANK-EX-NM-SEBT

SELECT
  '2. category_ex_neuromuscular 발행 카운트' AS check_label,
  CASE WHEN COUNT(*) = 8 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS actual,
  8        AS expected
FROM   techniques
WHERE  category     = 'category_ex_neuromuscular'
  AND  is_published = true;
-- 기대: PASS / 8 / 8


-- 참고 — NM 8 개 abbreviation 명단 확인 (056b §2.5 와 일치 여부)
SELECT
  '2-참고. NM 8 명단 매치' AS check_label,
  abbreviation,
  name_ko,
  body_region::text AS body_region,
  is_published
FROM   techniques
WHERE  category     = 'category_ex_neuromuscular'
  AND  is_published = true
ORDER  BY abbreviation;
-- 기대 (8 row):
--   ANK-EX-NM-SEBT       | ...
--   CervPropRetraining   | 경추 고유감각 재훈련 ...
--   DCFT                 | 심부 경추 굴곡근 훈련 ...
--   HIP-EX-NM-PelvStab   | ...
--   KN-EX-NM-SLB         | ...
--   MCE                  | 신경운동 조절 운동 ...
--   SH-EX-NM-PNF-D2      | ...
--   SH-EX-NM-Proprio     | ...


-- ----------------------------------------------------------------
-- §3) 전체 is_published=true 카운트 = 86 (056b 큐레이션 유지 재확인)
-- ----------------------------------------------------------------
-- 기대: PASS / 86 / 86

SELECT
  '3. 전체 published 카운트 (056b 유지)' AS check_label,
  CASE WHEN COUNT(*) = 86 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS actual,
  86       AS expected
FROM   techniques
WHERE  is_published = true;
-- 기대: PASS / 86 / 86


-- ----------------------------------------------------------------
-- §4) 카테고리별 published 분포 (23/16/12/13/8/7/7)
-- ----------------------------------------------------------------
-- 기대 (7 row, 모두 PASS):
--   category_joint_mobilization | 23 | 23 | PASS
--   category_mulligan           | 16 | 16 | PASS
--   category_mfr                | 12 | 12 | PASS
--   category_trigger_point      | 13 | 13 | PASS
--   category_ex_neuromuscular   |  8 |  8 | PASS   ← 058 핵심 (056b 측정 6 → 8)
--   category_ex_resistance      |  7 |  7 | PASS
--   category_ex_bodyweight      |  7 |  7 | PASS

SELECT
  '4. 카테고리별 published 분포' AS check_label,
  category::text AS category,
  COUNT(*)       AS actual,
  CASE category::text
    WHEN 'category_joint_mobilization' THEN 23
    WHEN 'category_mulligan'           THEN 16
    WHEN 'category_mfr'                THEN 12
    WHEN 'category_trigger_point'      THEN 13
    WHEN 'category_ex_neuromuscular'   THEN 8
    WHEN 'category_ex_resistance'      THEN 7
    WHEN 'category_ex_bodyweight'      THEN 7
    ELSE 0
  END AS expected,
  CASE
    WHEN COUNT(*) = CASE category::text
                      WHEN 'category_joint_mobilization' THEN 23
                      WHEN 'category_mulligan'           THEN 16
                      WHEN 'category_mfr'                THEN 12
                      WHEN 'category_trigger_point'      THEN 13
                      WHEN 'category_ex_neuromuscular'   THEN 8
                      WHEN 'category_ex_resistance'      THEN 7
                      WHEN 'category_ex_bodyweight'      THEN 7
                      ELSE -1
                    END THEN 'PASS'
    ELSE 'FAIL'
  END AS result
FROM   techniques
WHERE  is_published = true
GROUP  BY category
ORDER  BY
  CASE category::text
    WHEN 'category_joint_mobilization' THEN 1
    WHEN 'category_mulligan'           THEN 2
    WHEN 'category_mfr'                THEN 3
    WHEN 'category_trigger_point'      THEN 4
    WHEN 'category_ex_neuromuscular'   THEN 5
    WHEN 'category_ex_resistance'      THEN 6
    WHEN 'category_ex_bodyweight'      THEN 7
    ELSE 99
  END;
-- 기대: 7 row 모두 PASS, exercise01 row 자체가 결과에 등장하지 않아야 함


-- ----------------------------------------------------------------
-- §5) technique_categories 테이블 — category_exercise01 enum 상태 (참고용)
-- ----------------------------------------------------------------
-- 본 058 은 row UPDATE 만 수행. enum 정의 (technique_categories.category_key
-- = 'category_exercise01') 는 그대로 존재. techniques 테이블 row 0 인 시점에서
-- enum 자체를 deprecate (is_active=false) 또는 제거 가능 — 별도 마이그 검토 대상.
-- 본 검증에서는 enum 정의 존재 여부 + 참조 row 0 만 확인.

SELECT
  '5. technique_categories enum 상태 (참고)' AS check_label,
  category_key,
  name_ko,
  is_active,
  (SELECT COUNT(*) FROM techniques t WHERE t.category::text = tc.category_key) AS referencing_rows
FROM   technique_categories tc
WHERE  category_key = 'category_exercise01';
-- 기대 (1 row):
--   category_exercise01 | 운동처방 | true (또는 false) | 0
--   referencing_rows = 0 이면 enum deprecate 안전 (별도 마이그 후속 검토).


-- ============================================================
-- END OF verify-058
-- ============================================================
-- 모든 §1~§4 가 PASS 일 때 058 적용 성공 — 056b NM 분배 의도(8) 달성.
-- §5 는 후속 enum deprecate 마이그 검토 시 참고용 (본 058 통과 조건 아님).
-- ============================================================
