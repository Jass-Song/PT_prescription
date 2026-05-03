# PT Prescription — Software Team Rules

## Scope of Work (Absolute Boundary)
The directory containing this CLAUDE.md (`pt-prescription/`) is the **entire scope of work** for the software team.

🚫 **Strictly prohibited**: Modifying files outside `pt-prescription/`
- Access to `../episodes/`, `../.jarvis/`, `../growth/`, and other parent directories is not allowed
- If read access is needed, request it from Jarvis

✅ **Allowed**: All files inside `pt-prescription/`

---

## Product Information
- **Product name**: PT 처방 도우미
- **URL**: https://pt-prescription.vercel.app
- **GitHub**: https://github.com/Jass-Song/PT_prescription
- **Deployment**: Vercel (auto-deploy via GitHub integration)
- **Tech stack**: HTML/CSS/JS + Vercel Serverless + Claude API + Supabase
- **Target users**: Novice physical therapists in Korea

---

## Software Team Agents & Permissions

| Agent | Write Permission | Read Permission |
|-------|----------------|----------------|
| sw-lead | All of `pt-prescription/` | All of `pt-prescription/` |
| sw-product-manager | `pt-prescription/docs/specs/` | All of `pt-prescription/` |
| sw-frontend-dev | `pt-prescription/index.html`, `pt-prescription/css/`, `pt-prescription/js/` | All of `pt-prescription/` |
| sw-backend-dev | `pt-prescription/api/` | All of `pt-prescription/` |
| sw-clinical-translator | `pt-prescription/docs/clinical-*.md` | All of `pt-prescription/` |
| sw-ux-researcher | `pt-prescription/docs/ux/` | All of `pt-prescription/` |
| sw-qa-tester | `pt-prescription/docs/qa/` | All of `pt-prescription/` |
| sw-devops | `pt-prescription/vercel.json`, `pt-prescription/.vercel/`, `pt-prescription/debug/` | All of `pt-prescription/` |
| sw-auth-specialist | `pt-prescription/api/auth/` | `pt-prescription/api/`, `pt-prescription/saas/schema.sql` |
| sw-db-architect | `pt-prescription/saas/schema.sql`, `pt-prescription/saas/migrations/`, `pt-prescription/saas/docs/`, `pt-prescription/saas/scripts/` | All of `pt-prescription/saas/` |
| sw-db-architect (additional read) | — | `research/techniques_research/` (read-only), `research/techniques/` (read-only) |

---

## Directory Structure

```
pt-prescription/
├── CLAUDE.md                    ← This file (sw team rules)
├── index.html                   ← Frontend (sw-frontend-dev)
├── vercel.json                  ← Vercel deployment config (sw-devops)
├── api/                         ← Serverless API (sw-backend-dev)
│   ├── _auth.js                 ← JWT auth helper
│   ├── _logger.js               ← Server error logging helper
│   ├── recommend.js
│   ├── feedback.js
│   ├── history.js
│   ├── settings.js
│   ├── config.js
│   ├── admin.js
│   ├── log-error.js
│   ├── debug-errors.js
│   └── debug-scores.js
├── debug/                       ← Debug dashboard (sw-devops)
│   ├── index.html
│   ├── errors.html
│   └── admin.html
├── saas/                        ← DB (sw-db-architect)
│   ├── schema.sql               ← Master schema
│   ├── migrations/              ← Numbered migration SQL files
│   ├── scripts/                 ← Utility scripts
│   └── docs/                   ← DB documentation (guides, templates, reports)
├── docs/                        ← Team shared documents
│   ├── specs/                   ← Product specifications (sw-product-manager)
│   │   └── PRODUCT_SPEC.md
│   ├── DEV-HANDOFF.md           ← Team-wide handoff guide
│   ├── ux/                      ← UX research (sw-ux-researcher)
│   └── qa/                      ← QA documents (sw-qa-tester)
├── sw-lead/                     ← sw-lead home
├── sw-backend-dev/              ← sw-backend-dev home
├── sw-frontend-dev/             ← sw-frontend-dev home
├── sw-db-architect/             ← sw-db-architect home
├── sw-devops/                   ← sw-devops home
├── sw-product-manager/          ← sw-product-manager home
├── sw-auth-specialist/          ← sw-auth-specialist home
├── sw-clinical-translator/      ← sw-clinical-translator home
├── sw-ux-researcher/            ← sw-ux-researcher home
├── sw-qa-tester/                ← sw-qa-tester home
├── _archive/                    ← History archive (review before deletion)
└── _to_delete/                  ← Pending deletion (awaiting Director confirmation)
```

---

## KMO Philosophy (Must be applied to all AI recommendations)
- 통증 ≠ 손상 (Pain does not equal damage)
- Anti-catastrophizing
- "Calm things down, and build things back up." — Greg Lehman
- Fear-inducing expressions are strictly prohibited
- Evidence-based recommendations only

