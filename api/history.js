// PT 처방 도우미 — 이력 조회 API
// GET /api/history                  → 최근 추천 이력 + "좋아요" 평가 기법 (recentLogs + likedTechniques)
// GET /api/history?type=pending     → 14일 내 evaluation_status='pending' 추천 로그 (최대 20건, { pending: [...] })
// GET /api/history?type=recent      → 위 기본(생략) 동작과 동일
//
// 통합 배경 (2026-05-06 핫픽스):
//   Vercel Hobby 플랜의 12 Serverless Functions 한도 초과로 인해
//   별도 엔드포인트였던 api/pending-evaluations.js 의 로직을 본 파일로 통합.
//   클라이언트 호환성을 위해 응답 shape 은 유지 ({ pending: [...] } vs { recentLogs, likedTechniques }).
//
// pending 분기 마이그 의존:
//   - recommendation_logs.evaluation_status (마이그 051: enum pending/rated/expired/skipped)
//   - 14일 경과 pending → expired (expire_old_pending_evaluations() 함수, 별도 cron)

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

// ── pending 분기 전용 후처리 (구 api/pending-evaluations.js 에서 통합) ──
// 처리 대상:
//   - log.symptom                              → bodyRegion=log.region
//   - log.recommended_techniques[].name        → bodyRegion=log.region
//   - log.recommended_techniques[].category_key (한글 섞일 가능성 대비)
async function applyGlossaryToPendingResponse(list) {
  if (!Array.isArray(list) || list.length === 0) return;

  const apply = (text, region) =>
    applyGlossary(text, { bodyRegion: region || null }).catch(err => {
      console.warn('[term_glossary] pending 후처리 실패:', err.message);
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

  // ?type=pending → 평가 대기 추천 조회 (구 /api/pending-evaluations 통합)
  // 그 외 (생략 / type=recent) → 기존 history (recentLogs + likedTechniques)
  const type = (req.query && req.query.type) || 'recent';

  if (type === 'pending') {
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
        console.error('[history?type=pending] Supabase error:', response.status, errText);
        return res.status(502).json({ error: 'pending evaluations 조회 실패' });
      }

      const pendingLogs = await response.json();
      const list = Array.isArray(pendingLogs) ? pendingLogs : [];

      // term_glossary 후처리 — 한자/외래어를 한글 표준으로 자동 치환
      await applyGlossaryToPendingResponse(list);

      return res.status(200).json({ pending: list });
    } catch (e) {
      console.error('[history?type=pending GET]', e.message);
      return res.status(500).json({ error: 'pending evaluations 로드 실패' });
    }
  }

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
      // "좋아요" 평가 기법 — 단일 신호 모델 (대표님 결정 2026-05-06):
      // outcome ∈ {excellent, good} 만 필터. star_rating 기준 폐기 (마이그 054 NULL 허용).
      fetch(
        `${SUPABASE_URL}/rest/v1/ratings` +
        `?user_id=eq.${user.id}` +
        `&outcome=in.(excellent,good)` +
        `&select=outcome,star_rating,created_at,techniques(name_ko,technique_categories(category_key,name_ko))` +
        `&order=created_at.desc&limit=30`,
        { headers: authHeaders }
      ),
    ]);

    const recentLogs  = await logsRes.json();
    const ratingsData = await ratingsRes.json();

    // 평가 데이터 평탄화
    // 단일 신호 모델: outcome 이 1차 키. star_rating 은 deprecated (마이그 054 후 NULL 가능)
    // — 호환성을 위해 응답에 그대로 포함. 라벨링은 클라이언트 책임.
    const likedTechniques = (Array.isArray(ratingsData) ? ratingsData : [])
      .filter(r => r.techniques)
      .map(r => ({
        name_ko:       r.techniques.name_ko,
        category_key:  r.techniques.technique_categories?.category_key  || null,
        category_name: r.techniques.technique_categories?.name_ko       || null,
        outcome:       r.outcome,      // 'excellent' | 'good' (필터 결과)
        star_rating:   r.star_rating,  // deprecated, NULL 가능
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
