<!-- owner: sw-qa-tester -->
# D-Day Monitoring Runbook — PT 처방 도우미 MVP 베타 출시

**작성일**: 2026-05-05 (D-Day, MVP 베타 출시일)
**대상**: sw-qa-tester (driver), sw-frontend-dev / sw-backend-dev / sw-devops (escalation)
**Production URL**: https://pt-prescription.vercel.app
**Debug 대시보드**:
- Errors: https://pt-prescription.vercel.app/debug/errors.html
- Admin: https://pt-prescription.vercel.app/debug/admin.html
  (둘 다 인증 필요할 수 있음. 인증 막히면 Jarvis 또는 sw-devops에 요청)

> 본 런북은 출시 직후 **첫 24시간 모니터링**과 그 이후 **익일 24시간 모니터링**을 다룬다.
> 모든 시각은 KST 기준. UTC 변환 필요시 -9시간.

---

## 0. Baseline (5/4 D-1 마지막 관찰값)

| 지표 | 값 | 출처 |
|------|----|------|
| P50 latency | 8.4s | 5/4 admin.html |
| P95 latency | 11.2s | 5/4 admin.html |
| 추천 누적 | 68건 | 5/4 admin.html |
| 별점 누적 | 2건 | 5/4 admin.html |
| region "??" 비율 | 13% | 5/4 admin.html |
| 5xx 에러 | 0건 | 5/4 errors.html |
| R1 latency outlier | 20.62s (1건) | 5/4 회귀 §2 |

이 값을 출시 직후 비교 기준으로 사용한다. 출시 후 트래픽 증가에 따라 변동 예상.

---

## 1. 체크 스케줄

| Phase | 시점 | 간격 | 비고 |
|-------|------|------|------|
| Phase A | T+0 ~ T+6h | 30분 간격 | 출시 직후 위험 시간대 — 풀 모니터링 |
| Phase B | T+6h ~ T+24h | 1시간 간격 | 안정화 단계 — 야간 휴식 가능 (최소 4시간 1회) |
| Phase C | T+24h ~ T+48h | 4시간 간격 | 익일 추세 관찰 |
| Phase D | T+48h ~ | 1일 1회 | 정상화 — 주간 리포트로 전환 검토 |

**T+0 정의**: ManyChat 시퀀스 활성화 + 베타 테스터에게 URL 발송 시점 (5/5 출시 시각).

---

## 2. 각 체크에서 확인할 지표

### 2-1. errors.html (5xx / 클라이언트 에러)
| 지표 | 정상 범위 | 주의 | 위험 |
|------|----------|------|------|
| 5xx 카운트 (전체) | 0 | 1~2건 | **3건 이상 또는 동일 endpoint 반복** |
| 5xx 카운트 (recommend) | 0 | 1건 | **1건이라도 반복 발생 시** |
| 4xx (auth/401) 비율 | <5% | 5~10% | >10% (로그인 흐름 회귀 가능성) |
| JS console error | 0 | 1~2건 | 동일 메시지 반복 |

### 2-2. admin.html (사용량·품질)
| 지표 | 정상 범위 | 주의 | 위험 |
|------|----------|------|------|
| 추천량 증감 | 양의 증가 | 정체 30분+ | **0건 1시간+** (서비스 다운 가능) |
| avg latency (P50) | 6~12s | 12~15s | **>15s** |
| P95 latency | <14s | 14~18s | **>18s** |
| 별점 평균 | ≥3.5 | 3.0~3.5 | **<3.0** (5건 이상 누적 후) |
| region "??" 비율 | <20% | 20~30% | **>30%** (지역 매핑 회귀) |

### 2-3. 사용자 행동 흐름 (admin.html funnel)
- 추천 생성 → outcome 기입 → accuracy 기입 → 별점 입력 까지의 drop-off
- 별점 도달율이 **5% 미만**이면 UX 회귀 의심 → sw-ux-researcher에 위임

---

## 3. 임계값 & 에스컬레이션 매트릭스

