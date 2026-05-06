# PT 처방 도우미 서비스 경험 흐름 (Service Experience Flow)

**작성일**: 2026-05-06
**작성자**: sw-ux-researcher
**시점**: 베타 출시 D+1 (2026-05-05 출시) · Track C(평가 타이밍 재설계) 코드 통합 완료, production 활성화 직전
**기준 코드**: `index.html` (4,469 lines) · `api/recommend.js` · `api/feedback.js` · `api/pending-evaluations.js` · `api/history.js` · `saas/migrations/051-recommendation-evaluation.sql`

---

## 1. 페르소나 & 1세션 정의

| 항목 | 값 |
|---|---|
| 주 사용자 | 한국 초보 PT (1~5년 경력) |
| 일평균 환자 수 | 약 8명 (가정) |
| **1세션 정의** | **환자 1명 진료 단위** (입력 → 추천 → 시술 → 다음 환자 진입) |
| 베타 일일 한도 | 사용자 등급별 동적 (`tier_limits.daily_limit`, 기본 `beta=20`) — `api/recommend.js:941` |
| 등급 기본값 | `beta` 등급, 행 없으면 한도 20 (`api/recommend.js:52`) |
| 한도 리셋 | KST 자정 (`api/recommend.js:937`, 라벨 “내일 0시(KST) 리셋”, `index.html:3619`) |
| 베타 운영 | 4주 예정 (welcome 모달 안내 — `index.html:1874`) |

---

## 2. 핵심 흐름 — 1세션 다이어그램

```
                         ┌────────────────────────┐
                         │  로그인 / OAuth 콜백   │  screen0  (index.html:1912)
                         └───────────┬────────────┘
                                     │ checkAllowedAndEnter()
                                     │ (index.html:2485)
                                     ▼
                         ┌────────────────────────┐
                         │  is_allowed 판정       │
                         └────────┬───────┬───────┘
                          allowed │       │ pending
                                  ▼       ▼
                                  │   screenPending  (index.html:2006)
                                  │   "운영자 승인 후 이용"
                                  │
                                  ▼
        ┌─────────────────────────────────────────────────┐
        │  loadSavedSettingsAndNavigate()                  │  index.html:2516
        │  ┌─ Track C 가드 (PENDING_EVAL_MODAL_ENABLED) ─┐  │
        │  │  GET /api/pending-evaluations              │  │  곧 활성화
        │  │  pending.length > 0 → showPendingEvalModal │  │  (현재 코드만 통합)
        │  │  실패 → fail-open (검색 진입 허용)          │  │
        │  └─────────────────────────────────────────────┘  │
        │  ↓                                                │
        │  GET /api/settings (DB 동기화) → localStorage     │
        │  저장된 mt/ex 있으면 → goScreen2 (입력 화면)      │
        │  없으면 → goScreen('screen1') (설정 화면)         │
        └────────┬─────────────────────────────────┬───────┘
                 │ (저장 설정 있음)                │ (없음)
                 ▼                                 ▼
   ┌─────────────────────────────┐    ┌─────────────────────────┐
   │  Step 2 — 환자 입력         │    │  Step 1 — 사용 기법 설정 │
   │  screen2  (index.html:2059) │    │  screen1 (index.html:2024)│
   │  • 부위 6개                 │    │  MT 그룹 5개 (최대 3)    │
   │  • 시기 3개                 │    │  EX 그룹 3개 (최대 2)    │
   │  • 증상 패턴 3개            │    │  → 저장 후 goScreen2     │
   │  step-indicator 1·2·3       │    └─────────────────────────┘
   └────────────┬────────────────┘
                │ goScreenCat()
                ▼
   ┌──────────────────────────────────┐
   │  Step 2.5 — 3박자(Pillar) 선택   │  screenCat (index.html:2111)
   │  관절 가동 / 연부조직 / 운동       │
   │  다중 선택 + 클릭 순 우선순위      │
   │  고급: 카테고리 직접 지정 (옵션)   │
   └────────────┬─────────────────────┘
                │ submitRecommend()
                ▼
   ┌──────────────────────────────────┐
   │  Step 3 — 추천 받기 (screen3)    │  index.html:2160
   │  3단계 로딩 가시화                │
   │   1) 🔍 기법 검색 중              │  setRecLoading + 5s 후 step2
   │   2) 🤖 임상 메모 작성 중         │
   │   3) ✅ 완료                       │
   │  POST /api/recommend (LLM)        │
   │  hint: "보통 10~20초 소요"         │  index.html:2176
   └────────────┬─────────────────────┘
                │ renderAIResult
                ▼
   ┌────────────────────────────────────────────────┐
   │  Step 4 — 추천 결과 카드 + 인라인 평가          │
   │  • 카테고리별 카드 (manualTherapy / exercise)   │
   │  • relatedManualTherapy (연관 부위)            │
   │  • clinicalNote                                │
   │  • 사용량 배지 (오늘 N/20 사용)                 │
   │  • "🔄 다른 기법 보기" (카테고리별 새로고침)     │
   │  • 인라인 별점은 약화(display:none),            │
   │    outcome/accuracy/notes 즉시 노출            │
   └────────────┬───────────────────────────────────┘
                │ (앱 외부)
                ▼
   ┌──────────────────────────────────┐
   │  Step 5 — 시술 (앱 외부)         │
   │  PT가 환자에게 추천 기법 적용     │
   │  환자 퇴실                        │
   └────────────┬─────────────────────┘
                │ "다시 입력" 또는 다음 환자 진입
                ▼
   ┌────────────────────────────────────────────────┐
   │  Step 6 — 다음 환자 진입 (Track C, 곧 활성화)   │
   │  loadSavedSettingsAndNavigate 가드 재진입       │
   │  pending 있으면 pending-eval-overlay 강제 모달  │
   │  outcome 6 + accuracy 1~5 + 메모 + 스킵         │
   │  모든 카드 처리 완료 → 모달 닫힘 → 검색 허용    │
   └────────────────────────────────────────────────┘
```

