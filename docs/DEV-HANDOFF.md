# KMO 도수치료 테크닉 AI 추천 시스템 — 개발팀 핸드오프

**작성일**: 2026-04-27
**버전**: MVP v0.2
**전달자**: KMO 콘텐츠팀 (쟈르스)
**수신자**: 소프트웨어 개발팀

---

## 1. 프로젝트 개요

### 서비스 목적
물리치료사가 환자 상태를 입력하면 Supabase DB 기반 스코어링 알고리즘이 최적의 도수치료 기법을 선별하고, Claude AI가 구체적인 임상 지침과 함께 추천하는 임상 지원 SaaS. 근거기반 재활 원칙(K-Movement Optimism 철학)을 기반으로 치료사의 임상 의사결정을 보조한다.

### 현재 범위 (2026-04-27 기준)
- **지원 부위**: 경추(cervical), 요추(lumbar)
- **MT 카테고리**: 12개 (아래 전체 목록 참조)
- **Supabase DB**: 연결 완료, 마이그레이션 015·016 적용됨
- **타 부위**: Coming Soon 처리

### 향후 확장 계획
- 전신 부위 추가: 흉추, 천장관절, 어깨, 팔꿈치, 고관절, 무릎, 발목 등
- 커뮤니티 케이스 공유 기능
- 치료 프로토콜 묶음 기능

---

## 2. 현재 준비된 자료

| 자료 | 경로 | 설명 |
|------|------|------|
| DB 스키마 | `pt-prescription/saas/schema.sql` | Supabase PostgreSQL DDL (테이블 8개, 트리거 7개, 뷰 2개, RLS 정책 전체 포함) |
| 스키마 설계 문서 | `pt-prescription/saas/schema_design.md` | 설계 결정 사항, 인덱스 전략, AI 연동 포인트 상세 설명 |
| 마이그레이션 디렉토리 | `pt-prescription/saas/migrations/` | 001–016 마이그레이션 SQL 파일 |
| UI 프로토타입 | `pt-prescription/index.html` | Supabase 연결 포함 추천 UI (바닐라 JS) |
| 추천 API | `pt-prescription/api/recommend.js` | 스코어링 알고리즘 + Claude AI 호출 (Vercel Serverless) |
| 인디케이션 리서치 | `research/indication-research/` | 12개 MT 카테고리 근거 기반 인디케이션 매트릭스 |

---

## 3. Supabase 연결 정보

| 항목 | 값 |
|------|-----|
| Project URL | `https://gnusyjnviugpofvaicbv.supabase.co` |
| Anon Key | `.env` 파일 참조 (프로토타입 `index.html`에 하드코딩된 값 존재 — 프로덕션 빌드 시 환경변수로 교체 필요) |
| Service Role Key | `.env` 파일 참조 (마이그레이션 실행 시 사용) |
| 현재 DB 상태 | 스키마 생성 완료, 마이그레이션 001–016 적용 완료 |
| Supabase JS SDK | `@supabase/supabase-js@2` |

> 주의: 프로토타입 `index.html`에 anon key가 직접 노출되어 있습니다. 프로덕션 배포 전 환경변수(`VITE_SUPABASE_ANON_KEY` 등)로 반드시 교체하십시오.

---

## 4. MT 카테고리 전체 목록 (12개)

| 카테고리 키 | 명칭 | 분류 |
|------------|------|------|
| `joint_mobilization` | 관절가동술 (Maitland/Kaltenborn) | 관절 |
| `mulligan` | Mulligan Concept (SNAG, MWM) | 관절 |
| `mfr` | 근막이완기법 (MFR) | 연부조직 |
| `art` | 능동이완기법 (ART) | 연부조직 |
| `ctm` | 결합조직마사지 (CTM) | 연부조직 |
| `deep_friction` | 심부마찰마사지 (Deep Friction) | 연부조직 |
| `trigger_point` | 트리거포인트 기법 | 연부조직 |
| `anatomy_trains` | 근막경선치료 (Anatomy Trains) | 연부조직 |
| `d_neural` | 신경가동술 (Neurodynamics) | 신경 |
| `mdt` | McKenzie Method (MDT) | 특수 |
| `scs` | 긴장·반긴장 기법 (SCS) | 특수 |
| `pne` | 통증신경과학교육 (PNE) | 특수 |

---

## 5. 데이터 구조 — 핵심 테이블

