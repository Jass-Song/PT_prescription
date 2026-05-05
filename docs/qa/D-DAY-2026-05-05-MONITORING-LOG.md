<!-- owner: sw-qa-tester -->
# D-Day Monitoring Log — 2026-05-05 (PT 처방 도우미 MVP 베타 출시)

**대상**: production https://pt-prescription.vercel.app
**런북**: `docs/qa/D-DAY-MONITORING-RUNBOOK.md`
**Driver**: sw-qa-tester
**시간대**: KST (UTC+9)

> 본 로그는 출시 직후 24시간 + 익일 24시간을 커버한다. 각 체크는 런북 §9 형식으로 append.

---

## T+0 — Baseline (출시 직전)

**시각**: 2026-05-05 (출시 시각 KST 채워넣을 것)

### Production 직접 관찰 시도
- WebFetch `https://pt-prescription.vercel.app/` → **HTTP 403 (직접 접근 불가)**
- WebFetch `https://pt-prescription.vercel.app/debug/admin.html` → **HTTP 403**
- WebFetch `https://pt-prescription.vercel.app/debug/errors.html` → **HTTP 403**

→ sw-qa-tester 환경에서는 production 직접 검증 불가. 인증된 브라우저 세션(대표님/Jarvis) 또는 sw-devops 위임 필요.
→ 본 로그는 5/4 마지막 관찰값을 baseline으로 채택.

### Baseline 값 (5/4 admin.html 마지막 스냅샷)

| 지표 | 값 | 비고 |
|------|----|------|
| 추천 누적 | 68건 | 5/4 회귀 §2 종료 시점 |
| 별점 누적 | 2건 | 베타 발송 전 내부 테스트만 |
| P50 latency | 8.4s | recommend.js 2-pillar/3-pillar 평균 |
| P95 latency | 11.2s | R1 outlier 20.62s 제외 시 |
| region "??" 비율 | 13% | 매핑 회귀 트래킹용 |
| 5xx 누적 | 0건 | errors.html 클린 |
| JS console error | 0건 | 클린 |
| R1 outlier | 20.62s 1건 | 5/5 재현 여부 추적 |

### 출시 직후 5분 Smoke Test (PR #44 머지 직후)

PR #44 = 사용량 배지 + 3단계 로딩 (5/5 머지). 출시 전 또는 출시 직후 신규 세션 1회로 5분 smoke 수행.

| # | 항목 | 기대 | 결과 | 비고 |
|---|------|------|:---:|------|
| S1 | 첫 로그인 후 환영 모달 1회 노출 | PASS | ⬜ | localStorage clear 상태에서 |
| S2 | 환영 모달 닫기 → 새로고침 → 미노출 | PASS | ⬜ | 'pt-welcome-v1-dismissed' 저장 확인 |
| S3 | 헤더에 사용량 배지 노출 | PASS | ⬜ | 정상 색상 (회색/녹색 계열) |
| S4 | 추천 트리거 시 3단계 로딩 (🔍→🤖→✅) | PASS | ⬜ | 단계 전환 자연스러움 |
| S5 | 추천 1회 후 사용량 배지 +1 갱신 | PASS | ⬜ | 즉시 갱신 확인 |
| S6 | recommend latency | <15s | ⬜ | 첫 호출 |
| S7 | 모바일 viewport (375px) — outcome 6개 wrap | PASS | ⬜ | DevTools device emulation |
| S8 | 모바일 viewport (375px) — accuracy 1~5 그리드 | PASS | ⬜ | 동일 |
| S9 | 모바일 viewport (375px) — 별점 터치 영역 ≥44px | PASS | ⬜ | 동일 |
| S10 | DevTools console — JS error 0건 | PASS | ⬜ | F12 → Console |

→ S1~S10 중 1건이라도 FAIL 시 런북 §8 핫픽스 트리거 기준에 따라 즉시 sw-frontend-dev/sw-backend-dev 호출.

---

## T+30m — 첫 30분 체크

**시각**: 2026-05-05 (출시+30분 KST)

### 결과
```
- 5xx: ⬜
- 추천 누적: ⬜ (Δ +⬜)
- P50 / P95: ⬜ / ⬜
- 별점 평균 (n=⬜): ⬜
- region "??" 비율: ⬜%
- 모바일 회귀 (M1~M3): ⬜
- 발견 이슈: ⬜
- 다음 체크: T+1h
```