---

## 3. 단계별 상세

### 3.1 온보딩

**첫 진입 — welcome-modal** (`index.html:1829`~1876)

베타 사용자가 처음 로그인하면 환영 모달이 노출됨. 4 step 구성:

| Step | 아이콘 | 제목 | 설명 |
|---|---|---|---|
| 1 | 📍 | 환자 조건 입력 | 부위 → 시기(급성·아급성·만성) → 증상(움직임·안정·방사통) |
| 2 | 🎯 | 3박자 선택 | 관절가동 · 연부조직 · 운동 중 원하는 만큼 (다중 선택 가능) |
| 3 | 🤖 | 추천 받기 (8~15초) | AI 가 임상 메모를 작성 중. 빈 화면이 잠시 보여도 정상 |
| 4 | ⭐ | 별점·효과 평가 | 한 줄 피드백이 다음 추천을 더 정확하게 만든다 |

CTA: **시작하기** (`dismissWelcomeModal`).
하단 안내: “일일 한도: 20회 · 베타 4주 운영 예정” + “문의·버그·아이디어는 헤더의 💬 피드백 으로 언제든지” (`index.html:1872~1875`).

> **확인 필요**: welcome-modal 노출/dismiss 트리거 (localStorage flag 등 시점 제어)는 본 조사 범위에서 직접 확인하지 못함. `dismissWelcomeModal` 본체 별도 확인 권장.

**OAuth / 인증** (`api/auth/`, `api/_auth.js`)

- `api/_auth.js:verifyToken` — Bearer JWT → Supabase `/auth/v1/user` 검증 → `{ user, error }` 반환. 모든 보호 엔드포인트(`recommend`, `feedback`, `history`, `pending-evaluations`, `settings`)에서 호출.
- `api/auth/callback.js` / `api/auth/providers.js` — OAuth 콜백 + 제공자 구성.
- 로그인 후 `checkAllowedAndEnter` (`index.html:2485`) — `user_profiles.is_allowed` 확인:
  - 행 없을 시 800ms 후 1회 재시도 (트리거 지연 고려).
  - `is_allowed=true` → `loadSavedSettingsAndNavigate()`.
  - `is_allowed=false` → `screenPending` (운영자 승인 대기 안내).

**일일 한도 (N/20)**

- 체크 위치: `api/recommend.js:935~957` — `getUserDailyLimit(userId, userToken)` 으로 사용자 등급(`user_tiers`) → `tier_limits.daily_limit` 조회 → `recommendation_logs` 의 KST 자정 이후 row 수 vs `DAILY_LIMIT` 비교 → 도달 시 `429` 반환 (`{ error, dailyLimit, usedToday }`).
- 클라이언트 표시: `updateUsageBadge(used, limit)` (`index.html:3610~3624`) — 80% 이상 `warn`, 100% 이상 `full` + “내일 0시(KST) 리셋” 노트.

