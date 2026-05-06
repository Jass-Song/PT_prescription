// PT 처방 도우미 — 평가 대기 추천 조회 API
// GET /api/pending-evaluations → 14일 내 evaluation_status='pending' 추천 로그 (최대 20건)
//
// 클라이언트 흐름:
//   환자2 진입 시 → 본 엔드포인트 호출 → 환자1 추천 카드별 평가 모달 표시
//   → POST /api/feedback (recommendation_log_id + recommended_technique_index 동봉)
//   → DB 트리거가 recommendation_logs.evaluation_status='rated' 자동 갱신
//
// 마이그 051 의존:
//   - recommendation_logs.evaluation_status (enum: pending/rated/expired/skipped)
//   - 14일 경과 pending → expired (expire_old_pending_evaluations() 함수, 별도 cron)

import { verifyToken } from './_auth.js';
import { applyGlossary } from './_term_glossary.js';

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;

// ── term_glossary 후처리 (history.js 패턴 차용) ──
// 처리 대상:
//   - log.symptom                         → bodyRegion=log.region
//   - log.recommended_techniques[].name   → bodyRegion=log.region
//   - log.recommended_techniques[].category_key (한글 섞일 가능성 대비)
async function applyGlossaryToPendingResponse(list) {
  if (!Array.isArray(list) || list.length === 0) return;

  const apply = (text, region) =>
    applyGlossary(text, { bodyRegion: region || null }).catch(err => {
      console.warn('[term_glossary] pending-evaluations 후처리 실패:', err.message);
      return text;
    });

  const tasks = [];
  for (const log of list) {
    if (!log || typeof log !== 'object') continue;
    const region = log.region || null;

    if (typeof log.symptom === 'string' && log.symptom.length > 0) {
      tasks.push(apply(log.symptom, region).then(v => { log.symptom = v; }));
    }

    if (Array.isArray(log.recommended_techniques)) {
      for (const item of log.recommended_techniques) {
        if (!item || typeof item !== 'object') continue;
        if (typeof item.name === 'string' && item.name.length > 0) {
          tasks.push(apply(item.name, region).then(v => { item.name = v; }));
        }
        if (typeof item.category_key === 'string' && item.category_key.length > 0) {
          tasks.push(apply(item.category_key, region).then(v => { item.category_key = v; }));
        }
      }
    }
  }

  if (tasks.length > 0) await Promise.all(tasks);
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const { user, error: authError } = await verifyToken(req);
  if (authError) return res.status(401).json({ error: authError });

  if (!SUPABASE_KEY) {
    return res.status(500).json({ error: 'Supabase 설정 오류' });
  }

  const userToken = (req.headers['authorization'] || '').split(' ')[1];
  const authHeaders = {
    'apikey': SUPABASE_KEY,
    'Authorization': `Bearer ${userToken}`,
  };

  try {
    // 14일 윈도우 (마이그 051 expire_old_pending_evaluations 와 동일 기간)
    const sinceIso = new Date(Date.now() - 14 * 24 * 60 * 60 * 1000).toISOString();
    const url = `${SUPABASE_URL}/rest/v1/recommendation_logs` +
      `?user_id=eq.${user.id}` +
      `&evaluation_status=eq.pending` +
      `&created_at=gte.${encodeURIComponent(sinceIso)}` +
      `&select=id,region,acuity,symptom,recommended_techniques,created_at` +
      `&order=created_at.desc&limit=20`;

    const response = await fetch(url, { headers: authHeaders });
    if (!response.ok) {
      const errText = await response.text();
      console.error('[pending-evaluations] Supabase error:', response.status, errText);
      return res.status(502).json({ error: 'pending evaluations 조회 실패' });
    }

    const pendingLogs = await response.json();
    const list = Array.isArray(pendingLogs) ? pendingLogs : [];

    // term_glossary 후처리 — 한자/외래어를 한글 표준으로 자동 치환
    await applyGlossaryToPendingResponse(list);

    return res.status(200).json({ pending: list });
  } catch (e) {
    console.error('[pending-evaluations GET]', e.message);
    return res.status(500).json({ error: 'pending evaluations 로드 실패' });
  }
}
