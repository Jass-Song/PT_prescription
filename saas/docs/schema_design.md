<!-- owner: sw-db-architect -->
# 도수치료 테크닉 SaaS — Supabase 스키마 설계 문서

**작성일**: 2026-04-24
**최종 업데이트**: 2026-04-27 (태그 컬럼 활용 방식 및 hard filter 로직 추가)
**담당**: sw-db-architect
**파일**: `pt-prescription/saas/schema.sql`

---

## 1. 전체 구조 개요

```
auth.users (Supabase 내장)
    │
    ├── user_profiles          치료사 프로필 확장
    │
    ├── techniques             테크닉 마스터 DB
    │       └── technique_stats  집계 통계 (AI 추천 가중치 포함)
    │
    ├── ratings                사용 후 효과 평가
    │       └── community_cases  커뮤니티 케이스 공유 (미래 확장)
    │
    ├── usage_logs             사용 이력 (AI 피드백 루프 원천)
    │
    ├── user_favorites         즐겨찾기
    │
    └── technique_tags         태그 마스터 (정규화)
```

---

## 2. 테이블별 설계 결정 사항

### 2.1 `techniques` — 테크닉 마스터

**핵심 결정: 태그를 배열(TEXT[])로 저장**

태그를 별도 조인 테이블 대신 PostgreSQL 네이티브 배열로 저장했다. 이유:
- AI 추천 쿼리에서 `@>` (contains) 연산자로 단일 테이블 스캔 가능
- GIN 인덱스가 배열 검색을 효율적으로 처리
- 조인 없이 `purpose_tags @> ARRAY['pain_relief']` 형태로 필터링

**태그 4종 분리 이유:**
- `purpose_tags`: AI가 "무엇을 하려는가"로 필터 (통증 감소, ROM 개선 등)
- `target_tags`: "어떤 환자인가"로 필터 (급성, 만성, 운동선수 등)
- `symptom_tags`: "어떤 증상인가"로 필터 (요통, 경추성 두통 등)
- `contraindication_tags`: AI 추천 제외 조건 — 입력 조건과 교차 확인 후 필터 아웃

**`technique_steps` JSONB 선택 이유:**
단계가 1~10개로 가변적이고, 각 단계마다 구조(step, instruction, image_url 등)가 다를 수 있다. JSONB가 배열보다 유연하고, GIN 인덱스로 내부 검색도 가능.

**`key_references` JSONB:**
`[{pmid, title, year, journal}]` 형태로 PubMed 연동 또는 수동 입력 모두 수용.

---

### 2.2 `technique_tags` — 태그 마스터

정규화 목적. 태그 키(`tag_key`)는 시스템 내부 식별자(영어 snake_case), `label_ko`/`label_en`은 UI 표시용. 태그 추가/수정을 admin UI에서 관리할 수 있도록 별도 테이블로 분리했다.

`techniques.purpose_tags` 배열의 값은 이 테이블의 `tag_key`를 참조하는 소프트 레퍼런스다. 외래키 강제(hard FK)는 걸지 않았다 — 태그 삭제 시 배열 정리가 복잡해지고, 임상 데이터의 특성상 태그 체계가 진화하기 때문.

---

### 2.3 `ratings` — 효과 평가 (핵심 테이블)

**`indication_accuracy` 필드 (1-5점):**
AI 추천 품질 피드백의 핵심. "이 환자에게 이 테크닉을 추천했을 때 얼마나 적절했는가"를 치료사가 사후 평가. `was_ai_recommended = true`인 케이스에서만 의미 있지만, 모든 케이스에 열어두어 수동 사용 케이스도 수집 가능.

**`ai_recommendation_score` 저장 이유:**
추천 당시의 AI 점수를 스냅샷으로 보관. 나중에 "점수가 높았는데 효과 없었던 케이스"를 분석해 모델 튜닝에 활용.

**`actual_symptom_tags` / `actual_target_tags`:**
AI가 추천 시 사용한 태그와 치료사가 실제로 확인한 태그를 비교 분석 가능. 추천 정확도 측정의 두 번째 축.