---

### 3.2 Step 1 — 화면 진입 (`loadSavedSettingsAndNavigate`)

`index.html:2516~2583`. 순서:

1. **(곧 활성화) Track C pending-eval 가드** (`2517~2537`)
   - `PENDING_EVAL_MODAL_ENABLED && currentAccessToken` 일 때만 작동.
   - 활성화 방법: 콘솔에서 `localStorage.setItem('pt_feature_pending_eval','true')` (`index.html:2402`).
   - `GET /api/pending-evaluations` → `pending` 배열 반환 (14일 내 `evaluation_status='pending'` 추천 로그, 최대 20건, `api/pending-evaluations.js:81~87`).
   - `pending.length > 0` → `await showPendingEvalModal(pending); return;` (검색 차단 유지, 모달 닫혀도 흐름 종료).
   - 실패 시 `console.warn` + 통과 (fail-open — 백엔드 장애 시 UX 보호, `index.html:2519`).
2. **DB 설정 동기화** (`2540~2560`)
   - `GET /api/settings` → `mt_groups` / `ex_groups` / `categoryFrequency` → localStorage 캐시 갱신.
3. **로컬 설정 로드 + 검증** (`2562~2581`)
   - `pt_settings` 의 mt/ex id 가 현재 옵션 정의와 일치하는지 확인 (cleanup).
   - 선택 있으면 `goScreen2()` (입력 화면), 없으면 `goScreen('screen1')` (설정 화면).

---

### 3.3 Step 2 — 환자 정보 입력 (screen2)

`index.html:2059~2106`. 헤더에 **📋 이력** 버튼 (`openHistory()`, 라인 2065). step-indicator (1·2·3) 표시.

**입력 항목** (각 항목 `section-card collapsible` — 선택 시 자동 접힘 + 다음 카드로 진행):

| 항목 | 옵션 | 데이터 ID |
|---|---|---|
| 부위 | 경추 / 요추 / 어깨 관절 / 무릎 관절 / 엉덩 관절 / 발목 관절 | cervical, lumbar, shoulder, knee, hip, ankle_foot |
| 시기 | 급성 (<6주) / 아급성 (6주~3개월) / 만성 (>3개월) | acute, subacute, chronic |
| 증상 패턴 | 움직임 시 통증 / 안정 시 통증 / 방사통 | movement, rest, radicular |

(`MT_OPTIONS` `EX_OPTIONS` `REGIONS` `STAGES` `SYMPTOMS` 정의: `index.html:2202~2233`)

3개 모두 선택해야 **다음 →** 버튼 활성화 (`btn-recommend`, `goScreenCat()`).

---

### 3.4 Step 2.5 — Pillar 선택 (screenCat)

`index.html:2111~2155`. “이번 세션 어디에 집중하시겠어요?” — 3박자 다중 선택.

| Pillar | 라벨 | 아이콘 | 카테고리 매핑 (`PILLAR_META`, 2281~2303) |
|---|---|---|---|
| joint | 관절 가동 | 🔧 | category_joint_mobilization, category_mulligan, category_mdt |
| soft_tissue | 연부조직 | 💆 | mfr, art, ctm, deep_friction, trigger_point, anatomy_trains, scs |
| exercise | 운동 | 🏃 | resistance, bodyweight, neuromuscular, aerobic |

- 클릭 순서로 **우선순위(rank)** 결정 (`togglePillar`, `index.html:2308`).
- **고급**(접기) — 특정 카테고리 직접 선택 (선택사항, `cat-picker-area`).
- “이전”(`screen2`로) / “추천 받기 →”(`submitRecommend`).

---

### 3.5 Step 3 — 추천 받기 (screen3)

`index.html:2160~2194`, `submitRecommend` (`3116~3228`).

**3단계 로딩 가시화** (`index.html:2169~2177`, 로직 `setRecLoading`@`3628~3661`):

| Step | 라벨 | 동작 |
|---|---|---|
| 1 | 🔍 기법 검색 중... | 로딩 시작 시 active |
| 2 | 🤖 임상 메모 작성 중... | 5,000ms 후 step1→done, step2→active |
| 3 | ✅ 완료 | 응답 도착 시 step3→done |

