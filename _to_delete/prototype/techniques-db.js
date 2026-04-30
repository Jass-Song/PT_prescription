// KMO 도수치료 테크닉 데이터베이스
// MVP v0.1 — 경추·요추 테크닉만 활성화
// Category A (MVP): 경추 2개 + 요추 2개 = 4개
// Category B (MVP): 경추 4개 + 요추 3개 = 7개
// TECHNIQUES_DB_FUTURE: 나머지 31개 보관 (데이터 보존)

// 카테고리 마스터 데이터 (DB의 technique_categories 테이블과 동기화)
const TECHNIQUE_CATEGORIES = [
  {
    id: 'cat-A',
    category_key: 'category_a_joint_mobilization',
    name_ko: '관절가동술',
    name_en: 'Joint Mobilization',
    subtitle_ko: 'Maitland Concept 기반 접근법',
    subtitle_en: 'Maitland Concept-Based Approach',
    basic_principles: [
      { icon: '🎯', title_ko: '치료 전 평가가 먼저', desc_ko: '시술 전 반드시 관절 가동 범위(ROM)와 통증 위치를 확인하세요. 치료 후 변화를 비교해야 효과를 판단할 수 있습니다.' },
      { icon: '🖐️', title_ko: '저항 감지가 핵심 (R1 / R2)', desc_ko: 'R1은 처음 조직 저항이 느껴지는 지점, R2는 최대 저항 지점입니다. Grade I-II는 R1 이전, Grade III-IV는 R1-R2 사이에서 시행합니다.' },
      { icon: '📊', title_ko: 'Grade 선택 기준', desc_ko: 'Grade I-II: 통증이 주 증상일 때 (부드럽게). Grade III-IV: 관절 굳음이 주 증상일 때 (더 깊게). 처음에는 낮은 Grade로 시작해 반응을 봅니다.' },
      { icon: '🔄', title_ko: '시술 후 즉각 재평가', desc_ko: '3-5회 시행 후 ROM 변화와 통증 변화를 반드시 확인하세요. 변화가 없으면 방향, 분절, 또는 Grade를 조정합니다.' },
      { icon: '⚠️', title_ko: '절대 금기 확인', desc_ko: '골절, 종양, 심한 골다공증, 척수 압박 증상(양하지 저림·대소변 장애)이 있으면 시행하지 마세요.' }
    ],
    sort_order: 1
  },
  {
    id: 'cat-B',
    category_key: 'category_b_mulligan',
    name_ko: 'Mulligan Concept',
    name_en: 'Mulligan Concept',
    subtitle_ko: 'MWM / SNAG / NAG 기반 접근법',
    subtitle_en: 'MWM / SNAG / NAG-Based Approach',
    basic_principles: [
      { icon: '🚫', title_ko: 'No Pain Rule (절대 원칙)', desc_ko: '시술 중 통증이 발생하면 즉시 방향을 수정하거나 중단하세요. Mulligan의 핵심 원칙 — 통증 없는 범위에서만 시행합니다.' },
      { icon: '✅', title_ko: 'PILL 반응 확인', desc_ko: 'Pain-free(통증 없음), Instant(즉각), Long-lasting(지속) — 세 가지가 모두 나타나야 올바른 방향과 분절을 선택한 것입니다.' },
      { icon: '🤝', title_ko: '수동 활주 + 능동 운동 결합', desc_ko: '치료사가 활주(glide)를 유지하는 동안 환자가 스스로 움직입니다. 수동 치료와 능동 운동의 결합이 핵심입니다.' },
      { icon: '🔍', title_ko: '방향 재탐색', desc_ko: 'PILL 반응이 없으면 활주 방향(전상방/내측/외측), 분절 레벨, 활주 크기를 순서대로 조정하세요.' },
      { icon: '📏', title_ko: '즉각 ROM 확인', desc_ko: '1세트(6-10회) 후 즉각적인 ROM 증가가 없으면 파라미터를 변경합니다. 효과는 첫 세션에서 즉시 나타나야 합니다.' }
    ],
    sort_order: 2
  }
];

