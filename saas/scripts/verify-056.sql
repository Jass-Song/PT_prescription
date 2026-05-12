-- ============================================================
-- verify-056.sql
-- ============================================================
-- Purpose: 마이그 056a (Lumbar P0 6 신규) + 056b (86 큐레이션 시드) 적용 후 검증.
--          §1 ~ §4 항목별 결과 출력 — PASS/FAIL 판정 또는 운영 절차 안내.
-- Usage  : Supabase 대시보드 SQL 에디터에 본 파일 전체 붙여넣고 Run.
--          또는 psql -h <host> -U <user> -d <db> -f saas/scripts/verify-056.sql
-- Author : sw-db-architect
-- Date   : 2026-05-12
-- ============================================================
-- 검증 항목 (총 4):
--   §1. is_published=true 카운트 = 86 + 카테고리별 분포 (23/16/12/13/22)
--   §2. 056a P0 6 abbreviation 존재 + is_published=true 확인
--   §3. is_active=true AND is_published=true 인 row (recommend.js 필터 가정) 분포
--   §4. 운영 절차 헤더 — Supabase SQL 에디터 분리 실행 순서 안내
-- ============================================================


-- ----------------------------------------------------------------
-- §1) published 카운트 = 86 + 카테고리별 분포
-- ----------------------------------------------------------------
-- 기대: 총 86 / Maitland 23 / Mulligan 16 / MFR 12 / TrP 13 / NM 8 / RES 7 / BW 7

SELECT
  '1-A. 전체 published 카운트' AS check_label,
  CASE WHEN COUNT(*) = 86 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS pub_count,
  86       AS expected
FROM   techniques
WHERE  is_published = true;
-- 기대: PASS / 86 / 86


SELECT
  '1-B. 카테고리별 published 분포' AS check_label,
  category::text AS category,
  COUNT(*)       AS pub_count,
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
-- 기대 (7 row):
--   category_joint_mobilization | 23 | 23 | PASS
--   category_mulligan           | 16 | 16 | PASS
--   category_mfr                | 12 | 12 | PASS
--   category_trigger_point      | 13 | 13 | PASS
--   category_ex_neuromuscular   |  8 |  8 | PASS
--   category_ex_resistance      |  7 |  7 | PASS
--   category_ex_bodyweight      |  7 |  7 | PASS


SELECT
  '1-C. body_region 분포 (참고)' AS check_label,
  body_region::text AS body_region,
  COUNT(*)          AS pub_count
FROM   techniques
WHERE  is_published = true
GROUP  BY body_region
ORDER  BY pub_count DESC;
-- 기대: cervical / lumbar / shoulder / hip / knee / ankle_foot 6 부위 분포 — 합 86.


-- ----------------------------------------------------------------
-- §2) 056a P0 6 abbreviation 존재 + is_published=true 확인
-- ----------------------------------------------------------------

SELECT
  '2-A. 056a P0 6 abbreviation 존재 + published' AS check_label,
  CASE
    WHEN COUNT(*) = 6
     AND bool_and(is_active = true)
     AND bool_and(is_published = true)
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  COUNT(*)                                         AS row_count,
  COUNT(*) FILTER (WHERE is_active = true)         AS active_count,
  COUNT(*) FILTER (WHERE is_published = true)      AS published_count
FROM   techniques
WHERE  abbreviation IN (
  'JM-LX-PA-C','JM-LX-PA-U','JM-LX-Rot',
  'MUL-LX-SNAG-Flex','MUL-LX-SNAG-Ext','MUL-LX-SLR-MWM'
);
-- 기대: PASS / 6 / 6 / 6


SELECT
  '2-B. 056a P0 6 상세' AS check_label,
  abbreviation,
  name_ko,
  category::text       AS category,
  body_region::text    AS body_region,
  is_active,
  is_published,
  evidence_level::text AS evidence_level
FROM   techniques
WHERE  abbreviation IN (
  'JM-LX-PA-C','JM-LX-PA-U','JM-LX-Rot',
  'MUL-LX-SNAG-Flex','MUL-LX-SNAG-Ext','MUL-LX-SLR-MWM'
)
ORDER  BY
  CASE abbreviation
    WHEN 'JM-LX-PA-C'       THEN 1
    WHEN 'JM-LX-PA-U'       THEN 2
    WHEN 'JM-LX-Rot'        THEN 3
    WHEN 'MUL-LX-SNAG-Flex' THEN 4
    WHEN 'MUL-LX-SNAG-Ext'  THEN 5
    WHEN 'MUL-LX-SLR-MWM'   THEN 6
  END;
