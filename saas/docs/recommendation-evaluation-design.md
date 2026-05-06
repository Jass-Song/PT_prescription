# Recommendation Evaluation — Track C Day 0 DB 인프라 설계

**작성**: sw-db-architect
**날짜**: 2026-05-06
**대상 마이그**: `saas/migrations/051-recommendation-evaluation.sql`
**검증 SQL**: `saas/scripts/verify-051.sql`

---

## 1. 목적

Track C "평가 타이밍 재설계" 의 DB 측 전제 조건. 기존 구조의 두 가지 누락을
보완해 **다음 환자 진입 시 직전 추천 평가 모달** 노출과 **AI 피드백 루프 카드
단위 매칭** 을 가능하게 한다.

### 1.1 해결하는 문제

| #   | 문제                                                | 영향                                                                                                              |
| --- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| 1   | `recommendation_logs` 에 평가 상태 컬럼 부재        | "이 추천이 평가됐는지" 추적 불가 → pending 추천 모달 노출 로직 구현 불가                                          |
| 2   | `ratings` 에 `recommendation_log_id` FK 부재        | "어느 추천에 대한 평가인지" 매칭 불가 → 어떤 입력 조건/카드가 효과적이었는지 학습 불가 (AI 피드백 루프 미완성)     |
| 3   | 마지막 환자/휴진/외래 종료 케이스 안전망 부재       | 다음 환자 진입이 영원히 없을 수도 있어 pending 이 무한 누적 가능                                                  |

### 1.2 단일 진실 소스 (Single Source of Truth)

- **마이그 본체**: `saas/migrations/051-recommendation-evaluation.sql`
  - ENUM, 컬럼, 인덱스, RLS, 트리거, 함수, 기존 데이터 일괄 처리 모두 여기.
- **schema.sql 동기화**: 컬럼/인덱스/RLS/ENUM 만. 트리거·함수 정의는 마이그
  단독 책임 (schema.sql 비대화 방지 + 050b 패턴 준수).

---

## 2. 스키마 변경 요약

### 2.1 신규 ENUM

```sql
CREATE TYPE evaluation_status_enum AS ENUM (
  'pending',  -- 아직 평가 안 됨 (기본값)
  'rated',    -- 1개 이상 카드 평가 완료 (트리거 자동 전환)
  'expired',  -- 14일 경과 또는 5/6 이전 historical row
  'skipped'   -- 사용자가 명시적으로 스킵 (UI 측 UPDATE)
);
```

### 2.2 컬럼 추가

#### `recommendation_logs`

| 컬럼              | 타입                        | 제약                       | 비고                                          |
| ----------------- | --------------------------- | -------------------------- | --------------------------------------------- |
| evaluation_status | `evaluation_status_enum`    | NOT NULL DEFAULT 'pending' | 트리거가 첫 ratings INSERT 시 'rated' 로 전환 |
| evaluated_at      | `TIMESTAMPTZ`               | NULL                       | 평가 시점 (트리거가 NOW() 자동 기록)          |

#### `ratings`

| 컬럼                          | 타입       | 제약                                                 | 비고                                                   |
| ----------------------------- | ---------- | ---------------------------------------------------- | ------------------------------------------------------ |
| recommendation_log_id         | `UUID`     | REFERENCES recommendation_logs(id) ON DELETE SET NULL| NULL 허용 (수동 평가/historical 호환), CASCADE 금지     |
| recommended_technique_index   | `SMALLINT` | NULL                                                 | 1-based 카드 인덱스 (피드백 루프 매칭)                 |

> **CASCADE 가 아닌 SET NULL 인 이유**: log 가 삭제되어도 평가 데이터 자체는
> 가치 있음 (집계·통계용). FK 만 끊고 데이터는 보존.

### 2.3 인덱스

| 이름                          | 컬럼                                                     | 용도                                                  |
| ----------------------------- | -------------------------------------------------------- | ----------------------------------------------------- |
| idx_rec_logs_pending_user     | (user_id, evaluation_status, created_at DESC)            | 다음 환자 진입 시 pending 추천 1건 조회               |
| idx_ratings_rec_log_idx       | (recommendation_log_id, recommended_technique_index)     | partial UNIQUE WHERE 둘 다 NOT NULL — 동일 카드 중복 평가 방지 |

### 2.4 RLS

