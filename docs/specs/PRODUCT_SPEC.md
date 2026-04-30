# PT 처방 도우미 — 제품 기획 명세서

## 1. 제품 개요

- **제품명:** PT 처방 도우미 (PT_prescription)
- **URL:** https://pt-prescription.vercel.app
- **GitHub:** https://github.com/Jass-Song/PT_prescription
- **대상:** 한국 초보 물리치료사 (novice PT)
- **미션:** 근거기반 도수치료 기법 및 운동 처방 추천으로 초보 PT의 임상 의사결정 지원

---

## 2. 핵심 문제 정의

한국 초보 물리치료사가 직면하는 문제:

- 임상 경험 부족으로 기법 선택에 어려움
- 교과서 지식과 실제 임상 적용 간의 갭
- 선배 PT에게 매번 물어봐야 하는 비효율
- 환자별/증상별 맞춤 기법 선택 기준 부재

---

## 3. 솔루션 개요

환자 증상을 입력하면 → 치료사가 선호하는 기법 범위 내에서 → Claude AI가 매우 구체적인 임상 지침과 함께 추천

---

## 4. 현재 구현 상태 (Phase 1 MVP)

### 4.1 기술 스택

- **Frontend:** HTML + CSS + JS (단일 파일)
- **Backend:** Vercel Serverless Function (api/recommend.js)
- **AI:** Claude Sonnet API (Anthropic)
- **DB:** Supabase (연결 예정)
- **배포:** Vercel (GitHub 연동 자동 배포)

### 4.2 사용자 흐름 (3단계)

**1단계 — 설정 (최초 1회)**

Manual Therapy 선택지 6개 중 최대 3개 선택:

- 관절가동술 (Maitland / Kaltenborn)
- 관절교정술 (HVLA)
- 연부조직 가동술
- 신경가동술
- McKenzie
- Mulligan

Exercise 선택지 8개 중 최대 3개 선택:

- 안정화 운동, 점진적 부하 운동, 근력 강화, 관절가동범위 운동
- 스트레칭, 자가도수/자기관리, 체중부하 운동, 재활 운동

선택값 localStorage에 저장

**2단계 — 환자 입력**

- 부위: 경추 / 요추
- 시기: 급성 (<6주) / 만성 (>6주)
- 증상: 움직임 시 통증 / 안정 시 통증 / 방사통

**3단계 — 추천 출력**

Manual Therapy 추천 (선호 기법 내):

- 환자 자세 / 치료사 손 위치 / 동작 방향·강도 / 목표 근육(해부학명) / 환자 피드백 신호

Exercise 추천 (선호 기법 내):

- 시작 자세 / 치료사 가이드 방법 / 처방(세트·반복) / 목표 근육 / 큐잉 문장

임상 메모 (초보 PT용)

### 4.3 AI 프롬프트 원칙

- 대상: 초보 물리치료사
- KMO 철학: 통증 ≠ 손상, 반카타스트로파이징
- "Calm things down, then build things back up" (Greg Lehman)
- 근거기반, 공포 유발 금지
- 해부학적 명칭 필수 포함

---

## 5. 제품 로드맵

### Phase 1 (현재) — AI 추천 MVP

- [x] 설정 화면 (선호 기법 선택)
- [x] 환자 입력 화면
- [x] Claude AI 상세 추천 출력
- [x] Vercel 배포
- [ ] 별점 평가 시스템 (구현 예정)

### Phase 2 — 기법 노드 + 별점 DB

**목표:** 치료사들의 평가 데이터 축적

**기법 노드(Technique Node) 구조:**

```
TechniqueNode {
  id: string
  name: string
  category: 'MT' | 'EX'
  avgRating: number (전체 치료사 평균 별점)
  useCount: number (사용 횟수)
  conditionScores: {
    region + acuity + symptom → effectivenessScore
  }
}
```

**별점 시스템:**

- 추천 결과 각 기법마다 1-5★ 평가 버튼
- Supabase DB에 저장
- 조건별(경추/요추 + 급성/만성 + 증상) 집계
- 전체 서비스 사용자의 평가 반영

