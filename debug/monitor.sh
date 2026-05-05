#!/usr/bin/env bash
# PT 처방 도우미 — D-Day 모니터링 폴링 스크립트 (sw-devops)
#
# 목적: production /debug/* 페이지 WebFetch 403 우회용. Supabase REST API에 직접 폴링하여
#       런북(D-DAY-MONITORING-RUNBOOK.md) §2 핵심 지표 5종을 한 번에 출력.
#
# 인증 방식: (A) Supabase REST + Service Role Key
#   사유: /api/admin (path B)는 admin JWT 발급/저장 필요 → 셋업 1단계 추가.
#         출시 D-Day는 빠른 셋업이 우선. /debug/* 페이지는 사람이 보고, 자동화는 DB 직접 조회.
#         service role key는 env로만 주입, 코드/리포지토리에 절대 저장 금지.
#
# 사용:
#   1회 실행:           ./monitor.sh
#   주기 폴링 (10분):   ./monitor.sh --watch          # 기본 600초
#   주기 폴링 (사용자): ./monitor.sh --loop 300       # 300초 간격
#   JSON 출력:          ./monitor.sh --json           # cron 파이프용
#
# 필수 env:
#   SUPABASE_URL                Supabase project URL (예: https://xxx.supabase.co)
#   SUPABASE_SERVICE_ROLE_KEY   service_role 키 (Supabase Dashboard → Settings → API)
#
# 임계값 (런북 §3 기준):
#   - 5xx ≥ 1                       → CRIT (빨강)
#   - P95 latency > 18000ms        → CRIT (빨강), > 14000ms → WARN (노랑)
#   - 추천량 1h = 0                 → CRIT (빨강, 정상 시간대 가정)
#   - region "??" 비율 > 30%       → CRIT, 20~30% → WARN
#
# 의존성: bash 4+, curl, jq

set -u

# ── 색상 (TTY일 때만) ────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_CYAN=$'\033[36m'
else
  C_RESET=''; C_BOLD=''; C_DIM=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''
fi

# ── 인자 파싱 ────────────────────────────────────────────────────────
WATCH=0
INTERVAL=600   # 기본 10분
JSON_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --watch)        WATCH=1; shift ;;
    --loop)         WATCH=1; INTERVAL="${2:-600}"; shift 2 ;;
    --json)         JSON_ONLY=1; shift ;;
    -h|--help)
      sed -n '2,30p' "$0"
      exit 0
      ;;
    *)
      echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# ── env 검증 ─────────────────────────────────────────────────────────
: "${SUPABASE_URL:?SUPABASE_URL not set — see debug/MONITOR-SETUP.md}"
: "${SUPABASE_SERVICE_ROLE_KEY:?SUPABASE_SERVICE_ROLE_KEY not set — see debug/MONITOR-SETUP.md}"

# 의존성
for cmd in curl jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing dependency: $cmd" >&2; exit 3
  fi
done

# ── REST 호출 헬퍼 ───────────────────────────────────────────────────
sb_get() {
  # $1 = path+query (예: /rest/v1/error_logs?...)
  curl -sSfL \
    -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Accept: application/json" \
    "${SUPABASE_URL}${1}"
}

