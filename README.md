# PT 처방 도우미 (PT Prescription Assistant)

**Live**: https://pt-prescription.vercel.app
**Stack**: Vanilla JS · Vercel Serverless · Claude API · Supabase + pgvector · Voyage AI
**Status**: Closed beta launching 2026-05-05

## What It Does

A clinical decision support tool for novice Korean physical therapists (1~5 years experience). Therapist enters patient condition (body region · acuity · symptom) and selects preferred technique categories; the AI returns ranked manual therapy + exercise prescriptions with detailed clinical guidance, sourced from a curated database of ~370 evidence-based techniques.

## Core Features

| Feature | What it does |
|---------|--------------|
| **AI 추천 엔진** | 환자 조건 + 치료사 선호 카테고리 → 룰 기반 점수 (`CONDITION_CATEGORY_SCORES`) + pgvector 임베딩 유사도 → Claude Haiku 가 임상 적용 순서·자세·도수·메모 작성 |
| **부위 6개** | 경추 · 요추 · 어깨 · 무릎 · 엉덩 · 발목 |
| **수기치료 12 카테고리** | Maitland · Mulligan · MFR · ART · CTM · Deep Friction · Trigger Point · Anatomy Trains · 신경가동술 · MDT · SCS · PNE |
| **운동 처방** | 신경근·근력·유산소 그룹 — 자세·세트·반복·큐잉 |
| **사용자 설정 동기화** | 선호 카테고리·등급·일일 한도 → `user_profiles.pt_settings` (Supabase) |
| **별점 + 효과 평가** | ⭐1~5 + outcome (excellent/good/moderate/poor/no_effect/adverse) + indication_accuracy 1~5 + 메모. 트리거가 자동으로 `recommendation_weight` 갱신 |
| **하이브리드 점수 융합** | 룰 점수 + 벡터 유사도 + 사용자 피드백 가중치 → 최종 추천 순위 |
| **사용 이력** | recommendation_logs · usage_logs · session_logs 누적 (분석·개인화 기반) |
| **금기증 필터** | `contraindication_tags` 배열 hard filter — 안전성 |
| **일일 한도** | 등급별 차등 (beta 20회 / pro / admin) — KST 자정 리셋 |
| **베타 게이트** | `is_allowed = true` user_profiles 만 접근. 별도 코드 게이트 없음 — 로그인 자체가 게이트 |
| **어드민 대시보드** | `/debug/admin.html` — 사용자 등급 관리 + 사용량 모니터링 |
| **에러 텔레메트리** | `/debug/errors.html` — 클라이언트/서버 에러 + 응답 시간 P50/P95 |

## Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| Frontend | Vanilla HTML/CSS/JS (single `index.html`) | 프레임워크 없이 로딩 빠름, 베타 단계 단순함 |
| Backend | Vercel Serverless Functions (Node.js 18+ ESM) | 서버 운영 부담 0, 자동 배포, KST 인지 |
| AI 텍스트 | **Claude Haiku 4.5** (Anthropic API) | 임상 메모·자세 설명 생성 |
| 임베딩 | **Voyage AI** `voyage-3-lite` (512차원) | 한국어 임상 텍스트 벡터화, 무료 플랜 호환 |
| Vector DB | **pgvector** in Supabase Postgres + IVFFlat 인덱스 | 룰 점수와 동일 트랜잭션 내 처리 |
| RDB | **Supabase** (PostgreSQL 15 + RLS) | Auth + DB + RLS 통합, 60+ 마이그레이션 |
| Auth | Supabase Auth (email/pw + OAuth Google/Kakao 코드 준비) | RLS 정책 + JWT, 베타 동안 OAuth 비활성 |
| Deployment | Vercel (GitHub main 자동 배포) | 무중단, 환경변수 분리 |
| Telemetry | 자체 `error_logs` + `recommendation_logs.latency_ms` | DIY Sentry 대체, 베타 비용 0 |

