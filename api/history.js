// PT 처방 도우미 — 이력 조회 API
// GET /api/history → 최근 추천 이력 + 별 3개 이상 평가 기법

import { verifyToken } from './_auth.js';
import { applyGlossary } from './_term_glossary.js';

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;

// ── term_glossary 후처리 (history 응답 직렬화 직전) ──
// 처리 대상:
//   - likedTechniques[].name_ko / category_name → 글로벌(bodyRegion=null)
//   - recentLogs[].selected_categories          → 배열 내 각 텍스트, bodyRegion=row.region
//   - recentLogs[].recommended_techniques       → JSONB 배열의 {name, category_key} 중
//                                                 텍스트 필드, bodyRegion=row.region
// recommended_techniques JSONB 구조는 api/recommend.js:logRecommendationSession
// (라인 795~798) 의 INSERT 시점 shape: [{ name: string, category_key: string|null }, ...].
// 모든 필드는 Promise.all 로 병렬 처리. 실패 시 원문 유지.
async function applyGlossaryToHistoryResponse(payload) {
  if (!payload || typeof payload !== 'object') return;

  const apply = (text, region) =>
    applyGlossary(text, { bodyRegion: region || null }).catch(err => {
      console.warn('[term_glossary] history 후처리 실패:', err.message);
      return text;
    });

  const tasks = [];

  // 1) likedTechniques[] — 글로벌 후처리 (특정 부위에 묶이지 않음)
  const liked = Array.isArray(payload.likedTechniques) ? payload.likedTechniques : [];
  for (const t of liked) {
    if (!t || typeof t !== 'object') continue;
    if (typeof t.name_ko === 'string' && t.name_ko.length > 0) {
      tasks.push(apply(t.name_ko, null).then(v => { t.name_ko = v; }));
    }
    if (typeof t.category_name === 'string' && t.category_name.length > 0) {
      tasks.push(apply(t.category_name, null).then(v => { t.category_name = v; }));
    }
  }

  // 2) recentLogs[] — region 별 후처리
  const logs = Array.isArray(payload.recentLogs) ? payload.recentLogs : [];
  for (const log of logs) {
    if (!log || typeof log !== 'object') continue;
    const region = log.region || null;

    // selected_categories: 텍스트 배열
    if (Array.isArray(log.selected_categories)) {
      const arr = log.selected_categories;
      for (let i = 0; i < arr.length; i++) {
        const v = arr[i];
        if (typeof v === 'string' && v.length > 0) {
          tasks.push(apply(v, region).then(nv => { arr[i] = nv; }));
        }
      }
    }

    // recommended_techniques: JSONB 배열 — [{ name, category_key }]
    if (Array.isArray(log.recommended_techniques)) {
      for (const item of log.recommended_techniques) {
        if (!item || typeof item !== 'object') continue;
        if (typeof item.name === 'string' && item.name.length > 0) {
          tasks.push(apply(item.name, region).then(v => { item.name = v; }));
        }
        // category_key 는 슬러그(영문)이지만 한글 표시명을 담는 구현이 있을 수 있어
        // 한글이 섞여 있을 때만 후처리 (영문 슬러그는 applyGlossary no-op).
        if (typeof item.category_key === 'string' && item.category_key.length > 0) {
          tasks.push(apply(item.category_key, region).then(v => { item.category_key = v; }));
        }
      }
    }

    // symptom: 자유 텍스트 (있으면 후처리)
    if (typeof log.symptom === 'string' && log.symptom.length > 0) {
      tasks.push(apply(log.symptom, region).then(v => { log.symptom = v; }));
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

  const userToken = (req.headers['authorization'] || '').split(' ')[1];
  const authHeaders = {
    'apikey': SUPABASE_KEY,
    'Authorization': `Bearer ${userToken}`,
  };

  try {
    const [logsRes, ratingsRes] = await Promise.all([
      // 최근 추천 이력 (20건)
      fetch(
        `${SUPABASE_URL}/rest/v1/recommendation_logs` +
        `?user_id=eq.${user.id}` +
        `&select=id,region,acuity,symptom,selected_categories,recommended_techniques,created_at` +
        `&order=created_at.desc&limit=20`,
        { headers: authHeaders }
      ),
      // 별 3개 이상 평가 기법 (techniques 조인)
      fetch(
        `${SUPABASE_URL}/rest/v1/ratings` +
        `?user_id=eq.${user.id}` +
        `&star_rating=gte.3` +
        `&select=star_rating,created_at,techniques(name_ko,technique_categories(category_key,name_ko))` +
        `&order=star_rating.desc,created_at.desc&limit=30`,
        { headers: authHeaders }
      ),
    ]);

    const recentLogs  = await logsRes.json();
    const ratingsData = await ratingsRes.json();

    // 평가 데이터 평탄화
    const likedTechniques = (Array.isArray(ratingsData) ? ratingsData : [])
      .filter(r => r.techniques)
      .map(r => ({
        name_ko:       r.techniques.name_ko,
        category_key:  r.techniques.technique_categories?.category_key  || null,
        category_name: r.techniques.technique_categories?.name_ko       || null,
        star_rating:   r.star_rating,
        created_at:    r.created_at,
      }));

    const payload = {
      recentLogs:      Array.isArray(recentLogs) ? recentLogs : [],
      likedTechniques,
    };

    // term_glossary 후처리 — 한자/외래어를 한글 표준으로 자동 치환
    // (saas/migrations/052·053). 캐시 hit 시 ~0ms / cold ~50-100ms.
    await applyGlossaryToHistoryResponse(payload);

    return res.status(200).json(payload);
  } catch (e) {
    console.error('[history GET]', e.message);
    return res.status(500).json({ error: '이력 로드 실패' });
  }
}
