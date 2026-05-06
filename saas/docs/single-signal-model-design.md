# 단일 신호 모델 — outcome 기반 가중치 (마이그 054)

작성: sw-db-architect · 2026-05-06
관련 마이그: `saas/migrations/054-ratings-single-signal-model.sql`
검증: `saas/scripts/verify-054.sql`

---

## 1. 배경 — 왜 단일 신호인가

### 1.1 대표님 결정 (2026-05-06)

> "임상 현장에서 정확성(indication_accuracy)과 효과(outcome)를 분리해 묻는 것은
> 인지적으로 부담일 뿐 아니라 답이 동치(同値)에 가깝다. 환자가 좋아졌으면
> 그게 정답이다. 별점은 만족도 평가에 가깝지 효과 평가가 아니다."

### 1.2 기존 050b 공식의 문제

마이그 050b 공식 (구):
```
weight =
    (avg_star_rating / 5)            × 0.20   ← 별점 (만족도)
  + (avg_indication_accuracy / 5)    × 0.30   ← 적응증 정확도
  + (LEAST(recent_30d, 20) / 20)     × 0.20   ← 활성도
  + (excellent_good_ratio)           × 0.30   ← 효과 분류
```

발견된 이슈:
- **중복 신호**: indication_accuracy 와 outcome 은 임상적으로 동일한 질문 — 적응증이 맞으면 효과가 좋다. 두 신호를 별도 가중치로 합치면 사실상 outcome 신호의 중복 카운트.
- **별점의 의미 모호**: star_rating 은 만족도(서비스 경험) 와 효과(임상 결과) 가 섞임. 별점 4점이 "고객 응대가 좋았다" 인지 "환자가 정말 좋아졌다" 인지 분리 불가.
- **UI 부하**: 인라인 평가 UI 에서 별점·outcome·indication_accuracy 3종을 묻는 것은 1세션 흐름 중 인지 비용 과다.
- **adverse 처리 부족**: 050b 는 adverse 를 단순히 excellent_good 비율 분모에 포함 — 부작용 발생을 명시적 페널티로 다루지 않음.

---

## 2. 새 데이터 모델

### 2.1 단일 핵심 신호 = `ratings.outcome`

```
rating_outcome ENUM (마이그 049):
  excellent  -- 매우 효과적
  good       -- 효과적
  moderate   -- 보통
  poor       -- 효과 미미
  no_effect  -- 효과 없음
  adverse    -- 부작용 발생
```

이 6분류가 **단일 임상 신호**. UI 는 6개 옵션 중 하나만 받으면 됨.

### 2.2 보존되는 컬럼 (역사 데이터)

| 컬럼 | 상태 | 사유 |
|---|---|---|
| `ratings.star_rating` | NULL 허용 + DEPRECATED 코멘트 | 마이그 041 부터의 역사 데이터 (별점만 받았던 시기). 분석/회고용 보존. CHECK (1~5) 유지. |
| `ratings.indication_accuracy` | NULL 허용 + DEPRECATED 코멘트 | 049~053 기간 수집 데이터. AI 추천 정확도 회고용. |
| `technique_stats.avg_star_rating` | DEFAULT 0 + 갱신 중단 | 함수에서 더 이상 UPDATE 안 함. 기존 값은 그대로 보존. |
| `technique_stats.avg_indication_accuracy` | 동일 | 동일 |

### 2.3 신규 INSERT 권장

| 필드 | 신규 권장값 |
|---|---|
| `outcome` | **필수** (rating_outcome 6분류 중 1개) |
| `star_rating` | NULL (보내지 않음) |
| `indication_accuracy` | NULL (보내지 않음) |
| `was_ai_recommended` | true/false |

기존 컬럼들은 NULLABLE 이므로 백엔드 API 가 NULL 로 명시적 INSERT 해도 안전.

---

## 3. 가중치 공식 (70/20/10)

### 3.1 새 공식

