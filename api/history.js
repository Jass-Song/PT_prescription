// PT 처방 도우미 — 이력 조회 API
// GET  /api/history                  → 최근 추천 이력 + "좋아요" 평가 기법 (recentLogs + likedTechniques)
// GET  /api/history?type=pending     → 14일 내 evaluation_status='pending' 추천 로그 (최대 20건, { pending: [...] })
// GET  /api/history?type=recent      → 위 기본(생략) 동작과 동일
// GET  /api/history?type=patients    → 본인 등록 환자 라벨 목록 (최대 50, { patients: [...] })
// POST /api/history { type:'patients', label } → 환자 라벨 신규 등록 (UNIQUE 충돌 시 409 + 기존 row)
//
// 통합 배경 (2026-05-06 핫픽스):
//   Vercel Hobby 플랜의 12 Serverless Functions 한도 초과로 인해
//   별도 엔드포인트였던 api/pending-evaluations.js 의 로직을 본 파일로 통합.
//   클라이언트 호환성을 위해 응답 shape 은 유지 ({ pending: [...] } vs { recentLogs, likedTechniques }).
//
// 환자 timeline tracking (2026-05-12, 마이그 059 의존):
//   - patients 테이블 (id UUID, user_id FK, label TEXT, last_visit_at, visit_count, notes)
//   - UNIQUE (user_id, label) — 동일 PT 가 같은 라벨 재등록 시 409 + 기존 row 반환 (idempotent UX)
//   - RLS: user_id = auth.uid() — 다른 PT 환자 노출 0 보장
//   - 신규 endpoint 파일 (api/patients.js) 생성 금지 — Vercel Hobby 12-fn 한도
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
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(200).end();

  // GET (조회: recent / pending / patients) + POST (등록: patients) 만 허용
  if (req.method !== 'GET' && req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

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

  // ── POST 분기: 환자 라벨 신규 등록 ──
  // 본문: { type: 'patients', label: '<text>' }
  // 응답: 201 { ok: true, patient: { id, label, last_visit_at, visit_count } }
  //       409 { ok: false, error, patient: {...기존 row...} }  ← UNIQUE 충돌 (idempotent UX)
  //       400 { error } — 본문 검증 실패
  if (req.method === 'POST') {
    const body = req.body || {};
    if (body.type !== 'patients') {
      return res.status(400).json({ error: 'type 은 "patients" 만 지원합니다' });
    }
    // 라벨 검증: trim → 1~50자, 빈 문자열 거부
    const rawLabel = typeof body.label === 'string' ? body.label : '';
    const label = rawLabel.trim();
    if (label.length === 0) {
      return res.status(400).json({ error: '환자 라벨이 비어 있습니다' });
    }
    if (label.length > 50) {
      return res.status(400).json({ error: '환자 라벨은 50자 이내로 입력해주세요' });
    }

    try {
      // INSERT — UNIQUE (user_id, label) 위반 시 PostgREST 가 409 + code 23505 반환
      const insertUrl = `${SUPABASE_URL}/rest/v1/patients` +
        `?select=id,label,last_visit_at,visit_count`;
      const insertRes = await fetch(insertUrl, {
        method: 'POST',
        headers: {
          ...authHeaders,
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
        },
        // user_id 는 RLS 정책 (WITH CHECK user_id = auth.uid()) 이 강제 — 명시도 가능하나
        // 마이그 059 default(auth.uid()) 가 있으면 생략 가능. 안전하게 명시.
        body: JSON.stringify({ user_id: user.id, label }),
      });

      if (insertRes.ok) {
        const rows = await insertRes.json();
        const patient = Array.isArray(rows) ? rows[0] : rows;
        return res.status(201).json({ ok: true, patient });
      }

      // UNIQUE 충돌 → 기존 row 조회 후 409 반환 (idempotent UX — 클라이언트는 그대로 선택)
      if (insertRes.status === 409) {
        const fetchUrl = `${SUPABASE_URL}/rest/v1/patients` +
          `?user_id=eq.${user.id}` +
          `&label=eq.${encodeURIComponent(label)}` +
          `&select=id,label,last_visit_at,visit_count&limit=1`;
        const dupRes = await fetch(fetchUrl, { headers: authHeaders });
        const dupRows = dupRes.ok ? await dupRes.json() : [];
        const existing = Array.isArray(dupRows) && dupRows.length > 0 ? dupRows[0] : null;
        return res.status(409).json({
          ok: false,
          error: '동일한 라벨의 환자가 이미 존재합니다',
          patient: existing,
        });
      }

      const errText = await insertRes.text();
      console.error('[history POST patients] Supabase error:', insertRes.status, errText);
      return res.status(502).json({ error: '환자 등록 실패' });
    } catch (e) {
      console.error('[history POST patients]', e.message);
      return res.status(500).json({ error: '환자 등록 실패' });
    }
  }

  // ?type=pending  → 평가 대기 추천 조회 (구 /api/pending-evaluations 통합)
  // ?type=patients → 본인 등록 환자 라벨 목록 (드롭다운용)
  // 그 외 (생략 / type=recent) → 기존 history (recentLogs + likedTechniques)
  const type = (req.query && req.query.type) || 'recent';

  // ── GET ?type=patients ──
  // 응답: { patients: [{ id, label, last_visit_at, visit_count }, ...] }
  // 정렬: last_visit_at DESC NULLS LAST → 최근 방문 환자 상단
  // RLS: user_id = auth.uid() (마이그 059) — 추가 user_id 필터는 안전망
  if (type === 'patients') {
    try {
      const url = `${SUPABASE_URL}/rest/v1/patients` +
        `?user_id=eq.${user.id}` +
        `&select=id,label,last_visit_at,visit_count` +
        `&order=last_visit_at.desc.nullslast&limit=50`;
      const response = await fetch(url, { headers: authHeaders });
      if (!response.ok) {
        const errText = await response.text();
        console.error('[history?type=patients] Supabase error:', response.status, errText);
        return res.status(502).json({ error: '환자 목록 조회 실패' });
      }
      const rows = await response.json();
      // term_glossary 후처리 불필요 — label 은 PT 자유 입력 (자동 치환 대상 아님)
      return res.status(200).json({ patients: Array.isArray(rows) ? rows : [] });
    } catch (e) {
      console.error('[history?type=patients GET]', e.message);
      return res.status(500).json({ error: '환자 목록 로드 실패' });
    }
  }

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
