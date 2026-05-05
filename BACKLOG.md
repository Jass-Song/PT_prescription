# PT Prescription (SW팀) 백로그

> SW팀 미래 할 일 큐. 저녁 마감 시 .jarvis/MASTER-BACKLOG.md로 집계됨.

---

## [2026-05-03] sw-lead -- 추천 응답 시간 사용자 가시화

**Priority**: medium
**Background**: P50 8.4s / P95 11.2s -- 사용자가 빈 화면 보며 기다리는 시간. 현재 latency_ms 백엔드 기록만 있음.
**To-do**: 프론트엔드에 추천 응답 시간 3단계 표시 UI (PR #44에 구현 중)
**Expected timing**: 베타 출시 후 데이터 누적 후 판단
**Status**: PR #44 진행 중

---

## [2026-05-03] sw-lead -- "다른 기법 보기" 클릭 트래킹

**Priority**: medium
**Background**: NEXT-2 client_events와 통합 필요. 현재 클릭 횟수 미수집.
**To-do**: client_events에 다른기법보기 클릭 이벤트 추가
**Expected timing**: 베타 데이터 수집 후
**Status**: 대기중

---

## [2026-05-03] sw-lead -- 일일 한도 N/20 사용자 표시 UI

**Priority**: medium
**Background**: 사용자가 자신의 사용량과 남은 횟수를 인지하지 못함.
**To-do**: 헤더 또는 입력 화면에 N/20 배지 표시
**Expected timing**: 베타 데이터 수집 후
**Status**: 대기중

---

## [2026-05-03] sw-lead -- 가시위근/극상근 동의어 중복 제거

**Priority**: low
**Background**: 데이터 정규화 이슈. 동의어 중복으로 추천 결과에 혼선 가능성.
**To-do**: technique 데이터 정규화
**Expected timing**: 베타 데이터 수집 후 토론
**Status**: 대기중

---

## [2026-05-04] sw-qa-tester -- 급성기 운동 카드 부재

**Priority**: low
**Background**: 급성기 조건에서 운동 카드 미추천 -- 의도된 동작. 임상적 타당성 검토 필요.
**To-do**: 급성기 운동 추천 포함 여부 임상팀과 토론
**Expected timing**: 베타 데이터 수집 후
**Status**: 대기중

---

## [2026-05-04] sw-qa-tester -- R1 latency 이상치 추적

**Priority**: low
**Background**: QA 중 R1 latency 20.62s outlier 1건 (P95 2배). 단발성 여부 불명확.
**To-do**: 베타 기간 중 latency_ms 데이터 누적 후 패턴 분석
**Expected timing**: 베타 D+7
**Status**: 대기중

---

## [2026-05-04] sw-frontend-dev -- 풀 인터랙티브 튜토리얼

**Priority**: low
**Background**: 현재 welcome 모달은 4 step 정적 카드. D+7 이후 인터랙티브 튜토리얼 검토.
**To-do**: 풀 튜토리얼 UX 설계 및 구현
**Expected timing**: 베타 D+7 이후
**Status**: 대기중

---

## [2026-05-05] [sw-lead] — Zuggriff·Grundaufbau 한국어 매핑 결정 + DB 정제

**Priority**: medium
**Team**: software (Track B 후속)
**Background**:
Track B 용어 표준화에서 audit §6-6 (보류) 항목으로 분리. CTM(결합조직마사지) 핵심 손기법 두 가지의 정확한 한국어 풀이가 필요한데, 한국 PT 표준 술어가 정착돼 있지 않고 audit 시 임시 풀이("당김 손기법"·"기저 스트로크")는 정확성·자연스러움 부족. 대표님이 CTM 원전(Bindegewebsmassage 교과서·KPTA 가이드 등) 직접 검토 후 결정 예정.

DB 영향:
- `techniques` 테이블 마이그레이션 013 (CTM 10건) — direction / technique_steps(jsonb) / clinical_notes 컬럼에 Zuggriff 21회 + Grundaufbau 1회 등장
- term_glossary 테이블에는 시드 INSERT 안 됨 (마이그 052 §6-6 제외)

**To-do**:
1. CTM 원전 자료 검토 후 확정 한국어 매핑 결정 — 단어형(예: "잡아당기기") vs 풀이형(예: "피부 잡고 당기는 동작")
2. term_glossary 시드 추가 마이그레이션 작성 (saas/migrations/053-term-glossary-german-ctm.sql 후보)
   - INSERT row 2건 (Zuggriff / Grundaufbau)
   - body_region = NULL (글로벌)
   - english = 'Zug grip' / 'Grundaufbau (basic build-up)'
   - status = 'active'
3. 또는 DB 원문 정제 — 마이그 013 INSERT문의 외래어를 한국어로 직접 치환 (마이그 053으로 UPDATE)
4. sw-clinical-translator 에 검토 위임 가능 (대표님 결정 input 필요)

**Related files**:
- `saas/migrations/013-cervical-lumbar-techniques.sql` (라인 177~996, CTM 10건)
- `docs/clinical-terminology-audit-2026-05-05.md` (§6-6)
- `saas/migrations/052-term-glossary.sql` (확장 대상)

**Expected timing**: 2026-05-06 (내일)
**Status**: 🔲 대기중

---

## [2026-05-05] [sw-lead] — Track B Phase 3: api/history.js 후처리 + 클라이언트 TERM_REPLACEMENTS 제거

**Priority**: medium
**Team**: software (Track B 마무리)
**Background**:
Track B Phase 2까지 production 적용 완료 (term_glossary 123 row + api/recommend.js 후처리). 그러나 api/history.js 가 applyGlossary 미적용 상태이고, 클라이언트 index.html 의 TERM_REPLACEMENTS 24건 + sanitizeTerms 14건 호출이 아직 살아있음. 단일 진실 소스 원칙 위반 — 단 history 응답이 raw 한자어로 반환되는 한 클라이언트 sanitize를 즉시 제거할 수 없음.

**To-do**:
1. api/history.js 수정 (sw-backend-dev) — applyGlossary 통합 — 대상 필드: recentLogs[].recommended_techniques, likedTechniques[].name_ko, likedTechniques[].category_name 등
2. index.html 수정 (sw-frontend-dev) — TERM_REPLACEMENTS 배열 + sanitizeTerms 함수 + 14건 호출 모두 제거 또는 String() 통과로 교체
3. 회귀 검증 — 추천 결과 / 이력 화면 / 모달 모두 한자어가 한글표준+영문 형태로 정상 표시되는지

**Related files**:
- `api/history.js`
- `api/_term_glossary.js` (재사용)
- `index.html` (TERM_REPLACEMENTS line 3288~3302, sanitizeTerms line 3303~3308, 호출 14건)

**Expected timing**: 2026-05-06 ~ 5-08 (1~2시간)
**Status**: 🔲 대기중

---

## [2026-05-05] [sw-lead] — Track C: 평가 타이밍 재설계 (다음 세션 진입 시 필수 모달)

**Priority**: high
**Team**: software
**Background**:
현재 인라인 별점 평가는 추천 받자마자 노출되어 PT 임상 워크플로 (추천 → 시술 → 효과 평가) 와 어긋남. 사용자가 환자에게 시술해 본 후에야 추천의 효과를 판단 가능 → 평가는 다음 세션 진입 시가 자연스러움. 또한 ratings 테이블에 recommendation_log_id FK가 없어 "어느 추천에 대한 평가인지" 매칭 불가 — AI 피드백 루프 미완성.

대표님 결정 (2026-05-05):
- 다음 세션 진입 시 필수 모달 (검색 차단)
- 인라인 별점 유지하되 약화
- 14일 만료
- 카드별 outcome 6라디오 + accuracy 1~5 + 메모 + "이거 시술 안 했어요" 스킵 버튼

**To-do**:
1. DB 마이그 051 작성 (sw-db-architect) — recommendation_logs.evaluation_status·evaluated_at 컬럼 / ratings.recommendation_log_id·recommended_technique_index FK / RLS update_own / 트리거 (ratings INSERT 시 status='rated') / pending 인덱스
2. Backend (sw-backend-dev) — recommend.js 가 recommendation_log_id 응답 반환 / feedback.js 페이로드에 FK 추가 / api/pending-evaluations.js 신규 엔드포인트 (14일 윈도우)
3. Frontend (sw-frontend-dev) — pending-eval-overlay 모달 마크업 / loadSavedSettingsAndNavigate 검색 차단 가드 / 인라인 별점 약화 / feedback POST 페이로드 FK 추가
4. 단계 출시: Day 0 마이그+Backend (모달 미노출, 데이터 매칭만) → Day 2 모니터링 → Day 3+ Frontend 모달 활성화

**Related files**:
- `saas/migrations/051-recommendation-evaluation.sql` (신규)
- `api/recommend.js`, `api/feedback.js`
- `api/pending-evaluations.js` (신규)
- `index.html` (모달 마크업 line 1564 직후, loadSavedSettingsAndNavigate line 2219, .inline-feedback-section line 1334~1450)

**Plan 파일** (참고): `/root/.claude/plans/come-to-think-of-distributed-riddle.md` (Track C 섹션)

**Expected timing**: 2026-05-08 ~ 5-12 (2~3일)
**Status**: 🔲 대기중

---

## [2026-05-05] [sw-lead] — Track D: 추천 알고리즘 조정 (디테일·다양성)

**Priority**: medium
**Team**: software
**Background**:
대표님 관찰 (2026-05-05):
1. 추천 받은 기법 디테일 부족 — 시술 시 즉시 적용하기 어려움
2. "같은 그룹 다른 기법 보기" 가 명칭만 나오고 추가 정보 없음 — 사용자가 명칭만 보고 선택하기 어려움

향후 평가 데이터 (Track C 완료 후) 기반으로 가중치 공식·LLM 프롬프트·필터·다양성 정책 튜닝 필요. Track C 가 완료되어야 평가가 정확히 매칭되고, 그 데이터로 알고리즘 의미 있는 조정 가능.

**To-do**:
1. 요구사항 정리 — "디테일 부족" 의 구체 사례 수집 (PT 베타 사용자 피드백 기반)
2. "다른 기법 보기" UX 보강 — 명칭 + 카테고리 + 별점 + 짧은 설명 1줄
3. 가중치 공식 검토 (Migration 050b — 별점 20% / 정확도 30% / 활성도 20% / 효과 30%) — 데이터 적은 기법(activity_30d=0)이 너무 낮게 나오는지 / 별점 후한 기법만 반복되는지
4. LLM 프롬프트 추가 규칙 — 환자 안전성 우선 / 신참 PT 친화 기법 우선 / 최신 근거 기반
5. (선택) PT 경력별 난이도 매칭 — 초보 vs 숙련 — 도입 의향 검토

**Related files**:
- `api/recommend.js` (LLM 프롬프트 line 1134~1180, 가중치 적용 로직)
- `saas/migrations/050b-fix-trigger-security-and-outcome-ratio.sql` (가중치 공식)
- `index.html` (다른 기법 보기 UI 라인 식별 필요)

**Dependencies**: Track C 완료 후 시작 권장 (recommendation_log_id ↔ rating 매칭 정확해진 후)

**Expected timing**: 2026-05-13 ~ 5-15 (1~2일)
**Status**: 🔲 대기중

---