```
let outcome_n = COUNT(*) WHERE outcome IS NOT NULL
let eg_count  = COUNT(*) WHERE outcome IN ('excellent','good')
let adv_count = COUNT(*) WHERE outcome = 'adverse'
let recent_30 = COUNT(*) WHERE created_at ≥ NOW() - 30 days

outcome_ratio   = COALESCE(eg_count  / NULLIF(outcome_n, 0), 0.5)
adverse_ratio   = COALESCE(adv_count / NULLIF(outcome_n, 0), 0.0)
activity_score  = LEAST(recent_30, 20) / 20.0
adverse_penalty = 1.0 - adverse_ratio

weight = CLAMP(
    outcome_ratio   × 0.70   +
    activity_score  × 0.20   +
    adverse_penalty × 0.10
, 0.0, 1.0)
```

### 3.2 직관 설명

| 컴포넌트 | 비중 | 의도 |
|---|---|---|
| outcome ratio | 70% | "환자가 좋아졌나" — 단일 핵심 신호. excellent+good 비율. |
| activity score | 20% | "최근에 임상가가 실제로 쓰고 있나" — 활성도. 최근 30일 사용 ≥ 20건이면 만점. |
| adverse penalty | 10% | "부작용 신호 없나" — adverse 비율이 0이면 만점, 1이면 0. |

분리한 이유:
- **outcome ratio** 와 **adverse penalty** 를 분리해야 "효과는 좋지만 부작용도 있는" 케이스를 적절히 페널티 가능. 합치면 adverse 가 단순히 분자에서 빠질 뿐 — 명시적 페널티 안 됨.
- **activity score** 보존: 신규 평가 데이터가 없으면 신뢰도 낮음 — 활성도 가중으로 보완.

### 3.3 outcome 0건 시 동작

`outcome_n = 0` (트리거 발화 시점에 모든 ratings 가 outcome NULL):
- `outcome_ratio = 0.5` (중립)
- `adverse_ratio = 0.0` → `adverse_penalty = 1.0`
- 결과: `weight = 0.5×0.7 + activity×0.2 + 1.0×0.1 = 0.45 + activity×0.2`
  - activity 0 → **0.45** (보수적 중립)
  - activity 만점 → 0.65

050b 의 무평가 시 0.5~0.7 대비 **0.45 시작 — 약간 보수적**. outcome 데이터 누적 전 신중한 추천을 위함.

### 3.4 weight 범위 보장

`LEAST(1.0, GREATEST(0.0, ...))` CLAMP 절로 [0.0, 1.0] 강제. 입력값이 모두 [0,1] 범위이므로 이론적으로 합도 [0,1] 이지만 부동소수점 오차 방지용 가드.

---

## 4. 마이그 050b → 054 전환 영향

### 4.1 기존 데이터 weight 분포 변화 (예상)

가정: 평균적인 기법이 outcome 미입력 다수, 별점 평균 4.0, indication_accuracy 평균 3.5 보유.

| 시나리오 | 050b weight | 054 weight | 변화 |
|---|---|---|---|
| outcome 0건 + 별점 4.0 평균 + 활성도 50% | 0.20×4/5 + 0.30×3.5/5 + 0.20×0.5 + 0.30×0.5 = 0.16+0.21+0.10+0.15 = **0.62** | 0.5×0.7 + 0.5×0.2 + 1.0×0.1 = 0.35+0.10+0.10 = **0.55** | -0.07 |
| outcome 80% excellent+good, 활성도 100%, adverse 0 | 0.20×4/5 + 0.30×3.5/5 + 0.20×1.0 + 0.30×0.8 = **0.81** | 0.8×0.7 + 1.0×0.2 + 1.0×0.1 = **0.86** | +0.05 |
| outcome 30% excellent+good, adverse 20% | (별점/적응증 평균이라 가정) ≈ 0.51 | 0.3×0.7 + activity×0.2 + 0.8×0.1 = 0.21 + 0.2×activity + 0.08 ≈ **0.39** | -0.12 (adverse 페널티 강화) |

