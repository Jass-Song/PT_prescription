# Retention & Diversity 전략 — 86 큐레이션 고정 시 다양성 확보

> 작성: 2026-05-12 (jarvis ↔ 대표님 세션 후 문서화)
> 컨텍스트: 베타 출시 직전, Tier 1 86 기법 큐레이션 락인 상태. 
> PT 가 몇 세션 사용 후 추천 패턴 학습 → 의존성 미형성 우려.
> 대표님 제약: "기법은 추가하지 말고 86 그대로 유지하면서 다양성 확보".

## 핵심 메타 전환

**Before**: 기법 = 데이터 (정적)  
**After**: 기법 = 맥락·적용·시점에 따라 살아 움직이는 권고

```
같은 환자 → 다른 시간축 → 다른 추천 (회복 단계)
같은 시나리오 → 다른 PT → 다른 추천 (개인 outcome 패턴)
같은 기법 → 다른 환자 → 다른 적용 노트 (persona)
같은 응답 → 다른 횟수 → 다른 강조 (이번엔 이 측면)
```

## 8가지 다양성 강화 방법 (기법 86 유지)

### ⭐ 1. 환자별 맥락 보존 — Patient timeline tracking
**가장 강력**. 현재는 한 번 추천 → 끝. 같은 환자 재방문 시 시스템이 모름.

**개선**:
- `patient_visits` 테이블 신설 (patient_id + visit_no + previous_outcomes + 추천 history)
- PT 가 환자 식별 (이름/별명/번호 입력) → 시스템이 "이 환자 3번째 방문" 인지
- LLM 프롬프트에 history 주입:
  - "Session 1: SNAG 시술 → outcome=good"
  - "Session 2: 같은 환자, 진행성 — 강도 ↑ 또는 운동 비중 ↑"
- **효과**: 같은 86 안에서도 회복 phase 따라 다른 조합·강도·강조

**난이도**: 중 (테이블 신설 + UI 환자 식별 + LLM context 확장)  
**의존성 효과**: 매우 큼 (환자 차트가 시스템 안에 누적되면 떠나기 어려움)

**구현 상태 (5/12)**: ✅ 완료 — 마이그 059 + PR #58 (Patient Timeline)

### ⭐ 2. PT 별 outcome 패턴 학습 — Personalized re-ranking
같은 86개, **PT 별 다른 우선순위**.

**원리**:
- PT A 는 SNAG outcome 평균 0.85 → SNAG 우선 추천
- PT B 는 SNAG 시술 익숙치 않아 outcome 평균 0.50 → MFR/TrP 우선 추천
- 같은 입력 (cervical/acute/방사통) 이라도 PT 마다 다른 5건 노출

**구현**: `recommendation_logs.user_id` 활용 → 가중치 공식에 user-specific outcome 가산점 추가 (예: 글로벌 weight × 0.7 + user weight × 0.3)

**난이도**: 중 (DB 함수 + recommend.js 가중치 로직)  
**효과**: PT 가 "내 도구" 라고 느끼는 결정적 순간

**구현 상태**: 🔲 미구현 (베타 데이터 누적 후 도입)

### 3. Dosage 변주 — 같은 기법, 다른 강도·횟수
86 기법 각각에 **3 단계 dosage variant** 정의:
- **초기 (acute reactive)**: Grade I~II / 3~5회 / hold 5초
- **중기 (subacute)**: Grade III / 5~8회 / hold 10초
- **후기 (chronic)**: Grade IV~V / 8~12회 / hold 15초 + 자가 처방

**기법 추가 없이** dosage 변주만으로 한 기법 → 3개 표정.

**구현**: `techniques.dosage_variants` jsonb 컬럼 추가 (또는 기존 technique_steps 확장). LLM 프롬프트에서 acuity 따라 적절한 dosage 선택 명시.

**난이도**: 중 (마이그 + LLM 프롬프트 보강)  
**효과**: 다양성 + 임상 정확도

**구현 상태**: 🔲 미구현

### 4. Persona 맞춤 적용 노트 — Patient persona augmentation
PT 입력 단계에 환자 persona 옵션 추가 (선택):
- 직업: 사무직 / 수공업 / 운동선수 / 노인
- 활동 수준: 좌식 / 보통 / 활발
- 핵심 우려: 통증 완화 / ROM 회복 / 기능 복귀

**같은 기법 추천이지만 clinical_notes 가 persona 별로 다름**:
- 사무직 + 경추 SNAG → "책상에서 1시간 작업 시 SNAG self-treatment 2분 권고"
- 운동선수 + 경추 SNAG → "운동 전 워밍업으로 SNAG 결합, 강도 ↑ 가능"

**구현**: LLM 프롬프트에 persona augmentation 블록 추가 (54 시나리오 매트릭스 확장)  
**난이도**: 낮~중  
**효과**: PT 가 환자 맞춤 진료 자신감 ↑

**구현 상태**: 🔲 미구현

