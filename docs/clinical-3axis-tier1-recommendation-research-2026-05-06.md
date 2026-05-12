# 3축 × Tier 1 카테고리 임상 권장 매트릭스 (2026-05-06)

> **작성**: sw-clinical-translator
> **목적**: 추천 시스템 차별화 — "임상가가 받자마자 환자에게 적용 가능한 형태"의 시나리오별(부위 × 급성도 × 통증 양상) 표준 도수치료 / 연부조직 / 운동 처방 정리.
> **근거**: APTA Clinical Practice Guidelines (각 부위), IFOMPT/KAOMPT, Cochrane Reviews, JOSPT 시스템 리뷰, 한국 임상 현실 컨텍스트.
> **KMO 철학**: 통증 ≠ 손상. 반파국화. "Calm things down, build things back up."

---

## 1. 한 줄 요약

54 시나리오 (6 부위 × 3 acuity × 3 통증 양상) × Tier 1 카테고리 (Maitland / Mulligan / MFR / TrP / 운동 처방) 권장 접근. CPG 권고 강도와 한국 외래 정형 PT 임상 선호도를 함께 명시. **목표: 임상가가 LLM 검색 대신 한 번의 추천으로 환자에게 즉시 적용 가능한 처방을 받게 한다.**

---

## 2. Tier 1 카테고리 + 운동 처방 (대표님 결정 2026-05-06)

| 그룹 | 카테고리 ID | 핵심 기법 | 적용 강도 |
|---|---|---|---|
| **관절 가동술** | `category_joint_mobilization` (Maitland) | Grade I~V PA / AP / Glide, 진동 또는 지속 압 | 통증 한계 안 ~ 한계 너머 |
| **관절 가동술** | `category_mulligan` | MWM (Mobilization with Movement), SNAG, NAG | 통증 즉시 감소 가능한 범위 |
| **연부조직 — 근막** | `category_mfr` | Tom Myers 기반 근막 라인 이완, 지속 압·신장 | 부드러움 ~ 중간 |
| **연부조직 — TrP** | `category_trigger_point` | 압박(ischemic compression) → 신장 → 이완, 후속 운동 | 한계점 → 풀림 |
| **운동 처방** | `category_ex_neuromuscular` | 신경근 조절 / 등척성 / 자세 제어 | 통증 안전 범위 |
| **운동 처방** | `category_ex_resistance` | 저항 운동 / 점진적 부하 | 통증 한계 아래 점진 증량 |
| **운동 처방** | `category_ex_bodyweight` | 체중 부하 / 기능 동작 | 일상 동작 부하 모사 |

**운영 원칙 (KMO):**
- 통증 한계 내 작업 → 안전 신호.
- 환자 교육: "통증 = 위험 신호 아님" 명시.
- 도수 후 운동 결합 — "도수만으로 끝나지 않는다" 일관 메시지.

---

## 3. 3축 정의

### 3.1 Part (부위, 6개)
| Part | 한국어 | 주요 관절·구조 |
|---|---|---|
| `cervical` | 경추 | C0-C7, 상부 흉추, 사각근·승모근·견갑거근·후두하근 |
| `lumbar` | 요추 | L1-L5, 천장관절, 다열근·요방형근·복근군 |
| `shoulder` | 어깨 | GH·AC·SC·견갑흉관절, 회전근개·삼각근·견갑근군 |
| `knee` | 무릎 | TF·PF, 대퇴사두근·햄스트링·내측광근·하퇴근군 |
| `hip` | 엉덩이 | 고관절, 둔근군·이상근·고관절 굴곡근군 |
| `ankle` | 발목 | 거퇴·거골하·원위 경비, 비골근군·후경골근·아킬레스 |

### 3.2 Acuity (급성도, 3개)
| Acuity | 기간 | 임상 특징 |
|---|---|---|
| `acute` | 0~7일 | 염증 활성, 통증 강도 높음, 부종·열감 가능, AROM 제한 |
| `subacute` | 7~30일 | 조직 회복기, 통증 변동, ROM 점진 회복, 동작 두려움 시작 |
| `chronic` | 30일+ | 중추감작 가능, 운동공포, 기능 장애 위주, 조직 회복 단계 지남 |

### 3.3 Pain Condition (통증 양상, 3개)
| Pain Condition | 한국어 | 특징 |
|---|---|---|
| `movement-evoked` | 움직임 시 통증 | 가동 범위 끝, 부하 시 발생. 안정 시 호전. |
| `rest-pain` | 안정 시 통증 | 특정 자세, 야간통, 활동과 무관한 통증. 조직 자극 또는 중추감작 의심. |
| `radicular` | 방사통 | 신경 뿌리/말초 신경 패턴. 데르마톰 분포, 저림·감각 이상 동반 가능. |

---

## 4. 매트릭스 — 부위별 9 시나리오 × 3 카테고리

### 4.1 Cervical (경추)