힌트 텍스트: “(보통 10~20초 소요)” (`index.html:2176`).

**API 호출 분기** (`submitRecommend`):

- **Pillar 모드** (선택 1개 이상, `index.html:3138~3169`) — `POST /api/recommend` 1회 호출. body: `{ region, acuity, symptom, selectedCategories, focusPillars, excludedTechniqueIds, sessionHistory }`.
- **Legacy 카테고리 모드** (`3170~3216`) — 카테고리당 병렬 호출 → 병합.

**응답 처리**:

- 성공 → `renderAIResult(data)` + `updateUsageBadge(usedToday, dailyLimit)`.
- `429` → 한도 도달 토스트 + 배지 full.
- 기타 오류 → `showRecError()` + “다시 시도” 버튼 노출.

> **확인 필요**: P50 8.4s / P95 11.2s 수치는 본 조사 범위에서 코드/문서로 확인 못함. UI 힌트는 **“보통 10~20초”**. QA 타이밍 로그(`docs/qa/qa-timing-log-2026-05-04.md`) 별도 확인 권장.

---

### 3.6 Step 4 — 추천 결과 + 인라인 평가

**카드 렌더링** (`renderTechniqueCard`, `index.html:3300~`)

- 카드 구성 요소(JSON 필드, `renderAIResult`/`renderTechniqueCard` 기준):
  - `technique` — 기법명
  - `movement` — 동작/단계
  - `therapistHands` — 치료사 손 위치
  - `patientPosition` — 환자 자세
  - `patientFeedback` — 환자 반응 확인 cue
  - `clinicalNote` — 임상 메모 (별도 블록)
  - `dosage` — 강도/횟수
  - `applicableMuscles` / `targetMuscles` — 적용 근육
  - `steps` — (movement 내부)
- “자세히 보기 ▼” 토글 (`btn-expand-card`, `index.html:3471`) — 기본 접힘, 펼치면 환자 반응/movement/근육 섹션 노출.
- 카드 헤더 영역에 카테고리 정보 패널 (`showCategoryModal` → cat-modal, `index.html:1794~1801` + `3784~3797`) — 선택한 카테고리 클릭 시 `name_ko (name_en)` + “이 카테고리의 임상 핵심 원칙” + `basic_principles[]` 리스트.

**섹션 단위 새로고침**: 카테고리별 “🔄 다른 기법 보기” 버튼 (`refreshCategory`, `index.html:3557~3604`) — 같은 카테고리에서 노출된 `techniqueId` 를 `excludedTechniqueIds` 에 누적해 재호출. 카드 갈아끼움.

**인라인 별점 약화 (Track C 후)**

- `.inline-star-rating { display: none !important }` (`index.html:1501`) — 별점 5개는 DOM에 있지만 화면에 안 보임.
- `outcome` 6 라디오 / `accuracy` 1~5 / `notes` (200자) / “저장”·“건너뛰기” 버튼은 **카드 렌더링 시 즉시 노출** (`initFeedbackSection`, `index.html:4080~4189`).
- prompt: “이 추천이 도움됐다면 다음 환자 진입 시 평가해주세요 (지금 평가도 가능)” (`index.html:4097`).
- `outcome` / `accuracy` / `notes` 중 하나라도 입력돼야 저장 가능 (가드 `4147`).
- 즉시 평가 시 `POST /api/feedback` body 에 `recommendation_log_id` + `recommended_technique_index` 동봉 (`4170~4173`).
- 저장 성공 → 폼 hide + `inline-feedback-done` 메시지 노출.

**outcome 6값 (한국어 라벨, `index.html:4200~4207` / `index.html:3509~3514`)**:

| key | 한국어 |
|---|---|
| excellent | 매우 효과적 |
| good | 효과적 |
| moderate | 보통 |
| poor | 효과 미미 |
| no_effect | 효과 없음 |
| adverse | 부작용 |

> **이슈 발견 (확인 필요)**: 인라인 평가가 보내는 `rating: 0` (`index.html:4166`) 과 pending-eval 모달이 보내는 `rating: 0` (`index.html:4418`) 은 `api/feedback.js:43` 의 `if (!technique || !rating)` 가드에 걸려 **400 오류**가 날 가능성이 있음. 같은 파일 라인 46 도 `rating < 1 || rating > 5` 검증으로 이중 거부. 베타 활성화 전 `api/feedback.js` 측 가드 완화(`rating === 0` 허용 또는 0 → null 변환) 또는 클라이언트가 별도 엔드포인트로 보내도록 변경 필요. 본 작업 범위 외 — 백엔드 PR 권장.