# ── 한 번 폴링 ───────────────────────────────────────────────────────
poll_once() {
  local now_iso since_1h_iso
  # macOS bash 호환을 위해 python3 fallback 없이 date -u 만 사용
  now_iso=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  since_1h_iso=$(date -u -d "1 hour ago" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null \
                 || date -u -v-1H +"%Y-%m-%dT%H:%M:%SZ")

  # 1) 최근 1h 5xx 에러 (error_logs.http_status >= 500)
  local errors_json count_5xx
  errors_json=$(sb_get "/rest/v1/error_logs?created_at=gte.${since_1h_iso}&http_status=gte.500&select=id,source,http_status,message,request_path,created_at&order=created_at.desc&limit=50") \
    || errors_json='[]'
  count_5xx=$(jq 'length' <<<"$errors_json")

  # 2) 최근 1h 추천 (recommendation_logs) + latency p50/p95/avg + region "??" 비율
  local recs_json count_recs p50 p95 avg unknown_pct unknown_count
  recs_json=$(sb_get "/rest/v1/recommendation_logs?created_at=gte.${since_1h_iso}&select=created_at,latency_ms,region&order=created_at.desc&limit=2000") \
    || recs_json='[]'
  count_recs=$(jq 'length' <<<"$recs_json")

  # latency 통계 (jq 정렬 → percentile)
  read -r p50 p95 avg < <(jq -r '
    [ .[] | .latency_ms | select(. != null and . > 0) ] | sort as $s
    | ($s | length) as $n
    | if $n == 0 then "null null null"
      else
        ( $s[ ([( ($n * 0.5 | ceil) - 1), 0] | max) ] | tostring ) + " " +
        ( $s[ ([( ($n * 0.95 | ceil) - 1), 0] | max) ] | tostring ) + " " +
        ( ([ $s[] ] | add / $n | round) | tostring )
      end
  ' <<<"$recs_json")

  # region "??" 카운트
  unknown_count=$(jq '[ .[] | select(.region == "??" or .region == null or .region == "") ] | length' <<<"$recs_json")
  if [[ "$count_recs" -gt 0 ]]; then
    unknown_pct=$(awk -v u="$unknown_count" -v t="$count_recs" 'BEGIN{ printf "%.1f", (u/t)*100 }')
  else
    unknown_pct="0.0"
  fi

  # 3) 최근 1h session_logs 카운트 (백업 메트릭, recommend.js가 동시 기록)
  local sess_json count_sessions
  sess_json=$(sb_get "/rest/v1/session_logs?created_at=gte.${since_1h_iso}&select=id&limit=2000") \
    || sess_json='[]'
  count_sessions=$(jq 'length' <<<"$sess_json")

  # 4) 최근 1h 별점 (ratings)
  local ratings_json count_ratings ratings_avg
  ratings_json=$(sb_get "/rest/v1/ratings?created_at=gte.${since_1h_iso}&category_key=neq.general_app&select=star_rating,created_at&order=created_at.desc&limit=500") \
    || ratings_json='[]'
  count_ratings=$(jq 'length' <<<"$ratings_json")
  ratings_avg=$(jq -r '
    [ .[] | .star_rating | select(. != null) ] as $a
    | if ($a | length) == 0 then "null"
      else ( ($a | add) / ($a | length) | . * 10 | round / 10 | tostring ) end
  ' <<<"$ratings_json")

  # ── JSON 모드 출력 ──
  if [[ "$JSON_ONLY" -eq 1 ]]; then
    jq -n \
      --arg ts "$now_iso" \
      --arg since "$since_1h_iso" \
      --argjson c5 "$count_5xx" \
      --argjson cr "$count_recs" \
      --argjson cs "$count_sessions" \
      --argjson cR "$count_ratings" \
      --arg p50 "$p50" --arg p95 "$p95" --arg avg "$avg" \
      --arg u "$unknown_pct" --argjson uc "$unknown_count" \
      --arg ra "$ratings_avg" \
      '{
        ts: $ts, window_since: $since,
        count_5xx_1h: $c5,
        count_recs_1h: $cr,
        count_sessions_1h: $cs,
        count_ratings_1h: $cR,
        ratings_avg_1h: ($ra | if . == "null" then null else tonumber end),
        latency_p50_ms: ($p50 | if . == "null" then null else tonumber end),
        latency_p95_ms: ($p95 | if . == "null" then null else tonumber end),
        latency_avg_ms: ($avg | if . == "null" then null else tonumber end),
        region_unknown_pct: ($u | tonumber),
        region_unknown_count: $uc
      }'
    return 0
  fi

  # ── 사람용 출력 ──
  # 임계값 색상 결정
  local sev_5xx sev_p95 sev_recs sev_unknown
  sev_5xx=$([[ "$count_5xx" -ge 1 ]] && echo "$C_RED" || echo "$C_GREEN")
  if [[ "$p95" == "null" ]]; then sev_p95="$C_DIM"
  elif (( p95 > 18000 )); then sev_p95="$C_RED"
  elif (( p95 > 14000 )); then sev_p95="$C_YELLOW"
  else sev_p95="$C_GREEN"; fi
  if [[ "$count_recs" -eq 0 ]]; then sev_recs="$C_RED"
  else sev_recs="$C_GREEN"; fi
  local u_int
  u_int=${unknown_pct%.*}
  if (( u_int > 30 )); then sev_unknown="$C_RED"
  elif (( u_int > 20 )); then sev_unknown="$C_YELLOW"
  else sev_unknown="$C_GREEN"; fi

  printf '%s──────── PT 처방 도우미 모니터링 (%s, KST≈+9h) ────────%s\n' "$C_BOLD" "$now_iso" "$C_RESET"
  printf '  %s최근 1h 5xx 에러     %s%s%-6s%s   (임계: ≥1 → CRIT)\n' "$C_DIM" "$C_RESET" "$sev_5xx" "$count_5xx" "$C_RESET"
  printf '  %s최근 1h 추천량       %s%s%-6s%s   (recommendation_logs; 0 = CRIT)\n' "$C_DIM" "$C_RESET" "$sev_recs" "$count_recs" "$C_RESET"
  printf '  %s   └ session_logs    %s%-6s\n' "$C_DIM" "$C_RESET" "$count_sessions"
  printf '  %s최근 1h P50 / P95   %s%s%s ms / %s%s ms%s   (P95 임계: >18000=CRIT, >14000=WARN)\n' \
    "$C_DIM" "$C_RESET" "$sev_p95" "$p50" "$sev_p95" "$p95" "$C_RESET"
  printf '  %s최근 1h avg latency %s%s ms\n' "$C_DIM" "$C_RESET" "$avg"
  printf '  %s최근 1h region ??   %s%s%s%% (%s/%s)%s   (>30=CRIT, >20=WARN)\n' \
    "$C_DIM" "$C_RESET" "$sev_unknown" "$unknown_pct" "$unknown_count" "$count_recs" "$C_RESET"
  printf '  %s최근 1h 별점       %s%s건 (avg=%s)\n' "$C_DIM" "$C_RESET" "$count_ratings" "$ratings_avg"

  # 알림 — stderr 에 한 줄씩
  if [[ "$count_5xx" -ge 1 ]]; then
    echo "${C_RED}${C_BOLD}[ALERT]${C_RESET} 5xx ${count_5xx}건 발견 — sw-backend-dev 호출 (런북 §3)" >&2
    echo "$errors_json" | jq -r '.[] | "  - [\(.created_at)] \(.http_status) \(.request_path // "-") \(.message // "")"' >&2
  fi
  if [[ "$p95" != "null" ]] && (( p95 > 18000 )); then
    echo "${C_RED}${C_BOLD}[ALERT]${C_RESET} P95 latency ${p95}ms > 18000ms — sw-backend-dev 호출 (런북 §3)" >&2
  fi
  if [[ "$count_recs" -eq 0 ]]; then
    echo "${C_RED}${C_BOLD}[ALERT]${C_RESET} 최근 1h 추천량 0건 — 서비스 다운 가능성, sw-devops + sw-backend-dev 호출 (런북 §3)" >&2
  fi
  if (( u_int > 30 )); then
    echo "${C_YELLOW}${C_BOLD}[WARN]${C_RESET} region '??' 비율 ${unknown_pct}% > 30% — sw-backend-dev 호출 (런북 §3)" >&2
  fi
}

# ── 메인 루프 ────────────────────────────────────────────────────────
if [[ "$WATCH" -eq 1 ]]; then
  echo "${C_DIM}모니터링 시작 (간격 ${INTERVAL}s) — Ctrl+C 로 중단${C_RESET}"
  while true; do
    poll_once
    echo
    sleep "$INTERVAL"
  done
else
  poll_once
fi