## Architecture

```
[ Browser ]
   │  index.html (Vanilla JS + Supabase JS SDK)
   │
   ├─ POST /api/recommend        ─→ Claude Haiku + pgvector + 룰 점수 합성
   ├─ POST /api/feedback         ─→ ratings INSERT (트리거 → technique_stats)
   ├─ GET/POST /api/settings     ─→ user_profiles.pt_settings JSONB
   ├─ GET /api/history           ─→ 사용자 이력 + 즐겨찾기
   ├─ GET /api/admin             ─→ 등급 관리 (관리자만)
   ├─ POST /api/log-error        ─→ error_logs 텔레메트리
   └─ GET /api/auth/callback     ─→ OAuth PKCE 코드 교환
                  │
                  ▼
         [ Supabase PostgreSQL ]
            techniques (~370행, 12 카테고리, 6 부위)
            technique_embeddings (vector 512)
            ratings ──[trigger fn_refresh_technique_stats]──▶ technique_stats
            user_profiles + recommendation_logs + session_logs + error_logs
            RLS: 인증 사용자만, 본인 데이터만
                  │
                  ▼
            [ Claude Haiku 4.5 API ]
            [ Voyage AI Embeddings API ]
```

## Project Structure

```
pt-prescription/
├── index.html               메인 SPA (단일 파일, ~3800줄)
├── vercel.json              라우팅·함수 maxDuration 60s
├── api/                     서버리스 함수
│   ├── _auth.js             JWT 검증 헬퍼
│   ├── _logger.js           서버 에러 → error_logs (RLS 우회)
│   ├── recommend.js         AI 추천 핵심 (룰 + 벡터 + LLM)
│   ├── feedback.js          별점 + outcome + accuracy 저장
│   ├── settings.js          사용자 설정 GET/POST
│   ├── history.js           이력·즐겨찾기
│   ├── admin.js             관리자 대시보드 API
│   ├── config.js            anon key 안전 노출
│   ├── log-error.js         클라이언트 에러 수집
│   ├── debug-*.js           내부 디버그 도구 (벡터 점수, 에러)
│   └── auth/                OAuth (Google/Kakao 콜백·providers)
├── debug/                   내부 디버그 페이지
│   ├── index.html           D3 force-directed 기법 그래프
│   ├── admin.html           등급별 사용자 관리
│   └── errors.html          에러 + 응답 시간 통계
├── saas/
│   ├── schema.sql           마스터 스키마
│   ├── migrations/          60+ 단계별 SQL (002~050b)
│   ├── scripts/             embed-techniques.js, verify SQL
│   └── docs/                스키마 설계, 카테고리 원칙, 분석 쿼리
├── docs/
│   ├── DEV-HANDOFF.md       개발자 인계 가이드 (388줄)
│   ├── specs/PRODUCT_SPEC.md  상세 제품 스펙 (319줄)
│   ├── specs/MVP-BETA-CHECKLIST.md  베타 출시 체크리스트
│   └── qa/                  QA 체크리스트
├── CLAUDE.md                Claude Code/팀 에이전트 운영 룰
└── sw-*/                    SW 팀 에이전트 홈 (LOG/TODO/MEMORY)
```

## Recommendation Pipeline

