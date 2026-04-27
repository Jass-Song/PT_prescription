// PT 처방 도우미 — 이력 조회 API
// GET /api/history → 최근 추천 이력 + 별 3개 이상 평가 기법

import { verifyToken } from './_auth.js';

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const { user, error: authError } = await verifyToken(req);
  if (authError) return res.status(401).json({ error: authError });

  const userToken = (req.headers['authorization'] || '').split(' ')[1];
  const authHeaders = {
    'apikey': SUPABASE_KEY,
    'Authorization': `Bearer ${userToken}`,
  };

  try {
    const [logsRes, ratingsRes] = await Promise.all([
      // 최근 추천 이력 (20건)
      fetch(
        `${SUPABASE_URL}/rest/v1/recommendation_logs` +
        `?user_id=eq.${user.id}` +
        `&select=id,region,acuity,symptom,selected_categories,recommended_techniques,created_at` +
        `&order=created_at.desc&limit=20`,
        { headers: authHeaders }
      ),
      // 별 3개 이상 평가 기법 (techniques 조인)
      fetch(
        `${SUPABASE_URL}/rest/v1/ratings` +
        `?user_id=eq.${user.id}` +
        `&star_rating=gte.3` +
        `&select=star_rating,created_at,techniques(name_ko,technique_categories(category_key,name_ko))` +
        `&order=star_rating.desc,created_at.desc&limit=30`,
        { headers: authHeaders }
      ),
    ]);

    const recentLogs  = await logsRes.json();
    const ratingsData = await ratingsRes.json();

    // 평가 데이터 평탄화
    const likedTechniques = (Array.isArray(ratingsData) ? ratingsData : [])
      .filter(r => r.techniques)
      .map(r => ({
        name_ko:       r.techniques.name_ko,
        category_key:  r.techniques.technique_categories?.category_key  || null,
        category_name: r.techniques.technique_categories?.name_ko       || null,
        star_rating:   r.star_rating,
        created_at:    r.created_at,
      }));

    return res.status(200).json({
      recentLogs:      Array.isArray(recentLogs) ? recentLogs : [],
      likedTechniques,
    });
  } catch (e) {
    console.error('[history GET]', e.message);
    return res.status(500).json({ error: '이력 로드 실패' });
  }
}
