// PT 처방 도우미 — AI 추천 서버리스 함수
// Input:  { region, acuity, symptom, preferredMT, sessionHistory }
// Output: { manualTherapy[], exercise[], clinicalNote, sessionSummary }

// 치료사 선호 ID → Supabase category 매핑
const MT_CATEGORY_MAP = {
  mt_joint: ['category_joint_mobilization', 'category_mulligan'],
  mt_soft:  ['category_mfr'],
  mt_neuro: ['category_d_neural'],
};

// 역방향 맵: category → MT 그룹 ID
const CATEGORY_TO_MT_GROUP = {};
for (const [mtId, cats] of Object.entries(MT_CATEGORY_MAP)) {
  for (const cat of cats) CATEGORY_TO_MT_GROUP[cat] = mtId;
}

const MT_GROUP_LABEL = {
  mt_joint: '관절가동술 (Maitland · Mulligan · HVLA)',
  mt_soft:  '연부조직 가동술 (MFR)',
  mt_neuro: '신경가동술',
};

// 운동 처방 선호 ID → Supabase category 매핑
const EX_CATEGORY_MAP = {
  ex_neuro:    ['category_exercise01', 'category_f_therapeutic_exercise'],
  ex_strength: ['category_exercise01', 'category_f_therapeutic_exercise'],
  ex_aerobic:  ['category_exercise01', 'category_f_therapeutic_exercise'],
};

const EX_PREFERENCE_LABEL = {
  ex_neuro:    '신경근·운동조절 훈련 (Motor Control)',
  ex_strength: '근력·저항성 운동 (Strength/Resistance)',
  ex_aerobic:  '유산소·활동성 운동 (Aerobic)',
};

// Supabase에서 is_active=true 테크닉 상세 데이터 조회
async function fetchActiveTechniques(categories) {
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_KEY || categories.length === 0) return [];

  const catFilter = categories.map(c => `category.eq.${c}`).join(',');
  const url = `${SUPABASE_URL}/rest/v1/techniques?is_active=eq.true&or=(${catFilter})` +
    `&select=name_ko,category,patient_position,therapist_position,contact_point,direction,technique_steps`;

  try {
    const res = await fetch(url, {
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`
      }
    });
    if (!res.ok) return [];
    const data = await res.json();
    return (data || []).filter(t => t.name_ko);
  } catch {
    return [];
  }
}

// 카테고리 일반 원칙(basic_principles) 조회
// category_key를 구/신 두 형태로 모두 인덱싱 (migration 004b가 category_a_ → category_ 로 rename했기 때문)
async function fetchCategoryPrinciples() {
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_KEY) return {};

  const url = `${SUPABASE_URL}/rest/v1/technique_categories?is_active=eq.true` +
    `&select=category_key,name_ko,name_en,basic_principles`;

  try {
    const res = await fetch(url, {
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`
      }
    });
    if (!res.ok) return {};
    const data = await res.json();
    const map = {};
    (data || []).forEach(c => {
      if (!c.category_key || !Array.isArray(c.basic_principles) || c.basic_principles.length === 0) return;
      // 원래 key로 인덱싱
      map[c.category_key] = c;
      // letter prefix 제거 버전도 인덱싱 (category_a_joint_mobilization → category_joint_mobilization)
      const withoutPrefix = c.category_key.replace(/^(category|group)_[a-z]_/, '$1_');
      if (withoutPrefix !== c.category_key) map[withoutPrefix] = c;
      // letter prefix 추가 버전도 인덱싱 (category_joint_mobilization → category_a_joint_mobilization)
      if (c.category_key.match(/^category_(?![a-z]_)/)) {
        map[c.category_key.replace(/^category_/, 'category_a_')] = c;
      }
    });
    return map;
  } catch {
    return {};
  }
}

