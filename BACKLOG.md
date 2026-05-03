# PT 처방 도우미 — 백로그 (Backlog & Future Plans)

> **소프트웨어팀 백로그**. 작업 시작 전 쟈르스에게 우선순위 확인.
> 글로벌 백로그(`.jarvis/BACKLOG.md`) 동기화는 쟈르스가 주기적으로 진행.
>
> 마지막 업데이트: 2026-05-02

---

## 📋 현재 백로그 (14개)

### 📊 MVP 분석 측정 (다음 우선) ⭐ 다음 작업
> **컨텍스트**: MVP 출시 전 사용자 행동 분석 인프라 보강 필요. 출시 후 데이터가 모이기 전에 수집 구조부터 갖춰야 함.

- [ ] **[NEXT][high] focus_pillars 로깅 (Migration 049)**
  - `recommendation_logs.focus_pillars TEXT[]` 컬럼 추가
  - `api/recommend.js`에서 INSERT 시 focus_pillars 같이 저장
  - 분석: 어느 pillar 조합이 가장 자주 선택되는지, 효과는?
  - 영향 범위: Migration 1개 + recommend.js 1줄

- [ ] **[NEXT][high] 클라이언트 이벤트 로깅 인프라**
  - **Migration 050**: `client_events (id, user_id, event_type, payload jsonb, created_at)` + RLS
  - **`api/telemetry.js`**: POST 이벤트 수집 엔드포인트 (fire-and-forget)
  - **`index.html` hooks**: 6개 핵심 이벤트 트래킹
    - `card_expand` — 자세히 보기 클릭
    - `card_feedback_click` — 별점 모달 오픈
    - `refresh_category` — "다른 기법 보기"
    - `star_rating_submit` — 별점 저장
    - `session_start` — 앱 진입
    - `pillar_select` — pillar 칩 클릭
  - 영향 범위: ~200줄 추가, 5개 파일

- [ ] **[NEXT][medium] 재시도·이탈 패턴 추적**
  - 같은 조건으로 재추천 빈도 (만족도 proxy)
  - "다른 기법 보기" 호출률
  - 결과 화면 평균 체류 시간 (page_unload 이벤트)

- [ ] **[NEXT][medium] 분석 SQL 뷰·문서**
  - `saas/docs/ANALYTICS-QUERIES.md` 신설
  - Funnel: 가입 → 첫 추천 → 재방문 → 별점
  - Cohort: 주간 신규/리텐션
  - Pillar 사용 패턴
  - 카테고리·기법 인기도
  - 부위별·시기별 사용 분포

- [ ] **[NEXT][low] A/B 테스트 인프라**
  - 베타 단계엔 불필요, 사용자 풀 커지면 검토
  - `experiments` 테이블 + variant 할당 로직

### 🤖 알고리즘·임상
- [ ] **피드백 점수를 추천 알고리즘에 통합**
  - 우선순위: high (정확도 직접 영향)
  - 트리거: 별점 데이터 수십~수백 건 누적 시
  - 공식 안: `ruleScore × 0.5 + vectorScore × 0.3 + feedbackScore × 0.2`
  - 관련 파일: `api/recommend.js`, `api/feedback.js`, `saas/migrations/041-ratings-table.sql`

- [ ] **4 부위(어깨/무릎/엉덩/발목) × 급성 적응증 기법 enrichment**
  - 우선순위: medium (4부위 급성 시나리오 카드 부족 보완)
  - 담당: sw-clinical-translator
  - 후보: 어깨 SCS 5개·MDT 4개·신경 슬라이더 3개 / 무릎 SCS 5개·MDT 2개·신경 4개 / 엉덩 SCS 4개·신경 2개 / 발목 SCS 4개·MDT 2개·신경 4개

### 🎯 사용자 행동·분석
- [ ] **사용자 즐겨찾기 pillar 조합 저장**
  - 자주 쓰는 [관절+운동] 같은 조합 저장
  - 우선순위: low

- [ ] **Pillar 선택 행동 분석 대시보드**
  - 어느 pillar 조합이 가장 자주 선택되는지
  - 우선순위: low (어드민 대시보드 확장)

### 💎 UX 개선 (사용량·알림·트래킹) — 5/3 대표님 요청 반영
- [ ] **사용량 표시 UI** ("오늘 12/20회 사용")  ⭐ **5/3 재요청**
  - 우선순위: **high (출시 후 즉시)** — 베타 테스터가 한도 모르고 21번째 시도하면 혼란
  - 데이터 이미 응답에 포함 (`usedToday`, `dailyLimit`)
  - 위치: 메인 화면 상단/하단 (예: "오늘 5/20 사용 · 15회 남음")

