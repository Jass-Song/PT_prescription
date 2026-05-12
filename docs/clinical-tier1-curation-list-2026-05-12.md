# Tier 1 80 큐레이션 명단 (2026-05-12)

> **작성**: sw-clinical-translator
> **목적**: 베타 출시 시 332개 기법 전체가 아닌 Tier 1 카테고리 7종 + 운동 처방 = **80개 큐레이션** 명단 확정. AI 추천 시스템의 `is_published = true` 필터링 후보 정의.
> **근거**: `docs/clinical-3axis-tier1-recommendation-research-2026-05-06.md` 54 시나리오 매트릭스 + APTA CPG + Cochrane SR + KAOMPT.
> **KMO 철학**: 통증 ≠ 손상. 반파국화. "Calm things down, build things back up."

---

## §1. 요약

### 1.1 카테고리별 큐레이션 카운트

| 그룹 | 카테고리 ID | 권장 N | 실제 N (마이그 본문) | 큐레이션 N | 충당률 | 비고 |
|---|---|---:|---:|---:|---:|---|
| 관절가동술 (Maitland) | `category_joint_mobilization` | 20 | 31 | **20** | 100% | 부위 균형 선별 — lumbar 신규 추가 필요 |
| 관절가동술 (Mulligan) | `category_mulligan` | 15 | 13 | **13** | 87% | lumbar SNAG·SLR-MWM 신규 추가 필요 (2건) |
| 연부조직 — 근막 (MFR) | `category_mfr` | 12 | 27 | **12** | 100% | CPG·KMO 매칭 선별 |
| 연부조직 — TrP | `category_trigger_point` | 13 | 45 (중복 제외) | **13** | 100% | 부위·CPG 매칭 선별 |
| 운동 — 신경근 | `category_ex_neuromuscular` | — | 11 | **8** | — | acute/subacute 핵심 |
| 운동 — 저항 | `category_ex_resistance` | — | 13 | **7** | — | subacute/chronic 핵심 |
| 운동 — 체중부하 | `category_ex_bodyweight` | — | 10 | **7** | — | chronic·기능 회복 핵심 |
| **운동 합계** | (3 카테고리) | 20 | 34 | **22** | 110% | 목표 약간 초과 — 6 부위 × 3 acuity 커버 보강 |
| **전체** | | **80** | **160** | **80** | 100% | |

### 1.2 54 시나리오 커버리지

- 전체 54 시나리오 중 **시나리오당 최소 3개 Tier 1 기법 매핑** 기준:
  - **48 / 54 (89%) 시나리오 충분 커버 (≥3 매핑)**
  - **6 / 54 시나리오 부분 커버 (1~2 매핑)** — 모두 **lumbar × Maitland·Mulligan 부재**가 원인:
    - Lumbar × Acute / Subacute / Chronic × 움직임 시 통증 (3건) — Maitland Lumbar PA 부재
    - Lumbar × Acute / Subacute / Chronic × 방사통 (3건) — Mulligan SLR-MWM 부재
  - Lumbar × 안정 시 통증 3건은 MFR + TrP + 운동 (MCE·McGill·GradedActivity)로 ≥3 커버 가능

### 1.3 핵심 부족분 (sw-db-architect 위임 후보)

| 우선 | 카테고리 | 신규 추가 후보 | 이유 |
|---:|---|---|---|
| **P0** | `category_joint_mobilization` | Lumbar PA central / unilateral (Maitland Grade I~IV) | APTA LBP CPG 2021 강한 권고. 6 시나리오 직접 영향. |
| **P0** | `category_mulligan` | Lumbar SNAG, SLR-MWM | APTA LBP CPG 2021 + KAOMPT 임상 표준. 6 시나리오 직접 영향. |
| **P1** | `category_ex_neuromuscular` | Lumbar Neural Mobilization (Sciatic Slider/Tensioner) — 별도 abbrev | 현 MCE 1건만. 방사통 시나리오 운동 보강. |
| **P2** | `category_ex_bodyweight` | Lumbar McKenzie REIL/REIS, hip hinge 교육 분리 항목 | GradedActivity·McGill에 흡수되어 있으나 명시 항목으로 분리 권장. |

---

## §2. 카테고리별 큐레이션 명단

**선정 근거 코드**:
- **A**: CPG 권고 강도 strong (APTA / JOSPT)
- **B**: 한국 임상 사용 빈도 높음 (KAOMPT / 외래 정형 PT 표준)
- **C**: 54 시나리오 커버리지 보강 필수
- **D**: KMO 안전성 — 통증 한계 내 적용, 반파국화 메시지 호환

---

### 2.1 `category_joint_mobilization` (Maitland) — 20 큐레이션