**예상 변화 방향**:
- outcome 데이터가 충분한 좋은 기법 → 가중치 약간 상승 (별점 가중 빠지고 outcome 70% 집중).
- adverse 비율 높은 기법 → 가중치 명확히 하락 (부작용 페널티 분리).
- outcome 미입력 기법 → 0.55 부근 (050b 의 0.62 대비 약간 보수적).

마이그 본문에서 `UPDATE technique_stats SET recommendation_weight = ...` 일괄 재계산 — 1회 실행. 이후 트리거가 신규 ratings 마다 자동 갱신.

### 4.2 Vercel API 영향

- `api/recommend.js` 가 `recommendation_weight` 컬럼 기반 정렬 → 가중치 절대값은 바뀌지만 **순위 의도는 유지** (outcome 좋은 기법이 더 위로). 회귀 위험 낮음.
- `v_techniques_with_stats` VIEW (schema.sql §VIEWS) 에 `recommendation_weight` 만 노출 — VIEW 재정의 불필요.

### 4.3 UI 영향 (별도 위임)

- **sw-frontend-dev**: 인라인 평가 UI 에서 별점·indication_accuracy 입력란 제거, outcome 6분류만 표시. 마이그 054 적용 후 PR 별도 진행.
- **sw-backend-dev**: `api/feedback.js` 가 `star_rating` 을 NULL 로 INSERT 가능하도록 가드 수정 — 기존 `if (!rating) return 400` 패턴이 있다면 outcome 기반 가드로 전환 필요.

---

## 5. 마이그 멱등성 / 안전성

| 항목 | 보장 방식 |
|---|---|
| `ALTER COLUMN ... DROP NOT NULL` | DO 블록에서 `is_nullable = 'NO'` 가드 후 실행 — 재실행 시 no-op. |
| `CREATE OR REPLACE FUNCTION` | 표준 멱등 패턴. |
| `UPDATE technique_stats ... recommendation_weight` | 동일 입력 → 동일 결과, 멱등. |
| `COMMENT ON COLUMN` | 항상 덮어쓰기, 멱등. |
| 트리거 자체 | 마이그 050 등록분 그대로 — 본 마이그는 함수 본문만 교체. |
| 데이터 손실 | 없음. star_rating 컬럼 보존, 모든 기존 ratings 행 무손상. |

---

## 6. 검증 (verify-054.sql)

7개 항목:
1. ratings.star_rating is_nullable = 'YES'
2. fn_refresh_technique_stats SECURITY DEFINER 함수 존재
3. 함수 본문에 새 가중치 패턴 (`outcome IS NOT NULL`, `0.70`, `0.20`, `0.10`, `adverse`) 포함
4. technique_stats.recommendation_weight ∈ [0.0, 1.0]
5. (INFO) weight 분포 통계 (050b 와 비교용)
6. ratings.star_rating COMMENT 'DEPRECATED' 포함
7. (E2E) BEGIN/ROLLBACK — `star_rating=NULL, outcome='good'` INSERT 시 트리거가 weight 정상 갱신

---

## 7. 관련 위임 / 후속 작업

| 팀 | 작업 |
|---|---|
| sw-backend-dev | `api/feedback.js`: star_rating NULL 허용, outcome 필수 가드 전환. |
| sw-frontend-dev | 인라인 평가 UI 에서 별점·indication_accuracy 입력란 제거, outcome 6분류 단일화. |
| sw-qa-tester | 마이그 054 적용 후 추천 결과 회귀 테스트 (가중치 분포 변화 vs 추천 순위 안정성). |
| sw-product-manager | DEPRECATED 컬럼 (star_rating, indication_accuracy) 의 향후 DROP 시점 검토 — 최소 6개월 후. |

---

## 8. KMO 철학 정합성

- "통증 ≠ 손상 / 반파국화" — outcome 신호는 환자의 실제 회복을 직접 측정 (별점이 아니라).
- "Calm things down, and build things back up." — adverse 페널티를 분리해 "해를 끼치지 않는 추천" 우선시.
- 두려움 유발 표현 없음 — 컬럼/함수 코멘트 모두 임상적 근거 기반.
