# PT Prescription — Software Team Rules

---

## 🚨 작업마다 필수 행동 (Every Task — 절대 생략 불가)

### 보드 실시간 업데이트

Board server: `http://34.47.91.197:3131`

**작업 시작 즉시 (첫 번째 행동):**
```bash
curl -s -X PATCH http://34.47.91.197:3131/api/todo/<todo-id> \
  -H "Content-Type: application/json" \
  -d '{"status":"active","title":"<작업명>","team":"software","agents":[{"agent":"<내 이름>","activity":"<지금 하는 일>"}]}'
curl -s -X PATCH http://34.47.91.197:3131/api/agent/<내 이름> \
  -H "Content-Type: application/json" \
  -d '{"status":"active","activity":"<지금 하는 일>"}'
```

**작업 완료 즉시 (마지막 행동):**
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

### LOG 기록 (🔴 필수 — 보드보다 우선)

**🚨 LOG 없으면 작업 완료로 인정하지 않음**

LOG 파일 경로: `pt-prescription/LOG-YYYY-MM.md` (팀 통합 파일)

기록 형식 (파일 끝에 append, **에이전트명 필수**):
```markdown
## YYYY-MM-DD | [내 에이전트명] | [TODO-ID] 작업명

### 계획 (작업 시작 시)
- [ ] 할 일 1
- [ ] 할 일 2

### 결과 (작업 완료 후)
- [x] 할 일 1 — 완료 메모
- [x] 할 일 2 — 완료 메모

### 이슈/변경사항
없음 또는 변경 내용

---
```

### 백로그 기록 (작업 중 발견 시 즉시)

발견 즉시 `C:/project/PT/KMovement Optimism/.jarvis/BACKLOG.md`에 추가:
```
## [YYYY-MM-DD] [agent-name] — [한 줄 제목]

**Priority**: high / medium / low
**Team**: software
**Background**: [왜 필요한지]
**To-do**: [구체적으로 무엇을]
**Related files**: [경로]
**Expected timing**: [언제쯤]
**Status**: 🔲 대기중
```

---

## 🔒 작업 전 확인 (Before Starting)

### 내 권한 범위

| 에이전트 | 쓰기 권한 | 읽기 권한 |
|---|---|---|
| sw-lead | `pt-prescription/` 전체 | `pt-prescription/` 전체 |
| sw-product-manager | `pt-prescription/docs/specs/` | `pt-prescription/` 전체 |
| sw-frontend-dev | `pt-prescription/index.html`, `css/`, `js/` | `pt-prescription/` 전체 |
| sw-backend-dev | `pt-prescription/api/` | `pt-prescription/` 전체 |
| sw-clinical-translator | `pt-prescription/docs/clinical-*.md` | `pt-prescription/` 전체 |
| sw-ux-researcher | `pt-prescription/docs/ux/` | `pt-prescription/` 전체 |
| sw-qa-tester | `pt-prescription/docs/qa/` | `pt-prescription/` 전체 |
| sw-devops | `vercel.json`, `.vercel/`, `debug/` | `pt-prescription/` 전체 |
| sw-auth-specialist | `api/auth/` | `api/`, `saas/schema.sql` |
| sw-db-architect | `saas/schema.sql`, `saas/migrations/`, `saas/docs/`, `saas/scripts/` | `saas/` 전체 + `research/techniques*` (읽기 전용) |

### 작업 범위 절대 경계

🚫 `pt-prescription/` 외부 파일 수정 절대 금지
- `../episodes/`, `../.jarvis/`, `../growth/`, `../research/` 등 접근 불가
- 외부 수정 필요 시 Jarvis에 요청

✅ `pt-prescription/` 내부 전체 허용 (권한 범위 내)

### DB 스키마 중복 방지 (절대 규칙 — SW팀 전용)

작업 전 반드시:
1. `saas/schema.sql`에서 같은 목적의 함수·테이블·컬럼 검색
2. 중복 발견 시 → 직접 생성/수정 금지, Jarvis에 "대체 vs 신규 생성" 승인 요청 후 진행
3. 마이그레이션 파일 추가 시도 → 기존 마이그레이션 내용 먼저 확인

✅ 올바른 순서: schema.sql 검색 → 중복 없음 확인 → Jarvis 보고 → 승인 후 진행
❌ 금지: 검증 없이 신규 함수/테이블 생성

### Git 워크플로우

- 항상 feature 브랜치에서 작업
- 의미 있는 커밋 메시지 사용 (한국어 가능)
- `main` 브랜치 직접 push 절대 금지 — PR 사용
- main 머지 시 Vercel 자동 배포

---

## 📁 디렉토리 구조 (Reference)

```
pt-prescription/
├── CLAUDE.md                    ← 이 파일 (sw팀 규칙)
├── index.html                   ← Frontend (sw-frontend-dev)
├── vercel.json                  ← Vercel 배포 설정 (sw-devops)
├── api/                         ← Serverless API (sw-backend-dev)
├── debug/                       ← Debug 대시보드 (sw-devops)
├── saas/                        ← DB (sw-db-architect)
│   ├── schema.sql
│   ├── migrations/
│   ├── scripts/
│   └── docs/
├── docs/                        ← 팀 공유 문서
│   ├── specs/                   ← 제품 명세 (sw-product-manager)
│   ├── ux/                      ← UX 리서치 (sw-ux-researcher)
│   └── qa/                      ← QA 문서 (sw-qa-tester)
├── sw-lead/ · sw-frontend-dev/ · sw-backend-dev/ · ...  ← 에이전트 홈
├── _archive/                    ← 이력 보관 (삭제 전 검토)
└── _to_delete/                  ← 삭제 대기 (Director 확인 후)
```

## 💭 KMO 철학 (모든 AI 추천에 적용)
- 통증 ≠ 손상 / 반파국화 / "Calm things down, and build things back up." — Greg Lehman
- 두려움 유발 표현 금지 / 근거 기반 추천만
