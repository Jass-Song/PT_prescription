<!-- owner: sw-devops -->
# PT 처방 도우미 — 모니터링 셋업 가이드 (D-Day 폴링)

**대상**: 대표님 (Director) 또는 sw-devops / sw-qa-tester
**스크립트**: `debug/monitor.sh`
**런북 연동**: `docs/qa/D-DAY-MONITORING-RUNBOOK.md` §2 핵심 지표 5종

> Production `/debug/errors.html`, `/debug/admin.html` 페이지가 (a) 인증 또는 (b) 외부 fetch 차단으로
> 자동화 폴링이 막히는 상황을 우회하기 위한 **DB 직접 폴링** 스크립트입니다.
> 사람이 보는 대시보드는 그대로 사용하고, 자동화는 본 스크립트로 처리합니다.

---

## 1. 인증 방식 결정 (요약)

본 스크립트는 **(A) Supabase REST + Service Role Key** 방식을 사용합니다.

| 방식 | 셋업 시간 | 의존성 | D-Day 적합 |
|------|----------|--------|----------|
| **(A) Supabase REST + service_role** ✅ | 1분 (env 1개 복사) | Supabase Dashboard 접근 | **선택** |
| (B) `/api/admin` + admin JWT | 5~10분 (admin 로그인 → JWT 캡처 → 만료 갱신 운영) | admin 계정 + JWT 갱신 운영 | 비선택 |

**선택 사유**: D-Day 출시일은 셋업 시간이 곧 위험. (A)는 Supabase Dashboard에서 키 한 번 복사하면 끝.
키는 env로만 주입하고 코드/Git에 절대 저장하지 않습니다 (런북 §3 보안 가드).

> 향후 multi-user 또는 외부 알림 연동 단계에서 (B)로 전환 검토 가능.

---

## 2. 필수 환경변수

| 변수 | 설명 | 출처 |
|------|------|------|
| `SUPABASE_URL` | Supabase project URL | Vercel Dashboard → Project → Settings → Environment Variables → `SUPABASE_URL` (또는 Supabase Dashboard → Project URL). 예: `https://gnusyjnviugpofvaicbv.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | service_role 키 (RLS 우회) | Supabase Dashboard → Project Settings → **API** → `service_role` (secret). 노출 금지. |

> **주의**: `anon` key 가 아닌 **`service_role`** 키여야 합니다. `error_logs`, `session_logs` 등은 service role 만 SELECT 가능 (RLS 정책 미정의 또는 본인 행만 허용).

---

## 3. 로컬 실행

### 3-1. 1회 출력 (수동 체크)
```bash
export SUPABASE_URL="https://gnusyjnviugpofvaicbv.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOi..."   # service_role 키, 절대 커밋 금지

cd pt-prescription
./debug/monitor.sh
```

출력 예시:
```
──────── PT 처방 도우미 모니터링 (2026-05-05T05:00:00Z, KST≈+9h) ────────
  최근 1h 5xx 에러     0       (임계: ≥1 → CRIT)
  최근 1h 추천량       12      (recommendation_logs; 0 = CRIT)
     └ session_logs    12
  최근 1h P50 / P95   8400 ms / 11200 ms   (P95 임계: >18000=CRIT, >14000=WARN)
  최근 1h avg latency  9200 ms
  최근 1h region ??   8.3% (1/12)   (>30=CRIT, >20=WARN)
  최근 1h 별점         2건 (avg=4.5)
```

### 3-2. 주기 폴링 (--watch)
```bash
# 기본 600초 (10분) 간격
./debug/monitor.sh --watch

# 사용자 지정 간격 (초 단위)
./debug/monitor.sh --loop 300       # 5분
```

Ctrl+C 로 중단.

### 3-3. JSON 출력 (cron / 알림 파이프용)
```bash
./debug/monitor.sh --json | jq '.'
```

응답 키: `count_5xx_1h`, `count_recs_1h`, `count_sessions_1h`, `count_ratings_1h`, `ratings_avg_1h`, `latency_p50_ms`, `latency_p95_ms`, `latency_avg_ms`, `region_unknown_pct`, `region_unknown_count`.

### 3-4. env 파일 사용 (권장)
서비스 키를 매번 복사하지 않으려면 로컬에 `.env.monitor` (gitignore 됨) 작성:
```bash
# .env.monitor (커밋 금지)
export SUPABASE_URL="https://gnusyjnviugpofvaicbv.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOi..."
```
실행:
```bash
source .env.monitor && ./debug/monitor.sh
```

> `.env.monitor` 가 `.gitignore` 미포함이면 `.gitignore` 에 한 줄 추가하세요.

---

## 4. cron 셋업 (런북 §1 스케줄)

런북 §1 스케줄에 맞춘 cron:

```cron
# /etc/cron.d/pt-monitor — 또는 user crontab
# Phase A (출시 ~ T+6h): 10분 간격 폴링 → 로그 파일에 append
*/10 * * * * SUPABASE_URL="https://...supabase.co" SUPABASE_SERVICE_ROLE_KEY="eyJ..." /path/to/pt-prescription/debug/monitor.sh --json >> /var/log/pt-monitor.jsonl 2>> /var/log/pt-monitor.err

