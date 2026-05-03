-- ============================================================
-- 한 방에 보는 검증 — production 에서 실제 별점 INSERT 후 1초 점검
-- ============================================================
-- 사용 시나리오:
--   1. production 앱에서 추천 → 별점 + outcome + accuracy + 메모 입력 후 저장
--   2. Supabase SQL 에디터에서 본 파일 전체 복사 → Run
--   3. 4개 결과 표가 순서대로 나옴:
--      [1] 가장 최근 ratings 1건 (방금 저장한 데이터 확인)
--      [2] 그 기법의 technique_stats (트리거 발화 결과)
--      [3] 자동 검증 — pass/fail 표시 (8개 체크포인트)
--      [4] technique_stats 의 recommendation_weight 변화 추이 (최근 갱신 5개 기법)
--
-- 안전성: 모든 쿼리 SELECT only — 데이터 변경 0.
-- 실행 시점: 049/050/050b 적용 + Vercel 최신 배포 + 별점 1회 저장 직후.
-- ============================================================


-- ============================================================
-- [1] 가장 최근 ratings 1건 — 방금 저장한 데이터
-- ============================================================
SELECT
  '[1] latest rating' AS check_name,
  r.id::TEXT                          AS rating_id,
  r.user_id::TEXT                     AS user_id,
  r.technique_id::TEXT                AS technique_id,
  r.technique_label                   AS technique_name,
  r.star_rating                       AS star,
  r.outcome::TEXT                     AS outcome,
  r.indication_accuracy               AS accuracy,
  r.was_ai_recommended                AS was_ai,
  COALESCE(r.notes, '(no notes)')     AS notes,
  r.region, r.acuity, r.symptom,
  r.created_at::TEXT                  AS saved_at,
  AGE(NOW(), r.created_at)            AS time_ago
FROM ratings r
ORDER BY r.created_at DESC
LIMIT 1;


-- ============================================================
-- [2] 그 기법의 technique_stats — 트리거 발화 결과
-- ============================================================
SELECT
  '[2] technique_stats after trigger' AS check_name,
  t.name_ko                           AS technique_name,
  s.total_ratings                     AS total,
  s.avg_star_rating                   AS avg_star,
  s.excellent_count                   AS excellent,
  s.good_count                        AS good,
  s.moderate_count                    AS moderate,
  s.poor_count                        AS poor,
  s.no_effect_count                   AS no_effect,
  s.adverse_count                     AS adverse,
  s.ai_recommended_count              AS ai_rec_total,
  s.avg_indication_accuracy           AS avg_accuracy,
  s.recent_30d_avg_rating             AS avg_30d,
  s.recommendation_weight             AS weight,
  s.updated_at::TEXT                  AS stats_updated_at,
  AGE(NOW(), s.updated_at)            AS time_since_update
FROM technique_stats s
JOIN techniques t ON t.id = s.technique_id
WHERE s.technique_id = (SELECT technique_id FROM ratings ORDER BY created_at DESC LIMIT 1);


