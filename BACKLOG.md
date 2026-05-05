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
