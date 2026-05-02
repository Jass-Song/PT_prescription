// PT 처방 도우미 — AI 추천 서버리스 함수
// Input:  { region, acuity, symptom, selectedCategories, excludedTechniqueIds, sessionHistory }
// Output: { manualTherapy[], exercise[], clinicalNote, selectedCategories, sessionSummary }

import { verifyToken } from './_auth.js';
import { logServerError } from './_logger.js';

// ── 세션 단위 usage 로깅 (session_logs 테이블, fire-and-forget) ──
// 추천 요청마다 부위·acuity·증상·카테고리·결과 수·응답시간 자동 저장
// 오류가 추천 응답을 막지 않도록 catch 필수
async function logSessionUsage({ userId, region, acuity, symptom, categories, resultCount, responseMs }) {
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_URL || !SUPABASE_KEY) return;
  await fetch(`${SUPABASE_URL}/rest/v1/session_logs`, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_KEY,
      'Authorization': `Bearer ${SUPABASE_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    },
    body: JSON.stringify({
      user_id: userId || null,
      region,
      acuity,
      symptom,
      categories,
      result_count: resultCount,
      response_ms: responseMs,
    }),
  });
}

// ── Voyage AI 임베딩 헬퍼 ──
// 사용자 입력 텍스트를 voyage-3-lite(512차원)로 임베딩
// VOYAGE_API_KEY 없거나 오류 시 null 반환 (graceful fallback)
async function getQueryEmbedding(text) {
  const VOYAGE_API_KEY = process.env.VOYAGE_API_KEY;
  if (!VOYAGE_API_KEY) return null;

  try {
    const response = await fetch('https://api.voyageai.com/v1/embeddings', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${VOYAGE_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'voyage-3-lite',
        input: [text],
      }),
    });
    if (!response.ok) {
      console.warn('[vector] Voyage API 오류:', response.status);
      return null;
    }
    const data = await response.json();
    return data?.data?.[0]?.embedding || null;
  } catch (err) {
    console.warn('[vector] 임베딩 생성 실패:', err.message);
    return null;
  }
}

// ── pgvector 유사도 검색 ──
// Supabase match_techniques RPC 호출 → { id: UUID, similarity: float }[] 반환
// 오류 시 빈 배열 반환 (graceful fallback)
async function fetchVectorSimilarities(queryEmbedding, userToken) {
  if (!queryEmbedding) return [];

  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_KEY) return [];

  const authToken = userToken || SUPABASE_KEY;
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/match_techniques`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        query_embedding: queryEmbedding,
        match_threshold: 0.3,
        match_count: 20,
      }),
    });
    if (!response.ok) {
      console.warn('[vector] match_techniques RPC 오류:', response.status);
      return [];
    }
    const data = await response.json();
    return Array.isArray(data) ? data : [];
  } catch (err) {
    console.warn('[vector] pgvector 검색 실패:', err.message);
    return [];
  }
}

// 치료사 선호 ID → Supabase category 매핑
const MT_CATEGORY_MAP = {
  mt_joint:   ['category_joint_mobilization', 'category_mulligan'],
  mt_soft:    ['category_mfr', 'category_art', 'category_ctm', 'category_deep_friction', 'category_trigger_point', 'category_anatomy_trains'],
  mt_neuro:   ['category_d_neural'],
  mt_special: ['category_mdt', 'category_scs'],
  mt_edu:     ['category_pne'],
};

// 역방향 맵: category → MT 그룹 ID
const CATEGORY_TO_MT_GROUP = {};
for (const [mtId, cats] of Object.entries(MT_CATEGORY_MAP)) {
  for (const cat of cats) CATEGORY_TO_MT_GROUP[cat] = mtId;
}

const MT_GROUP_LABEL = {
  mt_joint:   '관절가동술 (Maitland · Mulligan · HVLA)',
  mt_soft:    '연부조직 가동술 (MFR · ART · CTM · Deep Friction · Trigger Point · Anatomy Trains)',
  mt_neuro:   '신경가동술',
  mt_special: '특수기법 (MDT · SCS)',
  mt_edu:     '통증 신경과학 교육 (PNE)',
};

// ── Pillar 매핑 (한국 도수치료 3 박자 모델) ──
// 한국 임상 워크플로우: 관절 가동 + 연부조직 + 운동 3 그룹.
// 보조(d_neural/pne)는 룰점수 기반 자동 추가.
// 사용자가 focusPillars로 직접 선택 가능 (기본: 모두 활성).
const MT_PILLARS = {
  joint: {
    label: '관절 가동',
    label_en: 'Joint Mobilization',
    categories: ['category_joint_mobilization', 'category_mulligan', 'category_mdt'],
  },
  soft_tissue: {
    label: '연부조직',
    label_en: 'Soft Tissue',
    categories: [
      'category_mfr', 'category_art', 'category_ctm', 'category_deep_friction',
      'category_trigger_point', 'category_anatomy_trains', 'category_scs', 'category_iastm',
    ],
  },
};
const EXERCISE_PILLAR = {
  label: '운동',
  label_en: 'Exercise',
  categories: ['category_ex_resistance', 'category_ex_bodyweight', 'category_ex_neuromuscular', 'category_ex_aerobic'],
};
const ADJUNCT_PILLAR = {
  label: '보조',
  label_en: 'Adjunct',
  categories: ['category_d_neural', 'category_pne'],
};

// 카테고리 → pillar 역방향 맵
const CATEGORY_TO_PILLAR = {};
for (const [pillarKey, def] of Object.entries(MT_PILLARS)) {
  for (const cat of def.categories) CATEGORY_TO_PILLAR[cat] = pillarKey;
}
for (const cat of EXERCISE_PILLAR.categories) CATEGORY_TO_PILLAR[cat] = 'exercise';
for (const cat of ADJUNCT_PILLAR.categories) CATEGORY_TO_PILLAR[cat] = 'adjunct';

const ALL_PILLARS = { ...MT_PILLARS, exercise: EXERCISE_PILLAR, adjunct: ADJUNCT_PILLAR };

// 운동 처방 선호 ID → Supabase category 매핑
const EX_CATEGORY_MAP = {
  ex_neuro:    ['category_ex_neuromuscular'],
  ex_strength: ['category_ex_resistance', 'category_ex_bodyweight'],
  ex_aerobic:  ['category_ex_aerobic'],
};

const EX_PREFERENCE_LABEL = {
  ex_neuro:    '신경근·운동조절 훈련 (Motor Control)',
  ex_strength: '근력·저항성 운동 (Strength/Resistance)',
  ex_aerobic:  '유산소·활동성 운동 (Aerobic)',
};

// 환자 컨디션(acuity + symptom) 기반 카테고리 우선순위 점수표
// 근거: Maitland 8th ed. / Mulligan 6th ed. / Travell & Simons Vol.1-2 / Myers AT 4th ed.
//       Butler Mobilisation of the Nervous System / McKenzie MDT / Jones SCS / Moseley Explain Pain
// 그룹 내 기법을 이 점수 기준으로 정렬 후 상위 6개 후보 → Claude 최종 3개 선택. 미정의 기본값 0.
const CONDITION_CATEGORY_SCORES = {
  '급성': {
    '움직임 시 통증': {
      category_mulligan: 3, category_mdt: 3, category_scs: 3,
      category_d_neural: 2,
      category_joint_mobilization: 1, category_mfr: 1, category_ctm: 1,
      category_trigger_point: 1, category_pne: 1,
    },
    '안정 시 통증': {
      category_scs: 3,
      category_mdt: 2,
      category_d_neural: 1, category_pne: 1,
    },
    '방사통': {
      category_d_neural: 3, category_mdt: 3,
      category_mulligan: 1, category_scs: 1, category_pne: 1,
    },
  },
  '아급성': {
    '움직임 시 통증': {
      category_joint_mobilization: 3, category_mdt: 3,
      category_mulligan: 2, category_mfr: 2, category_art: 2, category_ctm: 2,
      category_deep_friction: 2, category_trigger_point: 2, category_d_neural: 2,
      category_scs: 2, category_pne: 2,
      category_anatomy_trains: 1,
    },
    '안정 시 통증': {
      category_scs: 2, category_trigger_point: 2, category_mdt: 2, category_ctm: 2, category_pne: 2,
      category_joint_mobilization: 1, category_mulligan: 1, category_mfr: 1, category_art: 1,
      category_deep_friction: 1, category_anatomy_trains: 1, category_d_neural: 1,
    },
    '방사통': {
      category_d_neural: 3, category_mdt: 3,
      category_mulligan: 2,
      category_joint_mobilization: 1, category_mfr: 1, category_art: 1, category_ctm: 1,
      category_deep_friction: 1, category_trigger_point: 1, category_scs: 1, category_pne: 1,
    },
  },
  '만성': {
    '움직임 시 통증': {
      category_joint_mobilization: 3, category_mfr: 3, category_art: 3,
      category_deep_friction: 3, category_trigger_point: 3, category_pne: 3,
      category_mulligan: 2, category_ctm: 2, category_anatomy_trains: 2,
      category_d_neural: 2, category_mdt: 2, category_scs: 2,
    },
    '안정 시 통증': {
      category_ctm: 3, category_pne: 3,
      category_mfr: 2, category_art: 2, category_deep_friction: 2, category_trigger_point: 2,
      category_joint_mobilization: 1, category_mulligan: 1, category_anatomy_trains: 1,
      category_d_neural: 1, category_mdt: 1, category_scs: 1,
    },
    '방사통': {
      category_d_neural: 3,
      category_mulligan: 2, category_mdt: 2, category_art: 2, category_pne: 2,
      category_joint_mobilization: 1, category_mfr: 1, category_ctm: 1,
      category_deep_friction: 1, category_trigger_point: 1,
    },
  },
};