### 5.1 전체 구조

```
auth.users (Supabase 내장)
    │
    ├── user_profiles          치료사 프로필 확장 (자격, 전문분야, 인증 여부)
    │
    ├── techniques             테크닉 마스터 DB  (콘텐츠팀 관리)
    │       └── technique_stats  집계 통계 캐시 (AI 추천 가중치 포함)
    │
    ├── ratings                사용 후 효과 평가 (AI 피드백 루프 핵심)
    │       └── community_cases  커뮤니티 케이스 공유 (Phase 3)
    │
    ├── usage_logs             사용 이력 (AI 추천 세션 추적)
    │
    ├── user_favorites         즐겨찾기 (컬렉션 구조 지원)
    │
    └── technique_tags         태그 마스터 (정규화)
```

### 5.2 `techniques` — 테크닉 마스터

핵심 필드:

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | UUID | PK |
| `name_ko` / `name_en` | TEXT | 한국어·영어 명칭 |
| `abbreviation` | TEXT | 약어 (예: SNAG, MWM, CPA) |
| `category` | TEXT | 12개 MT 카테고리 키 또는 EX |
| `body_region` | TEXT | 13개 부위 (cervical, lumbar, thoracic 등) |
| `technique_steps` | JSONB | 단계별 수행 방법 `[{step: N, instruction: "..."}]` |
| `patient_position` | TEXT | 환자 자세 |
| `therapist_position` | TEXT | 치료사 자세 |
| `purpose_tags` | TEXT[] | 치료 목적 태그 (GIN 인덱스) |
| `target_tags` | TEXT[] | 대상 환자 태그 — **hard filter 핵심** (`acute`, `subacute`, `chronic` 등) |
| `symptom_tags` | TEXT[] | 적응 증상 태그 (GIN 인덱스) |
| `contraindication_tags` | TEXT[] | 금기증 태그 (AI 하드 필터용) |
| `evidence_level` | TEXT | `level_1a`부터 `level_5`, `insufficient` |
| `key_references` | JSONB | PubMed 참고문헌 `[{pmid, title, year, journal}]` |
| `clinical_notes` | TEXT | 임상 팁 및 주의사항 |
| `is_published` | BOOLEAN | `false` = 비공개 (admin 승인 후 `true`) |

**태그 배열 설계 결정**: 조인 테이블 대신 PostgreSQL 네이티브 `TEXT[]` + GIN 인덱스. AI 추천 쿼리에서 `@>` (contains) 연산자로 단일 테이블 스캔 가능.

### 5.3 표준 태그 체계 (016 마이그레이션 이후 확정)

| 태그 종류 | 값 목록 |
|----------|--------|
| `symptom_tags` | `movement_pain`, `hypomobile`, `morning_stiffness`, `disc_related`, `rest_pain`, `lbp_nonspecific`, `cervicogenic_headache`, `radicular_pain`, `referred_pain` |
| `target_tags` | `acute`, `subacute`, `chronic`, `muscle_hypertonicity`, `sensitized` |
| `contraindication_tags` | `fracture`, `malignancy`, `instability`, `neurological_deficit`, `osteoporosis`, `anticoagulants`, `active_infection`, `vbi`, `upper_cervical_instability` |

### 5.4 `technique_stats` — 집계 통계 캐시

직접 쓰기 불가. 트리거가 자동 갱신. 애플리케이션 레이어에서 READ ONLY.

`recommendation_weight` 산출 공식 (DB 트리거 `fn_refresh_technique_stats` 자동 실행):

```
recommendation_weight =
  (avg_star_rating / 5.0)                      × 0.20  -- 별점
  + (avg_indication_accuracy / 5.0)            × 0.30  -- 적응증 정확도
  + (MIN(recent_30d_uses, 20) / 20.0)          × 0.20  -- 최근 30일 활성도
  + ((excellent + good 비율))                  × 0.30  -- 효과 분포
```

범위: 0.0000–1.0000. 초기값 0.5000.

### 5.5 `ratings` — 효과 평가

AI 피드백 루프의 핵심 테이블.