// 기법 객체를 LLM 프롬프트용 텍스트 블록으로 변환
// groupLabel: 사용자 그룹명 (category 필드 대신 표시 — LLM이 category 경계로 그룹을 오해하는 것 방지)
function formatTechniqueForPrompt(t, groupLabel) {
  const steps = Array.isArray(t.technique_steps)
    ? t.technique_steps.map(s => `    ${s.step}. ${s.instruction}`).join('\n')
    : '';

  return [
    `[${t._promptId}] 【${t.name_ko}】`,
    `  group: ${groupLabel}`,
    `  환자자세: ${t.patient_position || ''}`,
    `  치료사위치: ${t.therapist_position || ''}`,
    `  접촉부위: ${t.contact_point || ''}`,
    `  방향: ${t.direction || ''}`,
    steps ? `  시술단계:\n${steps}` : '',
  ].filter(Boolean).join('\n');
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const {
    region,
    acuity,
    symptom,
    preferredMT = [],
    preferredEX = [],
    sessionHistory = []
  } = req.body;

  if (!region || !acuity || !symptom) {
    return res.status(400).json({ error: '필수 항목 누락: region, acuity, symptom' });
  }

  const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY;
  if (!ANTHROPIC_API_KEY) {
    return res.status(500).json({ error: 'API 키 설정 오류' });
  }

  // preferredMT ID → Supabase category 변환
  const mtCategories = [...new Set(preferredMT.flatMap(id => MT_CATEGORY_MAP[id] || []))];
  const exCategories = [...new Set(preferredEX.flatMap(id => EX_CATEGORY_MAP[id] || []))];

  // Supabase에서 is_active=true 테크닉 + 카테고리 원칙 병렬 조회
  let activeMT = [], activeEX = [], categoryPrinciplesMap = {};
  try {
    const fetches = [fetchActiveTechniques(mtCategories), fetchCategoryPrinciples()];
    if (exCategories.length > 0) fetches.push(fetchActiveTechniques(exCategories));
    const results = await Promise.all(fetches);
    activeMT = results[0];
    categoryPrinciplesMap = results[1];
    activeEX = results[2] || [];
  } catch (e) {
    console.error('[DEBUG] Supabase fetch error:', e);
  }


  // MT 기법에 고유 인덱스 ID 부여
  const indexedTechniques = new Map(); // 'MT-001' → technique object
  let counter = 1;
  activeMT.forEach(t => {
    const id = `MT-${String(counter++).padStart(3, '0')}`;
    t._promptId = id;
    indexedTechniques.set(id, t);
  });

  // EX 기법에 고유 인덱스 ID 부여
  const indexedExercises = new Map(); // 'EX-001' → technique object
  let exCounter = 1;
  activeEX.forEach(t => {
    const id = `EX-${String(exCounter++).padStart(3, '0')}`;
    t._promptId = id;
    indexedExercises.set(id, t);
  });

  // 허용 목록 텍스트 — MT 그룹별로 분리하여 LLM에 전달 (category 필드 숨김)
  let allowedMTText;
  if (activeMT.length > 0) {
    // 기법을 MT 그룹별로 분류
    const techniquesByGroup = {};
    preferredMT.forEach(mtId => { techniquesByGroup[mtId] = []; });
    activeMT.forEach(t => {
      const mtId = CATEGORY_TO_MT_GROUP[t.category];
      if (mtId && techniquesByGroup[mtId]) techniquesByGroup[mtId].push(t);
    });

    allowedMTText = `사용 가능한 Manual Therapy 기법 목록 (그룹별, 각 === 섹션에서 정확히 3개씩 선택):\n\n` +
      preferredMT.map(mtId => {
        const label = MT_GROUP_LABEL[mtId] || mtId;
        const techs = techniquesByGroup[mtId] || [];
        return `=== [${label}] ===\n${techs.map(t => formatTechniqueForPrompt(t, label)).join('\n\n')}`;
      }).join('\n\n');
  } else {
    allowedMTText = `선호 기법: ${preferredMT.join(', ') || '지정 없음'}`;
  }

  // 운동 처방 허용 목록 텍스트
  const preferenceLabels = preferredEX.map(id => EX_PREFERENCE_LABEL[id]).filter(Boolean);
  const allowedEXText = activeEX.length > 0
    ? `\n\n=== 운동 처방 목록 (환자 상태 + 치료사 선호에 맞춰 3개 선택) ===\n` +
      `치료사 선호 유형: ${preferenceLabels.join(', ') || '전체'}\n\n` +
      activeEX.map(t => formatTechniqueForPrompt(t, '운동처방')).join('\n\n')
    : '';

  // 세션 히스토리 요약 (중복 추천 방지)
  const historyText = sessionHistory.length > 0
    ? `\n\n이전 세션 기록 (중복 추천 피할 것):\n${sessionHistory.map((h, i) => `${i+1}. ${JSON.stringify(h)}`).join('\n')}`
    : '';

  const systemPrompt = `당신은 근거기반 임상 물리치료사 멘토입니다.
반-카타스트로파이징(anti-catastrophizing) 접근을 강조합니다.
핵심 원칙: "통증 ≠ 손상", "몸은 적응적이다", "Calm things down, then build things back up"
자세 불균형·정렬 이상 프레임 사용 금지. 공포 유발 표현 금지.
⚠️ 중요: 아래 허용 목록에 있는 기법만 선택하여 우선순위 순으로 나열하세요. 목록에 없는 기법 생성 절대 금지.
응답은 반드시 순수 JSON만 출력하세요. 마크다운 금지.

언어 원칙 (반드시 준수):
1. 자세·동작 설명은 초보 치료사도 바로 이해하는 쉬운 한국어 사용. 한자어·의학 약어 금지.
   ✗ 반좌위, 복위, 복와위, 전굴, 후굴, 측굴, 촉진, 신연, 거상
   ✓ 등받이 세워 앉기, 엎드려 눕기, 앞으로 굽히기, 뒤로 젖히기, 옆으로 기울이기, 손으로 부드럽게 누르기, 팔 들어올리기
2. 신체 부위명과 해부학 구조물은 반드시 "한국어(영어)" 형식으로 작성.
   - 신체 부위: 경추(cervical spine), 흉추(thoracic spine), 요추(lumbar spine), 천장관절(sacroiliac joint), 고관절(hip), 슬관절(knee), 견관절(shoulder)
   - 해부학 구조물: 척추기립근(erector spinae), 다열근(multifidus), 후두하근(suboccipital muscles), 요방형근(quadratus lumborum)
   - technique 필드(기법명)에도 신체 부위는 반드시 영어 병기. 예: "경추(cervical spine) 중앙 PA 가동술"
3. movement 필드는 반드시 "1. [동작] 2. [동작] 3. [동작] 4. [동작]" 번호 단계 형식으로 작성.
   예: "1. 양손을 극돌기 위에 올려놓기 2. 천천히 아래 방향으로 압력 가하기 3. 환자 반응 보며 5초 유지 4. 서서히 압력 제거"
4. MT 기법: DB 정보(환자자세·치료사위치·접촉부위·방향·시술단계)를 기반으로 재작성.
   - patientPosition: DB 환자자세 → 쉬운 한국어 (25자 이내)
   - therapistHands: DB "치료사위치 + 접촉부위" 결합 (25자 이내)
5. 운동 처방 기법: DB 정보(환자자세·방향·시술단계)를 기반으로 재작성.
   - patientPosition: 운동 시작 자세 → 쉬운 한국어 (25자 이내)
   - therapistHands: 세트/횟수 또는 핵심 동작 포인트 (25자 이내)
6. DB 정보가 없는 기법은 선택하지 마세요.
7. 각 기법의 ID를 techniqueId 필드에 정확히 복사하세요. 절대 변형 금지.
   MT 기법: [MT-007] → "techniqueId": "MT-007" / EX 기법: [EX-003] → "techniqueId": "EX-003"`;

  // exercise 스키마는 운동 처방 데이터가 있을 때만 포함
  const exerciseSchema = allowedEXText
    ? `,\n  "exercise": [\n    {\n      "techniqueId": "EX-001",\n      "technique": "운동명 (10자 이내)",\n      "patientPosition": "시작 자세 (25자 이내)",\n      "therapistHands": "세트/횟수 또는 동작 포인트 (25자 이내)",\n      "movement": "1. [단계] 2. [단계] 3. [단계] 4. [단계]",\n      "targetMuscles": ["한국어(영어)"],\n      "patientFeedback": "올바른 반응: [증상]. 주의신호: [경고]"\n    }\n  ]`
    : '';

  const userPrompt = `환자 정보:
- 부위: ${region}
- 시기: ${acuity}
- 증상 패턴: ${symptom}

${allowedMTText}${allowedEXText}
${historyText}

위 허용 목록에서 환자(부위: ${region}, 시기: ${acuity}, 증상: ${symptom})에게
▸ MT: 각 === 섹션별로 정확히 3개씩 선택 (섹션 2개 → 총 6개, 1개 → 총 3개)
▸ 운동: 치료사 선호 유형과 환자 상태를 고려하여 3개 선택
DB 정보를 쉬운 한국어로 재작성하여 아래 형식으로만 반환하세요. 목록에 없는 기법 생성 금지.

반환 형식 (JSON 외 출력 금지):
{
  "manualTherapy": [
    {
      "techniqueId": "MT-001",
      "technique": "기법명 (10자 이내)",
      "patientPosition": "쉬운 일상 언어로 자세 설명 (25자 이내, 의학 약어 금지)",
      "therapistHands": "손 배치 위치와 방법 (25자 이내)",
      "movement": "1. [단계] 2. [단계] 3. [단계] 4. [단계] 번호 형식 필수",
      "targetMuscles": ["한국어(영어)", "한국어(영어)"],
      "patientFeedback": "올바른 반응: [증상]. 주의신호: [경고]"
    }
  ]${exerciseSchema},
  "clinicalNote": "임상 핵심 메시지 1~2문장 (100자 이내)"
}
MT: 섹션당 3개 / 운동처방: 3개 / targetMuscles: 최대 3개
techniqueId는 [MT-XXX] 또는 [EX-XXX] ID를 그대로 복사.`;

  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5',
        max_tokens: 4096,
        system: systemPrompt,
        messages: [{ role: 'user', content: userPrompt }]
      })
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error('Anthropic API 오류:', response.status, errText);
      return res.status(502).json({ error: `AI 서비스 오류 (${response.status})` });
    }

    const data = await response.json();
    const rawText = data?.content?.[0]?.text || '';

    // JSON 추출 (마크다운 코드블록 제거)
    const jsonMatch = rawText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      console.error('JSON 파싱 실패. 원문:', rawText.slice(0, 200));
      return res.status(502).json({ error: 'AI 응답 파싱 오류' });
    }

    const result = JSON.parse(jsonMatch[0]);
    // techniqueId(인덱스 ID)로 기법 lookup → category 확보 → categoryInfo 부착
    (result.manualTherapy || []).forEach(item => {
      const t = indexedTechniques.get(item.techniqueId);
      const catKey = t ? t.category : null;
      const catData = catKey ? categoryPrinciplesMap[catKey] : null;
      if (catData) {
        item.categoryInfo = {
          name_ko: catData.name_ko,
          name_en: catData.name_en,
          basic_principles: catData.basic_principles || [],
        };
      }
    });

    // exercise categoryInfo 부착 (EX 인덱스 ID로 lookup)
    (result.exercise || []).forEach(item => {
      const t = indexedExercises.get(item.techniqueId);
      const catKey = t ? t.category : 'category_exercise01';
      const catData = categoryPrinciplesMap[catKey];
      if (catData) {
        item.categoryInfo = {
          name_ko: catData.name_ko,
          name_en: catData.name_en,
          basic_principles: catData.basic_principles || [],
        };
      }
    });

    result.sessionSummary = {
      region,
      acuity,
      symptom,
      mt: preferredMT,
      ex: preferredEX,
    };

    return res.status(200).json(result);

  } catch (err) {
    console.error('서버 오류:', err);
    return res.status(500).json({ error: '서버 오류: ' + err.message });
  }
}