// 프론트엔드 region 레이블 → DB body_region enum 값 매핑 (primary: 환부, secondary: 운동사슬 연관 부위)
// secondary 기법은 결과에서 relatedManualTherapy로 분리되어 "연관 부위 기법" 섹션에 표시됨
const REGION_MAP = {
  '경추':   { primary: ['cervical'],    secondary: ['thoracic'],   label: '경추(cervical spine)' },
  '요추':   { primary: ['lumbar'],      secondary: ['sacroiliac'], label: '요추(lumbar spine)' },
  '어깨 관절': { primary: ['shoulder'],   secondary: ['thoracic'],   label: '어깨 관절(shoulder)' },
  '무릎 관절': { primary: ['knee'],       secondary: [],             label: '무릎 관절(knee)' },
  '엉덩 관절': { primary: ['hip'],        secondary: ['sacroiliac'], label: '엉덩 관절(hip)' },
  '발목 관절': { primary: ['ankle_foot'], secondary: [],             label: '발목 관절(ankle)' },
};

// ── Anatomy Trains 라인 데이터 (리전별) ──
// Anatomy Trains는 치료 기법이 아닌 치료 관점이므로
// 리전에 해당하는 근막경선을 평가 지침으로 제공하고, 치료는 타 연부조직 기법으로 유도합니다.
const ANATOMY_TRAINS_DATA = {
  '경추': [
    {
      name: '심부 전방선 (Deep Front Line)',
      patientPosition: '바로 눕기. 경추 전방 심부 구조물 촉진·평가',
      therapistHands: 'MFR · ART · 호흡 패턴 운동 연계',
      movement: '1. 장경근·두장근 긴장도 촉진 2. 사각근·설골근 연결 확인 3. MFR·ART로 전방 라인 이완',
      targetMuscles: ['장경근(longus colli)', '두장근(longus capitis)', '사각근(scalenes)', '설골근(hyoid muscles)', '횡격막(diaphragm)'],
      patientFeedback: '두통·경추 전방 통증·호흡 패턴 이상 동반 시 우선 평가하세요',
      symptomPriority: { '방사통': 3, '안정 시 통증': 3, '움직임 시 통증': 1 },
    },
    {
      name: '표층 후방선 (Superficial Back Line)',
      patientPosition: '엎드려 눕기. 후두부~경추 이행부 긴장 촉진',
      therapistHands: 'MFR · 심부마찰 · CTM 적용',
      movement: '1. 후두하근 긴장도 확인 2. 경추~흉추 이행부 평가 3. MFR·심부마찰로 후방 라인 치료',
      targetMuscles: ['후두하근(suboccipital muscles)', '척추기립근(erector spinae)', '흉요근막(thoracolumbar fascia)', '슬굴곡근(hamstrings)', '족저근막(plantar fascia)'],
      patientFeedback: '경추 신전 통증·긴장성 두통·자세성 두통 시 후두하근부터 라인 전체 평가',
      symptomPriority: { '방사통': 1, '안정 시 통증': 2, '움직임 시 통증': 3 },
    },
    {
      name: '나선선 (Spiral Line)',
      patientPosition: '앉은 자세. 견갑골 안정성·흉추 회전 패턴 평가',
      therapistHands: '능형근 · 전거근 MFR · ART 적용',
      movement: '1. 능형근~전거근 연결 긴장도 촉진 2. 회전 대칭성 확인 3. MFR·ART로 나선 패턴 이완',
      targetMuscles: ['능형근(rhomboids)', '전거근(serratus anterior)', '외복사근(external oblique)', '내복사근(internal oblique)', '대퇴근막장근(TFL)'],
      patientFeedback: '경추 회전 제한·견갑골 익상·흉추 회전 비대칭 동반 시 우선 평가',
      symptomPriority: { '방사통': 2, '안정 시 통증': 1, '움직임 시 통증': 2 },
    },
    {
      name: '측방선 (Lateral Line)',
      patientPosition: '앉은 자세. 경추 측굴 범위·측방 긴장 패턴 평가',
      therapistHands: 'SCM · 사각근 ART · CTM 적용',
      movement: '1. SCM~사각근 긴장도 촉진 2. 측굴 대칭성 확인 3. ART·CTM으로 측방 라인 치료',
      targetMuscles: ['흉쇄유돌근(SCM)', '사각근(scalenes)', '외복사근(external oblique)', '요방형근(quadratus lumborum)', '비골근(peroneus)'],
      patientFeedback: '경추 측굴 제한·일측성 두통·어지러움 동반 시 SCM~사각근 우선 확인',
      symptomPriority: { '방사통': 2, '안정 시 통증': 2, '움직임 시 통증': 2 },
    },
  ],
  '요추': [
    {
      name: '표층 후방선 (Superficial Back Line)',
      patientPosition: '엎드려 눕기. 흉요근막 긴장도·분절 평가',
      therapistHands: 'MFR · CTM · 심부마찰 적용',
      movement: '1. 흉요근막 긴장 패턴 확인 2. 척추기립근~둔근 연결 평가 3. MFR·CTM으로 후방 라인 치료',
      targetMuscles: ['척추기립근(erector spinae)', '흉요근막(thoracolumbar fascia)', '대둔근(gluteus maximus)', '슬굴곡근(hamstrings)', '족저근막(plantar fascia)'],
      patientFeedback: '요추 굴곡 제한·후방 통증 패턴의 가장 흔한 장력선. 라인 전체를 평가하세요',
      symptomPriority: { '방사통': 1, '안정 시 통증': 2, '움직임 시 통증': 3 },
    },
    {
      name: '심부 전방선 (Deep Front Line)',
      patientPosition: '바로 눕기. 복부 심부 촉진·호흡 패턴 관찰',
      therapistHands: '장요근 MFR · ART · 안정화 운동 연계',
      movement: '1. 장요근 긴장도·단축 확인 2. 복횡근 활성화 패턴 평가 3. MFR·ART로 전방 라인 이완 후 안정화 운동 연계',
      targetMuscles: ['장요근(iliopsoas)', '복횡근(transversus abdominis)', '골반저근(pelvic floor)', '횡격막(diaphragm)', '전종인대(anterior longitudinal ligament)'],
      patientFeedback: '만성 요통·골반 통증·호흡 패턴 이상 동반 시 장요근부터 우선 평가',
      symptomPriority: { '방사통': 3, '안정 시 통증': 3, '움직임 시 통증': 1 },
    },
    {
      name: '후방 기능선 (Back Functional Line)',
      patientPosition: '엎드려 눕기. 광배근~대둔근 대각선 연결 확인',
      therapistHands: '광배근 · 대둔근 MFR · ART 적용',
      movement: '1. 광배근~흉요근막~대둔근 대각선 장력 촉진 2. 상·하지 연결 패턴 평가 3. MFR·ART로 기능선 이완',
      targetMuscles: ['광배근(latissimus dorsi)', '흉요근막(thoracolumbar fascia)', '대둔근(gluteus maximus)', '대퇴근막장근(TFL)'],
      patientFeedback: '천장관절 통증·보행 시 요통·회전 불안정 패턴에서 광배근~대둔근 연결 우선 평가',
      symptomPriority: { '방사통': 2, '안정 시 통증': 2, '움직임 시 통증': 2 },
    },
    {
      name: '측방선 (Lateral Line)',
      patientPosition: '앉은 자세. 요추 측굴 대칭성·요방형근 긴장 평가',
      therapistHands: '요방형근 · TFL ART · 심부마찰 적용',
      movement: '1. 요방형근~TFL 긴장도 촉진 2. 측방 굴곡 대칭성·장경인대 확인 3. ART·심부마찰로 측방 라인 치료',
      targetMuscles: ['요방형근(quadratus lumborum)', '대퇴근막장근(TFL)', '장경인대(IT band)', '외복사근(external oblique)', '비골근(peroneus)'],
      patientFeedback: '측방 요통·하지 방사통·다리 길이 차이 동반 시 요방형근~TFL 연결 우선 확인',
      symptomPriority: { '방사통': 2, '안정 시 통증': 1, '움직임 시 통증': 2 },
    },
  ],
  '어깨 관절': [
    {
      name: '심부 후방 팔선 (Deep Back Arm Line)',
      patientPosition: '앉은 자세. 어깨 외회전 제한 및 회전근개 긴장 촉진',
      therapistHands: '회전근개 MFR · ART 적용',
      movement: '1. 극상·극하·소원근 긴장도 촉진 2. 어깨 외회전 범위 확인 3. MFR·ART로 후방 팔선 이완',
      targetMuscles: ['극상근(supraspinatus)', '극하근(infraspinatus)', '소원근(teres minor)', '견갑하근(subscapularis)', '삼두근 장두(triceps long head)'],
      patientFeedback: '어깨 외회전 제한·야간 통증·오십견 증상 시 회전근개 라인 우선 평가하세요',
      symptomPriority: { '방사통': 1, '안정 시 통증': 3, '움직임 시 통증': 3 },
    },
    {
      name: '심부 전방 팔선 (Deep Front Arm Line)',
      patientPosition: '바로 눕기. 소흉근·견갑하근 긴장도 평가',
      therapistHands: '소흉근 ART · MFR · 견갑하근 이완 적용',
      movement: '1. 소흉근 긴장·단축 촉진 2. 어깨 내회전 가동범위 확인 3. ART·MFR로 전방 팔선 이완',
      targetMuscles: ['소흉근(pectoralis minor)', '견갑하근(subscapularis)', '이두근 단두(biceps short head)', '손목굴근(wrist flexors)'],
      patientFeedback: '어깨 내회전 제한·전방 어깨 통증·흉곽출구증후군 증상 동반 시 우선 평가',
      symptomPriority: { '방사통': 3, '안정 시 통증': 2, '움직임 시 통증': 2 },
    },
    {
      name: '표층 전방 팔선 (Superficial Front Arm Line)',
      patientPosition: '바로 눕기. 대흉근·이두근 긴장 패턴 확인',
      therapistHands: '대흉근 ART · MFR · 이두근 ART 적용',
      movement: '1. 대흉근~이두근 연결 긴장도 촉진 2. 어깨 굴곡 가동범위 확인 3. ART·MFR로 전방 라인 이완',
      targetMuscles: ['대흉근(pectoralis major)', '이두근(biceps brachii)', '전완굴근(forearm flexors)'],
      patientFeedback: '어깨 굴곡 제한·전방 어깨 통증·팔꿈치 굴곡 통증 동반 시 우선 평가',
      symptomPriority: { '방사통': 2, '안정 시 통증': 2, '움직임 시 통증': 3 },
    },
    {
      name: '나선선 (Spiral Line) — 견갑대',
      patientPosition: '앉은 자세. 견갑골 안정성·흉추 회전 패턴 평가',
      therapistHands: '능형근 · 전거근 MFR · ART 적용',
      movement: '1. 능형근~전거근 대각선 긴장도 촉진 2. 견갑골 날개 여부 확인 3. MFR·ART로 나선 패턴 이완',
      targetMuscles: ['전거근(serratus anterior)', '능형근(rhomboids)', '소흉근(pectoralis minor)', '흉쇄유돌근(SCM)'],
      patientFeedback: '견갑골 이상 움직임·날개 견갑골·어깨 외전 시 통증 동반 시 우선 평가',
      symptomPriority: { '방사통': 2, '안정 시 통증': 1, '움직임 시 통증': 2 },
    },
  ],
  '무릎 관절': [
    {
      name: '표층 후방선 (Superficial Back Line)',
      patientPosition: '엎드려 눕기. 슬굴곡근~비복근 긴장도 촉진',
      therapistHands: '슬굴곡근 · 비복근 MFR · ART 적용',
      movement: '1. 슬굴곡근 긴장·단축 정도 확인 2. 무릎 굽히기 가동범위 측정 3. MFR·ART로 후방 라인 이완',
      targetMuscles: ['슬굴곡근(hamstrings)', '비복근(gastrocnemius)', '가자미근(soleus)', '족저근막(plantar fascia)'],
      patientFeedback: '무릎 굽히기 제한·슬와 통증·전방 허벅지 당김 동반 시 후방선 전체 평가하세요',
      symptomPriority: { '방사통': 1, '안정 시 통증': 2, '움직임 시 통증': 3 },
    },
    {
      name: '측방선 (Lateral Line)',
      patientPosition: '옆으로 눕기. 장경인대·외측 무릎 긴장 촉진',
      therapistHands: 'IT 밴드 MFR · ART · 심부마찰 적용',
      movement: '1. IT밴드~외측광근 긴장도 촉진 2. 외측 무릎 통증 재현 여부 확인 3. MFR·ART·심부마찰로 측방 라인 치료',
      targetMuscles: ['장경인대(IT band)', '대퇴근막장근(TFL)', '외측광근(vastus lateralis)', '이두대퇴근(biceps femoris)', '비골근(peroneals)'],
      patientFeedback: '외측 무릎 통증·IT 밴드 증후군·외측 무릎 삐걱 소리 동반 시 우선 평가',
      symptomPriority: { '방사통': 2, '안정 시 통증': 2, '움직임 시 통증': 3 },
    },
    {
      name: '심부 전방선 (Deep Front Line)',
      patientPosition: '바로 눕기. 무릎 안쪽 구조물 촉진',
      therapistHands: '슬와근 MFR · 심부마찰 적용',
      movement: '1. 슬와근 긴장도·통증점 확인 2. 무릎 안쪽 관절 가동성 평가 3. MFR·심부마찰로 전방선 이완',
      targetMuscles: ['슬와근(popliteus)', '장지굴근(flexor digitorum longus)', '후경골근(tibialis posterior)', '장요근(iliopsoas)'],
      patientFeedback: '무릎 완전 펴기 제한·안쪽 무릎 통증·서 있을 때 무릎 잠김 느낌 동반 시 우선 평가',
      symptomPriority: { '방사통': 3, '안정 시 통증': 3, '움직임 시 통증': 1 },
    },
    {
      name: '나선선 (Spiral Line) — 무릎',
      patientPosition: '바로 눕기. 슬개골 추적 이상 평가',
      therapistHands: '장경인대 · 전경골근 ART · MFR 적용',
      movement: '1. IT밴드~전경골근 긴장 대칭성 촉진 2. 슬개골 안·바깥쪽 편위 확인 3. MFR·ART로 나선 패턴 이완',
      targetMuscles: ['장경인대(IT band)', '대퇴이두근(biceps femoris)', '전경골근(tibialis anterior)', '비골근(peroneals)'],
      patientFeedback: '슬개대퇴 통증증후군·슬개골 추적 이상·무릎 앞쪽 통증 동반 시 나선선 우선 평가',
      symptomPriority: { '방사통': 2, '안정 시 통증': 2, '움직임 시 통증': 2 },
    },
  ],
  '엉덩 관절': [
    {
      name: '심부 전방선 (Deep Front Line)',
      patientPosition: '바로 눕기. 장요근 긴장도·골반 중립 평가',
      therapistHands: '장요근 MFR · ART · 내전근 MFR 적용',
      movement: '1. 장요근 긴장·단축 촉진 2. 골반 앞으로 기울기 패턴 확인 3. MFR·ART로 전방선 이완',
      targetMuscles: ['장요근(iliopsoas)', '내전근군(adductor complex)', '골반저근(pelvic floor)', '복횡근(transversus abdominis)'],
      patientFeedback: '고관절 굽히기 제한·걸을 때 통증·골반 전방 경사 자세 동반 시 장요근부터 우선 평가',
      symptomPriority: { '방사통': 3, '안정 시 통증': 3, '움직임 시 통증': 2 },
    },
    {
      name: '측방선 (Lateral Line)',
      patientPosition: '옆으로 눕기. 대퇴근막장근·중둔근 긴장 평가',
      therapistHands: 'TFL · 중둔근 ART · MFR 적용',
      movement: '1. TFL~중둔근 긴장도 촉진 2. 외측 고관절 통증 재현 여부 확인 3. ART·MFR로 측방 라인 치료',
      targetMuscles: ['대퇴근막장근(TFL)', '중둔근(gluteus medius)', '소둔근(gluteus minimus)', '장경인대(IT band)'],
      patientFeedback: '대전자 통증·외측 엉덩이 통증·불안정한 보행 동반 시 우선 평가',
      symptomPriority: { '방사통': 2, '안정 시 통증': 2, '움직임 시 통증': 3 },
    },
    {
      name: '표층 후방선 (Superficial Back Line)',
      patientPosition: '엎드려 눕기. 대둔근~슬굴곡근 긴장 촉진',
      therapistHands: '대둔근 · 슬굴곡근 MFR · ART 적용',
      movement: '1. 대둔근 긴장도·통증점 확인 2. 고관절 펴기 가동범위 평가 3. MFR·ART로 후방 라인 이완',
      targetMuscles: ['대둔근(gluteus maximus)', '슬굴곡근(hamstrings)', '천결절인대(sacrotuberous ligament)', '척추기립근(erector spinae)'],
      patientFeedback: '고관절 펴기 제한·앉다 일어설 때 통증·후방 엉덩이 통증 동반 시 대둔근부터 평가',
      symptomPriority: { '방사통': 1, '안정 시 통증': 2, '움직임 시 통증': 3 },
    },
    {
      name: '후방 기능선 (Back Functional Line)',
      patientPosition: '엎드려 눕기. 대둔근~이상근 긴장도 촉진',
      therapistHands: '대둔근 · 이상근 MFR · ART 적용',
      movement: '1. 대둔근~이상근 긴장도 촉진 2. 천장관절 가동성 평가 3. MFR·ART로 기능선 이완',
      targetMuscles: ['대둔근(gluteus maximus)', '이상근(piriformis)', '흉요근막(thoracolumbar fascia)', '광배근(latissimus dorsi)'],
      patientFeedback: '걸을 때 엉덩이 통증·이상근 증후군·천장관절 기능장애 동반 시 기능선 전체 평가',
      symptomPriority: { '방사통': 2, '안정 시 통증': 2, '움직임 시 통증': 2 },
    },
  ],
  '발목 관절': [
    {
      name: '표층 후방선 (Superficial Back Line)',
      patientPosition: '엎드려 눕기. 비복근·아킬레스건 긴장 촉진',
      therapistHands: '비복근 · 아킬레스건 MFR · ART 적용',
      movement: '1. 비복근~아킬레스건 긴장도 촉진 2. 발목 발등 쪽으로 굽히기 범위 측정 3. MFR·ART로 후방 라인 이완',
      targetMuscles: ['비복근(gastrocnemius)', '가자미근(soleus)', '아킬레스건(Achilles tendon)', '족저근막(plantar fascia)'],
      patientFeedback: '발목 발등 굽히기 제한·아킬레스건 통증·족저근막염 동반 시 후방선 전체 평가',
      symptomPriority: { '방사통': 1, '안정 시 통증': 3, '움직임 시 통증': 3 },
    },
    {
      name: '측방선 (Lateral Line)',
      patientPosition: '옆으로 눕기. 비골근 긴장도·외측 발목 안정성 평가',
      therapistHands: '비골근 MFR · ART · 심부마찰 적용',
      movement: '1. 비골근 긴장도·압통 촉진 2. 발목 안쪽 굽히기 불안정성 평가 3. MFR·ART·심부마찰로 측방 라인 치료',
      targetMuscles: ['비골근(peroneals)', '장경인대(IT band) 원위부', '외측 발목 인대(lateral ankle ligaments)'],
      patientFeedback: '반복 발목 염좌·만성 외측 불안정성·외측 발목 통증 동반 시 비골근부터 우선 평가',
      symptomPriority: { '방사통': 2, '안정 시 통증': 2, '움직임 시 통증': 3 },
    },
    {
      name: '심부 전방선 (Deep Front Line)',
      patientPosition: '바로 눕기. 후경골근·족저 내재근 긴장 촉진',
      therapistHands: '후경골근 · 족저근막 MFR · 심부마찰 적용',
      movement: '1. 후경골근 긴장도·통증점 확인 2. 발 아치 높이·족저 내재근 활성도 평가 3. MFR·심부마찰로 전방선 이완',
      targetMuscles: ['후경골근(tibialis posterior)', '장지굴근(flexor digitorum longus)', '장모지굴근(flexor hallucis longus)', '족저 내재근(plantar intrinsic)'],
      patientFeedback: '평발·후족부 안쪽으로 꺾임·족저근막염 동반 시 족저 내재근~후경골근 연결 우선 평가',
      symptomPriority: { '방사통': 3, '안정 시 통증': 3, '움직임 시 통증': 1 },
    },
    {
      name: '나선선 (Spiral Line) — 발목',
      patientPosition: '바로 눕기. 전경골근·비골근 대각선 긴장 평가',
      therapistHands: '전경골근 · 비골근 ART · MFR 적용',
      movement: '1. 전경골근~비골근 긴장 대칭성 촉진 2. 발목 안·바깥 굽히기 대칭성 확인 3. ART·MFR로 나선 패턴 이완',
      targetMuscles: ['전경골근(tibialis anterior)', '비골근(peroneals)', '족저 근막(plantar fascia)'],
      patientFeedback: '발목 안·바깥 움직임 비대칭·걸을 때 발목 이상 패턴·만성 발목 불안정성 동반 시 평가',
      symptomPriority: { '방사통': 2, '안정 시 통증': 1, '움직임 시 통증': 2 },
    },
  ],
};

