// PT 처방 도우미 — 벡터 점수 디버그 API
// 사용 목적: 대표님 전용 내부 디버그 도구. 인증 불필요 (내부망 전용 도구)
// Input:  { region, acuity, symptom, selectedCategories }
// Output: { techniques[], vectorRows[], queryText, stats }

// ── Voyage AI 임베딩 헬퍼 ──
async function getQueryEmbedding(text) {
  const VOYAGE_API_KEY = process.env.VOYAGE_API_KEY;
  if (!VOYAGE_API_KEY) return null;
  try {
    const response = await fetch('https://api.voyageai.com/v1/embeddings', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${VOYAGE_API_KEY}` },
      body: JSON.stringify({ model: 'voyage-3-lite', input: [text] }),
    });
    if (!response.ok) return null;
    const data = await response.json();
    return data?.data?.[0]?.embedding || null;
  } catch { return null; }
}

// ── pgvector 유사도 검색 ──
async function fetchVectorSimilarities(queryEmbedding) {
  if (!queryEmbedding) return [];
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_KEY) return [];
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/match_techniques`, {
      method: 'POST',
      headers: { 'apikey': SUPABASE_KEY, 'Authorization': `Bearer ${SUPABASE_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ query_embedding: queryEmbedding, match_threshold: 0.1, match_count: 50 }),
    });
    if (!response.ok) return [];
    const data = await response.json();
    return Array.isArray(data) ? data : [];
  } catch { return []; }
}

// ── 전체 기법 조회 ──
async function fetchAllTechniques(categories, bodyRegions) {
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_KEY) return [];

  const catFilter = categories.length > 0
    ? `&or=(${categories.map(c => `category.eq.${c}`).join(',')})`
    : '';
  const url = `${SUPABASE_URL}/rest/v1/techniques?is_active=eq.true${catFilter}&select=id,abbreviation,name_ko,category,body_region,target_tags&limit=200`;

  try {
    const res = await fetch(url, {
      headers: { 'apikey': SUPABASE_KEY, 'Authorization': `Bearer ${SUPABASE_KEY}` }
    });
    if (!res.ok) return [];
    const data = await res.json();
    let all = (data || []).filter(t => t.name_ko);
    if (bodyRegions.length > 0) {
      all = all.filter(t => !t.body_region || bodyRegions.includes(t.body_region));
    }
    return all;
  } catch { return []; }
}

// ── 모든 기법 임베딩 유사도 매트릭스 조회 (그래프용) ──
async function fetchTechniquePairSimilarities(techniqueIds) {
  if (techniqueIds.length === 0) return [];
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_KEY) return [];

  // technique_embeddings 테이블에서 해당 기법들의 임베딩 조회
  const idList = techniqueIds.map(id => `id.eq.${id}`).join(',');
  const url = `${SUPABASE_URL}/rest/v1/technique_embeddings?or=(${idList})&select=technique_id,embedding`;

  try {
    const res = await fetch(url, {
      headers: { 'apikey': SUPABASE_KEY, 'Authorization': `Bearer ${SUPABASE_KEY}` }
    });
    if (!res.ok) return [];
    const data = await res.json();
    return Array.isArray(data) ? data : [];
  } catch { return []; }
}

const REGION_MAP = {
  '경추':   { primary: ['cervical'],    secondary: ['thoracic'] },
  '요추':   { primary: ['lumbar'],      secondary: ['sacroiliac'] },
  '어깨 관절': { primary: ['shoulder'],   secondary: ['thoracic'] },
  '무릎 관절': { primary: ['knee'],       secondary: [] },
  '엉덩 관절': { primary: ['hip'],        secondary: ['sacroiliac'] },
  '발목 관절': { primary: ['ankle_foot'], secondary: [] },
};

const CONDITION_CATEGORY_SCORES = {
  '급성': {
    '움직임 시 통증': { category_mulligan: 3, category_mdt: 3, category_scs: 3, category_d_neural: 2, category_joint_mobilization: 1, category_mfr: 1, category_ctm: 1, category_trigger_point: 1, category_pne: 1 },
    '안정 시 통증': { category_scs: 3, category_mdt: 2, category_d_neural: 1, category_pne: 1 },
    '방사통': { category_d_neural: 3, category_mdt: 3, category_mulligan: 1, category_scs: 1, category_pne: 1 },
  },
  '아급성': {
    '움직임 시 통증': { category_joint_mobilization: 3, category_mdt: 3, category_mulligan: 2, category_mfr: 2, category_art: 2, category_ctm: 2, category_deep_friction: 2, category_trigger_point: 2, category_d_neural: 2, category_scs: 2, category_pne: 2, category_anatomy_trains: 1 },
    '안정 시 통증': { category_scs: 2, category_trigger_point: 2, category_mdt: 2, category_ctm: 2, category_pne: 2, category_joint_mobilization: 1, category_mulligan: 1, category_mfr: 1, category_art: 1, category_deep_friction: 1, category_anatomy_trains: 1, category_d_neural: 1 },
    '방사통': { category_d_neural: 3, category_mdt: 3, category_mulligan: 2, category_joint_mobilization: 1, category_mfr: 1, category_art: 1, category_ctm: 1, category_deep_friction: 1, category_trigger_point: 1, category_scs: 1, category_pne: 1 },
  },
  '만성': {
    '움직임 시 통증': { category_joint_mobilization: 3, category_mfr: 3, category_art: 3, category_deep_friction: 3, category_trigger_point: 3, category_pne: 3, category_mulligan: 2, category_ctm: 2, category_anatomy_trains: 2, category_d_neural: 2, category_mdt: 2, category_scs: 2 },
    '안정 시 통증': { category_ctm: 3, category_pne: 3, category_mfr: 2, category_art: 2, category_deep_friction: 2, category_trigger_point: 2, category_joint_mobilization: 1, category_mulligan: 1, category_anatomy_trains: 1, category_d_neural: 1, category_mdt: 1, category_scs: 1 },
    '방사통': { category_d_neural: 3, category_mulligan: 2, category_mdt: 2, category_art: 2, category_pne: 2, category_joint_mobilization: 1, category_mfr: 1, category_ctm: 1, category_deep_friction: 1, category_trigger_point: 1 },
  },
};

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(200).end();

  const body = req.method === 'GET' ? req.query : req.body;
  const { region = '경추', acuity = '아급성', symptom = '움직임 시 통증', selectedCategories } = body;

  const categories = selectedCategories
    ? (typeof selectedCategories === 'string' ? JSON.parse(selectedCategories) : selectedCategories)
    : ['category_joint_mobilization', 'category_mulligan', 'category_mfr', 'category_art',
       'category_trigger_point', 'category_d_neural', 'category_mdt', 'category_scs', 'category_pne'];

  const regionConfig = REGION_MAP[region] || { primary: [], secondary: [] };
  const bodyRegions = [...regionConfig.primary, ...regionConfig.secondary];

  const queryText = `${region} ${acuity} ${symptom}`;

  // 병렬: 기법 조회 + 임베딩 생성
  const [techniques, queryEmbedding] = await Promise.all([
    fetchAllTechniques(categories, bodyRegions),
    getQueryEmbedding(queryText),
  ]);

  // 벡터 유사도
  const vectorRows = await fetchVectorSimilarities(queryEmbedding);
  const vectorScoreMap = Object.fromEntries(vectorRows.map(r => [r.id, r.similarity]));

  const RULE_SCORE_MAX = 3;
  const conditionScores = (CONDITION_CATEGORY_SCORES[acuity] || {})[symptom] || {};
  const acuityTagMap = { '급성': 'acute', '아급성': 'subacute', '만성': 'chronic' };
  const requiredTag = acuityTagMap[acuity];

  const scoredTechniques = techniques.map(t => {
    const ruleScore = conditionScores[t.category] ?? 0;
    const ruleNorm = ruleScore / RULE_SCORE_MAX;
    const vectorScore = vectorScoreMap[t.id] ?? 0;
    const hasVector = Object.keys(vectorScoreMap).length > 0;
    const finalScore = hasVector ? ruleNorm * 0.6 + vectorScore * 0.4 : ruleNorm;
    const passesTagFilter = !requiredTag || !Array.isArray(t.target_tags) || t.target_tags.length === 0 || t.target_tags.includes(requiredTag);

    return {
      id: t.id,
      abbreviation: t.abbreviation,
      name_ko: t.name_ko,
      category: t.category,
      body_region: t.body_region,
      target_tags: t.target_tags,
      ruleScore,
      ruleNorm: Math.round(ruleNorm * 100) / 100,
      vectorScore: Math.round(vectorScore * 1000) / 1000,
      finalScore: Math.round(finalScore * 1000) / 1000,
      passesTagFilter,
      hasVector: vectorScore > 0,
    };
  }).sort((a, b) => b.finalScore - a.finalScore);

  // 기법 간 임베딩 유사도 (그래프용) — technique_embeddings 테이블 조회
  const techniqueIds = techniques.map(t => t.id);
  const embedRows = await fetchTechniquePairSimilarities(techniqueIds);

  // 임베딩 벡터로 기법 간 cosine similarity 계산
  const embMap = {};
  embedRows.forEach(row => { embMap[row.technique_id] = row.embedding; });

  function cosine(a, b) {
    if (!a || !b || a.length !== b.length) return 0;
    let dot = 0, na = 0, nb = 0;
    for (let i = 0; i < a.length; i++) { dot += a[i] * b[i]; na += a[i] * a[i]; nb += b[i] * b[i]; }
    return na && nb ? dot / (Math.sqrt(na) * Math.sqrt(nb)) : 0;
  }

  const links = [];
  const ids = Object.keys(embMap);
  for (let i = 0; i < ids.length; i++) {
    for (let j = i + 1; j < ids.length; j++) {
      const sim = cosine(embMap[ids[i]], embMap[ids[j]]);
      if (sim > 0.6) {
        links.push({ source: ids[i], target: ids[j], similarity: Math.round(sim * 1000) / 1000 });
      }
    }
  }

  const stats = {
    queryText,
    hasEmbedding: !!queryEmbedding,
    totalTechniques: techniques.length,
    techniquesWithVector: scoredTechniques.filter(t => t.hasVector).length,
    techniquesPassingTagFilter: scoredTechniques.filter(t => t.passesTagFilter).length,
    vectorRowsReturned: vectorRows.length,
    embeddingPairsComputed: links.length,
    region, acuity, symptom,
    bodyRegions,
    categories,
  };

  return res.status(200).json({
    stats,
    techniques: scoredTechniques,
    vectorRows: vectorRows.slice(0, 30), // top 30 유사 기법
    links, // 그래프 엣지
  });
}
