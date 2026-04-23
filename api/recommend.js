// Vercel Serverless Function
// Claude API를 호출해서 추천 결과 반환

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { region, acuity, symptom, preferredMT, preferredEX } = req.body;

  const prompt = `당신은 한국의 근거기반 물리치료 전문가입니다. 다음 환자 정보와 치료사의 선호 기법을 바탕으로 최적의 치료 기법을 추천해주세요.

**환자 정보:**
- 통증 부위: ${region} (경추 또는 요추)
- 시기: ${acuity} (급성 <6주 또는 만성 >6주)
- 증상 패턴: ${symptom} (움직임 시 통증 / 안정 시 통증 / 방사통)

**치료사 선호 기법 (이 범위 내에서만 추천):**
- Manual Therapy: ${preferredMT.join(', ')}
- Exercise: ${preferredEX.join(', ')}

**중요 원칙:**
- 반드시 치료사가 선호하는 기법 목록 내에서만 추천
- 통증 = 손상이 아님 (반카타스트로파이징 원칙)
- "Calm things down, then build things back up" 원칙 적용
- 근거기반 접근

**응답 형식 (반드시 JSON으로만 응답, 다른 텍스트 없음):**
{
  "manualTherapy": [
    {"technique": "기법명", "reason": "이 환자에게 적합한 이유 한 줄"},
    {"technique": "기법명", "reason": "이유"}
  ],
  "exercise": [
    {"name": "운동명", "description": "구체적인 운동 방법 한 줄"},
    {"name": "운동명", "description": "방법"},
    {"name": "운동명", "description": "방법"}
  ],
  "clinicalNote": "치료사를 위한 임상 메모 1-2문장"
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
        model: 'claude-haiku-4-5',
        max_tokens: 1024,
        messages: [{ role: 'user', content: prompt }]
      })
    });

    const data = await response.json();
    const text = data.content[0].text;
    const result = JSON.parse(text);

    return res.status(200).json(result);
  } catch (error) {
    return res.status(500).json({ error: '추천 생성 실패: ' + error.message });
  }
}