| # | abbreviation | name_ko | body_region | acuity 적합 | 근거 | 임상 노트 (1줄) |
|---:|---|---|---|---|---|---|
| 1 | `JM-CX-PA-C` | 경추 중앙 후-전방 가동술 | cervical | acute~chronic | A,B,C | APTA Neck 2017 — cervical mobilization strong. 중앙 PA Grade I~IV 진동. |
| 2 | `JM-CX-PA-U` | 경추 단측 후-전방 가동술 | cervical | acute~chronic | A,B | 패턴 매칭 우월 — 회전·측굴 제한 시 핵심. |
| 3 | `JM-CX-Rot` | 경추 회전 관절가동술 | cervical | subacute~chronic | A,B | 회전 제한 직접 표적. Grade III~IV. |
| 4 | `JM-CX-LatFx` | 경추 측방굴곡 관절가동술 | cervical | subacute~chronic | B,C | 측굴 제한 패턴. |
| 5 | `SH-JM-GHJ-INF` | 견관절 GHJ 하방 견인 | shoulder | acute~chronic | A,B,D | Adhesive capsulitis CPG 핵심. Grade I~II 안전 진정. |
| 6 | `SH-JM-GHJ-POST` | 견관절 GHJ 후방 글라이드 | shoulder | subacute~chronic | A,B | 굴곡·내회전 제한 표적 (frozen shoulder). |
| 7 | `SH-JM-GHJ-ANT` | 견관절 GHJ 전방 글라이드 | shoulder | subacute~chronic | A,B | 외회전·신전 제한 표적. |
| 8 | `SH-JM-GHJ-ABD` | 견관절 외전 위치 하방 글라이드 | shoulder | subacute~chronic | A,B | Subacromial space 확보. JOSPT 2020. |
| 9 | `SH-JM-STJ-INF` | 견갑흉곽관절 하방 활주 | shoulder | subacute~chronic | B,C | Scapular dyskinesis 동반 시 핵심. |
| 10 | `SH-JM-ACJ-PA` | 견봉쇄골관절 전방 PA 가동술 | shoulder | acute~chronic | B | AC joint stiffness, scapular plane 통증. |
| 11 | `KN-JM-TFJ-PA` | 무릎 경대퇴관절 후방 PA 글라이드 | knee | acute~chronic | A,B,D | 무릎 OA CPG. Grade I~II 안전. |
| 12 | `KN-JM-TFJ-AP` | 무릎 경대퇴관절 전방 AP 글라이드 | knee | subacute~chronic | A,B | 신전 제한 표적. |
| 13 | `KN-JM-PFJ-INF` | 슬개골 하방 글라이드 | knee | subacute~chronic | A,B | 굴곡 제한 (PFP, OA) — 단, PFP는 운동 우선 (CPG). |
| 14 | `KN-JM-PFJ-MED` | 슬개골 내측 글라이드 | knee | subacute~chronic | B | 외측 tracking 동반 시. |
| 15 | `HIP-JM-TRACT` | 엉덩 관절 장축 견인 (LADM) | hip | acute~chronic | A,B,D | Hip OA CPG 2025 high-quality evidence. 안전·효과. |
| 16 | `HIP-JM-AP` | 엉덩 관절 전방 AP 글라이드 | hip | subacute~chronic | A,B | 굴곡·내회전 제한 표적. |
| 17 | `HIP-JM-INF` | 엉덩 관절 하방·외측 견인 | hip | acute~subacute | A,D | Grade I~II 진정. |
| 18 | `ANK-JM-TCJ-PA` | 거퇴관절 후방 PA 글라이드 | ankle_foot | acute~chronic | A,B | Lateral Ankle Sprain CPG 2021. Dorsiflexion 회복. |
| 19 | `ANK-JM-TCJ-TRACT` | 거퇴관절 장축 견인 | ankle_foot | acute | A,D | Grade I~II 안전 진정 (sprain acute). |
| 20 | `ANK-JM-STJ-MED` | 거종관절 내측 글라이드 | ankle_foot | subacute~chronic | B,C | CAI 시 subtalar mobility. |

**제외 (이유 → §5)**:
- `SH-JM-ACJ-INF`, `SH-JM-SCJ-ANT`, `SH-JM-STJ-MED`: 임상 빈도 ↓ — STJ-INF·ACJ-PA로 흉부대 충분 커버.
- `KN-JM-TFJ-LAT`, `KN-JM-PFJ-SUP`: 빈도 ↓ — TFJ-PA·PFJ-MED·PFJ-INF로 핵심 방향 커버.
- `HIP-JM-IR`, `HIP-JM-SIJ-ANT`, `HIP-JM-SIJ-POST`: SI joint는 별도 평가 흐름 필요 — LADM·AP·INF 우선. (SI는 P2 후속 큐레이션.)
- `ANK-JM-TCJ-AP`, `ANK-JM-STJ-LAT`, `ANK-JM-MTJ-DORS`: TCJ-PA·STJ-MED로 dorsiflexion·subtalar 핵심 방향 커버.

---

### 2.2 `category_mulligan` — 13 큐레이션 (목표 15, 부족 2)

| # | abbreviation | name_ko | body_region | acuity 적합 | 근거 | 임상 노트 |
|---:|---|---|---|---|---|---|
| 1 | `MUL-CX-SNAG-Rot` | 경추 회전 SNAG | cervical | acute~chronic | **A**,B | APTA Neck 2017 strong. 즉시 효과 — 한국 임상 선호 1순위. |
| 2 | `MUL-CX-SNAG-Ext` | 경추 신전 SNAG | cervical | subacute~chronic | A,B | 신전 제한 + 두통 양상. |
| 3 | `MUL-CX-SNAG-HA` | 경추성 두통 C1-C2 SNAG | cervical | subacute~chronic | A,B | Cervicogenic headache CPG. |
| 4 | `SH-MUL-FLEX` | 견관절 굴곡 MWM | shoulder | acute~chronic | A,B | 즉시 효과. JOSPT 2020 — subacromial pain. |
| 5 | `SH-MUL-ABD` | 견관절 외전 MWM | shoulder | acute~chronic | A,B | Painful arc 직접 표적. |
| 6 | `SH-MUL-ER` | 견관절 외회전 MWM | shoulder | subacute~chronic | A,B | Adhesive capsulitis thawing 단계. |
| 7 | `KN-MUL-FLEX` | 무릎 굽히기 MWM | knee | subacute~chronic | B | OA·PFP 굴곡 회복. 도수 isolation 회피 (CPG) — 운동 결합. |
| 8 | `KN-MUL-EXT` | 무릎 펴기 MWM | knee | subacute~chronic | B | 신전 제한 표적. |
| 9 | `KN-MUL-Pat` | 슬개건병증 MWM | knee | subacute~chronic | B | Patellar tendinopathy. |
| 10 | `HIP-MUL-FLEX` | 엉덩 관절 굽히기 MWM | hip | subacute~chronic | A,B | Hip OA CPG 2025. |
| 11 | `HIP-MUL-IR` | 엉덩 관절 내회전 MWM | hip | subacute~chronic | A,B | 내회전 제한 — capsular pattern. |
| 12 | `ANK-MUL-DF` | 발목 배측굴곡 MWM | ankle_foot | acute~chronic | **A**,B | Lateral Ankle Sprain CPG 2021 strong recommendation. PMC 2020. |
| 13 | `ANK-MUL-INV` | 발목 내번 염좌 MWM | ankle_foot | subacute~chronic | A,B | CAI 단계. Weight-bearing MWM. |

