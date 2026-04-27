// PT 처방 도우미 — 사용자 설정 동기화 API
// GET  /api/settings  → 설정 로드 + 카테고리 사용 빈도
// POST /api/settings  → 설정 저장 (user_profiles.pt_settings PATCH)

import { verifyToken } from './_auth.js';

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(200).end();

  const { user, error: authError } = await verifyToken(req);
  if (authError) return res.status(401).json({ error: authError });

  const userToken = (req.headers['authorization'] || '').split(' ')[1];
  const authHeaders = {
    'apikey': SUPABASE_KEY,
    'Authorization': `Bearer ${userToken}`,
  };

  // ── GET: 설정 + 카테고리 사용 빈도 ──────────────────────────────
  if (req.method === 'GET') {
    try {
      const [profileRes, logsRes] = await Promise.all([
        fetch(
          `${SUPABASE_URL}/rest/v1/user_profiles?id=eq.${user.id}&select=pt_settings`,
          { headers: authHeaders }
        ),
        fetch(
          `${SUPABASE_URL}/rest/v1/recommendation_logs?user_id=eq.${user.id}&select=selected_categories&order=created_at.desc&limit=100`,
          { headers: authHeaders }
        ),
      ]);

      const profileData = await profileRes.json();
      const logsData    = await logsRes.json();

      const ptSettings = profileData?.[0]?.pt_settings || {
        mt_groups: ['mt_joint', 'mt_soft'],
        ex_groups: [],
      };

      // 카테고리별 사용 빈도 계산 (최근 100건 기준)
      const categoryFrequency = {};
      if (Array.isArray(logsData)) {
        for (const log of logsData) {
          for (const cat of (log.selected_categories || [])) {
            categoryFrequency[cat] = (categoryFrequency[cat] || 0) + 1;
          }
        }
      }

      return res.status(200).json({
        mt_groups: ptSettings.mt_groups || ['mt_joint', 'mt_soft'],
        ex_groups: ptSettings.ex_groups || [],
        categoryFrequency,
      });
    } catch (e) {
      console.error('[settings GET]', e.message);
      return res.status(500).json({ error: '설정 로드 실패' });
    }
  }

  // ── POST: 설정 저장 (user_profiles.pt_settings PATCH) ────────────────
  if (req.method === 'POST') {
    const { mt_groups = [], ex_groups = [] } = req.body || {};
    try {
      await fetch(
        `${SUPABASE_URL}/rest/v1/user_profiles?id=eq.${user.id}`,
        {
          method: 'PATCH',
          headers: {
            ...authHeaders,
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal',
          },
          body: JSON.stringify({
            pt_settings: { mt_groups, ex_groups },
            updated_at: new Date().toISOString(),
          }),
        }
      );
      return res.status(200).json({ success: true });
    } catch (e) {
      console.error('[settings POST]', e.message);
      return res.status(500).json({ error: '설정 저장 실패' });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
