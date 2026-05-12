// ─────────────────────────────────────────────────────────────────────────────
// _scenario-matrix.js — 3축 × Tier 1 카테고리 임상 권장 매트릭스 (54 시나리오)
//
// 출처: docs/clinical-3axis-tier1-recommendation-research-2026-05-06.md
// 작성: sw-clinical-translator (2026-05-06) → 본 파일은 sw-backend-dev 가
//       LLM 프롬프트 augmentation 용도로 압축·구조화 (2026-05-12, Item 4)
//
// 축:
//   - 부위 (region):   경추 / 요추 / 어깨 관절 / 무릎 관절 / 엉덩 관절 / 발목 관절
//   - 급성도 (acuity): 급성 (0~7일) / 아급성 (7~30일) / 만성 (30일+)
//   - 통증 양상 (sym): 움직임 시 통증 / 안정 시 통증 / 방사통
//
// 셀 (6 × 3 × 3 = 54) 마다:
//   { cpg, maitland, mulligan, mfr, trp, exercise, cautions, kmo }
//
// 각 셀은 docs Section 4 의 핵심 1~2줄 압축. KMO 철학 위반 표현 회피.
// ─────────────────────────────────────────────────────────────────────────────

// 공통 KMO 메시지 (acuity 단위)
export const KMO_BY_ACUITY = {
  '급성':
    '통증은 위험 신호가 아닌 보호 반응일 수 있습니다. 조직이 진정될 시간을 주면서 통증 한계 안에서 부드러운 움직임을 시작합니다 (Calm things down).',
  '아급성':
    '조직은 회복 중이고 적응적입니다. 부드러운 부하를 점진적으로 늘리며 신뢰감 있는 움직임 경험을 쌓아갑니다.',
  '만성':
    '통증 ≠ 손상. 영상 소견(디스크·퇴행성)이 곧 영구 손상을 의미하지 않습니다. 점진 노출과 일상 활동 회복이 핵심이며, 환자 자기 효능감 회복이 가장 중요합니다 (Build things back up).',
};

// ── 6 부위 × 9 시나리오 (3 acuity × 3 sym) ───────────────────────────────────
// 모든 문자열은 한국 임상가에게 즉시 활용 가능한 1~2줄 요약.
// "Grade I~II" 등 강도는 docs 원문과 일치.

