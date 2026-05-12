# 055 (a/b) Production 적용 가이드 — 대표님 직접 실행용

> 🚀 **빠른 실행 (SQL 에디터 옆 띄우기용)**: `saas/docs/055-cheatsheet-2026-05-12.md` 참조 (한 페이지 TL;DR — SQL 블록 7개 + 결정 트리 + 비상 안내). 본 풀 가이드는 상세 디버깅 / FAQ / 롤백 검토 시 참조.

**작성일**: 2026-05-12
**작성자**: sw-db-architect
**대상**: 대표님 (Supabase SQL 에디터에서 직접 실행)
**예상 소요 시간**: 5 ~ 10 분 (6값 케이스 기준, full apply + verify)

---

## 0. 한눈에 보기 — 결정 트리

```
                ┌──────────────────────────────┐
                │  Step 1: pg_enum 카운트 조회  │
                │   (verify-055 §1 단독)        │
                └──────────────┬───────────────┘
                               │
            ┌──────────────────┼──────────────────┐
            │                  │                  │
        ┌───▼────┐         ┌───▼────┐         ┌───▼────┐
        │ 7 값    │         │ 6 값    │         │ 그 외   │
        │ (적용됨)│         │ (미적용)│         │(이상)  │
        └───┬────┘         └───┬────┘         └───┬────┘
            │                  │                  │
            ▼                  ▼                  ▼
       Step 2A            Step 2B           Step 2D
       verify §2~6        055a → 055b        조사 후
       전 항목 PASS       → verify §1~6      Jarvis 보고
       확인               전 항목 PASS
            │                  │
            └──────┬───────────┘
                   │
        §2~6 중 일부 FAIL 시
                   ▼
              Step 2C
              055b 단독 재실행
              → verify §2~6
```

**핵심 원칙 3가지**:

1. **055a 와 055b 는 절대 같은 쿼리 창에서 실행하지 말 것** (PG `55P04 — unsafe use of new enum value` 에러).
2. **각 SQL 블록을 새 쿼리 창에 복사 → Run 클릭 → 다음 블록은 또 새 쿼리 창** 패턴 준수.
3. **다운타임 0** — 모든 변경은 metadata-only (`ALTER TYPE ADD VALUE` / `ADD COLUMN IF NOT EXISTS` / `CREATE OR REPLACE FUNCTION`) + non-blocking UPDATE. 운영 중 실행해도 무방.

---

## 1. 사전 점검

### 1.1 Supabase SQL 에디터 접근

1. Supabase 대시보드 → **PT Prescription** 프로젝트.
2. 좌측 메뉴 → **SQL Editor**.
3. 우상단 **New query** 버튼으로 새 쿼리 창 생성 가능 (이후 단계마다 사용).

### 1.2 본 가이드와 함께 열어둘 파일 (참조용)

저장소에서 다음 파일을 미리 열어두시면 복붙이 빠릅니다:

- `saas/migrations/055a-outcome-not-used-enum.sql` (53 줄)
- `saas/migrations/055b-outcome-not-used-stats.sql` (196 줄)
- `saas/scripts/verify-055.sql` (296 줄)

본 가이드의 SQL 블록은 위 파일들에서 그대로 복사한 내용입니다. 본 가이드만 보고 진행해도 무방하나, 차이가 발견되면 **원본 파일이 우선** 입니다.

### 1.3 안전망

- 모든 변경은 **멱등** (재실행해도 동일 결과). 중간에 실패해도 같은 블록 다시 실행 가능.
- production 데이터 손실 가능성 0 (DROP 이나 DELETE 없음).
- 트랜잭션 단위로 변경되므로 중간 실패 시 자동 롤백.

---

## Step 1. 현재 상태 진단 — `pg_enum` 카운트

**목적**: production DB 의 `rating_outcome` ENUM 이 6값(055 미적용)인지 7값(055 적용 완료)인지 확인.

**실행 방법**: 새 쿼리 창에 아래 SQL 블록 전체를 복사하고 Run.

