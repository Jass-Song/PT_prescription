// PT 처방 도우미 — term_glossary 캐시 무효화 (관리자 전용)
//
// 용도: 어드민이 term_glossary 행을 추가/수정/삭제한 직후, 모든 서버리스
//       인스턴스가 다음 요청에서 즉시 새 데이터를 로드하도록 in-memory 캐시
//       (api/_term_glossary.js 의 모듈 스코프 Map) 을 비운다.
//
// 인증: Authorization: Bearer <service_role_key>
//   - 일반 사용자 JWT 가 아닌 service_role key 직접 비교 (admin 전용)
//   - 환경변수 TERM_GLOSSARY_ADMIN_KEY 가 있으면 그것 우선, 없으면
//     SUPABASE_SERVICE_KEY 와 비교 (어드민 키 재사용)
//
// 응답: { ok: true, invalidated_at: <ISO timestamp> }
//
// 주의: Vercel serverless 는 인스턴스마다 메모리가 분리되어 있어 본 endpoint
//       호출 한 번이 *즉시* 모든 인스턴스를 비우지는 않는다. 다만 각 인스턴스가
//       다음 요청에서 invalidateGlossary() 호출 시 reload 되므로 결국 모두 갱신된다.
//       글로벌 즉시 무효화가 필요하면 외부 KV/Redis 로 교체 (out-of-scope).
//
// 작성: sw-backend-dev, 2026-05-05

import { invalidateGlossary } from '../_term_glossary.js';

function getAdminKey() {
  return process.env.TERM_GLOSSARY_ADMIN_KEY
      || process.env.SUPABASE_SERVICE_KEY
      || null;
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const expected = getAdminKey();
  if (!expected) {
    return res.status(500).json({ error: 'admin key 환경변수 미설정' });
  }

  const auth = req.headers['authorization'] || '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7).trim() : '';
  if (!token || token !== expected) {
    return res.status(401).json({ error: 'unauthorized' });
  }

  invalidateGlossary();
  return res.status(200).json({
    ok: true,
    invalidated_at: new Date().toISOString(),
  });
}
