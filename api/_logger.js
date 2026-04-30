// api/_logger.js
// 서버사이드 에러를 error_logs 테이블에 직접 INSERT하는 헬퍼.
// SUPABASE_SERVICE_KEY 사용 (RLS 우회).
// 실패해도 조용히 무시 — 로깅 실패가 응답을 방해하면 안 됨.

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SERVICE_KEY  = process.env.SUPABASE_SERVICE_KEY;

/**
 * 서버사이드 에러를 error_logs 테이블에 기록합니다.
 * @param {string} source - API 파일명 ('feedback' | 'recommend' | 'history' 등)
 * @param {string} message - 에러 메시지
 * @param {Object} opts - { stack, http_status, request_path, context, user_id }
 */
export async function logServerError(source, message, opts = {}) {
  if (!SERVICE_KEY) return;
  try {
    await fetch(`${SUPABASE_URL}/rest/v1/error_logs`, {
      method: 'POST',
      headers: {
        'apikey':        SERVICE_KEY,
        'Authorization': `Bearer ${SERVICE_KEY}`,
        'Content-Type':  'application/json',
        'Prefer':        'return=minimal',
      },
      body: JSON.stringify({
        source:       'server',
        message:      String(message).slice(0, 2000),
        stack:        opts.stack        ? String(opts.stack).slice(0, 8000) : null,
        http_status:  opts.http_status  ?? null,
        request_path: opts.request_path ?? null,
        context:      opts.context      ?? null,
        user_id:      opts.user_id      ?? null,
        url:          source, // source 파일명을 url 컬럼에 저장 (어느 API인지 식별)
      }),
    });
  } catch (_) { /* fail-silent */ }
}
