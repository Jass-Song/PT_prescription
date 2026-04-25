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

// Supabase에서 is_active=true 테크닉 이름 목록 조회
async function fetchActiveTechniques(categories) {
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_KEY || categories.length === 0) return [];

  const catFilter = categories.map(c => `category.eq.${c}`).join(',');
  const url = `${SUPABASE_URL}/rest/v1/techniques?is_active=eq.true&or=(${catFilter})&select=name_ko,category`;

  try {
    const res = await fetch(url, {
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`
      }
    });
    if (!res.ok) return [];
    const data = await res.json();
    return (data || []).map(t => t.name_ko).filter(Boolean);
  } catch {
    return [];
  }
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
  const [activeMT, activeEX] = await Promise.all([
    fetchActiveTechniques(mtCategories),
    fetchActiveTechniques(exCategories),
  ]);

  // 허용 목록 텍스트 (LLM에 전달)
  const allowedMTText = activeMT.length > 0
    ? `사용 가능한 Manual Therapy 기법 목록 (이 목록에서만 추천할 것):\n${activeMT.map(n => `- ${n}`).join('\n')}`
    : `선호 기법: ${preferredMT.join(', ') || '지정 없음'}`;

  const allowedEXText = activeEX.length > 0
    ? `사용 가능한 Exercise 목록 (이 목록에서만 추천할 것):\n${activeEX.map(n => `- ${n}`).join('\n')}`
    : `선호 운동: ${preferredEX.join(', ') || '지정 없음'}`;

  // 세션 히스토리 요약 (중복 추천 방지)
  const historyText = sessionHistory.length > 0
    ? `\n\n이전 세션 기록 (중복 추천 피할 것):\n${sessionHistory.map((h, i) => `${i+1}. ${JSON.stringify(h)}`).join('\n')}`
    : '';

  const systemPrompt = `당신은 K-Movement Optimism의 임상 물리치료사 멘토입니다.
근거기반 재활 원칙을 따르며 반-카타스트로파이징(anti-catastrophizing) 접근을 강조합니다.
핵심 원칙: "통증 ≠ 손상", "몸은 적응적이다", "Calm things down, then build things back up"
KPM 프레임(자세 불균형, 정렬 이상) 사용 금지. 공포 유발 표현 금지.
⚠️ 중요: 아래에 제공된 허용 목록에 없는 기법은 절대 추천하지 마세요.
응답은 반드시 순수 JSON만 출력하세요. 마크다운 금지.`;

  const userPrompt = `환자 정보:
- 부위: ${region}
- 시기: ${acuity}
- 증상 패턴: ${symptom}

${allowedMTText}

${allowedEXText}
${historyText}

위 환자에게 적합한 임상 추천을 아래 JSON 형식으로 작성하세요.
반드시 위의 허용 목록에 있는 기법만 추천하세요. 목록에 없는 기법 추천 금지.

반환 형식:
{
  "manualTherapy": [
    {
      "technique": "기법명",
      "patientPosition": "환자 자세",
      "therapistHands": "치료사 손 위치",
      "movement": "동작 방향 및 강도",
      "targetMuscles": ["목표 구조물1", "목표 구조물2"],
      "patientFeedback": "올바른 반응 vs 주의 신호"
    }
  ],
  "exercise": [
    {
      "name": "운동명",
      "startPosition": "시작 자세",
      "therapistGuide": "치료사 가이드",
      "movement": "동작 설명",
      "sets": "세트 및 반복 처방",
      "targetMuscles": ["목표 근육"],
      "cue": "환자 큐잉 멘트"
    }
  ],
  "clinicalNote": "이 환자에게 특히 중요한 임상 포인트 (KMO 철학 기반)"
}`;

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
        max_tokens: 2000,
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
