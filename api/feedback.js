// PT 처방 도우미 — 기법 별점 평가 저장 (ratings 테이블)
// Input:  { technique, category, region, acuity, symptom, rating, notes }
// Output: { success: true }
//
// 동작:
//   1) JWT 검증 → user_id
//   2) techniques.name_ko 로 UUID 조회 (없으면 null — Anatomy Trains·LLM 의역 등)
//   3) ratings 인서트 (user JWT 사용 → RLS auth.uid() = user_id 충족)

import { verifyToken } from './_auth.js';

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { user, error: authError } = await verifyToken(req);
  if (authError) return res.status(401).json({ error: authError });

  if (!SUPABASE_KEY) {
    return res.status(500).json({ error: 'Supabase 설정 오류' });
  }

  const userToken = (req.headers['authorization'] || '').split(' ')[1];

  const { technique, category, region, acuity, symptom, rating, notes } = req.body || {};

  if (!technique || !rating) {
    return res.status(400).json({ error: '필수 항목 누락: technique, rating' });
  }
  if (typeof rating !== 'number' || rating < 1 || rating > 5) {
    return res.status(400).json({ error: '평점은 1~5 사이의 정수여야 합니다' });
  }

  // techniques.name_ko → UUID 조회 (없으면 null 폴백)
  let techniqueId = null;
  try {
    const lookupRes = await fetch(
      `${SUPABASE_URL}/rest/v1/techniques?name_ko=eq.${encodeURIComponent(technique)}&select=id&limit=1`,
      { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${userToken}` } }
    );
    if (lookupRes.ok) {
      const rows = await lookupRes.json();
      if (Array.isArray(rows) && rows[0]?.id) techniqueId = rows[0].id;
    }
  } catch (e) {
    console.error('[feedback] technique lookup failed:', e.message);
  }

  const payload = {
    user_id:         user.id,
    technique_id:    techniqueId,
    technique_label: technique,
    category_key:    category || null,
    region:          region   || null,
    acuity:          acuity   || null,
    symptom:         symptom  || null,
    star_rating:     Math.round(rating),
    notes:           notes    || null,
  };

  const response = await fetch(`${SUPABASE_URL}/rest/v1/ratings`, {
    method: 'POST',
    headers: {
      'apikey':        SUPABASE_KEY,
      'Authorization': `Bearer ${userToken}`,
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