const TECHNIQUES_DB = [

  // ═══════════════════════════════════════════
  // CATEGORY A — 전통 관절가동술 (MVP: 경추·요추)
  // ═══════════════════════════════════════════

  // --- 경추 ---
  {
    id: "tech-A-001",
    name_ko: "경추 중앙 PA 가동술",
    name_en: "Cervical Central PA Mobilization",
    category: "A",
    category_id: "cat-A",
    category_label: "전통 관절가동술",
    body_part: "cervical",
    body_part_label: "경추",
    purpose_tags: ["pain_relief", "rom_improvement", "stiffness"],
    target_tags: ["subacute", "chronic", "hypomobile"],
    symptom_tags: ["cervicogenic_ha", "lbp_nonspecific"],
    contraindications: ["VBI 증상", "불안정성", "골절", "종양", "류마티스 경추"],
    evidence_level: "high",
    maitland_grade: ["I","II","III","IV"],
    recommendation_weight: 0.88,
    patient_position: "복와위, 이마 치료대 헤드피스",
    therapist_contact: "양 엄지 지문면(pad) → 극돌기 중앙 접촉",
    key_technique_tip: "어깨를 엄지 바로 위에 위치시키고 체중 이동으로 수직 압력 전달. 팔 힘 사용 금지.",
    common_mistake: "엄지 끝으로 찌르듯 접촉 → 엄지 지문면으로 넓게 / 팔로 밀기 → 체중 이동으로 교정",
    good_response: "국소 압통 수준 불편감, 시술 후 ROM 증가, 두통 완화"
  },
  {
    id: "tech-A-002",
    name_ko: "경추 단측 PA 가동술",
    name_en: "Cervical Unilateral PA Mobilization",
    category: "A",
    category_id: "cat-A",
    category_label: "전통 관절가동술",
    body_part: "cervical",
    body_part_label: "경추",
    purpose_tags: ["pain_relief", "rom_improvement", "stiffness"],
    target_tags: ["subacute", "chronic", "hypomobile"],
    symptom_tags: ["cervicogenic_ha"],
    contraindications: ["척추동맥 혈관 문제", "불안정 경추", "급성 신경근병증"],
    evidence_level: "high",
    maitland_grade: ["I","II","III","IV"],
    recommendation_weight: 0.85,
    patient_position: "복와위, 머리 중립 또는 소량 회전(5~10°)",
    therapist_contact: "엄지 지문면 → 관절기둥(articular pillar), 극돌기 외측 1~1.5cm",
    key_technique_tip: "힘 방향은 약 15~20° 내측 + 두측 벡터. 양측 비교 후 단단한 쪽 집중 치료.",
    common_mistake: "극돌기 너무 가깝게 접촉 → articular pillar 정확히 촉진 / 한쪽만 체크 → 항상 양측 비교",
    good_response: "시술 부위 압통 수준 불편감, 치료 후 경부 ROM 증가, 두통 경감"
  },

  // --- 요추 ---
  {
    id: "tech-A-005",
    name_ko: "요추 중앙 PA 가동술",
    name_en: "Lumbar Central PA Mobilization",
    category: "A",
    category_id: "cat-A",
    category_label: "전통 관절가동술",
    body_part: "lumbar",
    body_part_label: "요추",
    purpose_tags: ["pain_relief", "rom_improvement", "stiffness"],
    target_tags: ["subacute", "chronic", "hypomobile"],
    symptom_tags: ["lbp_nonspecific", "disc_herniation"],
    contraindications: ["마미총 증후군", "척추 불안정", "급성 추간판 탈출 + 신경 결손", "골절", "종양"],
    evidence_level: "high",
    maitland_grade: ["I","II","III","IV"],
    recommendation_weight: 0.92,
    patient_position: "복와위, 팔 몸 옆 또는 머리 앞, 발목 아래 베개 가능",
    therapist_contact: "손바닥 척측(pisiform fat pad) → 목표 극돌기, 반대손 reinforcement",
    key_technique_tip: "Pisiform만 극돌기에 닿도록 손목 완전 신전. '내 몸이 파도처럼 앞으로 넘어지는 느낌'으로 체중 전달.",
    common_mistake: "손가락/손바닥 전체로 접촉 → pisiform만 닿도록 / 팔로 밀기 → 체중 이동으로 교정",
    good_response: "국소 압통, 요부 뻐근함(하지 방사 없어야 함), 시술 후 요추 굴곡·신전 ROM 증가"
  },
  {
    id: "tech-A-006",
    name_ko: "요추 단측 PA + 측방굴곡 가동술",
    name_en: "Lumbar Unilateral PA + Side-lying Rotation",
    category: "A",
    category_id: "cat-A",
    category_label: "전통 관절가동술",
    body_part: "lumbar",
    body_part_label: "요추",
    purpose_tags: ["pain_relief", "rom_improvement"],
    target_tags: ["chronic", "hypomobile"],
    symptom_tags: ["lbp_nonspecific"],
    contraindications: ["급성 신경근병증", "불안정 척추"],
    evidence_level: "medium",
    maitland_grade: ["II","III","IV"],
    recommendation_weight: 0.75,
    patient_position: "측와위, 증상 측 위, 상부 다리 고관절·무릎 90° 굴곡",
    therapist_contact: "엄지 끝이나 pisiform → 목표 요추 facet 외측",
    key_technique_tip: "측와위 자중(重)이 추가 gapping 효과 제공. 촉진으로 facet 위치 정확히 확인 필수.",
    common_mistake: "분절 잠금 없이 전체 요추 회전 → 목표 분절에서 분절 잠금 후 시행",
    good_response: "국소 facet 압통, 치료 후 측방굴곡·굴곡 ROM 개선"
  },


  // ═══════════════════════════════════════════
  // CATEGORY B — Mulligan Concept (MVP: 경추·요추)
  // ═══════════════════════════════════════════

  // --- 경추 ---
  {
    id: "tech-B-001",
    name_ko: "경추 SNAG",
    name_en: "Cervical SNAG (Sustained Natural Apophyseal Glide)",
    category: "B",
    category_id: "cat-B",
    category_label: "Mulligan Concept",
    body_part: "cervical",
    body_part_label: "경추",
    purpose_tags: ["pain_relief", "rom_improvement", "functional_recovery"],
    target_tags: ["subacute", "chronic", "athlete", "hypomobile"],
    symptom_tags: ["cervicogenic_ha", "radiculopathy"],
    contraindications: ["불안정성", "골절", "종양", "RA 경추 침범", "VBI 불충분", "심한 골다공증"],
    evidence_level: "high",
    maitland_grade: [],
    recommendation_weight: 0.90,
    patient_position: "앉은 자세, 척추 중립, 발바닥 바닥",
    therapist_contact: "pisiform 또는 엄지 → 목표 분절 위 척추체 관절돌기에 두상골 접촉. facet plane 방향(상방 45°) 활주.",
    key_technique_tip: "No Pain Rule — 통증 발생 즉시 방향 재탐색. PILL 반응(Pain-free, Instant, Long-Lasting) 확인 필수. 1차: 전상방 45°, 2차: 내측/외측 조정.",
    common_mistake: "활주 방향이 순수 전방(PA) → 전상방(antero-superior) facet plane 각도로 조정 / 극돌기 위 아닌 아래 걸어서 반대 분절 치료",
    good_response: "활주 유지 시 능동 운동 통증 즉각 소실 (VAS 50% 이상↓), 1세트 후 ROM 증가"
  },
  {
    id: "tech-B-002",
    name_ko: "경추 NAG",
    name_en: "Cervical NAG (Natural Apophyseal Glide)",
    category: "B",
    category_id: "cat-B",
    category_label: "Mulligan Concept",
    body_part: "cervical",
    body_part_label: "경추",
    purpose_tags: ["pain_relief", "rom_improvement", "stiffness"],
    target_tags: ["subacute", "chronic", "elderly", "hypomobile"],
    symptom_tags: ["cervicogenic_ha"],
    contraindications: ["불안정성", "골절", "종양", "RA 경추 침범", "VBI 불충분"],
    evidence_level: "medium",
    maitland_grade: [],
    recommendation_weight: 0.78,
    patient_position: "앉은 자세, 척추 중립, 이완",
    therapist_contact: "엄지 또는 두상골 → 위 분절 횡돌기 접촉. 치료면 방향 리듬적(1~2Hz) 반복 활주.",
    key_technique_tip: "수동적 리듬 활주 — 환자는 자세만 유지. SNAG 전 준비 기법 또는 고령 환자 첫 세션에 활용.",
    common_mistake: "수직 방향 누르기 → 관절면 각도(antero-superior)에 맞는 방향 / 너무 강한 힘 → 매우 가벼운 oscillation으로 시작",
    good_response: "활주 중 통증 없음, 시술 후 굴곡·신전 ROM 개선"
  },
  {
    id: "tech-B-003",
    name_ko: "경추 Reverse NAG",
    name_en: "Cervical Reverse NAG",
    category: "B",
    category_id: "cat-B",
    category_label: "Mulligan Concept",
    body_part: "cervical",
    body_part_label: "경추",
    purpose_tags: ["rom_improvement", "stiffness"],
    target_tags: ["subacute", "chronic", "hypomobile"],
    symptom_tags: ["cervicogenic_ha"],
    contraindications: ["전방 경부 수술력", "경동맥 질환", "연하장애 기왕력"],
    evidence_level: "low",
    maitland_grade: [],
    recommendation_weight: 0.60,
    patient_position: "앉은 자세, 머리 중립 또는 약간 후방 경사",
    therapist_contact: "두 번째 손가락 중간 마디 → C1~C3 전방 접촉(턱 아래 연조직). 고정손: 후두골 지지.",
    key_technique_tip: "전방 구조를 후방-상방으로 리듬적 활주. 매우 부드럽게 — 연조직 압박 최소화. SNAG 효과 부족한 굴곡 제한에 추가.",
    common_mistake: "접촉점이 너무 내측(spinous process 직접) → 외측 관절돌기(articular pillar)에 접촉 / 두부 지지 부족 → 치료사 몸통으로 두부 완전 지지",
    good_response: "굴곡 ROM 즉각 개선, 가벼운 압박감"
  },
  {
    id: "tech-B-004",
    name_ko: "C1-C2 SNAG",
    name_en: "Atlanto-Axial SNAG (C1-C2 SNAG)",
    category: "B",
    category_id: "cat-B",
    category_label: "Mulligan Concept",
    body_part: "cervical",
    body_part_label: "경추",
    purpose_tags: ["pain_relief", "rom_improvement", "stiffness"],
    target_tags: ["subacute", "chronic", "hypomobile"],
    symptom_tags: ["cervicogenic_ha"],
    contraindications: ["상위 경추 불안정성(RA, 다운증후군, 외상)", "골절", "종양", "불안정성 스크리닝 미완료"],
    evidence_level: "medium",
    maitland_grade: [],
    recommendation_weight: 0.72,
    patient_position: "앉은 자세, 척추 중립",
    therapist_contact: "엄지 또는 두상골 → C1 횡돌기(후방) 접촉. 고정손: 반대편 두개골 지지.",
    key_technique_tip: "반드시 불안정성 스크리닝 선행(Sharp-Purser, Alar ligament test). C1을 회전 방향으로 측방 활주 유지하며 환자 능동 회전.",
    common_mistake: "불안정성 스크리닝 없이 시행 → 절대 금지 / 힘 과다 → 매우 부드러운 조직 첫 저항 수준만",
    good_response: "회전 ROM 즉각 증가 (10° 이상), 통증 소실"
  },

  // --- 요추 ---
  {
    id: "tech-B-007",
    name_ko: "요추 SNAG",
    name_en: "Lumbar SNAG",
    category: "B",
    category_id: "cat-B",
    category_label: "Mulligan Concept",
    body_part: "lumbar",
    body_part_label: "요추",
    purpose_tags: ["pain_relief", "rom_improvement", "stiffness", "functional_recovery"],
    target_tags: ["subacute", "chronic", "athlete", "hypomobile"],
    symptom_tags: ["lbp_nonspecific", "radiculopathy"],
    contraindications: ["마미증후군 증상", "불안정성 골절", "복부 대동맥류 의심"],
    evidence_level: "medium",
    maitland_grade: [],
    recommendation_weight: 0.85,
    patient_position: "서기 자세(standing) 우선, 양발 어깨 넓이",
    therapist_contact: "두상골 → 목표 분절 극돌기 바로 외측 접촉. 요추 facet plane(거의 수직 상방) 방향 활주.",
    key_technique_tip: "서기 자세에서 기능 회복 목표. PILL 반응 없으면 Belt SNAG으로 업그레이드. Self-SNAG: 벨트 또는 타월로 가정 운동 연계.",
    common_mistake: "활주 방향이 순수 PA → 상방(cephalic) 수직 방향으로 조정 / 너무 약한 힘 → 체중 이동 활용, 필요시 Belt SNAG 전환",
    good_response: "굴곡/신전 ROM 즉각 개선, 두상골 압박감, 통증 소실"
  },
  {
    id: "tech-B-008",
    name_ko: "요추 벨트 SNAG",
    name_en: "Lumbar Belt SNAG",
    category: "B",
    category_id: "cat-B",
    category_label: "Mulligan Concept",
    body_part: "lumbar",
    body_part_label: "요추",
    purpose_tags: ["pain_relief", "rom_improvement", "stiffness"],
    target_tags: ["chronic", "hypomobile", "athlete"],
    symptom_tags: ["lbp_nonspecific"],
    contraindications: ["마미증후군 증상", "불안정성 골절", "복부 대동맥류 의심"],
    evidence_level: "medium",
    maitland_grade: [],
    recommendation_weight: 0.82,
    patient_position: "서기 자세(standing), 체중 부하, 양발 어깨 넓이",
    therapist_contact: "치료 벨트 → 목표 분절 극돌기 직하방에 위치. 치료사 엉덩이로 걸어 체중으로 상방 활주 제공.",
    key_technique_tip: "손 SNAG보다 더 강하고 일정한 힘. 큰 체격·심한 강직 → Belt SNAG 우선. Self-Belt SNAG: 침대 헤드보드나 문 손잡이 이용 가정 교육.",
    common_mistake: "벨트가 극돌기 위에 걸림 → 극돌기 직하방에 정확히 위치 / 치료사 팔로 힘 생성 → 엉덩이·몸통 체중 이동으로",
    good_response: "굴곡 ROM 현저한 즉각 개선, 벨트 압박감, 통증 소실"
  },

  {
    id: "tech-B-021",
    name_ko: "요추 신전 SNAG",
    name_en: "Lumbar Extension SNAG",
    category: "B",
    category_id: "cat-B",
    category_label: "Mulligan Concept",
    body_part: "lumbar",
    body_part_label: "요추",
    purpose_tags: ["pain_relief", "rom_improvement"],
    target_tags: ["subacute", "chronic"],
    symptom_tags: ["lbp_nonspecific"],
    contraindications: ["마미증후군 증상", "불안정성 골절", "신전 시 신경 증상 악화"],
    evidence_level: "medium",
    maitland_grade: [],
    recommendation_weight: 0.76,
    patient_position: "서기 자세",
    therapist_contact: "두상골 → 목표 분절 극돌기. 상방 활주 유지하며 환자 허리 신전.",
    key_technique_tip: "요추 신전 통증 환자에서 상방 활주로 신전 시 통증 소실 여부 즉각 확인. 신전 시 하지 방사통 악화 시 즉시 중단.",
    common_mistake: "신전 시 하지 방사통 무시하고 지속 → 즉시 중단 필수",
    good_response: "신전 시 통증 소실, 신전 ROM 즉각 증가"
  },
];