| 필드 | 설명 |
|------|------|
| `star_rating` | 별점 1–5 (필수) |
| `outcome` | 효과 분류 ENUM (excellent / good / moderate / poor / no_effect / adverse) |
| `indication_accuracy` | 적응증 적합도 1–5 (AI 추천 품질 피드백의 핵심) |
| `was_ai_recommended` | AI 추천으로 사용했는지 여부 |
| `ai_recommendation_score` | 추천 당시 AI 점수 스냅샷 (사후 모델 분석용) |
| `patient_profile` | 익명 환자 프로필 (예: 40대 남성 만성 요통) |
| `actual_symptom_tags` / `actual_target_tags` | 치료사가 실제 확인한 태그 (AI 예측 태그와 비교 분석용) |
| `follow_up_rating` / `follow_up_date` | 추적 효과 (단기/중기 효과 구분) |
| `is_shared` | 커뮤니티 공개 동의 여부 |

---

## 6. AI 추천 로직 명세 (`api/recommend.js`)

### 6.1 CONDITION_CATEGORY_SCORES — 전문가 합의 근거 기반 점수 행렬

12개 MT 카테고리 × 9개 컨디션(acuity × symptom) 점수. 2026-04-27 전면 재작성.

```js
// acuity: acute | subacute | chronic
// symptom: movement_pain | rest_pain | radicular_pain

CONDITION_CATEGORY_SCORES = {
  acute: {
    movement_pain: { mulligan:3, mdt:3, scs:3, d_neural:2, joint_mobilization:1, mfr:1, ctm:1, trigger_point:1, pne:1 },
    rest_pain:     { scs:3, mdt:2, d_neural:1, pne:1 },
    radicular_pain:{ d_neural:3, mdt:3, mulligan:1, scs:1, pne:1 }
  },
  subacute: {
    movement_pain: { joint_mobilization:3, mdt:3, mulligan:2, mfr:2, art:2, deep_friction:2, trigger_point:2, ctm:2, d_neural:2, pne:2, scs:2 },
    rest_pain:     { scs:2, ctm:2, trigger_point:2, mdt:2, pne:2, mfr:1, art:1, deep_friction:1, d_neural:1, mulligan:1 },
    radicular_pain:{ d_neural:3, mdt:3, mulligan:2, scs:1, pne:1, mfr:1, art:1, deep_friction:1 }
  },
  chronic: {
    movement_pain: { mfr:3, art:3, deep_friction:3, trigger_point:3, joint_mobilization:3, mdt:2, anatomy_trains:2, mulligan:2, ctm:2, d_neural:2, pne:3, scs:2 },
    rest_pain:     { ctm:3, pne:3, trigger_point:2, art:2, mfr:2, scs:1, mdt:1, deep_friction:2 },
    radicular_pain:{ d_neural:2, mdt:2, pne:2, art:2, mfr:1, deep_friction:1, trigger_point:1 }
  }
}
```

### 6.2 target_tags hard filter

스코어 계산 전 적용. DB에서 가져온 기법의 `target_tags` 배열 기반 필터링.

```js
// 의사 코드
function passesTargetTagFilter(technique, acuity) {
  const tags = technique.target_tags;
  if (!tags || tags.length === 0) return true;  // 빈 태그 → 통과 (하위 호환)
  return tags.includes(acuity);  // 'acute' | 'subacute' | 'chronic'
}
```

- `target_tags`가 `['acute', 'chronic']`이면 subacute 환자에게 제외됨
- `target_tags`가 `[]`이면 모든 acuity에 노출 (레거시 기법 하위 호환)

### 6.3 금기증 필터 (contraindication_tags hard filter)

입력된 금기증 키워드가 테크닉의 `contraindication_tags` 배열과 교집합이 있으면 결과에서 제외.

DB 레이어 SQL:
```sql
AND NOT (t.contraindication_tags && $active_contraindications)
```

현재 프로토타입: 클라이언트 사이드. **프로덕션에서는 DB 레이어(서버 사이드)로 이전 권장.**

### 6.4 추천 세션 기록

추천 실행 후 반드시 `usage_logs`에 기록:
- `source = 'ai_recommendation'`
- `recommendation_session_id` (UUID, 세션 단위 발급)
- `recommendation_rank` (1–5)
- `query_body_region`, `query_purpose_tags`, `query_target_tags`, `query_symptom_tags`

---

## 7. DB 마이그레이션 현황

| 파일 | 주요 내용 | 상태 |
|------|----------|------|
| `001–014` | 초기 기법 시드, 관절가동술·Mulligan 중심 | 완료 |
| `015-exercise-neural-lumbar-cervical.sql` | 운동, 신경가동술, 요추·경추 기법 다수 INSERT; AT-SBL-DFL-Lumbar 포함 | 완료 |
| `016-cervical-techniques-tags.sql` | 경추 기법 11개 신규 INSERT; 13개 카테고리 전체 symptom_tags/target_tags/contraindication_tags UPDATE | 완료 |

