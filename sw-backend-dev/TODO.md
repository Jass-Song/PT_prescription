# sw-backend-dev — 작업 체크리스트

> **사용 규칙**
> - 작업 시작 시 `## 🔄 진행 중` 섹션 아래에 새 작업 항목 추가
> - 완료 항목은 `- [ ]` → `- [x]` 체크
> - **매주 월요일**: `- [x]` 완료 항목들을 `## 📦 주간 아카이브` 표에 1줄 요약 후 진행 중 섹션에서 삭제
> - 완료 여부 확인 요청 시 → 이 파일 먼저 확인 후 답변

---

## 🔄 진행 중 / 미완료 작업

### ⭐ 다음 작업 (NEXT) — MVP 분석 측정 인프라

- [ ] **[NEXT-1][high] Migration 049 — focus_pillars 로깅**
  - `recommendation_logs.focus_pillars TEXT[]` 컬럼 추가
  - `api/recommend.js`에서 INSERT 시 focus_pillars 저장
  - 영향 범위: 작음 (Migration 1 + recommend.js 1줄)

- [ ] **[NEXT-2][high] 클라이언트 이벤트 로깅**
  - Migration 050 — `client_events` 테이블 (id, user_id, event_type, payload jsonb, created_at) + RLS
  - `api/telemetry.js` — POST 엔드포인트 (fire-and-forget, 인증 필요)
  - `index.html` — 6개 hook: card_expand, card_feedback_click, refresh_category, star_rating_submit, session_start, pillar_select
  - 영향 범위: ~200줄 추가

- [ ] **[NEXT-3][medium] 재시도·이탈 패턴 추적**
  - 같은 조건 재추천 빈도 (만족도 proxy)
  - "다른 기법 보기" 호출률
  - 결과 화면 체류 시간 (page_unload 이벤트)

- [ ] **[NEXT-4][medium] 분석 SQL 뷰·문서**
  - `saas/docs/ANALYTICS-QUERIES.md` 신설
  - Funnel (가입→첫추천→재방문→별점)
  - Cohort (주간 신규/리텐션)
  - Pillar·카테고리·기법 인기도
  - 부위별·시기별 사용 분포

- [ ] **[NEXT-5][low] A/B 테스트 인프라** — 베타 단계엔 불필요, 추후 검토

---

