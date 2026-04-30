# sw-db-architect — 작업 체크리스트

> **사용 규칙**
> - 작업 시작 시 `## 🔄 진행 중` 섹션 아래에 새 작업 항목 추가
> - 완료 항목은 `- [ ]` → `- [x]` 체크
> - **매주 월요일**: `- [x]` 완료 항목들을 `## 📦 주간 아카이브` 표에 1줄 요약 후 진행 중 섹션에서 삭제
> - 완료 여부 확인 요청 시 → 이 파일 먼저 확인 후 답변

---

## 🔄 진행 중 / 미완료 작업

<!-- 여기에 날짜순으로 현재 작업 항목 추가 -->

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
