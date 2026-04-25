// Vercel Serverless Function
// KMO 고급 프로토타입 통합 — Supabase DB + Claude LLM 추천 플로우
// 기존 pt-prescription recommend.js 패턴 기반으로 확장

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { techniques, query, session_id } = req.body;

  // 요청 유효성 검사
  if (!techniques || !Array.isArray(techniques) || techniques.length === 0) {
    return res.status(400).json({ error: '후보 테크닉 배열이 필요합니다.' });
  }
  if (!query || !query.body_part) {
    return res.status(400).json({ error: '쿼리 정보(body_part)가 필요합니다.' });
  }

  const {
    body_part,
    purpose_tags = [],
    target_tags = [],
    symptom_tags = []
  } = query;

  // 테크닉 목록을 프롬프트용 텍스트로 변환
  const techniqueList = techniques.map((t, i) =>
    `${i + 1}. [ID: ${t.id}] ${t.name_ko || t.name_en || t.id}` +
    (t.category ? ` (카테고리: ${t.category})` : '') +
    (t.description_ko ? `\n   설명: ${t.description_ko}` : '') +
    (t.evidence_level ? `\n   근거 수준: ${t.evidence_level}` : '')
  ).join('\n\n');

  const systemPrompt = `당신은 K-Movement Optimism의 임상 물리치료사 멘토입니다.
근거기반, 반-카타스트로파이징 원칙을 엄격히 따릅니다.

핵심 원칙:
- 통증 ≠ 손상 (절대 통증=손상 프레임 사용 금지)
- "Calm things down, and build things back up." (Greg Lehman)
- 생물심리사회적 관점 유지
- 환자에게 공포 유발하는 표현 금지
- 자세 불균형, 정렬 틀어짐 등 KPM 프레임 차용 금지

당신의 역할: 제공된 후보 테크닉 목록에서 환자 상태에 최적인 임상 치료 플로우를 설계한다.`;

  const userPrompt = `환자 정보:
- 치료 부위: ${body_part}
- 치료 목적: ${purpose_tags.length > 0 ? purpose_tags.join(', ') : '명시되지 않음'}
- 대상 특성: ${target_tags.length > 0 ? target_tags.join(', ') : '명시되지 않음'}
- 증상 패턴: ${symptom_tags.length > 0 ? symptom_tags.join(', ') : '명시되지 않음'}

후보 테크닉 목록 (이 목록 내에서만 선택):
${techniqueList}

위 후보 테크닉들을 임상 치료 세션 순서에 맞게 정렬하고, 각 기법을 선택한 근거를 제시하세요.
순서는 세션 흐름(준비→주치료→마무리)에 맞게 구성하세요.

응답 형식 (순수 JSON만, 마크다운 코드블록 없음):
{
  "ordered_techniques": [
    {
      "id": "테크닉-id",
      "rank": 1,
      "clinical_reason": "이 기법을 이 순서에 적용하는 임상적 근거 (1-2문장)",
      "session_timing": "세션 내 적용 타이밍 (예: 세션 초반 5분, 중반 10분)"
    }
  ],
  "session_flow": "전체 세션 진행 순서를 1-2-3 단계로 요약 (예: 1. 연부조직 이완 → 2. 관절가동술 → 3. 움직임 재교육)",
  "clinical_notes": "이 환자에게 특히 주의할 임상적 포인트 (반-카타스트로파이징 관점, 2-3문장)"
}`;

  try {
    // Claude API 호출 (기존 pt-prescription 패턴 유지)
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': process.env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5',
        max_tokens: 2000,
        system: systemPrompt,
        messages: [{ role: 'user', content: userPrompt }]
      })
    });

    const data = await response.json();

    // Claude API 자체 에러 처리
    if (!response.ok || data.error) {
      const apiErr = data.error ? JSON.stringify(data.error) : `HTTP ${response.status}`;
      console.error('Claude API 오류:', apiErr);
      return res.status(200).json(buildFallback(techniques));
    }

    if (!data.content || !data.content[0] || !data.content[0].text) {
      console.error('Claude 응답 구조 오류:', JSON.stringify(data));
      return res.status(200).json(buildFallback(techniques));
    }

    const text = data.content[0].text;

    // JSON 추출 (마크다운 코드블록 처리 포함)
    const match = text.match(/\{[\s\S]*\}/);
    if (!match) {
      console.error('JSON 없음. Claude 원문:', text.slice(0, 300));
      return res.status(200).json(buildFallback(techniques));
    }

    let result;
    try {
      result = JSON.parse(match[0]);
    } catch (parseErr) {
      console.error('JSON 파싱 오류:', parseErr.message);
      return res.status(200).json(buildFallback(techniques));
    }

    // Supabase에 추천 결과 저장 (비동기, 실패해도 응답에 영향 없음)
    saveToSupabase({
      session_id: session_id || null,
      query_body_part: body_part,
      query_tags: { purpose_tags, target_tags, symptom_tags },
      input_techniques: techniques,
      llm_response: result
    }).catch(err => console.error('Supabase 저장 오류:', err.message));

    return res.status(200).json(result);

  } catch (error) {
    console.error('서버리스 함수 오류:', error.message);
    return res.status(200).json(buildFallback(techniques));
  }
}

// 폴백: LLM 실패 시 원래 순서 그대로 반환
function buildFallback(techniques) {
  return {
    fallback: true,
    ordered_techniques: techniques.map((t, i) => ({
      id: t.id,
      rank: i + 1,
      clinical_reason: '자동 추천 불가 — 원래 순서로 제공됩니다.',
      session_timing: '-'
    })),
    session_flow: '자동 추천 생성 실패 — 기본 순서를 사용하세요.',
    clinical_notes: 'LLM 추천 서비스에 일시적 문제가 발생했습니다. 잠시 후 다시 시도해주세요.'
  };
}

// Supabase llm_recommendations 테이블에 결과 저장
async function saveToSupabase(payload) {
  const supabaseUrl = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const serviceKey = process.env.SUPABASE_SERVICE_KEY;

  if (!serviceKey) {
    console.warn('SUPABASE_SERVICE_KEY 미설정 — 저장 건너뜀');
    return;
  }

  const response = await fetch(`${supabaseUrl}/rest/v1/llm_recommendations`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'apikey': serviceKey,
      'Authorization': `Bearer ${serviceKey}`,
      'Prefer': 'return=minimal'
    },
    body: JSON.stringify({
      session_id: payload.session_id,
      query_body_part: payload.query_body_part,
      query_tags: payload.query_tags,
      input_techniques: payload.input_techniques,
      llm_response: payload.llm_response,
      created_at: new Date().toISOString()
    })
  });

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`Supabase INSERT 실패: ${response.status} — ${errText}`);
  }
}
