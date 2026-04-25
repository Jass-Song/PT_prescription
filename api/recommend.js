// PT 처방 도우미 — AI 추천 서버리스 함수
// Input:  { region, acuity, symptom, preferredMT, preferredEX, sessionHistory }
// Output: { manualTherapy[], exercise[], clinicalNote, sessionSummary }

// 치료사 선호 ID → Supabase category 매핑
const MT_CATEGORY_MAP = {
  mt_maitland:  ['category_joint_mobilization'],
  mt_mulligan:  ['category_mulligan'],
  mt_soft:      ['category_mfr'],          // 연부조직 가동술 = MFR만 (IASTM 제외)
  mt_neuro:     ['category_d_neural'],
  mt_mckenzie:  ['category_exercise01'],
  mt_hvla:      ['category_joint_mobilization'],
};

const EX_CATEGORY_MAP = {
  ex_stab:    ['category_exercise01'],
  ex_prog:    ['category_exercise01'],
  ex_strength:['category_exercise01'],
  ex_rom:     ['category_exercise01'],
  ex_stretch: ['category_exercise01'],
  ex_self:    ['category_exercise01'],
  ex_wbear:   ['category_exercise01'],
  ex_rehab:   ['category_exercise01'],
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
    // category_key → { name_ko, name_en, basic_principles } 맵으로 변환
    return Object.fromEntries((data || []).map(c => [c.category_key, c]));
  } catch {
    return {};
  }
}

// techniques.category enum → technique_categories.category_key 매핑
const ENUM_TO_CATEGORY_KEY = {
  'category_joint_mobilization': 'category_a_joint_mobilization',
  'category_mulligan':           'category_b_mulligan',
  'category_mfr':                'category_c_mfr',
  'category_d_neural':           'category_d_neural',
  'category_exercise01':         'category_exercise01',
};