-- ============================================================
-- [3] 자동 검증 — 8개 체크포인트 PASS/FAIL
-- ============================================================
WITH r AS (
  SELECT * FROM ratings ORDER BY created_at DESC LIMIT 1
), s AS (
  SELECT * FROM technique_stats WHERE technique_id = (SELECT technique_id FROM r)
), now_diff AS (
  SELECT
    EXTRACT(EPOCH FROM (NOW() - (SELECT created_at FROM r))) AS rating_age_sec,
    EXTRACT(EPOCH FROM (NOW() - (SELECT updated_at FROM s))) AS stats_age_sec
)
SELECT '[3] verification' AS check_name, label, status, detail FROM (
  SELECT 1 AS ord, 'rating saved within 5min'              AS label,
    CASE WHEN (SELECT rating_age_sec FROM now_diff) < 300 THEN '✅ PASS' ELSE '⚠️  STALE' END AS status,
    CONCAT(ROUND((SELECT rating_age_sec FROM now_diff)::NUMERIC, 0)::TEXT, ' sec ago') AS detail
  UNION ALL
  SELECT 2, 'star_rating in [1,5]',
    CASE WHEN (SELECT star_rating FROM r) BETWEEN 1 AND 5 THEN '✅ PASS' ELSE '❌ FAIL' END,
    'star = ' || (SELECT star_rating FROM r)::TEXT
  UNION ALL
  SELECT 3, 'was_ai_recommended = true',
    CASE WHEN (SELECT was_ai_recommended FROM r) = true THEN '✅ PASS' ELSE '❌ FAIL — feedback.js 미배포 or PR #34 미머지' END,
    'value = ' || (SELECT was_ai_recommended FROM r)::TEXT
  UNION ALL
  SELECT 4, 'technique_stats row exists',
    CASE WHEN (SELECT COUNT(*) FROM s) >= 1 THEN '✅ PASS' ELSE '❌ FAIL — 트리거 미발화' END,
    'row count = ' || (SELECT COUNT(*) FROM s)::TEXT
  UNION ALL
  SELECT 5, 'recommendation_weight is NOT NULL',
    CASE WHEN (SELECT recommendation_weight FROM s) IS NOT NULL THEN '✅ PASS' ELSE '❌ FAIL — 함수 오류 의심' END,
    'weight = ' || COALESCE((SELECT recommendation_weight FROM s)::TEXT, 'NULL')
  UNION ALL
  SELECT 6, 'recommendation_weight in [0, 1]',
    CASE WHEN (SELECT recommendation_weight FROM s) BETWEEN 0 AND 1 THEN '✅ PASS' ELSE '⚠️  out of range' END,
    'weight = ' || COALESCE((SELECT recommendation_weight FROM s)::TEXT, 'NULL')
  UNION ALL
  SELECT 7, 'stats updated within 1min of rating',
    CASE WHEN ABS((SELECT stats_age_sec FROM now_diff) - (SELECT rating_age_sec FROM now_diff)) < 60
         THEN '✅ PASS' ELSE '⚠️  stats stale' END,
    'rating ' || ROUND((SELECT rating_age_sec FROM now_diff)::NUMERIC, 0)::TEXT
      || 's ago / stats ' || ROUND((SELECT stats_age_sec FROM now_diff)::NUMERIC, 0)::TEXT || 's ago'
  UNION ALL
  SELECT 8, 'outcome counts match (excellent+good+moderate+poor+no_effect+adverse <= total)',
    CASE WHEN (SELECT excellent_count + good_count + moderate_count + poor_count + no_effect_count + adverse_count FROM s)
              <= (SELECT total_ratings FROM s) THEN '✅ PASS' ELSE '❌ FAIL' END,
    'sum = ' || (SELECT excellent_count + good_count + moderate_count + poor_count + no_effect_count + adverse_count FROM s)::TEXT
      || ' / total = ' || (SELECT total_ratings FROM s)::TEXT
) checks
ORDER BY ord;


-- ============================================================
-- [4] 최근 갱신된 technique_stats 5개 — 트리거 활성도 추이
-- ============================================================
SELECT
  '[4] recently updated stats' AS check_name,
  t.name_ko                    AS technique_name,
  s.total_ratings              AS total,
  s.avg_star_rating            AS avg_star,
  s.recommendation_weight      AS weight,
  s.updated_at::TEXT           AS updated_at,
  AGE(NOW(), s.updated_at)     AS time_ago
FROM technique_stats s
JOIN techniques t ON t.id = s.technique_id
WHERE s.total_ratings > 0
ORDER BY s.updated_at DESC
LIMIT 5;


-- ============================================================
-- 해석 가이드
-- ============================================================
-- ✅ PASS 8개 모두 → C-3 + C-4 production 정상 동작 확인
--
-- ❌ FAIL 발생 시:
--   체크 3 (was_ai_recommended): PR #34 미배포 or feedback.js 캐시 → Vercel Redeploy
--   체크 4 (technique_stats row): 050 트리거 미등록 → migration 050 재실행
--   체크 5 (weight NULL): 050b 미적용 (RLS 차단) → migration 050b 실행
--   체크 7 (stats stale): 트리거가 동기 발화 안 됨 → 함수 컴파일 에러 의심, pg_proc 확인
--   체크 8 (outcome counts): 함수 본체 버그 → 050b 본체 점검
--
-- ⚠️ STALE 발생 시: 별점 INSERT 시점이 너무 오래됨 → 새로 별점 1회 저장 후 본 스크립트 재실행
