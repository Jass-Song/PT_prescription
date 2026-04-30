// PT 처방 도우미 — 관리자 전용 대시보드 API
// 인증: JWT 검증 후 관리자 이메일 확인 (junnyhsong@gmail.com)
// Output:
//   {
//     ratings: [...],
//     generalFeedback: [...],
//     usageStats: { regionCounts, dailyCounts, uniqueUsers, totalRecs, avgLatency },
//     recentErrors: [...]
//   }

import { verifyToken } from './_auth.js';

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || SUPABASE_ANON_KEY;

const ADMIN_EMAIL = 'junnyhsong@gmail.com';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  if (!SERVICE_KEY) {
    return res.status(500).json({ error: 'Supabase 키 미설정' });
  }

  // 1. JWT 검증
  const { user, error: authError } = await verifyToken(req);
  if (!user) {
    return res.status(401).json({ error: authError || '인증 실패' });
  }

  // 2. 관리자 이메일 확인 — auth.admin API로 사용자 정보 조회
  try {
    const userRes = await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${user.id}`, {
      headers: {
        Authorization: `Bearer ${SERVICE_KEY}`,
        apikey: SERVICE_KEY,
      },
    });

    if (!userRes.ok) {
      return res.status(403).json({ error: '사용자 정보를 확인할 수 없습니다.' });
    }

    const userData = await userRes.json();
    const email = userData.email || '';

    if (email !== ADMIN_EMAIL) {
      return res.status(403).json({ error: '관리자 전용 엔드포인트입니다.' });
    }
  } catch (e) {
    console.error('[admin] 관리자 확인 실패:', e.message);
    return res.status(500).json({ error: '관리자 확인 중 오류 발생' });
  }

  // 3. 데이터 병렬 조회
  const now = new Date();
  const sevenDaysAgo = new Date(now - 7 * 24 * 3600 * 1000).toISOString();
  const oneDayAgo   = new Date(now - 24 * 3600 * 1000).toISOString();

  const headers = {
    apikey: SERVICE_KEY,
    Authorization: `Bearer ${SERVICE_KEY}`,
  };

  try {
    const [ratingsRes, usageRes, errorsRes] = await Promise.all([
      fetch(
        `${SUPABASE_URL}/rest/v1/ratings` +
        `?created_at=gte.${sevenDaysAgo}` +
        `&order=created_at.desc&limit=200` +
        `&select=id,user_id,technique_label,category_key,region,acuity,star_rating,notes,created_at`,
        { headers }
      ),
      fetch(
        `${SUPABASE_URL}/rest/v1/recommendation_logs` +
        `?created_at=gte.${sevenDaysAgo}` +
        `&select=user_id,region,acuity,symptom,selected_categories,recommended_techniques,latency_ms,created_at` +
        `&order=created_at.desc&limit=500`,
        { headers }
      ),
      fetch(
        `${SUPABASE_URL}/rest/v1/error_logs` +
        `?created_at=gte.${oneDayAgo}` +
        `&order=created_at.desc&limit=50` +
        `&select=source,message,http_status,created_at`,
        { headers }
      ),
    ]);

    const allRatings  = ratingsRes.ok  ? await ratingsRes.json()  : [];
    const usageLogs   = usageRes.ok    ? await usageRes.json()    : [];
    const recentErrors = errorsRes.ok  ? await errorsRes.json()   : [];

    // 4. ratings / generalFeedback 분리
    const ratings        = (Array.isArray(allRatings) ? allRatings : []).filter(r => r.category_key !== 'general_app');
    const generalFeedback = (Array.isArray(allRatings) ? allRatings : []).filter(r => r.category_key === 'general_app');

    // 5. 서버 사이드 usageStats 집계
    const logs = Array.isArray(usageLogs) ? usageLogs : [];

    // regionCounts
    const regionCounts = {};
    for (const log of logs) {
      const region = log.region || '(미기입)';
      regionCounts[region] = (regionCounts[region] || 0) + 1;
    }

    // dailyCounts — 지난 7일 날짜 슬롯 생성
    const dailyMap = {};
    for (let i = 6; i >= 0; i--) {
      const d = new Date(now);
      d.setDate(d.getDate() - i);
      const key = d.toISOString().slice(0, 10); // YYYY-MM-DD
      dailyMap[key] = 0;
    }
    for (const log of logs) {
      const day = (log.created_at || '').slice(0, 10);
      if (day in dailyMap) dailyMap[day]++;
    }
    const dailyCounts = Object.entries(dailyMap).map(([date, count]) => ({ date, count }));

    // uniqueUsers
    const uniqueUserSet = new Set(logs.map(l => l.user_id).filter(Boolean));
    const uniqueUsers = uniqueUserSet.size;

    // totalRecs
    const totalRecs = logs.length;

    // avgLatency
    const latencies = logs.map(l => l.latency_ms).filter(n => Number.isFinite(n));
    const avgLatency = latencies.length
      ? Math.round(latencies.reduce((a, b) => a + b, 0) / latencies.length)
      : null;

    const usageStats = { regionCounts, dailyCounts, uniqueUsers, totalRecs, avgLatency };

    return res.status(200).json({ ratings, generalFeedback, usageStats, recentErrors });
  } catch (e) {
    console.error('[admin] 데이터 조회 실패:', e.message);
    return res.status(500).json({ error: '어드민 데이터 로드 실패: ' + e.message });
  }
}