```sql
CREATE POLICY rec_logs_update_own ON recommendation_logs
  FOR UPDATE
  USING      (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

> 트리거가 SECURITY DEFINER 라 정책 우회 가능하지만, 명시적 UPDATE
> (예: skipped 전환, expire 함수) 가 본인 row 만 건드리도록 정책 추가.

---

## 3. 상태 전이 다이어그램

```
                        ┌──────────────────────────────────────┐
                        │                                      │
                        │    [recommendation_logs row 생성]    │
                        │                                      │
                        └──────────────────┬───────────────────┘
                                           │ DEFAULT
                                           ▼
                                      ┌─────────┐
                                      │ pending │
                                      └────┬────┘
                                           │
              ┌────────────────────────────┼────────────────────────────┐
              │                            │                            │
   ratings INSERT (FK match)    UI "스킵"  버튼 클릭          14일 경과
   (트리거 자동)                 (직접 UPDATE)        expire_old_pending_evaluations()
              │                            │                            │
              ▼                            ▼                            ▼
        ┌─────────┐                  ┌─────────┐                  ┌─────────┐
        │  rated  │                  │ skipped │                  │ expired │
        └─────────┘                  └─────────┘                  └─────────┘
        (terminal)                    (terminal)                    (terminal)
        evaluated_at                  evaluated_at                  evaluated_at
        = NOW()                       = NULL (or UI 결정)            = NULL
```

**전이 규칙**:

- `pending → rated`: 트리거 단독 (멱등 — 두 번째 카드 평가는 no-op)
- `pending → skipped`: UI 측 명시적 UPDATE (예: "다음에 평가" 버튼)
- `pending → expired`: `expire_old_pending_evaluations()` 호출
- `rated/skipped/expired → 무엇이든`: **전환 금지** — 트리거는 `WHERE
  evaluation_status = 'pending'` 으로 보호

---

## 4. 트리거 동작

### 4.1 함수: `update_evaluation_status_on_rating()`

- **언어**: PL/pgSQL
- **권한**: `SECURITY DEFINER` + `SET search_path = public` (마이그 050b 패턴)
- **이유**: ratings INSERT 는 user 컨텍스트 → RLS 가 다른 컬럼 UPDATE 를
  차단할 수 있음. SECURITY DEFINER 로 함수 소유자 권한 실행 → RLS 우회.
  본 트리거는 본인 log 만 매칭하므로 보안 영향 없음.

### 4.2 로직

```sql
IF NEW.recommendation_log_id IS NOT NULL THEN
  UPDATE recommendation_logs
     SET evaluation_status = 'rated',
         evaluated_at      = NOW()
   WHERE id = NEW.recommendation_log_id
     AND evaluation_status = 'pending';   -- ← 멱등성 키
END IF;
```

- `WHERE evaluation_status = 'pending'` → 두 번째 카드 평가 시 이미 `rated`
  라 UPDATE 0 row 영향. skipped/expired 도 건드리지 않음.
- 수동 평가 (`recommendation_log_id IS NULL`) 는 무시.

### 4.3 등록

```sql
CREATE TRIGGER trg_update_evaluation_on_rating
  AFTER INSERT ON ratings
  FOR EACH ROW
  EXECUTE FUNCTION update_evaluation_status_on_rating();
```

- AFTER INSERT 만 (UPDATE/DELETE 미등록 — 평가 수정·삭제는 log 상태에 영향
  없도록 설계).

---

## 5. 만료 처리 (`expire_old_pending_evaluations`)

### 5.1 함수 정의

```sql
CREATE FUNCTION expire_old_pending_evaluations()
RETURNS INTEGER -- 변경된 row 수
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE updated_count INTEGER;
BEGIN
  UPDATE recommendation_logs
     SET evaluation_status = 'expired'
   WHERE evaluation_status = 'pending'
     AND created_at < NOW() - INTERVAL '14 days';
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END $$;
```

### 5.2 호출 책임

- **마이그 051 단독에서는 함수 정의만** — 자동 호출 안 함.
- 호출 옵션 (구현 책임 = sw-frontend-dev / sw-backend-dev / sw-devops):
  1. **클라이언트 진입 시**: 사용자 로그인 직후 1회 호출. 가벼움 + 즉각.
     (권장)
  2. **Vercel cron**: 일 1회 호출. 클라이언트 진입 빈도가 낮을 때 안전망.
  3. **수동 호출**: 디버그/운영 — `SELECT expire_old_pending_evaluations();`.

---

## 6. 14일 만료 정책 의미

### 6.1 왜 14일?

- **다음 환자 진입 시 즉시 평가** 가 본 설계의 1차 메커니즘. 14일 만료는
  **마지막 환자/휴진/외래 종료** 케이스의 안전망.
- 너무 짧으면 (예: 3일): 휴가·연휴·교육 일정 상 자연스러운 평가 기회가
  소실됨.
- 너무 길면 (예: 90일): pending 누적 → "다음 환자 진입 시" 모달이 너무 오래
  된 추천을 노출 → 사용자가 기억 못 해 평가 품질 저하.
- **14일** 은 임상 현장 평균 휴진 주기 + 사용자 기억 retention 절충값.

### 6.2 만료 후 처리

- `evaluation_status = 'expired'` row 는 모달 후보에서 제외 (인덱스 partial
  필터링은 미적용 — 전체 인덱스로 충분).
- `evaluated_at` 은 NULL 유지 (만료 시점 기록 안 함). 필요 시 후속 마이그에서
  `expired_at` 컬럼 추가 가능.
- AI 피드백 루프에는 영향 없음 — `ratings.recommendation_log_id` 만 보면 됨.

---

## 7. 기존 데이터 일괄 처리 정책

### 7.1 recommendation_logs

```sql
UPDATE recommendation_logs
   SET evaluation_status = 'expired'
 WHERE evaluation_status = 'pending'
   AND created_at < '2026-05-06'::TIMESTAMPTZ;