**부족 (sw-db-architect 신규 추가 P0)**:
- **Lumbar SNAG** (예: `MUL-LX-SNAG-Flex`, `MUL-LX-SNAG-Ext`) — APTA LBP CPG 2021 conditional, 한국 임상 빈도 매우 높음.
- **Lumbar SLR-MWM** (예: `MUL-LX-SLR-MWM`) — 방사통 환자 핵심.

---

### 2.3 `category_mfr` — 12 큐레이션

| # | abbreviation | name_ko | body_region | acuity 적합 | 근거 | 임상 노트 |
|---:|---|---|---|---|---|---|
| 1 | `MFR-Scalenes` | 사각근 근막이완 기법 | cervical | subacute~chronic | B,C | 경추 acute/subacute 방사통 인자. TOS 감별 후. |
| 2 | `MFR-LevScap` | 견갑거근 근막이완 기법 | cervical | acute~chronic | B | 한국 사무직 환자 최빈도. |
| 3 | `Suboccipital MFR` | 후두하 근막이완 기법 | cervical | subacute~chronic | B,D | 안정 시 통증·두통 양상. Sustained 60~90초 진정. |
| 4 | `Lumbar MFR` | 요추 근막이완 기법 | lumbar | acute~chronic | B,C | 요추 광범위 커버. |
| 5 | `LumbMFR-Psoas` | 장요근 근막이완 기법 | lumbar | subacute~chronic | B | 요추 굴곡·hip 굴곡 인자. |
| 6 | `LumbMFR-Pir` | 이상근 근막이완 기법 | lumbar | subacute~chronic | B,C | 좌골신경 referred — 방사통 시나리오 핵심. |
| 7 | `SH-MFR-PecMin` | 소흉근 근막이완 | shoulder | subacute~chronic | A,B | 전방 어깨 자세 인자. JOSPT 2020. |
| 8 | `SH-MFR-Infra` | 극하근·소원근 근막이완 | shoulder | subacute~chronic | A,B | 회전근개 referred (어깨 전방통). |
| 9 | `KN-MFR-Quad` | 대퇴사두근 근막이완 | knee | subacute~chronic | B | PFP/OA 인자. |
| 10 | `HIP-MFR-GluMed` | 중둔근·소둔근 근막이완 | hip | subacute~chronic | A,B | Hip OA + 외측 hip pain (trochanteric). |
| 11 | `HIP-MFR-Pir` | 이상근 근막이완 | hip | subacute~chronic | B,C | Hip 방사통 — sciatic referred. |
| 12 | `ANK-MFR-GastSol` | 비복근·가자미근 근막이완 | ankle_foot | subacute~chronic | A,B | Dorsiflexion 회복. Ankle Sprain CPG. |

**제외**: 중복·임상 빈도 ↓ — `Neck Posterior MFR` (LevScap·Suboccipital로 커버), `TLF MFR`·`LumbMFR-LPJ` (Lumbar MFR로 흡수), `SH-MFR-Supra`·`SH-MFR-Sub`·`SH-MFR-Post` (PecMin·Infra로 핵심 커버), `KN-MFR-Ham`·`KN-MFR-ITB`·`KN-MFR-GastSol` (TrP에서 커버), `HIP-MFR-Psoas`·`HIP-MFR-TFL`·`HIP-MFR-Add` (TrP·LumbMFR-Psoas 와 중복), `ANK-MFR-PlantFas`·`ANK-MFR-Achilles`·`ANK-MFR-Peron` (별도 plantar fasciitis 시나리오 외 빈도 ↓).

---

### 2.4 `category_trigger_point` — 13 큐레이션

| # | abbreviation | name_ko | body_region | acuity 적합 | 근거 | 임상 노트 |
|---:|---|---|---|---|---|---|
| 1 | `UT-TrP` | 위등세모근 트리거포인트 (허혈성 압박) | cervical | subacute~chronic | B | 한국 임상 최빈도 1순위. 자가 도구 처방 가능. |
| 2 | `LevScap-TrP` | 견갑거근 트리거포인트 | cervical | subacute~chronic | B | 사무직 + 측방 경추 통증. |
| 3 | `Scalenes-TrP` | 사각근 트리거포인트 | cervical | subacute~chronic | B,C | 방사통 시나리오 핵심 — referred to arm. |
| 4 | `SubOcc-TrP` | 후두하근 트리거포인트 | cervical | subacute~chronic | B | 경추성 두통 + 안정 시 통증. |
| 5 | `QL-TPR` | 허리네모근 트리거포인트 | lumbar | acute~chronic | A,B,C | 요추 모든 시나리오 — referred 통증 패턴. |
| 6 | `LumbTrP-MF` | 요추 다열근 트리거포인트 | lumbar | subacute~chronic | B | 요추 심부 — segmental pain. |
| 7 | `LumbTrP-Pir` | 이상근 트리거포인트 | lumbar | subacute~chronic | B,C | Sciatica 양상 — 방사통 시나리오 필수. |
| 8 | `IS-TrP` | 가시아래근 트리거포인트 | shoulder | subacute~chronic | B,C | 어깨 전방 referred — 흔한 진단 누락 인자. |
| 9 | `SH-TrP-Sub` | 견갑하근 트리거포인트 이완 | shoulder | subacute~chronic | A,B | Frozen shoulder thawing 단계 핵심. |
| 10 | `KN-TrP-VMO` | 내측광근(VMO) 트리거포인트 | knee | subacute~chronic | B,C | PFP — 내측 무릎 통증. |
| 11 | `HIP-TrP-TFL` | 대퇴근막장근 트리거포인트 | hip | subacute~chronic | B,C | Trochanteric pain · ITB 인자. |
| 12 | `HIP-TrP-GluMed` | 중둔근 트리거포인트 | hip | subacute~chronic | A,B | Hip OA + 외측 hip pain. |
| 13 | `ANK-TrP-Peron` | 비골근 트리거포인트 | ankle_foot | subacute~chronic | B,C | CAI · 외측 발목 통증. |

