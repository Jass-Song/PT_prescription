# term_glossary — 설계 문서

- **마이그레이션**: `saas/migrations/052-term-glossary.sql`
- **검증 스크립트**: `saas/scripts/verify-term-glossary.sql`
- **단일 진실 소스**: `pt-prescription/docs/clinical-terminology-audit-2026-05-05.md` §6
- **작성**: sw-db-architect, 2026-05-05

---

## 1. 목적과 범위

한국어 PT 임상 용어 표준화의 **단일 진실 소스(single source of truth)** 를 제공한다. 다음 세 갈래의 사용처를 통합한다.

1. **클라이언트 후처리** — `index.html` 의 `TERM_REPLACEMENTS` 하드코딩 24건 (현행) → DB 룩업으로 대체.
2. **서버 LLM 후처리** — Claude/GPT 응답 본문의 한자/외래어를 표준 한글로 자동 치환.
3. **임상 가이드 콘텐츠** — 미래의 환자용 설명자료, 어드민 글쓰기 가이드.

범위 외:
- 영어 → 한국어 단방향 번역 사전이 아님. 본 테이블은 *원어(한자/외래어/옛 표기) → 한글 표준* 매핑.
- audit §6-6 보류 항목 (Zuggriff/Grundaufbau, glide/barrier/Mobilization 외래어 정착 결정) — 별도 결정 후 추가.
- 기법 약어(CTM/MFR 등)는 보존 정책으로 등록되며 치환 대상이 아님.

---

## 2. 컬럼 의미

| 컬럼 | 의미 |
|---|---|
| `id` | UUID 기본키 |
| `original_ko` | 원어 (한자/외래어/옛 표기). 본문 매칭 키. |
| `replacement_ko` | 한글 표준 풀이. `NULL` 이면 보존 (치환 제외). |
| `english` | 영문 표기 (괄호 표기 `한글(English)` 등 UI 노출용). |
| `category` | `posture / movement / examination / anatomy / depth / foreign / expression / preserved` |
| `body_region` | 동음이의어 부위 구분 (예: `forearm` / `ankle`). `NULL` = 글로벌 단일 매핑. |
| `disambiguation_pattern` | 정규식. `original_ko` 가 본문에서 이 패턴과 매칭되면 치환을 건너뜀. |
| `is_preserved` | 보존 플래그. `true` 이면 약어/정착어 → 치환 제외. |
| `status` | `active / review / deprecated`. 운영 중 검수 상태. |
| `frequency` | audit 시점 등장 횟수 (참고용 메트릭). |
| `evidence_url` | KPTA, 논문 등 표준 근거 (선택). |
| `notes` | 자유 메모 (예: §6 결정 메모). |
| `created_at / updated_at` | 자동 관리. `updated_at` 은 트리거 `trg_term_glossary_updated_at` 로 갱신. |

**유니크 제약**: `(original_ko, body_region)` — 같은 원어를 부위별로 다른 풀이로 등록할 수 있도록 (회내/회외 등).

---

## 3. 동음이의어 처리 규칙 (audit §6-5 인용)

> - **신장**: 기본은 "늘리기(Stretching)" 매핑. 단 정규식 `신장\s*\(콩팥\)` 또는 `신장\s*통증` 패턴은 치환 제외 (콩팥 의미)
> - **활주**: "미끄러짐(Gliding)" 매핑. 단 "혈관 활주" 등 비-PT 맥락은 추후 검토
> - **압박**: "압박(Compression)" 매핑. "압박골절" 등 병태 표현은 보존
> - **이완**: "풀림(relaxation)" 기본. 단 "이완대기·이완 효과" 같은 시술 흐름 표현은 자연스러운 한국어 유지

마이그 052 시드의 등록 패턴:

| original_ko | disambiguation_pattern (정규식) | 동작 |
|---|---|---|
| 신장 | `신장\s*\(콩팥\)\|신장\s*통증` | 본문이 매칭되면 치환 건너뜀 |
| 활주 | `혈관\s*활주` | 비-PT 맥락 |
| 압박 | `압박\s*골절` | 병태 표현 |
| 이완 | `이완\s*대기\|이완\s*효과` | 시술 흐름 표현 |

**부위별 분기** (회내/회외):
- `body_region = 'forearm'` → 회내 = "엎침", 회외 = "뒤침"
- `body_region = 'ankle'`   → 회내 = "안쪽 돌리기", 회외 = "바깥 돌리기"

서버/클라이언트 후처리는 본문 컨텍스트(상위 명사/관절명 — 어깨/무릎/발목/팔)를 보고 `body_region` 을 결정하여 룩업해야 함.

---

## 4. 보존 정책 (audit §6-7 인용)

