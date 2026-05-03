# PT 처방 도우미 — Product Specification

## 1. Product Overview

- **Product name:** PT 처방 도우미 (PT_prescription)
- **URL:** https://pt-prescription.vercel.app
- **GitHub:** https://github.com/Jass-Song/PT_prescription
- **Target users:** Novice physical therapists in Korea (1–5 years experience)
- **Mission:** Support evidence-based clinical decision-making for novice PTs — manual therapy technique selection + exercise prescription, powered by Claude AI and a curated technique database

---

## 2. Core Problem

Novice Korean PTs face:
- Difficulty choosing techniques due to limited clinical experience
- Gap between textbook knowledge and real-world clinical application
- Inefficiency of having to ask senior PTs every time
- Lack of criteria for selecting techniques per patient condition

---

## 3. Solution

Patient condition input → within therapist-preferred technique categories → Claude AI recommends specific techniques with detailed clinical guidance, sourced from a curated Supabase technique database.

---

## 4. Current Implementation State (Beta)

### 4.1 Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Single HTML file (HTML + CSS + JS, no framework) |
| Backend | Vercel Serverless Functions (Node.js ESM) |
| AI | Claude Haiku 4.5 (Anthropic API) |
| Vector search | Voyage AI (voyage-3-lite, 512-dim embeddings) + pgvector |
| Database | Supabase (PostgreSQL) — 45+ migrations applied |
| Deployment | Vercel (auto-deploy on GitHub main push) |
| Auth | Supabase Auth (email/password; OAuth providers via env flag) |

### 4.2 User Flow

**Step 1 — Settings (first use or via Settings button)**

Therapist selects preferred technique groups:

Manual Therapy groups (choose any):
- `mt_joint` — 관절가동술 (Maitland · Mulligan · HVLA)
- `mt_soft` — 연부조직 가동술 (MFR · ART · CTM · Deep Friction · Trigger Point · Anatomy Trains)
- `mt_neuro` — 신경가동술
- `mt_special` — 특수기법 (MDT · SCS)
- `mt_edu` — 통증 신경과학 교육 (PNE)

Exercise groups (choose any):
- `ex_neuro` — 신경근·운동조절 훈련 (Motor Control)
- `ex_strength` — 근력·저항성 운동
- `ex_aerobic` — 유산소·활동성 운동

Settings are persisted in Supabase (`user_profiles.pt_settings`) and synced cross-device.

**Step 2 — Patient Input**

| Field | Options |
|-------|---------|
| Region (부위) | 경추, 요추, 어깨 관절, 무릎 관절, 엉덩 관절, 발목 관절 |
| Acuity (시기) | 급성, 아급성, 만성 |
| Symptom (증상) | 움직임 시 통증, 안정 시 통증, 방사통 |

**Step 3 — AI Recommendation Output**

Manual Therapy recommendations (up to 3, from preferred categories):
- Patient position, therapist hand placement, movement steps (3-step format), dosage, target muscles (Korean/English), patient feedback cues
- Category info panel (basic principles, expandable)
- Applicable muscles list per modality card

Exercise recommendations (up to 2, from preferred categories):
- Start position, set/rep prescription, movement steps, target muscles, cuing

Clinical note (anti-catastrophizing, possibility framing)

"See another technique" button — excludes already-shown techniques, re-calls API

Star rating (★1–5) + text feedback per technique — saved to `ratings` table

**Anatomy Trains special path:**
When `category_anatomy_trains` is the only MT category selected, the API returns hardcoded fascial line data (no LLM call needed), sorted by symptom priority.

### 4.3 Authentication

- Login required for all API calls (JWT Bearer token)
- Supabase Auth (email/password)
- Sign-up tab hidden during beta (access control)
- OAuth (Google, Kakao) available via env flags (`OAUTH_GOOGLE_ENABLED`, `OAUTH_KAKAO_ENABLED`)
- PKCE flow handled by `api/auth/callback.js`
- Admin access restricted to `junnyhsong@gmail.com`

### 4.4 AI Recommendation Logic

1. User selects MT/EX category groups → mapped to Supabase `category_*` keys
2. Parallel: fetch active techniques from DB + generate Voyage AI query embedding
3. Parallel: pgvector similarity search (`match_techniques` RPC, threshold 0.3, top 20) + fetch category principles
4. Hybrid scoring: `finalScore = ruleNorm * 0.6 + vectorScore * 0.4`
   - Rule score: condition × category priority table (3-tier, by acuity + symptom)
   - Vector score: cosine similarity from pgvector
