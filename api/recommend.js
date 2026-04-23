// Vercel Serverless Function
// Claude API를 호출해서 추천 결과 반환

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { region, acuity, symptom, preferredMT, preferredEX, sessionHistory = [] } = req.body;

  const sessionContext = sessionHistory && sessionHistory.length > 0
    ? `\n\n**이전 세션 기록 (중복 없이 다양한 기법 추천에 활용):**\n${sessionHistory.map((h, i) => `세션 ${i+1}: MT - ${h.mt.join(', ')} / EX - ${h.ex.join(', ')}`).join('\n')}`
    : '';

  const prompt = `당신은 초보 물리치료사를 위한 한국의 근거기반 물리치료 전문 멘토입니다. 초보 치료사가 즉시 임상에서 실행할 수 있도록 매우 구체적이고 단계적인 지침을 제공하세요.

**환자 정보:**
- 통증 부위: ${region}
- 시기: ${acuity}
- 증상 패턴: ${symptom}

**치료사 선호 기법 (이 목록 내에서만 추천):**
- Manual Therapy: ${preferredMT.join(', ')}
- Exercise: ${preferredEX.join(', ')}

**핵심 원칙:**
- 통증 ≠ 손상 (반카타스트로파이징 원칙)
- "Calm things down, then build things back up" (Greg Lehman)
- 근거기반 접근, 환자에게 공포 유발 금지${sessionContext}

**응답 요구사항 — 초보 치료사를 위해 극도로 구체적으로:**

Manual Therapy 각 기법마다 반드시 포함:
1. 환자 자세 (침대/의자, 앉기/눕기, 고개/팔 위치 등)
2. 치료사 손 위치 (어느 손이 어느 뼈/근육/인대에 접촉하는지)
3. 동작 방향과 힘의 강도 (Maitland grade, 속도, 리듬 등)
4. 목표 근육/조직 (최소 2-3개 구체적인 해부학적 명칭)
5. 환자가 느껴야 할 감각 vs 즉시 중단해야 할 신호

Exercise 각 운동마다 반드시 포함:
1. 시작 자세 (침대/바닥/의자, 팔다리 위치)
2. 치료사의 손 위치와 가이드 방법 (어디를 잡고, 어떻게 유도하는지)
3. 환자의 움직임 방향과 범위 (몇 도, 어떤 면에서)
4. 세트/반복수/속도
5. 목표 근육 (최소 2-3개 해부학적 명칭)

**응답 형식 (순수 JSON만, 마크다운 없음):**
{
  "manualTherapy": [
    {
      "technique": "기법명",
      "patientPosition": "환자 자세 상세 설명",
      "therapistHands": "치료사 손 위치와 접촉 부위 상세",
      "movement": "동작 방향, 강도, 리듬 설명",
      "targetMuscles": ["근육명1", "근육명2", "근육명3"],
      "patientFeedback": "환자가 느껴야 할 감각과 중단 신호"
    }
  ],
  "exercise": [
    {
      "name": "운동명",
      "startPosition": "시작 자세 상세",
      "therapistGuide": "치료사 손 위치와 가이드 방법",
      "movement": "환자 움직임 방향, 범위, 속도",
      "sets": "세트x반복 (예: 3세트 x 10회)",
      "targetMuscles": ["근육명1", "근육명2"],
      "cue": "치료사가 환자에게 말할 구체적인 큐잉 문장"
    }
  ],
  "clinicalNote": "초보 치료사를 위한 임상 팁 및 주의사항 2-3문장",
  "sessionSummary": {
    "mt": ["추천된 MT 기법명들"],
    "ex": ["추천된 운동명들"]
  }
}`;

  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': process.env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-5',
        max_tokens: 4096,
        messages: [{ role: 'user', content: prompt }]
      })
    });

    const data = await response.json();
    const text = data.content[0].text;
    const cleanText = text.replace(/^```json\s*\n?/, '').replace(/\n?```\s*$/, '').trim();
    const result = JSON.parse(cleanText);

    return res.status(200).json(result);
  } catch (error) {
    return res.status(500).json({ error: '추천 생성 실패: ' + error.message });
  }
}