```sql
-- Step 1: rating_outcome ENUM 현재 값 카운트
-- 기대 결과:
--   - 6 → 055 미적용 (Step 2B 진행)
--   - 7 → 055 적용 완료 (Step 2A 진행)

SELECT
  '1. rating_outcome ENUM 7 값 + not_used' AS check_label,
  CASE
    WHEN COUNT(*) >= 7
     AND bool_or(enumlabel = 'not_used')
     AND bool_or(enumlabel = 'excellent')
     AND bool_or(enumlabel = 'good')
     AND bool_or(enumlabel = 'moderate')
     AND bool_or(enumlabel = 'poor')
     AND bool_or(enumlabel = 'no_effect')
     AND bool_or(enumlabel = 'adverse')
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  COUNT(*)                          AS value_count,
  array_agg(enumlabel ORDER BY enumsortorder) AS enum_values
FROM   pg_enum
WHERE  enumtypid = 'rating_outcome'::regtype;
```

### 예상 결과 분기

| `value_count` | `result` | `enum_values` 에 `not_used` 포함? | 다음 단계 |
|---|---|---|---|
| 7 | PASS | YES | **Step 2A** (검증만 — §2~6) |
| 6 | FAIL | NO | **Step 2B** (055a → 055b → verify §1~6) |
| 그 외 (5 / 8+) | FAIL | — | **Step 2D** (이상 상태 — 작업 중단, Jarvis 보고) |

### 실패 시 대처

- 쿼리 자체가 에러: `rating_outcome` ENUM 자체가 없을 수 있음. 마이그 054 미적용 가능성 → **Jarvis 에 보고**.
- 결과 0 행: 동일 (ENUM 존재하지 않음).

---

## Step 2A. 7 값 케이스 — 검증만 (verify §2~6)

**전제**: Step 1 결과가 `value_count = 7` + `PASS`.

**의미**: 055a + 055b 가 어느 시점엔가 production 에 적용됐음. 함수 본문 / 컬럼 / weight 값 모두 정상인지만 확인.

**진행 순서**: 아래 §2.1 → §2.2 → §2.3 → §2.4 → §2.5 를 **각각 새 쿼리 창** 에 복사 후 Run.

### 2A.1 fn_refresh_technique_stats 함수 본문 검증 (verify §2)

```sql
-- Step 2A.1: fn_refresh_technique_stats 함수 검증
-- 기대 결과: PASS + 모든 플래그 t (true)

SELECT
  '2. fn_refresh_technique_stats — 055 본문 패턴' AS check_label,
  CASE
    WHEN function_count = 1
     AND security_definer = true
     AND has_not_used_filter = true
     AND has_not_used_count = true
     AND has_070 = true
     AND has_020 = true
     AND has_010 = true
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  function_count, security_definer,
  has_not_used_filter, has_not_used_count,
  has_070, has_020, has_010
FROM (
  SELECT
    COUNT(*)                                          AS function_count,
    bool_and(prosecdef = true)                        AS security_definer,
    bool_or(pg_get_functiondef(oid) LIKE '%outcome != ''not_used''%') AS has_not_used_filter,
    bool_or(pg_get_functiondef(oid) LIKE '%not_used_count%')          AS has_not_used_count,
    bool_or(pg_get_functiondef(oid) LIKE '%0.70%')                    AS has_070,
    bool_or(pg_get_functiondef(oid) LIKE '%0.20%')                    AS has_020,
    bool_or(pg_get_functiondef(oid) LIKE '%0.10%')                    AS has_010
  FROM pg_proc
  WHERE proname = 'fn_refresh_technique_stats'
) sub;
```

**실패 시 (FAIL)**:
- `has_not_used_filter = f` → 함수 본문에 `not_used` 필터 부재 → **Step 2C** 진행 (055b 단독 재실행).
- `has_not_used_count = f` → 동일.
- `security_definer = f` → 함수가 SECURITY DEFINER 미설정 → **Step 2C** 진행.
- `function_count = 0` → 함수 자체 부재 → 마이그 050 미적용 가능성 → **Jarvis 보고**.

### 2A.2 technique_stats.not_used_count 컬럼 검증 (verify §3)

```sql
-- Step 2A.2: not_used_count 컬럼 존재 + 타입 확인
-- 기대 결과: PASS / integer / DEFAULT 0

SELECT
  '3. technique_stats.not_used_count 컬럼' AS check_label,
  CASE
    WHEN data_type = 'integer'
     AND column_default LIKE '%0%'
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  data_type, is_nullable, column_default
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'technique_stats'
  AND  column_name  = 'not_used_count';
```