// Supabase에서 카테고리별 기법 전체 조회 (body_region 포함)
// 부위 필터는 서버에서 처리: body_region이 NULL(범용)이거나 대상 부위에 해당하는 기법만 반환
async function fetchActiveTechniques(categories, bodyRegions = [], userToken = null) {
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_KEY || categories.length === 0) return [];

  const catFilter = categories.map(c => `category.eq.${c}`).join(',');
  const selectFields = `id,abbreviation,name_ko,category,body_region,body_regions,patient_position,therapist_position,contact_point,direction,technique_steps,target_tags,applicable_muscles`;
  // RLS는 auth.uid() 기반 — 사용자 JWT가 있으면 사용, 없으면 anon key fallback
  const authToken = userToken || SUPABASE_KEY;
  const headers = { 'apikey': SUPABASE_KEY, 'Authorization': `Bearer ${authToken}` };
  const url = `${SUPABASE_URL}/rest/v1/techniques?is_active=eq.true&or=(${catFilter})&select=${selectFields}`;

  try {
    const res = await fetch(url, { headers });
    if (!res.ok) return null; // DB 실제 오류 (RLS 차단 등) — null로 구분
    const data = await res.json();
    const all = (data || []).filter(t => t.name_ko);
    // body_regions(배열) 우선, 없으면 body_region(단일) fallback — NULL은 범용 기법으로 통과
    if (bodyRegions.length > 0) {
      return all.filter(t => {
        if (!t.body_region) return true;
        const regions = t.body_regions?.length > 0 ? t.body_regions : [t.body_region];
        return regions.some(r => bodyRegions.includes(r));
      });
    }
    return all;
  } catch {
    return null; // 네트워크 예외 — null로 구분
  }
}