> - **기법 약어 14종** (CTM/MFR/SNAG/NAG/Mulligan/Maitland/Cyriax/ART/MDT/IASTM/TrP/SCS/DTFM/DFM): `term_glossary.is_preserved=true`
> - **표준 영어 약어 8종** (ROM/SLR/ASIS/PSIS/MRI/CT/VAS/NRS/TMJ): 동일

마이그 052에서 `category='preserved'`, `is_preserved=true`, `replacement_ko=NULL` 로 22 row 등록.
- 슬래시 묶음 표기(`ASIS / PSIS`, `MRI / CT`, `VAS / NRS`)는 매칭/관리 편의를 위해 **각 약어를 개별 row 로 분리** — 결과 22 row.

후처리 로직 권장:
```
if term in glossary AND glossary[term].is_preserved == true:
    skip()  # 본문에서 그대로 유지
```

---

## 5. RLS 모델

| 동작 | 권한 |
|---|---|
| `SELECT` | 모두 허용 (`USING (true)`) — 글로벌 표준이므로 인증 불요 |
| `INSERT / UPDATE / DELETE` | 정책 미설정 — RLS 우회 권한(`service_role`)만 가능 |

→ 어드민 워크플로 (마이그 / 어드민 API / 직접 DB 접근) 만 변경 가능. 일반 사용자는 읽기 전용.

---

## 6. 캐시 권장 (백엔드 인계 메모)

본 테이블은 **거의 변경되지 않는 정적 마스터 데이터** (월 단위 변경 추정). 매 요청마다 DB 룩업은 비효율.

권장 패턴:
- **서버 메모리 캐시** (Vercel serverless의 모듈 스코프 변수 또는 Edge Runtime KV)
- **TTL 1시간** — 짧은 운영 변경(어드민 patch) 반영
- **수동 무효화 엔드포인트**: `POST /api/admin/term-glossary/invalidate-cache` (서비스롤 토큰 보호)
- **로딩 형태**:
  ```js
  // 서버 측 1회 로드 후 in-memory Map 으로 변환
  // key = `${original_ko}::${body_region ?? '*'}`
  const map = await loadGlossary(); // 1 row -> 1 entry
  // 룩업: map.get(`${term}::${region}`) ?? map.get(`${term}::*`)
  ```

후처리 함수 시그니처 예시 (sw-backend-dev 인계용):
```ts
applyGlossary(text: string, opts: { bodyRegion?: 'forearm' | 'ankle' | ... }): string
// 1) is_preserved=true 약어는 보호 토큰 치환 후 복원
// 2) disambiguation_pattern 매칭 구간은 보호
# 3) original_ko 발견 시 replacement_ko 로 치환, 필요 시 (english) 병기
```

---

## 7. 어드민 워크플로 후보 (sw-frontend-dev 인계 메모)

미래 어드민 페이지에서 다음 기능 제공 권장:
- 카테고리별 필터 + 검색 (`original_ko`, `english`)
- 신규 row 추가 (status='review' 로 등록 → sw-clinical-translator 검수 후 active 승격)
- `disambiguation_pattern` 정규식 검증 (라이브 테스트 — 샘플 본문 입력 → 매칭 시각화)
- `is_preserved` 토글
- audit 로그 (변경 이력은 향후 `term_glossary_history` 별도 테이블로 확장 권장)
- CSV import/export — KPTA 표준 갱신 시 일괄 반영

---

## 8. 테스트 시나리오 (QA 인계 메모)

| 케이스 | 입력 | 기대 출력 |
|---|---|---|
| 기본 매핑 | "전완 회내 시" + region=forearm | "전완 엎침 시" |
| 부위 분기 | "발 회내 시" + region=ankle | "발 안쪽 돌리기 시" |
| disambiguation | "신장(콩팥) 통증" | 변경 없음 (치환 제외) |
| 보존 약어 | "CTM 적용" | "CTM 적용" (변경 없음) |
| 동의어 통일 | "동결견 의심" | "오십견 의심" |
| 한자 → 한글 | "비복근 단축" | "장딴지근 단축" |

검증 스크립트(`saas/scripts/verify-term-glossary.sql`) 의 §6, §7, §8 SELECT 결과로 시드 무결성 확인 가능.

---

## 9. 향후 확장 (out-of-scope for 052)

- §6-6 보류 (Zuggriff, Grundaufbau, glide, barrier, Mobilization) — 별도 마이그 053+ 에서 결정 반영
- audit §2-A 자세 본문(앙와위 73회 등) — preemptive(§6-4)만 052 시드 포함. 본문 자세는 별도 결정 후 추가.
- audit §2-C / §2-D / §2-E 본문 row — 결정 단계 진입 시 추가 (현재는 §6 결정 사항만 시드).
- term_glossary_history (변경 이력)
- evidence_url 자동 백필 (KPTA 표준 매핑)

---

## 10. 변경 이력

| 일자 | 변경 | 작업자 |
|---|---|---|
| 2026-05-05 | 초안 작성 + 마이그 052 동시 배포 | sw-db-architect |