#### 4.1.1 Cervical × Acute × 움직임 시 통증
- **임상 패턴**: 아침에 일어나니 목이 한쪽으로 안 돌아간다 / 운전 중 후방 확인 시 찌릿. AROM 회전 제한, 끝 범위에서 sharp pain. 어깨에 힘이 들어감. 외상 없음 → "잠을 잘못 잤다(낙침)" 또는 가벼운 stiffness pattern.
- **CPG 권고**: APTA Neck Pain CPG 2017 — Acute neck pain with mobility deficits → cervical mobilization/manipulation + thoracic manipulation + ROM exercise (강력 권고). [JOSPT 2017](https://www.jospt.org/doi/10.2519/jospt.2017.0302)
- **Tier 1 권장**:
  - **Maitland 관절가동술**: C2–C7 PA central/unilateral Grade I~II 진동, 통증 한계 안. 흉추 PA Grade III~IV 같이 적용 (cervical은 부드럽게, thoracic은 적극적). 환자가 "찌릿"한 자세 회피.
  - **Mulligan**: SNAG (회전 제한 측 articular pillar에 lateral glide + 환자 active rotation). 즉시 ROM 회복 체감 강함. NAG도 유효.
  - **MFR**: 상부 승모근, 견갑거근 부드러운 release. 급성 자극 시점은 짧고 부드럽게.
  - **TrP**: 상부 승모근 TrP 압박 — 통증 강하면 회피. 저강도 압만.
  - **운동 (neuromuscular)**: 등척성 deep neck flexor 활성화 (chin tuck) — 1세트 10회 × 10초 hold, 통증 한계 내. 능동 ROM (천천히, 통증 한계까지).
- **금기/주의**: Red flag — 외상 후 (whiplash 의심 시 영상 진단 우선), VBI 증상 (어지럼·복시·구음장애·뇌신경 증상), 야간통 + 체중감소 (종양 의심). 5D's And 3 N's 스크리닝.
- **한국 임상 선호**: 환자가 "한 번에 풀어달라" 요구 — Mulligan SNAG 즉시 효과 인상 강함. 흉추 manipulation 결합 시 환자 만족도 높음. 단, "뚝 소리"에 거부감 있는 환자 → Maitland Grade III 진동 대체.

---

#### 4.1.2 Cervical × Acute × 안정 시 통증
- **임상 패턴**: 누워있어도 아프다, 베개를 바꿔도 불편. 야간통 가능. 전방 머리자세에서 후두하 압박감. 기침·재채기 시 자극.
- **CPG 권고**: APTA Neck Pain CPG 2017 — 안정 시 통증 동반은 inflammatory/irritable presentation 가능 → 자극 최소 + 환자 교육 + 자세 조언. [JOSPT 2017](https://www.jospt.org/doi/10.2519/jospt.2017.0302)
- **Tier 1 권장**:
  - **Maitland**: Grade I 진동만 (무자극·진정 목적). 통증 유발 자세 회피. C0/C1 부드러운 distraction 시도 가능.
  - **Mulligan**: 급성 안정 시 통증은 SNAG 부적합 (자극 가능). 환자 reactive면 회피. Subacute 진입 후 도입.
  - **MFR**: 후두하근, 상부 승모근 부드러운 sustained pressure (60~90초). 환자 호흡과 동조.
  - **TrP**: 후두하 TrP 가능 — 단, 안정 시 통증 강한 시점은 직접 압박 회피. 저강도만.
  - **운동 (neuromuscular)**: 베개 조정 교육 (목 중립 유지). 등척성 chin tuck 누운 자세에서 가볍게.
- **금기/주의**: Red flag 적극 스크리닝 — 야간통 + 진행성 + 비기계적 통증 (체중감소, 발열, 신경 증상) → 의뢰. 안정 시 통증 + 점진 악화 = 영상 진단 우선.
- **한국 임상 선호**: 환자가 "수면 부족" 호소 → 자세 교육·베개 조정 + 부드러운 도수. "센 도수" 요구해도 거부, 점진 접근 설명 필요.

---

#### 4.1.3 Cervical × Acute × 방사통
- **임상 패턴**: 목 + 한쪽 팔로 찌릿한 통증, 손가락 저림. 특정 자세 (목 신전+회전+측굴 동측 — Spurling 양성)에서 악화. 야간 자세에서 깸. 외상 또는 갑작스런 발생.
- **CPG 권고**: APTA Neck Pain CPG 2017 — Acute neck pain with radiating pain → cervical traction (mechanical intermittent), cervicothoracic mobilization, neural mobilization 고려. [JOSPT 2017](https://www.jospt.org/doi/10.2519/jospt.2017.0302). 시스템 리뷰: manual therapy 효과 있음. [PMC 2021](https://pmc.ncbi.nlm.nih.gov/articles/PMC8201115/)
- **Tier 1 권장**:
  - **Maitland**: Contralateral C-spine PA Grade I~II (증상측 신경 부하 회피). 흉추 mobilization (T1-T4) Grade III~IV. 환자 통증 측 과도 압박 금지.
  - **Mulligan**: SNAG (대측 articular pillar) — 통증 한계 내 시도. 통증 즉시 감소되면 양호 신호. 변화 없거나 악화 → 중단.
  - **MFR**: 사각근 (특히 anterior/middle scalene — TOS 감별 후) 부드러운 release. 상부 승모근.
  - **TrP**: 사각근 TrP — 신경 자극 우려로 경계 필요. Trigger 압박이 방사통 재현 → 양성, 부드러운 sustained pressure만.
  - **운동 (neuromuscular)**: Neural slider (median nerve glide) 통증 한계 안. Deep neck flexor 등척성. 통증 유발 자세 회피 교육.
- **금기/주의**: Red flag — 진행성 신경 증상 (근력 감소, 반사 소실, myelopathy 징후 [Hoffmann/Babinski]), 양측 증상, 보행 장애 → 즉시 의뢰. Cervical manipulation은 acute radiculopathy에서 신중. VBI 증상 동반 시 절대 금기.
- **한국 임상 선호**: "신경 눌렸다고 들었다" 환자 표현 — KMO 철학상 disc/nerve 강조 자제, "신경 자극이 가라앉을 수 있도록 도와드리는 단계" 표현. 트랙션 환자 선호 높음 (한국 외래 정형 PT 흔한 처방).

---

#### 4.1.4 Cervical × Subacute × 움직임 시 통증
- **임상 패턴**: 2~3주 경과, 끝 범위에서 여전히 stiff. 컴퓨터 작업 후 악화. 회전·신전 패턴 제한 잔존.
- **CPG 권고**: APTA Neck Pain CPG 2017 — Subacute → cervical/thoracic manipulation/mobilization + SNAG exercises + 신경근 운동 (강한 권고). [JOSPT 2017](https://www.jospt.org/doi/10.2519/jospt.2017.0302)
- **Tier 1 권장**:
  - **Maitland**: PA Grade III~IV (통증 한계 너머 진동) — stiffness 해결 목적. Unilateral PA가 패턴 매칭 시 효과 큼. 흉추 manipulation 적극 결합.
  - **Mulligan**: SNAG self-treatment 처방 (수건/벨트 활용 자가 SNAG). MWM 적극 시도.
  - **MFR**: 사각근, 상부 승모근, 후두하근 적극 release. 흉근(pec minor)도 자세 인자.
  - **TrP**: 상부 승모근, 견갑거근 직접 압박. 환자 자가 마사지 도구 처방 (lacrosse ball).
  - **운동 (neuromuscular + resistance)**: CCFT 진행, scapular setting (lower trap, mid trap), 흉추 신전 운동 (foam roller). 등척성 → 등장성 진행.
- **금기/주의**: 여전히 red flag 스크리닝 (체중감소·야간통·진행성 신경 증상).
- **한국 임상 선호**: 도수 + 자가 운동 결합 처방 환자 만족도 높음. "도수 받고 끝" 인식 깨기 — 운동 자가 처방 강조.

---

#### 4.1.5 Cervical × Subacute × 안정 시 통증
- **임상 패턴**: 회복 단계지만 잠자리 통증 잔존. 자세 유지 시 둔통. 활동 후 호전, 휴식 시 다시 발생.
- **CPG 권고**: 자세·생활습관 인자 평가 + multimodal care. APTA 2017 — patient education + ergonomic 권고.
- **Tier 1 권장**:
  - **Maitland**: PA Grade II~III, sustained mobilization. 환자 편안한 자세에서.
  - **Mulligan**: SNAG 가능. 환자 반응 모니터.
  - **MFR**: 후두하근·상부 승모근 sustained 60~120초. Pec minor (전방 머리자세 인자).
  - **TrP**: 후두하 TrP 적극 — 안정 시 통증 패턴과 매칭 잦음. 압박 후 신장.
  - **운동 (neuromuscular)**: 자세 교정 운동 (도복부 활성화, 흉추 신전). 베개·책상 환경 교육.
- **금기/주의**: 안정 시 통증 + 진행 = red flag 재평가.
- **한국 임상 선호**: 사무직 환자 다수 — 자세 교육 + 도수 + 자가 운동 패키지가 표준.

---

#### 4.1.6 Cervical × Subacute × 방사통
- **임상 패턴**: 초기 acute 이후 신경 증상 잔존. 팔 저림 강도는 감소했으나 잔존. 특정 자세 회피 패턴.
- **CPG 권고**: APTA 2017 — multimodal: manipulation/mobilization + neural mobilization + traction (선택적) + exercise. [JOSPT 2017](https://www.jospt.org/doi/10.2519/jospt.2017.0302)
- **Tier 1 권장**:
  - **Maitland**: C-spine PA + 흉추 mobilization 적극. 통증 한계 내 점진 진행.
  - **Mulligan**: SNAG with arm position (증상 재현 안 되는 자세). 효과 있으면 self-SNAG 처방.
  - **MFR**: 사각근 (TOS 인자 평가 후), 흉근, 상부 승모근.
  - **TrP**: 사각근 TrP — 방사 패턴 재현되면 적극 치료.
  - **운동 (neuromuscular)**: Neural mobilization (slider → tensioner 점진), deep neck flexor, scapular control (lower trap).
- **금기/주의**: 신경 증상 진행 시 즉시 의뢰. Manipulation은 신중 (mobilization 우선).
- **한국 임상 선호**: 트랙션 + 도수 + 운동 결합 일반적.

---

#### 4.1.7 Cervical × Chronic × 움직임 시 통증
- **임상 패턴**: 30일 이상 stiff·통증 잔존. 운동 회피, 어깨까지 동작 제한 확장. 직장에서 컴퓨터 8시간+. 환자 "원래 그래요" 인식.
- **CPG 권고**: APTA 2017 — Chronic neck pain with mobility deficits → multimodal: thoracic + cervical manipulation/mobilization, mixed exercises (coordination, proprioception, postural, stretching, strengthening, endurance, aerobic) + 인지 정서 요소. [JOSPT 2017](https://www.jospt.org/doi/10.2519/jospt.2017.0302)
- **Tier 1 권장**:
  - **Maitland**: PA Grade IV 적극, 흉추 manipulation 결합. 패턴 매칭 정확.
  - **Mulligan**: SNAG, self-SNAG 처방. MWM 적극.
  - **MFR**: 후두하·상부 승모근·견갑거근·사각근·흉근 — 만성에서 광범위 myofascial 인자.
  - **TrP**: 상부 승모근, 견갑거근 적극. 환자 자가 도구 처방.
  - **운동 (neuromuscular + resistance + bodyweight)**: 체계적 점진 — CCFT → 표재 굴곡근 → 신전근 → 회전근. Scapular control. 흉추 mobility. 유산소 (걷기·자전거) 결합.
- **금기/주의**: 만성 → 중추감작 가능, "통증 = 손상 아님" 환자 교육 (KMO 핵심).
- **한국 임상 선호**: 만성 환자 도수 의존 경향 — 운동 비중 높이는 단계적 처방 필요. "도수는 도구, 결국 본인 운동" 메시지.

---

#### 4.1.8 Cervical × Chronic × 안정 시 통증
- **임상 패턴**: 만성 + 안정 시 통증 동반 → 중추감작 의심. 잠자리 불편, 활동 줄여도 통증 변화 없음. 동반 우울·불안·수면장애 흔함.
- **CPG 권고**: 만성 + 안정 시 통증 = 통증 신경과학 교육 (PNE) + 점진 운동 + 다학제 접근. [JOSPT 2016](https://www.jospt.org/doi/10.2519/jospt.2016.0612)
- **Tier 1 권장**:
  - **Maitland**: Grade I~II 진정 목적. 만성에서도 자극 회피.
  - **Mulligan**: 효과 있으면 사용, 환자 반응 우선.
  - **MFR**: 부드러운 sustained — 진정·이완 효과 활용. 호흡·이완 결합.
  - **TrP**: 만성 TrP 다발 — 신중. 압박 시간·강도 모두 부드럽게.
  - **운동 (neuromuscular + bodyweight)**: 점진 노출 (graded exposure), 일상 활동 회복 우선. 유산소 강조 (전신 운동).
- **금기/주의**: 도수만으로 해결 불가능 단계 — 환자 교육 우선. PNE (Pain Neuroscience Education) 결합 권장. 우울·불안 동반 시 다학제 의뢰.
- **한국 임상 선호**: 만성 환자 "약 + 도수" 기대 → 운동 + 교육 비중 높이는 전환 필요.

---

#### 4.1.9 Cervical × Chronic × 방사통
- **임상 패턴**: 30일+ 신경 증상 잔존. 손 저림·약화 호소. 이전 영상 검사 (HIVD 진단 받은 경우 흔함). 동작 두려움·운동 회피.
- **CPG 권고**: APTA 2017 — chronic radiating pain → manual therapy + neural mobilization + 운동. Surgery 비교 conservative care 효과 동등 (대부분 케이스). [PMC 2011](https://pmc.ncbi.nlm.nih.gov/articles/PMC3143012/)
- **Tier 1 권장**:
  - **Maitland**: PA Grade III~IV (한계 너머). 흉추 manipulation 결합.
  - **Mulligan**: SNAG + arm position 적극.
  - **MFR**: 사각근, 흉근, 상부 승모근.
  - **TrP**: 사각근 TrP 적극.
  - **운동 (neuromuscular + resistance)**: Neural mobilization 진행 (tensioner), scapular control, 어깨 강화 (rotator cuff, scapular retractors).
- **금기/주의**: 신경 손상 진행 (근력·반사·감각) → 의뢰. Manipulation 신중.
- **한국 임상 선호**: 만성 디스크 진단 환자 — KMO 메시지 강력 ("디스크 = 손상 = 영구"는 사실 아님). 운동 비중 강조.

---

### 4.2 Lumbar (요추)

#### 4.2.1 Lumbar × Acute × 움직임 시 통증
- **임상 패턴**: 갑자기 허리 삐끗 (lifting, twisting). 굴곡·신전 제한, 일어설 때 sharp. 척추 측만 (antalgic shift) 가능. 보행 가능하지만 조심.
- **CPG 권고**: APTA Low Back Pain CPG 2021 — Acute LBP → thrust 또는 non-thrust joint mobilization (강한 권고), exercise, 환자 교육. [JOSPT 2021](https://www.jospt.org/doi/10.2519/jospt.2021.0304)
- **Tier 1 권장**:
  - **Maitland**: Lumbar PA central/unilateral Grade I~II (자극 회피), Grade III 점진 진입. SI joint mobilization 평가 후. Side-lying lumbar rotation 부드럽게.
  - **Mulligan**: SNAG (lumbar) — 굴곡·신전 제한 패턴. SLR-MWM 가능 (방사통 동반 시).
  - **MFR**: QL (quadratus lumborum), 다열근, 흉요추 근막. 부드러운 sustained.
  - **TrP**: QL TrP — acute에서 방사 통증 패턴. 압박 시 통증 재현 → 양성. 강도 조절.
  - **운동 (neuromuscular)**: 통증 한계 내 AROM, walking, 등척성 코어 (transverse abdominis 활성화). McKenzie 평가 (directional preference 확인).
- **금기/주의**: Red flag — 외상, 야간통, 발열, 체중감소, cauda equina 증상 (방광·항문 마비, saddle anesthesia), 진행성 신경 증상 → 즉시 의뢰.
- **한국 임상 선호**: 환자 "허리 삐끗" 표현 — Mulligan SNAG 즉시 효과 매력적. 도수 + 운동 + 자세 교육 패키지.

---

#### 4.2.2 Lumbar × Acute × 안정 시 통증
- **임상 패턴**: 누워있어도 아프다, 자세 변경해도 안 줄어. 야간통 가능. 굴곡·신전 자세 모두 회피.
- **CPG 권고**: APTA 2021 — irritable presentation → 자극 회피 + 환자 교육 + 부드러운 운동. [JOSPT 2021](https://www.jospt.org/doi/10.2519/jospt.2021.0304)
- **Tier 1 권장**:
  - **Maitland**: Grade I 진동만, sustained pressure 회피. Side-lying neutral position.
  - **Mulligan**: 급성 안정 시 통증 SNAG 보류, 환자 reactive면 부적합.
  - **MFR**: QL, 다열근, 광배근 부드러운 sustained pressure (호흡 동조).
  - **TrP**: QL TrP — 압박 가능하지만 부드럽게. 자극 시 회피.
  - **운동 (neuromuscular)**: 통증 한계 내 deep breathing, gentle pelvic tilt, knee-to-chest (편안한 자세 찾기).
- **금기/주의**: Red flag 적극 — 야간통 + 비기계적 통증 = 의뢰 우선. cauda equina 스크리닝 필수.
- **한국 임상 선호**: "자고 일어나도 안 풀려" 환자 — 자세·매트리스 교육 + 부드러운 도수.

---

#### 4.2.3 Lumbar × Acute × 방사통
- **임상 패턴**: 허리 + 다리로 찌릿. 한쪽 다리 발끝까지 저림. SLR 양성. 기침·재채기 시 자극. 갑작스런 lifting 후 발생 흔함.
- **CPG 권고**: APTA 2021 — acute LBP with radiating pain → thrust mobilization 효과 (moderate evidence), 신경 mobilization, McKenzie. [JOSPT 2021](https://www.jospt.org/doi/10.2519/jospt.2021.0304). 시스템 리뷰: manipulation 효과 moderate quality. [PMC 2021](https://pmc.ncbi.nlm.nih.gov/articles/PMC8201115/)
- **Tier 1 권장**:
  - **Maitland**: Lumbar PA contralateral 측 (증상측 신경 부하 회피), Grade I~II. Side-lying lumbar rotation 신중.
  - **Mulligan**: SLR-MWM (bent leg raise) 통증 한계 안. Lumbar SNAG 가능.
  - **MFR**: 이상근 (sciatic 자극 인자 가능), QL, 다열근. 직접 sciatic 압박 회피.
  - **TrP**: 이상근 TrP — 방사 패턴 재현 시 양성. 신중 압박.
  - **운동 (neuromuscular)**: 신경 mobilization (slider), McKenzie REIL (repeated extension in lying) — directional preference 평가 후. 통증 centralization 관찰.
- **금기/주의**: Red flag — 진행성 운동 약화 (foot drop), cauda equina (방광·항문), 양측 증상 → 즉시 의뢰. Manipulation 신중.
- **한국 임상 선호**: "허리 디스크" 환자 인식 강함 — 트랙션 (mechanical lumbar) 흔히 처방. KMO 메시지: "디스크 ≠ 영구 손상", "신경 자극 가라앉을 수 있다."

---

#### 4.2.4 Lumbar × Subacute × 움직임 시 통증
- **임상 패턴**: 2~3주 경과, 굴곡 제한 잔존. 앉다 일어날 때 stiff. 운동 시작 두려움.
- **CPG 권고**: APTA 2021 — subacute → exercise + manipulation/mobilization + 환자 교육. [JOSPT 2021](https://www.jospt.org/doi/10.2519/jospt.2021.0304)
- **Tier 1 권장**:
  - **Maitland**: PA Grade III~IV. Lumbar manipulation (HVLA) 환자 거부감 없으면 적극.
  - **Mulligan**: SNAG, self-SNAG 처방.
  - **MFR**: QL, 다열근, 광배근, 흉요추 근막. 적극.
  - **TrP**: QL, 다열근 TrP 적극.
  - **운동 (neuromuscular + resistance)**: 코어 (transverse abdominis, 다열근), McKenzie (directional preference 매칭), bird-dog, dead-bug, hip hinge 교육.
- **금기/주의**: 여전히 red flag 스크리닝.
- **한국 임상 선호**: 도수 + 운동 + 자세 교육 표준. 만성화 예방 메시지.

---

#### 4.2.5 Lumbar × Subacute × 안정 시 통증
- **임상 패턴**: 앉아있을 때 통증, 일어서면 호전 (또는 반대). 휴식 시 stiffness.
- **CPG 권고**: APTA 2021 — multimodal + 환자 교육 + 자세·생활습관.
- **Tier 1 권장**:
  - **Maitland**: PA Grade II~III. SI joint 평가.
  - **Mulligan**: SNAG.
  - **MFR**: QL, 광배근. Sustained pressure.
  - **TrP**: QL, 다열근.
  - **운동 (neuromuscular)**: 자세 교정 (neutral spine), 골반 mobility (cat-camel), 활동 휴식 사이클.
- **금기/주의**: 야간통 + 진행 = red flag.
- **한국 임상 선호**: 사무직 환자 흔함 — 책상 환경 교육 + 도수 + 운동.

---

#### 4.2.6 Lumbar × Subacute × 방사통
- **임상 패턴**: 초기 acute 후 신경 증상 잔존. SLR 변화 추이 관찰. 통증 centralization 진행 중 또는 정체.
- **CPG 권고**: APTA 2021 — subacute radiating → neural mobilization + manipulation/mobilization + McKenzie. [JOSPT 2021](https://www.jospt.org/doi/10.2519/jospt.2021.0304). Cochrane: lower-quarter neural mobilization 권장. [PMC 2023](https://pmc.ncbi.nlm.nih.gov/articles/PMC9848316/)
- **Tier 1 권장**:
  - **Maitland**: Lumbar PA + manipulation 점진. 통증 centralization 추적.
  - **Mulligan**: SLR-MWM, Lumbar SNAG.
  - **MFR**: 이상근, QL, 햄스트링 myofascial. Sciatic 직접 압박 회피.
  - **TrP**: 이상근, 둔근.
  - **운동 (neuromuscular + resistance)**: Neural mobilization (slider → tensioner), McKenzie, 코어, 둔근 강화.
- **금기/주의**: 진행성 신경 약화 → 의뢰.
- **한국 임상 선호**: 트랙션 + 도수 + 운동 결합 흔함.

---

#### 4.2.7 Lumbar × Chronic × 움직임 시 통증
- **임상 패턴**: 30일+ 만성 LBP. 운동 회피, 일상 활동 두려움. 영상 검사로 disc degeneration 진단 받은 경우 흔함.
- **CPG 권고**: APTA 2021 — Chronic LBP → motor control exercise + manipulation/mobilization + 환자 교육 (강한 권고). [JOSPT 2021](https://www.jospt.org/doi/10.2519/jospt.2021.0304). McKenzie chronic LBP with directional preference 효과. [JOSPT 2016](https://www.jospt.org/doi/10.2519/jospt.2016.6379)
- **Tier 1 권장**:
  - **Maitland**: PA Grade III~IV. Manipulation.
  - **Mulligan**: SNAG, self-SNAG.
  - **MFR**: 광범위 myofascial — QL, 광배근, 흉요추, 둔근.
  - **TrP**: QL, 다열근, 둔근, 이상근.
  - **운동 (neuromuscular + resistance + bodyweight)**: Motor control exercise, McKenzie, 점진 부하 (deadlift hip hinge 교육), 유산소 (걷기, 수영). 점진 노출.
- **금기/주의**: 만성 → 중추감작 가능, KMO 교육 핵심.
- **한국 임상 선호**: "디스크 환자" 자기 인식 강함 — 운동 무서워함. 점진 노출 + 안전 메시지 핵심.

---

#### 4.2.8 Lumbar × Chronic × 안정 시 통증
- **임상 패턴**: 만성 + 안정 시 통증 = 중추감작 강한 의심. 동반 우울·불안·수면장애.
- **CPG 권고**: APTA 2021 — 환자 교육 (PNE) + 점진 운동 + 다학제. [JOSPT 2016](https://www.jospt.org/doi/10.2519/jospt.2016.0612)
- **Tier 1 권장**:
  - **Maitland**: Grade I~II 진정.
  - **Mulligan**: 환자 반응 따라.
  - **MFR**: 이완 목적 sustained.
  - **TrP**: 신중.
  - **운동 (neuromuscular + bodyweight)**: 점진 노출, 유산소 강조.
- **금기/주의**: 도수 의존 깨기 — 환자 교육 우선.
- **한국 임상 선호**: PNE 도입 단계 — "통증 ≠ 손상" 메시지.

---

#### 4.2.9 Lumbar × Chronic × 방사통
- **임상 패턴**: 만성 신경 증상. 영상 진단 받음 (HIVD, spinal stenosis 등). 운동 두려움 강함.
- **CPG 권고**: APTA 2021 — chronic radiating → neural mobilization + manipulation + 운동 + 환자 교육. [JOSPT 2021](https://www.jospt.org/doi/10.2519/jospt.2021.0304)
- **Tier 1 권장**:
  - **Maitland**: PA Grade III~IV.
  - **Mulligan**: SLR-MWM, SNAG.
  - **MFR**: 이상근, QL, 햄스트링.
  - **TrP**: 이상근, 둔근.
  - **운동 (neuromuscular + resistance)**: Neural mobilization (tensioner), 코어, 둔근 강화, 점진 부하.
- **금기/주의**: 신경 진행 → 의뢰. Stenosis 환자 신전 운동 신중 (통증 패턴 반대).
- **한국 임상 선호**: 만성 디스크 진단 환자 — 운동 + 교육 비중 강조.

---

### 4.3 Shoulder (어깨)

#### 4.3.1 Shoulder × Acute × 움직임 시 통증
- **임상 패턴**: 갑자기 팔 들 때 통증, 옷 입을 때 sharp. Painful arc (60~120°). 외상 이력 또는 갑작스런 과사용 (페인팅, 골프 등).
- **CPG 권고**: Subacromial pain syndrome → 운동 치료 first-line (강한 권고). [JOSPT 2020](https://www.jospt.org/doi/10.2519/jospt.2020.8498)
- **Tier 1 권장**:
  - **Maitland**: GH joint inferior glide (통증 한계 안), AP glide, posterior glide. Grade I~II 진동.
  - **Mulligan**: Shoulder MWM (humeral head posterior glide + 환자 active flexion/abduction). 즉시 효과 체감.
  - **MFR**: Pec minor, 상부 승모근, 회전근개 myofascial.
  - **TrP**: Infraspinatus TrP (어깨 앞쪽 referred pain), supraspinatus, 상부 승모근.
  - **운동 (neuromuscular)**: 통증 한계 내 AROM (pulley, wand), 등척성 회전근개, scapular setting (lower trap, mid trap).
- **금기/주의**: Red flag — 외상 후 골절 의심 (변형, 못 들음 = 영상), 회전근개 전층 파열 (drop arm test) → 의뢰. 종양·감염 스크리닝.
- **한국 임상 선호**: "오십견 시작인가요?" 환자 흔한 질문 — 명확 감별 (impingement vs adhesive capsulitis). MWM 즉시 효과 매력.

---

#### 4.3.2 Shoulder × Acute × 안정 시 통증
- **임상 패턴**: 누우면 아파서 못 잠. 해당 측으로 못 누움. 활동과 무관한 통증.
- **CPG 권고**: 안정 시 통증 + 야간통 = inflammatory phase (frozen shoulder freezing 단계 의심). [PMC 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC10882424/)
- **Tier 1 권장**:
  - **Maitland**: Grade I 진동만 (자극 회피). Sustained 회피.
  - **Mulligan**: 급성 reactive 시 보류.
  - **MFR**: Pec minor, 상부 승모근 부드러운 sustained.
  - **TrP**: 신중. 압박 시 자극 가능.
  - **운동 (neuromuscular)**: Codman pendulum, 통증 한계 내 AROM, 등척성 가벼운.
- **금기/주의**: 야간통 + 점진 악화 + 연령 (50~60대 여성, 당뇨) → adhesive capsulitis freezing 단계 가능성. 영상 진단 의뢰 (rotator cuff tear 감별).
- **한국 임상 선호**: 환자 "오십견" 자기 진단 흔함 — 정확한 감별 + 단계별 치료 설명.

---

#### 4.3.3 Shoulder × Acute × 방사통
- **임상 패턴**: 어깨 + 팔 (deltoid 또는 손까지) 통증. 경추 인자 가능 (cervical radiculopathy referred). 또는 회전근개 referred pain.
- **CPG 권고**: 감별 — cervical 인자 vs shoulder 인자. APTA Neck CPG 2017, Shoulder CPG.
- **Tier 1 권장**:
  - **Maitland**: 감별 후 — cervical 인자면 C-spine, shoulder 인자면 GH. Thoracic mobilization 결합 (어깨에도 효과).
  - **Mulligan**: 감별 후 — Cervical SNAG 또는 Shoulder MWM.
  - **MFR**: 사각근 (TOS 감별), pec minor, 회전근개.
  - **TrP**: 사각근 (referred to arm), infraspinatus (referred to anterior shoulder/arm).
  - **운동 (neuromuscular)**: Neural mobilization (median, radial, ulnar 평가), 회전근개 등척성.
- **금기/주의**: 신경 진행 시 의뢰. TOS 인자 평가.
- **한국 임상 선호**: 감별 진단 핵심 — "목인지 어깨인지" 명확.

---

#### 4.3.4 Shoulder × Subacute × 움직임 시 통증
- **임상 패턴**: 2~3주 경과, painful arc 잔존. 머리 위 동작 제한.
- **CPG 권고**: 운동 치료 (scapular stabilization + 회전근개 강화) + 도수 결합. [JOSPT 2020](https://www.jospt.org/doi/10.2519/jospt.2020.8498)
- **Tier 1 권장**:
  - **Maitland**: GH posterior/inferior glide Grade III~IV. Thoracic mobilization 적극.
  - **Mulligan**: MWM 적극, self-MWM 처방.
  - **MFR**: Pec minor (전방 어깨 자세 인자), 회전근개, 상부 승모근.
  - **TrP**: Infraspinatus, supraspinatus, 상부 승모근, levator scapulae.
  - **운동 (neuromuscular + resistance)**: Scapular stabilization (lower trap, serratus anterior — wall slides, scapular Y/T/W), 회전근개 (external rotation with band), 점진 부하.
- **금기/주의**: 진행성 약화 → 의뢰.
- **한국 임상 선호**: 도수 + 운동 결합 표준.

---

#### 4.3.5 Shoulder × Subacute × 안정 시 통증
- **임상 패턴**: 야간통 잔존, 잠자리 자세 어려움.
- **CPG 권고**: Adhesive capsulitis freezing/frozen 단계 가능 — 단계별 접근. [PMC 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC10882424/), [JOSPT 2013](https://www.jospt.org/doi/10.2519/jospt.2013.0302)
- **Tier 1 권장**:
  - **Maitland**: GH inferior/posterior glide Grade II~III, sustained.
  - **Mulligan**: MWM 점진.
  - **MFR**: Pec minor, latissimus.
  - **TrP**: Infraspinatus, subscapularis (deep, careful).
  - **운동 (neuromuscular)**: Pendulum, sleeper stretch (posterior capsule), cross-body stretch, 등척성.
- **금기/주의**: Adhesive capsulitis freezing 단계는 stretch over-aggressive 회피.
- **한국 임상 선호**: 단계별 진행 — "지금은 풀기보다 진정시키는 단계" 환자 교육.

---

#### 4.3.6 Shoulder × Subacute × 방사통
- **임상 패턴**: 신경 증상 잔존. 감별 진행 중.
- **CPG 권고**: 감별 후 multimodal.
- **Tier 1 권장**:
  - **Maitland**: 감별 후 cervical/shoulder.
  - **Mulligan**: SNAG 또는 MWM.
  - **MFR**: 사각근, pec minor.
  - **TrP**: 사각근, infraspinatus.
  - **운동 (neuromuscular)**: Neural mobilization, 회전근개, scapular control.

---

#### 4.3.7 Shoulder × Chronic × 움직임 시 통증
- **임상 패턴**: 만성 (30일+) 어깨 통증. 일상 동작 제한 (옷 입기, 머리 빗기, 뒷주머니). 환자 회피 패턴 강함.
- **CPG 권고**: 만성 — 점진 부하 운동 (강한 권고), 환자 교육, 도수 결합. [JOSPT 2024](https://www.jospt.org/doi/10.2519/jospt.2024.12453). Adhesive capsulitis frozen/thawing 단계 — Maitland Grade III~IV. [PMC 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC10882424/)
- **Tier 1 권장**:
  - **Maitland**: GH Grade III~IV (thawing 단계), inferior/posterior/anterior glide all directions.
  - **Mulligan**: MWM 적극.
  - **MFR**: 광범위 myofascial.
  - **TrP**: 광범위 — infraspinatus, subscapularis, supraspinatus, 상부 승모근, levator scapulae.
  - **운동 (resistance + bodyweight)**: 점진 부하 (탄성밴드 → 덤벨), 기능 동작 (push, pull, overhead). 지구력 운동.
- **금기/주의**: 만성 통증 = 중추감작 가능, KMO 교육.
- **한국 임상 선호**: 만성 어깨 환자 운동 회피 — 점진 노출 + 안전 메시지.

---

#### 4.3.8 Shoulder × Chronic × 안정 시 통증
- **임상 패턴**: 만성 + 야간통 = adhesive capsulitis frozen 단계 또는 중추감작.
- **CPG 권고**: 단계별 + 교육 + 점진 운동.
- **Tier 1 권장**:
  - **Maitland**: Grade III~IV (frozen 단계는 stretch tolerable).
  - **Mulligan**: MWM.
  - **MFR**: Sustained.
  - **TrP**: 신중.
  - **운동 (neuromuscular)**: Stretch (sleeper, cross-body, towel behind back), 등척성, 점진.
- **한국 임상 선호**: "오십견" 환자 — 단계 설명 + 인내 메시지.

---

#### 4.3.9 Shoulder × Chronic × 방사통
- **임상 패턴**: 만성 신경 증상.
- **Tier 1 권장**:
  - **Maitland**: 감별 후.
  - **Mulligan**: SNAG/MWM.
  - **MFR**: 사각근, pec minor.
  - **TrP**: 사각근, infraspinatus, subscapularis.
  - **운동**: Neural mobilization, 회전근개, scapular.

---

### 4.4 Knee (무릎)

#### 4.4.1 Knee × Acute × 움직임 시 통증
- **임상 패턴**: 갑자기 무릎 통증 — 계단 내려갈 때 sharp, 쪼그려 앉기 못함. 외상 (sprain) 또는 과사용. 부종 가능.
- **CPG 권고**: 무릎 OA CPG (강한 권고): 운동 치료 + 환자 교육 + 체중 관리. PFP CPG: hip + knee 운동, 도수 isolation 부적합. [JOSPT 2019 PFP](https://www.jospt.org/doi/10.2519/jospt.2019.0302)
- **Tier 1 권장**:
  - **Maitland**: TF joint mobilization (anterior, posterior glide), patellar mobilization (medial, lateral, superior, inferior glide). Grade I~II.
  - **Mulligan**: Knee MWM (tibial rotation + active flexion/extension). Patellar MWM.
  - **MFR**: 사두근 (특히 vastus lateralis), IT band, 햄스트링.
  - **TrP**: VL TrP (referred to lateral knee), 햄스트링, 비복근.
  - **운동 (neuromuscular)**: 등척성 사두근 (quad set), SLR (straight leg raise), AROM 통증 한계 안.
- **금기/주의**: Red flag — 외상 후 못 디딤 (Ottawa knee rule), 골절 의심, 인대 전체 파열 (Lachman, anterior drawer 양성), 감염 (열감, 발적, 발열) → 의뢰.
- **한국 임상 선호**: 도수 + 운동 결합 표준. PFP CPG는 도수 isolation 비추천 강조.

---

#### 4.4.2 Knee × Acute × 안정 시 통증
- **임상 패턴**: 안정 시에도 욱신, 부종 동반.
- **CPG 권고**: 급성 염증 단계 — RICE + 부드러운 운동 + 환자 교육.
- **Tier 1 권장**:
  - **Maitland**: Grade I 진동 (부종 감소 목적도).
  - **Mulligan**: 급성 reactive 시 보류.
  - **MFR**: 부드러운 sustained — 사두근, 햄스트링.
  - **TrP**: 신중.
  - **운동**: 등척성 quad set, ankle pump (부종 관리).
- **금기/주의**: 부종 + 발적 + 발열 = 감염 의심. 외상 후 = 영상 우선.

---

#### 4.4.3 Knee × Acute × 방사통
- **임상 패턴**: 무릎 + 다리로 방사 — 드물지만 lumbar radiculopathy 또는 신경 문제 의심.
- **CPG 권고**: 감별 — lumbar 인자 평가.
- **Tier 1 권장**:
  - **Maitland**: Lumbar 인자면 lumbar PA. Knee 인자면 TF.
  - **Mulligan**: 감별 후.
  - **MFR**: 햄스트링, 비복근, 이상근.
  - **TrP**: 햄스트링, 비복근.
  - **운동**: Neural mobilization (sciatic), 사두근, 햄스트링.

---

#### 4.4.4 Knee × Subacute × 움직임 시 통증
- **임상 패턴**: 2~3주, 부종 감소, 동작 제한 잔존.
- **CPG 권고**: 운동 + 도수 결합.
- **Tier 1 권장**:
  - **Maitland**: TF mobilization Grade III~IV. Patellar.
  - **Mulligan**: MWM 적극.
  - **MFR**: 사두근, IT band, 햄스트링.
  - **TrP**: VL, 햄스트링.
  - **운동 (neuromuscular + resistance)**: SLR 진행, mini squat (통증 한계 안), step-up, 햄스트링 강화, hip 강화 (gluteus medius — PFP에서 핵심).
- **한국 임상 선호**: hip 강화의 무릎 효과 환자 잘 모름 — 교육 필요.

---

#### 4.4.5 Knee × Subacute × 안정 시 통증
- **임상 패턴**: 안정 시 통증 잔존, 야간 stiff.
- **Tier 1 권장**:
  - **Maitland**: Grade II~III.
  - **Mulligan**: MWM.
  - **MFR**: 사두근, IT band.
  - **TrP**: VL.
  - **운동**: AROM, 등척성, 점진.

---

#### 4.4.6 Knee × Subacute × 방사통
- **Tier 1 권장**:
  - **Maitland**: 감별 후.
  - **Mulligan**: 감별 후.
  - **MFR**: 햄스트링, 비복근.
  - **TrP**: 햄스트링.
  - **운동**: Neural mobilization.

---

#### 4.4.7 Knee × Chronic × 움직임 시 통증
- **임상 패턴**: 만성 무릎 OA 또는 PFP. 계단·쪼그려 앉기 회피. 환자 영상 진단 (퇴행성).
- **CPG 권고**: 무릎 OA CPG — 운동 + 교육 + 체중 관리 (강한 권고). PFP — hip + knee 운동, 도수 isolation 부적합. [JOSPT 2019](https://www.jospt.org/doi/10.2519/jospt.2019.0302)
- **Tier 1 권장**:
  - **Maitland**: TF Grade III~IV. Patellar mobilization.
  - **Mulligan**: MWM 적극, self-MWM.
  - **MFR**: 사두근, IT band, 햄스트링, gastrocnemius.
  - **TrP**: VL, 햄스트링, 비복근.
  - **운동 (neuromuscular + resistance + bodyweight)**: Hip 강화 (gluteus medius, lateral rotators) + knee 강화 (quad, hamstring) 결합. 점진 부하 (squat, lunge, step-up). 유산소 (자전거, 수영). PFP에서 high-volume (3 sets × 30+ reps × 3/week).
- **금기/주의**: KMO — "퇴행성 = 영구 손상 아님" 교육.
- **한국 임상 선호**: "관절이 닳아서" 환자 인식 강함 — KMO 메시지 핵심. 운동 비중 강조.

---

#### 4.4.8 Knee × Chronic × 안정 시 통증
- **임상 패턴**: 만성 + 안정 시 통증 = OA 진행 또는 중추감작.
- **Tier 1 권장**:
  - **Maitland**: Grade III.
  - **Mulligan**: MWM.
  - **MFR**: 광범위.
  - **TrP**: VL, 햄스트링.
  - **운동**: 점진 운동, 유산소 (저충격), 체중 관리 교육.

---

#### 4.4.9 Knee × Chronic × 방사통
- **Tier 1 권장**: 감별 후 lumbar 또는 knee 처방.

---

### 4.5 Hip (엉덩)

#### 4.5.1 Hip × Acute × 움직임 시 통증
- **임상 패턴**: 갑자기 사타구니 또는 외측 엉덩이 통증. 보행 시 절뚝. 외상 또는 과사용.
- **CPG 권고**: Hip OA CPG 2025 — 운동 + 도수 + 환자 교육. [JOSPT 2025](https://www.jospt.org/doi/10.2519/jospt.2025.0301). LADM (long-axis distraction) high-quality evidence. [PMC 2022](https://pmc.ncbi.nlm.nih.gov/articles/PMC9621225/)
- **Tier 1 권장**:
  - **Maitland**: Hip long-axis distraction Grade I~II, lateral distraction, posterior glide. SI joint 평가.
  - **Mulligan**: Hip MWM (lateral glide + active flexion/abduction).
  - **MFR**: 둔근군, 이상근, 고관절 굴곡근, IT band.
  - **TrP**: 이상근, gluteus medius, gluteus minimus, TFL.
  - **운동 (neuromuscular)**: 등척성 둔근 (clam, side-lying abduction), AROM, 통증 한계 내 보행 교정.
- **금기/주의**: Red flag — 외상 후 골절 의심 (특히 노인 + 낙상), avascular necrosis, 종양 → 의뢰.

---

#### 4.5.2 Hip × Acute × 안정 시 통증
- **임상 패턴**: 야간통, 누우면 외측 통증 (greater trochanteric bursitis 의심).
- **Tier 1 권장**:
  - **Maitland**: Grade I~II.
  - **Mulligan**: 보류.
  - **MFR**: Gluteus medius/minimus, TFL.
  - **TrP**: Gluteus medius, TFL.
  - **운동**: 등척성, 자세 교육 (옆으로 누울 때 다리 사이 베개).

---

#### 4.5.3 Hip × Acute × 방사통
- **임상 패턴**: 엉덩이 + 다리 — 이상근 증후군 또는 lumbar radiculopathy 감별.
- **Tier 1 권장**:
  - **Maitland**: Lumbar 인자면 lumbar PA, hip 인자면 hip mobilization.
  - **Mulligan**: SLR-MWM.
  - **MFR**: 이상근.
  - **TrP**: 이상근 적극.
  - **운동**: Neural mobilization, hip 강화.

---

#### 4.5.4 Hip × Subacute × 움직임 시 통증
- **CPG 권고**: Hip OA — 운동 + 도수.
- **Tier 1 권장**:
  - **Maitland**: LADM Grade III~IV.
  - **Mulligan**: MWM 적극.
  - **MFR**: 둔근, 이상근, 굴곡근, IT band.
  - **TrP**: 이상근, gluteus medius.
  - **운동 (neuromuscular + resistance)**: Clam, side-lying abduction, glute bridge, mini squat, lunge.

---

#### 4.5.5 Hip × Subacute × 안정 시 통증
- **Tier 1 권장**:
  - **Maitland**: Grade II~III.
  - **Mulligan**: MWM.
  - **MFR**: Gluteus medius/minimus, TFL.
  - **TrP**: Gluteus medius.
  - **운동**: 점진 강화.

---

#### 4.5.6 Hip × Subacute × 방사통
- **Tier 1 권장**:
  - **Maitland**: 감별 후.
  - **Mulligan**: SLR-MWM.
  - **MFR**: 이상근.
  - **TrP**: 이상근.
  - **운동**: Neural mobilization.

---

#### 4.5.7 Hip × Chronic × 움직임 시 통증
- **임상 패턴**: 만성 hip OA. 보행 제한, 일상 동작 (양말 신기, 차에서 내리기) 어려움. 영상 진단.
- **CPG 권고**: Hip OA CPG 2025 — 운동 (강한 권고) + 도수 + 환자 교육 + 체중 관리. [JOSPT 2025](https://www.jospt.org/doi/10.2519/jospt.2025.0301)
- **Tier 1 권장**:
  - **Maitland**: LADM Grade III~IV (high-force). Posterior/lateral glide.
  - **Mulligan**: MWM 적극.
  - **MFR**: 광범위.
  - **TrP**: 이상근, gluteus medius/minimus, TFL, hip flexors.
  - **운동 (neuromuscular + resistance + bodyweight)**: Hip 강화 (abductors, extensors, rotators), 코어, 점진 부하 (squat, deadlift), 유산소 (자전거, 수영).
- **한국 임상 선호**: 노인 환자 다수 — 안전한 점진 부하 + 낙상 예방 교육.

---

#### 4.5.8 Hip × Chronic × 안정 시 통증
- **Tier 1 권장**:
  - **Maitland**: LADM.
  - **Mulligan**: MWM.
  - **MFR**: 광범위.
  - **TrP**: 광범위.
  - **운동**: 점진, 유산소.

---

#### 4.5.9 Hip × Chronic × 방사통
- **Tier 1 권장**: 감별 후.

---

### 4.6 Ankle (발목)

#### 4.6.1 Ankle × Acute × 움직임 시 통증
- **임상 패턴**: 발목 삐끗 (lateral ankle sprain 흔함, ATFL 손상). 부종, 멍, 체중 부하 시 sharp.
- **CPG 권고**: Lateral Ankle Sprain CPG 2021 — 도수 (graded mobilization, manipulation, MWM) + 운동 (강한 권고). [JOSPT 2021](https://www.jospt.org/doi/10.2519/jospt.2021.0302). MWM (Mulligan) 효과 evidence. [PMC 2020](https://pmc.ncbi.nlm.nih.gov/articles/PMC6973758/)
- **Tier 1 권장**:
  - **Maitland**: Talocrural anterior/posterior glide, subtalar mobilization. Grade I~II.
  - **Mulligan**: Fibula MWM (posterior glide of distal fibula + active dorsiflexion). 핵심 권고.
  - **MFR**: 비복근, soleus, 비골근군.
  - **TrP**: 비골근, 비복근.
  - **운동 (neuromuscular)**: 등척성 dorsiflexion/eversion, AROM, 부종 관리 (RICE).
- **금기/주의**: Red flag — 외상 후 못 디딤 (Ottawa ankle rule), 골절 의심 → 영상.
- **한국 임상 선호**: Mulligan MWM 강력 권고 (CPG 명시) — 즉시 효과.

---

#### 4.6.2 Ankle × Acute × 안정 시 통증
- **Tier 1 권장**:
  - **Maitland**: Grade I.
  - **Mulligan**: 보류.
  - **MFR**: 부드러운.
  - **TrP**: 신중.
  - **운동**: RICE, 등척성.

---

#### 4.6.3 Ankle × Acute × 방사통
- **임상 패턴**: 드뭄. 비골 신경 자극 가능 (sprain 후 traction injury).
- **Tier 1 권장**:
  - **Maitland**: Grade I~II 감별 후.
  - **Mulligan**: MWM 신중.
  - **MFR**: 비골근.
  - **TrP**: 비골근.
  - **운동**: Neural mobilization (peroneal, tibial).

---

#### 4.6.4 Ankle × Subacute × 움직임 시 통증
- **CPG 권고**: 도수 + 운동. [JOSPT 2021](https://www.jospt.org/doi/10.2519/jospt.2021.0302)
- **Tier 1 권장**:
  - **Maitland**: Talocrural Grade III~IV (특히 dorsiflexion 제한).
  - **Mulligan**: MWM 적극, weight-bearing MWM.
  - **MFR**: 비복근, soleus, 비골근.
  - **TrP**: 비복근, 비골근.
  - **운동 (neuromuscular + resistance)**: 균형 운동 (BAPS, 한 발 서기), 등척성 → 등장성, calf raise, eversion 강화 (band).

---

#### 4.6.5 Ankle × Subacute × 안정 시 통증
- **Tier 1 권장**:
  - **Maitland**: Grade II~III.
  - **Mulligan**: MWM.
  - **MFR**: 비복근.
  - **TrP**: 비복근.
  - **운동**: 점진 강화.

---

#### 4.6.6 Ankle × Subacute × 방사통
- **Tier 1 권장**:
  - **Maitland**: 감별 후.
  - **Mulligan**: MWM.
  - **MFR**: 비골근.
  - **TrP**: 비골근.
  - **운동**: Neural mobilization.

---

#### 4.6.7 Ankle × Chronic × 움직임 시 통증
- **임상 패턴**: Chronic ankle instability (CAI). 반복 sprain, 균형 어려움, 운동 회피.
- **CPG 권고**: CPG 2021 — 도수 + 균형 운동 + 점진 부하 (강한 권고). [JOSPT 2021](https://www.jospt.org/doi/10.2519/jospt.2021.0302)
- **Tier 1 권장**:
  - **Maitland**: Talocrural Grade III~IV, subtalar.
  - **Mulligan**: MWM 적극, weight-bearing MWM.
  - **MFR**: 광범위.
  - **TrP**: 비골근, 비복근, soleus.
  - **운동 (neuromuscular + resistance + bodyweight)**: 균형 progression (eyes open → closed, firm → unstable), proprioceptive (BOSU, wobble board), 비골근 강화, 점진 운동 복귀 (jogging, jumping).

---

#### 4.6.8 Ankle × Chronic × 안정 시 통증
- **Tier 1 권장**:
  - **Maitland**: Grade III.
  - **Mulligan**: MWM.
  - **MFR**: 광범위.
  - **TrP**: 비복근.
  - **운동**: 점진.

---

#### 4.6.9 Ankle × Chronic × 방사통
- **Tier 1 권장**: 감별 후 (lumbar 또는 peripheral nerve).

---

## 5. 주요 패턴 인사이트

### 5.1 Acuity별 공통 원칙

| Acuity | 도수 강도 | 운동 비중 | 환자 교육 핵심 |
|---|---|---|---|
| **Acute** | Grade I~II 부드럽게 | 통증 한계 내 등척성·AROM | "통증 = 위험 신호 아님 (대부분)", red flag 스크리닝 |
| **Subacute** | Grade III~IV 적극 | 신경근 조절 + 점진 저항 | "조직 회복 중, 부드럽게 부하 주기" |
| **Chronic** | 도수는 도구, 운동 비중↑ | 점진 부하 + 기능 동작 + 유산소 | "통증 ≠ 손상", PNE, 점진 노출, 운동 회피 깨기 |

### 5.2 Pain Condition별 공통 원칙

| Pain Condition | 도수 접근 | 운동 접근 | 주의 |
|---|---|---|---|
| **움직임 시 통증** | 통증 한계 내 진동 → 한계 너머 점진 | 통증 한계 안 등척성 → 등장성 진행 | 패턴 매칭 도수 (제한 방향 명확) |
| **안정 시 통증** | 부드러운 진정 (Grade I), 자극 회피 | 자세 교육·이완 우선 | Red flag 적극 스크리닝 (야간통·체중감소) |
| **방사통** | 신경 부하 회피, contralateral 우선 | Neural mobilization (slider → tensioner) | 진행성 신경 약화 = 즉시 의뢰 |

### 5.3 부위별 Tier 1 적합도

| 부위 | Maitland | Mulligan | MFR | TrP | 운동 처방 비중 |
|---|---|---|---|---|---|
| **Cervical** | 강 | 강 (SNAG 효과 강) | 중 | 중 | 중 (CCFT 필수) |
| **Lumbar** | 강 | 강 (SNAG·SLR-MWM) | 강 (QL, 다열근) | 강 (QL, 이상근) | 강 (motor control) |
| **Shoulder** | 강 (GH inferior/posterior) | 강 (MWM 즉시 효과) | 중 (pec minor) | 강 (회전근개 referred) | 강 (scapular + 회전근개) |
| **Knee** | 중 (TF, patellar) | 중 (MWM) | 중 (사두근) | 중 (VL, 햄스트링) | **강 (PFP CPG: 도수 isolation 부적합)** |
| **Hip** | 강 (LADM high evidence) | 중 (MWM) | 중 (둔근) | 중 (이상근) | 강 |
| **Ankle** | 중 (TF dorsiflexion) | **강 (MWM CPG strong)** | 중 (비복근) | 중 (비골근) | 강 (균형 핵심) |

### 5.4 한국 시장 현실 vs CPG 갭

| 한국 현실 | CPG/Evidence | 대응 |
|---|---|---|
| 환자 "한 번에 풀어달라" — Mulligan 즉시 효과 압도적 선호 | CPG 동의 (acute neck/ankle: MWM 강한 근거) | Mulligan 적극 활용 OK, 단 운동 결합 필수 |
| 도수만 받고 운동 안 함 ("도수 = 치료") | 운동은 모든 부위 강한 권고 | 도수는 "수단", 자가 운동 처방 강조 |
| 트랙션 (특히 cervical/lumbar) 환자 선호 | 단독 효과 약함, multimodal에서 보조 역할 | 트랙션은 도수+운동 결합에서 보조 |
| TrP 직접 압박 ("뭉친 거 풀어달라") 환자 친숙 | 효과 controversial — 단순 누름 ≠ 임상 적합 | TrP는 환자 패턴 재현 시 적용, 자가 도구 처방 |
| "디스크/퇴행성" 진단 환자 수술 두려움 | 대부분 conservative care = surgery 효과 동등 | KMO 메시지: "통증 ≠ 영구 손상" |
| 운동 = "도수 후 숙제" 인식 | 운동 = 일차 치료 (특히 chronic) | 도수 + 운동 동등 비중 처방 |
| PFP 환자 무릎 도수 요구 | CPG: 도수 isolation 부적합 | hip 강화 효과 환자 교육 |

### 5.5 Tier 1 부적합 시나리오 (절대 또는 상대 금기)

| 상황 | Tier 1 부적합 이유 | 대응 |
|---|---|---|
| 외상 직후 (특히 cervical) | 골절·인대 파열 가능, 영상 우선 | 의뢰 |
| Cervical manipulation + VBI 의심 | 동맥 박리 위험 | manipulation 절대 금기, mobilization 신중 |
| Cauda equina 증상 (lumbar) | 응급 외과 적응증 | 즉시 의뢰 |
| 진행성 운동 약화 (cervical/lumbar 방사통) | 신경 손상 진행 | 즉시 의뢰 |
| 종양·감염·골절 의심 | 비기계적 통증 (야간통+체중감소+발열) | 의뢰 |
| 급성 reactive (강한 안정 시 통증) | Mulligan SNAG/MWM 자극 가능 | Maitland Grade I만, 진정 우선 |
| 급성 방사통 + 동측 압박 | 신경 자극 악화 | Contralateral 또는 indirect 접근 |
| PFP 환자 단독 도수 | 효과 약함, hip+knee 운동 우선 | 운동 + 도수 결합 |

---

## 6. 추천 시스템 큐레이션 시사점

### 6.1 80개 큐레이션 → Tier 1 카테고리 비중 가이드

54 시나리오 매트릭스 기준 권장 큐레이션 분포:

| 카테고리 | 권장 큐레이션 수 | 우선 시나리오 |
|---|---|---|
| **Maitland (Joint Mob)** | ~20 | 6 부위 × acuity 3 단계 = 18 + alpha. 모든 부위 적용. |
| **Mulligan** | ~15 | Cervical SNAG (acute/subacute), Shoulder MWM, Ankle MWM (CPG 명시), Lumbar SNAG/SLR-MWM. |
| **MFR** | ~12 | Lumbar (QL), Cervical (후두하·승모근), Shoulder (pec minor), Hip (둔근·이상근). |
| **Trigger Point** | ~13 | 부위별 흔한 TrP — 상부 승모근, QL, 이상근, infraspinatus, VL, 비골근. |
| **운동 처방 (3 categories)** | ~20 | 모든 부위 × acuity. 신경근 (acute/subacute) → 저항/체중부하 (subacute/chronic). |

### 6.2 시나리오별 우선 기법 식별 (큐레이션 매핑)

각 셀(부위 × acuity × pain condition)에 대해:
- **1차 권장**: CPG 강한 권고 + 한국 임상 선호 — 최우선 큐레이션 매칭.
- **2차 권장**: 보조 기법 (다른 카테고리에서 1개씩) — "다른 기법 보기" 보강.
- **금기 명시**: 절대/상대 금기 시나리오 명확.

### 6.3 "다른 기법 보기" 보강 원칙

- 같은 시나리오에서 **다른 그룹의 차선책**을 명시.
  - 예: Cervical Acute × 움직임 시 통증 → 1차 SNAG, 2차 Maitland PA, 3차 상부 승모근 MFR, 운동 CCFT.
- 환자 거부감/선호 반영 (예: "뚝 소리" 거부 → SNAG 대신 Maitland Grade III 진동).

### 6.4 LLM 검색 대비 차별화 핵심

| LLM 검색 | 본 시스템 |
|---|---|
| "neck pain mobilization" — 일반론 | "Cervical × Acute × 움직임 시 통증 → SNAG (즉시 효과) + 흉추 manipulation + CCFT 등척성" — 즉시 적용 |
| 출처 흩어짐 | CPG + 한국 임상 컨텍스트 통합 |
| 환자 표현 → 임상 표현 변환 부담 | 환자 패턴 묘사 → 곧바로 처방 |
| 금기 검색 별도 | 시나리오별 red flag·금기 함께 |

---

## 7. 인용·참고 문헌

### 7.1 APTA Clinical Practice Guidelines
- **Neck Pain Revision 2017**: Blanpied PR, et al. *JOSPT* 2017;47(7):A1-A83. [DOI:10.2519/jospt.2017.0302](https://www.jospt.org/doi/10.2519/jospt.2017.0302)
- **Low Back Pain Revision 2021**: George SZ, et al. *JOSPT* 2021;51(11):CPG1-CPG60. [DOI:10.2519/jospt.2021.0304](https://www.jospt.org/doi/10.2519/jospt.2021.0304)
- **Hip Pain and Mobility Deficits — Hip OA Revision 2025**: *JOSPT* 2025;55(11). [DOI:10.2519/jospt.2025.0301](https://www.jospt.org/doi/10.2519/jospt.2025.0301)
- **Knee Pain and Mobility Impairments 2018** + Knee OA 2nd Ed CPG: [orthopt.org PDF](https://www.orthopt.org/uploads/content_files/files/Knee%20pain%20and%20mobility%20impairments%202018.pdf)
- **Patellofemoral Pain CPG 2019**: Willy RW, et al. *JOSPT* 2019;49(9):CPG1-CPG95. [DOI:10.2519/jospt.2019.0302](https://www.jospt.org/doi/10.2519/jospt.2019.0302)
- **Shoulder Adhesive Capsulitis CPG 2013** (rev pending): Kelley MJ, et al. *JOSPT* 2013;43(5):A1-A31. [DOI:10.2519/jospt.2013.0302](https://www.jospt.org/doi/10.2519/jospt.2013.0302)
- **Subacromial Shoulder Pain Update**: *JOSPT* 2020. [DOI:10.2519/jospt.2020.8498](https://www.jospt.org/doi/10.2519/jospt.2020.8498)
- **Rotator Cuff Tendinopathy CPG 2025**: *JOSPT* 2025. [DOI:10.2519/jospt.2025.13182](https://www.jospt.org/doi/10.2519/jospt.2025.13182)
- **Lateral Ankle Ligament Sprains Revision 2021**: Martin RL, et al. *JOSPT* 2021;51(4):CPG1-CPG80. [DOI:10.2519/jospt.2021.0302](https://www.jospt.org/doi/10.2519/jospt.2021.0302)

### 7.2 시스템 리뷰 / Cochrane / RCT
- **Manual Therapy in Cervical and Lumbar Radiculopathy SR**: *Int J Environ Res Public Health* 2021. [PMC8201115](https://pmc.ncbi.nlm.nih.gov/articles/PMC8201115/)
- **Mulligan's Techniques in Non-Specific Neck Pain SR&MA**: 2025. [PMC12121345](https://pmc.ncbi.nlm.nih.gov/articles/PMC12121345/)
- **Manual Therapy and Exercise for Adhesive Capsulitis**: 2024. [PMC10882424](https://pmc.ncbi.nlm.nih.gov/articles/PMC10882424/)
- **Hip OA Manual Therapy Dosing SR**: 2022. [PMC9621225](https://pmc.ncbi.nlm.nih.gov/articles/PMC9621225/)
- **Mulligan Concept Lateral Ankle Sprain Case Series**: 2020. [PMC6973758](https://pmc.ncbi.nlm.nih.gov/articles/PMC6973758/)
- **McKenzie vs Motor Control Exercise (chronic LBP, directional preference)**: *JOSPT* 2016. [DOI:10.2519/jospt.2016.6379](https://www.jospt.org/doi/10.2519/jospt.2016.6379)
- **Scapular Stabilization SR&MA (Subacromial Pain)**: 2024. [Frontiers Neurology](https://www.frontiersin.org/journals/neurology/articles/10.3389/fneur.2024.1357763/full)
- **Hip Strengthening for PFP Meta-analysis**: *JOSPT* 2018. [DOI:10.2519/jospt.2018.7365](https://www.jospt.org/doi/10.2519/jospt.2018.7365)
- **Neural Mobilization in LBP and Radicular Pain SR**: 2023. [PMC9848316](https://pmc.ncbi.nlm.nih.gov/articles/PMC9848316/)

### 7.3 한국 정형도수물리치료학회 (KAOMPT)
- **KAOMPT (대한정형도수물리치료학회)**: IFOMPT/WCPT 회원. Maitland·Mulligan 번역·교육 활동. [kamompt.org](https://kamompt.org/page/2543/5156.tc)
- **대한정형도수물리치료학회지**: KCI 등재. [KCI Portal](https://www.kci.go.kr/kciportal/landing/journalHome.kci?sere_id=SER000005084)
- **도수치료의 최신 지견**: *JKOA* 2024;59(4):277. [DOI](https://jkoa.org/DOIx.php?id=10.4055/jkoa.2024.59.4.277)

### 7.4 안전·금기 (Cervical Arterial Dysfunction)
- **CAD: Knowledge and Reasoning for Manual PT**: Kerry R, Taylor AJ. *JOSPT* 2009. [DOI:10.2519/jospt.2009.2926](https://www.jospt.org/doi/10.2519/jospt.2009.2926)
- **APA Clinical Guide to Safe Manual Therapy in Cervical Spine 2017**: [Physiopedia summary](https://www.physio-pedia.com/APA_Clinical_guide_to_safe_manual_therapy_practice_in_the_cervical_spine_2017)

### 7.5 통증 신경과학 / 중추감작
- **Recognition and Treatment of Central Sensitization**: Nijs J, et al. *JOSPT* 2016. [DOI:10.2519/jospt.2016.0612](https://www.jospt.org/doi/10.2519/jospt.2016.0612)
- **Greg Lehman — Recovery Strategies**: KMO 철학 기반 ("Calm things down, build things back up").

---

## 8. 한계·확인 필요 사항

1. **CPG 일부 영문 원문**: 한국 임상 적용 시 표현·문화 차이 가능. KAOMPT 한글 자료 보완 필요.
2. **Subacute 정의 변동**: APTA/IFOMPT가 acute/subacute/chronic 구분 7일 vs 6주 vs 12주 등 가이드라인마다 다름. 본 매트릭스는 0-7일 / 7-30일 / 30일+ 운영적 구분 사용.
3. **Tier 1 카테고리 외 기법** (예: 침술, IASTM, 근막 hooking, CMT/HVLA 외 manipulation 변형) 본 문서 범위 외 — 별도 Tier 2/3 큐레이션 필요.
4. **개별 환자 특성 (연령·동반질환·심리상태)**: 본 매트릭스는 일반 권장. 임상가 판단으로 조정 필수. 노인 골다공증·연부조직 취약, 임산부, 항응고제 복용 등 별도 고려.
5. **한국 보험 수가 / 도수치료 운영 현실**: 도수치료 실손 청구 환경, 시간 제약 등 시스템 외 인자 — 별도 운영 매뉴얼 필요.
6. **Methods 인용 정확도**: 일부 CPG 권고 강도(strong/conditional/against)는 가이드라인 원문 직접 확인 권장. 본 문서는 시스템 리뷰/요약 기반.
7. **Pain Condition 중첩**: 실제 환자는 "움직임+안정 시 통증" 동반 흔함 — 본 매트릭스는 우세 양상 기준. 임상가 우세 양상 판단.
8. **운동 처방 dosage**: 본 문서는 기법·접근 수준. 구체적 set/rep/주기는 부위·환자별 상이 — 별도 dosage 가이드 필요.

---

> **다음 단계 (sw-product-manager / sw-frontend-dev 협업 필요)**:
> 1. 80개 큐레이션 셀(54 시나리오 × Tier 1) 매핑 — 각 셀 1차/2차 권장 기법 명확.
> 2. 큐레이션 부족 셀 식별 → 추가 큐레이션 작성 우선순위.
> 3. 추천 시스템 UI: 환자 패턴 묘사 → 즉시 적용 가능한 처방 (도수 + 운동) 동시 표시.
> 4. KMO 메시지 톤 전체 일관성 검토.
