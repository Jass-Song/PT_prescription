<!-- owner: sw-db-architect -->
# PT 처방 도우미 — 베타 운영 분석 SQL 쿼리 모음

**작성일**: 2026-05-03
**대상**: Supabase SQL 에디터 (service_role 컨텍스트)
**기반**: Notion "Outcome measure" 5개 카테고리 + ratings/technique_stats/recommendation_logs/session_logs 스키마

> 베타 출시 (5/5) 직후부터 매일·매주 돌리는 모니터링 쿼리. Supabase 대시보드 SQL 에디터에 그대로 붙여넣고 Run.

---

## 1. 기술 성능 (Technical Performance)

### 1-1. API 응답 시간 P50 / P95 (recommend.js latency_ms 활용)

```sql
SELECT
  date_trunc('day', created_at)                                  AS day,
  COUNT(*)                                                       AS req_count,
  ROUND(percentile_cont(0.50) WITHIN GROUP (ORDER BY latency_ms)::NUMERIC, 0) AS p50_ms,
  ROUND(percentile_cont(0.95) WITHIN GROUP (ORDER BY latency_ms)::NUMERIC, 0) AS p95_ms,
  MAX(latency_ms)                                                AS max_ms
FROM recommendation_logs
WHERE created_at >= NOW() - INTERVAL '7 days'
  AND latency_ms IS NOT NULL
GROUP BY day
ORDER BY day DESC;
-- 목표: P50 < 3000ms, P95 < 8000ms
```

### 1-2. 일일 에러율 (error_logs)

```sql
SELECT
  date_trunc('day', created_at) AS day,
  source,
  COUNT(*)                       AS error_count,
  COUNT(DISTINCT user_id)        AS affected_users,
  COUNT(DISTINCT request_path)   AS endpoints
FROM error_logs
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY day, source
ORDER BY day DESC, error_count DESC;
```

### 1-3. 429 한도 소진율

```sql
SELECT
  date_trunc('day', created_at)                              AS day,
  COUNT(*) FILTER (WHERE http_status = 429)                  AS limit_hits,
  COUNT(*)                                                   AS total_errors,
  ROUND(100.0 * COUNT(*) FILTER (WHERE http_status = 429) / NULLIF(COUNT(*), 0), 1) AS pct
FROM error_logs
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY day
ORDER BY day DESC;
-- 목표: 일일 한도 소진율 < 30%
```

---

## 2. 사용자 참여 (Engagement)

### 2-1. DAU / WAU

```sql
-- DAU: 최근 7일 일자별
SELECT
  date_trunc('day', created_at) AS day,
  COUNT(DISTINCT user_id)        AS dau
FROM recommendation_logs
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY day
ORDER BY day DESC;

-- WAU: 지난 7일 합산
SELECT COUNT(DISTINCT user_id) AS wau
FROM recommendation_logs
WHERE created_at >= NOW() - INTERVAL '7 days';
```

### 2-2. 세션당 추천 요청 수 분포

```sql
SELECT
  date_trunc('day', created_at) AS day,
  user_id,
  COUNT(*)                       AS requests_per_day
FROM recommendation_logs
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY day, user_id
ORDER BY day DESC, requests_per_day DESC;
-- 정상 패턴: 사용자당 2~5회/일
```

### 2-3. 7일 재방문율 (간이)

```sql
WITH first_use AS (
  SELECT user_id, MIN(created_at) AS first_seen
  FROM recommendation_logs
  GROUP BY user_id
),
returned AS (
  SELECT DISTINCT rl.user_id
  FROM recommendation_logs rl
  JOIN first_use fu ON fu.user_id = rl.user_id
  WHERE rl.created_at > fu.first_seen + INTERVAL '1 day'
    AND rl.created_at <= fu.first_seen + INTERVAL '7 days'
)
SELECT
  (SELECT COUNT(*) FROM first_use)                                  AS new_users,
  (SELECT COUNT(*) FROM returned)                                   AS returned_users,
  ROUND(100.0 * (SELECT COUNT(*) FROM returned)
              / NULLIF((SELECT COUNT(*) FROM first_use), 0), 1)     AS return_rate_pct;
-- 목표: > 50%
```

### 2-4. 피드백 제출률

