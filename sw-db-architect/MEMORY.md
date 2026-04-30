# sw-db-architect — 메모리 & 학습 로그

> 이 파일은 작업마다 누적됩니다. 매 작업 완료 후 해당 섹션을 업데이트하세요.

## 역할 한 줄 요약
PT 처방 도우미 데이터베이스 스키마 설계 & 마이그레이션 관리 — Supabase PostgreSQL 기반 임상 데이터 모델링

---

## 🗄️ DB 현재 상태 (2026-04-27 기준)

### 연결 정보
- **Project URL**: `https://gnusyjnviugpofvaicbv.supabase.co`
- **키**: `.env` 파일 참조 (`C:/project/PT/KMovement Optimism/.env`)

### 테이블 현황

| 테이블 | 행 수 | 상태 | 비고 |
|------|:---:|------|------|
| `techniques` | 194건 | ✅ 정상 | 활성 기법 포함 |
| `technique_categories` | 24건 | ⚠️ 정리 필요 | group_* 5개, 빈 카테고리 1개 |
| `user_profiles` | 1건 | ✅ 정상 | |
| `community_cases` | 0건 | ℹ️ 빈 테이블 | 기능 미구현 |
| `recommendation_sessions` | ❌ 없음 | 마이그레이션 미실행 | schema.sql에 DDL 있음 |
| `user_ratings` | ❌ 없음 | 마이그레이션 미실행 | |
| `technique_relationships` | ❌ 없음 | 마이그레이션 미실행 | |
| `user_technique_history` | ❌ 없음 | 마이그레이션 미실행 | |

### 마이그레이션 이력

| 파일 | 상태 | 내용 |
|------|------|------|
| 001~014 | ✅ 실행 완료 | 초기 스키마, 기본 데이터 |
| 015-exercise-neural-lumbar-cervical.sql | ✅ 실행 완료 | 운동·신경가동술·요추·경추 기법 추가, AT-SBL-DFL-Lumbar 포함 |
| 016-cervical-techniques-tags.sql | ✅ 실행 완료 | 경추 11개 신규 기법 + 13개 카테고리 태그 UPDATE |
| 017-user-settings-usage-logs.sql | ✅ 실행 완료 | 사용자 설정·사용 로그 |
| 018-cleanup-duplicates.sql | 🔲 작성 완료, 실행 대기 | 중복 기법 비활성화 (아래 참조) |

---

## ⚠️ 발견된 문제 & 처리 현황

### 1. category_exercise01 vs 전문 카테고리 중복 (017에서 처리)

`category_exercise01`(구버전 통합 운동 카테고리)에 있는 일부 기법이 신규 전용 카테고리와 중복:

| category_exercise01 기법 | 중복 카테고리 | 처리 |
|---|---|---|
| `MDT` (요추 맥켄지) | `category_mdt` → `MDT-Lumbar` | 017에서 비활성화 |
| `Cervical MDT` (경추 맥켄지) | `category_mdt` → `CervMDT` | 017에서 비활성화 |
| `PNE` (통증 신경과학 교육) | `category_pne` → `PNE-Combined` | 017에서 비활성화 |

**category_exercise01 잔여 기법 (정상 유지):**
MCE, DCFT, CPR, CSE, McGill Big 3, GA — 전용 카테고리 없음, recommend.js에서 사용 중

### 2. category_d_neural 내부 중복 (017에서 처리)

| 기법 | 처리 |
|---|---|
| `NM` (abbreviation) | 017에서 비활성화 |
| `NM-Sciatic` | 유지 |

### 3. category_iastm — 의도적 비활성화 (현재 OK)

- 카테고리 `is_active=false`
- 13건 중 4건만 active (경추·요추 부위만): IASTM-CLM, IASTM-CervPost, LumbIASTM-ES, LumbIASTM-MF
- recommend.js `CONDITION_CATEGORY_SCORES`에 미포함 → 경추·요추 범위 제한 의도적
- **향후 어깨·하지 범위 확장 시** active 처리 + 알고리즘 추가 필요

### 4. group_* 카테고리 5개 — 무해, 방치

`group_joint_mobilization`, `group_soft_tissue`, `group_exercise`, `group_neural`, `group_special`
- recommend.js에서 미사용
- techniques 테이블에 소속 기법 없음
- 삭제하거나 그냥 방치해도 무해

### 5. category_f_therapeutic_exercise — 빈 카테고리 (017에서 처리)

- 기법 0건, recommend.js 미사용
- 017에서 `is_active=false` 처리

---

## 📊 techniques 카테고리별 분포 (2026-04-27)

| 카테고리 | 총 기법 | active | published |
|---------|:---:|:---:|:---:|
| category_anatomy_trains | 10 | 10 | 10 |
| category_art | 21 | 21 | 21 |
| category_ctm | 11 | 11 | 11 |
| category_d_neural | 2 | 2 | 2 |
| category_deep_friction | 13 | 13 | 13 |
| category_ex_aerobic | 2 | 2 | 2 |
| category_ex_bodyweight | 4 | 4 | 4 |
| category_ex_neuromuscular | 3 | 3 | 3 |
| category_ex_resistance | 4 | 3 | 4 |
| category_exercise01 | 9 | 9 | 9 |
| category_iastm | 13 | 4 | 13 |
| category_joint_mobilization | 20 | 20 | 20 |
| category_mdt | 7 | 7 | 7 |
| category_mfr | 22 | 22 | 22 |
| category_mulligan | 22 | 22 | 22 |
| category_pne | 1 | 1 | 1 |
| category_scs | 7 | 7 | 7 |
| category_trigger_point | 23 | 23 | 23 |
| **합계** | **194** | **185** | **194** |

