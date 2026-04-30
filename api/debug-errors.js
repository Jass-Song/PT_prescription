// PT 처방 도우미 — 에러 로그 + 응답 시간 통계 디버그 API
// 사용 목적: 대표님 전용 내부 디버그 도구. 인증 불필요 (내부망 전용 도구).
// Output:
//   {
//     errors: [{ id, source, message, stack, url, user_agent, http_status, request_path, context, user_id, created_at }],
//     latency: { count, count24h, count1h, p50, p95, avg, max, recent: [{ created_at, latency_ms, region, acuity, symptom }] }
//   }

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || SUPABASE_ANON_KEY;

function percentile(sorted, p) {
  if (sorted.length === 0) return null;
  const idx = Math.min(sorted.length - 1, Math.max(0, Math.ceil((p / 100) * sorted.length) - 1));
  return sorted[idx];
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  if (!SUPABASE_ANON_KEY || !SERVICE_KEY) {
    return res.status(500).json({ error: 'Supabase 키 미설정' });
  }

  const limit = Math.min(parseInt(req.query?.limit) || 100, 500);
  const source = req.query?.source; // 'client' | 'server' | undefined

  const headers = { apikey: SUPABASE_ANON_KEY, Authorization: `Bearer ${SERVICE_KEY}` };

  try {
    const errorFilter = source === 'client' || source === 'server' ? `&source=eq.${source}` : '';
    const errorsUrl =
      `${SUPABASE_URL}/rest/v1/error_logs` +
      `?select=id,source,message,stack,url,user_agent,http_status,request_path,context,user_id,created_at` +
      errorFilter +
      `&order=created_at.desc&limit=${limit}`;

    // 최근 14일 latency (전체 통계는 14일 윈도우, 최근 표시는 30건)
    const since = new Date(Date.now() - 14 * 24 * 3600 * 1000).toISOString();
    const latencyUrl =
      `${SUPABASE_URL}/rest/v1/recommendation_logs` +
      `?latency_ms=not.is.null&created_at=gte.${since}` +
      `&select=created_at,latency_ms,region,acuity,symptom` +
      `&order=created_at.desc&limit=2000`;

    const [errRes, latRes] = await Promise.all([
      fetch(errorsUrl, { headers }),
      fetch(latencyUrl, { headers }),
    ]);

    const errors = errRes.ok ? await errRes.json() : [];
    const latencyRows = latRes.ok ? await latRes.json() : [];

    const latencies = (Array.isArray(latencyRows) ? latencyRows : [])
      .map(r => r.latency_ms)
      .filter(n => Number.isFinite(n))
      .sort((a, b) => a - b);

    const now = Date.now();
    const oneHour = now - 3600 * 1000;
    const oneDay = now - 24 * 3600 * 1000;
    const count1h  = latencyRows.filter(r => new Date(r.created_at).getTime() >= oneHour).length;
    const count24h = latencyRows.filter(r => new Date(r.created_at).getTime() >= oneDay).length;

    const sum = latencies.reduce((a, b) => a + b, 0);
    const avg = latencies.length ? Math.round(sum / latencies.length) : null;

    const latency = {
      count:    latencies.length,
      count24h,
      count1h,
      p50:      percentile(latencies, 50),
      p95:      percentile(latencies, 95),
      avg,
      max:      latencies.length ? latencies[latencies.length - 1] : null,
      recent:   latencyRows.slice(0, 30),
    };

    return res.status(200).json({ errors, latency });
  } catch (e) {
    console.error('[debug-errors]', e.message);
    return res.status(500).json({ error: '디버그 데이터 로드 실패: ' + e.message });
  }
}