- [ ] **한도 도달 80%/100% 알림**
  - 80%: 사전 안내 toast ("⚠️ 오늘 한도 80% 도달")
  - 100%: 차단 시 다음 리셋 시각 명시 ("내일 0시(KST) 리셋")
  - 우선순위: medium

- [ ] **추천 응답 시간 사용자 가시화** ⭐ **5/3 신규**
  - 현재 P50 8.4s / P95 11s — 빈 화면이라 사용자가 "멈췄나?" 의심
  - 옵션 A: progress bar + "추천 생성 중... (보통 8초)"
  - 옵션 B: 단계 표시 ("🔍 기법 검색 → 🤖 임상 메모 작성 → ✅ 완료")
  - 데이터: `recommendation_logs.latency_ms` 이미 기록 중
  - 우선순위: high (UX 첫인상)

- [ ] **"다른 기법 보기" 클릭 트래킹** ⭐ **5/3 신규**
  - 사용자가 몇 번 다시 추천 받았는지 기록 — 만족도 proxy
  - 카드별 또는 세션별 카운트
  - NEXT-2 (Migration 052 client_events) 의 `refresh_category` hook 과 통합
  - UI: 옵션 — "이번 추천에 N번 새로고침" 또는 단순 백엔드 트래킹만

- [ ] **사용자 history 페이지** (본인 추천 이력)
  - 데이터 소스: `recommendation_logs` (이미 존재)
  - 일자별·부위별 필터
  - 우선순위: medium

### 💰 비즈니스
- [ ] **결제 연동 (Stripe / 토스페이먼츠)**
  - pro 등급 자동 전환
  - 트리거: 베타 종료 + 비즈니스 모델 결정
  - 선결: 가격 정책, 환불 규정, 결제 공급사 결정
  - 우선순위: high (베타 종료 후)

### 🧹 잡 정리
- [ ] **favicon.ico 추가**
  - 브라우저 탭 아이콘 + 콘솔 404 노이즈 제거
  - 우선순위: low

---

## ✅ 최근 완료 (2026-05-01 ~ 02)

| 날짜 | PR | 내용 |
|---|---|---|
| 2026-05-01 | #11 | 디버그 응답 명확화 + pgvector 그래프 |
| 2026-05-01 | #12 | 모달리티 카드 + 카테고리 다양성 + 357개 백필 |
| 2026-05-02 | #13 | 3박자 pillar 모델 + 선택 UI + recommendations[] |
| 2026-05-02 | #14 | Pillar 내부 필터 (advanced picker) |
| 2026-05-02 | #15 | Pillar 카드 렌더링 (primary + related) |
| 2026-05-02 | #16 | Legacy 모드도 pillar 카드 적용 |
| 2026-05-02 | #17 | LLM 프롬프트 pillar 단위 재구성 |
| 2026-05-02 | #18 | 사용자 등급 차등 한도 + KST 시간대 정정 |
| 2026-05-02 | #19 | tier 컬럼을 user_profiles로 이전 |
| 2026-05-02 | #20 | tier_updated_at 트리거 |
| 2026-05-02 | #21 | checkAdmin 단순화 (access 이슈) |
| 2026-05-02 | #22 | localStorage 세션 키 자동 탐지 |
| 2026-05-02 | #23 | 등급별 필터 + 인라인 등급 변경 UI |

---

## 🔗 관련 위치

- **에이전트별 TODO**: `sw-backend-dev/TODO.md`, `sw-db-architect/TODO.md` 등
- **글로벌 백로그** (외부): `C:/project/PT/KMovement Optimism/.jarvis/BACKLOG.md`
- **노션 동기화**: 쟈르스가 주기적으로 "Backlog & Future Plans" 페이지에 반영

---

## 백로그 항목 추가 양식

새 항목 추가 시 아래 양식 사용 권장:

```markdown
- [ ] **[제목 한 줄]**
  - 우선순위: high / medium / low
  - 담당팀: sw-* (또는 미정)
  - 배경: 왜 필요한지
  - 할 일: 구체적으로 무엇을
  - 관련 파일: 경로
  - 트리거 시점: 언제 시작 가능한지
```