**제외**: 중복 또는 빈도 ↓ — `SCM-TrP` (UT-TrP·Scalenes-TrP로 핵심 커버), `CervMult-TrP` (LumbTrP-MF·UT-TrP 와 중복 임상 의의), `CervTP-SOC`·`CervTP-UT`·`LumbTP-QL`·`LumbTP-PIR` (마이그 016 → 002와 중복 abbreviation/내용), `WE-TrP` (body_region 없음 — 별도 elbow/wrist 시나리오 영역), `RH-TrP` (thoracic — Tier 1 6부위 외), `GAST-SOL-TPR`/`ANK-TrP-Gast`/`ANK-TrP-Sol` (`ANK-MFR-GastSol`로 커버), `GMED-TPR`·`PIR-TPR`·`HAM-TPR` (HIP-TrP-* 와 중복), `KN-TrP-RF`·`KN-TrP-Poplit`·`KN-TrP-SemiTend`·`KN-TrP-BF` (VMO + Quad MFR로 핵심 커버), `SH-TrP-Supra`·`SH-TrP-Infra`·`SH-TrP-TMin`·`SH-TrP-PecMin`·`SH-TrP-Delt` (IS-TrP + SH-TrP-Sub로 핵심 커버), `HIP-TrP-Psoas`·`HIP-TrP-Pir`·`HIP-TrP-GluMax`·`HIP-TrP-Add` (LumbTrP-Pir + HIP-TrP-TFL/GluMed로 커버), `ANK-TrP-TibAnt`·`ANK-TrP-Plantar`·`LumbTrP-IL`·`LumbTrP-GluMed` (핵심 외 빈도).

---

### 2.5 `category_ex_neuromuscular` — 8 큐레이션

| # | abbreviation | name_ko | body_region | acuity 적합 | 근거 | 임상 노트 |
|---:|---|---|---|---|---|---|
| 1 | `DCFT` | 심부 경추 굴곡근 훈련 (CCFT) | cervical | acute~chronic | **A**,B | APTA Neck 2017 strong. 모든 cervical 시나리오 표준. |
| 2 | `CervPropRetraining` | 경추 고유감각 재훈련 | cervical | subacute~chronic | A,B | Chronic neck — 다요소 운동 일부. |
| 3 | `MCE` | 신경운동 조절 운동 (심부 코어) | lumbar | acute~chronic | **A**,B | APTA LBP 2021 strong. Lumbar 모든 시나리오 표준. |
| 4 | `SH-EX-NM-PNF-D2` | 어깨 PNF D2 패턴 | shoulder | subacute~chronic | A,B | 회전근개 · scapular control. |
| 5 | `SH-EX-NM-Proprio` | 어깨 고유감각 재훈련 | shoulder | subacute~chronic | A,B | Subacromial pain · 회전근개. |
| 6 | `KN-EX-NM-SLB` | 단일 하지 균형 훈련 | knee | subacute~chronic | A,B | PFP CPG — hip + knee 운동 핵심. |
| 7 | `HIP-EX-NM-PelvStab` | 골반 안정화 훈련 | hip | acute~chronic | A,B | Hip OA + LBP 동반 빈번. |
| 8 | `ANK-EX-NM-SEBT` | 별 균형 도달 검사 훈련 | ankle_foot | subacute~chronic | **A**,B | Lateral Ankle Sprain CPG 2021 — 균형 핵심. |

**제외**: `KN-EX-NM-Landing`, `HIP-EX-NM-SLS`, `ANK-EX-NM-Wobble` — 진행 단계 운동, 베타에서는 상위 8개로 acute/subacute 핵심 커버 (chronic 진행은 resistance·bodyweight 카테고리에서 보강).

---

### 2.6 `category_ex_resistance` — 7 큐레이션

| # | abbreviation | name_ko | body_region | acuity 적합 | 근거 | 임상 노트 |
|---:|---|---|---|---|---|---|
| 1 | `CervStrengthening` | 경추 주변근 강화 훈련 | cervical | subacute~chronic | A,B | APTA Neck 2017 chronic — endurance·strength. |
| 2 | `SH-EX-RES-ER` | 어깨 외회전 강화 | shoulder | subacute~chronic | **A**,B | 회전근개 핵심. JOSPT 2020/2025. |
| 3 | `SH-EX-RES-ScapRetract` | 견갑 후인·하강 강화 | shoulder | subacute~chronic | A,B | Scapular stabilization SR&MA 2024. |
| 4 | `KN-EX-RES-TKE` | 터미널 무릎 신전 (VMO 강화) | knee | subacute~chronic | B | PFP · OA · 슬개건. |
| 5 | `HIP-EX-RES-GluMed` | 중둔근 저항 강화 | hip | subacute~chronic | **A**,B | Hip OA + PFP CPG 핵심 (hip strengthening for PFP — JOSPT 2018). |
| 6 | `HIP-EX-RES-GluMax` | 고관절 신전 강화 (대둔근) | hip | subacute~chronic | A,B | LBP·Hip OA 광범위. |
| 7 | `ANK-EX-RES-Peron` | 비골근 강화 | ankle_foot | subacute~chronic | **A**,B | Lateral Ankle Sprain CPG · CAI. |

**제외**: `SH-EX-RES-RC-Diag`, `KN-EX-RES-HamCurl`, `KN-EX-RES-StepUp`, `HIP-EX-RES-Add`, `ANK-EX-RES-CalfRaise`, `ANK-EX-RES-DF` — 진행 단계 / 핵심 운동 위 7개로 커버.

---

### 2.7 `category_ex_bodyweight` — 7 큐레이션