---

### 3.7 Step 5 — 시술 (앱 외부)

PT가 추천 결과를 보고 환자에게 직접 적용. 앱은 시술 중 사용되지 않음 (양손 자유). 시술 종료 후 환자 퇴실. 평가는 “지금” 인라인으로 가능하지만, **다음 환자 진입 시점이 메인 평가 경로**가 됨 (Track C 활성화 후).

---

### 3.8 Step 6 — 다음 환자 진입 (Track C — 곧 활성화)

**상태**: 코드 통합 완료(2026-05-06). production 활성화는 `pt_feature_pending_eval` flag 명시적 설정 필요.

**모달 트리거** (`loadSavedSettingsAndNavigate` 가드 재진입, `index.html:2517~2537`)

```
다음 환자 진입 (검색 화면 호출)
         │
         ▼
GET /api/pending-evaluations
  ↓ (14일 내 pending recommendation_logs, 최대 20건)
pending.length > 0  →  showPendingEvalModal(pending)
                        ↓ (Promise, 모달 닫힐 때까지 대기)
                        return;  ← 검색 진입 차단
pending.length == 0 →  정상 진입 (settings 동기화 → goScreen2)
fail (네트워크 등) →  fail-open (검색 진입 허용 + console.warn)
```

**모달 구조** (`index.html:1884~1894`, 동적 렌더링 `4234~4467`)

- 헤더 (sticky):
  - 타이틀: “직전 환자 시술 평가”
  - 서브: “환자 정보 보호를 위해 평가 후에 다음 환자로 진행할 수 있어요.”
- 닫기 버튼 **없음** (필수 모달).
- 카드 N개 (pending log 1개 = 카드 1개), 각 카드 안에 기법 N개 블록 (`renderPendingCard`).
  - 카드 메타: region · acuity · symptom 칩 + “추천: NN분 전 / N시간 전 / N일 전” (`_formatPendingWhen`).
  - 기법 블록당 폼: outcome 6 라디오 / accuracy 1~5 / 메모 / [이거 시술 안 했어요] [저장] 버튼.
  - 저장(`submitPendingEval`, 라인 4405) → `POST /api/feedback` (recommendation_log_id + technique_index 동봉) → 블록 `.rated` 클래스 → DB 트리거가 `recommendation_logs.evaluation_status = 'rated'` 자동 갱신 (마이그 051, 라인 113~135).
  - 스킵(`markPendingSkipped`, 라인 4440) → **DB 호출 없음, 클라이언트 로컬 처리만** → 블록 `.skipped` 클래스.
- 모든 카드의 모든 기법이 `rated` 또는 `skipped` 상태가 되면 `closePendingEvalIfDone()` (`4449`) → overlay 닫고 resolver 실행.
- 평가 가드: outcome / accuracy 둘 다 미선택이면 “효과 분류 또는 적합도를 선택해주세요.” 토스트 (`index.html:4372`).

**DB 측 동작 (마이그 051)**

- `recommendation_logs.evaluation_status` ENUM: `pending` / `rated` / `expired` / `skipped` (`051:36~44`).
- `ratings` 에 `recommendation_log_id` (FK, ON DELETE SET NULL) + `recommended_technique_index` (1-based SMALLINT) 추가 (`051:68~76`).
- 트리거 `trg_update_evaluation_on_rating` (AFTER INSERT, `051:138~142`) — `recommendation_log_id` 매칭된 INSERT 만 처리, `pending → rated` 만 전환 (멱등).
- 14일 만료 함수 `expire_old_pending_evaluations()` (`051:148~165`) — 14일 이상 된 pending → expired 일괄 전환. **호출 책임은 클라이언트 진입 시점/cron** — 마이그 자체는 함수 정의만.
- 베타 출시 전 historical row (`created_at < '2026-05-06'`) → 일괄 `expired` (`051:181~184`).

---

## 4. 부가 기능 흐름

### 4.1 이력 탭 (`openHistory`, `index.html:3896`)

