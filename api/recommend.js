// PT 처방 도우미 — AI 추천 서버리스 함수
// Input:  { region, acuity, symptom, preferredMT, sessionHistory }
// Output: { manualTherapy[], exercise[], clinicalNote, sessionSummary }

// 치료사 선호 ID → Supabase category 매핑
const MT_CATEGORY_MAP = {
  mt_joint:   ['category_joint_mobilization', 'category_mulligan'],
  mt_soft:    ['category_mfr', 'category_art', 'category_ctm', 'category_deep_friction', 'category_trigger_point', 'category_anatomy_trains'],
  mt_neuro:   ['category_d_neural'],
  mt_special: ['category_mdt', 'category_scs'],
  mt_edu:     ['category_pne'],
};

// 역방향 맵: category → MT 그룹 ID
const CATEGORY_TO_MT_GROUP = {};
for (const [mtId, cats] of Object.entries(MT_CATEGORY_MAP)) {
  for (const cat of cats) CATEGORY_TO_MT_GROUP[cat] = mtId;
}

const MT_GROUP_LABEL = {
  mt_joint:   '관절가동술 (Maitland · Mulligan · HVLA)',
  mt_soft:    '연부조직 가동술 (MFR · ART · CTM · Deep Friction · Trigger Point · Anatomy Trains)',
  mt_neuro:   '신경가동술',
  mt_special: '특수기법 (MDT · SCS)',
  mt_edu:     '통증 신경과학 교육 (PNE)',
};

// 운동 처방 선호 ID → Supabase category 매핑
const EX_CATEGORY_MAP = {
  ex_neuro:    ['category_ex_neuromuscular'],
  ex_strength: ['category_ex_resistance', 'category_ex_bodyweight'],
  ex_aerobic:  ['category_ex_aerobic'],
};

const EX_PREFERENCE_LABEL = {
  ex_neuro:    '신경근·운동조절 훈련 (Motor Control)',
  ex_strength: '근력·저항성 운동 (Strength/Resistance)',
  ex_aerobic:  '유산소·활동성 운동 (Aerobic)',
};

// 프론트엔드 region 레이블 → DB body_region enum 값 매핑
const REGION_BODY_REGION_MAP = {
  '경추': ['cervical', 'thoracic'],
  '요추': ['lumbar', 'sacroiliac'],
};

// Supabase에서 카테고리별 기법 전체 조회 (body_region 포함)
// 부위 필터는 서버에서 처리: body_region이 NULL(범용)이거나 대상 부위에 해당하는 기법만 반환
async function fetchActiveTechniques(categories, bodyRegions = []) {
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_KEY || categories.length === 0) return [];

  const catFilter = categories.map(c => `category.eq.${c}`).join(',');
  const selectFields = `name_ko,category,body_region,patient_position,therapist_position,contact_point,direction,technique_steps`;
  const headers = { 'apikey': SUPABASE_KEY, 'Authorization': `Bearer ${SUPABASE_KEY}` };
  const url = `${SUPABASE_URL}/rest/v1/techniques?is_active=eq.true&or=(${catFilter})&select=${selectFields}`;

  try {
    const res = await fetch(url, { headers });
    if (!res.ok) return [];
    const data = await res.json();
    const all = (data || []).filter(t => t.name_ko);
    // 서버에서 body_region 필터링: NULL(범용) 또는 대상 부위와 일치하는 기법만 포함
    if (bodyRegions.length > 0) {
      return all.filter(t => !t.body_region || bodyRegions.includes(t.body_region));
    }
    return all;
  } catch {
    return [];
  }
}

