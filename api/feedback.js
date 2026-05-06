// PT 처방 도우미 — 기법 별점 평가 저장 (ratings 테이블)
// Input:  { technique, category, region, acuity, symptom, rating, notes, outcome,
//           indication_accuracy, recommendation_log_id?, recommended_technique_index? }
// Output: { success: true }
//
// 동작:
//   1) JWT 검증 → user_id
//   2) techniques.name_ko 로 UUID 조회 (없으면 null — Anatomy Trains·LLM 의역 등)
//   3) ratings 인서트 (user JWT 사용 → RLS auth.uid() = user_id 충족)
//   4) 마이그 051 이후 recommendation_log_id (FK) + recommended_technique_index (1-based)
//      두 필드는 NULL 허용. INSERT 트리거가 recommendation_logs.evaluation_status='rated' 자동 갱신.

import { verifyToken } from './_auth.js';
import { logServerError } from './_logger.js';

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

  const {
    technique, category, region, acuity, symptom,
    rating, notes,
    outcome, indication_accuracy,
    recommendation_log_id, recommended_technique_index,
  } = req.body || {};

  if (!technique || !rating) {
    return res.status(400).json({ error: '필수 항목 누락: technique, rating' });
  }
  if (typeof rating !== 'number' || rating < 1 || rating > 5) {
    return res.status(400).json({ error: '평점은 1~5 사이의 정수여야 합니다' });
  }

  // outcome: rating_outcome ENUM 6값 중 하나 또는 null/undefined (선택)
  const VALID_OUTCOMES = ['excellent', 'good', 'moderate', 'poor', 'no_effect', 'adverse'];
  if (outcome != null && !VALID_OUTCOMES.includes(outcome)) {
    return res.status(400).json({ error: 'outcome 값이 유효하지 않습니다' });
  }

  // indication_accuracy: 1~5 또는 null/undefined (선택)
  if (indication_accuracy != null) {
    if (typeof indication_accuracy !== 'number' || indication_accuracy < 1 || indication_accuracy > 5) {
      return res.status(400).json({ error: 'indication_accuracy 는 1~5 사이의 정수여야 합니다' });
    }
  }

  // recommended_technique_index: 1~10 또는 null/undefined (선택, 방어 코드)
  // 같은 추천 세션 내 카드 인덱스(1-based). 마이그 051 이후 NULL 허용.
  if (recommended_technique_index != null) {
    if (typeof recommended_technique_index !== 'number' ||
        !Number.isInteger(recommended_technique_index) ||
        recommended_technique_index < 1 || recommended_technique_index > 10) {
      return res.status(400).json({ error: 'recommended_technique_index 는 1~10 사이의 정수여야 합니다' });
    }
  }

  // recommendation_log_id: UUID 문자열 또는 null/undefined (선택)
  // 형식 검증은 DB FK가 처리. 여기서는 타입만 점검.
  if (recommendation_log_id != null && typeof recommendation_log_id !== 'string') {
    return res.status(400).json({ error: 'recommendation_log_id 는 문자열이어야 합니다' });
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
    await logServerError('feedback', `technique lookup failed: ${e.message}`, {
      stack: e.stack,
      request_path: '/api/feedback',
      user_id: user?.id ?? null,
      context: { technique },
    });
  }

  const payload = {
    user_id:             user.id,
    technique_id:        techniqueId,
    technique_label:     technique,
    category_key:        category || null,
    region:              region   || null,
    acuity:              acuity   || null,
    symptom:             symptom  || null,
    star_rating:         Math.round(rating),
    notes:               notes    || null,
    outcome:             outcome  || null,
    indication_accuracy: indication_accuracy != null ? Math.round(indication_accuracy) : null,
    was_ai_recommended:  true,
    // 마이그 051 — 카드별 평가 매칭. 두 필드 모두 NULL 허용 (소급 호환).
    // INSERT 트리거가 recommendation_logs.evaluation_status='rated' 자동 갱신 (pending 한정).
    recommendation_log_id:        recommendation_log_id || null,
    recommended_technique_index:  recommended_technique_index != null ? Math.round(recommended_technique_index) : null,
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
    await logServerError('feedback', `ratings INSERT ${response.status}: ${errText}`, {
      http_status: response.status,
      request_path: '/api/feedback',
      user_id: user?.id ?? null,
      context: { technique, star_rating: Math.round(rating), outcome, indication_accuracy },
    });
    return res.status(502).json({ error: '저장 실패' });
  }

  return res.status(200).json({ success: true });
}
