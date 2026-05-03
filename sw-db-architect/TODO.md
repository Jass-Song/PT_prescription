# sw-db-architect — 작업 체크리스트

> **사용 규칙**
> - 작업 시작 시 `## 🔄 진행 중` 섹션 아래에 새 작업 항목 추가
> - 완료 항목은 `- [ ]` → `- [x]` 체크
> - **매주 월요일**: `- [x]` 완료 항목들을 `## 📦 주간 아카이브` 표에 1줄 요약 후 진행 중 섹션에서 삭제
> - 완료 여부 확인 요청 시 → 이 파일 먼저 확인 후 답변

---

## 🔄 진행 중 / 미완료 작업

### 📅 2026-05-03 D-2 sprint
- [x] Migration 049 — ratings 효과 평가 컬럼 (outcome ENUM / indication_accuracy / was_ai_recommended) — PR #31 머지 + Supabase 적용 완료
- [x] Migration 050 — technique_stats 보강 + fn_refresh_technique_stats + trg_refresh_stats_on_rating + 백필 — PR #31 머지 + Supabase 적용 완료
- [x] Migration 050b — fn_refresh_technique_stats SECURITY DEFINER + outcome 비율 분모 보정 — PR #34 hotfix 머지 + Supabase 적용 완료
- [x] Migration 049c — ratings 누락 컬럼 6개 (region/acuity/symptom/category_key/technique_label/notes) — PR #37 hotfix 머지 + Supabase 적용 완료 (production 별점 502 에러 해결)
- [x] verify-recommendation-weight-trigger.sql — BEGIN…ROLLBACK 검증 + post-rating-quick-verify.sql 한 방 검증 — 7 PASS + 1 cosmetic
- [x] ANALYTICS-QUERIES.md — Notion "Outcome measure" 5 카테고리 매핑 SQL 모음

### 🟡 출시 후 진행
- [ ] 가시위근/극상근 동의어 중복 제거 (데이터 정규화 마이그)
- [ ] technique_id NOT NULL 제약 검토 — Anatomy Trains 등 NULL 케이스 발생 시 049d ALTER COLUMN DROP NOT NULL
- [ ] 부위 통계 "??" 9건 (13%) — region 누락 데이터 추적
- [ ] Migration 051 (NEXT-1 focus_pillars 로깅) — sw-backend-dev 협업
- [ ] Migration 052 (NEXT-2 client_events 테이블) — telemetry 인프라

---

## ✅ 2026-04-28 완료 작업

- [x] Migration 019-fix-placeholder-steps.sql — MDT/SCS/CTM-AB placeholder technique_steps 11개 수정
- [x] Migration 021-fix-art-steps.sql — ART 11개 기법 technique_steps 5단계 작성
- [x] Migration 022-fix-ctm-dtfm-steps.sql — CTM/DTFM 기법 technique_steps + SQL single quote 오류 수정
- [x] Migration 023-fix-tp-steps.sql — TP 11개 기법 technique_steps 5단계 작성
- [x] Migration 024-fix-at-scs-steps.sql — AT 7개 + SCS 2개 technique_steps 5단계 작성
- [x] Migration 025-pgvector-setup.sql — pgvector extension 설치 + technique_embeddings 테이블 + match_techniques() 함수 + IVFFlat 인덱스
- [x] Migration 025b-fix-vector-dimension.sql — voyage-3-lite 512차원으로 벡터 컬럼/함수/인덱스 수정
- [x] Shoulder/Knee/Hip/Ankle 신규 마이그레이션 파일 4개 품질 검토 (019~022 DB팀 제작)
- [x] SQL single quote 오류 수정 (019: 4곳, 020: 2곳) + 오류 없는 파일 확인 (021, 022)
- [x] TECHNIQUE-INSERT-STANDARD.md 신규 생성 — DB팀 SQL 작성 표준 문서화
- [x] [2026-04-28] Migration 026-cervical-neural-techniques.sql — 경추 d_neural 기법 2개(슬라이더/텐셔너) 추가 및 Supabase 실행 완료

---

## 📦 주간 아카이브

> 완료된 주차는 이 표에 1줄 요약. 상세 내용은 MEMORY.md 참조.

| 주차 | 작업명 | 에피소드 | 완료일 | 결과물 |
|------|--------|---------|--------|--------|