export const MATRIX = {
  '경추': {
    '급성': {
      '움직임 시 통증': {
        cpg: 'APTA Neck Pain CPG 2017 — Acute neck pain with mobility deficits → cervical+thoracic mobilization/manipulation + ROM 운동 (강한 권고).',
        maitland: 'C2–C7 PA central/unilateral Grade I~II 진동, 통증 한계 안. 흉추 PA Grade III~IV 결합.',
        mulligan: 'SNAG (회전 제한측 articular pillar lateral glide + 환자 능동 회전). 즉시 ROM 회복 체감 강함.',
        mfr: '상부 승모근, 견갑거근 부드러운 release. 짧고 부드럽게.',
        trp: '상부 승모근 TrP 저강도 압박. 통증 강하면 회피.',
        exercise: '등척성 deep neck flexor 활성화 (chin tuck) 10회 × 10초. 능동 ROM 통증 한계까지.',
        cautions: '외상 후 (whiplash 의심 시 영상 우선), VBI 증상 (어지럼·복시·구음장애), 야간통+체중감소 시 의뢰.',
        kmo: '"잠을 잘못 잤다" 패턴 — 대부분 며칠 안에 호전됩니다. "뚝 소리" 거부 환자에게는 Maitland Grade III 진동으로 대체.',
      },
      '안정 시 통증': {
        cpg: 'APTA Neck Pain CPG 2017 — 안정 시 통증 동반은 irritable presentation → 자극 최소 + 환자 교육 + 자세 조언.',
        maitland: 'Grade I 진동만 (진정 목적). 통증 유발 자세 회피. C0/C1 부드러운 distraction 가능.',
        mulligan: '급성 안정 시 통증은 SNAG 부적합 (자극 가능). 아급성 진입 후 도입.',
        mfr: '후두하근, 상부 승모근 sustained pressure 60~90초, 호흡 동조.',
        trp: '후두하 TrP 가능하나 직접 압박 회피. 저강도만.',
        exercise: '베개 조정 교육 (목 중립). 등척성 chin tuck 누운 자세에서 가볍게.',
        cautions: '야간통+진행성+비기계적 통증 (체중감소·발열·신경 증상) 시 의뢰. 안정 시 통증+점진 악화는 영상 우선.',
        kmo: '"센 도수" 요구 환자도 점진 접근이 안전합니다. 수면 자세·베개 교육으로 자기 관리 동기 부여.',
      },
      '방사통': {
        cpg: 'APTA Neck Pain CPG 2017 — Acute radiating pain → cervical traction (mechanical intermittent), cervicothoracic mobilization, neural mobilization.',
        maitland: 'Contralateral C-spine PA Grade I~II (증상측 신경 부하 회피). 흉추 T1-T4 mobilization Grade III~IV.',
        mulligan: 'SNAG (대측 articular pillar) 통증 한계 내. 즉시 통증 감소 시 양호 신호, 악화 시 중단.',
        mfr: '사각근 (TOS 감별 후) 부드러운 release, 상부 승모근.',
        trp: '사각근 TrP — 신경 자극 우려, sustained pressure만 부드럽게.',
        exercise: 'Neural slider (median nerve glide) 통증 한계 안. Deep neck flexor 등척성. 통증 유발 자세 회피.',
        cautions: '진행성 신경 증상 (근력 감소·반사 소실·myelopathy 징후), 양측 증상, 보행 장애 시 즉시 의뢰. Cervical manipulation 신중. VBI 시 절대 금기.',
        kmo: '"신경 눌렸다"는 환자 표현 → "신경 자극이 가라앉을 수 있도록 도와드리는 단계"로 안내. 트랙션은 보조 역할.',
      },
    },
    '아급성': {
      '움직임 시 통증': {
        cpg: 'APTA Neck Pain CPG 2017 — Subacute → cervical/thoracic manipulation/mobilization + SNAG self-treatment + 신경근 운동 (강한 권고).',
        maitland: 'PA Grade III~IV (한계 너머 진동). Unilateral PA 패턴 매칭. 흉추 manipulation 적극 결합.',
        mulligan: 'SNAG self-treatment 처방 (수건·벨트 자가 SNAG). MWM 적극.',
        mfr: '사각근, 상부 승모근, 후두하근, 흉근 (pec minor) 적극 release.',
        trp: '상부 승모근, 견갑거근 직접 압박. 자가 도구 (lacrosse ball) 처방.',
        exercise: 'CCFT 진행, scapular setting (lower/mid trap), 흉추 신전 (foam roller). 등척성 → 등장성.',
        cautions: 'red flag 스크리닝 유지 (체중감소·야간통·진행성 신경 증상).',
        kmo: '"도수 받고 끝" 인식 깨기 — 자가 운동 처방을 동등 비중으로 강조.',
      },
      '안정 시 통증': {
        cpg: 'APTA Neck Pain CPG 2017 — 자세·생활습관 인자 평가 + multimodal care + ergonomic 교육.',
        maitland: 'PA Grade II~III sustained mobilization. 환자 편안한 자세에서.',
        mulligan: 'SNAG 가능. 환자 반응 모니터.',
        mfr: '후두하근·상부 승모근 sustained 60~120초. Pec minor (전방 머리자세 인자).',
        trp: '후두하 TrP 적극 — 안정 시 통증 패턴과 매칭 잦음. 압박 후 신장.',
        exercise: '자세 교정 (도복부 활성화, 흉추 신전). 베개·책상 환경 교육.',
        cautions: '안정 시 통증 + 진행 = red flag 재평가.',
        kmo: '사무직 환자 다수 — 자세 교육 + 도수 + 자가 운동 패키지가 표준.',
      },
      '방사통': {
        cpg: 'APTA Neck Pain CPG 2017 — multimodal: manipulation/mobilization + neural mobilization + traction (선택) + 운동.',
        maitland: 'C-spine PA + 흉추 mobilization 적극. 통증 한계 내 점진 진행.',
        mulligan: 'SNAG with arm position (증상 비재현 자세). 효과 있으면 self-SNAG 처방.',
        mfr: '사각근 (TOS 인자 평가 후), 흉근, 상부 승모근.',
        trp: '사각근 TrP — 방사 패턴 재현 시 적극 치료.',
        exercise: 'Neural mobilization (slider → tensioner 점진), deep neck flexor, scapular control.',
        cautions: '신경 증상 진행 시 즉시 의뢰. Manipulation 신중, mobilization 우선.',
        kmo: '트랙션 + 도수 + 운동 결합이 한국 임상 표준. "디스크 = 영구"가 아님을 일관되게 전달.',
      },
    },
    '만성': {
      '움직임 시 통증': {
        cpg: 'APTA Neck Pain CPG 2017 — Chronic neck pain → multimodal: thoracic+cervical manipulation/mobilization + mixed exercises (coordination/proprioception/strengthening/aerobic) + 인지 정서 요소.',
        maitland: 'PA Grade IV 적극, 흉추 manipulation 결합. 패턴 매칭 정확.',
        mulligan: 'SNAG, self-SNAG 처방. MWM 적극.',
        mfr: '후두하·상부 승모근·견갑거근·사각근·흉근 — 만성 광범위 myofascial 인자.',
        trp: '상부 승모근, 견갑거근 적극. 환자 자가 도구 처방.',
        exercise: '체계적 점진: CCFT → 표재 굴곡근 → 신전근 → 회전근. Scapular control. 유산소 (걷기·자전거) 결합.',
        cautions: '중추감작 가능 — 환자 교육 (PNE) 핵심.',
        kmo: '도수 의존 경향 환자에게 "도수는 도구, 결국 본인 운동" 메시지를 단계적으로 전달.',
      },
      '안정 시 통증': {
        cpg: 'JOSPT 2016 통증 신경과학 교육 (PNE) + 점진 운동 + 다학제 접근.',
        maitland: 'Grade I~II 진정 목적 (만성에서도 자극 회피).',
        mulligan: '효과 있으면 사용, 환자 반응 우선.',
        mfr: '부드러운 sustained — 진정·이완 효과. 호흡·이완 결합.',
        trp: '만성 다발 TrP — 신중. 압박 시간·강도 모두 부드럽게.',
        exercise: '점진 노출 (graded exposure), 일상 활동 회복 우선. 유산소 강조.',
        cautions: '도수 단독으로 해결 어려운 단계 — PNE 결합 권장. 우울·불안 동반 시 다학제 의뢰.',
        kmo: '"약 + 도수" 기대 환자 → 운동·교육 비중을 점진적으로 높이는 전환 필요.',
      },
      '방사통': {
        cpg: 'APTA Neck Pain CPG 2017 — chronic radiating → manual therapy + neural mobilization + 운동. Conservative care가 surgery와 효과 동등 (대부분 케이스).',
        maitland: 'PA Grade III~IV (한계 너머). 흉추 manipulation 결합.',
        mulligan: 'SNAG + arm position 적극.',
        mfr: '사각근, 흉근, 상부 승모근.',
        trp: '사각근 TrP 적극.',
        exercise: 'Neural mobilization (tensioner), scapular control, 어깨 강화 (rotator cuff, scapular retractors).',
        cautions: '신경 손상 진행 (근력·반사·감각) 시 의뢰. Manipulation 신중.',
        kmo: '"디스크 = 손상 = 영구"는 사실이 아닙니다. 운동 비중을 강조하고 자기 효능감 회복.',
      },
    },
  },

  '요추': {
    '급성': {
      '움직임 시 통증': {
        cpg: 'APTA Low Back Pain CPG 2021 — Acute LBP → thrust 또는 non-thrust joint mobilization (강한 권고) + 운동 + 환자 교육.',
        maitland: 'Lumbar PA central/unilateral Grade I~II (자극 회피), Grade III 점진. SI joint 평가. Side-lying lumbar rotation 부드럽게.',
        mulligan: 'Lumbar SNAG — 굴곡·신전 제한 패턴. SLR-MWM (방사통 동반 시).',
        mfr: 'QL, 다열근, 흉요추 근막. 부드러운 sustained.',
        trp: 'QL TrP — acute 방사 패턴. 압박 시 재현 → 양성. 강도 조절.',
        exercise: '통증 한계 내 AROM, walking, 등척성 코어 (TrA 활성화). McKenzie directional preference 평가.',
        cautions: '외상, 야간통, 발열, 체중감소, cauda equina 증상 (방광·항문 마비, saddle anesthesia), 진행성 신경 증상 시 즉시 의뢰.',
        kmo: '"허리 삐끗" 표현 — 대부분 빠르게 회복합니다. 도수 + 운동 + 자세 교육 패키지로 안내.',
      },
      '안정 시 통증': {
        cpg: 'APTA LBP CPG 2021 — irritable presentation → 자극 회피 + 환자 교육 + 부드러운 운동.',
        maitland: 'Grade I 진동만, sustained pressure 회피. Side-lying neutral position.',
        mulligan: '급성 안정 시 통증 SNAG 보류, reactive면 부적합.',
        mfr: 'QL, 다열근, 광배근 부드러운 sustained (호흡 동조).',
        trp: 'QL TrP — 부드럽게. 자극 시 회피.',
        exercise: '통증 한계 내 deep breathing, gentle pelvic tilt, knee-to-chest (편안한 자세 찾기).',
        cautions: '야간통+비기계적 통증 시 의뢰 우선. cauda equina 스크리닝 필수.',
        kmo: '"자고 일어나도 안 풀려" — 자세·매트리스 교육 + 부드러운 도수로 진정.',
      },
      '방사통': {
        cpg: 'APTA LBP CPG 2021 — acute LBP with radiating pain → thrust mobilization (moderate evidence) + 신경 mobilization + McKenzie.',
        maitland: 'Lumbar PA contralateral 측 (증상측 신경 부하 회피) Grade I~II. Side-lying lumbar rotation 신중.',
        mulligan: 'SLR-MWM (bent leg raise) 통증 한계 안. Lumbar SNAG 가능.',
        mfr: '이상근 (sciatic 자극 인자), QL, 다열근. 직접 sciatic 압박 회피.',
        trp: '이상근 TrP — 방사 패턴 재현 시 양성, 신중 압박.',
        exercise: '신경 mobilization (slider), McKenzie REIL — directional preference 평가 후. centralization 관찰.',
        cautions: '진행성 운동 약화 (foot drop), cauda equina (방광·항문), 양측 증상 시 즉시 의뢰. Manipulation 신중.',
        kmo: '"디스크" 인식이 강한 환자에게 "디스크 ≠ 영구 손상", "신경 자극은 가라앉을 수 있다"를 일관 전달.',
      },
    },
    '아급성': {
      '움직임 시 통증': {
        cpg: 'APTA LBP CPG 2021 — subacute → exercise + manipulation/mobilization + 환자 교육.',
        maitland: 'PA Grade III~IV. Lumbar manipulation (HVLA) 환자 거부감 없으면 적극.',
        mulligan: 'SNAG, self-SNAG 처방.',
        mfr: 'QL, 다열근, 광배근, 흉요추 근막 적극.',
        trp: 'QL, 다열근 TrP 적극.',
        exercise: '코어 (TrA, 다열근), McKenzie (directional preference 매칭), bird-dog, dead-bug, hip hinge 교육.',
        cautions: 'red flag 스크리닝 유지.',
        kmo: '도수 + 운동 + 자세 교육 표준. 만성화 예방 메시지 일관.',
      },
      '안정 시 통증': {
        cpg: 'APTA LBP CPG 2021 — multimodal + 환자 교육 + 자세·생활습관.',
        maitland: 'PA Grade II~III. SI joint 평가.',
        mulligan: 'SNAG.',
        mfr: 'QL, 광배근. Sustained pressure.',
        trp: 'QL, 다열근.',
        exercise: '자세 교정 (neutral spine), 골반 mobility (cat-camel), 활동 휴식 사이클.',
        cautions: '야간통+진행 시 red flag 재평가.',
        kmo: '사무직 환자 흔함 — 책상 환경 교육 + 도수 + 운동.',
      },
      '방사통': {
        cpg: 'APTA LBP CPG 2021 — subacute radiating → neural mobilization + manipulation/mobilization + McKenzie. Cochrane: lower-quarter neural mobilization 권장.',
        maitland: 'Lumbar PA + manipulation 점진. centralization 추적.',
        mulligan: 'SLR-MWM, Lumbar SNAG.',
        mfr: '이상근, QL, 햄스트링 myofascial. Sciatic 직접 압박 회피.',
        trp: '이상근, 둔근.',
        exercise: 'Neural mobilization (slider → tensioner), McKenzie, 코어, 둔근 강화.',
        cautions: '진행성 신경 약화 시 의뢰.',
        kmo: '트랙션 + 도수 + 운동 결합이 한국 임상 표준.',
      },
    },
    '만성': {
      '움직임 시 통증': {
        cpg: 'APTA LBP CPG 2021 — Chronic LBP → motor control exercise + manipulation/mobilization + 환자 교육 (강한 권고). McKenzie chronic LBP with directional preference 효과.',
        maitland: 'PA Grade III~IV. Manipulation.',
        mulligan: 'SNAG, self-SNAG.',
        mfr: '광범위 — QL, 광배근, 흉요추, 둔근.',
        trp: 'QL, 다열근, 둔근, 이상근.',
        exercise: 'Motor control, McKenzie, 점진 부하 (deadlift hip hinge 교육), 유산소 (걷기·수영). 점진 노출.',
        cautions: '중추감작 가능 — KMO 교육 핵심.',
        kmo: '"디스크 환자" 자기 인식 강함 — 점진 노출과 안전 메시지로 운동 회피 깨기.',
      },
      '안정 시 통증': {
        cpg: 'APTA LBP CPG 2021 — 환자 교육 (PNE) + 점진 운동 + 다학제.',
        maitland: 'Grade I~II 진정.',
        mulligan: '환자 반응 따라.',
        mfr: '이완 목적 sustained.',
        trp: '신중.',
        exercise: '점진 노출, 유산소 강조.',
        cautions: '도수 의존 깨기 — 환자 교육 우선.',
        kmo: 'PNE 도입 단계 — "통증 ≠ 손상" 메시지 일관.',
      },
      '방사통': {
        cpg: 'APTA LBP CPG 2021 — chronic radiating → neural mobilization + manipulation + 운동 + 환자 교육.',
        maitland: 'PA Grade III~IV.',
        mulligan: 'SLR-MWM, SNAG.',
        mfr: '이상근, QL, 햄스트링.',
        trp: '이상근, 둔근.',
        exercise: 'Neural mobilization (tensioner), 코어, 둔근 강화, 점진 부하.',
        cautions: '신경 진행 시 의뢰. Stenosis 환자 신전 운동 신중.',
        kmo: '만성 디스크 진단 환자 — 운동 + 교육 비중 강조.',
      },
    },
  },

  '어깨 관절': {
    '급성': {
      '움직임 시 통증': {
        cpg: 'JOSPT 2020 Subacromial pain syndrome → 운동 치료 first-line (강한 권고).',
        maitland: 'GH inferior glide (통증 한계 안), AP/posterior glide. Grade I~II 진동.',
        mulligan: 'Shoulder MWM (humeral head posterior glide + 환자 능동 굴곡/외전). 즉시 효과 체감.',
        mfr: 'Pec minor, 상부 승모근, 회전근개 myofascial.',
        trp: 'Infraspinatus TrP (어깨 앞쪽 referred pain), supraspinatus, 상부 승모근.',
        exercise: '통증 한계 내 AROM (pulley·wand), 등척성 회전근개, scapular setting (lower/mid trap).',
        cautions: '외상 후 골절 의심 (변형·못 들음 → 영상), 회전근개 전층 파열 (drop arm test) 시 의뢰. 종양·감염 스크리닝.',
        kmo: '"오십견 시작인가요?" 환자 흔한 질문 — 명확한 감별 (impingement vs adhesive capsulitis).',
      },
      '안정 시 통증': {
        cpg: '안정 시 통증 + 야간통 = inflammatory phase (frozen shoulder freezing 단계 의심).',
        maitland: 'Grade I 진동만. Sustained 회피.',
        mulligan: '급성 reactive 시 보류.',
        mfr: 'Pec minor, 상부 승모근 부드러운 sustained.',
        trp: '신중. 압박 시 자극 가능.',
        exercise: 'Codman pendulum, 통증 한계 내 AROM, 등척성 가벼운.',
        cautions: '야간통 + 점진 악화 + 50~60대 여성·당뇨 시 adhesive capsulitis freezing 단계 가능. 영상 의뢰 (회전근개 파열 감별).',
        kmo: '"오십견" 자기 진단 흔함 — 정확한 감별과 단계별 치료 설명.',
      },
      '방사통': {
        cpg: '감별 — cervical 인자 vs shoulder 인자. APTA Neck CPG 2017, Shoulder CPG.',
        maitland: '감별 후 — cervical 인자면 C-spine, shoulder 인자면 GH. Thoracic mobilization 결합.',
        mulligan: '감별 후 — Cervical SNAG 또는 Shoulder MWM.',
        mfr: '사각근 (TOS 감별), pec minor, 회전근개.',
        trp: '사각근 (referred to arm), infraspinatus (referred to anterior shoulder/arm).',
        exercise: 'Neural mobilization (median/radial/ulnar 평가), 회전근개 등척성.',
        cautions: '신경 진행 시 의뢰. TOS 인자 평가.',
        kmo: '"목인지 어깨인지" 감별 진단이 핵심.',
      },
    },
    '아급성': {
      '움직임 시 통증': {
        cpg: 'JOSPT 2020 — 운동 치료 (scapular stabilization + 회전근개 강화) + 도수 결합.',
        maitland: 'GH posterior/inferior glide Grade III~IV. Thoracic mobilization 적극.',
        mulligan: 'MWM 적극, self-MWM 처방.',
        mfr: 'Pec minor (전방 어깨 자세 인자), 회전근개, 상부 승모근.',
        trp: 'Infraspinatus, supraspinatus, 상부 승모근, levator scapulae.',
        exercise: 'Scapular stabilization (lower trap, serratus anterior — wall slides, scapular Y/T/W), 회전근개 (external rotation with band), 점진 부하.',
        cautions: '진행성 약화 시 의뢰.',
        kmo: '도수 + 운동 결합 표준.',
      },
      '안정 시 통증': {
        cpg: 'Adhesive capsulitis freezing/frozen 단계 가능 — 단계별 접근.',
        maitland: 'GH inferior/posterior glide Grade II~III sustained.',
        mulligan: 'MWM 점진.',
        mfr: 'Pec minor, latissimus.',
        trp: 'Infraspinatus, subscapularis (deep, careful).',
        exercise: 'Pendulum, sleeper stretch (posterior capsule), cross-body stretch, 등척성.',
        cautions: 'Adhesive capsulitis freezing 단계는 over-aggressive stretch 회피.',
        kmo: '"지금은 풀기보다 진정시키는 단계"로 환자 교육.',
      },
      '방사통': {
        cpg: '감별 후 multimodal.',
        maitland: '감별 후 cervical/shoulder.',
        mulligan: 'SNAG 또는 MWM.',
        mfr: '사각근, pec minor.',
        trp: '사각근, infraspinatus.',
        exercise: 'Neural mobilization, 회전근개, scapular control.',
        cautions: '신경 진행 시 의뢰.',
        kmo: '감별 진단 후 multimodal 접근.',
      },
    },
    '만성': {
      '움직임 시 통증': {
        cpg: 'JOSPT 2024 만성 어깨 — 점진 부하 운동 (강한 권고) + 환자 교육 + 도수 결합. Adhesive capsulitis frozen/thawing 단계 — Maitland Grade III~IV.',
        maitland: 'GH Grade III~IV (thawing 단계), inferior/posterior/anterior glide all directions.',
        mulligan: 'MWM 적극.',
        mfr: '광범위 myofascial.',
        trp: '광범위 — infraspinatus, subscapularis, supraspinatus, 상부 승모근, levator scapulae.',
        exercise: '점진 부하 (탄성밴드 → 덤벨), 기능 동작 (push/pull/overhead), 지구력 운동.',
        cautions: '중추감작 가능, KMO 교육.',
        kmo: '운동 회피 환자 — 점진 노출과 안전 메시지로 자기 효능감 회복.',
      },
      '안정 시 통증': {
        cpg: '단계별 + 교육 + 점진 운동.',
        maitland: 'Grade III~IV (frozen 단계는 stretch tolerable).',
        mulligan: 'MWM.',
        mfr: 'Sustained.',
        trp: '신중.',
        exercise: 'Stretch (sleeper, cross-body, towel behind back), 등척성, 점진.',
        cautions: '단계 감별 필수.',
        kmo: '"오십견" 환자 — 단계 설명과 인내 메시지.',
      },
      '방사통': {
        cpg: '감별 후 multimodal.',
        maitland: '감별 후.',
        mulligan: 'SNAG/MWM.',
        mfr: '사각근, pec minor.',
        trp: '사각근, infraspinatus, subscapularis.',
        exercise: 'Neural mobilization, 회전근개, scapular.',
        cautions: '신경 진행 시 의뢰.',
        kmo: '감별 후 운동 + 교육 비중 강조.',
      },
    },
  },

  '무릎 관절': {
    '급성': {
      '움직임 시 통증': {
        cpg: '무릎 OA CPG — 운동 + 환자 교육 + 체중 관리 (강한 권고). PFP CPG 2019 — hip + knee 운동, 도수 isolation 부적합.',
        maitland: 'TF anterior/posterior glide, patellar mobilization (medial/lateral/superior/inferior). Grade I~II.',
        mulligan: 'Knee MWM (tibial rotation + active flexion/extension). Patellar MWM.',
        mfr: '사두근 (특히 VL), IT band, 햄스트링.',
        trp: 'VL TrP (lateral knee referred), 햄스트링, 비복근.',
        exercise: '등척성 사두근 (quad set), SLR, AROM 통증 한계 안.',
        cautions: '외상 후 못 디딤 (Ottawa knee rule), 골절 의심, 인대 전체 파열 (Lachman·anterior drawer 양성), 감염 (열감·발적·발열) 시 의뢰.',
        kmo: '도수 + 운동 결합이 표준. PFP CPG는 도수 isolation을 비추천합니다.',
      },
      '안정 시 통증': {
        cpg: '급성 염증 단계 — RICE + 부드러운 운동 + 환자 교육.',
        maitland: 'Grade I 진동 (부종 감소 목적도).',
        mulligan: '급성 reactive 시 보류.',
        mfr: '부드러운 sustained — 사두근, 햄스트링.',
        trp: '신중.',
        exercise: '등척성 quad set, ankle pump (부종 관리).',
        cautions: '부종 + 발적 + 발열 시 감염 의심. 외상 후 영상 우선.',
        kmo: '부종 관리와 부드러운 움직임으로 진정 우선.',
      },
      '방사통': {
        cpg: '감별 — lumbar 인자 평가.',
        maitland: 'Lumbar 인자면 lumbar PA. Knee 인자면 TF.',
        mulligan: '감별 후.',
        mfr: '햄스트링, 비복근, 이상근.',
        trp: '햄스트링, 비복근.',
        exercise: 'Neural mobilization (sciatic), 사두근, 햄스트링.',
        cautions: '신경 진행 시 의뢰.',
        kmo: '무릎 → 다리 방사 패턴은 드뭅니다. lumbar 인자 평가 필수.',
      },
    },
    '아급성': {
      '움직임 시 통증': {
        cpg: '운동 + 도수 결합.',
        maitland: 'TF mobilization Grade III~IV. Patellar.',
        mulligan: 'MWM 적극.',
        mfr: '사두근, IT band, 햄스트링.',
        trp: 'VL, 햄스트링.',
        exercise: 'SLR 진행, mini squat (통증 한계 안), step-up, 햄스트링 강화, hip 강화 (gluteus medius — PFP 핵심).',
        cautions: '진행성 약화 시 의뢰.',
        kmo: 'hip 강화의 무릎 효과를 환자에게 교육해야 합니다.',
      },
      '안정 시 통증': {
        cpg: '단계별 진행.',
        maitland: 'Grade II~III.',
        mulligan: 'MWM.',
        mfr: '사두근, IT band.',
        trp: 'VL.',
        exercise: 'AROM, 등척성, 점진.',
        cautions: '야간 stiff 잔존 시 재평가.',
        kmo: '점진 부하로 회복 진행.',
      },
      '방사통': {
        cpg: '감별 후 multimodal.',
        maitland: '감별 후.',
        mulligan: '감별 후.',
        mfr: '햄스트링, 비복근.',
        trp: '햄스트링.',
        exercise: 'Neural mobilization.',
        cautions: '신경 진행 시 의뢰.',
        kmo: 'lumbar 또는 peripheral nerve 감별 후 접근.',
      },
    },
    '만성': {
      '움직임 시 통증': {
        cpg: '무릎 OA CPG — 운동 + 교육 + 체중 관리 (강한 권고). PFP — hip + knee 운동, 도수 isolation 부적합. PFP high-volume (3 sets × 30+ reps × 3/week).',
        maitland: 'TF Grade III~IV. Patellar mobilization.',
        mulligan: 'MWM 적극, self-MWM.',
        mfr: '사두근, IT band, 햄스트링, gastrocnemius.',
        trp: 'VL, 햄스트링, 비복근.',
        exercise: 'Hip 강화 (gluteus medius, lateral rotators) + knee 강화 (quad, hamstring) 결합. 점진 부하 (squat, lunge, step-up). 유산소 (자전거·수영).',
        cautions: 'KMO — "퇴행성 = 영구 손상 아님" 교육.',
        kmo: '"관절이 닳아서" 인식 강한 환자 — KMO 메시지 핵심. 운동 비중 강조.',
      },
      '안정 시 통증': {
        cpg: 'OA 진행 또는 중추감작 — 점진 운동 + 교육.',
        maitland: 'Grade III.',
        mulligan: 'MWM.',
        mfr: '광범위.',
        trp: 'VL, 햄스트링.',
        exercise: '점진 운동, 유산소 (저충격), 체중 관리 교육.',
        cautions: '중추감작 가능, PNE 결합.',
        kmo: '저충격 유산소와 점진 부하로 자기 효능감 회복.',
      },
      '방사통': {
        cpg: '감별 후 multimodal.',
        maitland: '감별 후 lumbar 또는 knee.',
        mulligan: '감별 후.',
        mfr: '햄스트링, 비복근.',
        trp: '햄스트링.',
        exercise: 'Neural mobilization, hip + knee 강화.',
        cautions: '신경 진행 시 의뢰.',
        kmo: 'lumbar 또는 peripheral nerve 감별 후 접근.',
      },
    },
  },

  '엉덩 관절': {
    '급성': {
      '움직임 시 통증': {
        cpg: 'Hip OA CPG 2025 — 운동 + 도수 + 환자 교육. LADM (long-axis distraction) high-quality evidence.',
        maitland: 'Hip long-axis distraction Grade I~II, lateral distraction, posterior glide. SI joint 평가.',
        mulligan: 'Hip MWM (lateral glide + active flexion/abduction).',
        mfr: '둔근군, 이상근, 고관절 굴곡근, IT band.',
        trp: '이상근, gluteus medius/minimus, TFL.',
        exercise: '등척성 둔근 (clam, side-lying abduction), AROM, 통증 한계 내 보행 교정.',
        cautions: '외상 후 골절 의심 (노인 + 낙상), avascular necrosis, 종양 시 의뢰.',
        kmo: '보행 교정과 부드러운 가동으로 진정 시작.',
      },
      '안정 시 통증': {
        cpg: '야간통 — greater trochanteric bursitis 의심.',
        maitland: 'Grade I~II.',
        mulligan: '보류.',
        mfr: 'Gluteus medius/minimus, TFL.',
        trp: 'Gluteus medius, TFL.',
        exercise: '등척성, 자세 교육 (옆으로 누울 때 다리 사이 베개).',
        cautions: '야간통+체중감소 시 red flag.',
        kmo: '수면 자세 교육으로 자기 관리 동기 부여.',
      },
      '방사통': {
        cpg: '이상근 증후군 또는 lumbar radiculopathy 감별.',
        maitland: 'Lumbar 인자면 lumbar PA, hip 인자면 hip mobilization.',
        mulligan: 'SLR-MWM.',
        mfr: '이상근.',
        trp: '이상근 적극.',
        exercise: 'Neural mobilization, hip 강화.',
        cautions: '신경 진행 시 의뢰.',
        kmo: '이상근 vs lumbar 감별이 핵심.',
      },
    },
    '아급성': {
      '움직임 시 통증': {
        cpg: 'Hip OA — 운동 + 도수.',
        maitland: 'LADM Grade III~IV.',
        mulligan: 'MWM 적극.',
        mfr: '둔근, 이상근, 굴곡근, IT band.',
        trp: '이상근, gluteus medius.',
        exercise: 'Clam, side-lying abduction, glute bridge, mini squat, lunge.',
        cautions: '진행성 약화 시 의뢰.',
        kmo: '점진 부하로 회복 진행.',
      },
      '안정 시 통증': {
        cpg: '단계별 진행.',
        maitland: 'Grade II~III.',
        mulligan: 'MWM.',
        mfr: 'Gluteus medius/minimus, TFL.',
        trp: 'Gluteus medius.',
        exercise: '점진 강화.',
        cautions: '야간통 진행 시 재평가.',
        kmo: '자세 교육 + 점진 강화.',
      },
      '방사통': {
        cpg: '감별 후 multimodal.',
        maitland: '감별 후.',
        mulligan: 'SLR-MWM.',
        mfr: '이상근.',
        trp: '이상근.',
        exercise: 'Neural mobilization.',
        cautions: '신경 진행 시 의뢰.',
        kmo: '이상근 vs lumbar 감별 후 접근.',
      },
    },
    '만성': {
      '움직임 시 통증': {
        cpg: 'Hip OA CPG 2025 — 운동 (강한 권고) + 도수 + 환자 교육 + 체중 관리.',
        maitland: 'LADM Grade III~IV (high-force). Posterior/lateral glide.',
        mulligan: 'MWM 적극.',
        mfr: '광범위.',
        trp: '이상근, gluteus medius/minimus, TFL, hip flexors.',
        exercise: 'Hip 강화 (abductors/extensors/rotators), 코어, 점진 부하 (squat·deadlift), 유산소 (자전거·수영).',
        cautions: '노인 환자 다수 — 안전한 점진 부하와 낙상 예방 교육.',
        kmo: '"닳아서"가 아닌 적응적 조직 — 점진 운동으로 기능 회복.',
      },
      '안정 시 통증': {
        cpg: '중추감작 또는 OA 진행 — 점진 운동 + 교육.',
        maitland: 'LADM.',
        mulligan: 'MWM.',
        mfr: '광범위.',
        trp: '광범위.',
        exercise: '점진, 유산소.',
        cautions: '다학제 의뢰 고려.',
        kmo: '저충격 유산소로 자기 효능감 회복.',
      },
      '방사통': {
        cpg: '감별 후 multimodal.',
        maitland: '감별 후.',
        mulligan: 'SLR-MWM.',
        mfr: '이상근.',
        trp: '이상근.',
        exercise: 'Neural mobilization, hip 강화.',
        cautions: '신경 진행 시 의뢰.',
        kmo: '감별 후 운동 비중 강조.',
      },
    },
  },

  '발목 관절': {
    '급성': {
      '움직임 시 통증': {
        cpg: 'Lateral Ankle Sprain CPG 2021 — 도수 (graded mobilization, manipulation, MWM) + 운동 (강한 권고). MWM 효과 evidence 강함.',
        maitland: 'Talocrural anterior/posterior glide, subtalar mobilization. Grade I~II.',
        mulligan: 'Fibula MWM (posterior glide of distal fibula + active dorsiflexion). 핵심 권고.',
        mfr: '비복근, soleus, 비골근군.',
        trp: '비골근, 비복근.',
        exercise: '등척성 dorsiflexion/eversion, AROM, 부종 관리 (RICE).',
        cautions: '외상 후 못 디딤 (Ottawa ankle rule), 골절 의심 시 영상.',
        kmo: 'CPG 명시 — Mulligan MWM 즉시 효과가 강력 권고됩니다.',
      },
      '안정 시 통증': {
        cpg: '급성 부종 단계 — RICE + 부드러운 운동.',
        maitland: 'Grade I.',
        mulligan: '보류.',
        mfr: '부드러운.',
        trp: '신중.',
        exercise: 'RICE, 등척성.',
        cautions: '부종 관리, 외상 영상 평가.',
        kmo: '부종 진정 단계 — 부드러운 가동.',
      },
      '방사통': {
        cpg: '드뭄. 비골 신경 자극 가능 (sprain 후 traction injury).',
        maitland: 'Grade I~II 감별 후.',
        mulligan: 'MWM 신중.',
        mfr: '비골근.',
        trp: '비골근.',
        exercise: 'Neural mobilization (peroneal, tibial).',
        cautions: '신경 손상 진행 시 의뢰.',
        kmo: '드문 패턴 — 신경 감별이 핵심.',
      },
    },
    '아급성': {
      '움직임 시 통증': {
        cpg: 'CPG 2021 — 도수 + 운동.',
        maitland: 'Talocrural Grade III~IV (특히 dorsiflexion 제한).',
        mulligan: 'MWM 적극, weight-bearing MWM.',
        mfr: '비복근, soleus, 비골근.',
        trp: '비복근, 비골근.',
        exercise: '균형 운동 (BAPS, 한 발 서기), 등척성 → 등장성, calf raise, eversion 강화 (band).',
        cautions: '진행성 통증 시 재평가.',
        kmo: '균형 운동이 재발 예방의 핵심입니다.',
      },
      '안정 시 통증': {
        cpg: '단계별 진행.',
        maitland: 'Grade II~III.',
        mulligan: 'MWM.',
        mfr: '비복근.',
        trp: '비복근.',
        exercise: '점진 강화.',
        cautions: '야간 stiff 잔존 시 재평가.',
        kmo: '점진 부하로 회복 진행.',
      },
      '방사통': {
        cpg: '감별 후 multimodal.',
        maitland: '감별 후.',
        mulligan: 'MWM.',
        mfr: '비골근.',
        trp: '비골근.',
        exercise: 'Neural mobilization.',
        cautions: '신경 진행 시 의뢰.',
        kmo: '신경 감별 후 접근.',
      },
    },
    '만성': {
      '움직임 시 통증': {
        cpg: 'CPG 2021 — 도수 + 균형 운동 + 점진 부하 (강한 권고). Chronic ankle instability (CAI) 핵심.',
        maitland: 'Talocrural Grade III~IV, subtalar.',
        mulligan: 'MWM 적극, weight-bearing MWM.',
        mfr: '광범위.',
        trp: '비골근, 비복근, soleus.',
        exercise: '균형 progression (eyes open → closed, firm → unstable), proprioceptive (BOSU, wobble board), 비골근 강화, 점진 운동 복귀 (jogging, jumping).',
        cautions: '반복 sprain 패턴 — 균형·proprioception 우선.',
        kmo: '"또 삐겠다"는 두려움을 점진 노출로 깨고 운동 복귀 자신감 회복.',
      },
      '안정 시 통증': {
        cpg: '단계별 점진 운동.',
        maitland: 'Grade III.',
        mulligan: 'MWM.',
        mfr: '광범위.',
        trp: '비복근.',
        exercise: '점진.',
        cautions: '중추감작 가능.',
        kmo: '점진 부하로 신뢰 회복.',
      },
      '방사통': {
        cpg: '감별 후 (lumbar 또는 peripheral nerve).',
        maitland: '감별 후.',
        mulligan: '감별 후.',
        mfr: '비골근.',
        trp: '비골근.',
        exercise: 'Neural mobilization.',
        cautions: '신경 진행 시 의뢰.',
        kmo: 'lumbar 또는 peripheral nerve 감별 후 접근.',
      },
    },
  },
};

