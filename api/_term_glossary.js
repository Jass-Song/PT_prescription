// PT 처방 도우미 — term_glossary 후처리 모듈
//
// 한국어 PT 임상 용어 표준화 단일 진실 소스(saas/migrations/052-term-glossary.sql)에
// 기반한 서버 사이드 LLM 응답 후처리.
//
// 책임:
//   1) Supabase term_glossary 테이블을 in-memory Map 으로 캐시 (TTL 1h)
//   2) applyGlossary(text, opts) — is_preserved 보호 → disambiguation 보호 →
//      original_ko → replacement_ko 치환 (영문 병기) → 임시 토큰 복원
//   3) invalidateGlossary() — 어드민 cache invalidation 엔드포인트에서 호출
//
// 단일 진실 소스: saas/docs/term-glossary-design.md §6
// 단일 fetch 패턴: 동시 요청에서도 한 번만 fetch (Promise 캐싱)
//
// 작성: sw-backend-dev, 2026-05-05

const SUPABASE_URL =
  process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_KEY =
  process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_ANON_KEY;

const CACHE_TTL_MS = 60 * 60 * 1000; // 1 hour

// ── 모듈 스코프 캐시 ──────────────────────────────────────────────
// Vercel serverless: 인스턴스 단위 (warm container 재사용 시 공유).
// 동시 요청 시 1회만 fetch 하도록 in-flight Promise 를 함께 캐싱한다.
let _state = {
  byKey: null,                  // Map<`${original_ko}::${region|*}`, row>
  preservedTokens: null,        // Array<row> — is_preserved=true
  disambRows: null,             // Array<row> — disambiguation_pattern 가 있는 row
  loadedAt: 0,                  // 마지막 로드 timestamp (ms)
  inflight: null,               // Promise<void> — 진행 중인 fetch (있으면 await)
};