- 트리거: screen2 헤더의 **📋 이력** 버튼 (`index.html:2065`).
- `GET /api/history` → `{ recentLogs, likedTechniques }`.
- 탭 1 — **최근 추천 이력** (recentLogs[], 최대 20건, `api/history.js:103~109`)
  - 카드: region/acuity/symptom 칩 + 기법명 리스트 + 날짜·시각.
  - `term_glossary` 후처리 적용 (한자/외래어 → 한글, `api/history.js:19~81`, 마이그 052·053).
- 탭 2 — **좋아요 (별 3개 이상 평가 기법)** (likedTechniques[], 최대 30건, `api/history.js:111~118`)
  - 카드: ★N + 기법명 + 카테고리 + 날짜.
  - 빈 상태: “별 3개 이상 평가한 기법이 없습니다.”

> **이슈 (확인 필요)**: 좋아요 탭은 `star_rating >= 3` 기준 (`api/history.js:114`). 그러나 인라인/모달 평가가 모두 `rating: 0` 으로 통일되면서, **베타 신규 평가는 좋아요 탭에 절대 노출되지 않음**. 좋아요 탭의 의미가 사라지므로 (a) 좋아요 기준을 `outcome IN ('excellent','good')` 로 재정의하거나 (b) 탭 자체 deprecate 결정 필요. PM 검토 권장.

### 4.2 카테고리 모달 (cat-modal)

- 트리거: 추천 결과 카드의 카테고리 정보 버튼 (`showCategoryModal`, `index.html:3784~3797`).
- 콘텐츠: `name_ko (name_en)` 타이틀 + “이 카테고리의 임상 핵심 원칙” 서브 + `basic_principles[]` 카드(아이콘 + 타이틀 + 설명).
- z-index: 1000 (welcome 1100 < pending-eval 1050 < 별도 영역).

### 4.3 토스트 (showToast)

- DOM: `<div class="toast" id="appToast">` (`index.html:1825`).
- API: `showToast(msg)` (`index.html:3995~4000`) — `.show` 클래스 부여 후 2,800ms 후 제거.
- 사용처: 한도 도달, 평가 저장 실패, 카테고리 새로고침 실패, 비밀번호 변경 성공, 인라인/모달 평가 가드, 피드백 전송 결과 등.

### 4.4 일일 한도 도달 시 동작

- 추천 시도 → `429` → `showToast(err.message || '오늘의 추천 한도에 도달했습니다. 내일 다시 이용해주세요.')` (`index.html:3222`).
- 카테고리 새로고침도 `429` 처리 동일 (`index.html:3600~3603`).
- 사용량 배지 → `full` 상태 + “내일 0시(KST) 리셋” 노트.
- 추천 외 다른 기능(이력, 평가, 설정)은 한도와 무관하게 사용 가능.

---

## 5. 종료 / 예외 시점

| 케이스 | 동작 |
|---|---|
| 마지막 환자 (당일 평가 후 다음날 첫 진입) | Track C 활성화 시 다음날 첫 진입 = `loadSavedSettingsAndNavigate` 가드 재실행 → 14일 내 pending 있으면 모달 노출 (24시간 경과는 14일 만료 미발동) |
| 휴진 / 외래 종료 | 14일 만료 안전망 — `expire_old_pending_evaluations()` 호출 시 14일 경과 pending → expired 일괄 전환 (호출 책임 미정) |
| 인증 만료 | `verifyToken` → 401 → 클라이언트가 `goScreen('screen0')` 로 복귀 (`index.html:2466, 2477, 2713`) |
| 추천 실패 (LLM 5xx 등) | `setRecLoading(false)` + `showRecError()` + “다시 시도” 버튼 (`index.html:3217~3227`, 3663~3667) |
| pending API 실패 | `console.warn` + fail-open (검색 진입 허용, `index.html:2534~2536`) |
| 14일 경과 평가 | 자동 제외 (조회 SQL: `created_at >= NOW() - 14d`, `api/pending-evaluations.js:81~87`). 만료 함수 호출 시 status 도 `expired` 로 정리 |
| 스킵 (모달) | DB 호출 없음, 로컬 state 만 `skipped` (`index.html:4440~4447`). DB 측 status 는 변하지 않음 — 다음 진입 시 다시 노출 가능 (다만 14일 경과 시 자동 제외) |

