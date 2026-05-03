// api/auth/callback.js
// Handles Supabase OAuth callback (PKCE code exchange)
//
// Flow:
//   1. User clicks "Google/Kakao 로그인" on frontend
//   2. Frontend calls supabase.auth.signInWithOAuth({ provider, options: { redirectTo } })
//   3. Supabase OAuth redirect → Google/Kakao → Supabase callback → this endpoint
//   4. This endpoint exchanges the auth code for a session via Supabase API
//   5. Redirects back to the app root; Supabase JS client picks up the session

const SUPABASE_URL =
  process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const APP_URL =
  process.env.APP_URL || 'https://pt-prescription.vercel.app';

export default async function handler(req, res) {
  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  const { code, error, error_description } = req.query;

  // --- OAuth error returned from provider ---
  if (error) {
    console.error('[auth/callback] OAuth error:', error, error_description);
    const params = new URLSearchParams({
      auth_error: error,
      auth_error_description: error_description || '',
    });
    return res.redirect(`${APP_URL}?${params.toString()}`);
  }

  // --- No code: unexpected state ---
  if (!code) {
    console.error('[auth/callback] No code in query params');
    return res.redirect(`${APP_URL}?auth_error=no_code`);
  }

  // --- Exchange code for session (PKCE) ---
  try {
    const exchangeRes = await fetch(
      `${SUPABASE_URL}/auth/v1/token?grant_type=pkce`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          apikey: process.env.SUPABASE_ANON_KEY || '',
        },
        body: JSON.stringify({ auth_code: code }),
      }
    );

    if (!exchangeRes.ok) {
      const errBody = await exchangeRes.text();
      console.error('[auth/callback] PKCE exchange failed:', errBody);
      return res.redirect(`${APP_URL}?auth_error=exchange_failed`);
    }

    const session = await exchangeRes.json();

    // Embed tokens in URL fragment so the Supabase JS client can pick them up
    // (same format Supabase uses for implicit flow redirect)
    const fragment = new URLSearchParams({
      access_token: session.access_token,
      refresh_token: session.refresh_token || '',
      token_type: session.token_type || 'bearer',
      expires_in: String(session.expires_in || 3600),
      type: 'recovery',  // triggers onAuthStateChange SIGNED_IN
    });

    // Redirect to app root with fragment — Supabase JS client will hydrate the session
    return res.redirect(`${APP_URL}/#${fragment.toString()}`);
  } catch (err) {
    console.error('[auth/callback] Unexpected error:', err.message);
    return res.redirect(`${APP_URL}?auth_error=server_error`);
  }
}