### 016 마이그레이션으로 추가된 경추 기법 (11개)

| 약어 | 명칭 | 카테고리 |
|------|------|---------|
| CervART-SCM | 경추 흉쇄유돌근 ART | art |
| CervART-UT | 경추 상부승모근 ART | art |
| CervART-LS | 경추 견갑거근 ART | art |
| CervDF-FC | 경추 후관절 심부마찰 | deep_friction |
| CervDF-SOC | 후두하근 심부마찰 | deep_friction |
| AT-SBL-Cerv | 근막경선 SBL 경추 | anatomy_trains |
| AT-SBAL-Cerv | 근막경선 SBAL 경추 | anatomy_trains |
| CervTP-SOC | 후두하근 트리거포인트 | trigger_point |
| CervTP-UT | 상부승모근 트리거포인트 | trigger_point |
| LumbTP-QL | 요방형근 트리거포인트 | trigger_point |
| LumbTP-PIR | 이상근 트리거포인트 | trigger_point |

---

## 8. UI/UX 현황 (`index.html`)

### 8.1 추천 카드 상세 섹션 순서 (`renderTechniqueCard`)

2026-04-27 변경. UX 근거: 신입 PT의 최우선 불안은 "지금 잘 하고 있는가?"이므로, 환자 반응 확인을 최상단으로 이동.

```
이전 순서:
1. 📋 시술 방법 (technique steps)
2. 🎯 목표 구조물 (target muscles)
3. 🔍 환자 반응 확인 (patient feedback)

현재 순서:
1. 🔍 환자 반응 확인  ← 불안 즉시 해소
2. 📋 시술 방법
3. 🎯 목표 구조물
```

### 8.2 입력 영역

| 입력 항목 | 선택 방식 | 비고 |
|-----------|---------|------|
| 치료 부위 | 드롭다운 단일 선택 | MVP: 경추·요추만 활성화, 나머지 "Coming Soon" |
| 시기 (acuity) | 라디오 버튼 | acute / subacute / chronic |
| 증상 (symptom) | 라디오 버튼 | movement_pain / rest_pain / radicular_pain |
| 선호 MT 카테고리 | 체크박스 복수 선택 | 12개 카테고리, localStorage 저장 |

---

## 9. RLS 정책 요약

| 테이블 | SELECT | INSERT | UPDATE | DELETE |
|--------|--------|--------|--------|--------|
| `techniques` | 공개 테크닉: 전체 / 비공개: 인증 사용자 | is_verified 사용자만 | 본인 작성만 | 본인 작성만 |
| `technique_tags` | 인증 사용자 | — | — | — |
| `technique_stats` | 인증 사용자 | 트리거 전용 | 트리거 전용 | — |
| `ratings` | 본인 것 + 공유된 것 | 본인 | 본인 | 본인 |
| `usage_logs` | 본인 | 본인 | — | — |
| `user_favorites` | 본인 | 본인 | 본인 | 본인 |
| `user_profiles` | 인증 사용자 전체 | 본인 | 본인 | — |
| `community_cases` | 공개 + 본인 | 본인 | 본인 | 본인 |

**anon key 제한**: anon key는 RLS 정책에 따라 동작. `ratings` / `usage_logs` 등 WRITE 작업은 Supabase Auth 로그인 필수.

---

## 10. 개발 우선순위 — 단계별 로드맵

### Phase 1 — MVP (완료)

- [x] Supabase DB 연결 및 기법 데이터 마이그레이션 (001–016)
- [x] 추천 알고리즘 전문가 합의 기반 재작성 (CONDITION_CATEGORY_SCORES)
- [x] target_tags hard filter 구현
- [x] 카드 상세 섹션 순서 최적화
- [ ] `is_published = false` 테크닉 → 검토 후 `is_published = true` 일괄 전환
- [ ] anon key 환경변수 분리 (프로덕션 배포 전 필수)

### Phase 2 — 레이팅 시스템