// LLM 호출 + JSON 파싱 헬퍼 (실패 시 null 반환)
async function callLLMAndParse(systemPrompt, userPrompt, apiKey) {
  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 4096,
        system: systemPrompt,
        messages: [{ role: 'user', content: userPrompt }]
      })
    });
    if (!response.ok) {
      const errText = await response.text();
      console.error('Anthropic API 오류:', response.status, errText);
      return { error: `AI 서비스 오류 (${response.status})`, status: 502 };
    }
    const data = await response.json();
    const rawText = data?.content?.[0]?.text || '';
    const jsonMatch = rawText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      console.error('JSON 추출 실패. 원문:', rawText.slice(0, 200));
      return { error: 'AI 응답 파싱 오류', status: 502 };
    }
    try {
      return { result: JSON.parse(jsonMatch[0]) };
    } catch (parseErr) {
      console.error('JSON.parse 실패:', parseErr.message, '| 원문:', rawText.slice(0, 400));
      return { error: 'AI 응답 파싱 오류', status: 502 };
    }
  } catch (err) {
    console.error('LLM 호출 오류:', err.message);
    return { error: '서버 오류: ' + err.message, status: 500 };
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
  // 프롬프트 크기 최적화: 처음 3단계만 포함 (LLM이 선택·재작성에 충분한 정보)
  const steps = Array.isArray(t.technique_steps)
    ? t.technique_steps.slice(0, 3).map(s => `    ${s.step}. ${s.instruction}`).join('\n')
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

  // region 레이블 → body_region enum 값 변환 (관련 없는 부위 기법 필터링)
  const bodyRegions = REGION_BODY_REGION_MAP[region] || [];

  // Supabase에서 is_active=true 테크닉 + 카테고리 원칙 병렬 조회
  let activeMT = [], activeEX = [], categoryPrinciplesMap = {};
  try {
    const fetches = [fetchActiveTechniques(mtCategories, bodyRegions), fetchCategoryPrinciples()];
    if (exCategories.length > 0) fetches.push(fetchActiveTechniques(exCategories, bodyRegions));
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

  // 알고리즘: MT 그룹별로 분류 후 최대 3개 사전 선택 (LLM이 선택하지 않음)
  let allowedMTText;
  if (activeMT.length > 0) {
    const techniquesByGroup = {};
    preferredMT.forEach(mtId => { techniquesByGroup[mtId] = []; });
    activeMT.forEach(t => {
      const mtId = CATEGORY_TO_MT_GROUP[t.category];
      if (mtId && techniquesByGroup[mtId]) techniquesByGroup[mtId].push(t);
    });

    // 그룹당 최대 3개 사전 선택 (추후 가중치 기반으로 고도화 예정)
    preferredMT.forEach(mtId => {
      techniquesByGroup[mtId] = techniquesByGroup[mtId].slice(0, 3);
    });

    // 그룹 구분 없이 단일 평면 목록으로 제시 (LLM이 임상 적용 순서로 통합 정렬)
    const allSelectedMT = preferredMT.flatMap(mtId => {
      const label = MT_GROUP_LABEL[mtId] || mtId;
      return (techniquesByGroup[mtId] || []).map(t => formatTechniqueForPrompt(t, label));
    });
    allowedMTText = `Manual Therapy 기법 목록 (치료 세션에서 먼저 적용할 기법부터 임상 적용 순서로 전부 정렬. group 경계 무시. 추가·제거 금지):\n\n` +
      allSelectedMT.join('\n\n');
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
clinicalNote 작성 원칙: 원인을 단정하지 말고 가능성으로 표현하세요. 단정 표현(~입니다, ~때문입니다)은 옐로우 플래그를 만들 수 있습니다.
  ✗ "요추 불안정성으로 인한 통증입니다" / "디스크 문제로 발생한 증상입니다"
  ✓ "요추 주변 근육의 협응이 통증에 기여하고 있을 수 있습니다" / "신경 민감화가 관여했을 가능성이 있습니다"
  가능성 표현 예시: ~일 수 있습니다, ~가능성이 있습니다, ~기여할 수 있습니다, ~관련이 있을 수 있습니다
⚠️ 중요: 아래 허용 목록에 있는 기법만 선택하여 우선순위 순으로 나열하세요. 목록에 없는 기법 생성 절대 금지.
응답은 반드시 순수 JSON만 출력하세요. 마크다운 금지.

언어 원칙 (반드시 준수):
1. 자세·동작 설명은 초보 치료사도 바로 이해하는 쉬운 한국어 사용. 한자어·의학 약어 금지.
   ✗ 양와위, 측와위, 복와위, 반좌위, 복위, 전굴, 후굴, 측굴, 촉진, 신연, 거상
   ✓ 등 대고 눕기(양와위→), 옆으로 눕기(측와위→), 엎드려 눕기(복와위→), 등받이 세워 앉기, 앞으로 굽히기, 뒤로 젖히기, 옆으로 기울이기, 손으로 부드럽게 누르기, 팔 들어올리기
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

환자 정보(부위: ${region}, 시기: ${acuity}, 증상: ${symptom})에 맞게:
▸ MT: 모든 기법을 치료 세션 적용 순서로 통합 정렬 (예: 연부조직 이완→관절가동→신경가동, 또는 상황에 따라 다른 순서. group 경계 무시. 추가·제거 금지)
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
  "clinicalNote": "① 1순위 [기법명]→[이 순서로 먼저 적용하는 임상 근거], 2순위 [기법명]→[이유] ② 환자 임상 메시지 (가능성 표현, 전체 200자 이내)"
}
MT: 주어진 기법 전부 포함(추가·제거 금지) / 운동처방: 3개 / targetMuscles: 최대 3개
techniqueId는 [MT-XXX] 또는 [EX-XXX] ID를 그대로 복사.`;

  // 1차 LLM 호출
  const { result: firstResult, error: llmErr, status: llmStatus } =
    await callLLMAndParse(systemPrompt, userPrompt, ANTHROPIC_API_KEY);

  if (llmErr) return res.status(llmStatus).json({ error: llmErr });

  let result = firstResult;

  // 아급성에서 MT 추천이 비어 있으면 급성으로 fallback 재시도
  if (acuity === '아급성' && (result.manualTherapy || []).length === 0) {
    console.log('[fallback] 아급성 MT 결과 없음 → 급성으로 재시도');
    const fallbackPrompt = userPrompt.replace(/아급성/g, '급성');
    const { result: fbResult } = await callLLMAndParse(systemPrompt, fallbackPrompt, ANTHROPIC_API_KEY);
    if (fbResult && (fbResult.manualTherapy || []).length > 0) {
      result = fbResult;
      result._usedFallbackAcuity = '급성';
    }
  }

  try {
    // MT 그룹당 최대 3개 강제 적용 (LLM이 초과 선택 시 서버에서 잘라냄)
    if (preferredMT.length > 0 && result.manualTherapy) {
      const groupCounts = {};
      result.manualTherapy = result.manualTherapy.filter(item => {
        const t = indexedTechniques.get(item.techniqueId);
        const catKey = t?.category;
        const mtGroup = (catKey && CATEGORY_TO_MT_GROUP[catKey]) || '_ungrouped';
        groupCounts[mtGroup] = (groupCounts[mtGroup] || 0) + 1;
        return groupCounts[mtGroup] <= 3;
      });
    }

    // techniqueId(인덱스 ID)로 기법 lookup → category 확보 → categoryInfo 부착
    (result.manualTherapy || []).forEach(item => {
      const t = indexedTechniques.get(item.techniqueId);
      const catKey = t ? t.category : null;
      const catData = catKey ? categoryPrinciplesMap[catKey] : null;
      if (catData) {
        item.categoryInfo = {
          category_key: catKey,
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
          category_key: catKey,
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
    console.error('후처리 오류:', err);
    return res.status(500).json({ error: '서버 오류: ' + err.message });
  }
}