> `category_ex_resistance` 1건 is_active=false 확인 필요

---

## 🏷️ 표준 태그 체계 (016 적용 완료)

### symptom_tags
`movement_pain`, `hypomobile`, `morning_stiffness`, `disc_related`, `rest_pain`, `lbp_nonspecific`, `cervicogenic_headache`, `radicular_pain`, `referred_pain`

### target_tags (hard filter 적용)
`acute`, `subacute`, `chronic`, `muscle_hypertonicity`, `sensitized`

> recommend.js에서 acuity → target_tags hard filter 작동 중:
> - 급성 환자 → `acute` 없는 기법 제외
> - 아급성 → `subacute` 없는 기법 제외
> - 만성 → `chronic` 없는 기법 제외
> - target_tags 비어있는 기법은 필터 통과 (하위 호환)

### contraindication_tags
`fracture`, `malignancy`, `instability`, `neurological_deficit`, `osteoporosis`, `anticoagulants`, `active_infection`, `vbi`, `upper_cervical_instability`

---

## 📋 CONDITION_CATEGORY_SCORES 현황 (recommend.js)

12개 MT 카테고리 × 9컨디션 (acuity × symptom) — 2026-04-27 전면 재작성

```
급성 + 움직임통증: mulligan(3), mdt(3), scs(3), d_neural(2), joint_mobilization(1), mfr(1), ctm(1), trigger_point(1), pne(1)
급성 + 안정통증: scs(3), mdt(2), d_neural(1), pne(1)
급성 + 방사통: d_neural(3), mdt(3), mulligan(1), scs(1), pne(1)
아급성 + 움직임통증: joint_mobilization(3), mdt(3), mulligan(2), mfr(2), art(2), deep_friction(2), trigger_point(2), ctm(2), d_neural(2), pne(2), scs(2)
아급성 + 안정통증: scs(2), ctm(2), trigger_point(2), mdt(2), pne(2), mfr(1), art(1), deep_friction(1), d_neural(1), mulligan(1)
아급성 + 방사통: d_neural(3), mdt(3), mulligan(2), scs(1), pne(1), mfr(1), art(1), deep_friction(1)
만성 + 움직임통증: mfr(3), art(3), deep_friction(3), trigger_point(3), joint_mobilization(3), mdt(2), anatomy_trains(2), mulligan(2), ctm(2), d_neural(2), pne(3), scs(2)
만성 + 안정통증: ctm(3), pne(3), trigger_point(2), art(2), mfr(2), scs(1), mdt(1), deep_friction(2)
만성 + 방사통: d_neural(2), mdt(2), pne(2), art(2), mfr(1), deep_friction(1), trigger_point(1)
```

---

## 축적된 스킬 & 패턴

- body_region은 NOT NULL — Anatomy Trains 기법도 'lumbar'/'cervical'로 지정 필요 (015/016에서 NULL→부위명 수정 경험)
- ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL 패턴으로 UPSERT 사용
- abbreviation은 기법의 고유 키로 활용 (id 대신 WHERE 조건으로 사용)
- category_key로 technique_categories 서브쿼리 참조: `(SELECT id FROM technique_categories WHERE category_key = '...')`

## 피드백 로그
| 날짜 | 작업 | 받은 피드백 / 수정 내용 | 반영 여부 |
|------|------|----------------------|----------|
| 2026-04-27 | 015/016 마이그레이션 | body_region NULL → NOT NULL 제약 에러 → 'lumbar'/'cervical'로 수정 | ✅ |

## 완료 작업 이력
| 날짜 | 작업명 | 결과물 | 핵심 학습 |
|------|--------|--------|----------|
| 2026-04-27 | 016 태그 표준화 마이그레이션 | 13개 카테고리 태그 UPDATE + 경추 11개 기법 INSERT | body_region NOT NULL 주의 |
| 2026-04-27 | DB 상태 감사 | 중복 4건 발견 (MDT×2, PNE×1, NM×1) | exercise01 vs 전문 카테고리 중복 패턴 |
| 2026-04-27 | 017 정리 마이그레이션 | 중복 비활성화 SQL 작성 | 삭제보다 is_active=false 비활성화 원칙 |

## 주의 사항 (경험 학습)
- body_region은 NOT NULL ENUM — Anatomy Trains처럼 multi-region 기법도 주 부위명('lumbar'/'cervical') 지정 필수
- category_exercise01은 구버전 통합 카테고리 — 신규 전용 카테고리(mdt/pne 등) 추가 시 중복 발생 주의
- 마이그레이션 기법 삭제 금지 — is_active=false로 비활성화, 히스토리 보존
- IASTM은 의도적 비활성 (경추·요추 범위 제한) — 함부로 활성화하지 말 것
