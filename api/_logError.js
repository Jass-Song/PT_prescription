// 서버 에러 → error_logs 기록 헬퍼 (서비스 롤로 RLS 우회)
// fire-and-forget — 로깅 실패가 본 요청을 절대 깨지 않도록 catch + return.

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

export async function logServerError({ message, stack, requestPath, httpStatus, userId, context }) {
  if (!SUPABASE_SERVICE_KEY || !message) return;
  try {
    await fetch(`${SUPABASE_URL}/rest/v1/error_logs`, {
      method: 'POST',
      headers: {
        'apikey':        SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type':  'application/json',
        'Prefer':        'return=minimal',
      },
      body: JSON.stringify({
        source: 'server',
        message: String(message).slice(0, 2000),
        stack: stack ? String(stack).slice(0, 8000) : null,
        request_path: requestPath || null,
        http_status: Number.isInteger(httpStatus) ? httpStatus : null,
        user_id: userId || null,
        context: context && typeof context === 'object' ? context : null,
      }),
    });
  } catch (e) {
    console.error('[logServerError] failed:', e.message);
  }
}
