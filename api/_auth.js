// api/_auth.js
// Vercel에서 _로 시작하는 파일은 라우팅 제외 (private helper)

export async function verifyToken(req) {
  const authHeader = req.headers['authorization'] || '';
  if (!authHeader.startsWith('Bearer ')) {
    return { user: null, error: '인증 토큰이 없습니다.' };
  }

  const token = authHeader.split(' ')[1];
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

  if (!SUPABASE_SERVICE_KEY) {
    console.error('[auth] SUPABASE_SERVICE_KEY not set');
    return { user: null, error: 'Server configuration error' };
  }

  try {
    const res = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'apikey': SUPABASE_SERVICE_KEY,
      },
    });

    if (!res.ok) {
      return { user: null, error: '유효하지 않은 토큰입니다.' };
    }

    const user = await res.json();
    return { user, error: null };
  } catch (err) {
    console.error('[auth] Token verification failed:', err.message);
    return { user: null, error: '인증 처리 중 오류가 발생했습니다.' };
  }
}
