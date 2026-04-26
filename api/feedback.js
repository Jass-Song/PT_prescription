// PT 처방 도우미 — 기법 평가 저장 서버리스 함수
// Input:  { technique, category, region, acuity, symptom, rating, notes }
// Output: { success: true }

import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const { verifyToken } = require('./_auth');

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  // JWT 검증
  const { user, error: authError } = await verifyToken(req);
  if (authError) {
    return res.status(401).json({ error: authError });
  }

  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;

  if (!SUPABASE_KEY) {
    return res.status(500).json({ error: 'Supabase 설정 오류' });
  }

  const { technique, category, region, acuity, symptom, rating, notes } = req.body || {};

  if (!technique || !rating) {
    return res.status(400).json({ error: '필수 항목 누락: technique, rating' });
  }
  if (typeof rating !== 'number' || rating < 1 || rating > 5) {
    return res.status(400).json({ error: '평점은 1~5 사이의 정수여야 합니다' });
  }

  const payload = {
    technique,
    category:   category  || null,
    region:     region    || null,
    acuity:     acuity    || null,
    symptom:    symptom   || null,
    rating:     Math.round(rating),
    notes:      notes     || null,
  };

  const response = await fetch(`${SUPABASE_URL}/rest/v1/technique_feedback`, {
    method: 'POST',
    headers: {
      'apikey':        SUPABASE_KEY,
      'Authorization': `Bearer ${SUPABASE_KEY}`,
      'Content-Type':  'application/json',
      'Prefer':        'return=minimal',
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const errText = await response.text();
    console.error('Supabase INSERT 오류:', errText);
    return res.status(502).json({ error: '저장 실패' });
  }

  return res.status(200).json({ success: true });
}
