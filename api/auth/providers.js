// api/auth/providers.js
// Returns the list of configured OAuth providers so the frontend
// can dynamically show/hide social login buttons.
//
// Usage: GET /api/auth/providers
// Response: { providers: ["google", "kakao"] }

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Cache-Control', 'public, max-age=3600');

  if (req.method === 'OPTIONS') return res.status(200).end();

  // List providers that are enabled.
  // Add or remove entries here when enabling/disabling providers in
  // the Supabase dashboard (Authentication → Providers).
  const providers = [];

  if (process.env.OAUTH_GOOGLE_ENABLED === 'true') {
    providers.push('google');
  }
  if (process.env.OAUTH_KAKAO_ENABLED === 'true') {
    providers.push('kakao');
  }

  return res.json({ providers });
}
