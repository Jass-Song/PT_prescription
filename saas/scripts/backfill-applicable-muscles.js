#!/usr/bin/env node
// backfill-applicable-muscles.js
// techniques.applicable_muscles JSONB 컬럼 1차 백필 스크립트
//
// 동작:
//   1. Supabase에서 is_active=true 기법 전체 조회 (id, abbreviation, name_ko, category, body_region)
//   2. 카테고리별 정책 + 한국어→영어 근육 사전으로 applicable_muscles 산출
//   3. --apply 미지정 시: dry-run으로 045-backfill-FULL.sql 파일 생성 + 미해결 행 리스트
//      --apply 지정 시:  Supabase에 직접 UPDATE
//
// 실행:
//   VOYAGE-style 동일 환경변수 사용 (SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY)
//   node -r dotenv/config saas/scripts/backfill-applicable-muscles.js          # dry-run (SQL 파일 생성)
//   node -r dotenv/config saas/scripts/backfill-applicable-muscles.js --apply  # 직접 적용
//   node saas/scripts/backfill-applicable-muscles.js --apply --only-empty      # 빈 행만 갱신

import { createClient } from '@supabase/supabase-js';
import { writeFileSync } from 'node:fs';

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!SUPABASE_SERVICE_ROLE_KEY) {
  console.error('❌ SUPABASE_SERVICE_ROLE_KEY 환경변수가 없습니다.');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

// ── 카테고리 정책 ──
// muscle-targeted: 근육 표적 — 정밀 매칭 시도
// non-muscle:      관절·움직임·교육·신경 — applicable_muscles = [] 로 명시 처리
const MUSCLE_TARGETED_CATEGORIES = new Set([
  'category_art',
  'category_mfr',
  'category_ctm',
  'category_trigger_point',
  'category_deep_friction',
  'category_scs', // counterstrain — 압통점이라 근육 동반
]);

const NON_MUSCLE_CATEGORIES = new Set([
  'category_joint_mobilization',
  'category_mulligan',
  'category_mdt',
  'category_pne',
  'category_d_neural',
  'category_anatomy_trains', // AT는 별도 처리 (recommend.js의 ANATOMY_TRAINS_DATA)
  // 운동 카테고리는 근육 표적이지만 본 백필 범위 외
  'category_ex_resistance',
  'category_ex_bodyweight',
  'category_ex_neuromuscular',
  'category_ex_aerobic',
]);

// ── 한국어→영어 근육·구조 사전 ──
// name_ko에 substring으로 등장하는 패턴을 매칭. 우선순위 긴 패턴 먼저.
// (긴 패턴이 짧은 패턴을 포함하는 경우 긴 것 먼저 매칭)
const MUSCLE_DICT = [
  // 경추·상부
  { ko: '상부 승모근',     en: 'upper trapezius' },
  { ko: '중부 승모근',     en: 'middle trapezius' },
  { ko: '하부 승모근',     en: 'lower trapezius' },
  { ko: '승모근',          en: 'trapezius' },
  { ko: '흉쇄유돌근',      en: 'sternocleidomastoid' },
  { ko: 'SCM',             en: 'sternocleidomastoid' },
  { ko: '사각근',          en: 'scalenes' },
  { ko: '후두하 근육군',   en: 'suboccipital muscles' },
  { ko: '후두하근',        en: 'suboccipital muscles' },
  { ko: '후두하',          en: 'suboccipital muscles' },
  { ko: '견갑거근',        en: 'levator scapulae' },
  { ko: '두판상근',        en: 'splenius capitis' },
  { ko: '경판상근',        en: 'splenius cervicis' },
  { ko: '판상근',          en: 'splenius' },
  { ko: '능형근',          en: 'rhomboids' },
  { ko: '마름근',          en: 'rhomboids' },
  { ko: '전거근',          en: 'serratus anterior' },

  // 흉부·요추
  { ko: '척추세움근',      en: 'erector spinae' },
  { ko: '척추기립근',      en: 'erector spinae' },
  { ko: '장요근',          en: 'iliopsoas' },
  { ko: '요방형근',        en: 'quadratus lumborum' },
  { ko: '흉요근막',        en: 'thoracolumbar fascia' },
  { ko: '광배근',          en: 'latissimus dorsi' },
  { ko: '횡격막',          en: 'diaphragm' },
  { ko: '복횡근',          en: 'transversus abdominis' },
  { ko: '외복사근',        en: 'external oblique' },
  { ko: '내복사근',        en: 'internal oblique' },

  // 어깨·팔
  { ko: '회전근개',        en: 'rotator cuff' },
  { ko: '극상근',          en: 'supraspinatus' },
  { ko: '극하근',          en: 'infraspinatus' },
  { ko: '소원근',          en: 'teres minor' },
  { ko: '대원근',          en: 'teres major' },
  { ko: '견갑하근',        en: 'subscapularis' },
  { ko: '대흉근',          en: 'pectoralis major' },
  { ko: '소흉근',          en: 'pectoralis minor' },
  { ko: '삼각근',          en: 'deltoid' },
  { ko: '이두근',          en: 'biceps brachii' },
  { ko: '삼두근',          en: 'triceps brachii' },
  { ko: '오훼완근',        en: 'coracobrachialis' },
  { ko: '전완굴근',        en: 'forearm flexors' },
  { ko: '전완신근',        en: 'forearm extensors' },
  { ko: '손목굴근',        en: 'wrist flexors' },
  { ko: '손목신근',        en: 'wrist extensors' },

  // 골반·고관절
  { ko: '대둔근',          en: 'gluteus maximus' },
  { ko: '중둔근',          en: 'gluteus medius' },
  { ko: '소둔근',          en: 'gluteus minimus' },
  { ko: '이상근',          en: 'piriformis' },
  { ko: '대퇴근막장근',    en: 'tensor fasciae latae' },
  { ko: 'TFL',             en: 'tensor fasciae latae' },
  { ko: '내전근군',        en: 'adductors' },
  { ko: '내전근',          en: 'adductors' },
  { ko: '치골근',          en: 'pectineus' },
  { ko: '대퇴직근',        en: 'rectus femoris' },
  { ko: '봉공근',          en: 'sartorius' },
  { ko: '골반저근',        en: 'pelvic floor' },

  // 무릎·하퇴
  { ko: '슬굴곡근',        en: 'hamstrings' },
  { ko: '햄스트링',        en: 'hamstrings' },
  { ko: '대퇴이두근',      en: 'biceps femoris' },
  { ko: '반건양근',        en: 'semitendinosus' },
  { ko: '반막양근',        en: 'semimembranosus' },
  { ko: '대퇴사두근',      en: 'quadriceps' },
  { ko: '외측광근',        en: 'vastus lateralis' },
  { ko: '내측광근',        en: 'vastus medialis' },
  { ko: '중간광근',        en: 'vastus intermedius' },
  { ko: '슬와근',          en: 'popliteus' },
  { ko: '장경인대',        en: 'iliotibial band' },
  { ko: '장경밴드',        en: 'iliotibial band' },
  { ko: 'IT 밴드',         en: 'iliotibial band' },

  // 발목·발
  { ko: '비복근',          en: 'gastrocnemius' },
  { ko: '가자미근',        en: 'soleus' },
  { ko: '아킬레스건',      en: 'Achilles tendon' },
  { ko: '족저근막',        en: 'plantar fascia' },
  { ko: '비골근',          en: 'peroneals' },
  { ko: '장비골근',        en: 'peroneus longus' },
  { ko: '단비골근',        en: 'peroneus brevis' },
  { ko: '후경골근',        en: 'tibialis posterior' },
  { ko: '전경골근',        en: 'tibialis anterior' },
  { ko: '장지굴근',        en: 'flexor digitorum longus' },
  { ko: '장모지굴근',      en: 'flexor hallucis longus' },
  { ko: '족저 내재근',     en: 'plantar intrinsic muscles' },

  // 척추·기타
  { ko: '심부 척추 안정화 근육', en: 'deep spinal stabilizers' },
  { ko: '다열근',          en: 'multifidus' },
  { ko: '회전근',          en: 'rotatores' },
];

// 사전 매칭 — name_ko에 등장하는 모든 근육 패턴 추출 (긴 패턴 우선)
const SORTED_DICT = [...MUSCLE_DICT].sort((a, b) => b.ko.length - a.ko.length);

function extractMuscles(nameKo) {
  if (!nameKo) return [];
  const text = nameKo;
  const found = [];
  const consumed = new Array(text.length).fill(false);

  for (const entry of SORTED_DICT) {
    let idx = 0;
    while ((idx = text.indexOf(entry.ko, idx)) !== -1) {
      // 이미 더 긴 패턴이 차지한 영역인지 확인
      const overlap = consumed.slice(idx, idx + entry.ko.length).some(Boolean);
      if (!overlap) {
        for (let i = idx; i < idx + entry.ko.length; i++) consumed[i] = true;
        if (!found.find(f => f.muscle_ko === entry.ko)) {
          found.push({ muscle_ko: entry.ko, muscle_en: entry.en });
        }
      }
      idx += entry.ko.length;
    }
  }
  return found;
}

// ── SQL 이스케이프 ──
function jsonbLiteral(arr) {
  return `'${JSON.stringify(arr).replace(/'/g, "''")}'::jsonb`;
}

// ── 메인 ──
async function main() {
  const apply = process.argv.includes('--apply');
  const onlyEmpty = process.argv.includes('--only-empty');

  console.log(`📦 Supabase에서 is_active=true 기법 전체 조회 중...`);
  const { data: techniques, error } = await supabase
    .from('techniques')
    .select('id, abbreviation, name_ko, category, body_region, applicable_muscles')
    .eq('is_active', true);

  if (error) {
    console.error('❌ 조회 실패:', error.message);
    process.exit(1);
  }
  console.log(`✅ ${techniques.length}개 로드됨`);

  const results = {
    nonMuscleTargeted: [],     // applicable_muscles = [] 로 처리
    matched: [],                // 사전 매칭 성공
    unresolved: [],             // muscle-targeted인데 매칭 실패 (수동 처리 대상)
    skippedExistingNonEmpty: [], // 이미 채워진 행 (--only-empty 시)
    skippedUnknownCategory: [],  // MUSCLE_TARGETED/NON_MUSCLE 어디에도 없는 카테고리
  };

  const updates = []; // { id, applicable_muscles }

  for (const t of techniques) {
    const cat = t.category;
    const isExistingFilled = Array.isArray(t.applicable_muscles) && t.applicable_muscles.length > 0;

    if (onlyEmpty && isExistingFilled) {
      results.skippedExistingNonEmpty.push(t);
      continue;
    }

    if (NON_MUSCLE_CATEGORIES.has(cat)) {
      results.nonMuscleTargeted.push(t);
      // 명시적 빈 배열 강제 — 기존에 잘못 채워진 경우 청소
      if (isExistingFilled) {
        updates.push({ id: t.id, applicable_muscles: [] });
      }
      continue;
    }

    if (!MUSCLE_TARGETED_CATEGORIES.has(cat)) {
      results.skippedUnknownCategory.push(t);
      continue;
    }

    // muscle-targeted — 사전 매칭 시도
    const muscles = extractMuscles(t.name_ko);
    if (muscles.length === 0) {
      results.unresolved.push(t);
      continue;
    }
    results.matched.push({ ...t, _extracted: muscles });
    updates.push({ id: t.id, applicable_muscles: muscles });
  }

  // ── 리포트 ──
  console.log('');
  console.log('=== 백필 결과 ===');
  console.log(`✅ 매칭 성공:           ${results.matched.length}`);
  console.log(`✅ 비-근육 카테고리:    ${results.nonMuscleTargeted.length} (applicable_muscles=[])`);
  console.log(`⚠️  미해결 (수동 필요): ${results.unresolved.length}`);
  console.log(`⏭️  건너뜀(이미 채움):  ${results.skippedExistingNonEmpty.length}`);
  console.log(`❓ 알 수 없는 카테고리: ${results.skippedUnknownCategory.length}`);
  console.log(`📝 UPDATE 대상:         ${updates.length}`);

  if (results.unresolved.length > 0) {
    console.log('\n⚠️  미해결 기법 (사전에 매칭되는 근육 substring 없음):');
    results.unresolved.forEach(t => {
      console.log(`  - [${t.abbreviation}] ${t.name_ko} (cat=${t.category}, region=${t.body_region})`);
    });
  }

  if (results.skippedUnknownCategory.length > 0) {
    console.log('\n❓ 정책 미정 카테고리:');
    results.skippedUnknownCategory.forEach(t => {
      console.log(`  - [${t.abbreviation}] cat=${t.category}`);
    });
  }

  // ── 출력 또는 적용 ──
  if (apply) {
    console.log('\n🚀 Supabase에 직접 적용 중...');
    let success = 0, fail = 0;
    for (const u of updates) {
      const { error: updErr } = await supabase
        .from('techniques')
        .update({ applicable_muscles: u.applicable_muscles })
        .eq('id', u.id);
      if (updErr) { console.error(`❌ ${u.id}: ${updErr.message}`); fail++; }
      else success++;
    }
    console.log(`✅ 적용 완료: ${success}개 성공, ${fail}개 실패`);
  } else {
    // SQL 파일 생성
    const sqlLines = [
      '-- ============================================================',
      '-- 045-FULL-backfill-applicable-muscles.sql (자동 생성)',
      `-- 생성 시각: ${new Date().toISOString()}`,
      `-- 매칭: ${results.matched.length} / 비-근육: ${results.nonMuscleTargeted.length} / 미해결: ${results.unresolved.length}`,
      '-- 실행 전 검토 필수. 미해결 기법은 별도 수동 UPDATE 필요.',
      '-- ============================================================',
      '',
      'BEGIN;',
      '',
    ];
    for (const u of updates) {
      const matched = results.matched.find(r => r.id === u.id);
      const label = matched ? `${matched.abbreviation} ${matched.name_ko}` : '[비-근육 정리]';
      sqlLines.push(`-- ${label}`);
      sqlLines.push(`UPDATE techniques SET applicable_muscles = ${jsonbLiteral(u.applicable_muscles)} WHERE id = '${u.id}';`);
    }
    sqlLines.push('', 'COMMIT;', '');

    if (results.unresolved.length > 0) {
      sqlLines.push('-- ── 미해결 기법 (수동 처리 필요) ──');
      results.unresolved.forEach(t => {
        sqlLines.push(`-- TODO [${t.abbreviation}] ${t.name_ko} (cat=${t.category}, region=${t.body_region})`);
        sqlLines.push(`-- UPDATE techniques SET applicable_muscles = '[{"muscle_ko":"...","muscle_en":"..."}]'::jsonb WHERE id = '${t.id}';`);
      });
    }

    const outPath = 'saas/migrations/045-FULL-generated.sql';
    writeFileSync(outPath, sqlLines.join('\n'), 'utf8');
    console.log(`\n📄 SQL 파일 생성: ${outPath}`);
    console.log('   → 검토 후 Supabase SQL Editor에서 실행하세요.');
    console.log('   → 직접 적용하려면 --apply 플래그 추가.');
  }
}

main().catch(err => {
  console.error('❌ 예상치 못한 오류:', err);
  process.exit(1);
});