> **확인 필요**: 모달 스킵 후 같은 추천이 반복 노출되는 동작이 의도인지 PM 결정 필요. 의도라면 사용자에게 “스킵 시 다음에 다시 묻습니다” 안내 추가, 의도 아니라면 클라이언트가 `recommendation_logs.evaluation_status='skipped'` UPDATE 추가 필요(051 마이그의 RLS 정책 이미 허용).

---

## 6. UX 핵심 결정 (이력)

| 결정 | 일자 | 출처 / 근거 |
|---|---|---|
| 인라인 별점 약화 + 다음 세션 모달 | 2026-05-05 (대표님) | `index.html:1498~1501` 주석 + LOG-2026-05.md 최신 entry |
| 14일 만료 안전망 | 마이그 051 | `expire_old_pending_evaluations()`, mig 051:148~168 |
| 다음 환자 진입 시 검색 차단 (필수 모달) | Track C | `loadSavedSettingsAndNavigate` 가드 + 모달 닫기 버튼 부재 (`index.html:1884`, 2517~2537) |
| 스킵은 DB 호출 없음 (로컬) | Track C | `markPendingSkipped` 주석 (`index.html:4441`) |
| outcome 6값 + accuracy 1~5 (별점 대체) | Track C | mig 049 ratings_effect_columns + `index.html:3506~3528` |
| KMO 철학 — 두려움 유발 표현 금지, 근거 기반만 | 프로젝트 | `CLAUDE.md:142~144` |
| 모달 “환자 정보 보호를 위해 평가 후에…” 카피 | Track C | `index.html:1888` (의료 정보 보호 프레이밍 — 비파국화) |

---

## 7. 미해결 / Backlog (관찰된 이슈)

> 본 문서 작성 중 발견. `BACKLOG.md` 등록 추천 항목.

| 우선순위 | 항목 | 설명 |
|---|---|---|
| 🔴 high | `rating: 0` vs feedback.js 가드 모순 | `api/feedback.js:43,46` 가 `rating>=1` 강제 → 모든 신규 평가가 400 가능. Track C activation 전 차단 필요 |
| 🔴 high | 좋아요 탭 무력화 | `star_rating>=3` 기준이 의미 없어짐. 기준 재정의 또는 탭 deprecate |
| 🟡 medium | 모달 스킵 반복 노출 동작 정의 | DB 호출 없는 로컬 스킵 → 다음 진입 재노출. 의도 명시 필요 |
| 🟡 medium | `expire_old_pending_evaluations()` 호출 책임 | 마이그은 함수만 정의. 클라이언트 진입 시 / cron 결정 미정 (mig 051:147 주석) |
| 🟡 medium | 일일 한도 N/20 사전 표시 UI | 현재는 추천 후 응답으로만 노출. screen2/screenCat 진입 시 사전 배지 노출 검토 |
| 🟢 low | "다른 기법 보기" 클릭 트래킹 | 사용자 탐색 패턴 분석 — 카테고리별 새로고침 빈도 미수집 |
| 🟢 low | welcome-modal dismiss 영속화 검증 | 본 조사에서 트리거/dismiss 영속화 흐름 미확인 |
| 🟢 low | Track D | 추천 알고리즘 조정 (대기 — 별도 트랙) |
| 🟢 low | Zuggriff·Grundaufbau 한국어 매핑 | term_glossary 보완 (마이그 053 supplement 후속) |

---

## 8. Track 4 분리 컨텍스트 (참고)

| Track | 상태 (2026-05-06 기준) |
|---|---|
| Track A | D-Day 핫픽스 — **완료** |
| Track B Phase 3 | 용어 표준화 마무리 (마이그 052·053, term_glossary) — **완료** |
| Track C | 평가 타이밍 재설계 — **코드 통합 완료, production 활성화 대기** (`localStorage.setItem('pt_feature_pending_eval','true')` 필요) |
| Track D | 추천 알고리즘 조정 — **대기** |

---

## 9. 관련 파일 참조

**프론트엔드**