### 5. 임상 추론 설명 강화 — Clinical reasoning narrative
이미 LLM 프롬프트에 부분 구현 (54 시나리오 매트릭스 augmentation — PR #55). 추가 강화:
- 매 추천에 "왜 이게 이 환자에 맞는가" 1~2줄
- 출처 인용 (APTA CPG / Cochrane / KAOMPT)
- 매번 다른 측면 강조 (이번엔 CPG / 다음엔 outcome 패턴 / 또 다음엔 KMO 메시지)

**같은 기법이라도 매번 다른 인사이트 → PT 가 도구 통해 배움 → dependency**.

**구현**: LLM 프롬프트 schema 확장 (clinicalNote 필드에 `reasoning_facet` 추가)  
**난이도**: 낮  
**효과**: PT 학습 효과 = 가장 강력한 의존성 (PT 가 "이 도구로 임상 추론 늘어남")

**구현 상태**: 🟡 부분 구현 (54 시나리오만 — 매번 다른 측면 강조는 미구현)

### 6. 회복 단계별 progression template
환자 같은데 시간 따라:
- **Session 1 (acute)**: Maitland Grade I~II + MFR 부드럽게 + 운동 minimal + 자세 교육
- **Session 2 (subacute, day 7~14)**: Grade III + Mulligan SNAG + 등척성 운동 추가
- **Session 3 (subacute~chronic, day 14+)**: 자가 운동 처방 중심 + 도수 빈도 ↓
- **Session 4+ (chronic)**: 기능 회복 운동 + 도수 maintenance

**같은 86 기법이지만 progression rule 따라 매 세션 추천 변화**.

**구현**: LLM 프롬프트에 session phase 인식 + 단계별 강조 룰  
**난이도**: 중 (Patient timeline tracking — #1 과 연계)

**구현 상태**: 🟡 #1 완료로 기반 마련됨, progression template 자체는 미구현

### 7. Variety 강제 룰 — Anti-repetition
LLM 프롬프트에 명시:
- "지난 2 세션 동일 환자에 사용한 기법 반복 시 → 대안 카테고리 1개 이상 포함"
- "같은 PT 가 1주 내 같은 시나리오 3회 호출 시 → discovery option 1개 포함"

**같은 86 안에서도 의도적 다양성 강제**.

**구현**: 추천 응답 생성 전 LLM 프롬프트에 최근 use history 인용  
**난이도**: 낮 (recommendation_logs 활용 + 프롬프트 룰 추가)  
**효과**: 패턴 인지 방지

**구현 상태**: 🔲 미구현

### 8. Discovery / alternative view — 추천 옆에 대안 노출
현재: top 5 기법 추천 → 끝  
**개선**: 각 카드 옆에 "alternative: 같은 효과 다른 기법" 1건 노출
- 예: Mulligan SNAG 추천 → 옆에 "또는: Maitland Grade III PA" 작은 카드
- PT 가 선택권 행사 — 시스템에 종속이 아닌 도구로 사용 (역설적으로 의존성 ↑)

**구현**: recommend.js 응답에 alternatives 필드 추가  
**난이도**: 낮~중

**구현 상태**: 🔲 미구현

---

## 우선순위 추천 (베타 데이터 누적 후 도입 로드맵)

| 단계 | 항목 | 효과 | 상태 |
|---|---|---|---|
| **Week 1~2 (즉시)** | #5 임상 추론 설명 강화 | 즉시 PT 학습 체감, LLM 프롬프트만 변경 | 🟡 부분 |
| **Week 1~2 (즉시)** | #7 Variety 강제 (anti-repetition) | recommendation_logs 활용, 프롬프트 룰 | 🔲 |
| **Week 3~4** | #1 환자 timeline tracking | DB 신설, 가장 큰 가치 | ✅ 완료 |
| **Week 3~4** | #6 progression template | #1 의존 | 🟡 기반만 |
| **Month 2** | #2 PT 별 outcome 패턴 학습 | 평가 데이터 누적 후 | 🔲 |
| **Month 2** | #3 dosage 변주 | 임상 검토 필요 (sw-clinical-translator) | 🔲 |
| **Month 2~3** | #4 persona 맞춤 | LLM 프롬프트 확장 | 🔲 |
| **Month 3** | #8 alternative view | UX 보강 | 🔲 |

---

## 가장 큰 인사이트

**기법 수가 부족한 게 아니라, 같은 기법을 "다르게 보여주는 차원"이 부족했던 것입니다**.

86개 × 다음 차원들 곱셈으로 다양성 폭발 가능:
- 환자 timeline (3~5 phase) ×
- PT outcome 패턴 (개인화) ×
- Persona (4~5 종) ×
- Dosage (3 단계) ×
- Reasoning facet (3~4 측면)

= **86 × 수십 가지 표현** → PT 가 "같은 기법인데 매번 다른 가치"

베타에서 데이터 누적되는 동안 이 차원들 하나씩 도입하면 됩니다. 베타 시작 시점엔 **현재 상태 그대로** 충분하고, Week 1~2 에 #5 (임상 추론 강화) + #7 (anti-repetition) 만 추가해도 큰 변화 체감 가능합니다.

---

## 패턴 인지 vs 도구 성장 — 핵심 방어 메커니즘

"패턴 인지 → 떠남" 막는 가장 강력한 방법은 **"도구가 사용자보다 더 빨리 성장"**:

- 사용자가 시스템 패턴을 인지하는 속도 < 시스템이 새 환자·시나리오·기법을 학습하는 속도 → **PT 가 매주 새로운 가치 발견**
- 알고리즘 학습 루프 (이미 가동) + 큐레이션 점진 확대 + 임상 추론 설명 — 이 셋의 결합

베타 4주 차에 평가 데이터 ~500건 누적되면 Track D (알고리즘 튜닝) 본격 진입 → **개인화 추천** (PT 별로 outcome 패턴이 달라서 같은 입력에도 다른 추천 가능) → 도구가 "내 환자에 맞춰진 비서" 같이 느껴지면 churn 방어.

---

## 관련 결정·구현

- **5/12 결정**: Patient Timeline (#1) 즉시 구현 → PR #58 머지 완료
- **5/12 결정**: 86 큐레이션 락인 (마이그 056b 적용 완료)
- **베타 출시 다음 주 예정** — Week 1~2 에 #5, #7 우선 도입 검토