// 기법 객체를 LLM 프롬프트용 텍스트 블록으로 변환
function formatTechniqueForPrompt(t) {
  const steps = Array.isArray(t.technique_steps)
    ? t.technique_steps.map(s => `    ${s.step}. ${s.instruction}`).join('\n')
    : '';

  return [
    `【${t.name_ko} | categoryEnum:${t.category}】`,
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

  // preferredMT/EX ID → Supabase category 변환
  const mtCategories = [...new Set(preferredMT.flatMap(id => MT_CATEGORY_MAP[id] || []))];
  const exCategories = [...new Set(preferredEX.flatMap(id => EX_CATEGORY_MAP[id] || []))];

  // Supabase에서 is_active=true 테크닉만 조회 (IASTM 등 비활성화 자동 제외)
  let activeMT = [], activeEX = [], categoryPrinciplesMap = {};
  try {
    [activeMT, activeEX, categoryPrinciplesMap] = await Promise.all([
      fetchActiveTechniques(mtCategories),
      fetchActiveTechniques(exCategories),
      fetchCategoryPrinciples(),
    ]);
  } catch {
    // Supabase 조회 실패 시 LLM이 자체 판단으로 추천
  }

  // 허용 목록 텍스트 (LLM에 전달) — DB 상세 데이터 포함
  const allowedMTText = activeMT.length > 0
    ? `사용 가능한 Manual Therapy 기법 목록 (이 목록에서만 추천할 것):\n\n${activeMT.map(t => formatTechniqueForPrompt(t)).join('\n\n')}`
    : `선호 기법: ${preferredMT.join(', ') || '지정 없음'}`;

  const allowedEXText = activeEX.length > 0
    ? `사용 가능한 Exercise 목록 (이 목록에서만 추천할 것):\n\n${activeEX.map(t => formatTechniqueForPrompt(t)).join('\n\n')}`
    : `선호 운동: ${preferredEX.join(', ') || '지정 없음'}`;

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
4. 아래 기법 목록의 DB 정보(환자자세·치료사위치·접촉부위·방향·시술단계)를 기반으로 각 필드를 재작성하세요.
   - patientPosition: DB 환자자세를 쉬운 한국어로 변환 (25자 이내)
   - therapistHands: DB "치료사위치 + 접촉부위"를 결합하여 쉬운 한국어로 (25자 이내)
   - movement: DB 시술단계를 번호 형식으로 요약 (각 단계 15자 이내)
   - targetMuscles: DB에 없음 — 기법명과 신체부위 기반으로 임상 지식에서 추론
5. DB 정보가 없는 기법은 선택하지 마세요.`;

  // Exercise 섹션은 Supabase에 활성 데이터가 있을 때만 포함
  const hasExData = activeEX.length > 0;

  const exPromptSection = hasExData ? `

${allowedEXText}` : '';

  const exSchemaSection = hasExData ? `,
  "exercise": [
    {
      "name": "운동명 (10자 이내)",
      "startPosition": "쉬운 일상 언어로 시작 자세 (25자 이내)",
      "therapistGuide": "치료사 역할 설명 (25자 이내)",
      "movement": "1. [단계] 2. [단계] 3. [단계] 4. [단계] 번호 형식 필수",
      "sets": "처방 (예: 3×10회, 2세트)",
      "targetMuscles": ["한국어(영어)", "한국어(영어)"],
      "cue": "환자에게 말하는 쉬운 큐잉 1문장"
    }
  ]` : '';

  const exCountNote = hasExData ? ', exercise는 정확히 3개' : '';

  const userPrompt = `환자 정보:
- 부위: ${region}
- 시기: ${acuity}
- 증상 패턴: ${symptom}

${allowedMTText}${exPromptSection}
${historyText}

위 허용 목록에서 환자(부위: ${region}, 시기: ${acuity}, 증상: ${symptom})에게 가장 적합한 기법 3개를 선택하고,
각 기법의 DB 정보를 쉬운 한국어로 재작성하여 아래 형식으로만 반환하세요.
목록에 없는 기법 생성 금지.

반환 형식 (JSON 외 출력 금지):
{
  "manualTherapy": [
    {
      "technique": "기법명 (10자 이내)",
      "categoryEnum": "입력 데이터의 categoryEnum 값을 그대로 복사",
      "patientPosition": "쉬운 일상 언어로 자세 설명 (25자 이내, 의학 약어 금지)",
      "therapistHands": "손 배치 위치와 방법 (25자 이내)",
      "movement": "1. [단계] 2. [단계] 3. [단계] 4. [단계] 번호 형식 필수",
      "targetMuscles": ["한국어(영어)", "한국어(영어)"],
      "patientFeedback": "올바른 반응: [증상]. 주의신호: [경고]"
    }
  ]${exSchemaSection},
  "clinicalNote": "임상 핵심 메시지 1~2문장 (100자 이내)"
}
manualTherapy는 정확히 3개${exCountNote}, targetMuscles는 최대 3개.`;

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

    // exercise 데이터가 없으면 빈 배열 보장 (Supabase 미설정 시 LLM이 임의 생성하지 않도록)
    if (!hasExData) result.exercise = [];

    // 각 기법에 카테고리 원칙 attach
    (result.manualTherapy || []).forEach(item => {
      const categoryKey = ENUM_TO_CATEGORY_KEY[item.categoryEnum] || item.categoryEnum;
      const catData = categoryPrinciplesMap[categoryKey];
      if (catData) {
        item.categoryInfo = {
          name_ko: catData.name_ko,
          name_en: catData.name_en,
          basic_principles: catData.basic_principles || [],
        };
      }
      delete item.categoryEnum;
    });

    // sessionSummary는 서버에서 직접 조립 (LLM에게 맡기지 않음)
    result.sessionSummary = {
      region,
      acuity,
      symptom,
      mt: preferredMT,
      ex: preferredEX
    };

    return res.status(200).json(result);

  } catch (err) {
    console.error('서버 오류:', err);
    return res.status(500).json({ error: '서버 오류: ' + err.message });
  }
}
