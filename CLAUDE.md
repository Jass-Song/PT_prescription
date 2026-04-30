# PT Prescription — 소프트웨어팀 규칙

## 작업 범위 (절대 경계)
이 CLAUDE.md가 있는 디렉토리(`pt-prescription/`) 가 소프트웨어팀의 **전체 작업 범위**다.

🚫 **절대 금지**: `pt-prescription/` 밖의 파일 수정
- `../episodes/`, `../.jarvis/`, `../growth/` 등 상위 디렉토리 접근 불가
- 읽기도 필요한 경우 쟈르스에게 요청

✅ **허용**: `pt-prescription/` 내부 파일 전체

---

## 제품 정보
- **제품명**: PT 처방 도우미
- **URL**: https://pt-prescription.vercel.app
- **GitHub**: https://github.com/Jass-Song/PT_prescription
- **배포**: Vercel (GitHub 연동 자동 배포)
- **기술 스택**: HTML/CSS/JS + Vercel Serverless + Claude API + Supabase
- **대상 사용자**: 한국 초보 물리치료사 (novice PT)

---

## 소프트웨어팀 에이전트 & 권한

| 에이전트 | 쓰기 권한 | 읽기 권한 |
|---------|----------|----------|
| sw-lead | `pt-prescription/` 전체 | `pt-prescription/` 전체 |
| sw-product-manager | `pt-prescription/docs/specs/` | `pt-prescription/` 전체 |
| sw-frontend-dev | `pt-prescription/index.html`, `pt-prescription/css/`, `pt-prescription/js/` | `pt-prescription/` 전체 |
| sw-backend-dev | `pt-prescription/api/` | `pt-prescription/` 전체 |
| sw-clinical-translator | `pt-prescription/docs/clinical-*.md` | `pt-prescription/` 전체 |
| sw-ux-researcher | `pt-prescription/docs/ux/` | `pt-prescription/` 전체 |
| sw-qa-tester | `pt-prescription/docs/qa/` | `pt-prescription/` 전체 |
| sw-devops | `pt-prescription/vercel.json`, `pt-prescription/.vercel/` | `pt-prescription/` 전체 |
| sw-auth-specialist | `pt-prescription/api/auth/` | `pt-prescription/api/`, `pt-prescription/saas/schema.sql` |
| sw-db-architect | `pt-prescription/saas/schema.sql`, `pt-prescription/saas/migrations/` | `pt-prescription/saas/` 전체 |
| sw-db-architect (추가 읽기) | — | `research/techniques_research/`(읽기 전용), `research/techniques/`(읽기 전용) |

---

## 디렉토리 구조

```
pt-prescription/
├── CLAUDE.md                    ← 이 파일 (sw팀 규칙)
├── PRODUCT_SPEC.md              ← 제품 기획 명세서
├── index.html                   ← 프론트엔드
├── vercel.json                  ← Vercel 배포 설정
├── api/
│   └── recommend.js             ← Serverless API
├── saas/                        ← DB, 스키마, 마이그레이션
│   ├── schema.sql
│   ├── schema_design.md
│   ├── seed.sql
│   ├── migrations/
│   ├── scripts/
│   └── [기타 saas 파일들 — techniques는 research/로 이동됨]
└── docs/                        ← 기획 문서 (생성 시)
    ├── specs/
    ├── ux/
    └── qa/
```

---

## KMO 철학 (AI 추천에 반드시 적용)
- 통증 ≠ 손상 (Pain does not equal damage)
- 반카타스트로파이징 (Anti-catastrophizing)
- "Calm things down, and build things back up." — Greg Lehman
- 공포 유발 표현 절대 금지
- 근거기반 추천만 제공

---

## 보드 업데이트 규칙

보드 서버: `http://34.47.91.197:3131`

**작업 시작 시:**
```bash
curl -s -X PATCH http://34.47.91.197:3131/api/todo/<todo-id> \
  -H "Content-Type: application/json" \
  -d '{"status":"active","title":"<작업명>","team":"software","agents":[{"agent":"<내 이름>","activity":"<지금 하는 일>"}]}'
curl -s -X PATCH http://34.47.91.197:3131/api/agent/<내 이름> \
  -H "Content-Type: application/json" \
  -d '{"status":"active","activity":"<지금 하는 일>"}'
```

**작업 완료 시:**
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

## DB 함수/스키마 중복 방지 규칙 (절대 원칙)

작업 전 반드시:
1. `saas/schema.sql`에서 동일한 역할의 함수·테이블·컬럼 검색
2. 중복 발견 시 → 직접 생성/수정 금지, 쟈르스에게 **"대체 vs 신규 생성"** 승인 요청 후 진행
3. 마이그레이션 파일 추가도 동일 — 기존 migration 내용 먼저 확인

✅ 올바른 순서: schema.sql 검색 → 중복 확인 → 쟈르스에게 보고 → 승인 후 진행
❌ 금지: 확인 없이 새 함수/테이블 생성

---

## Git 워크플로우
- 항상 feature 브랜치에서 작업
- 의미있는 커밋 메시지 (한국어 가능)
- `main` 브랜치 직접 push 금지 — PR 경유
- Vercel은 `main` 머지 시 자동 배포

---

## 📓 월별 작업 LOG 규칙 (모든 에이전트 필수)

작업 완료 후 **보드 done 처리 전에** 반드시 자신의 LOG 파일에 기록하라.

**LOG 파일 경로**: `pt-prescription/[내 에이전트명]/LOG-YYYY-MM.md`
(예: `pt-prescription/sw-db-architect/LOG-2026-04.md`)

**파일이 없으면 먼저 생성** (새 달 첫 작업인 경우):
```markdown
# [에이전트명] 월간 작업 로그 — YYYY-MM

> 작업할 때마다 append 방식으로 기록합니다. 삭제 금지.

---
```

**기록 형식** (파일 끝에 append):
```markdown
## YYYY-MM-DD | [TODO-ID] 작업명

- **지시 받은 내용**: 한 줄 요약
- **수행한 작업**: 구체적으로 무엇을 했는지
- **결과물**: 파일 경로 또는 "없음"
- **이슈/메모**: (있을 경우만)

---
```

---

## 📌 백로그 기록 규칙 (모든 에이전트 필수)

작업 중 아래 상황이 발생하면 **반드시** `.jarvis/BACKLOG.md` 파일에 기록:
- 지금 당장은 못 하지만 나중에 해야 할 수정 사항
- 발견한 개선 가능성 (코드·콘텐츠·프로세스)
- 의존성 때문에 나중으로 미룬 작업
- 대표님께 제안하고 싶은 아이디어

**기록 형식:**
```
## [YYYY-MM-DD] [에이전트명] — [한 줄 제목]

**우선순위**: high / medium / low
**담당팀**: [팀명]
**배경**: [왜 필요한지]
**할 일**: [구체적으로 무엇을]
**관련 파일**: [경로]
**예상 시기**: [언제쯤]
**상태**: 🔲 대기중
```

백로그 파일 경로: `C:/project/PT/KMovement Optimism/.jarvis/BACKLOG.md`
노션 동기화: 쟈르스가 주기적으로 Notion "Backlog & Future Plans" 페이지에 반영