**실패 시 (FAIL)**:
- 0 행 반환 → 컬럼 자체 부재 → **Step 2C** 진행.
- `data_type != 'integer'` → 타입 이상 → **Jarvis 보고**.

### 2A.3 recommendation_weight 범위 검증 (verify §4)

```sql
-- Step 2A.3: 모든 technique_stats.recommendation_weight 가 [0, 1] 범위인지 확인
-- 기대 결과: PASS / 위반 0

SELECT
  '4. recommendation_weight 범위 [0,1]' AS check_label,
  CASE
    WHEN COUNT(*) FILTER (
      WHERE recommendation_weight IS NOT NULL
        AND (recommendation_weight < 0.0 OR recommendation_weight > 1.0)
    ) = 0
    THEN 'PASS'
    ELSE 'FAIL'
  END AS result,
  COUNT(*)                                   AS total_rows,
  COUNT(*) FILTER (WHERE recommendation_weight IS NULL) AS null_count,
  MIN(recommendation_weight)                 AS min_weight,
  MAX(recommendation_weight)                 AS max_weight
FROM   technique_stats;
```

**실패 시 (FAIL)**:
- weight 가 [0, 1] 범위 밖 → 함수 본문 버그 가능성 → **Jarvis 보고** (롤백 검토).

### 2A.4 E2E not_used INSERT 검증 (verify §5)

```sql
-- Step 2A.4: outcome='not_used' 가상 INSERT → weight 영향 0 확인
-- BEGIN/ROLLBACK 으로 실데이터 변경 없음 (의도된 예외로 자동 롤백)
-- 기대 결과: NOTICE '5. E2E not_used: PASS — ...'

DO $$
DECLARE
  v_user_id     UUID;
  v_tech_id     UUID;
  v_label       TEXT;
  v_eff_pre     INT;
  v_eff_post    INT;
  v_evald_pre   INT;
  v_evald_post  INT;
  v_nu_pre      INT;
  v_nu_post     INT;
  v_pass        BOOLEAN := false;
BEGIN
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;
  SELECT id, name_ko INTO v_tech_id, v_label FROM techniques WHERE is_active = true LIMIT 1;

  IF v_user_id IS NULL OR v_tech_id IS NULL THEN
    RAISE NOTICE '5. E2E not_used: SKIP — auth.users 또는 techniques 데이터 부족';
    RETURN;
  END IF;

  SELECT excellent_count + good_count, not_used_count
    INTO v_eff_pre, v_nu_pre
  FROM technique_stats WHERE technique_id = v_tech_id;
  v_eff_pre := COALESCE(v_eff_pre, 0);
  v_nu_pre  := COALESCE(v_nu_pre, 0);

  SELECT COUNT(*) INTO v_evald_pre
  FROM ratings
  WHERE technique_id = v_tech_id
    AND outcome IS NOT NULL
    AND outcome != 'not_used';

  BEGIN
    INSERT INTO ratings (user_id, technique_id, technique_label, star_rating, outcome)
    VALUES (v_user_id, v_tech_id, COALESCE(v_label, 'verify-055 not_used'), NULL, 'not_used');

    SELECT excellent_count + good_count, not_used_count
      INTO v_eff_post, v_nu_post
    FROM technique_stats WHERE technique_id = v_tech_id;

    SELECT COUNT(*) INTO v_evald_post
    FROM ratings
    WHERE technique_id = v_tech_id
      AND outcome IS NOT NULL
      AND outcome != 'not_used';

    IF v_eff_post = v_eff_pre
       AND v_evald_post = v_evald_pre
       AND v_nu_post = v_nu_pre + 1 THEN
      v_pass := true;
    END IF;

    RAISE NOTICE '5. E2E not_used: % — eff(pre/post)=%/% evald=%/% nu_count=%/%',
      CASE WHEN v_pass THEN 'PASS' ELSE 'FAIL' END,
      v_eff_pre, v_eff_post, v_evald_pre, v_evald_post, v_nu_pre, v_nu_post;

    RAISE EXCEPTION 'verify-055 E2E not_used rollback (intentional)';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLERRM LIKE '%verify-055 E2E not_used rollback%' THEN
        RAISE NOTICE '5. E2E not_used: 트랜잭션 롤백 완료';
      ELSE
        RAISE NOTICE '5. E2E not_used: FAIL — 예상 외 예외: %', SQLERRM;
        RAISE;
      END IF;
  END;
END $$;
```