**추천 로직 진화:**

```
현재: AI 지식 기반 추천
Phase 2: AI + DB 평점 반영 추천 (별점 높은 기법 우선)
```

**"다른 기법 보기" 기능:**

- 기본 추천이 맞지 않을 때 대안 기법 요청
- 1차: 별점 높은 순 추천
- 2차: 대안 기법 추천

### Phase 3 — 환자 ID + 개인화

**목표:** 환자별 치료 기록 및 맞춤 추천

**확장 기능:**

- 환자 ID 등록 (익명 또는 이름)
- 환자별 치료 기록 저장 (날짜, 사용 기법, 별점, 반응)
- 재방문 시: "지난번 이 환자에게 McKenzie 효과 좋았음" 알림
- 치료사별 + 환자별 이중 개인화

**미래 데이터 활용:**

- 조건별 최고 효과 기법 TOP 3 리포트
- 특정 환자 프로필에 최적화된 기법 추천
- 한국 PT 현장 임상 데이터 아카이브

---

## 6. 데이터베이스 설계 (예정 — Supabase)

### 테이블 구조

```sql
-- 기법 마스터 테이블
technique_nodes (
  id UUID PRIMARY KEY,
  name VARCHAR,
  category VARCHAR, -- 'MT' or 'EX'
  created_at TIMESTAMP
)

-- 평가 테이블
ratings (
  id UUID PRIMARY KEY,
  technique_id UUID REFERENCES technique_nodes,
  session_id UUID, -- 익명 사용자 ID
  stars INTEGER,   -- 1-5
  region VARCHAR,
  acuity VARCHAR,
  symptom VARCHAR,
  created_at TIMESTAMP
)

-- 환자 테이블 (Phase 3)
patients (
  id UUID PRIMARY KEY,
  clinic_id UUID,
  anonymous_name VARCHAR,
  created_at TIMESTAMP
)

-- 치료 기록 테이블 (Phase 3)
treatment_records (
  id UUID PRIMARY KEY,
  patient_id UUID REFERENCES patients,
  session_id UUID,
  technique_id UUID REFERENCES technique_nodes,
  stars INTEGER,
  notes TEXT,
  created_at TIMESTAMP
)
```

---

## 7. 수익 모델 (예정)

| 플랜 | 기능 | 가격 |
|------|------|------|
| 무료 | 월 20회 추천, 기본 기법 | 무료 |
| Pro | 무제한 추천, 별점 히스토리, 환자 기록 | 월 15,000원 |
| Clinic | 다중 치료사, 환자 DB, 분석 리포트 | 월 50,000원 |

---

## 8. 개발팀 (KMO Software Team)

| 역할 | 담당 |
|------|------|
| sw-lead | 소프트웨어팀 총괄 |
| sw-product-manager | 제품 기획 |
| sw-frontend-dev | UI/UX 개발 |
| sw-backend-dev | API 개발 |
| sw-clinical-translator | KMO 임상 지식 → 기능 명세 |
| sw-ux-researcher | PT 현장 UX 리서치 |
| sw-qa-tester | 테스트 |
| sw-devops | 배포/인프라 |
| sw-auth-specialist | 인증/결제 |
| sw-db-architect | DB 설계 |

---

## 9. KMO 연계 전략

- KMO 콘텐츠(에피소드, 카드뉴스)가 PT들에게 이 서비스를 알리는 마케팅 채널
- 서비스 내 KMO 철학(반카타스트로파이징) 적용 → 브랜드 일관성
- KMO 유료 강의 수강생에게 Pro 플랜 할인 제공 예정

---

## 10. 다음 액션 아이템

- [ ] Supabase 테이블 생성 (technique_nodes, ratings)
- [ ] 별점 UI 컴포넌트 추가 (index.html)
- [ ] 별점 저장 API 추가 (api/rate.js)
- [ ] 익명 세션 ID 생성 (UUID v4, localStorage)
- [ ] 별점 기반 추천 로직 반영 (recommend.js)

---

*문서 작성일: 2026-04-24*
*작성: KMO sw-product-manager*
