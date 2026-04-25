// PT 처방 도우미 — AI 추천 서버리스 함수
// Input:  { region, acuity, symptom, preferredMT, preferredEX, sessionHistory }
// Output: { manualTherapy[], exercise[], clinicalNote, sessionSummary }

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

  // 세션 히스토리 요약 (중복 추천 방지)
  const historyText = sessionHistory.length > 0
    ? `\n\n이전 세션 기록 (중복 추천 피할 것):\n${sessionHistory.map((h, i) => `${i+1}. ${JSON.stringify(h)}`).join('\n')}`
    : '';

  const systemPrompt = `당신은 K-Movement Optimism의 임상 물리치료사 멘토입니다.
근거기반 재활 원칙을 따르며 반-카타스트로파이징(anti-catastrophizing) 접근을 강조합니다.
핵심 원칙: "통증 ≠ 손상", "몸은 적응적이다", "Calm things down, then build things back up"
KPM 프레임(자세 불균형, 정렬 이상) 사용 금지. 공포 유발 표현 금지.
응답은 반드시 순수 JSON만 출력하세요. 마크다운 금지.`;

  const userPrompt = `환자 정보:
- 부위: ${region}
- 시기: ${acuity}
- 증상 패턴: ${symptom}

치료사 선호 기법:
- Manual Therapy: ${preferredMT.length > 0 ? preferredMT.join(', ') : '지정 없음'}
- Exercise: ${preferredEX.length > 0 ? preferredEX.join(', ') : '지정 없음'}
${historyText}

위 환자에게 적합한 임상 추천을 아래 JSON 형식으로 작성하세요.
선호 기법 목록 내에서만 추천하되, 없으면 임상적으로 적합한 것을 추천하세요.

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