- [ ] Supabase Auth 로그인 (이메일/소셜)
- [ ] `user_profiles` 생성 플로우 (회원가입 시 자격 입력)
- [ ] 별점 + 효과 평가 UI 컴포넌트
- [ ] `indication_accuracy` 피드백 UI (AI 추천 케이스 한정 노출)
- [ ] `usage_logs` 자동 기록 (추천 세션 ID 발급 포함)
- [ ] `recommendation_weight` 자동 갱신 트리거 동작 검증
- [ ] `recent_30d_*` 야간 재산출 스케줄 설정

### Phase 3 — 확장

- [ ] 전신 부위 테크닉 데이터 추가 (콘텐츠팀에서 제공)
- [ ] 즐겨찾기 + 컬렉션 기능
- [ ] 케이스 공유 커뮤니티 (`community_cases` 테이블 활성화)
- [ ] 치료 프로토콜 묶음 기능

---

## 11. 알려진 이슈 및 주의사항

### 11.1 스키마 불일치 — 확인 필요

| 이슈 | 위치 | 내용 |
|------|------|------|
| `evidence_level` 매핑 불일치 | `index.html` | DB ENUM(`level_1a`, `level_1b` 등)과 프론트엔드 legacy 값(`high`, `medium`, `low`)이 혼재. 프로덕션에서 DB ENUM으로 통일 권장 |
| `body_part` vs `body_region` 명칭 혼용 | `recommend.js` | `recommend.js` 내부 변수명은 `body_part`, DB 컬럼명은 `body_region`. 혼동 주의 |
| `is_published = false` 전체 | 마이그레이션 시드 데이터 | 모든 시드 데이터가 비공개 상태. 콘텐츠팀 검토 후 일괄 공개 처리 필요 |

### 11.2 RLS 및 보안

- anon key 클라이언트 노출은 Supabase 설계 방식이나, 민감한 쓰기 API는 service_role key를 서버에서만 사용
- `technique_stats`는 앱 레이어에서 직접 UPDATE 금지 — 트리거가 무결성 보장
- `techniques` INSERT 정책의 `is_verified = true` 조건으로 미인증 사용자 테크닉 추가 차단. 최초 시드는 service_role로 삽입

### 11.3 `pg_trgm` 확장

퍼지 한국어 이름 검색(`ILIKE`)에 필요. `schema.sql` 상단에 활성화 코드 포함되어 있으나, Supabase 대시보드 Database > Extensions에서도 수동 확인 필요.

---

## 12. 리서치 문서 현황 (`research/indication-research/`)

| 파일 | 내용 |
|------|------|
| `group-A-joint.md` | `joint_mobilization`, `mulligan` 인디케이션 매트릭스 |
| `group-B-soft-basic.md` | `mfr`, `art`, `ctm` 인디케이션 매트릭스 |
| `group-C-soft-special.md` | `deep_friction`, `trigger_point`, `anatomy_trains` 인디케이션 매트릭스 |
| `group-D-neural-special.md` | `d_neural`, `mdt`, `scs`, `pne` 인디케이션 매트릭스 |
| `INDICATION-RESEARCH-TEMPLATE.md` | 미래 리서치 에이전트용 표준 템플릿 |

---

## 13. 콘텐츠팀 연락 방법

### 13.1 신규 테크닉 데이터 요청

콘텐츠팀(technique-researcher 에이전트)에 요청 시:
- 경로: `research/techniques_research/[부위]-[카테고리].json`
- 신규 기법은 마이그레이션 SQL로 변환 후 `saas/migrations/` 에 추가

### 13.2 DB 스키마 변경 요청

1. 쟈르스에게 변경 요청 (변경 사항, 이유, 영향 범위 명시)
2. 쟈르스 → 콘텐츠팀 협의 → 승인 후 `schema.sql` 업데이트
3. 마이그레이션 스크립트는 개발팀에서 작성 후 쟈르스 검수

### 13.3 임상 콘텐츠 관련

테크닉 데이터의 임상적 정확성(금기증, 적응증, 근거 수준 등)은 KMO 콘텐츠팀(물리치료사 호스트 3인)이 최종 검토. 개발팀에서 임의 수정 불가.

---

*작성: technique-researcher (KMO 콘텐츠팀)*
*검수: 쟈르스*
*최종 업데이트: 2026-04-27 (v0.2 — 알고리즘 재작성, 016 마이그레이션, UX 개선 반영)*
*파일 경로: `C:/project/PT/KMovement Optimism/pt-prescription/saas/DEV-HANDOFF.md`*