// ── Red Flag 일반 가이드 (docs §5.5) ─────────────────────────────────────────
export const TIER1_RED_FLAGS = [
  '외상 직후 (특히 cervical) → 골절·인대 파열 가능, 영상 우선',
  'Cervical manipulation + VBI 의심 (어지럼·복시·구음장애) → manipulation 절대 금기',
  'Cauda equina 증상 (방광·항문 마비, saddle anesthesia) → 즉시 의뢰',
  '진행성 운동 약화 (cervical/lumbar 방사통) → 즉시 의뢰',
  '종양·감염·골절 의심 (야간통+체중감소+발열 등 비기계적 통증) → 의뢰',
  '급성 reactive (강한 안정 시 통증) → Maitland Grade I만, Mulligan SNAG/MWM 보류',
  '급성 방사통 + 동측 압박 → contralateral 또는 indirect 접근',
  'PFP 환자 단독 도수 → 효과 약함, hip+knee 운동 결합 필수',
];

// ── 룩업 함수 ────────────────────────────────────────────────────────────────
// 매칭 부재 시 null 반환 (호출자가 fallback 처리).
export function lookupScenario(region, acuity, painCondition) {
  if (!region || !acuity || !painCondition) return null;
  const r = MATRIX[region];
  if (!r) return null;
  const a = r[acuity];
  if (!a) return null;
  return a[painCondition] || null;
}

export function getKmoMessage(acuity) {
  return KMO_BY_ACUITY[acuity] || KMO_BY_ACUITY['아급성'];
}

export function getRedFlags() {
  return TIER1_RED_FLAGS.slice();
}

export default {
  MATRIX,
  KMO_BY_ACUITY,
  TIER1_RED_FLAGS,
  lookupScenario,
  getKmoMessage,
  getRedFlags,
};