// ── 정규식 안전 이스케이프 ──
// original_ko 가 토큰화된 한국어이므로 메타문자 거의 없으나 방어적으로 처리.
function escapeRegex(s) {
  return String(s).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// 본문에 이미 (english) 병기가 있는지 검사 — 단순 substring 체크
function alreadyHasEnglish(text, term, english) {
  if (!english) return false;
  // 'replacement (english)' 또는 'replacement(english)' 패턴 모두 검사
  // 또한 본문 어디든 ' (english)' 형태가 이미 있으면 중복 회피
  const re = new RegExp(`\\(\\s*${escapeRegex(english)}\\s*\\)`, 'i');
  return re.test(text);
}

// ── 캐시 로드 (콜드 스타트 또는 TTL 만료 시 호출) ──
async function _fetchGlossary() {
  if (!SUPABASE_URL || !SUPABASE_KEY) {
    // 키 미설정 — 빈 캐시로 동작 (후처리 no-op)
    console.warn('[term_glossary] SUPABASE_URL/SERVICE_KEY 미설정 — 후처리 비활성');
    _state.byKey = new Map();
    _state.preservedTokens = [];
    _state.disambRows = [];
    _state.loadedAt = Date.now();
    return;
  }

  const url =
    `${SUPABASE_URL}/rest/v1/term_glossary` +
    `?status=eq.active` +
    `&select=original_ko,replacement_ko,english,category,body_region,` +
    `disambiguation_pattern,is_preserved`;

  const res = await fetch(url, {
    headers: {
      apikey: SUPABASE_KEY,
      Authorization: `Bearer ${SUPABASE_KEY}`,
    },
  });
  if (!res.ok) {
    throw new Error(`term_glossary fetch 실패: ${res.status}`);
  }
  const rows = await res.json();

  // phrase 길이 우선 정렬 (내림차순) — prefix 충돌 자동 해결.
  // 예: '신장 자세'(2단어 phrase) 가 '신장'(단어) 보다 먼저 매칭되어야 함.
  // JavaScript Map 은 insertion order 를 보장하므로 정렬된 순서로 set.
  // is_preserved / disambiguation 배열도 동일 정렬 적용 (예: 'TrP-deep' vs 'TrP').
  const sortedRows = (Array.isArray(rows) ? rows : [])
    .slice()
    .sort(
      (a, b) =>
        String(b.original_ko || '').length - String(a.original_ko || '').length
    );

  const byKey = new Map();
  const preservedTokens = [];
  const disambRows = [];

  for (const row of sortedRows) {
    const region = row.body_region || '*';
    byKey.set(`${row.original_ko}::${region}`, row);
    if (row.is_preserved) preservedTokens.push(row);
    if (row.disambiguation_pattern) disambRows.push(row);
  }

  _state.byKey = byKey;
  _state.preservedTokens = preservedTokens;
  _state.disambRows = disambRows;
  _state.loadedAt = Date.now();
}

// ── public: 캐시 로드·갱신 ──
// force=true 면 TTL 무시하고 재로드.
// 동시 호출은 inflight promise 를 공유 (단일 fetch).
export async function loadGlossary({ force = false } = {}) {
  const now = Date.now();
  const fresh =
    _state.byKey !== null && now - _state.loadedAt < CACHE_TTL_MS;
  if (!force && fresh) return;

  if (_state.inflight) {
    await _state.inflight;
    if (!force) return;
  }

  _state.inflight = (async () => {
    try {
      await _fetchGlossary();
    } finally {
      _state.inflight = null;
    }
  })();
  await _state.inflight;
}

// ── public: 캐시 무효화 ──
// 어드민 endpoint 에서 호출. 다음 applyGlossary/loadGlossary 시 즉시 재로드.
export function invalidateGlossary() {
  _state.byKey = null;
  _state.preservedTokens = null;
  _state.disambRows = null;
  _state.loadedAt = 0;
  _state.inflight = null;
}

// ── 내부: 토큰 placeholder 생성기 ──
function makeTokenizer(prefix) {
  let i = 0;
  const map = new Map(); // token → original
  return {
    next(original) {
      const tok = `__${prefix}_${i++}__`;
      map.set(tok, original);
      return tok;
    },
    restore(text) {
      let out = text;
      for (const [tok, original] of map) {
        // 단순 split-join 으로 안전 복원 (placeholder 는 메타문자 없음)
        out = out.split(tok).join(original);
      }
      return out;
    },
  };
}

// ── public: 핵심 후처리 ──
// 처리 순서 (반드시 유지):
//   1) is_preserved=true 약어 보호 → __PRESERVED_n__
//   2) disambiguation_pattern 매칭 구간 보호 → __DISAMB_n__
//   3) original_ko → replacement_ko 치환 (body_region 우선, 없으면 글로벌)
//      4) 영어 병기는 3 안에서 수행 — 'replacement (english)' (이미 병기 있으면 skip)
//   5) 임시 토큰 복원
//   6) 빈 문자열/null/non-string → 그대로 반환 (방어 코드)
export async function applyGlossary(text, { bodyRegion = null } = {}) {
  if (text === null || text === undefined) return text;
  if (typeof text !== 'string') return text;
  if (text.length === 0) return text;

  await loadGlossary();
  const { byKey, preservedTokens, disambRows } = _state;
  if (!byKey || byKey.size === 0) return text;

  let out = text;

  // 1) is_preserved 약어 보호
  const preserveTok = makeTokenizer('PRESERVED');
  for (const row of preservedTokens || []) {
    if (!row.original_ko) continue;
    const re = new RegExp(escapeRegex(row.original_ko), 'g');
    out = out.replace(re, (m) => preserveTok.next(m));
  }

  // 2) disambiguation_pattern 매칭 구간 보호
  const disambTok = makeTokenizer('DISAMB');
  for (const row of disambRows || []) {
    let re;
    try {
      re = new RegExp(row.disambiguation_pattern, 'g');
    } catch {
      // 잘못된 정규식 — 안전하게 skip
      continue;
    }
    out = out.replace(re, (m) => disambTok.next(m));
  }

  // 3) original_ko → replacement_ko 치환
  // body_region 일치 row 우선 → 없으면 글로벌(*) row
  // 동일 original_ko 에 대해 여러 region 키가 있을 수 있으므로 unique original 만 순회
  const seenOriginals = new Set();
  for (const [, row] of byKey) {
    if (!row.original_ko) continue;
    if (row.is_preserved) continue;            // 이미 보호됨
    if (!row.replacement_ko) continue;         // 보존 정책 (NULL replacement)
    if (seenOriginals.has(row.original_ko)) continue;
    seenOriginals.add(row.original_ko);

    // 룩업 전략: bodyRegion 키 우선, 없으면 '*' 키
    let chosen = null;
    if (bodyRegion) {
      chosen = byKey.get(`${row.original_ko}::${bodyRegion}`) || null;
    }
    if (!chosen) chosen = byKey.get(`${row.original_ko}::*`) || null;
    if (!chosen) chosen = row; // 안전망 — 다른 region row 라도 사용
    if (!chosen.replacement_ko) continue;

    const replacement = chosen.replacement_ko;
    const english = chosen.english;

    const re = new RegExp(escapeRegex(row.original_ko), 'g');
    out = out.replace(re, () => {
      // 4) 영문 병기 — 이미 본문에 (english) 가 있으면 중복 회피
      if (english && !alreadyHasEnglish(out, replacement, english)) {
        return `${replacement}(${english})`;
      }
      return replacement;
    });
  }

  // 5) 임시 토큰 복원 (역순: disamb → preserved 순서는 무관, 토큰이 분리됨)
  out = disambTok.restore(out);
  out = preserveTok.restore(out);

  return out;
}

// ── 내부 헬퍼: 캐시 상태 (디버그용 export) ──
export function _debugCacheState() {
  return {
    loaded: _state.byKey !== null,
    rows: _state.byKey ? _state.byKey.size : 0,
    preserved: _state.preservedTokens ? _state.preservedTokens.length : 0,
    disamb: _state.disambRows ? _state.disambRows.length : 0,
    loadedAt: _state.loadedAt,
    ttlMs: CACHE_TTL_MS,
  };
}

// ============================================================
// 수동 검증 (로컬 또는 staging — sandbox 에서는 실행 금지)
// ============================================================
// 1) SUPABASE_URL / SUPABASE_SERVICE_KEY 환경변수 설정
// 2) node -e "import('./api/_term_glossary.js').then(m =>
//       m.applyGlossary('환자를 앙와위로 눕히고 견갑골을 외전').then(console.log))"
//    기대 출력: '환자를 등 대고 눕기로 눕히고 어깨뼈를 벌림(Abduction)'
// 3) 회내 (forearm) 검증:
//    applyGlossary('전완 회내 검사', { bodyRegion: 'forearm' })
//      → '아래팔 엎침(Pronation) 검사'
// 4) 회내 (ankle) 검증:
//    applyGlossary('발 회내 변형', { bodyRegion: 'ankle' })
//      → '발 엎침(Pronation) 변형'      // ※ DB 시드에 따라 '안쪽 돌리기' 일 수도 있음
// 5) 콩팥 제외 검증 (disambiguation):
//    applyGlossary('근육을 신장 / 신장(콩팥) 통증과 감별')
//      → '근육을 늘리기 / 신장(콩팥) 통증과 감별'
// 6) 약어 보존 검증:
//    applyGlossary('CTM 시작 전 ART 적용')
//      → 'CTM 시작 전 ART 적용' (변경 없음)
// 7) phrase 길이 우선 정렬 검증:
//    applyGlossary('근육 신장 자세 유지')
//      → '근육 늘어난 자세 유지' (NOT '근육 늘리기 자세 유지')
// 8) 단축/신장 자세 검증:
//    applyGlossary('견갑거근 단축 자세에서 시작')
//      → '견갑거근 짧아진 자세에서 시작'
//    applyGlossary('근막 신장 자세 유지')
//      → '근막 늘어난 자세 유지'
//
// 주의: 위 출력 예시는 DB 시드 (saas/migrations/052·053) 의 replacement_ko 와
// english 컬럼에 의해 결정된다. 부위별 정확한 매핑은 design doc §3 참조.
// ============================================================