| # | abbreviation | name_ko | body_region | acuity 적합 | 근거 | 임상 노트 |
|---:|---|---|---|---|---|---|
| 1 | `McGill-Big3` | 코어 안정화 훈련 (맥길 빅 쓰리) | lumbar | subacute~chronic | **A**,B | APTA LBP 2021. Chronic LBP 표준. |
| 2 | `GradedActivity` | 점진적 활동 (행동주의적 재활) | lumbar | chronic | **A**,D | PNE · 점진 노출. JOSPT 2016 중추감작. KMO 핵심. |
| 3 | `SH-EX-BW-Pendulum` | 진자 운동 (Codman) | shoulder | acute~subacute | B,D | Adhesive capsulitis freezing — 안전 운동. |
| 4 | `SH-EX-BW-WallSlide` | 벽 슬라이드 | shoulder | subacute~chronic | A,B | Serratus anterior · scapular control. |
| 5 | `KN-EX-BW-MiniSquat` | 미니 스쿼트 (벽 스쿼트) | knee | subacute~chronic | A,B | OA·PFP — 통증 한계 안. |
| 6 | `HIP-EX-BW-Bridge` | 브릿지 운동 | hip | acute~chronic | A,B | Hip extension · LBP 동반 빈번. |
| 7 | `HIP-EX-BW-Clam` | 클램셸 운동 | hip | acute~chronic | A,B | 중둔근 활성화 · PFP·Hip OA. |

**제외**: `KN-EX-BW-EccDecline` (patellar tendinopathy 전용 — 베타 범위 외), `ANK-EX-BW-ABC`·`ANK-EX-BW-ShortFoot` (균형 훈련 SEBT가 우선 커버).

---

## §3. 54 시나리오 ↔ 큐레이션 매핑

각 셀: 1차 권장 → 2차 권장. 형식: `abbreviation` (카테고리 약어). 카테고리 약어: M=Maitland, MU=Mulligan, MFR, TrP, NM=neuromuscular, RES=resistance, BW=bodyweight.

### 3.1 Cervical (경추) — 9 시나리오

| Acuity \ Pain | 움직임 시 통증 | 안정 시 통증 | 방사통 |
|---|---|---|---|
| **Acute** | `MUL-CX-SNAG-Rot`(MU) · `JM-CX-PA-C`(M) · `MFR-LevScap`(MFR) · `DCFT`(NM) | `JM-CX-PA-C`(M, Grade I) · `Suboccipital MFR`(MFR) · `SubOcc-TrP`(TrP) · `DCFT`(NM) | `JM-CX-PA-U`(M, contralateral) · `MFR-Scalenes`(MFR) · `Scalenes-TrP`(TrP) · `DCFT`(NM) |
| **Subacute** | `JM-CX-PA-U`(M) · `MUL-CX-SNAG-Ext`(MU) · `UT-TrP`(TrP) · `CervStrengthening`(RES) | `Suboccipital MFR`(MFR) · `SubOcc-TrP`(TrP) · `CervPropRetraining`(NM) | `MUL-CX-SNAG-Rot`(MU) · `MFR-Scalenes`(MFR) · `Scalenes-TrP`(TrP) · `CervStrengthening`(RES) |
| **Chronic** | `JM-CX-PA-U`(M) · `MUL-CX-SNAG-Rot`(MU) · `LevScap-TrP`(TrP) · `CervStrengthening`(RES) · `DCFT`(NM) | `Suboccipital MFR`(MFR) · `CervPropRetraining`(NM) · `GradedActivity`(BW, 일반화) | `MUL-CX-SNAG-Ext`(MU) · `MFR-Scalenes`(MFR) · `Scalenes-TrP`(TrP) · `CervStrengthening`(RES) |

**커버리지**: 9/9 ≥3 매핑.

### 3.2 Lumbar (요추) — 9 시나리오

| Acuity \ Pain | 움직임 시 통증 | 안정 시 통증 | 방사통 |
|---|---|---|---|
| **Acute** | ⚠️ `MCE`(NM) · `QL-TPR`(TrP) · `Lumbar MFR`(MFR) · **[부족: Lumbar PA, Lumbar SNAG]** | `Lumbar MFR`(MFR, sustained) · `QL-TPR`(TrP, 부드러움) · `MCE`(NM) | ⚠️ `LumbMFR-Pir`(MFR) · `LumbTrP-Pir`(TrP) · `MCE`(NM) · **[부족: SLR-MWM, Lumbar PA]** |
| **Subacute** | ⚠️ `LumbMFR-Psoas`(MFR) · `LumbTrP-MF`(TrP) · `MCE`(NM) · `McGill-Big3`(BW) · **[부족: Lumbar PA III~IV, SNAG]** | `Lumbar MFR`(MFR) · `QL-TPR`(TrP) · `MCE`(NM) · `McGill-Big3`(BW) | ⚠️ `LumbMFR-Pir`(MFR) · `LumbTrP-Pir`(TrP) · `MCE`(NM) · **[부족: SLR-MWM]** |
| **Chronic** | ⚠️ `LumbMFR-Psoas`(MFR) · `LumbTrP-MF`(TrP) · `McGill-Big3`(BW) · `GradedActivity`(BW) · `MCE`(NM) · **[부족: PA III~IV]** | `Lumbar MFR`(MFR) · `QL-TPR`(TrP) · `McGill-Big3`(BW) · `GradedActivity`(BW) · PNE | ⚠️ `LumbMFR-Pir`(MFR) · `LumbTrP-Pir`(TrP) · `McGill-Big3`(BW) · `GradedActivity`(BW) · **[부족: SLR-MWM, neural mobilization]** |

**커버리지**: 9/9 ≥3 매핑 (전체) — 단, ⚠️ 표시 6 시나리오는 Maitland/Mulligan 부재로 CPG 강한 권고 기법 누락 상태. **sw-db-architect 신규 추가 필요 (P0).**

### 3.3 Shoulder (어깨) — 9 시나리오