```

- 베타 출시일 (2026-05-05) 이전 추천 = 평가 매칭 의미 없음.
- 5/6 (현재 시점) 이후 신규 추천만 `pending` 기본값으로 진입.
- **멱등**: `WHERE ... = 'pending'` 가드로 재실행 안전.

### 7.2 ratings

- `ALTER TABLE ratings ADD COLUMN recommendation_log_id UUID` 의 NULL 기본값
  → 기존 row 모두 NULL.
- 소급 매칭 불가. 베타 출시 전 평가는 history 가치만 갖고 AI 피드백 루프에서
  제외됨.

---

## 8. 결정 사항 (Open Questions 정리)

### 8.1 "log 단위 status vs 카드 단위 status"

- **결정**: log 단위.
- **이유**:
  1. 한 추천 (log) 은 보통 5~6 개 카드를 포함. 모든 카드 평가 강제 시 UX
     마찰 큼.
  2. 첫 카드 평가 시점에 `evaluation_status = 'rated'` 전환 → "평가 시작
     했음" 시그널로 충분.
  3. 카드 단위 평가 여부는 `ratings` row 존재 여부 + `recommended_technique_index` 로 추적 가능. 별도 컬럼 불필요.
  4. UI 는 "스킵 버튼" 으로 부분 평가 종료 허용.

### 8.2 RLS 정책 — UPDATE 추가 vs 생략

- **결정**: 추가 (`rec_logs_update_own`).
- **이유**: 트리거 SECURITY DEFINER 가 RLS 우회하지만, 클라이언트가 직접
  UPDATE (예: skipped 전환) 시 본인 row 만 변경하도록 정책 보호 필요.

### 8.3 `recommended_technique_index` — 1-based vs 0-based

- **결정**: 1-based.
- **이유**: 클라이언트 UI/UX 가 사용자에게 "1번 추천", "2번 추천" 으로 노출.
  DB 인덱스도 일치시켜 디버깅·로그 분석 시 mental load 감소.

### 8.4 partial UNIQUE 인덱스

- **결정**: 적용. `(recommendation_log_id, recommended_technique_index)
  WHERE 둘 다 NOT NULL`.
- **이유**: 동일 (log, card) 에 중복 평가 방지. NULL 케이스 (수동 평가 /
  historical) 는 제외 — 무수히 많을 수 있음.

---

## 9. 검증 (verify-051.sql)

총 11 항목 + 1 E2E 트리거 동작 테스트 (BEGIN ... ROLLBACK).

상세는 `saas/scripts/verify-051.sql` 헤더 참조.

---

## 10. 관련 마이그

- **의존**: 017 (recommendation_logs), 041 (ratings), 049/049c (ratings 컬럼),
  050b (트리거 SECURITY DEFINER 패턴).
- **후속 트랙**: Track C UI/API (sw-frontend-dev / sw-backend-dev) — pending
  log 조회 API + 평가 모달 + skipped 전환 + expire 함수 호출 책임.

---

## 11. 변경 이력

| 날짜       | 작성자             | 변경                  |
| ---------- | ------------------ | --------------------- |
| 2026-05-06 | sw-db-architect    | 최초 작성 (마이그 051) |