# Phase B (T+6h ~ T+24h): 1시간 간격 (*/10 줄 비활성화 후 사용)
# 0 * * * * SUPABASE_URL="..." SUPABASE_SERVICE_ROLE_KEY="..." /path/to/.../monitor.sh --json >> /var/log/pt-monitor.jsonl 2>> /var/log/pt-monitor.err

# Phase C (T+24h ~ T+48h): 4시간 간격
# 0 */4 * * * ...

# Phase D (T+48h ~): 1일 1회
# 0 9 * * * ...
```

**보안 권장**: cron 내부에 키를 직접 적지 말고 `EnvironmentFile=/etc/pt-monitor.env` 사용 (systemd timer) 또는 `/etc/cron.d/pt-monitor` 파일 권한 600 + root 소유로 설정.

systemd timer 예시 (`/etc/systemd/system/pt-monitor.service`):
```ini
[Service]
Type=oneshot
EnvironmentFile=/etc/pt-monitor.env
ExecStart=/path/to/pt-prescription/debug/monitor.sh --json
StandardOutput=append:/var/log/pt-monitor.jsonl
StandardError=append:/var/log/pt-monitor.err
```
타이머 (`/etc/systemd/system/pt-monitor.timer`):
```ini
[Timer]
OnCalendar=*:0/10
Unit=pt-monitor.service
[Install]
WantedBy=timers.target
```
```bash
sudo systemctl enable --now pt-monitor.timer
```

---

## 5. 임계값 알림 (현재 동작)

런북 §3 매트릭스 기준. 위반 시 **stderr** 에 한 줄씩 출력 + 콘솔 색상 강조 (TTY일 때).

| 트리거 | 출력 | 색상 |
|--------|------|------|
| 5xx ≥ 1 | `[ALERT] 5xx N건 발견 — sw-backend-dev 호출` + 상세 행 | RED |
| P95 latency > 18000ms | `[ALERT] P95 latency Nms > 18000ms — sw-backend-dev 호출` | RED |
| P95 14000~18000ms | (색상만 노랑, alert 미발생) | YELLOW |
| 추천량 1h = 0 | `[ALERT] 최근 1h 추천량 0건 — 서비스 다운 가능성` | RED |
| region '??' > 30% | `[WARN] region '??' 비율 N% > 30%` | YELLOW |

수동 모니터링 흐름 권장:
```bash
./debug/monitor.sh 2>>alerts.log     # stdout 콘솔 / stderr는 파일에 누적
```
또는 watch 루프로:
```bash
./debug/monitor.sh --watch 2> >(tee -a alerts.log >&2)
```

### 5-1. (선택) Slack/Discord webhook 연동
시간 부족으로 본 단계는 미구현. 필요 시 cron 라인 끝에 다음 한 줄 추가하면 즉시 작동:
```bash
*/10 * * * * /path/.../monitor.sh --json | jq -r 'select(.count_5xx_1h>=1 or .latency_p95_ms>18000 or .count_recs_1h==0) | "[ALERT] \(.)"' | xargs -I{} curl -s -X POST -H 'Content-Type: application/json' -d '{"text":"{}"}' "$SLACK_WEBHOOK_URL"
```

---

## 6. 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| `SUPABASE_URL not set` 에러 | env 누락 | `export SUPABASE_URL=...` 또는 `.env.monitor` source |
| `missing dependency: jq` | jq 미설치 | macOS: `brew install jq` / Ubuntu: `apt install jq` |
| 모든 카운트가 0 | service_role 키가 아닌 anon 키 사용 → RLS 차단 | Supabase Dashboard → API → `service_role` (secret) 키로 교체 |
| `curl: (22) HTTP 401` | 키 만료 또는 오타 | Dashboard 재발급 후 env 갱신 |
| `date: invalid option -- 'd'` | macOS BSD `date` | 스크립트 89~90번 줄이 BSD 폴백 포함 (`date -u -v-1H`) — 동작함 |
| P50/P95 가 `null` | 1시간 내 추천 0건 | 정상 (출시 직후 트래픽 미도달 시) — `count_recs_1h` 확인 |

---

## 7. vercel.json 영향

본 스크립트는 Supabase REST API에 직접 호출 → Vercel 함수 cold start 영향 **없음**.
`vercel.json` 의 `api/*.js maxDuration: 60` 설정 변경 불필요. 현재 12줄짜리 최소 설정 유지.

---

## 8. 다음 단계 (출시 후)

- [ ] T+24h 데이터 누적 후 임계값 조정 검토 (현재 P95 18s 는 베이스라인 11.2s × 1.6)
- [ ] 별점 평균 <3.0 (n≥5) 알림 추가 — 런북 §3 항목이지만 1h 윈도우로는 표본 부족, 24h 윈도우 별도 추가 권장
- [ ] (B) `/api/admin` + admin JWT 방식 옵션화 — service_role 키 노출 면적 최소화 목적
- [ ] Slack/Discord webhook 연동 (§5-1 스니펫 기반)

*Last updated: 2026-05-05 (D-Day) by sw-devops*