| 트리거 | 즉시 대응 담당 | 대응 시한 |
|--------|--------------|----------|
| **5xx 1건이라도 발견** (recommend/feedback/auth 어느 endpoint든) | sw-backend-dev | 30분 내 핫픽스 결정 |
| **JS console error 반복 (동일 메시지 3회+)** | sw-frontend-dev | 1시간 내 |
| **P95 > 18s 30분 지속** | sw-backend-dev | 1시간 내 (Anthropic API 상태 우선 확인) |
| **추천량 0건 1시간 지속** (정상 트래픽 시간대) | sw-devops + sw-backend-dev | 즉시 (장애 가능) |
| **모바일 레이아웃 깨짐 보고** | sw-frontend-dev | 2시간 내 |
| **환영 모달 z-index 가림 / 닫힘 안 됨** | sw-frontend-dev | 2시간 내 |
| **사용량 배지 색상 변경 안 됨 (80%/100%)** | sw-frontend-dev | 4시간 내 (UX 영향) |
| **3단계 로딩 미표시 (🔍→🤖→✅ 그대로)** | sw-frontend-dev | 4시간 내 |
| **별점 평균 <3.0 (5건+)** | sw-clinical-translator + sw-product-manager | 4시간 내 (콘텐츠 품질 회귀) |
| **region "??" >30%** | sw-backend-dev | 4시간 내 |

**에스컬레이션 채널**: 보드 PATCH (서버 unreachable 시) → Jarvis 에 보고 → 해당 에이전트 호출.

---

## 4. 첫날 발견 가능한 핫픽스 패턴 (예상)

> 본 표는 sw-qa-tester가 직접 들고 가는 트리아주 가이드. 발견 패턴 추가 시 append.

| 증상 | 1차 의심 원인 | 1차 대응 |
|------|-------------|---------|
| recommend 5xx 간헐 발생 | Anthropic API rate limit 또는 timeout | sw-backend-dev: retry/backoff 확인, vercel.json maxDuration 점검 |
| recommend 5xx 특정 입력에서 항상 | 프롬프트/파싱 회귀 | sw-backend-dev: 입력 페이로드 캡처 후 재현 |
| 환영 모달 닫혀도 다시 노출 | localStorage 'pt-welcome-v1-dismissed' 미설정 또는 키 충돌 | sw-frontend-dev: 키 검증, 시크릿 모드 테스트 |
| 환영 모달이 다른 모달 뒤에 깔림 | z-index 충돌 | sw-frontend-dev: z-index 재조정 (welcomeOverlay > 다른 overlay) |
| 사용량 배지 미노출 | API `/api/usage` 또는 settings 응답 누락 | sw-backend-dev: 엔드포인트 응답 확인 |
| 사용량 배지 80% 도달했는데 색상 그대로 | CSS 클래스 토글 누락 | sw-frontend-dev: 임계값 조건문 |
| 3단계 로딩 첫 단계만 보이고 멈춤 | setInterval/timeout 회귀 | sw-frontend-dev: 단계 전환 타이머 |
| outcome 라디오 6개 모바일에서 가로 잘림 | flex-wrap 미적용 | sw-frontend-dev: outcome group flex-wrap: wrap |
| accuracy 1~5 그리드 모바일에서 깨짐 | grid-template-columns 고정값 | sw-frontend-dev: minmax 또는 repeat(auto-fit) |
| 별점 터치 영역 부족 (모바일) | min-height/padding 부족 | sw-frontend-dev: 별 hit area 44px 이상 |
| region "??" 비율 급증 | 요청 페이로드 region 필드 누락 또는 매핑 회귀 | sw-backend-dev: recommend.js region 정규화 로직 |
| 로그인 후 첫 화면 환영 모달 안 뜸 | localStorage 이미 set 또는 트리거 조건 회귀 | sw-frontend-dev: 신규 계정으로 시크릿 모드 재현 |

> **참고**: 더 상세한 핫픽스 결정 트리는 `docs/specs/PRODUCT_SPEC.md` 또는 Notion D-2 페이지(있을 경우)에 있을 수 있음. 본인이 접근 못 해도 본 표로 D-Day 대응 가능.

---

## 5. 모바일 회귀 체크 항목 (각 체크 시 1회 이상)

| # | 항목 | 검증 방법 |
|---|------|----------|
| M1 | outcome 라디오 6개 wrap 정상 | iPhone SE (375px) 가정 viewport에서 줄바꿈 확인 |
| M2 | accuracy 1~5 그리드 정상 | 모바일에서 5개 가로 또는 자연스러운 wrap |
| M3 | 별점 터치 영역 ≥44px | 별 1개 영역 손가락 폭으로 정확히 선택 가능 |
| M4 | 환영 모달 모바일 가독성 | 텍스트 잘림 없음, 닫기 버튼 터치 가능 |
| M5 | 사용량 배지 가독성 | 헤더 영역에서 잘리거나 가려지지 않음 |
| M6 | 3단계 로딩 애니메이션 | 모바일에서도 단계 전환 시각화 |

각 체크에서 최소 M1~M3 + 변동분(M4~M6) 1회 확인.

---

