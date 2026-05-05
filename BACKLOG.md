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