```sql
SELECT
  date_trunc('day', rl.created_at) AS day,
  COUNT(*)                          AS recommend_requests,
  COUNT(DISTINCT r.id)              AS rating_submissions,
  ROUND(100.0 * COUNT(DISTINCT r.id) / NULLIF(COUNT(*), 0), 1) AS submit_rate_pct
FROM recommendation_logs rl
LEFT JOIN ratings r ON r.user_id = rl.user_id
                   AND r.created_at >= rl.created_at
                   AND r.created_at <  rl.created_at + INTERVAL '24 hours'
WHERE rl.created_at >= NOW() - INTERVAL '7 days'
GROUP BY day
ORDER BY day DESC;
-- 목표: 추천 대비 별점 제출률 > 20%
```

---

## 3. 추천 품질 (Recommendation Quality)

### 3-1. 전체 평균 별점 + 분포

```sql
SELECT
  COUNT(*)                                                    AS total_ratings,
  ROUND(AVG(star_rating)::NUMERIC, 2)                         AS avg_star,
  COUNT(*) FILTER (WHERE star_rating <= 2)                    AS unsatisfied,
  ROUND(100.0 * COUNT(*) FILTER (WHERE star_rating <= 2) / COUNT(*), 1) AS unsatisfied_pct,
  COUNT(*) FILTER (WHERE star_rating = 5)                     AS five_star,
  COUNT(*) FILTER (WHERE outcome = 'excellent')               AS outcome_excellent,
  COUNT(*) FILTER (WHERE outcome = 'adverse')                 AS outcome_adverse
FROM ratings
WHERE created_at >= NOW() - INTERVAL '30 days';
-- 목표: avg_star > 3.5, unsatisfied_pct < 10%
```

### 3-2. 평점 하위 20% 기법 (개선 우선순위)

```sql
SELECT
  t.name_ko,
  t.category::TEXT,
  s.total_ratings,
  s.avg_star_rating,
  s.recommendation_weight,
  s.adverse_count
FROM technique_stats s
JOIN techniques t ON t.id = s.technique_id
WHERE s.total_ratings >= 5  -- 신뢰 가능한 표본
ORDER BY s.avg_star_rating ASC, s.adverse_count DESC
LIMIT 20;
-- → sw-clinical-translator 개선 큐로 전달
```

### 3-3. AI 추천 적합도 (indication_accuracy)

```sql
SELECT
  region,
  acuity,
  symptom,
  COUNT(*)                                                          AS samples,
  ROUND(AVG(indication_accuracy) FILTER (WHERE indication_accuracy IS NOT NULL)::NUMERIC, 2) AS avg_accuracy,
  COUNT(*) FILTER (WHERE indication_accuracy >= 4)                  AS positive,
  COUNT(*) FILTER (WHERE indication_accuracy <= 2)                  AS negative
FROM ratings
WHERE was_ai_recommended = true
  AND indication_accuracy IS NOT NULL
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY region, acuity, symptom
ORDER BY samples DESC;
-- AI 추천 정확도가 낮은 시나리오 = recommend.js CONDITION_CATEGORY_SCORES 재조정 후보
```

### 3-4. recommendation_weight 갱신 작동 확인

```sql
SELECT
  t.name_ko,
  s.total_ratings,
  s.avg_star_rating,
  s.recommendation_weight,
  s.updated_at,
  AGE(NOW(), s.updated_at) AS time_since_update
FROM technique_stats s
JOIN techniques t ON t.id = s.technique_id
WHERE s.total_ratings > 0
ORDER BY s.updated_at DESC
LIMIT 30;
-- 트리거가 정상 발화하면 ratings INSERT 직후 updated_at 이 갱신돼야 함
```

---

## 4. 임상 유효성 (Clinical Utility)

### 4-1. 부위별 요청 분포

```sql
SELECT
  region,
  COUNT(*)                                AS requests,
  COUNT(DISTINCT user_id)                 AS unique_users,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM recommendation_logs
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY region
ORDER BY requests DESC;
```

### 4-2. Acuity × Symptom 조합 분포

```sql
SELECT
  acuity,
  symptom,
  COUNT(*)                                AS requests,
  COUNT(DISTINCT user_id)                 AS unique_users
FROM recommendation_logs
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY acuity, symptom
ORDER BY requests DESC;
-- 9-시나리오 중 어느 케이스가 가장 자주 발생하는지
```

### 4-3. 카테고리별 추천 빈도 (실제 사용)

```sql
SELECT
  jsonb_array_elements(recommended_techniques)->>'category_key' AS category,
  COUNT(*)                                                       AS recommended_count
FROM recommendation_logs
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY category
ORDER BY recommended_count DESC;
```