---

## Board Update Rules

Board server: `http://34.47.91.197:3131`

**When starting a task:**
```bash
curl -s -X PATCH http://34.47.91.197:3131/api/todo/<todo-id> \
  -H "Content-Type: application/json" \
  -d '{"status":"active","title":"<작업명>","team":"software","agents":[{"agent":"<내 이름>","activity":"<지금 하는 일>"}]}'
curl -s -X PATCH http://34.47.91.197:3131/api/agent/<내 이름> \
  -H "Content-Type: application/json" \
  -d '{"status":"active","activity":"<지금 하는 일>"}'
```

**When completing a task:**
```bash
curl -s -X PATCH http://34.47.91.197:3131/api/todo/<todo-id> \
  -H "Content-Type: application/json" \
  -d '{"status":"done","outcome":"<결과물 요약>"}'
curl -s -X PATCH http://34.47.91.197:3131/api/agent/<내 이름> \
  -H "Content-Type: application/json" \
  -d '{"status":"done","activity":"<완료 내용>"}'
curl -s -X POST http://34.47.91.197:3131/api/activity \
  -H "Content-Type: application/json" \
  -d '{"agent":"<내 이름>","action":"<완료 내용 한 줄>"}'
```

---

## DB Function/Schema Duplication Prevention Rule (Absolute Rule)

Before any task, you must:
1. Search `saas/schema.sql` for existing functions, tables, and columns serving the same purpose
2. If a duplicate is found → Do not create/modify directly; request **"replace vs. create new"** approval from Jarvis before proceeding
3. Same applies to adding migration files — check existing migration contents first

✅ Correct order: Search schema.sql → Confirm no duplicates → Report to Jarvis → Proceed after approval
❌ Prohibited: Creating new functions/tables without verification

---

## ⚠️ Agent Home Folder & LOG Recording Rule (Absolute Rule)

Each agent maintains a monthly LOG file in their home folder (`pt-prescription/<agent-name>/`).

**LOG file path**: `pt-prescription/<agent-name>/LOG-YYYY-MM.md`

**If the file does not exist, create it first** (first task of a new month):
```markdown
# [에이전트명] 월간 작업 로그 — YYYY-MM

> 작업할 때마다 append 방식으로 기록합니다. 삭제 금지.

---
```

**Recording format** (append to end of file; must be done before marking the task done on the board):
```markdown
## YYYY-MM-DD | [TODO-ID] 작업명

- **지시 받은 내용**: 한 줄 요약
- **수행한 작업**: 구체적으로 무엇을 했는지
- **결과물**: 파일 경로 또는 "없음"
- **이슈/메모**: (있을 경우만)

---
```

**🚨 A task is not considered complete if the LOG entry is missing.**

---

## Git Workflow
- Always work on feature branches
- Use meaningful commit messages (Korean is acceptable)
- Direct push to `main` branch is strictly prohibited — use PRs
- Vercel auto-deploys on merge to `main`

---

## 📓 Monthly Task LOG Rule (Mandatory for all agents)

After completing a task, **before marking it done on the board**, you must record it in your LOG file.

**LOG file path**: `pt-prescription/[my-agent-name]/LOG-YYYY-MM.md`
(e.g., `pt-prescription/sw-db-architect/LOG-2026-04.md`)

**If the file does not exist, create it first** (first task of a new month):
```markdown
# [에이전트명] 월간 작업 로그 — YYYY-MM

> 작업할 때마다 append 방식으로 기록합니다. 삭제 금지.

---
```

**Recording format** (append to end of file):
```markdown
## YYYY-MM-DD | [TODO-ID] 작업명

- **지시 받은 내용**: 한 줄 요약
- **수행한 작업**: 구체적으로 무엇을 했는지
- **결과물**: 파일 경로 또는 "없음"
- **이슈/메모**: (있을 경우만)

---
```

---

## 📌 Backlog Recording Rule (Mandatory for all agents)

During a task, if any of the following situations arise, you **must** record them in `.jarvis/BACKLOG.md`:
- Changes that cannot be made now but need to be done later
- Discovered improvement opportunities (code, content, or process)
- Tasks deferred due to dependencies
- Ideas to propose to the Director

**Recording format:**
```
## [YYYY-MM-DD] [agent-name] — [one-line title]

**Priority**: high / medium / low
**Team**: [team name]
**Background**: [why it's needed]
**To-do**: [what specifically needs to be done]
**Related files**: [path]
**Expected timing**: [when approximately]
**Status**: 🔲 대기중
```

Backlog file path: `C:/project/PT/KMovement Optimism/.jarvis/BACKLOG.md`
Notion sync: Jarvis periodically reflects entries in the Notion "Backlog & Future Plans" page