// LLM 호출 + JSON 파싱 헬퍼 (파싱 실패 시 1회 자동 재시도)
async function callLLMAndParse(systemPrompt, userPrompt, apiKey, retryCount = 0) {
  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5',
        max_tokens: 4096,
        system: systemPrompt,
        messages: [{ role: 'user', content: userPrompt }]
      })
    });
    if (!response.ok) {
      const errText = await response.text();
      console.error('Anthropic API 오류:', response.status, errText);
      await logServerError('recommend', `Anthropic API ${response.status}: ${errText.slice(0, 500)}`, {
        http_status: response.status,
        request_path: '/api/recommend',
      });
      return { error: `AI 서비스 오류 (${response.status}): ${errText.slice(0, 300)}`, status: 502 };
    }
    const data = await response.json();
    const rawText = data?.content?.[0]?.text || '';

    // JSON 블록 추출: ```json ... ``` 또는 { ... } 패턴 모두 처리
    const jsonMatch = rawText.match(/```json\s*([\s\S]*?)```/) || rawText.match(/(\{[\s\S]*\})/);
    const jsonStr = jsonMatch ? (jsonMatch[1] || jsonMatch[0]).trim() : null;

    if (!jsonStr) {
      console.error('JSON 추출 실패. 원문:', rawText.slice(0, 200));
      if (retryCount < 1) {
        console.log('[retry] JSON 추출 실패 → 1회 재시도');
        return callLLMAndParse(systemPrompt, userPrompt, apiKey, retryCount + 1);
      }
      await logServerError('recommend', 'LLM JSON 추출 실패 (재시도 소진)', {
        request_path: '/api/recommend',
        context: { rawTextPreview: rawText.slice(0, 200) },
      });
      return { error: 'AI 응답 파싱 오류', status: 502 };
    }
    try {
      return { result: JSON.parse(jsonStr) };
    } catch (parseErr) {
      console.error('JSON.parse 실패:', parseErr.message, '| 원문:', rawText.slice(0, 400));
      if (retryCount < 1) {
        console.log('[retry] JSON.parse 실패 → 1회 재시도');
        return callLLMAndParse(systemPrompt, userPrompt, apiKey, retryCount + 1);
      }
      await logServerError('recommend', `LLM JSON.parse 실패: ${parseErr.message}`, {
        stack: parseErr.stack,
        request_path: '/api/recommend',
        context: { rawTextPreview: rawText.slice(0, 400) },
      });
      return { error: 'AI 응답 파싱 오류', status: 502 };
    }
  } catch (err) {
    console.error('LLM 호출 오류:', err.message);
    await logServerError('recommend', `LLM 호출 오류: ${err.message}`, {
      stack: err.stack,
      request_path: '/api/recommend',
    });
    return { error: '서버 오류: ' + err.message, status: 500 };
  }
}