- `index.html`
  - 1216~1380 : welcome-modal CSS
  - 1386 / 1501 : inline-star-rating CSS (약화)
  - 1503~1701 : pending-eval-overlay/modal CSS
  - 1794~1822 : cat-modal-overlay 마크업
  - 1825 : toast DOM
  - 1829~1876 : welcome-modal 마크업 (4 step)
  - 1884~1894 : pending-eval-overlay 마크업
  - 1912 : screen0 (로그인)
  - 1988 / 2006 : screenPwd / screenPending
  - 2024 / 2059 / 2111 / 2160 : screen1/2/screenCat/screen3
  - 2169~2177 : 3단계 로딩 가시화 마크업
  - 2202~2303 : MT/EX/REGION/STAGE/SYMPTOM/CAT/PILLAR 메타 정의
  - 2402~2405 : `PENDING_EVAL_MODAL_ENABLED` feature flag
  - 2485~2514 : `checkAllowedAndEnter` (인증 후 라우팅)
  - 2516~2583 : `loadSavedSettingsAndNavigate` (Track C 가드 포함)
  - 3116~3228 : `submitRecommend` (Pillar/Legacy 분기)
  - 3300~3555 : `renderTechniqueCard` (인라인 평가 섹션 포함)
  - 3557~3604 : `refreshCategory` (다른 기법 보기)
  - 3610~3624 : `updateUsageBadge`
  - 3626~3661 : `setRecLoading` (3단계 로딩 가시화 로직)
  - 3784~3803 : `showCategoryModal` / `closeCategoryModal`
  - 3896~3993 : `openHistory` / `renderHistTab` / `switchHistTab`
  - 3995~4000 : `showToast`
  - 4080~4189 : `initFeedbackSection` (인라인 평가, Track C 적용)
  - 4197~4467 : pending-eval modal 함수 5종 + 헬퍼

**백엔드**

- `api/_auth.js` — `verifyToken` (Bearer JWT 검증)
- `api/recommend.js`
  - 24~58 : `getUserDailyLimit` (등급 기반 한도 캐시)
  - 935~957 : 일일 한도 체크 + 429
  - 도수치료 추천 LLM 파이프라인 (~1521 라인)
- `api/feedback.js` — ratings INSERT (recommendation_log_id + technique_index 동봉)
- `api/pending-evaluations.js` — 14일 내 pending logs 조회 (term_glossary 후처리)
- `api/history.js` — recentLogs + likedTechniques (term_glossary 후처리)
- `api/settings.js` — DB 기반 mt/ex/카테고리 빈도 동기화

**DB / 마이그**

- `saas/migrations/051-recommendation-evaluation.sql` — Track C DB 인프라 (ENUM, 컬럼, 인덱스, RLS, 트리거, 만료 함수, historical 정리)
- `saas/migrations/041-ratings-table.sql` — ratings 테이블 베이스
- `saas/migrations/049-ratings-effect-columns.sql` — outcome / indication_accuracy 컬럼
- `saas/migrations/052-term-glossary.sql` / `053-term-glossary-supplement.sql` — 한자/외래어 한글 매핑
- `saas/migrations/046-user-tiers-and-limits.sql` / `047-move-tier-to-user-profiles.sql` — 등급 기반 일일 한도

**문서 / 사양**

- `docs/specs/PRODUCT_SPEC.md` — 제품 사양
- `docs/specs/MVP-BETA-CHECKLIST.md` — 베타 체크리스트
- `docs/onboarding/beta-onboarding-DM-form.md` — 베타 온보딩 DM 폼
- `docs/qa/qa-timing-log-2026-05-04.md` — QA 타이밍 로그 (P50/P95 수치 확인 시 우선)
- `docs/qa/D-DAY-2026-05-05-MONITORING-LOG.md` — D-Day 모니터링 로그
- `docs/clinical-terminology-audit-2026-05-05.md` — 임상 용어 감사

---

## 10. 부록 — 활성화 절차 (Track C)

베타 콘솔에서 다음 순서로 검증:

1. 로그인 → 추천 1회 실행 → 평가 없이 화면 닫기 (recommendation_logs.evaluation_status = 'pending').
2. DevTools 콘솔에서 `localStorage.setItem('pt_feature_pending_eval','true')` 실행.
3. 새로고침 → 다음 환자 진입 시점(=`loadSavedSettingsAndNavigate` 호출) → pending-eval 모달 노출.
4. 한 카드 평가 → DB 측 `evaluation_status='rated'` 확인 (트리거 동작).
5. 모든 카드 처리 → 모달 자동 닫힘 → screen2 진입.

활성화 해제: `localStorage.removeItem('pt_feature_pending_eval')` + 새로고침 → 가드 비활성화 → 기존 흐름 100% 유지.

---

**문서 끝**.