**결과 확인 방법**: Supabase SQL 에디터의 결과 패널 **Messages** 탭에서 `NOTICE` 메시지 확인. `5. E2E not_used: PASS` + `5. E2E not_used: 트랜잭션 롤백 완료` 두 줄 모두 보여야 정상.

**실패 시 (FAIL)**:
- `eff_post != eff_pre` 또는 `evald_post != evald_pre` → not_used 가 evaluated 분모에 잘못 들어감 → **Step 2C** (055b 재실행).
- `nu_post != nu_pre + 1` → not_used_count 컬럼이 트리거에 잘못 연결됨 → **Step 2C**.
- `SKIP` 노출 → 데이터 부족 (auth.users 또는 techniques 비어 있음). production 에서는 일반적으로 발생하지 않음 — **Jarvis 보고**.

### 2A.5 E2E good INSERT 검증 (verify §6)

```sql
-- Step 2A.5: outcome='good' 가상 INSERT → effective +1 + weight 갱신 확인
-- BEGIN/ROLLBACK 으로 실데이터 변경 없음
-- 기대 결과: NOTICE '6. E2E good: PASS — ...'

DO $$
DECLARE
  v_user_id     UUID;
  v_tech_id     UUID;
  v_label       TEXT;
  v_eff_pre     INT;
  v_eff_post    INT;
  v_evald_pre   INT;
  v_evald_post  INT;
  v_weight_pre  NUMERIC(5,4);
  v_weight_post NUMERIC(5,4);
  v_pass        BOOLEAN := false;
BEGIN
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;
  SELECT id, name_ko INTO v_tech_id, v_label FROM techniques WHERE is_active = true LIMIT 1;

  IF v_user_id IS NULL OR v_tech_id IS NULL THEN
    RAISE NOTICE '6. E2E good: SKIP — 데이터 부족';
    RETURN;
  END IF;

  SELECT excellent_count + good_count, recommendation_weight
    INTO v_eff_pre, v_weight_pre
  FROM technique_stats WHERE technique_id = v_tech_id;
  v_eff_pre := COALESCE(v_eff_pre, 0);

  SELECT COUNT(*) INTO v_evald_pre
  FROM ratings
  WHERE technique_id = v_tech_id
    AND outcome IS NOT NULL
    AND outcome != 'not_used';

  BEGIN
    INSERT INTO ratings (user_id, technique_id, technique_label, star_rating, outcome)
    VALUES (v_user_id, v_tech_id, COALESCE(v_label, 'verify-055 good'), NULL, 'good');

    SELECT excellent_count + good_count, recommendation_weight
      INTO v_eff_post, v_weight_post
    FROM technique_stats WHERE technique_id = v_tech_id;

    SELECT COUNT(*) INTO v_evald_post
    FROM ratings
    WHERE technique_id = v_tech_id
      AND outcome IS NOT NULL
      AND outcome != 'not_used';

    IF v_eff_post = v_eff_pre + 1
       AND v_evald_post = v_evald_pre + 1
       AND v_weight_post IS NOT NULL
       AND v_weight_post BETWEEN 0.0 AND 1.0 THEN
      v_pass := true;
    END IF;

    RAISE NOTICE '6. E2E good: % — eff(pre/post)=%/% evald=%/% w(pre/post)=%/%',
      CASE WHEN v_pass THEN 'PASS' ELSE 'FAIL' END,
      v_eff_pre, v_eff_post, v_evald_pre, v_evald_post,
      v_weight_pre, v_weight_post;

    RAISE EXCEPTION 'verify-055 E2E good rollback (intentional)';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLERRM LIKE '%verify-055 E2E good rollback%' THEN
        RAISE NOTICE '6. E2E good: 트랜잭션 롤백 완료';
      ELSE
        RAISE NOTICE '6. E2E good: FAIL — 예상 외 예외: %', SQLERRM;
        RAISE;
      END IF;
  END;
END $$;
```