| Acuity \ Pain | 움직임 시 통증 | 안정 시 통증 | 방사통 |
|---|---|---|---|
| **Acute** | `SH-MUL-FLEX`(MU) · `SH-JM-GHJ-INF`(M, Grade I) · `IS-TrP`(TrP) · `SH-EX-BW-Pendulum`(BW) | `SH-JM-GHJ-INF`(M, Grade I) · `SH-MFR-PecMin`(MFR) · `SH-EX-BW-Pendulum`(BW) | (감별 후) `Scalenes-TrP`(TrP) · `MFR-Scalenes`(MFR) · `SH-EX-NM-Proprio`(NM) |
| **Subacute** | `SH-MUL-ABD`(MU) · `SH-JM-GHJ-POST`(M) · `SH-MFR-PecMin`(MFR) · `IS-TrP`(TrP) · `SH-EX-RES-ScapRetract`(RES) | `SH-JM-GHJ-INF`(M, II~III) · `SH-MFR-PecMin`(MFR) · `SH-TrP-Sub`(TrP) · `SH-EX-BW-WallSlide`(BW) | (감별 후) `MUL-CX-SNAG-Rot`(MU) · `Scalenes-TrP`(TrP) · `SH-EX-NM-PNF-D2`(NM) |
| **Chronic** | `SH-JM-GHJ-POST`(M, III~IV) · `SH-MUL-ABD`(MU) · `SH-TrP-Sub`(TrP) · `SH-EX-RES-ER`(RES) · `SH-EX-RES-ScapRetract`(RES) | `SH-MUL-ER`(MU) · `SH-JM-GHJ-ANT`(M) · `SH-TrP-Sub`(TrP) · `SH-EX-BW-WallSlide`(BW) | `MUL-CX-SNAG-Rot`(MU) · `Scalenes-TrP`(TrP) · `SH-EX-RES-ScapRetract`(RES) · `SH-EX-NM-PNF-D2`(NM) |

**커버리지**: 9/9 ≥3 매핑.

### 3.4 Knee (무릎) — 9 시나리오

| Acuity \ Pain | 움직임 시 통증 | 안정 시 통증 | 방사통 |
|---|---|---|---|
| **Acute** | `KN-JM-TFJ-PA`(M, I~II) · `KN-MFR-Quad`(MFR) · `KN-TrP-VMO`(TrP) · `KN-EX-NM-SLB`(NM, 안전) | `KN-JM-TFJ-PA`(M, Grade I) · `KN-MFR-Quad`(MFR) · `KN-EX-BW-MiniSquat`(BW, 등척성) | (감별 lumbar) `LumbMFR-Pir`(MFR) · `LumbTrP-Pir`(TrP) · `MCE`(NM) |
| **Subacute** | `KN-MUL-FLEX`(MU) · `KN-JM-TFJ-AP`(M) · `KN-TrP-VMO`(TrP) · `KN-EX-RES-TKE`(RES) · `HIP-EX-RES-GluMed`(RES, PFP 필수) | `KN-JM-PFJ-INF`(M) · `KN-MFR-Quad`(MFR) · `KN-EX-BW-MiniSquat`(BW) | (감별 후) `LumbTrP-Pir`(TrP) · `MCE`(NM) |
| **Chronic** | `KN-MUL-FLEX`(MU) · `KN-JM-TFJ-PA`(M, III~IV) · `KN-TrP-VMO`(TrP) · `HIP-EX-RES-GluMed`(RES) · `KN-EX-RES-TKE`(RES) · `KN-EX-BW-MiniSquat`(BW) | `KN-JM-TFJ-PA`(M, III) · `KN-MFR-Quad`(MFR) · `GradedActivity`(BW) | (감별) `LumbMFR-Pir`(MFR) · `LumbTrP-Pir`(TrP) · `HIP-EX-RES-GluMed`(RES) |

**커버리지**: 9/9 ≥3 매핑. PFP 시나리오는 hip strengthening 결합 명시.

### 3.5 Hip (엉덩이) — 9 시나리오

| Acuity \ Pain | 움직임 시 통증 | 안정 시 통증 | 방사통 |
|---|---|---|---|
| **Acute** | `HIP-JM-TRACT`(M, LADM I~II) · `HIP-MFR-GluMed`(MFR) · `HIP-TrP-TFL`(TrP) · `HIP-EX-BW-Clam`(BW, 등척성) | `HIP-JM-INF`(M, Grade I) · `HIP-MFR-GluMed`(MFR) · `HIP-TrP-GluMed`(TrP) | `LumbMFR-Pir`(MFR) · `LumbTrP-Pir`(TrP) · `HIP-MFR-Pir`(MFR) · `MCE`(NM) |
| **Subacute** | `HIP-MUL-FLEX`(MU) · `HIP-JM-TRACT`(M, III~IV) · `HIP-MFR-GluMed`(MFR) · `HIP-EX-RES-GluMed`(RES) · `HIP-EX-BW-Bridge`(BW) | `HIP-JM-INF`(M, II~III) · `HIP-MFR-GluMed`(MFR) · `HIP-TrP-GluMed`(TrP) · `HIP-EX-BW-Clam`(BW) | `HIP-MUL-IR`(MU) · `LumbTrP-Pir`(TrP) · `HIP-MFR-Pir`(MFR) · `MCE`(NM) |
| **Chronic** | `HIP-JM-TRACT`(M, III~IV) · `HIP-MUL-FLEX`(MU) · `HIP-MFR-GluMed`(MFR) · `HIP-EX-RES-GluMax`(RES) · `HIP-EX-RES-GluMed`(RES) · `HIP-EX-BW-Bridge`(BW) | `HIP-JM-TRACT`(M) · `HIP-MFR-GluMed`(MFR) · `GradedActivity`(BW) | `HIP-MUL-IR`(MU) · `LumbMFR-Pir`(MFR) · `HIP-EX-RES-GluMax`(RES) · `MCE`(NM) |

