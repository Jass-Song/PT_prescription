// PT 처방 도우미 — 에러 텔레메트리 수집 엔드포인트
// Input:  { source, message, stack?, url?, user_agent?, http_status?, request_path?, context? }
// Output: 204 No Content (항상 — 에러 응답이 클라이언트 루프 유발 방지)
//
// 인증 불필요 (인증 자체가 깨졌을 때도 로그 수집 가능해야 함).
// JWT가 있으면 user_id 추가, 없으면 null. service role 키로 인서트 (RLS 우회).

import { verifyToken } from './_auth.js';

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

const MSG_MAX = 2000;
const STACK_MAX = 8000;

function clip(s, n) {
  if (typeof s !== 'string') return null;
  return s.length > n ? s.slice(0, n) : s;
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(204).end();

  if (!SUPABASE_SERVICE_KEY) {
    console.error('[log-error] SUPABASE_SERVICE_KEY not set');
    return res.status(204).end();
  }

  const body = req.body || {};
  const source = typeof body.source === 'string' ? body.source : null;
  const message = typeof body.message === 'string' ? body.message : null;
  if (!source || !message) return res.status(204).end();

  // 인증은 선택 — 실패해도 무시
  let userId = null;
  try {
    const { user } = await verifyToken(req);
    if (user?.id) userId = user.id;
  } catch (_) { /* swallow */ }

  const payload = {
    source:       clip(source, 32),
    message:      clip(message, MSG_MAX),
    stack:        clip(body.stack, STACK_MAX),
    url:          clip(body.url, 1000),
    user_agent:   clip(body.user_agent, 500),
    http_status:  Number.isInteger(body.http_status) ? body.http_status : null,
    request_path: clip(body.request_path, 500),
    context:      body.context && typeof body.context === 'object' ? body.context : null,
    user_id:      userId,
  };

  try {
    await fetch(`${SUPABASE_URL}/rest/v1/error_logs`, {
      method: 'POST',
      headers: {
        'apikey':        SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type':  'application/json',
        'Prefer':        'return=minimal',
      },
      body: JSON.stringify(payload),
    });
  } catch (e) {
    console.error('[log-error] insert failed:', e.message);
  }

  return res.status(204).end();
}