**실패 시 (FAIL)**:
- `eff_post != eff_pre + 1` → 트리거 함수가 카운트를 못 늘림 → **Jarvis 보고**.
- `weight_post NULL` 또는 범위 밖 → 함수 본문 이상 → **Step 2C**.

### Step 2A 종료 조건

§2.1 ~ §2.5 모두 PASS 라면 **055 적용은 production 에서 완료된 상태** — 별도 조치 불필요. 본 가이드 작업 종료.

---

## Step 2B. 6 값 케이스 — 신규 적용 (055a → 055b → verify)

**전제**: Step 1 결과가 `value_count = 6` + `FAIL` + `enum_values` 에 `not_used` 없음.

**의미**: 055 가 production 미적용 상태. 본 Step 에서 적용 + 검증.

**진행 순서**: 2B.1 → 2B.2 → 2B.3 (각각 새 쿼리 창).

⚠️ **절대 같은 쿼리 창에서 2B.1 + 2B.2 연속 실행 금지** — PG `55P04` 에러 발생.

### 2B.1 — 055a 적용 (ENUM 'not_used' 추가)

**새 쿼리 창 열기** → 아래 SQL 블록 복사 → Run.

```sql
-- ============================================================
-- 055a — outcome rating_outcome ENUM 'not_used' 값 추가
-- ============================================================
-- 본 블록 단독 실행 → commit 후 새 쿼리 창에서 055b 실행할 것.
-- ============================================================

-- 1. rating_outcome ENUM 에 'not_used' 추가 (멱등)
DO $$ BEGIN
  ALTER TYPE rating_outcome ADD VALUE IF NOT EXISTS 'not_used';
EXCEPTION WHEN duplicate_object THEN null; END $$;

COMMENT ON TYPE rating_outcome IS
  '055 단일 신호 모델 (7 분류): excellent / good / moderate / poor / no_effect / adverse / not_used. not_used 는 PT 가 추천을 받았으나 미시술. weight 산식에서 effectiveness 분모/분자 제외 (영향 0). 활성도 카운트에는 포함.';

-- 2. 검증 (같은 세션 안전 — pg_enum 메타조회만)
DO $$
DECLARE
  v_count INT;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM pg_enum
  WHERE enumtypid = 'rating_outcome'::regtype;
  RAISE NOTICE 'rating_outcome enum value count: % (기대: 7)', v_count;
END $$;
```

**예상 결과** (Messages 탭):
```
NOTICE: rating_outcome enum value count: 7 (기대: 7)
```

**실패 시**:
- `ERROR: type "rating_outcome" does not exist` → 마이그 054 미적용 → **Jarvis 보고**.
- 그 외 에러 → 스크린샷 + 에러 메시지 Jarvis 에 전달.

**운영 영향**:
- 락 시간: **수 밀리초** (ALTER TYPE ADD VALUE 는 metadata-only).
- 다운타임: **없음** (사용자 트래픽 영향 0).
- 롤백: ENUM 값 제거는 PG 가 직접 지원 안 함 → forward-only. 추가 자체가 위험하지 않으므로 실용적 무해.

⚠️ **다음 단계로 가기 전 반드시 새 쿼리 창을 열 것** (같은 창에 이어서 055b 붙여넣지 말 것).

### 2B.2 — 055b 적용 (컬럼 + 함수 + 일괄 재계산)

**새 쿼리 창 열기** → 아래 SQL 블록 전체 복사 → Run.

