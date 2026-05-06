# not_used 추적 — outcome 7번째 분류 (마이그 055)

작성: sw-db-architect · 2026-05-06
관련 마이그: `saas/migrations/055-outcome-not-used.sql`
검증: `saas/scripts/verify-055.sql`
선행 마이그: `054-ratings-single-signal-model.sql` (단일 신호 모델 70/20/10)

---

## 1. 배경 — 왜 not_used 가 필요한가

### 1.1 대표님 결정 (2026-05-06)

> "PT 가 추천을 받았다고 다 시술하는 게 아니다. 안 쓴 케이스도 데이터다.
> 다만 안 쓴 걸 '효과 없음' 으로 카운트하면 안 된다 — 그건 다른 차원의
> 신호다. 가중치(weight) 영향은 0 으로 두고 정보만 추적해라."

### 1.2 기존 054 모델의 한계

마이그 054 의 단일 신호 모델은 6 분류 outcome 으로 effectiveness 를 측정:
```
excellent / good / moderate / poor / no_effect / adverse
```

이 6 분류는 모두 "**시술 후** 효과" 를 전제. PT 가 AI 추천을 받았으나
실제로 시술하지 않은 케이스 (예: 환자 거부, 시간 부족, 다른 기법 선택) 는
어떤 분류에도 해당하지 않는다.

기존 운영 방식: PT 가 미시술 시 평가 모달을 닫음 (skip) → ratings 행 없음
→ AI 추천 채택률(use rate) 추적 불가.

### 1.3 weight 영향 0 인 이유

not_used 를 effectiveness 신호로 섞으면 안 됨:
- "안 썼다" 는 "효과 없음" 이 아니다 — 환자 상황 / PT 판단 / 우선순위 등
  비-effectiveness 요인.
- not_used 를 분모에 포함시키면 PT 가 거부한 빈도만큼 weight 가 떨어짐
  → "PT 가 자주 거부하는 기법 = 효과 낮은 기법" 이라는 잘못된 추론.
- 거부 빈도는 별도 분석 (use rate, 채택률) 으로 다뤄야 함.

---

## 2. ENUM 변경 (6 → 7 값)

### 2.1 변경 전 (054)
```sql
CREATE TYPE rating_outcome AS ENUM (
  'excellent', 'good', 'moderate', 'poor', 'no_effect', 'adverse'
);
```

### 2.2 변경 후 (055)
```sql
ALTER TYPE rating_outcome ADD VALUE IF NOT EXISTS 'not_used';
-- 결과: 7 값 (excellent/good/moderate/poor/no_effect/adverse/not_used)
```

### 2.3 기존 데이터 영향
- 기존 ratings 행에 'not_used' 없음 (신규 값) → 무영향.
- ENUM 값 추가만으로 기존 SELECT/INSERT 쿼리 영향 없음.
- ALTER TYPE ADD VALUE IF NOT EXISTS — 멱등 (PG 12+).

---

## 3. fn_refresh_technique_stats 변경

### 3.1 핵심: 분모/분자 not_used 제외

054 공식 (effectiveness 비율):
```
excellent + good 비율 = COUNT(outcome IN ('excellent','good'))
                       / COUNT(outcome IS NOT NULL)
```

055 공식 (분모 보정):
```
excellent + good 비율 = COUNT(outcome IN ('excellent','good'))
                       / COUNT(outcome IS NOT NULL AND outcome != 'not_used')
```

분자는 변화 없음 (not_used 가 'excellent' 도 'good' 도 아니므로 자동 제외).
분모만 명시적으로 not_used 제외.

### 3.2 가중치 공식 — 054 와 동일 (70/20/10)

```
weight = CLAMP(
   (excellent+good_count / evaluated_count)         × 0.70   -- effectiveness
 + (LEAST(recent_30d_count, 20) / 20)               × 0.20   -- 활성도
 + (1 - (adverse_count / evaluated_count))           × 0.10   -- adverse penalty
, 0.0, 1.0)

evaluated_count = COUNT(outcome IS NOT NULL AND outcome != 'not_used')
```