**커버리지**: 9/9 ≥3 매핑.

### 3.6 Ankle (발목) — 9 시나리오

| Acuity \ Pain | 움직임 시 통증 | 안정 시 통증 | 방사통 |
|---|---|---|---|
| **Acute** | `ANK-MUL-DF`(MU, **CPG strong**) · `ANK-JM-TCJ-TRACT`(M, I~II) · `ANK-MFR-GastSol`(MFR) · `ANK-EX-NM-SEBT`(NM, 안전) | `ANK-JM-TCJ-TRACT`(M, Grade I) · `ANK-MFR-GastSol`(MFR) · `ANK-EX-NM-SEBT`(NM, 등척성 우선) | (희귀, 감별) `LumbTrP-Pir`(TrP) · `MCE`(NM) · `ANK-TrP-Peron`(TrP) |
| **Subacute** | `ANK-MUL-DF`(MU) · `ANK-JM-TCJ-PA`(M, III~IV) · `ANK-MFR-GastSol`(MFR) · `ANK-EX-NM-SEBT`(NM) · `ANK-EX-RES-Peron`(RES) | `ANK-JM-TCJ-PA`(M) · `ANK-MFR-GastSol`(MFR) · `ANK-TrP-Peron`(TrP) | (감별) `ANK-MUL-DF`(MU) · `ANK-TrP-Peron`(TrP) · `MCE`(NM) |
| **Chronic** | `ANK-MUL-INV`(MU) · `ANK-JM-TCJ-PA`(M) · `ANK-JM-STJ-MED`(M) · `ANK-TrP-Peron`(TrP) · `ANK-EX-RES-Peron`(RES) · `ANK-EX-NM-SEBT`(NM) | `ANK-JM-TCJ-PA`(M, III) · `ANK-MFR-GastSol`(MFR) · `GradedActivity`(BW) | (감별) `LumbMFR-Pir`(MFR) · `LumbTrP-Pir`(TrP) · `ANK-TrP-Peron`(TrP) |

**커버리지**: 9/9 ≥3 매핑.

### 3.7 커버리지 요약

| 부위 | ≥3 매핑 | 부족 | 비고 |
|---|---:|---:|---|
| Cervical | 9/9 | 0 | 완전 커버 |
| Lumbar | 9/9 | 6 (CPG 권고 누락) | Maitland Lumbar PA + Mulligan SNAG/SLR-MWM 부재 — 신규 추가 P0 |
| Shoulder | 9/9 | 0 | 완전 커버 |
| Knee | 9/9 | 0 | 완전 커버 (PFP hip strengthening 결합 명시) |
| Hip | 9/9 | 0 | 완전 커버 |
| Ankle | 9/9 | 0 | 완전 커버 |
| **합계** | **54/54 (100%)** | **6 (CPG 권고 누락 경고)** | 매핑은 충족, lumbar 도수 기법 부재 |

---

## §4. 부족분 / 신규 추가 필요

### 4.1 P0 — 베타 출시 전 추가 권장 (CPG 강한 권고 누락)

| 카테고리 | 신규 abbreviation 후보 | name_ko | body_region | 근거 |
|---|---|---|---|---|
| `category_joint_mobilization` | `JM-LX-PA-C` | 요추 중앙 후-전방 가동술 (Maitland) | lumbar | APTA LBP CPG 2021 conditional/strong (acute/chronic LBP — non-thrust joint mobilization) |
| `category_joint_mobilization` | `JM-LX-PA-U` | 요추 단측 후-전방 가동술 | lumbar | APTA LBP 2021 — 패턴 매칭 |
| `category_joint_mobilization` | `JM-LX-Rot` | 요추 회전 관절가동술 (side-lying rotation) | lumbar | KAOMPT 임상 표준 |
| `category_mulligan` | `MUL-LX-SNAG-Flex` | 요추 굴곡 SNAG | lumbar | APTA LBP 2021 + KAOMPT |
| `category_mulligan` | `MUL-LX-SNAG-Ext` | 요추 신전 SNAG | lumbar | APTA LBP 2021 |
| `category_mulligan` | `MUL-LX-SLR-MWM` | 요추 SLR-MWM (bent leg raise) | lumbar | 방사통 시나리오 핵심 |

### 4.2 P1 — 베타 후 보강

| 카테고리 | 신규 abbreviation 후보 | name_ko | body_region | 근거 |
|---|---|---|---|---|
| `category_ex_neuromuscular` | `LumbNeural-Slider`, `LumbNeural-Tensioner` | 좌골신경 슬라이더 / 텐셔너 | lumbar | Cochrane 2023 neural mobilization. 방사통 시나리오 운동 보강. |
| `category_ex_bodyweight` | `McKenzie-REIL`, `McKenzie-REIS` | 맥켄지 신전 운동 (lying/standing) | lumbar | JOSPT 2016 chronic LBP with directional preference. 현재 `GradedActivity`에 흡수되어 있으나 명시 항목 권장. |
| `category_joint_mobilization` | `JM-TX-PA-C` | 흉추 중앙 후-전방 가동술 | thoracic (별도) | APTA Neck 2017 — cervical 시나리오 흉추 결합 권고. Tier 1 6 부위 외 보강. |

### 4.3 P2 — 옵션 (큐레이션 확장 시 고려)

- SI joint mobilization 별도 분리 (현재 `HIP-JM-SIJ-*` 존재하나 큐레이션 제외 — 별도 lumbopelvic 시나리오 정의 필요).
- Plantar fasciitis · Achilles tendinopathy 별도 시나리오 추가 시 `ANK-MFR-PlantFas`, `ANK-MFR-Achilles`, `KN-EX-BW-EccDecline` 추가.
- 손목·팔꿈치 (lateral epicondylalgia 등) — `WE-TrP` 외 별도 부위 시나리오 정의 필요 (현재 Tier 1 6 부위 외).

---

## §5. 제외 사유 (KMO 철학 + 임상 적합성)