```sql
-- ============================================================
-- 055b — technique_stats.not_used_count + 함수 재정의 + 일괄 재계산
-- ============================================================
-- 전제: 055a 가 이미 commit 됐을 것. 같은 쿼리 창 절대 금지.
-- ============================================================

-- 1. technique_stats.not_used_count 컬럼 추가 (멱등)
ALTER TABLE public.technique_stats
  ADD COLUMN IF NOT EXISTS not_used_count INT DEFAULT 0;

COMMENT ON COLUMN public.technique_stats.not_used_count IS
  '055: PT 가 AI 추천을 받았으나 미시술한 케이스 누계. weight 영향 없음. use rate / 추천 채택률 분석용.';

UPDATE public.technique_stats
SET not_used_count = 0
WHERE not_used_count IS NULL;


-- 2. fn_refresh_technique_stats() 재정의 — outcome != 'not_used' 필터
CREATE OR REPLACE FUNCTION fn_refresh_technique_stats()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tech_id UUID;
BEGIN
  v_tech_id := COALESCE(NEW.technique_id, OLD.technique_id);

  IF v_tech_id IS NULL THEN
    RETURN NULL;
  END IF;

  INSERT INTO technique_stats (
    technique_id,
    total_ratings,
    excellent_count,
    good_count,
    moderate_count,
    poor_count,
    no_effect_count,
    adverse_count,
    not_used_count,
    ai_recommended_count,
    recent_30d_avg_rating,
    recommendation_weight,
    updated_at
  )
  SELECT
    v_tech_id,
    COUNT(*),
    COUNT(*) FILTER (WHERE outcome = 'excellent'),
    COUNT(*) FILTER (WHERE outcome = 'good'),
    COUNT(*) FILTER (WHERE outcome = 'moderate'),
    COUNT(*) FILTER (WHERE outcome = 'poor'),
    COUNT(*) FILTER (WHERE outcome = 'no_effect'),
    COUNT(*) FILTER (WHERE outcome = 'adverse'),
    COUNT(*) FILTER (WHERE outcome = 'not_used'),
    COUNT(*) FILTER (WHERE was_ai_recommended = true),
    ROUND(AVG(star_rating) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'
                                     AND star_rating IS NOT NULL), 2),
    ROUND(
      LEAST(1.0, GREATEST(0.0,
        (COALESCE(
          COUNT(*) FILTER (WHERE outcome IN ('excellent','good'))::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL AND outcome != 'not_used'), 0),
          0.5
        ) * 0.70) +
        (LEAST(COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 20) / 20.0 * 0.20) +
        ((1.0 - COALESCE(
          COUNT(*) FILTER (WHERE outcome = 'adverse')::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL AND outcome != 'not_used'), 0),
          0.0
        )) * 0.10)
      ))::NUMERIC,
    4),
    NOW()
  FROM ratings
  WHERE technique_id = v_tech_id
  ON CONFLICT (technique_id) DO UPDATE SET
    total_ratings           = EXCLUDED.total_ratings,
    excellent_count         = EXCLUDED.excellent_count,
    good_count              = EXCLUDED.good_count,
    moderate_count          = EXCLUDED.moderate_count,
    poor_count              = EXCLUDED.poor_count,
    no_effect_count         = EXCLUDED.no_effect_count,
    adverse_count           = EXCLUDED.adverse_count,
    not_used_count          = EXCLUDED.not_used_count,
    ai_recommended_count    = EXCLUDED.ai_recommended_count,
    recent_30d_avg_rating   = EXCLUDED.recent_30d_avg_rating,
    recommendation_weight   = EXCLUDED.recommendation_weight,
    updated_at              = NOW();

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION fn_refresh_technique_stats() IS
  '055: 054 공식 유지(outcome 70% + 활성도 20% + adverse 10%) + not_used 분모/분자 제외. SECURITY DEFINER. avg_star_rating/avg_indication_accuracy 는 보존하되 갱신 안 함. not_used_count 컬럼은 정보 추적용으로 INSERT.';


-- 3. 기존 technique_stats 일괄 재계산 (not_used_count + weight)
UPDATE technique_stats ts
SET
  not_used_count        = sub.nu,
  recommendation_weight = sub.new_weight,
  updated_at            = NOW()
FROM (
  SELECT
    technique_id,
    COUNT(*) FILTER (WHERE outcome = 'not_used') AS nu,
    ROUND(
      LEAST(1.0, GREATEST(0.0,
        (COALESCE(
          COUNT(*) FILTER (WHERE outcome IN ('excellent','good'))::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL AND outcome != 'not_used'), 0),
          0.5
        ) * 0.70) +
        (LEAST(COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days'), 20) / 20.0 * 0.20) +
        ((1.0 - COALESCE(
          COUNT(*) FILTER (WHERE outcome = 'adverse')::FLOAT
            / NULLIF(COUNT(*) FILTER (WHERE outcome IS NOT NULL AND outcome != 'not_used'), 0),
          0.0
        )) * 0.10)
      ))::NUMERIC,
    4) AS new_weight
  FROM ratings
  WHERE technique_id IS NOT NULL
  GROUP BY technique_id
) sub
WHERE ts.technique_id = sub.technique_id;

COMMENT ON COLUMN public.ratings.outcome IS
  '단일 핵심 신호 (마이그 055). rating_outcome ENUM 7분류 (054 의 6 + 055 의 not_used). NULL 허용 (기존 데이터 호환). not_used = PT 가 추천을 받았으나 미시술. effectiveness 가중치(70%)/adverse 가중치(10%) 분모/분자 제외, 활성도 가중치(20%) 에는 포함.';
```