### 상세 메모
- (체크 시 append)

---

## T+1h — 1시간 체크

**시각**: 2026-05-05 (출시+1h KST)

### 결과
```
- 5xx: ⬜
- 추천 누적: ⬜ (Δ +⬜)
- P50 / P95: ⬜ / ⬜
- 별점 평균 (n=⬜): ⬜
- region "??" 비율: ⬜%
- 모바일 회귀 (M1~M3): ⬜
- 발견 이슈: ⬜
- 다음 체크: T+1.5h (Phase A 30분 간격)
```

### 상세 메모
- (체크 시 append)

---

## T+3h — 3시간 체크

**시각**: 2026-05-05 (출시+3h KST)

### 결과
```
- 5xx: ⬜
- 추천 누적: ⬜ (Δ +⬜)
- P50 / P95: ⬜ / ⬜
- 별점 평균 (n=⬜): ⬜
- region "??" 비율: ⬜%
- 모바일 회귀 (M1~M3): ⬜
- 발견 이슈: ⬜
- 다음 체크: T+3.5h (Phase A 30분 간격)
```

### 상세 메모
- (체크 시 append)

---

## T+6h — 6시간 체크 (Phase A → Phase B 전환점)

**시각**: 2026-05-05 (출시+6h KST)

### 결과
```
- 5xx: ⬜
- 추천 누적: ⬜ (Δ +⬜)
- P50 / P95: ⬜ / ⬜
- 별점 평균 (n=⬜): ⬜
- region "??" 비율: ⬜%
- 모바일 회귀 (M1~M3): ⬜
- 발견 이슈: ⬜
- 다음 체크: T+7h (Phase B 1시간 간격으로 전환)
```

### 상세 메모
- Phase A 종료 시점. 누적 5xx, 추천량, 별점 평균을 baseline 대비 정리.
- R1 outlier(20.62s) 재현 여부 — 동일 입력(경추 × 급성 × 움직임) 1회 재실행 후 latency 기록.

---

## T+24h — 익일 체크 (Phase B → Phase C 전환점)

**시각**: 2026-05-06 (출시+24h KST)

### 결과
```
- 5xx: ⬜
- 추천 누적: ⬜ (Δ +⬜)
- P50 / P95: ⬜ / ⬜
- 별점 평균 (n=⬜): ⬜
- region "??" 비율: ⬜%
- 모바일 회귀 (M1~M6 풀 체크): ⬜
- 발견 이슈: ⬜
- 다음 체크: T+28h (Phase C 4시간 간격)
```

### 24시간 종합 요약
- **5xx 누적**: ⬜
- **추천 누적**: ⬜건 (목표: 베타 테스터당 1~3건 × N명 추산)
- **별점 도달율**: ⬜% (별점 입력 / 추천 생성)
- **핫픽스 발생 건수**: ⬜
- **에스컬레이션 건수**: ⬜ (sw-frontend-dev: ⬜, sw-backend-dev: ⬜)
- **R1 outlier 재현 여부**: ⬜
- **PR #43 환영 모달 production 검증**: W1~W5 ⬜
- **PR #44 사용량 배지 + 3단계 로딩 production 검증**: U1~U5 / L1~L5 ⬜
- **모바일 회귀 종합**: M1~M6 ⬜
- **D+1 결정**: 정상화 → Phase C 진행 / 이슈 누적 → 핫픽스 sprint

---

## 📝 발견 이슈 누적 (자유 append)

### 이슈 #1
- 발견 시각:
- 증상:
- 재현 경로:
- 위임 대상:
- 처리 결과:

(이슈 발견 시 위 템플릿 복사하여 append)

---

## 📊 누적 통계 (각 체크 후 갱신)

| 시점 | 추천 누적 | 5xx 누적 | P50 | P95 | 별점 (n) | region "??" % |
|------|---------|---------|:---:|:---:|:-------:|:-------------:|
| T+0 (baseline) | 68 | 0 | 8.4s | 11.2s | 0 (n=2) | 13% |
| T+30m | | | | | | |
| T+1h | | | | | | |
| T+3h | | | | | | |
| T+6h | | | | | | |
| T+24h | | | | | | |

---

*Started: 2026-05-05 (D-Day) by sw-qa-tester*
*Runbook 참조: docs/qa/D-DAY-MONITORING-RUNBOOK.md*