- [x] [2026-04-28] Vercel Dashboard → VOYAGE_API_KEY 환경변수 등록 (대표님 수동 등록 완료, 2026-05-01 확인)
- [x] [2026-04-28] embed-techniques.js 실행 완료 — technique_embeddings 180개 적재 완료
- [x] [2026-04-28] recommend.js d_neural 503 버그 픽스 — fetchActiveTechniques null/[] 반환 분리
- [x] [2026-05-01] 9개 컨디션 시나리오 하이브리드 추천 결과 검증 — 9/9 통과 (정확일치 2 + 통과 4 + 부분통과 3). SCENARIO-VERIFICATION.md 매트릭스 갱신.
- [x] [2026-05-01] 카테고리 다양성 강제 로직 추가 — selectTopTechniquesGlobally maxPerCategory 도입 (PR #12 머지)
- [x] [2026-05-02] 한국 도수치료 3박자 모델 — pillar 기반 recommendations[] (PR #13)
- [x] [2026-05-02] B안 — pillar 선택 시 advanced 카테고리 picker 자동 필터링 (PR #14)
- [x] [2026-05-02] Pillar 카드 렌더링 — primary + related 계층 (PR #15)
- [x] [2026-05-02] Legacy 모드도 pillar 카드 렌더링 적용 (PR #16)
- [x] [2026-05-02] LLM 프롬프트 pillar 단위 재구성 (PR #17)
- [x] [2026-05-02] 사용자 등급 차등 한도 + KST 시간대 정정 (Migration 046)
- [x] [2026-05-02] tier 컬럼을 user_profiles로 이전 (Migration 047, user_tiers 별도 테이블 폐기)
- [x] [2026-05-02] tier_updated_at 자동 추적 (Migration 048, 트리거 기반)

## 📋 백로그 (장기·향후 작업)

- [ ] **[backlog] 피드백 점수를 추천 알고리즘에 통합**
  - **배경**: 현재 별점 피드백은 `technique_feedback` 테이블에 수집만 되고 추천 점수에 미반영
  - **할 일**: 같은 조건(region × acuity × symptom)에서의 기법별 평균 별점 집계 → 정규화 → 스코어 공식에 추가
  - **공식 안**: `ruleScore × 0.5 + vectorScore × 0.3 + feedbackScore × 0.2`
  - **Cold start 처리**: 별점 N개 미만 기법은 feedbackScore 가중치 0 (또는 데이터 충분할 때까지 기존 공식 유지)
  - **선결 조건**: 피드백 데이터 충분량 누적 (수십 ~ 수백 건/기법). 데이터 적을 때 적용하면 노이즈 큼
  - **관련 파일**: `api/recommend.js` (스코어링), `api/feedback.js` (데이터 소스), `saas/migrations/041-ratings-table.sql`
- [ ] **[backlog] LLM 프롬프트 pillar 단위 재구성**
  - 현재: LLM이 후보 6개 중 3개 MT 선택. pillar 분류는 후처리에서.
  - 미래: 프롬프트에 pillar별 candidate section 분리 → LLM이 각 pillar에서 PRIMARY 1개씩 선택
  - 효과: 토큰 절약 + pillar 보장 강화
  - ✅ **완료 (PR #17, 2026-05-02)** — focusPillars 명시 시 pillar 단위 LLM 프롬프트 적용
- [ ] **[backlog] 4 부위(어깨/무릎/엉덩/발목) × 급성 적응증 기법 enrichment**
  - 어깨 SCS 회전근개 5개, MDT 4개, 신경 슬라이더 3개
  - 무릎 SCS 5개, MDT 2개, 신경 슬라이더 4개
  - 엉덩 SCS 4개, 신경 슬라이더 2개
  - 발목 SCS 4개, MDT 2개, 신경 슬라이더 4개
  - 임상 검토(sw-clinical-translator) 후 마이그레이션 SQL 작성
- [ ] **[backlog] 사용자 즐겨찾기 pillar 조합 저장** — 자주 쓰는 [관절+운동] 같은 조합 저장
- [ ] **[backlog] Pillar 선택 행동 분석 대시보드** — 어느 pillar 조합이 가장 자주 선택되는지

### UX 개선 (사용량·알림)
- [ ] **[backlog] 사용량 표시 UI** — 메인 화면에 "오늘 12/20회 사용" 같은 일일 한도 진행도 표시
  - **관련**: `api/recommend.js` 응답 (`usedToday`, `dailyLimit` 이미 포함됨), `index.html` 상단/하단 표시
- [ ] **[backlog] 한도 도달 80%/100% 알림** — toast 또는 이메일/푸시 알림
  - 80%: "한도 곧 소진" 사전 안내 / 100%: 차단 시 명확한 다음 리셋 시각 안내
- [ ] **[backlog] 사용자 history 페이지** — 본인 추천 이력 일자별·부위별 조회
  - **데이터 소스**: `recommendation_logs` (이미 존재)
  - **UI**: 메인 앱에 "내 이력" 탭 추가, 일자별 필터 + 부위/카테고리 통계

### 비즈니스 (결제·구독)
- [ ] **[backlog] 결제 연동 (Stripe / 토스페이먼츠)** — pro 등급 자동 전환
  - **트리거**: 베타 종료 + 비즈니스 모델 결정 후
  - **연계**: `user_profiles.tier` + 구독 상태 컬럼 추가, 만료일 추적, 갱신 알림
  - **선결**: 가격 정책, 환불 규정, 결제 공급사 결정

### 잡 정리
- [ ] **[backlog] favicon.ico 추가** — 브라우저 탭 아이콘 + 콘솔 404 노이즈 제거

---

## ✅ 2026-04-28 완료 작업

- [x] saas/scripts/embed-techniques.js 생성 — Voyage AI voyage-3-lite 임베딩 생성 스크립트 (BATCH_SIZE=3, 21초 대기)
- [x] api/recommend.js — getQueryEmbedding() 함수 추가 (Voyage AI API 호출)
- [x] api/recommend.js — fetchVectorSimilarities() 함수 추가 (match_techniques RPC 호출)
- [x] api/recommend.js — 하이브리드 점수 산정 구현 (룰 60% + 벡터 40%)
- [x] pt-prescription/.env 파일 생성 (VOYAGE_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
- [x] pt-prescription/.gitignore에 .env 추가

---

## 📦 주간 아카이브

> 완료된 주차는 이 표에 1줄 요약. 상세 내용은 MEMORY.md 참조.

| 주차 | 작업명 | 에피소드 | 완료일 | 결과물 |
|------|--------|---------|--------|--------|