```
입력: { region, acuity, symptom, selectedCategories, focusPillars? }
        │
        ▼
1. Hard Filter (DB 쿼리 레이어)
   - body_region 매칭
   - is_active = true AND is_published = true
   - contraindication_tags && active_contraindications → NOT IN
   - target_tags 시기 적합성
        │
        ▼
2. 룰 점수 계산 (per technique)
   - CONDITION_CATEGORY_SCORES[acuity][symptom][category] (0~3)
   - 사용자 선호 카테고리 가산점
   - technique_stats.recommendation_weight 가중치 (0~1)
        │
        ▼
3. 벡터 유사도 (pgvector)
   - 입력 텍스트 → Voyage AI 임베딩
   - cosine distance vs technique_embeddings
        │
        ▼
4. 점수 융합 (recommend.js maxPerCategory 1로 다양성 강제)
   - 최종 점수 = 룰 0.5 + 벡터 0.3 + 가중치 0.2
   - 카테고리당 최대 1개 → 다양성 보장
        │
        ▼
5. Claude Haiku 임상 적용 가이드 생성
   - 환자 자세, 치료사 손, 단계별 동작, 도수, 환자 피드백
   - KMO 철학 (anti-catastrophizing, 통증 ≠ 손상) 강제
        │
        ▼
출력: { manualTherapy[], exercise[], clinicalNote, sessionSummary }
```

## recommendation_weight 자동 갱신 (피드백 루프)

```
ratings INSERT/UPDATE/DELETE
    │
    ▼
trg_refresh_stats_on_rating (AFTER ROW)
    │
    ▼
fn_refresh_technique_stats() [SECURITY DEFINER]
    │
    ▼
technique_stats UPSERT (가중치 4 컴포넌트):
    별점 (avg_star_rating / 5)              × 0.20
  + 적응증 정확도 (NULL → 디폴트 3) / 5      × 0.30
  + 최근 30일 활성도 (MIN(uses, 20) / 20)   × 0.20
  + 효과 분류 (excellent + good 비율)        × 0.30
    [outcome 미입력 행은 분모에서 제외, 전부 NULL → 0.5 중립]
```

## 개발·배포 환경

### 로컬 실행 (Vercel CLI)
```bash
npm install -g vercel
vercel link            # 최초 1회
vercel dev             # localhost:3000
```

### 환경변수 (Vercel Dashboard 또는 .env)
```
SUPABASE_URL=https://gnusyjnviugpofvaicbv.supabase.co
SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...
ANTHROPIC_API_KEY=...
VOYAGE_API_KEY=...
```

### 임베딩 생성·갱신 (신규 기법 추가 후)
```bash
node saas/scripts/embed-techniques.js --only-new
```

### 마이그레이션 실행
Supabase 대시보드 SQL 에디터에 `saas/migrations/NNN-*.sql` 순서대로 붙여넣고 Run.
서비스 롤 컨텍스트라 RLS 우회.

## 주요 문서

| 문서 | 용도 |
|------|------|
| [`docs/specs/PRODUCT_SPEC.md`](docs/specs/PRODUCT_SPEC.md) | 상세 제품 스펙 (사용자 플로우, 화면별) |
| [`docs/DEV-HANDOFF.md`](docs/DEV-HANDOFF.md) | 신규 개발자 인계 가이드 |
| [`docs/specs/MVP-BETA-CHECKLIST.md`](docs/specs/MVP-BETA-CHECKLIST.md) | 베타 출시 체크리스트 |
| [`saas/docs/schema_design.md`](saas/docs/schema_design.md) | DB 스키마 설계 결정 근거 |
| [`saas/docs/ANALYTICS-QUERIES.md`](saas/docs/ANALYTICS-QUERIES.md) | 베타 운영 모니터링 SQL |
| [`saas/docs/CATEGORY-PRINCIPLES-TEMPLATE.md`](saas/docs/CATEGORY-PRINCIPLES-TEMPLATE.md) | 카테고리별 임상 원칙 |
| [`docs/qa/C3-C4-QA-CHECKLIST.md`](docs/qa/C3-C4-QA-CHECKLIST.md) | C-3/C-4 검증 단계 |
| `CLAUDE.md` | SW 팀 Claude 에이전트 운영 룰 |

## KMO Philosophy (모든 AI 출력에 적용)

- 통증 ≠ 손상
- Anti-catastrophizing
- "Calm things down, and build things back up." — Greg Lehman
- 공포 유발 표현 금지
- 근거 기반 추천만

## License & Ownership

Proprietary. © Jass Song / K Movement Optimism.