### 4-4. 부위 × 카테고리 매트릭스 (어디에 어떤 카테고리가 많이 추천되는지)

```sql
SELECT
  rl.region,
  jsonb_array_elements(rl.recommended_techniques)->>'category_key' AS category,
  COUNT(*) AS cnt
FROM recommendation_logs rl
WHERE rl.created_at >= NOW() - INTERVAL '30 days'
GROUP BY rl.region, category
ORDER BY rl.region, cnt DESC;
```

---

## 5. 성장 (Growth)

### 5-1. 일일 한도 소진율 (사용자당)

```sql
SELECT
  user_id,
  date_trunc('day', created_at) AS day,
  COUNT(*)                       AS daily_uses,
  CASE WHEN COUNT(*) >= 20 THEN 'limit_reached' ELSE 'within_limit' END AS status
FROM recommendation_logs
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY user_id, day
ORDER BY day DESC, daily_uses DESC;
-- 한도 도달 사용자가 많으면 → 한도 상향 검토
```

### 5-2. 신규 사용자 (일자별)

```sql
WITH first_use AS (
  SELECT user_id, MIN(created_at) AS first_seen
  FROM recommendation_logs
  GROUP BY user_id
)
SELECT
  date_trunc('day', first_seen) AS day,
  COUNT(*)                       AS new_users
FROM first_use
WHERE first_seen >= NOW() - INTERVAL '14 days'
GROUP BY day
ORDER BY day DESC;
```

### 5-3. 사용자별 누적 사용 (Top 10)

```sql
SELECT
  user_id,
  COUNT(*) AS total_requests,
  MIN(created_at)::DATE AS first_use,
  MAX(created_at)::DATE AS last_use,
  COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '7 days') AS last_7d
FROM recommendation_logs
GROUP BY user_id
ORDER BY total_requests DESC
LIMIT 10;
-- 헤비유저 식별 → 인터뷰 후보
```

---

## 6. 운영 모니터링 (매일 5분)

```sql
-- 한 번에 보는 어제 요약
WITH y AS (
  SELECT NOW() - INTERVAL '24 hours' AS since
)
SELECT 'requests'    AS metric, COUNT(*)::TEXT AS value FROM recommendation_logs, y WHERE created_at >= y.since
UNION ALL
SELECT 'unique_users',          COUNT(DISTINCT user_id)::TEXT FROM recommendation_logs, y WHERE created_at >= y.since
UNION ALL
SELECT 'errors',                COUNT(*)::TEXT FROM error_logs, y WHERE created_at >= y.since
UNION ALL
SELECT 'ratings',               COUNT(*)::TEXT FROM ratings, y WHERE created_at >= y.since
UNION ALL
SELECT 'avg_star',              ROUND(AVG(star_rating)::NUMERIC, 2)::TEXT FROM ratings, y WHERE created_at >= y.since
UNION ALL
SELECT 'avg_latency_ms',        ROUND(AVG(latency_ms)::NUMERIC, 0)::TEXT FROM recommendation_logs, y WHERE created_at >= y.since;
```

---

## 7. 추후 추가 후보 (NEXT-2 client_events 적용 후)

> Migration 052 (NEXT-2) 가 적용되면 아래 카테고리 추가 가능

- card_expand 클릭률 (자세히 보기)
- card_feedback_click → star_rating_submit 전환율
- session_start → 첫 추천까지 소요 시간
- pillar_select 분포 (어느 pillar 조합이 가장 자주)
- refresh_category 호출률 (만족도 proxy)

---

## 8. 사용 팁

- **service_role 컨텍스트 필수** — Supabase SQL 에디터 기본값. 프론트에서 anon key 로 호출하면 RLS 로 차단됨.
- **인덱스 활용**:
  - `recommendation_logs(user_id, created_at DESC)` — DAU/WAU 빠름
  - `ratings(user_id, star_rating DESC)` — 평점 조회 빠름
  - `technique_stats(recommendation_weight DESC)` — AI 추천 정렬 빠름
- **샘플 크기 주의** — 베타 초기엔 표본 < 5건이면 통계적 의미 없음. WHERE 절에 `total_ratings >= 5` 같은 조건 활용.
- **재현 가능성** — 매주 동일 쿼리 돌려서 시계열로 비교. 결과를 `saas/docs/weekly-reports/YYYY-WWW.md` 같은 파일로 백업 권장.