-- 기대 (6 row, 모두 is_active=true, is_published=true, body_region=lumbar):
--   JM-LX-PA-C       요추 중앙 후-전방 가동술              category_joint_mobilization
--   JM-LX-PA-U       요추 단측 후-전방 가동술              category_joint_mobilization
--   JM-LX-Rot        요추 회전 관절가동술 (옆누운 자세)    category_joint_mobilization
--   MUL-LX-SNAG-Flex 요추 굴곡 SNAG                       category_mulligan
--   MUL-LX-SNAG-Ext  요추 신전 SNAG                       category_mulligan
--   MUL-LX-SLR-MWM   요추 SLR-MWM (Bent Leg Raise)        category_mulligan


-- ----------------------------------------------------------------
-- §3) is_active=true AND is_published=true 인 row — 추천 후보 풀
-- ----------------------------------------------------------------
-- recommend.js 필터 가정: WHERE is_active = true AND is_published = true
-- 본 절은 본 필터 적용 시의 후보 풀 분포를 확인.

SELECT
  '3-A. 추천 후보 풀 (is_active AND is_published)' AS check_label,
  CASE WHEN COUNT(*) = 86 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS candidate_count,
  86       AS expected
FROM   techniques
WHERE  is_active = true
  AND  is_published = true;
-- 기대: PASS / 86 / 86


SELECT
  '3-B. 후보 풀 — 카테고리 × body_region 교차' AS check_label,
  category::text     AS category,
  body_region::text  AS body_region,
  COUNT(*)           AS n
FROM   techniques
WHERE  is_active = true
  AND  is_published = true
GROUP  BY category, body_region
ORDER  BY category, body_region;
-- 참고용: 부위·카테고리별 후보 분포 — 시나리오 매핑 검증에 활용.


-- 음성 검증 — is_published=true 인데 is_active=false 인 row (0 이어야 함)
SELECT
  '3-C. 음성 — published 이지만 inactive 인 row (0 이어야)' AS check_label,
  CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result,
  COUNT(*) AS row_count
FROM   techniques
WHERE  is_published = true
  AND  is_active = false;
-- 기대: PASS / 0


-- ----------------------------------------------------------------
-- §4) 운영 절차 — Supabase SQL 에디터 분리 실행 순서 안내
-- ----------------------------------------------------------------
-- 본 verify 는 056a + 056b 적용 후 단일 회 실행만으로 검증을 완료한다.
--
-- 권장 production 적용 순서 (Supabase 대시보드 SQL 에디터):
--
--   STEP 1. saas/migrations/056a-tier1-lumbar-p0-techniques.sql 전체 붙여넣기 → Run
--           - 끝부분 NOTICE 로 ''056a 결과 — Tier 1 Lumbar P0 abbreviation 카운트: 6'' 확인.
--           - EXCEPTION 발생 시 즉시 중단 → 본문 INSERT 검토.
--
--   STEP 2. saas/migrations/056b-tier1-curation-publish.sql 전체 붙여넣기 → Run
--           - NOTICE 로 ''056b 결과 — is_published=true 카운트: 86'',
--                       ''056b 결과 — 큐레이션 86 중 DB 매치: 86'' 확인.
--           - EXCEPTION 발생 시 056a 미실행 또는 abbreviation 오타 가능성 검토.
--
--   STEP 3. saas/scripts/verify-056.sql 전체 붙여넣기 → Run
--           - §1-A / §1-B / §2-A / §3-A / §3-C 모두 PASS 인지 확인.
--           - 하나라도 FAIL 시 056a/056b 재실행 또는 큐레이션 리스트 검토.
--
-- 재실행 (멱등성) 보장:
--   - 056a 는 ON CONFLICT (abbreviation) DO NOTHING — 재실행 시 row 변경 없음.
--   - 056b 는 ''전체 reset → 86 set'' 패턴 — 재실행 시에도 동일 최종 상태 (86 published).
--   - verify-056 는 SELECT 만 — 재실행 부작용 없음.
--
-- 롤백 (필요 시):
--   - 큐레이션 변경 시 056b 의 abbreviation 리스트만 수정 후 재실행.
--   - 056a 신규 row 제거가 필요한 경우 별도 DELETE 마이그를 작성한다
--     (단, 임상 데이터는 보존 권장 — is_published=false 만 토글하는 방식 우선).

SELECT
  '4. 운영 절차 요약' AS check_label,
  '056a → 056b → verify-056 §1~3' AS execution_order,
  '멱등 — 056a DO NOTHING / 056b reset→set / verify SELECT-only' AS idempotency,
  '롤백 — 056b abbreviation 리스트 수정 후 재실행 (is_published 토글)' AS rollback_strategy;


-- ============================================================
-- END OF VERIFY-056
-- ============================================================