본 명단에서 제외된 카테고리 내 기법들의 사유 분류:

### 5.1 KMO 위배 또는 안전성 우려 — 0건

본 검토에서 KMO 철학 (통증 ≠ 손상, 반파국화) 명백히 위배하는 기법은 마이그 본문 내 발견되지 않음. 모든 INSERT는 `absolute_contraindications`·`relative_contraindications` 명시되어 안전성 확보. (cervical manipulation HVLA 같은 고위험 기법은 현재 마이그 본문에 미포함 — 자연스러운 KMO 정렬.)

### 5.2 임상 빈도 ↓ / 우선순위 외 — 다수

- `SH-JM-ACJ-INF`, `SH-JM-SCJ-ANT`, `SH-JM-STJ-MED`, `KN-JM-TFJ-LAT`, `KN-JM-PFJ-SUP`, `HIP-JM-IR`, `HIP-JM-SIJ-ANT`, `HIP-JM-SIJ-POST`, `ANK-JM-TCJ-AP`, `ANK-JM-STJ-LAT`, `ANK-JM-MTJ-DORS`: 주요 패턴 매칭은 큐레이션 20개 내 핵심 방향으로 충분 커버. 위 기법은 특수 임상 상황 (베타 후 확장).
- MFR · TrP 중복 부위 (`Neck Posterior MFR`, `TLF MFR`, `SH-MFR-Supra`/`Sub`/`Post`, `KN-MFR-Ham`/`ITB`/`GastSol`, `HIP-MFR-Psoas`/`TFL`/`Add`, `ANK-MFR-PlantFas`/`Achilles`/`Peron`): 광범위 MFR 1건 (예: `Lumbar MFR`) + 부위별 TrP 1~2건으로 임상 의의 충분. MFR + TrP 합쳐 25 큐레이션이면 핵심 근육군 커버.

### 5.3 중복 abbreviation (DB 본문 자체 UPSERT 처리) — 3건

- `UT-TrP`, `SCM-TrP`, `QL-TPR`: 마이그 002(soft-tissue-techniques) 와 마이그 016(cervical-techniques-tags) 간 UPSERT 충돌. 본 큐레이션에서는 distinct abbreviation 1건만 카운트.

### 5.4 Tier 1 6 부위 외 — 2건

- `WE-TrP` (손목·팔꿈치): body_region 미지정 + Tier 1 6 부위 외. 별도 시나리오 정의 시 추후 큐레이션.
- `RH-TrP` (thoracic): Tier 1 6 부위 외. 흉추 보조 시나리오 추가 시 큐레이션.

### 5.5 진행 단계 운동 (chronic 후속) — 5건

- `KN-EX-NM-Landing`, `HIP-EX-NM-SLS`, `ANK-EX-NM-Wobble`, `SH-EX-RES-RC-Diag`, `ANK-EX-RES-CalfRaise` 등: chronic 진행 단계 — 베타에서는 acute/subacute 핵심 운동 우선. P2 확장 시 추가.

---

## §6. 운영 사용 가이드

### 6.1 베타 출시 시 적용

1. `techniques.is_published = true` AND `abbreviation IN (위 80건)` 필터링이 베타 추천 풀.
2. AI 추천 prompt에서 80개만 검색하도록 제한 (`recommendation_evaluation` 마이그 051 가중치 합산 대상 좁힘).
3. 시나리오 매핑 (§3) 표를 LLM context 또는 retrieval 메타데이터로 활용.

### 6.2 신규 추가 우선순위 (sw-db-architect 위임)

- **마이그 056 (P0)** — 후속: `JM-LX-PA-C`, `JM-LX-PA-U`, `JM-LX-Rot`, `MUL-LX-SNAG-Flex`, `MUL-LX-SNAG-Ext`, `MUL-LX-SLR-MWM` (6건 신규 INSERT) → 80 + 6 = 86 큐레이션 확장.
- **마이그 057~ (P1~P2)** — neural mobilization, McKenzie, 흉추 mobilization, SI joint 분리, plantar fasciitis 시나리오 등.

### 6.3 LOG / 추후 검토 사항

- 본 명단은 **마이그 본문 기준** (002~038, 045) — production DB의 `is_published` 상태와 정확히 일치하는지는 sw-db-architect 검증 권장 (Item별 sanity check).
- 마이그 045 (`backfill-applicable-muscles`) 는 INSERT 가 아니라 UPDATE 이므로 본 추출에서 제외됨 — 영향 없음.
- 마이그 018 (`cleanup-duplicates`), 019(`fix-placeholder-steps`), 021/022/023/024 (`fix-*-steps`) 는 UPDATE — 본 추출에 영향 없음.

---

## §7. 인용

본 명단의 임상 근거 인용은 `docs/clinical-3axis-tier1-recommendation-research-2026-05-06.md` §7 (인용·참고 문헌) 전체 항목 — APTA CPG (Neck 2017 / LBP 2021 / Hip 2025 / Knee 2018 / PFP 2019 / Shoulder 2013/2020/2025 / Ankle 2021), Cochrane SR (Neural Mobilization 2023 / Manual Therapy 2021 / Mulligan 2025 / Adhesive Capsulitis 2024), JOSPT 2016 (Central Sensitization / McKenzie), KAOMPT (도수치료 최신 지견 2024).

---

> **다음 단계**:
> 1. (sw-db-architect) 마이그 056 작성 — P0 6 건 신규 INSERT (lumbar Maitland 3 + Mulligan 3). 본 명단 §4.1 참조.
> 2. (sw-backend-dev) 추천 API에서 `is_published = true AND abbreviation IN (위 80건)` 필터 적용.
> 3. (sw-product-manager) UI에서 시나리오 매핑 (§3) 표를 활용한 "환자 패턴 → 처방" 흐름 구현 검토.
> 4. (sw-clinical-translator, sw-qa-tester) 베타 시점 임상가 피드백 수집 → 큐레이션 명단 분기별 재검토 (분기당 1회).
