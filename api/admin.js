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

// ── 어드민 권한 확인: ADMIN_EMAIL 또는 user_profiles.tier='admin' ──
// verifyToken이 반환하는 user 객체에 email 이미 포함됨 → 추가 fetch 불필요
// path 2는 사용자 본인 토큰으로 자기 행 조회 (RLS-friendly)
async function checkAdmin(user, userToken) {
  // 1) email 체크 (legacy 어드민)
  if ((user?.email || '').toLowerCase() === ADMIN_EMAIL.toLowerCase()) return true;

  // 2) user_profiles.tier='admin' 체크 (신규 등급 시스템)
  // 본인 토큰으로 자기 행만 조회 — RLS: auth.uid()=id 정책으로 자기 행 SELECT 허용
  try {
    const authToken = userToken || SERVICE_KEY;
    const tierRes = await fetch(
      `${SUPABASE_URL}/rest/v1/user_profiles?id=eq.${user.id}&select=tier`,
      { headers: { apikey: SUPABASE_ANON_KEY, Authorization: `Bearer ${authToken}` } }
    );
    if (tierRes.ok) {
      const rows = await tierRes.json();
      const tier = rows?.[0]?.tier || null;
      return tier === 'admin';
    } else {
      console.warn('[admin] user_profiles 조회 실패:', tierRes.status);
    }
  } catch (e) {
    console.warn('[admin] tier 조회 예외:', e.message);
  }
  return false;
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, PATCH, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (!['GET', 'PATCH'].includes(req.method)) return res.status(405).json({ error: 'Method not allowed' });

  if (!SERVICE_KEY) {
    return res.status(500).json({ error: 'Supabase 키 미설정' });
  }

  // 1. JWT 검증
  const { user, error: authError } = await verifyToken(req);
  if (!user) {
    return res.status(401).json({ error: authError || '인증 실패' });
  }
  const userToken = (req.headers['authorization'] || '').split(' ')[1] || null;

  // 2. 관리자 권한 확인 (ADMIN_EMAIL 또는 user_profiles.tier='admin')
  const isAdminUser = await checkAdmin(user, userToken);
  if (!isAdminUser) {
    return res.status(403).json({
      error: '관리자 전용 엔드포인트입니다.',
      hint: '본인 user_profiles.tier가 admin인지 확인하거나, 등록된 ADMIN_EMAIL과 일치하는지 확인하세요.',
      debug: { user_email: user.email, user_id: user.id },
    });
  }

  const headersAdmin = { apikey: SERVICE_KEY, Authorization: `Bearer ${SERVICE_KEY}`, 'Content-Type': 'application/json' };
  const type = req.query?.type || req.body?.type || '';

  // ── 신규 등급 관리 엔드포인트 (type 분기) ──
  if (req.method === 'GET' && type === 'tier_limits') {
    const r = await fetch(`${SUPABASE_URL}/rest/v1/tier_limits?select=*&order=daily_limit`, { headers: headersAdmin });
    return res.status(r.status).json(r.ok ? await r.json() : { error: 'tier_limits 조회 실패' });
  }
  if (req.method === 'GET' && type === 'tiers') {
    // user_profiles에서 tier 있는 사용자만 (기본 'beta' 제외 옵션 가능). 일단 모두 반환.
    const tr = await fetch(`${SUPABASE_URL}/rest/v1/user_profiles?select=id,tier,display_name,tier_updated_at,updated_at&order=tier_updated_at.desc.nullslast&limit=200`, { headers: headersAdmin });
    if (!tr.ok) return res.status(500).json({ error: 'user_profiles 조회 실패' });
    const rows = await tr.json();
    // user_id 표준화 (id → user_id) + 이메일 보강 + tier_updated_at 노출
    const enriched = await Promise.all(rows.map(async row => {
      let email = null;
      try {
        const ur = await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${row.id}`, { headers: { Authorization: `Bearer ${SERVICE_KEY}`, apikey: SERVICE_KEY } });
        const u = ur.ok ? await ur.json() : null;
        email = u?.email || null;
      } catch {}
      return {
        user_id: row.id,
        tier: row.tier,
        notes: row.display_name,
        tier_updated_at: row.tier_updated_at,
        updated_at: row.updated_at,
        email,
      };
    }));
    return res.status(200).json(enriched);
  }
  if (req.method === 'PATCH' && type === 'tier_limit') {
    const tier = req.query?.tier || req.body?.tier;
    const daily_limit = req.body?.daily_limit;
    if (!tier || !Number.isFinite(Number(daily_limit))) {
      return res.status(400).json({ error: 'tier 및 daily_limit 필수' });
    }
    const r = await fetch(`${SUPABASE_URL}/rest/v1/tier_limits?tier=eq.${encodeURIComponent(tier)}`, {
      method: 'PATCH', headers: { ...headersAdmin, Prefer: 'return=representation' },
      body: JSON.stringify({ daily_limit: Number(daily_limit), updated_at: new Date().toISOString(), updated_by: user.id }),
    });
    return res.status(r.status).json(r.ok ? await r.json() : { error: 'tier_limit 갱신 실패' });
  }
  if (req.method === 'PATCH' && type === 'user_tier') {
    const target_user_id = req.query?.user_id || req.body?.user_id;
    const tier = req.body?.tier;
    if (!target_user_id || !tier) return res.status(400).json({ error: 'user_id 및 tier 필수' });
    // user_profiles는 가입 시 자동 생성됨 → UPDATE 직접 사용. 없으면 upsert.
    const r = await fetch(`${SUPABASE_URL}/rest/v1/user_profiles?on_conflict=id`, {
      method: 'POST',
      headers: { ...headersAdmin, Prefer: 'resolution=merge-duplicates,return=representation' },
      body: JSON.stringify({ id: target_user_id, tier, updated_at: new Date().toISOString() }),
    });
    return res.status(r.status).json(r.ok ? await r.json() : { error: 'user tier 갱신 실패' });
  }

  if (req.method !== 'GET') return res.status(405).json({ error: 'GET only for dashboard' });

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