5. Diversity guard: max 2 per MT group, max 1 per category → top 6 candidates
6. Claude Haiku 4.5 selects best 3 MT + 2 EX from candidates and rewrites in plain Korean
7. `a급성` fallback: if no MT results for `아급성`, retries with `급성` parameters
8. Post-processing: attach `categoryInfo`, `applicableMuscles`, `isPrimary` (primary vs. secondary region), replace `techniqueId` with DB abbreviation

**Daily limit:** 20 recommendations per user (enforced via `recommendation_logs` count)

### 4.5 KMO Philosophy Prompt Principles

- 통증 ≠ 손상 (Pain ≠ Damage)
- Anti-catastrophizing — no fear-inducing expressions
- "Calm things down, then build things back up" (Greg Lehman)
- Evidence-based, no biomechanical posture/alignment framing
- Clinical note uses possibility language: "~일 수 있습니다", "~가능성이 있습니다"

---

## 5. API Endpoints

All endpoints are Vercel Serverless Functions (60s max duration).

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/recommend` | Required | Main recommendation engine — returns MT + EX techniques |
| POST | `/api/feedback` | Required | Save star rating (1–5) + notes for a technique |
| GET | `/api/history` | Required | Recent recommendation logs + liked techniques (★3+) |
| GET | `/api/settings` | Required | Load saved PT settings + category usage frequency |
| POST | `/api/settings` | Required | Save PT settings (mt_groups, ex_groups) |
| GET | `/api/config` | None | Returns Supabase URL + anon key for frontend |
| POST | `/api/log-error` | Optional | Client-side error telemetry → `error_logs` table |
| GET | `/api/debug-errors` | None* | Internal: error logs + latency stats (admin tool) |
| POST/GET | `/api/debug-scores` | None* | Internal: vector score debugging per condition |
| GET | `/api/admin` | Admin only | Admin dashboard: ratings, usage stats, errors (7-day) |
| GET | `/api/auth/providers` | None | List configured OAuth providers |
| GET | `/api/auth/callback` | None | Supabase OAuth PKCE code exchange handler |

*Internal debug endpoints are unauthenticated but intended for internal use only.

### Private Helpers (not routed)
- `api/_auth.js` — JWT verification via Supabase Auth API
- `api/_logger.js` — Server-side error logging to `error_logs` (service role key)
- `api/_logError.js` — Duplicate/legacy helper (see `_logger.js`)

---

## 6. Database Schema (Supabase / PostgreSQL)

### Core Tables

| Table | Purpose |
|-------|---------|
| `techniques` | Technique master data (49+ entries) — name, category, body_region, steps, applicable_muscles |
| `technique_categories` | Category master — category_key, name, basic_principles (JSONB) |
| `technique_tags` | Normalized tag vocabulary |
| `technique_stats` | Aggregated rating/usage stats per technique (auto-updated via trigger) |
| `technique_embeddings` | Voyage AI 512-dim pgvector embeddings per technique |
| `user_profiles` | PT profile + `pt_settings` JSONB (mt_groups, ex_groups) |
| `ratings` | Per-user star ratings (1–5) for recommended techniques, with technique_label fallback |
| `recommendation_logs` | Per-session AI recommendation history (user_id, region, acuity, symptom, categories, techniques, latency_ms) |
| `session_logs` | Lightweight per-request usage log (region, acuity, symptom, result_count, response_ms) |
| `error_logs` | Client + server error telemetry (DIY Sentry replacement) |
| `usage_logs` | Technique-level usage (source: manual/ai_recommendation/search etc.) |
| `user_favorites` | Technique bookmarks per user |
| `community_cases` | Future: shared case reports (not yet in active use) |

### Key Enums

- `body_region`: cervical, thoracic, lumbar, sacroiliac, shoulder, elbow, wrist_hand, hip, knee, ankle_foot, temporomandibular, rib, full_spine
- `evidence_level`: level_1a → level_5, insufficient
- `rating_outcome`: excellent, good, moderate, poor, no_effect, adverse

### Key Functions & Triggers

- `fn_update_updated_at()` — auto-update `updated_at` on row changes
- `fn_refresh_technique_stats()` — recalculate `technique_stats` on rating INSERT/UPDATE
- `fn_increment_technique_uses()` — increment `total_uses` on usage_log INSERT
- `fn_sync_favorite_count()` — sync `favorite_count` on user_favorites change
- `match_techniques` RPC — pgvector cosine similarity search with threshold + match_count params

### Key Views

- `v_techniques_with_stats` — techniques + category + aggregated stats
- `v_user_activity_summary` — per-user usage summary
- `recommendation_analytics` — recommendation logs + user display_name

### RLS Policies

- `ratings`: SELECT/INSERT own rows (`auth.uid() = user_id`)
- `recommendation_logs`: SELECT/INSERT own rows
- `session_logs`: SELECT own rows; INSERT via service role only
- `error_logs`: no user-facing policy; service role write only

---

## 7. Deployment & Infrastructure

| Item | Detail |
|------|--------|
| Hosting | Vercel (Hobby/Pro) |
| Auto-deploy | GitHub main branch → Vercel |
| Function timeout | 60 seconds (all `api/*.js`) |
| Routing | `api/*` → serverless functions; all other paths → static files |
| Environment variables | `ANTHROPIC_API_KEY`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `VOYAGE_API_KEY`, `APP_URL`, `OAUTH_GOOGLE_ENABLED`, `OAUTH_KAKAO_ENABLED` |

---

## 8. Debug & Monitoring

| Tool | Path | Description |
|------|------|-------------|
| Error log dashboard | `/debug/errors.html` | Client + server errors, latency P50/P95 |
| Admin dashboard | `/debug/admin.html` | Ratings, usage stats, daily counts, unique users |
| Debug API | `/api/debug-errors` | Raw error_logs + recommendation latency stats |
| Score debug API | `/api/debug-scores` | Vector + rule scores per technique for a given condition |

---

## 9. Current Feature Status

### Implemented (Beta-ready)

- [x] Supabase Auth login/logout
- [x] Settings screen (MT + EX category selection, synced to Supabase)
- [x] Patient input screen (region, acuity, symptom)
- [x] AI recommendation (Claude Haiku 4.5 + Voyage AI hybrid)
- [x] 6-region support (경추, 요추, 어깨, 무릎, 엉덩, 발목)
- [x] 3-acuity support (급성, 아급성, 만성)
- [x] Anatomy Trains special path (no LLM call)
- [x] Star rating (★1–5) + feedback text per technique
- [x] Recommendation history tab (recent logs + liked techniques)
- [x] Daily limit (20 requests/user/day)
- [x] Category principles panel (expandable "basic principles" per modality)
- [x] Applicable muscles display per modality card
- [x] Primary vs. secondary region result separation
- [x] Session usage logging (`session_logs`)
- [x] Error telemetry (`error_logs`, `/api/log-error`)
- [x] Admin dashboard (`/debug/admin.html`, `/debug/errors.html`)
- [x] Cross-device settings sync via Supabase
- [x] GitHub CLI setup + PR-based deployment workflow
- [x] Vercel environment variables configured

### In Progress / Pending

- [ ] Password change feature (PR #10 in progress)
- [ ] PR #9 merge (sign-up tab hidden)
- [ ] Beta tester account creation (Director action via Supabase Dashboard)
- [ ] `is_published` status audit (Director action via Supabase Dashboard)
- [ ] Weekly survey Google Forms (sw-product-manager responsibility)
- [ ] Beta feedback analysis framework (sw-ux-researcher responsibility)
- [ ] NPS survey setup
- [ ] 7-day return rate query

---

## 10. Product Roadmap

### Phase 1 (Current) — AI Recommendation Beta

Core recommendation loop with user feedback collection. Focus: validate clinical usefulness with 10–20 novice PT beta testers.

### Phase 2 — Ratings-Weighted Recommendation

- Incorporate `technique_stats.recommendation_weight` into recommendation scoring
- "See another technique" improvements using ratings data
- Patient session tracking (anonymous patient IDs)

### Phase 3 — Personalization & History

- Per-therapist technique effectiveness tracking
- "Last session this patient responded well to X" alerts
- Condition-based TOP 3 technique reports
- Clinic-level multi-therapist data

---

## 11. Monetization Model (Planned)

| Plan | Features | Price |
|------|----------|-------|
| Free | 20 rec/day, core techniques | Free |
| Pro | Unlimited rec, rating history, patient records | ₩15,000/month |
| Clinic | Multi-therapist, patient DB, analytics report | ₩50,000/month |

---

## 12. Development Team (KMO Software Team)

| Agent | Role |
|-------|------|
| sw-lead | Software team overall |
| sw-product-manager | Product planning & specs |
| sw-frontend-dev | UI/UX development |
| sw-backend-dev | API development |
| sw-clinical-translator | KMO clinical knowledge → feature spec |
| sw-ux-researcher | PT field UX research |
| sw-qa-tester | Testing |
| sw-devops | Deployment / infrastructure |
| sw-auth-specialist | Auth / payment |
| sw-db-architect | DB design |

---

## 13. KMO Channel Integration Strategy

- KMO content (episodes, cardnews) serves as the marketing channel reaching PTs
- Service embeds KMO anti-catastrophizing philosophy → brand consistency
- KMO paid course students to receive Pro plan discounts (planned)

---

*Last updated: 2026-05-03*
*Updated by: sw-product-manager*
*Previous version: 2026-04-24*