## 6. PR #43 환영 모달 Production 검증

| # | 항목 | 기대 |
|---|------|------|
| W1 | 첫 로그인(localStorage clear 상태) | 환영 모달 1회 노출 |
| W2 | 모달 닫기 후 새로고침 | 다시 노출되지 않음 |
| W3 | localStorage 'pt-welcome-v1-dismissed' 키 | 'true' 또는 truthy 값으로 set됨 |
| W4 | 시크릿 모드 신규 진입 | 모달 다시 노출 (localStorage 비어있어야 함) |
| W5 | z-index 다른 overlay와 충돌 | 환영 모달이 항상 위에 표시 |

DevTools `localStorage.getItem('pt-welcome-v1-dismissed')` 로 직접 확인.

---

## 7. PR #44 사용량 배지 + 3단계 로딩 Production 검증

### 사용량 배지
| # | 항목 | 기대 |
|---|------|------|
| U1 | 배지 노출 위치 | 헤더 우측 또는 사용자 영역 (정확한 위치는 PR diff 기준) |
| U2 | 사용량 <80% | 정상 색상 (회색/녹색 계열) |
| U3 | 사용량 80% 도달 | 주의 색상 (노랑/주황 계열) |
| U4 | 사용량 100% | 위험 색상 (빨강 계열) + 추가 추천 차단 메시지 |
| U5 | 추천 1회 후 배지 카운트 +1 | 즉시 갱신 |

### 3단계 로딩 (🔍 → 🤖 → ✅)
| # | 항목 | 기대 |
|---|------|------|
| L1 | 추천 트리거 직후 | 🔍 단계 표시 ("입력 분석 중" 등) |
| L2 | API 호출 중 | 🤖 단계 표시 ("AI 추천 중" 등) |
| L3 | 응답 도착 직전 | ✅ 단계 표시 ("결과 정리 중" 등) |
| L4 | 단계 전환 타이밍 | 자연스러움 (한 단계에 갇히지 않음) |
| L5 | 에러 시 | 로딩 즉시 종료 + 에러 메시지 |

신규 사용자 1명 + 기존 사용자 1명 두 케이스 모두 확인.

---

## 8. 핫픽스 트리거 기준 (sw-frontend-dev 호출)

다음 중 **하나라도** 확인되면 즉시 sw-frontend-dev 호출:

1. **모바일 wrap 깨짐** (outcome 6개 가로 잘림 / accuracy 그리드 깨짐 / 텍스트 가로 스크롤 발생)
2. **사용량 배지 색상 미변경** (80% 또는 100% 도달했는데 회색 그대로)
3. **3단계 로딩 표시 누락** (단일 스피너 또는 첫 단계에서 멈춤)
4. **환영 모달 z-index 문제** (다른 모달/overlay에 가림 또는 dismissed 후 재노출)
5. **별점 터치 영역 부족** (모바일에서 인접 별 오선택 빈발)

호출 형식: `[D-DAY HOTFIX] <증상> — 재현경로 + 스크린샷` 으로 보드/Jarvis에 전달.

다음 중 **하나라도** 확인되면 즉시 sw-backend-dev 호출:

1. recommend/feedback/auth 5xx 1건이라도 발견
2. P95 latency >18s 30분 지속
3. 추천량 0건 1시간+ (정상 시간대)
4. region "??" 비율 >30%

---

## 9. 체크 보고 형식 (LOG에 기록)

각 체크마다 D-DAY-2026-05-05-MONITORING-LOG.md에 한 블럭 append:

```
### T+<시간> (<KST 시각>) — <상태 요약 1줄>
- 5xx: <건수>
- 추천 누적: <건수> (Δ +<증분>)
- P50 / P95: <값> / <값>
- 별점 평균 (n=): <값>
- region "??" 비율: <%>
- 모바일 회귀 (M1~M3): PASS/FAIL
- 발견 이슈: (있으면)
- 다음 체크: T+<시간>
```

---

## 10. 부록 — 5/4 R1 outlier (20.62s) 추적

5/4 R1 (경추 × 급성 × 움직임 시 통증) 시나리오에서 LLM latency 20.62s 측정됨 (P95 11.2s의 약 1.84배).
- 단발성 outlier 가능성 높음 — 5/5 출시 후 동일 입력 재실행하여 재현 여부 확인
- 재현되면 sw-backend-dev에 전달 (프롬프트 길이 또는 Anthropic side latency 의심)
- 재현 안 되면 1회성 outlier로 판정 — BACKLOG 종결

---

*Started: 2026-05-05 (D-Day) by sw-qa-tester*