### 3.3 활성도(20%) 처리

대표님 사양: weight 영향 0. 그러나 본 마이그는 활성도 가중치에는 not_used
를 포함시킨다. 이유:
- "활성도(activity)" 는 "최근 30 일 동안 PT 가 이 기법에 관여한 빈도".
- not_used 도 PT 가 추천 받고 의사결정한 활동 — 0 으로 카운트하면 PT 가
  명시적으로 거부한 케이스가 누락.
- effectiveness 분모만 제외하면 "효과 평가" 의 순도는 보장. 활성도는 별개.

영향 한계: 활성도 변화 폭은 LEAST(count, 20) / 20 × 0.20 → 1 행당 최대 +0.01.
not_used 가 weight 에 사실상 영향 0 으로 수렴.

### 3.4 not_used_count 컬럼 (정보 추적용)

```sql
ALTER TABLE technique_stats
  ADD COLUMN IF NOT EXISTS not_used_count INT DEFAULT 0;
```

용도:
- weight 계산에 사용 안 함 (정보 전용).
- 분석 SQL 단순화 — `SELECT name_ko, not_used_count FROM technique_stats JOIN techniques`.
- 추후 use rate (채택률) 메트릭의 분모: `not_used / (not_used + 시술된 카운트)`.

---

## 4. weight 영향 0 정책 — 한 줄 요약

> **PT 가 안 쓴 기법은 weight 가 떨어지지 않는다.** effectiveness 분모/분자
> 어느 쪽도 not_used 를 포함하지 않아, 단지 "효과 평가가 0 건 늘었다"
> 외에 변화가 없다. 활성도에는 카운트되지만 1 행당 최대 +0.01 미세.

---

## 5. 추후 분석 용도

### 5.1 Use rate (추천 채택률)
```sql
SELECT
  t.name_ko,
  ts.not_used_count,
  ts.total_ratings,
  ROUND(
    1.0 - ts.not_used_count::numeric / NULLIF(ts.total_ratings, 0),
    2
  ) AS use_rate
FROM technique_stats ts
JOIN techniques t ON t.id = ts.technique_id
WHERE ts.total_ratings > 0
ORDER BY use_rate ASC;
```
→ "AI 가 자주 추천했지만 PT 가 자주 거부하는" 기법 식별.
   추천 알고리즘 개선 입력.

### 5.2 PT 신뢰도 분석
```sql
SELECT
  user_id,
  COUNT(*) FILTER (WHERE outcome = 'not_used')::numeric
    / NULLIF(COUNT(*), 0) AS not_used_rate
FROM ratings
WHERE was_ai_recommended = true
GROUP BY user_id;
```
→ AI 추천 채택 패턴이 PT 별로 어떻게 다른지.

### 5.3 추천 정확도 회귀
not_used 비율이 특정 카테고리 (예: 신경계 기법) 에 편중되는지 → 카테고리별
가중치 / 추천 알고리즘 튜닝 인풋.

---

## 6. 멱등성 / 재실행 안전성

- `ALTER TYPE ADD VALUE IF NOT EXISTS` — PG 12+ 멱등.
- `CREATE OR REPLACE FUNCTION` — 멱등.
- `ALTER TABLE ADD COLUMN IF NOT EXISTS` — 멱등.
- `UPDATE technique_stats` — 동일 입력에 동일 결과.

전체 마이그 055 를 두 번 실행해도 동일한 최종 상태.

---

## 7. 향후 작업 (별도 PR)

- Frontend: pending-eval 모달에 "안 썼음" 옵션 추가 (outcome='not_used' 송신).
- Backend: ratings INSERT API 가 'not_used' 값 허용 (ENUM 자동 검증).
- Dashboard: use rate 카드 추가 (5.1 SQL 기반).