**예상 결과**:
- `ALTER TABLE` 성공 (이미 컬럼 있으면 NOTICE — 정상).
- `UPDATE 0` 또는 NULL 행 수 (DEFAULT 0 으로 이미 채워져 있음 — 정상).
- `CREATE FUNCTION` 성공.
- `UPDATE N` (technique_stats 행 수만큼 — production 기법 수에 따라 다름).

**실패 시**:
- `ERROR: invalid input value for enum rating_outcome: "not_used"` → 055a 가 commit 되지 않은 상태에서 055b 실행. 새 쿼리 창에서 다시 시도 (055a 결과는 보존됨).
- `ERROR: relation "technique_stats" does not exist` → 마이그 050 미적용 → **Jarvis 보고**.
- 그 외 에러 → 에러 메시지 Jarvis 에 전달.

**운영 영향**:
- 락 시간:
  - `ADD COLUMN IF NOT EXISTS ... DEFAULT 0`: PG 11+ 에서 **metadata-only** (수 밀리초).
  - `CREATE OR REPLACE FUNCTION`: **수 밀리초** (메타데이터 변경).
  - 일괄 `UPDATE technique_stats`: technique_stats 행 수 × 작은 비용. production 기법 수가 수백~수천이라면 **수 초 이내**.
- 다운타임: **없음** (모든 락은 ACCESS EXCLUSIVE 아니므로 SELECT 차단 안 함).
- 트리거 함수 교체 순간에 short blip 가능하나 사용자 영향은 **무시 가능**.

**롤백** (필요 시):
- `ALTER TABLE technique_stats DROP COLUMN IF EXISTS not_used_count;`
- 함수 본문 054 버전으로 `CREATE OR REPLACE` 재실행 (별도 진행 필요).
- 본 가이드 적용 후 즉시 문제 발견이 아니라면 롤백보다 forward-fix 권장.

⚠️ **다음 단계로 가기 전 반드시 새 쿼리 창을 열 것**.

### 2B.3 — verify §1~6 전수 실행

새 쿼리 창에서 **Step 2A 의 §2.1 → §2.2 → §2.3 → §2.4 → §2.5 를 차례로 실행** (각각 새 쿼리 창 권장하나, 같은 창에서 §2.1~§2.3 만 묶어 실행해도 무방. §2.4/§2.5 는 DO 블록이라 NOTICE 출력 위해 단독 실행 권장).

또한 Step 1 (pg_enum 카운트) 도 다시 한 번 실행하여 7 값 PASS 확인.

**모두 PASS 라면 본 가이드 작업 종료**.

---

## Step 2C. 혼합 케이스 — 055b 단독 재실행

**전제**: Step 1 결과는 7 값 PASS 였으나, Step 2A 중 §2.1 ~ §2.5 에서 일부 FAIL.

**의미**: ENUM 은 7 값으로 등록됐으나 컬럼 / 함수 / weight 재계산이 미완료 또는 비정상.

**진행**: Step 2B.2 (055b SQL 블록) 를 **새 쿼리 창에 그대로 복사 → Run**.

- 멱등이므로 안전 (재실행해도 동일 결과).
- 실행 후 Step 2A §2.1 ~ §2.5 를 다시 실행하여 PASS 확인.

여전히 FAIL 이 남으면 **Jarvis 보고** (특정 FAIL 항목 + 결과 스크린샷 첨부).

---

## Step 2D. 이상 케이스 — Jarvis 보고

**전제**: Step 1 결과가 6 / 7 이 아닌 값 (예: 5, 8+), 또는 쿼리 자체 에러.