**`follow_up_rating` / `follow_up_date`:**
즉각 효과와 추적 효과를 구분해서 수집. 도수치료 효과 검증에서 단기/중기 효과 차이가 임상적으로 중요.

---

### 2.4 `technique_stats` — 집계 통계

**설계 패턴: 캐시 테이블 (Materialized-like)**

매번 ratings를 COUNT/AVG하는 뷰 대신, 트리거로 갱신되는 캐시 테이블을 선택했다. 이유:
- 테크닉 목록 조회 시 N+1 집계 쿼리 없이 단일 JOIN으로 처리
- 추천 가중치 갱신은 ratings 변경 시에만 발생 — 읽기가 훨씬 많은 SaaS 특성에 적합

**`recommendation_weight` 산출 공식:**
```
가중치 = 별점(20%) + 적응증 정확도(30%) + 최근 30일 활성도(20%) + 효과 분포(30%)
```
- 별점: 순수 만족도
- 적응증 정확도: "맞는 환자에게 추천됐는지" — AI 추천 품질 직결
- 활성도: 최근에 많이 쓰이는 테크닉 우대 (최대 20회 사용 기준 정규화)
- 효과 분포: excellent + good 비율 (단순 평균보다 이진 분류가 더 안정적)

가중치 범위는 0.0000~1.0000. AI 추천 엔진에서 이 값을 기반 점수로 사용하고, 입력 태그 매칭 점수와 곱해 최종 순위 산출.

---

### 2.5 `usage_logs` — 사용 이력

**피드백 루프의 원천 데이터.**

`source` 필드로 진입 경로를 구분:
- `ai_recommendation`: AI가 추천한 경우 → indication_accuracy 피드백과 연결
- `search`: 검색으로 찾은 경우
- `favorite`: 즐겨찾기에서 꺼낸 경우

`recommendation_session_id`: 한 번의 추천 세션에서 여러 테크닉을 보여줬을 때 어떤 것을 선택했는지 추적. 선택률(CTR) 분석으로 추천 순위 로직 검증.

`query_*` 필드들: 추천 요청 시 입력한 파라미터를 로그로 보존. "어떤 조건으로 검색했을 때 이 테크닉을 선택했는지"를 사후 분석.

---

### 2.6 `user_favorites` — 즐겨찾기

`collection_name`으로 폴더 구조 지원. 기본값 '기본'. 나중에 컬렉션 공유 기능(동료에게 추천 세트 공유) 확장 가능.

`UNIQUE(user_id, technique_id)` 제약으로 중복 즐겨찾기 방지.

---

### 2.7 `user_profiles` — 치료사 프로필

`auth.users`의 `id`를 PK로 사용(1:1 확장). Supabase Auth와 완전 통합.

`specialty_tags`: 치료사의 전문 분야. 미래 기능 — 전문 분야와 일치하는 테크닉 우선 노출, 전문가 케이스 신뢰도 가중치 부여.

`is_verified`: 자격증 인증 여부. 인증된 치료사의 ratings에 더 높은 가중치를 부여하거나, 커뮤니티 케이스 표시 우선순위에 활용.

---

### 2.8 `community_cases` — 커뮤니티 케이스 (미래 확장)

현재는 구조만 정의. `ratings.is_shared = true`로 공개 동의한 케이스의 커뮤니티 레이어.

`rating_id` FK로 원본 평가 데이터와 연결 — 케이스는 평가 위에 제목/요약/태그를 추가한 뷰.

---

## 3. RLS 정책 구조

| 테이블 | SELECT | INSERT | UPDATE | DELETE |
|--------|--------|--------|--------|--------|
| techniques | 공개 테크닉: 전체 / 비공개: 인증 사용자 | 인증 사용자 (verified) | 본인 작성만 | 본인 작성만 |
| technique_tags | 인증 사용자 | — | — | — |
| technique_stats | 인증 사용자 | — (트리거 전용) | — | — |
| ratings | 본인 것 + 공유된 것 | 본인 | 본인 | 본인 |
| usage_logs | 본인 | 본인 | — | — |
| user_favorites | 본인 | 본인 | 본인 | 본인 |
| user_profiles | 인증 사용자 전체 | 본인 | 본인 | — |
| community_cases | 공개 + 본인 | 본인 | 본인 | 본인 |

