# sw-backend-dev — 작업 체크리스트

> **사용 규칙**
> - 작업 시작 시 `## 🔄 진행 중` 섹션 아래에 새 작업 항목 추가
> - 완료 항목은 `- [ ]` → `- [x]` 체크
> - **매주 월요일**: `- [x]` 완료 항목들을 `## 📦 주간 아카이브` 표에 1줄 요약 후 진행 중 섹션에서 삭제
> - 완료 여부 확인 요청 시 → 이 파일 먼저 확인 후 답변

---

## 🔄 진행 중 / 미완료 작업

- [x] [2026-04-28] Vercel Dashboard → VOYAGE_API_KEY 환경변수 등록 (대표님 수동 등록 완료, 2026-05-01 확인)
- [x] [2026-04-28] embed-techniques.js 실행 완료 — technique_embeddings 180개 적재 완료
- [x] [2026-04-28] recommend.js d_neural 503 버그 픽스 — fetchActiveTechniques null/[] 반환 분리
- [x] [2026-05-01] 9개 컨디션 시나리오 하이브리드 추천 결과 검증 — 9/9 통과 (정확일치 2 + 통과 4 + 부분통과 3). SCENARIO-VERIFICATION.md 매트릭스 갱신.
- [x] [2026-05-01] 카테고리 다양성 강제 로직 추가 — recommend.js:598~630 maxPerCategory 파라미터 구현 확인, "카테고리당 최대 1" 다양성 강제 동작 확인 (2026-05-02)

---

## ✅ 2026-04-28 완료 작업

- [x] saas/scripts/embed-techniques.js 생성 — Voyage AI voyage-3-lite 임베딩 생성 스크립트 (BATCH_SIZE=3, 21초 대기)
- [x] api/recommend.js — getQueryEmbedding() 함수 추가 (Voyage AI API 호출)
- [x] api/recommend.js — fetchVectorSimilarities() 함수 추가 (match_techniques RPC 호출)
- [x] api/recommend.js — 하이브리드 점수 산정 구현 (룰 60% + 벡터 40%)
- [x] pt-prescription/.env 파일 생성 (VOYAGE_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
- [x] pt-prescription/.gitignore에 .env 추가

---

## 📦 주간 아카이브

> 완료된 주차는 이 표에 1줄 요약. 상세 내용은 MEMORY.md 참조.

| 주차 | 작업명 | 에피소드 | 완료일 | 결과물 |
|------|--------|---------|--------|--------|