// ═══════════════════════════════════════════════════════════════
// TECHNIQUES_DB_FUTURE — MVP 이후 단계 테크닉 (데이터 보존)
// 현재 비활성화. 향후 흉추·천장관절·어깨·팔꿈치·손목·고관절·무릎·발목 확장 시 활성화.
// ═══════════════════════════════════════════════════════════════

const TECHNIQUES_DB_FUTURE = [

  // ── CATEGORY A ──────────────────────────────────────────────

  // 흉추
  { id: "tech-A-003", body_part: "thoracic", body_part_label: "흉추", category: "A", category_id: "cat-A", name_ko: "흉추 중앙 PA 가동술", name_en: "Thoracic Central PA Mobilization", evidence_level: "high", recommendation_weight: 0.85 },
  { id: "tech-A-004", body_part: "thoracic", body_part_label: "흉추", category: "A", category_id: "cat-A", name_ko: "흉추 단측 PA 가동술", name_en: "Thoracic Unilateral PA Mobilization", evidence_level: "medium", recommendation_weight: 0.75 },

  // 천장관절
  { id: "tech-A-007", body_part: "sacroiliac", body_part_label: "천장관절", category: "A", category_id: "cat-A", name_ko: "천장관절 압박 가동술", name_en: "Sacroiliac Joint Compression Mobilization", evidence_level: "medium", recommendation_weight: 0.68 },

  // 어깨
  { id: "tech-A-008", body_part: "shoulder", body_part_label: "어깨", category: "A", category_id: "cat-A", name_ko: "견관절 하방 활주 가동술", name_en: "GH Inferior Glide Mobilization", evidence_level: "high", recommendation_weight: 0.84 },
  { id: "tech-A-009", body_part: "shoulder", body_part_label: "어깨", category: "A", category_id: "cat-A", name_ko: "견관절 후방 활주 가동술", name_en: "GH Posterior Glide Mobilization", evidence_level: "medium", recommendation_weight: 0.78 },

  // 팔꿈치
  { id: "tech-A-010", body_part: "elbow", body_part_label: "팔꿈치", category: "A", category_id: "cat-A", name_ko: "주관절 가동술", name_en: "Elbow Joint Mobilization", evidence_level: "medium", recommendation_weight: 0.72 },

  // 손목/손
  { id: "tech-A-011", body_part: "wrist_hand", body_part_label: "손목/손", category: "A", category_id: "cat-A", name_ko: "손목 가동술", name_en: "Wrist Mobilization", evidence_level: "medium", recommendation_weight: 0.70 },

  // 고관절
  { id: "tech-A-012", body_part: "hip", body_part_label: "고관절", category: "A", category_id: "cat-A", name_ko: "고관절 견인 가동술", name_en: "Hip Distraction Mobilization", evidence_level: "high", recommendation_weight: 0.86 },
  { id: "tech-A-013", body_part: "hip", body_part_label: "고관절", category: "A", category_id: "cat-A", name_ko: "고관절 후방 활주 가동술", name_en: "Hip Posterior Glide Mobilization", evidence_level: "medium", recommendation_weight: 0.78 },

  // 무릎
  { id: "tech-A-014", body_part: "knee", body_part_label: "무릎", category: "A", category_id: "cat-A", name_ko: "슬관절 PA 가동술", name_en: "Knee PA Mobilization", evidence_level: "medium", recommendation_weight: 0.74 },

  // 발목/발
  { id: "tech-A-015", body_part: "ankle_foot", body_part_label: "발목/발", category: "A", category_id: "cat-A", name_ko: "거골 후방 활주 가동술", name_en: "Talar Posterior Glide Mobilization", evidence_level: "high", recommendation_weight: 0.82 },
  { id: "tech-A-016", body_part: "ankle_foot", body_part_label: "발목/발", category: "A", category_id: "cat-A", name_ko: "발목 견인 가동술", name_en: "Ankle Distraction Mobilization", evidence_level: "medium", recommendation_weight: 0.76 },

  // 흉추 (추가)
  { id: "tech-A-017", body_part: "thoracic", body_part_label: "흉추", category: "A", category_id: "cat-A", name_ko: "흉추 측와위 회전 가동술", name_en: "Thoracic Side-lying Rotation Mobilization", evidence_level: "medium", recommendation_weight: 0.72 },
  { id: "tech-A-018", body_part: "thoracic", body_part_label: "흉추", category: "A", category_id: "cat-A", name_ko: "흉추 신전 가동술", name_en: "Thoracic Extension Mobilization", evidence_level: "medium", recommendation_weight: 0.74 },
  { id: "tech-A-019", body_part: "shoulder", body_part_label: "어깨", category: "A", category_id: "cat-A", name_ko: "견갑흉곽 가동술", name_en: "Scapulothoracic Mobilization", evidence_level: "low", recommendation_weight: 0.62 },
  { id: "tech-A-020", body_part: "knee", body_part_label: "무릎", category: "A", category_id: "cat-A", name_ko: "슬개골 가동술", name_en: "Patellar Mobilization", evidence_level: "medium", recommendation_weight: 0.70 },

  // ── CATEGORY B (Mulligan) ────────────────────────────────────

  // 흉추
  { id: "tech-B-005", body_part: "thoracic", body_part_label: "흉추", category: "B", category_id: "cat-B", name_ko: "흉추 SNAG", name_en: "Thoracic SNAG", evidence_level: "medium", recommendation_weight: 0.78 },
  { id: "tech-B-006", body_part: "thoracic", body_part_label: "흉추", category: "B", category_id: "cat-B", name_ko: "늑골 SNAG", name_en: "Rib SNAG", evidence_level: "low", recommendation_weight: 0.60 },

  // 천장관절
  { id: "tech-B-022", body_part: "sacroiliac", body_part_label: "천장관절", category: "B", category_id: "cat-B", name_ko: "천장관절 MWM", name_en: "Sacroiliac Joint MWM", evidence_level: "low", recommendation_weight: 0.62 },

  // 어깨
  { id: "tech-B-009", body_part: "shoulder", body_part_label: "어깨", category: "B", category_id: "cat-B", name_ko: "어깨 MWM (외전)", name_en: "Shoulder MWM (Abduction)", evidence_level: "high", recommendation_weight: 0.88 },
  { id: "tech-B-010", body_part: "shoulder", body_part_label: "어깨", category: "B", category_id: "cat-B", name_ko: "어깨 MWM (내회전)", name_en: "Shoulder MWM (Internal Rotation)", evidence_level: "medium", recommendation_weight: 0.80 },
  { id: "tech-B-011", body_part: "shoulder", body_part_label: "어깨", category: "B", category_id: "cat-B", name_ko: "어깨 MWM (수평 내전)", name_en: "Shoulder MWM (Horizontal Adduction)", evidence_level: "medium", recommendation_weight: 0.76 },
  { id: "tech-B-012", body_part: "shoulder", body_part_label: "어깨", category: "B", category_id: "cat-B", name_ko: "견쇄관절 MWM", name_en: "AC Joint MWM", evidence_level: "low", recommendation_weight: 0.60 },
  { id: "tech-B-016", body_part: "shoulder", body_part_label: "어깨", category: "B", category_id: "cat-B", name_ko: "어깨 SNAG", name_en: "Shoulder SNAG", evidence_level: "medium", recommendation_weight: 0.74 },

  // 팔꿈치
  { id: "tech-B-013", body_part: "elbow", body_part_label: "팔꿈치", category: "B", category_id: "cat-B", name_ko: "팔꿈치 MWM (외측 상과염)", name_en: "Elbow MWM (Lateral Epicondylalgia)", evidence_level: "high", recommendation_weight: 0.90 },

  // 손목
  { id: "tech-B-020", body_part: "wrist_hand", body_part_label: "손목/손", category: "B", category_id: "cat-B", name_ko: "손목 MWM", name_en: "Wrist MWM", evidence_level: "medium", recommendation_weight: 0.72 },

  // 고관절
  { id: "tech-B-019", body_part: "hip", body_part_label: "고관절", category: "B", category_id: "cat-B", name_ko: "고관절 MWM", name_en: "Hip MWM", evidence_level: "medium", recommendation_weight: 0.76 },

  // 무릎
  { id: "tech-B-014", body_part: "knee", body_part_label: "무릎", category: "B", category_id: "cat-B", name_ko: "무릎 MWM (굴곡)", name_en: "Knee MWM (Flexion)", evidence_level: "high", recommendation_weight: 0.86 },
  { id: "tech-B-017", body_part: "knee", body_part_label: "무릎", category: "B", category_id: "cat-B", name_ko: "무릎 MWM (신전)", name_en: "Knee MWM (Extension)", evidence_level: "medium", recommendation_weight: 0.78 },

  // 발목
  { id: "tech-B-015", body_part: "ankle_foot", body_part_label: "발목/발", category: "B", category_id: "cat-B", name_ko: "발목 MWM (배측굴곡)", name_en: "Ankle MWM (Dorsiflexion)", evidence_level: "high", recommendation_weight: 0.88 },
  { id: "tech-B-018", body_part: "ankle_foot", body_part_label: "발목/발", category: "B", category_id: "cat-B", name_ko: "발목 MWM (내번 염좌 후)", name_en: "Ankle MWM (Post-Inversion Sprain)", evidence_level: "high", recommendation_weight: 0.85 },

];

// 모듈 내보내기 (Node.js 환경)
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { TECHNIQUE_CATEGORIES, TECHNIQUES_DB, TECHNIQUES_DB_FUTURE };
}