`technique_stats`에는 쓰기 정책을 설정하지 않는다. 오직 트리거 함수(SECURITY DEFINER 방식)만 갱신. 애플리케이션 레이어에서 직접 수정 불가.

---

## 4. 자동화 트리거 흐름

```
ratings INSERT/UPDATE/DELETE
    → trg_refresh_stats_on_rating
    → fn_refresh_technique_stats()
    → technique_stats UPSERT (별점, 효과 분포, recommendation_weight 갱신)

usage_logs INSERT
    → trg_increment_uses_on_log
    → fn_increment_technique_uses()
    → technique_stats.total_uses + 1, recent_30d_uses 재산출

user_favorites INSERT/DELETE
    → trg_sync_favorite_count
    → fn_sync_favorite_count()
    → technique_stats.favorite_count 동기화

techniques/ratings/user_profiles/community_cases UPDATE
    → trg_*_updated_at
    → fn_update_updated_at()
    → updated_at = NOW()
```

---

## 5. 인덱스 전략

| 인덱스 | 타입 | 대상 쿼리 |
|--------|------|---------|
| `idx_techniques_purpose_tags` | GIN | `WHERE purpose_tags @> ARRAY[...]` |
| `idx_techniques_target_tags` | GIN | `WHERE target_tags @> ARRAY[...]` |
| `idx_techniques_symptom_tags` | GIN | `WHERE symptom_tags @> ARRAY[...]` |
| `idx_techniques_name_trgm` | GIN (pg_trgm) | `WHERE name_ko ILIKE '%검색어%'` |
| `idx_techniques_body_region` | B-tree | `WHERE body_region = 'lumbar'` |
| `idx_technique_stats_recommendation_weight` | B-tree DESC | AI 추천 정렬 |
| `idx_ratings_technique_id` | B-tree | 테크닉별 평가 집계 |
| `idx_usage_logs_recommendation_session` | B-tree | 추천 세션 분석 |

**pg_trgm 활성화 필요**: `CREATE EXTENSION IF NOT EXISTS "pg_trgm"` — schema.sql 상단에 포함.

---

## 5-a. 태그 컬럼 활용 방식 및 Hard Filter 로직

### 태그 3종 역할 분리

`techniques` 테이블의 태그 컬럼은 역할이 명확하게 구분된다.

| 컬럼 | 역할 | 추천 로직에서 사용 방식 |
|------|------|------------------------|
| `symptom_tags` | "어떤 증상인가" | 매칭 점수 계산 (소프트 매칭) |
| `target_tags` | "어떤 환자인가 (시기)" | **hard filter** — 통과 못 하면 점수 계산 전 제외 |
| `contraindication_tags` | "금기 조건" | **hard filter** — 교집합 있으면 무조건 제외 |

### target_tags Hard Filter 동작 방식

`recommend.js`에서 DB 조회 후, 스코어 계산 전에 적용하는 필터다.

```js
// acuity: 'acute' | 'subacute' | 'chronic'
function passesTargetTagFilter(technique, acuity) {
  const tags = technique.target_tags;
  // target_tags가 비어있으면 모든 시기에 노출 (레거시 기법 하위 호환)
  if (!tags || tags.length === 0) return true;
  return tags.includes(acuity);
}
```

예시:
- `target_tags = ['acute', 'subacute']` → chronic 환자에게 제외됨
- `target_tags = ['chronic']` → acute·subacute 환자에게 제외됨
- `target_tags = []` → 모든 환자에게 노출 (하위 호환)

### 현재 확정된 표준 태그 값 (016 마이그레이션 이후)

```
symptom_tags 허용 값:
  movement_pain, hypomobile, morning_stiffness, disc_related,
  rest_pain, lbp_nonspecific, cervicogenic_headache,
  radicular_pain, referred_pain

target_tags 허용 값:
  acute, subacute, chronic, muscle_hypertonicity, sensitized

contraindication_tags 허용 값:
  fracture, malignancy, instability, neurological_deficit,
  osteoporosis, anticoagulants, active_infection,
  vbi, upper_cervical_instability
```