// 카테고리 일반 원칙(basic_principles) 조회
// category_key를 구/신 두 형태로 모두 인덱싱 (migration 004b가 category_a_ → category_ 로 rename했기 때문)
async function fetchCategoryPrinciples(userToken = null) {
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_KEY) return {};

  const url = `${SUPABASE_URL}/rest/v1/technique_categories?is_active=eq.true` +
    `&select=category_key,name_ko,name_en,basic_principles`;

  const authToken = userToken || SUPABASE_KEY;
  try {
    const res = await fetch(url, {
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${authToken}`
      }
    });
    if (!res.ok) return {};
    const data = await res.json();
    const map = {};
    (data || []).forEach(c => {
      if (!c.category_key || !Array.isArray(c.basic_principles) || c.basic_principles.length === 0) return;
      // 원래 key로 인덱싱
      map[c.category_key] = c;
      // letter prefix 제거 버전도 인덱싱 (category_a_joint_mobilization → category_joint_mobilization)
      const withoutPrefix = c.category_key.replace(/^(category|group)_[a-z]_/, '$1_');
      if (withoutPrefix !== c.category_key) map[withoutPrefix] = c;
      // letter prefix 추가 버전도 인덱싱 (category_joint_mobilization → category_a_joint_mobilization)
      if (c.category_key.match(/^category_(?![a-z]_)/)) {
        map[c.category_key.replace(/^category_/, 'category_a_')] = c;
      }
    });
    return map;
  } catch {
    return {};
  }
}

// 전체 글로벌 스코어링: 모든 MT 기법을 condition score + vector score 혼합으로 정렬
// vectorScoreMap: { [technique_id_uuid]: similarity(0~1) } — 없으면 빈 객체 (룰 기반만 사용)
// 혼합 공식: finalScore = ruleScore * 0.6 + vectorScore * 0.4
// ruleScore 최대값(3)으로 정규화하여 두 점수를 같은 스케일로 맞춤
//
// 다양성 가드:
//   - maxPerGroup: MT 5개 그룹(joint/soft/neuro/special/edu)당 최대 후보 수
//   - maxPerCategory: 카테고리(12종)당 최대 후보 수 — 단일 카테고리 클러스터링 방지
function selectTopTechniquesGlobally(activeMT, acuity, symptom, maxTotal = 6, maxPerGroup = 2, vectorScoreMap = {}, maxPerCategory = null) {
  const conditionScores = (CONDITION_CATEGORY_SCORES[acuity] || {})[symptom] || {};
  const RULE_SCORE_MAX = 3; // CONDITION_CATEGORY_SCORES 최대값

  const scored = activeMT
    .map(t => {
      const ruleScore = conditionScores[t.category] ?? 0;
      const ruleNorm = ruleScore / RULE_SCORE_MAX; // 0~1로 정규화

      const vectorScore = vectorScoreMap[t.id] ?? 0; // similarity 0~1

      const hasVector = Object.keys(vectorScoreMap).length > 0;
      const finalScore = hasVector
        ? ruleNorm * 0.6 + vectorScore * 0.4
        : ruleNorm; // vector 없으면 룰 기반 단독

      return {
        ...t,
        score: finalScore,
        _ruleScore: ruleScore,
        _vectorScore: vectorScore,
        mtGroup: CATEGORY_TO_MT_GROUP[t.category] || '_ungrouped',
      };
    })
    .sort((a, b) => b.score - a.score);

  const groupCounts = {};
  const categoryCounts = {};
  const selected = [];
  for (const t of scored) {
    if (selected.length >= maxTotal) break;
    if ((groupCounts[t.mtGroup] || 0) >= maxPerGroup) continue;
    if (maxPerCategory != null && (categoryCounts[t.category] || 0) >= maxPerCategory) continue;
    selected.push(t);
    groupCounts[t.mtGroup] = (groupCounts[t.mtGroup] || 0) + 1;
    categoryCounts[t.category] = (categoryCounts[t.category] || 0) + 1;
  }
  return selected;
}

// Pillar별 상위 N 후보 추출 — 한국 도수치료 3 박자 모델
// activeMT/activeEX 합집합 → ruleScore + vectorScore → pillar별 그룹화 → 각 pillar에서 top N
// 반환: { joint: [...], soft_tissue: [...], adjunct: [...], exercise: [...] }
function selectTopPerPillar(activeMT, activeEX, acuity, symptom, vectorScoreMap, perPillar = 5) {
  const conditionScores = (CONDITION_CATEGORY_SCORES[acuity] || {})[symptom] || {};
  const RULE_SCORE_MAX = 3;

  const scoreOne = (t) => {
    const ruleScore = conditionScores[t.category] ?? 0;
    const ruleNorm = ruleScore / RULE_SCORE_MAX;
    const vectorScore = vectorScoreMap[t.id] ?? 0;
    const hasVector = Object.keys(vectorScoreMap).length > 0;
    const finalScore = hasVector ? ruleNorm * 0.6 + vectorScore * 0.4 : ruleNorm;
    return { ...t, _ruleScore: ruleScore, _vectorScore: vectorScore, score: finalScore };
  };

  const allScored = [
    ...activeMT.map(scoreOne),
    ...activeEX.map(scoreOne),
  ].sort((a, b) => b.score - a.score);

  const buckets = { joint: [], soft_tissue: [], adjunct: [], exercise: [] };
  for (const t of allScored) {
    const pillar = CATEGORY_TO_PILLAR[t.category];
    if (!pillar) continue;
    if (buckets[pillar].length < perPillar) buckets[pillar].push(t);
  }
  return buckets;
}

// 룰점수 ≥ threshold 인 보조 카테고리(d_neural/pne)가 있는지 확인 — 자동 보조 카드 트리거
function shouldShowAdjunct(acuity, symptom, threshold = 2) {
  const conditionScores = (CONDITION_CATEGORY_SCORES[acuity] || {})[symptom] || {};
  return ADJUNCT_PILLAR.categories.some(cat => (conditionScores[cat] ?? 0) >= threshold);
}

// 카테고리 × region 단위 적용 가능 근육 합집합 — 카드 단위 다부위 노출용
// activeMT: fetchActiveTechniques 결과 (applicable_muscles 포함)
// regions: 필터할 region 배열 (primary regions). 빈 배열이면 region 무제한.
// 반환: [{muscle_ko, muscle_en, ...}] dedupe (muscle_ko 키준)
function aggregateApplicableMuscles(activeMT, category, regions) {
  if (!category) return [];
  const seen = new Map();
  for (const t of activeMT) {
    if (t.category !== category) continue;
    if (regions.length > 0) {
      const tRegions = t.body_regions?.length > 0 ? t.body_regions : (t.body_region ? [t.body_region] : []);
      const matchesRegion = tRegions.length === 0 || tRegions.some(r => regions.includes(r));
      if (!matchesRegion) continue;
    }
    const muscles = Array.isArray(t.applicable_muscles) ? t.applicable_muscles : [];
    for (const m of muscles) {
      if (m?.muscle_ko && !seen.has(m.muscle_ko)) seen.set(m.muscle_ko, m);
    }
  }
  return Array.from(seen.values());
}

// 추천 세션 로깅 (recommendation_logs 테이블, fire-and-forget)
async function logRecommendationSession(userId, userToken, { region, acuity, symptom, selectedCategories, result, latencyMs }) {
  const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
  if (!SUPABASE_KEY || !userId) return;

  const recommended = [
    ...(result.manualTherapy || []).map(t => ({ name: t.technique, category_key: t.categoryInfo?.category_key || null })),
    ...(result.exercise || []).map(t => ({ name: t.technique, category_key: t.categoryInfo?.category_key || null })),
  ];

  await fetch(`${SUPABASE_URL}/rest/v1/recommendation_logs`, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_KEY,
      'Authorization': `Bearer ${userToken}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    },
    body: JSON.stringify({
      user_id: userId,
      region,
      acuity,
      symptom,
      selected_categories: selectedCategories,
      recommended_techniques: recommended,
      latency_ms: Number.isFinite(latencyMs) ? latencyMs : null,
    }),
  });
}

// 기법 객체를 LLM 프롬프트용 텍스트 블록으로 변환
// groupLabel: 사용자 그룹명 (category 필드 대신 표시 — LLM이 category 경계로 그룹을 오해하는 것 방지)
function formatTechniqueForPrompt(t, groupLabel) {
  // 프롬프트 크기 최적화: 처음 3단계만 포함 (LLM이 선택·재작성에 충분한 정보)
  const steps = Array.isArray(t.technique_steps)
    ? t.technique_steps.slice(0, 3).map(s => `    ${s.step}. ${s.instruction}`).join('\n')
    : '';

  return [
    `[${t._promptId}] 【${t.name_ko}】`,
    `  group: ${groupLabel}`,
    `  환자자세: ${t.patient_position || ''}`,
    `  치료사위치: ${t.therapist_position || ''}`,
    `  접촉부위: ${t.contact_point || ''}`,
    `  방향: ${t.direction || ''}`,
    steps ? `  시술단계:\n${steps}` : '',
  ].filter(Boolean).join('\n');
}

