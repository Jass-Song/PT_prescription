// api/config.js
// 프론트엔드에 Supabase anon key를 안전하게 제공하는 엔드포인트
export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Cache-Control', 'public, max-age=3600');

  if (req.method === 'OPTIONS') return res.status(200).end();

  res.json({
    supabaseUrl: process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co',
    supabaseAnonKey: process.env.SUPABASE_ANON_KEY || '',
  });
}