새 기법 INSERT 시 이 값 목록 외의 태그를 사용하면 hard filter가 예상대로 동작하지 않을 수 있다. 태그 추가가 필요하면 콘텐츠팀과 협의 후 이 문서와 `recommend.js` 필터 로직을 동시에 업데이트해야 한다.

### contraindication_tags Hard Filter (DB 레이어)

프로덕션에서는 DB 쿼리 레이어에서 직접 필터링 권장:

```sql
AND NOT (t.contraindication_tags && $active_contraindications::text[])
```

`&&` 연산자는 두 배열의 교집합이 존재하면 `true`. GIN 인덱스(`idx_techniques_contraindication_tags`)가 있으면 성능 문제 없음.

---

## 6. AI 추천 엔진 연동 포인트

추천 API가 이 스키마를 사용하는 방식:

```sql
-- 입력: body_region, purpose_tags[], symptom_tags[], target_tags[]
-- 출력: technique_id, name_ko, recommendation_weight, avg_star_rating

SELECT
  t.id,
  t.name_ko,
  t.abbreviation,
  t.evidence_level,
  s.recommendation_weight,
  s.avg_star_rating,
  s.total_ratings,
  -- 태그 매칭 점수 (입력 태그와 교집합 크기)
  (
    CARDINALITY(t.purpose_tags & $purpose_tags) * 0.4 +
    CARDINALITY(t.symptom_tags & $symptom_tags) * 0.4 +
    CARDINALITY(t.target_tags  & $target_tags)  * 0.2
  ) AS tag_match_score
FROM techniques t
JOIN technique_stats s ON t.id = s.technique_id
WHERE
  t.body_region = $body_region
  AND t.is_published = true
  AND t.is_active = true
  -- 금기증 필터: 입력된 금기증과 교집합 없는 것만
  AND NOT (t.contraindication_tags && $active_contraindications)
ORDER BY
  (tag_match_score * 0.5 + s.recommendation_weight * 0.5) DESC
LIMIT 10;
```

추천 실행 후 `usage_logs`에 `source = 'ai_recommendation'`, `recommendation_session_id`, `recommendation_rank` 기록 → 이후 치료사가 평가하면 `ratings.was_ai_recommended = true`로 연결.

---

## 7. 미래 확장 포인트

| 기능 | 확장 방법 |
|------|---------|
| 테크닉 동영상 연결 | `techniques.video_url TEXT` 컬럼 추가 또는 `technique_media` 별도 테이블 |
| 다국어 지원 | `technique_translations(technique_id, locale, name, description)` 테이블 추가 |
| 팀/기관 단위 구독 | `organizations` + `organization_members` 테이블 + RLS에 org_id 조건 추가 |
| 케이스 댓글 | `case_comments(case_id, user_id, body, created_at)` 추가 |
| AI 모델 버전 추적 | `usage_logs.ai_model_version TEXT` 컬럼 추가 |
| 치료 프로토콜 묶음 | `protocols(id, name, steps: [{technique_id, order, notes}])` JSONB 테이블 |
| Stripe 구독 연동 | `subscriptions(user_id, stripe_customer_id, plan, status, expires_at)` |

---

## 8. Supabase 설정 체크리스트

schema.sql 실행 전 Supabase 대시보드에서 확인:

- [ ] `uuid-ossp` extension 활성화 (Database > Extensions)
- [ ] `pg_trgm` extension 활성화
- [ ] `auth.users` 테이블 존재 확인 (Supabase Auth 활성화 시 자동 생성)
- [ ] RLS 활성화 후 서비스 롤(service_role)로 초기 시드 데이터 삽입
- [ ] `technique_stats` 트리거 함수: SECURITY DEFINER 설정 확인 (필요시 수동 수정)
- [ ] Edge Function 또는 pg_cron으로 `recent_30d_*` 컬럼 야간 재산출 스케줄 설정 권장

---

*파일 경로: `C:/project/PT/KMovement Optimism/.jarvis/saas/schema_design.md`*