**진행**:
1. Step 1 결과 스크린샷 캡처.
2. 에러 메시지 전문 복사.
3. Jarvis 에 "055 적용 가이드 Step 2D — 이상 상태" 로 보고.
4. sw-db-architect 의 후속 조사 대기.

본 가이드 자체로 진행 불가 — 무리 실행 금지.

---

## 3. 자주 묻는 질문 (FAQ)

### Q1. SQL 블록 중간에 `ERROR: 55P04 unsafe use of new enum value` 가 떴습니다.

**A**: 055a 와 055b 를 같은 쿼리 창에서 실행했을 가능성. **새 쿼리 창** 을 열어 055b 만 다시 실행. 055a 의 결과(ENUM 추가)는 보존되므로 추가 작업 불필요.

### Q2. `ALTER TABLE technique_stats ADD COLUMN ... DEFAULT 0` 가 오래 걸리지 않을까요?

**A**: PG 11+ 부터 `DEFAULT` 가 정적 표현식(상수 0)이면 **metadata-only** 로 처리. 수십만 행이 있어도 수 밀리초. 다운타임 0.

### Q3. 가이드대로 했는데 verify §4 (weight 범위) FAIL 입니다.

**A**: 함수 본문에 버그가 있거나 일괄 재계산이 안 됐을 가능성. Step 2C (055b 단독 재실행) 진행. 그래도 FAIL 이면 Jarvis 에 weight FAIL 행 (technique_id + min/max) 함께 보고.

### Q4. verify §5 또는 §6 에서 `SKIP — 데이터 부족` 메시지가 떴습니다.

**A**: production 에서는 거의 발생하지 않음 (auth.users / techniques 가 비어 있을 경우). 만약 발생 시 Jarvis 에 보고 — 더 정밀한 검증 쿼리 제공 가능.

### Q5. 일괄 재계산 UPDATE 가 N 행을 갱신했다는 메시지에 N 이 0 입니다.

**A**: technique_stats 가 비어 있을 가능성 (production 초기 단계라면 정상). ratings 가 0건이면 technique_stats 도 0건. verify §3 (컬럼 존재) / §4 (범위, 0 행이라 PASS) 가 통과하면 정상.

### Q6. 055a 실행 후 ENUM 카운트가 여전히 6 입니다.

**A**: ALTER TYPE 가 commit 되지 않았을 가능성 (Supabase SQL 에디터는 기본적으로 auto-commit 이나, 트랜잭션 모드일 수 있음). 페이지 새로고침 후 Step 1 (pg_enum 카운트) 재실행. 그래도 6 이면 **Jarvis 보고**.

---

## 4. 적용 후 보고 양식

대표님이 Step 1 ~ 2B/2A 완료 후 sw-db-architect (Jarvis 경유) 에게 다음 정보 전달 요청:

```
- 적용 일시: YYYY-MM-DD HH:MM
- Step 1 결과: value_count = X (PASS/FAIL)
- 진행 경로: Step 2A / 2B / 2C / 2D 중 X
- verify §1~§6 결과:
  §1: PASS / FAIL
  §2: PASS / FAIL  (FAIL 시 어떤 플래그)
  §3: PASS / FAIL
  §4: PASS / FAIL  (FAIL 시 min/max)
  §5: PASS / FAIL  (FAIL 시 NOTICE 메시지)
  §6: PASS / FAIL  (FAIL 시 NOTICE 메시지)
- 이슈/관찰: (있다면 자유 기술)
```

sw-db-architect 는 위 결과를 받은 후:
1. `LOG-2026-05.md` 끝에 "055 production 적용 완료" entry 추가.
2. 다음 단계 (마이그 056 준비, frontend "안 썼음" 옵션 등) 진행 여부 결정.

---

## 5. 참고 자료

- 마이그 055 분할 배경: `LOG-2026-05.md` 5/6 sw-db-architect entry (L943 부근).
- 운영 절차 원문: `saas/docs/not-used-tracking-design.md` §6A.
- 단일 신호 모델 (054) 배경: `saas/docs/single-signal-model-design.md`.
- 055 의 weight 영향 0 정책: `saas/docs/not-used-tracking-design.md` §4.

---

**문서 끝.**