export default async function handler(req, res) {
  const t0 = Date.now();
  const startTime = t0; // usage 로깅용 응답시간 측정 시작점

  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // JWT 검증
  const { user, error: authError } = await verifyToken(req);
  if (authError) {
    return res.status(401).json({ error: authError });
  }
  const userToken = (req.headers['authorization'] || '').split(' ')[1] || null;

  // ── 일일 추천 한도 체크 (베타: 하루 20회) ──
  const SUPABASE_URL_RL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
  const SUPABASE_KEY_RL = process.env.SUPABASE_ANON_KEY;
  const DAILY_LIMIT = 20;
  try {
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const rlRes = await fetch(
      `${SUPABASE_URL_RL}/rest/v1/recommendation_logs?user_id=eq.${user.id}&created_at=gte.${todayStart.toISOString()}&select=id`,
      { headers: { apikey: SUPABASE_KEY_RL, Authorization: `Bearer ${userToken || SUPABASE_KEY_RL}` } }
    );
    if (rlRes.ok) {
      const rows = await rlRes.json();
      if (Array.isArray(rows) && rows.length >= DAILY_LIMIT) {
        return res.status(429).json({
          error: `오늘의 추천 한도(${DAILY_LIMIT}회)에 도달했습니다. 내일 다시 이용해주세요.`,
          dailyLimit: DAILY_LIMIT,
          usedToday: rows.length,
        });
      }
    }
  } catch (_) { /* rate-limit 확인 실패 시 추천은 정상 진행 */ }

  const {
    region,
    acuity,
    symptom,
    selectedCategories = [],
    excludedTechniqueIds = [],
    sessionHistory = [],
    focusPillars: rawFocusPillars,
  } = req.body;

  if (!region || !acuity || !symptom) {
    return res.status(400).json({ error: '필수 항목 누락: region, acuity, symptom' });
  }

  // ── focusPillars 정규화 ──
  // 사용자가 [4]단계에서 선택한 도수치료 초점 (한국 3박자 모델: 관절·연부조직·운동)
  // 미지정 시 기본 3 박자 모두 활성. 우선순위는 배열 순서.
  const VALID_PILLARS = ['joint', 'soft_tissue', 'exercise'];
  const focusPillars = Array.isArray(rawFocusPillars) && rawFocusPillars.length > 0
    ? rawFocusPillars.filter(p => VALID_PILLARS.includes(p))
    : ['joint', 'soft_tissue', 'exercise'];

  const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY;
  if (!ANTHROPIC_API_KEY) {
    return res.status(500).json({ error: 'API 키 설정 오류' });
  }

  // selectedCategories → MT/EX 분리
  const EX_CAT_KEYS_SERVER = new Set([
    'category_ex_neuromuscular', 'category_ex_resistance',
    'category_ex_aerobic', 'category_ex_bodyweight',
  ]);
  const mtCategories = selectedCategories.filter(k => !EX_CAT_KEYS_SERVER.has(k));
  const exCategories = selectedCategories.filter(k => EX_CAT_KEYS_SERVER.has(k));

  // ── Anatomy Trains 단독 요청 → 라인 기반 조기 반환 (DB·LLM 불필요) ──
  if (mtCategories.length === 1 && mtCategories[0] === 'category_anatomy_trains' && exCategories.length === 0) {
    const regionKey = ANATOMY_TRAINS_DATA[region] ? region : '요추';
    const allLines = ANATOMY_TRAINS_DATA[regionKey];

    // symptom 기반 우선순위 정렬
    const sorted = [...allLines].sort((a, b) => {
      const sa = a.symptomPriority?.[symptom] ?? 0;
      const sb = b.symptomPriority?.[symptom] ?? 0;
      return sb - sa;
    });

    // excludedTechniqueIds(라인 이름 기반)로 이미 본 라인 제외
    const available = sorted.filter(line => !excludedTechniqueIds.includes(line.name));
    const top3 = available.slice(0, 3);

    // categoryInfo 조회 (📖 원칙 보기용)
    const catMap = await fetchCategoryPrinciples(userToken);
    const catData = catMap['category_anatomy_trains'];
    const categoryInfo = catData
      ? { category_key: 'category_anatomy_trains', name_ko: catData.name_ko || '근막경선 Anatomy Trains', basic_principles: catData.basic_principles || [] }
      : null;

    const atItems = top3.map(line => ({
      techniqueId:     line.name,
      technique:       line.name,
      patientPosition: line.patientPosition,
      therapistHands:  line.therapistHands,
      movement:        line.movement,
      dosage:          '',
      targetMuscles:   line.targetMuscles,
      patientFeedback: line.patientFeedback,
      categoryInfo,
    }));

    const atResponse = {
      manualTherapy: atItems,
      exercise: [],
      clinicalNote: `Anatomy Trains는 치료 관점입니다. ${regionKey} 통증과 관련된 근막경선을 평가한 후, MFR·ART·CTM·심부마찰 등 연부조직 기법으로 해당 라인의 구조물을 치료하세요.`,
      selectedCategories: ['category_anatomy_trains'],
      sessionSummary: { region, acuity, symptom, selectedCategories: ['category_anatomy_trains'] },
    };

    logRecommendationSession(user.id, userToken, {
      region, acuity, symptom, selectedCategories: ['category_anatomy_trains'], result: atResponse,
      latencyMs: Date.now() - t0,
    }).catch(e => console.error('[logging AT]', e.message));

    // fire-and-forget: 세션 단위 usage 로깅
    logSessionUsage({
      userId: user?.id || null,
      region,
      acuity,
      symptom,
      categories: ['category_anatomy_trains'],
      resultCount: atItems.length,
      responseMs: Date.now() - startTime,
    }).catch(err => console.warn('[usage] 로그 실패:', err.message));

    return res.status(200).json(atResponse);
  }

  // region 레이블 → body_region enum 값 변환 (primary: 환부, secondary: 연관 부위)
  const regionConfig = REGION_MAP[region] || { primary: [], secondary: [], label: region };
  const primaryRegions = regionConfig.primary;
  const secondaryRegions = regionConfig.secondary;
  const bodyRegions = [...primaryRegions, ...secondaryRegions];

  // 사용자 입력 텍스트 (증상 설명) 임베딩 — Supabase 조회와 병렬 실행
  const acuityLabel = acuity === '급성' ? '급성기' : acuity === '아급성' ? '아급성기' : '만성';
  const queryText = `${region} ${acuityLabel} 환자. 주소증: ${symptom}. 수기치료 적응증 검색.`;
  const [queryEmbedding] = await Promise.all([getQueryEmbedding(queryText)]);

  // Supabase에서 is_active=true 테크닉 + 카테고리 원칙 + vector 유사도 병렬 조회
  let activeMT = [], activeEX = [], categoryPrinciplesMap = {}, vectorScoreMap = {};
  try {
    const fetches = [
      fetchActiveTechniques(mtCategories, bodyRegions, userToken),
      fetchCategoryPrinciples(userToken),
      fetchVectorSimilarities(queryEmbedding, userToken),
    ];
    if (exCategories.length > 0) fetches.push(fetchActiveTechniques(exCategories, bodyRegions, userToken));
    const results = await Promise.all(fetches);
    activeMT = results[0]; // null = DB 오류, [] = 정상 조회 결과 없음
    categoryPrinciplesMap = results[1];

    // vector 결과를 { [id]: similarity } 맵으로 변환
    const vectorRows = results[2] || [];
    vectorScoreMap = Object.fromEntries(vectorRows.map(r => [r.id, r.similarity]));

    activeEX = results[3] || [];

    // activeMT null(DB 오류) 조기 반환
    if (activeMT === null) {
      return res.status(503).json({
        error: `기법 데이터를 불러오지 못했습니다. (DB 조회 실패 — 계정 승인 여부를 확인하세요. mtCategories: ${JSON.stringify(mtCategories)})`
      });
    }

    // excludedTechniqueIds(abbreviation 기준)로 이미 본 기법 제외
    if (excludedTechniqueIds.length > 0) {
      activeMT = activeMT.filter(t => !excludedTechniqueIds.includes(t.abbreviation));
      activeEX = (activeEX || []).filter(t => !excludedTechniqueIds.includes(t.abbreviation));
    }

    // target_tags hard filter: 해당 acuity 없는 기법 제외 (MT + EX 모두 적용)
    const acuityTagMap = { '급성': 'acute', '아급성': 'subacute', '만성': 'chronic' };
    const requiredTag = acuityTagMap[acuity];
    if (requiredTag) {
      const acuityFilter = t =>
        !Array.isArray(t.target_tags) ||
        t.target_tags.length === 0 ||
        t.target_tags.includes(requiredTag);
      activeMT = activeMT.filter(acuityFilter);
      activeEX = (activeEX || []).filter(acuityFilter);
    }
  } catch (e) {
    console.error('[DEBUG] Supabase fetch error:', e);
    await logServerError('recommend', `Supabase fetch error: ${e.message}`, {
      stack: e.stack,
      request_path: '/api/recommend',
      user_id: user?.id ?? null,
      context: { region, acuity, symptom, mtCategories, exCategories },
    });
  }

  // 빈 결과는 오류가 아님 — LLM이 "해당 조건 없음" 안내를 생성하도록 흘려보냄
  // (activeMT === null인 DB 오류는 위에서 이미 503 반환 완료)

  // MT 기법에 고유 인덱스 ID 부여
  const indexedTechniques = new Map(); // 'MT-001' → technique object
  let counter = 1;
  activeMT.forEach(t => {
    const id = `MT-${String(counter++).padStart(3, '0')}`;
    t._promptId = id;
    indexedTechniques.set(id, t);
  });

  // EX 기법에 고유 인덱스 ID 부여
  const indexedExercises = new Map(); // 'EX-001' → technique object
  let exCounter = 1;
  activeEX.forEach(t => {
    const id = `EX-${String(exCounter++).padStart(3, '0')}`;
    t._promptId = id;
    indexedExercises.set(id, t);
  });

  // 알고리즘: 전체 글로벌 스코어링 → 상위 6개 후보 → Claude가 3개 선택
  // topMT를 블록 밖에 선언: LLM 프롬프트용 후보 목록 구성
  let topMT = [];
  let allowedMTText;
  if (activeMT.length > 0) {
    // 다양성 강제: 그룹당 최대 2 + 카테고리당 최대 1 → 6개 후보가 모두 다른 카테고리에서 추출됨
    // → LLM 최종 선택 3개도 자동으로 3개 다른 카테고리(모달리티) 보장
    topMT = selectTopTechniquesGlobally(activeMT, acuity, symptom, 6, 2, vectorScoreMap, 1);
    const allSelectedMT = topMT.map(t =>
      formatTechniqueForPrompt(t, MT_GROUP_LABEL[CATEGORY_TO_MT_GROUP[t.category]] || '기타')
    );
    allowedMTText = `Manual Therapy 후보 기법 (condition score 상위 6개. 이 중 이 환자에게 가장 적합한 3개를 임상적 우선순위 순으로 선택하세요):\n\n` +
      allSelectedMT.join('\n\n');
  } else {
    allowedMTText = '';
  }

  // 운동 처방 허용 목록 텍스트 (상위 4개 후보 → Claude 2개 선택)
  const topEX = activeEX.slice(0, 4);
  const allowedEXText = topEX.length > 0
    ? `\n\n=== 운동 처방 후보 (상위 4개. 환자 상태에 맞춰 2개 선택) ===\n\n` +
      topEX.map(t => formatTechniqueForPrompt(t, '운동처방')).join('\n\n')
    : '';

  // 세션 히스토리 요약 (중복 추천 방지)
  const historyText = sessionHistory.length > 0
    ? `\n\n이전 세션 기록 (중복 추천 피할 것):\n${sessionHistory.map((h, i) => `${i+1}. ${JSON.stringify(h)}`).join('\n')}`
    : '';

  const systemPrompt = `당신은 근거기반 임상 물리치료사 멘토입니다.
반-카타스트로파이징(anti-catastrophizing) 접근을 강조합니다.
핵심 원칙: "통증 ≠ 손상", "몸은 적응적이다", "Calm things down, then build things back up"
자세 불균형·정렬 이상 프레임 사용 금지. 공포 유발 표현 금지.
clinicalNote 작성 원칙: 원인을 단정하지 말고 가능성으로 표현하세요. 단정 표현(~입니다, ~때문입니다)은 옐로우 플래그를 만들 수 있습니다.
  ✗ "요추 불안정성으로 인한 통증입니다" / "디스크 문제로 발생한 증상입니다"
  ✓ "요추 주변 근육의 협응이 통증에 기여하고 있을 수 있습니다" / "신경 민감화가 관여했을 가능성이 있습니다"
  가능성 표현 예시: ~일 수 있습니다, ~가능성이 있습니다, ~기여할 수 있습니다, ~관련이 있을 수 있습니다
⚠️ 중요: 아래 허용 목록에 있는 기법만 선택하여 우선순위 순으로 나열하세요. 목록에 없는 기법 생성 절대 금지.
응답은 반드시 순수 JSON만 출력하세요. 마크다운 금지.

언어 원칙 (반드시 준수):
1. 자세·동작 설명은 초보 치료사도 바로 이해하는 쉬운 한국어 사용. 한자어·의학 약어 금지.
   ✗ 앙와위, 양와위, 측와위, 복와위, 반좌위, 복위, 전굴, 후굴, 측굴, 촉진, 신연, 거상, 표재층, 신전, 미측 방향, 두측 방향
   ✓ 등 대고 눕기(앙와위→), 옆으로 눕기(측와위→), 엎드려 눕기(복와위→), 등받이 세워 앉기, 앞으로 굽히기, 뒤로 젖히기, 옆으로 기울이기, 손으로 부드럽게 누르기, 팔 들어올리기, 피부 가까운 얕은 층(표재층→), 펴기(신전→), 발 쪽 방향(미측→), 머리 쪽 방향(두측→)
2. 신체 부위명과 해부학 구조물은 반드시 "한국어(영어)" 형식으로 작성.
   - 신체 부위: 경추(cervical spine), 흉추(thoracic spine), 요추(lumbar spine), 천장관절(sacroiliac joint), 어깨 관절(shoulder), 무릎 관절(knee), 엉덩 관절(hip), 발목 관절(ankle)
   - 해부학 구조물: 척추기립근(erector spinae), 다열근(multifidus), 후두하근(suboccipital muscles), 요방형근(quadratus lumborum)
   - technique 필드(기법명)에도 신체 부위는 반드시 영어 병기. 예: "경추(cervical spine) 중앙 PA 가동술"
3. movement 필드는 "1. [동작] 2. [동작] 3. [동작]" 3단계 번호 형식으로 작성. 각 단계 15자 이내.
   예: "1. 양손을 극돌기에 올리기 2. 아래로 압력 5초 유지 3. 서서히 압력 제거"
4. MT 기법: DB 정보(환자자세·치료사위치·접촉부위·방향·시술단계)를 기반으로 재작성.
   - patientPosition: DB 환자자세 → 쉬운 한국어 (15자 이내)
   - therapistHands: DB "치료사위치 + 접촉부위" 결합 (15자 이내)
5. 운동 처방 기법: DB 정보(환자자세·방향·시술단계)를 기반으로 재작성.
   - patientPosition: 운동 시작 자세 → 쉬운 한국어 (15자 이내). Rule 1 금지 용어 동일 적용 (앙와위→등 대고 눕기, 측와위→옆으로 눕기, 복와위→엎드려 눕기, 신전→쭉 펴기, 미측→발 쪽, 두측→머리 쪽 등)
   - therapistHands: 세트/횟수 또는 핵심 포인트 (15자 이내)
   - movement: 동작 설명에도 Rule 1 금지 용어 적용. 한자어·의학 약어 금지.
6. dosage: technique_steps에서 핵심 용량 정보 추출 (20자 이내).
   - Grade 기반(Maitland 등): "Grade I–II / 30–60회"
   - 시간 기반: "90–120초" 또는 "5분"
   - 세트/횟수 기반: "10회 × 3세트"
   - 정보 없으면 "" 반환
7. DB 정보가 없는 기법은 선택하지 마세요.
8. 각 기법의 ID를 techniqueId 필드에 정확히 복사하세요. 절대 변형 금지.
   MT 기법: [MT-007] → "techniqueId": "MT-007" / EX 기법: [EX-003] → "techniqueId": "EX-003"`;

  // exercise 스키마는 운동 처방 데이터가 있을 때만 포함
  const exerciseSchema = allowedEXText
    ? `,\n  "exercise": [\n    {\n      "techniqueId": "EX-001",\n      "technique": "운동명 (10자)",\n      "patientPosition": "시작 자세 (15자)",\n      "therapistHands": "세트/횟수 (15자)",\n      "movement": "1. [단계] 2. [단계] 3. [단계]",\n      "dosage": "10회 × 3세트",\n      "targetMuscles": ["한국어(영어)", "한국어(영어)"],\n      "patientFeedback": "핵심 반응·주의 (15자)"\n    }\n  ]`
    : '';

  const userPrompt = `환자 정보:
- 부위: ${region}
- 시기: ${acuity}
- 증상 패턴: ${symptom}

${allowedMTText}${allowedEXText}
${historyText}

환자 정보(부위: ${region}, 시기: ${acuity}, 증상: ${symptom})에 맞게:
${topMT.length > 0 ? `▸ MT: 후보 6개 중 이 환자(부위: ${region}, 시기: ${acuity}, 증상: ${symptom})에게 가장 적합한 3개를 임상적 우선순위 순서로 선택하여 DB 정보를 쉬운 한국어로 재작성. 동일 카테고리 중복 선택 금지 — 서로 다른 모달리티로 다층 접근 구성.` : ''}
${topEX.length > 0 ? '▸ 운동: 환자 상태를 고려하여 2개 선택' : ''}
DB 정보를 쉬운 한국어로 재작성하여 아래 형식으로만 반환하세요. 목록에 없는 기법 생성 금지.

반환 형식 (JSON 외 출력 금지):
{
  "manualTherapy": [
    {
      "techniqueId": "MT-001",
      "technique": "기법명 (10자 이내)",
      "patientPosition": "자세 (15자 이내, 의학 약어 금지)",
      "therapistHands": "손 위치와 방법 (15자 이내)",
      "movement": "1. [단계] 2. [단계] 3. [단계] 번호 형식 필수",
      "dosage": "Grade I–II / 30회",
      "targetMuscles": ["한국어(영어)", "한국어(영어)"],
      "patientFeedback": "핵심 반응·주의 (15자 이내)"
    }
  ]${exerciseSchema},
  "clinicalNote": "기법 선택 근거 + 환자 메시지 (가능성 표현, 80자 이내)"
}
${topMT.length > 0 ? 'MT: 후보 중 3개 선택 (우선순위 순)' : ''}${topMT.length > 0 && topEX.length > 0 ? ' / ' : ''}${topEX.length > 0 ? '운동처방: 2개' : ''} / targetMuscles: 최대 2개
techniqueId는 [MT-XXX] 또는 [EX-XXX] ID를 그대로 복사.`;

  // 1차 LLM 호출
  const { result: firstResult, error: llmErr, status: llmStatus } =
    await callLLMAndParse(systemPrompt, userPrompt, ANTHROPIC_API_KEY);

  if (llmErr) return res.status(llmStatus).json({ error: llmErr });

  let result = firstResult;

  // 아급성에서 MT 추천이 비어 있으면 급성으로 fallback 재시도
  if (acuity === '아급성' && (result.manualTherapy || []).length === 0) {
    console.log('[fallback] 아급성 MT 결과 없음 → 급성으로 재시도');
    const fallbackPrompt = userPrompt.replace(/아급성/g, '급성');
    const { result: fbResult } = await callLLMAndParse(systemPrompt, fallbackPrompt, ANTHROPIC_API_KEY);
    if (fbResult && (fbResult.manualTherapy || []).length > 0) {
      result = fbResult;
      result._usedFallbackAcuity = '급성';
    }
  }

  try {
    // techniqueId(인덱스 ID)로 기법 lookup → category 확보 → categoryInfo + abbreviation + isPrimary 부착
    // 추가: 모달리티 카드 단위로 카테고리×region에 적용 가능 근육 합집합(applicableMuscles) 부착
    (result.manualTherapy || []).forEach(item => {
      const t = indexedTechniques.get(item.techniqueId);
      const catKey = t ? t.category : null;
      const catData = catKey ? categoryPrinciplesMap[catKey] : null;
      if (catData) {
        item.categoryInfo = {
          category_key: catKey,
          name_ko: catData.name_ko,
          name_en: catData.name_en,
          basic_principles: catData.basic_principles || [],
        };
      }
      // techniqueId를 DB abbreviation으로 교체 (프론트에서 excludedTechniqueIds로 사용)
      if (t?.abbreviation) item.techniqueId = t.abbreviation;
      // Option B: 환부(primary) vs 연관 부위(secondary) 구분
      const tRegions = t?.body_regions?.length > 0 ? t.body_regions : (t?.body_region ? [t.body_region] : []);
      item.isPrimary = tRegions.length === 0 || tRegions.some(r => primaryRegions.includes(r));
      // 모달리티 카드 다부위 노출: 같은 카테고리 × primary regions의 applicable_muscles 합집합
      if (catKey) {
        item.applicableMuscles = aggregateApplicableMuscles(activeMT, catKey, primaryRegions);
      } else {
        item.applicableMuscles = [];
      }
    });

    // exercise categoryInfo + abbreviation 부착 (EX 인덱스 ID로 lookup)
    (result.exercise || []).forEach(item => {
      const t = indexedExercises.get(item.techniqueId);
      const catKey = t ? t.category : 'category_exercise01';
      const catData = categoryPrinciplesMap[catKey];
      if (catData) {
        item.categoryInfo = {
          category_key: catKey,
          name_ko: catData.name_ko,
          name_en: catData.name_en,
          basic_principles: catData.basic_principles || [],
        };
      }
      if (t?.abbreviation) item.techniqueId = t.abbreviation;
    });

    // primary/secondary 분리 (Option B)
    const primaryMTItems   = (result.manualTherapy || []).filter(i => i.isPrimary !== false);
    const relatedMTItems   = (result.manualTherapy || []).filter(i => i.isPrimary === false);
    result.manualTherapy   = primaryMTItems;
    if (relatedMTItems.length > 0) result.relatedManualTherapy = relatedMTItems;

    // ── recommendations[] 빌드 — 한국 도수치료 3박자 모델 (관절·연부조직·운동) ──
    // 사용자 focusPillars 우선순위 순서로 카드 구성. 각 카드 = primary(LLM 재작성) + related(DB 직접).
    // 보조(adjunct: d_neural/pne)는 LLM이 선택했거나 룰점수 ≥ 2일 때 자동 추가.
    const pillarBuckets = selectTopPerPillar(activeMT, activeEX, acuity, symptom, vectorScoreMap, 5);

    const buildRelatedFor = (pillarKey, primaryAbbr) => {
      const candidates = pillarBuckets[pillarKey] || [];
      return candidates
        .filter(t => t.abbreviation !== primaryAbbr)
        .slice(0, 4)
        .map(t => {
          const catData = categoryPrinciplesMap[t.category];
          return {
            techniqueId: t.abbreviation,
            name_ko: t.name_ko,
            applicableMuscles: aggregateApplicableMuscles(
              [...activeMT, ...activeEX], t.category, primaryRegions
            ),
            categoryInfo: catData ? {
              category_key: t.category,
              name_ko: catData.name_ko,
              name_en: catData.name_en,
              basic_principles: catData.basic_principles || [],
            } : null,
            _score: Math.round((t.score || 0) * 1000) / 1000,
          };
        });
    };

    const itemPillarOf = (item) =>
      CATEGORY_TO_PILLAR[item.categoryInfo?.category_key] || null;

    const allItems = [
      ...(primaryMTItems || []).map(i => ({ ...i, _source: 'mt' })),
      ...(result.exercise || []).map(i => ({ ...i, _source: 'ex' })),
    ];

    const recommendations = [];
    let rank = 1;

    // (1) 사용자 선택 pillar 순서대로 카드 빌드
    for (const pillarKey of focusPillars) {
      const pillarDef = ALL_PILLARS[pillarKey];
      if (!pillarDef) continue;
      const primary = allItems.find(i => itemPillarOf(i) === pillarKey);
      if (!primary) continue; // pillar 후보 부재 — 카드 생략 (강제 채우기 X)
      const { _source, ...primaryClean } = primary;
      recommendations.push({
        pillar: pillarKey,
        pillarLabel: pillarDef.label,
        pillarLabel_en: pillarDef.label_en,
        rank: rank++,
        primary: primaryClean,
        related: buildRelatedFor(pillarKey, primary.techniqueId),
      });
    }

    // (2) 보조(adjunct) — LLM이 선택했거나 룰점수 ≥ 2인 경우 자동 추가
    const adjunctInLLMOutput = allItems.find(i => itemPillarOf(i) === 'adjunct');
    if (adjunctInLLMOutput) {
      const { _source, ...primaryClean } = adjunctInLLMOutput;
      recommendations.push({
        pillar: 'adjunct',
        pillarLabel: ADJUNCT_PILLAR.label,
        pillarLabel_en: ADJUNCT_PILLAR.label_en,
        rank: rank++,
        auto: false,
        primary: primaryClean,
        related: buildRelatedFor('adjunct', adjunctInLLMOutput.techniqueId),
      });
    } else if (shouldShowAdjunct(acuity, symptom, 2)) {
      // LLM이 선택 안 했지만 룰점수가 강하면 DB 후보 1개를 PRIMARY로 (LLM 재작성 X — 정보만)
      const adjunctTop = (pillarBuckets.adjunct || [])[0];
      if (adjunctTop) {
        const catData = categoryPrinciplesMap[adjunctTop.category];
        recommendations.push({
          pillar: 'adjunct',
          pillarLabel: ADJUNCT_PILLAR.label,
          pillarLabel_en: ADJUNCT_PILLAR.label_en,
          rank: rank++,
          auto: true,
          primary: {
            techniqueId: adjunctTop.abbreviation,
            technique: adjunctTop.name_ko,
            applicableMuscles: aggregateApplicableMuscles(
              [...activeMT, ...activeEX], adjunctTop.category, primaryRegions
            ),
            categoryInfo: catData ? {
              category_key: adjunctTop.category,
              name_ko: catData.name_ko,
              name_en: catData.name_en,
              basic_principles: catData.basic_principles || [],
            } : null,
          },
          related: buildRelatedFor('adjunct', adjunctTop.abbreviation),
        });
      }
    }

    result.recommendations = recommendations;

    result.selectedCategories = selectedCategories;

    result.sessionSummary = {
      region,
      acuity,
      symptom,
      selectedCategories,
      focusPillars,
    };

    logRecommendationSession(user.id, userToken, {
      region, acuity, symptom, selectedCategories, result,
      latencyMs: Date.now() - t0,
    }).catch(e => console.error('[logging]', e.message));

    // fire-and-forget: 세션 단위 usage 로깅
    logSessionUsage({
      userId: user?.id || null,
      region,
      acuity,
      symptom,
      categories: selectedCategories,
      resultCount: (result.manualTherapy?.length || 0) + (result.exercise?.length || 0),
      responseMs: Date.now() - startTime,
    }).catch(err => console.warn('[usage] 로그 실패:', err.message));

    return res.status(200).json(result);

  } catch (err) {
    console.error('후처리 오류:', err);
    await logServerError('recommend', `후처리 오류: ${err.message}`, {
      stack: err.stack,
      request_path: '/api/recommend',
      user_id: user?.id ?? null,
      context: { region, acuity, symptom },
    });
    return res.status(500).json({ error: '서버 오류: ' + err.message });
  }
}
