# PT Prescription — MVP Beta Test Preparation Checklist
> Last updated: 2026-04-30

---

## 1. Core Features

| Item | Status |
|------|------|
| ~~AI recommendation engine (Claude Sonnet + Voyage AI hybrid)~~ | ~~✅ done~~ |
| ~~Cervical & lumbar 9-scenario recommendation support~~ | ~~✅ done~~ |
| ~~Category description UI (one-line explanation for novice PTs)~~ | ~~✅ done~~ |
| ~~Multi-region recommendation support~~ | ~~✅ done~~ |
| ~~Acuity filter exercise prescription applied~~ | ~~✅ done (bug fixed)~~ |
| ~~API daily limit 20 requests~~ | ~~✅ done~~ |
| ~~429 error user-friendly message~~ | ~~✅ done~~ |
| ~~KMO philosophy prompt (anti-catastrophizing)~~ | ~~✅ done~~ |

---

## 2. Database

| Item | Status |
|------|------|
| ~~Supabase DB setup (40+ migrations)~~ | ~~✅ done~~ |
| ~~Cervical & lumbar technique 49+ seed data~~ | ~~✅ done~~ |
| ~~pgvector embedding (512-dim, Voyage AI)~~ | ~~✅ done~~ |
| ~~ratings table (migration 041)~~ | ~~✅ done — Supabase execution complete~~ |
| ~~session_logs table (migration 043)~~ | ~~✅ done — Supabase execution complete~~ |
| Run is_published status check query | ⬜ Director to do directly (Supabase Dashboard) |

---

## 3. Auth & Access Control

| Item | Status |
|------|------|
| ~~Supabase Auth login/logout UI~~ | ~~✅ done~~ |
| ~~Sign-up tab hidden (access control during beta)~~ | ~~✅ done — PR #9~~ |
| Password change feature | 🔄 PR being created |
| Create beta tester accounts | ⬜ Director to do directly (Supabase Dashboard → Authentication → Users → Add user) |

---

## 4. Feedback & Monitoring

| Item | Status |
|------|------|
| ~~Star rating UI (★1~5) + feedback text~~ | ~~✅ done — PR #7 merged~~ |
| ~~`/api/feedback` ratings table integration~~ | ~~✅ done~~ |
| ~~usage_logs (session_logs) auto-recording~~ | ~~✅ done — PR #8 merged~~ |
| ~~Error log dashboard (/debug/errors.html)~~ | ~~✅ done~~ |
| ~~Admin dashboard (/debug/admin.html)~~ | ~~✅ done~~ |
| ~~feedback.js error capture enhancement (await + try/catch)~~ | ~~✅ done~~ |
| Run 9-scenario manual test matrix | ⬜ sw-qa-tester responsible |

---

## 5. Deployment & Infra

| Item | Status |
|------|------|
| ~~Vercel auto-deployment (GitHub main integration)~~ | ~~✅ done~~ |
| ~~Vercel environment variable registration (ANTHROPIC_API_KEY, SUPABASE_ANON_KEY, etc.)~~ | ~~✅ done~~ |
| ~~GitHub CLI (gh) installation and authentication~~ | ~~✅ done~~ |
| ~~Agent role-based file reorganization~~ | ~~✅ done — PR #6 merged~~ |

---

## 6. Beta Operations

| Item | Status |
|------|------|
| Recruit beta participants (10~20 people, 1~5 years experience PTs) | ⬜ Director to do directly |
| Create tester accounts (Supabase Dashboard) | ⬜ Director to do directly |
| Tester onboarding materials (URL + account info email) | ⬜ Director to do directly |
| Create weekly survey Google Forms | ⬜ sw-product-manager responsible |
| Design beta feedback analysis framework | ⬜ sw-ux-researcher responsible |

---

## 7. Outcome Measurement Setup

| Metric | Collection Method | Status |
|------|----------|------|
| API response time P50/P95 | /debug/errors.html | ~~✅ dashboard ready~~ |
| Error rate | /debug/admin.html | ~~✅ dashboard ready~~ |
| Average star rating (ratings table) | Supabase query | ~~✅ table ready~~ |
| DAU / session count (session_logs) | Supabase query | ~~✅ table ready~~ |
| NPS (weekly survey) | Google Forms | ⬜ survey not yet created |
| 7-day return rate | Supabase query | ⬜ query not yet written |

---

## 8. PR Status

| PR | Description | Status |
|----|------|------|
| ~~#5~~ | ~~feedback/ratings mapping fix~~ | ~~✅ merged~~ |
| ~~#6~~ | ~~Agent role-based file reorganization~~ | ~~✅ merged~~ |
| ~~#7~~ | ~~Star rating feedback UI~~ | ~~✅ merged~~ |
| ~~#8~~ | ~~usage_logs auto-recording + scenario validation matrix~~ | ~~✅ merged~~ |
| #9 | Hide sign-up tab | ⬜ awaiting merge |
| #10 (planned) | Password change feature | 🔄 PR being created |

---

## ✅ Beta Launch Minimum Requirements (Launch Gate)

- [ ] PR #9, #10 merge complete
- [ ] Verify password change feature works
- [ ] Create at least 1 tester account + login test
- [ ] Confirm star rating feedback is saved (ratings table)
- [ ] Verify data in admin dashboard
