-- ============================================================
-- verify-057.sql
-- ============================================================
-- Purpose: 마이그 057 (term_glossary 동의어 6쌍 보충) 적용 후 검증.
--          §1 ~ §4 항목별 PASS/FAIL 또는 안내 출력.
-- Usage  : Supabase 대시보드 SQL 에디터에 본 파일 전체 붙여넣고 Run.
--          또는 psql -h <host> -U <user> -d <db> -f saas/scripts/verify-057.sql
-- Author : sw-db-architect
-- Date   : 2026-05-12
-- ============================================================
-- 검증 항목 (총 4):
--   §1. term_glossary 6쌍 row 수 (예상 6)
--   §2. 6쌍 매핑 상세 표시 (original_ko, replacement_ko, english, status)
--   §3. 캐시 무효화 안내 — POST /api/admin/term-glossary-invalidate
--   §4. E2E 가이드 — 추천 응답 후 한자어 → 한글 변환 확인 절차
-- ============================================================


-- ----------------------------------------------------------------
-- §1) row 수 검증 (예상 6)
-- ----------------------------------------------------------------

SELECT
  '1. term_glossary 동의어 6쌍 row 수' AS check_label,
  CASE
    WHEN COUNT(*) = 6
     AND bool_and(status = 'active')
     AND bool_and(body_region IS NULL)
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  COUNT(*)                                  AS row_count,
  COUNT(*) FILTER (WHERE status = 'active') AS active_count,
  COUNT(*) FILTER (WHERE body_region IS NULL) AS global_count
FROM   term_glossary
WHERE  original_ko IN ('승모근','중둔근','소원근','능형근','대둔근','대흉근');
-- 기대: PASS / 6 / 6 / 6


-- ----------------------------------------------------------------
-- §2) 6쌍 매핑 상세 표시
-- ----------------------------------------------------------------

SELECT
  '2. 매핑 상세' AS check_label,
  original_ko,
  replacement_ko,
  english,
  category,
  status,
  body_region,
  frequency,
  left(notes, 60) AS notes_prefix
FROM   term_glossary
WHERE  original_ko IN ('승모근','중둔근','소원근','능형근','대둔근','대흉근')
ORDER  BY
  CASE original_ko
    WHEN '승모근' THEN 1
    WHEN '중둔근' THEN 2
    WHEN '소원근' THEN 3
    WHEN '능형근' THEN 4
    WHEN '대둔근' THEN 5
    WHEN '대흉근' THEN 6
  END;
-- 기대 (6 row):
--   승모근  → 등세모근    (Trapezius)         anatomy active NULL 52
--   중둔근  → 중간볼기근  (Gluteus medius)    anatomy active NULL 44
--   소원근  → 작은원근    (Teres minor)       anatomy active NULL 28
--   능형근  → 마름근      (Rhomboid)          anatomy active NULL 26
--   대둔근  → 큰볼기근    (Gluteus maximus)   anatomy active NULL 23
--   대흉근  → 큰가슴근    (Pectoralis major)  anatomy active NULL 12


-- ----------------------------------------------------------------
-- §3) 캐시 무효화 안내
-- ----------------------------------------------------------------
-- 마이그 적용 후 frontend applyGlossary 의 in-memory 캐시는 즉시 새 매핑을
-- 반영하지 않는다. 반드시 다음 엔드포인트를 호출하여 캐시를 무효화한다.
--
--   curl -X POST https://<프로덕션 도메인>/api/admin/term-glossary-invalidate \
--        -H "Authorization: Bearer <ADMIN_SECRET>"
--
--   기대 응답:  { "ok": true, "invalidated_at": "<ISO 타임스탬프>" }
--
-- 캐시 무효화 후 60초 이내에 추천 응답에서 한자어 → 한글 변환이 반영된다.
-- 호출 실패 시 서버 재시작으로도 캐시는 초기화된다.

SELECT
  '3. 캐시 무효화 안내' AS check_label,
  'POST /api/admin/term-glossary-invalidate (Authorization: Bearer ADMIN_SECRET)' AS endpoint,
  '응답 { ok: true, invalidated_at: ... } 확인 후 60초 이내 반영' AS expected;


-- ----------------------------------------------------------------
-- §4) E2E 가이드 — 한자어 → 한글 변환 확인
-- ----------------------------------------------------------------
-- 추천 호출 후 응답 본문에 6 한자어 중 하나라도 그대로 노출되면 FAIL.
-- techniques 본문은 protocol_steps / description / contraindications 등에
-- 한자어를 포함할 수 있으나, frontend applyGlossary 후처리가 표준 한글로
-- 변환한다. 변환 검증을 위해 다음 절차를 따른다.
--
-- [절차 A] 데이터 측면 — techniques 본문에 한자어가 살아있는 row 식별
--   (frontend 변환이 실패해도 데이터가 어떤 한자어를 포함하는지 미리 안다)
--
SELECT
  '4-A. techniques 본문에 한자어 포함된 row 수 (참고용)' AS check_label,
  original_ko,
  COUNT(DISTINCT t.id) AS technique_row_count
FROM (
  VALUES ('승모근'),('중둔근'),('소원근'),('능형근'),('대둔근'),('대흉근')
) AS s(original_ko)
LEFT JOIN techniques t
  ON t.is_active = true
 AND (
       COALESCE(t.name_ko,        '') ILIKE '%' || s.original_ko || '%'
    OR COALESCE(t.description,    '') ILIKE '%' || s.original_ko || '%'
    OR COALESCE(t.korean_label,   '') ILIKE '%' || s.original_ko || '%'
 )
GROUP BY s.original_ko
ORDER BY s.original_ko;
-- 기대: 각 한자어별 0 이상의 row (데이터에 한자어가 있어야 변환 가치가 있음).
-- 모두 0 이면 본 마이그의 즉각적 효과는 없으나, 향후 추가 시드를 대비한
-- preemptive 매핑으로 의미가 있다.
--
-- [절차 B] 운영 측면 — 실제 추천 호출 후 응답 검증
--
--   1. 프론트엔드에서 추천 호출:
--        body region = shoulder / hip / scapular 등 (한자어 포함 가능 부위)
--        ex) POST /api/recommend  with { region: 'shoulder', symptom: '어깨 통증' }
--
--   2. 응답 JSON 의 다음 필드들을 grep:
--        - protocol_steps[].description
--        - description
--        - korean_label / name_ko
--      grep 패턴: '승모근|중둔근|소원근|능형근|대둔근|대흉근'
--      기대: 0건 매치 (모두 한글 표준으로 치환됨)
--
--   3. 변환된 표기 확인:
--        '등세모근(trapezius)' / '중간볼기근(gluteus medius)' / ...
--        applyGlossary 의 영문 괄호 표기 패턴이 적용된다.
--
-- [절차 C] 회귀 방지 — 추후 신규 마이그에서 동일 한자어가 누락되지
--          않도록 audit 스크립트 (clinical-terminology-audit) 에 본 6쌍을
--          baseline 으로 등록할 것 (별도 작업, 본 verify 범위 외).

SELECT
  '4-B. E2E 절차 요약' AS check_label,
  '1) 추천 호출 → 2) 응답 본문에 한자어 6개 grep → 3) 0건 매치 확인' AS steps,
  '한자어가 응답에 남아있으면 캐시 무효화 (§3) 또는 마이그 057 적용 누락 확인' AS troubleshoot;


-- ============================================================
-- END OF VERIFY-057
-- ============================================================
