#!/usr/bin/env node
// embed-techniques.js — Voyage AI 임베딩 생성 후 Supabase technique_embeddings에 저장
//
// 실행 방법:
//   VOYAGE_API_KEY=<key> SUPABASE_URL=<url> SUPABASE_SERVICE_ROLE_KEY=<key> node saas/scripts/embed-techniques.js
//
// 또는 .env 파일 사용 시 (dotenv 설치 필요):
//   node -r dotenv/config saas/scripts/embed-techniques.js
//
// 필요 패키지: @supabase/supabase-js
// Node 18+ 내장 fetch 사용 (node-fetch 별도 설치 불필요)

import { createClient } from '@supabase/supabase-js';

// ── 환경 변수 확인 ──
const VOYAGE_API_KEY = process.env.VOYAGE_API_KEY;
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gnusyjnviugpofvaicbv.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!VOYAGE_API_KEY) {
  console.error('❌ VOYAGE_API_KEY 환경 변수가 없습니다.');
  process.exit(1);
}
if (!SUPABASE_SERVICE_ROLE_KEY) {
  console.error('❌ SUPABASE_SERVICE_ROLE_KEY 환경 변수가 없습니다.');
  process.exit(1);
}

// ── Supabase 클라이언트 (service_role — RLS 우회) ──
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

const VOYAGE_API_URL = 'https://api.voyageai.com/v1/embeddings';
const VOYAGE_MODEL = 'voyage-3-lite';  // 512차원
const BATCH_SIZE = 3;                  // 무료 플랜 3 RPM 대응 (배치당 1 req)

// ── 임베딩 텍스트 조합 ──
// name_ko + technique_steps instructions + clinical_notes
function buildEmbeddingText(technique) {
  const namePart = technique.name_ko || '';

  // technique_steps는 JSONB 배열 — 각 step의 instruction 필드를 ". "로 join
  let stepsPart = '';
  if (Array.isArray(technique.technique_steps) && technique.technique_steps.length > 0) {
    stepsPart = technique.technique_steps
      .map(s => s.instruction || '')
      .filter(Boolean)
      .join('. ');
  }

  const notesPart = technique.clinical_notes || '';

  return [namePart, stepsPart, notesPart]
    .filter(Boolean)
    .join(' | ');
}

// ── Voyage AI 임베딩 API 호출 (배치) ──
async function getEmbeddings(texts) {
  const response = await fetch(VOYAGE_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${VOYAGE_API_KEY}`,
    },
    body: JSON.stringify({
      model: VOYAGE_MODEL,
      input: texts,
    }),
  });

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`Voyage API 오류 (${response.status}): ${errText.slice(0, 300)}`);
  }

  const data = await response.json();
  // data.data[i].embedding — 순서가 입력 texts 순서와 동일
  return data.data.map(item => item.embedding);
}

// ── 배치 분할 헬퍼 ──
function chunkArray(arr, size) {
  const chunks = [];
  for (let i = 0; i < arr.length; i += size) {
    chunks.push(arr.slice(i, i + size));
  }
  return chunks;
}

// ── 메인 ──
async function main() {
  const onlyNew = process.argv.includes('--only-new');

  console.log('📦 Supabase에서 is_active=true 기법 조회 중...');

  const { data: techniques, error: fetchErr } = await supabase
    .from('techniques')
    .select('id, name_ko, technique_steps, clinical_notes')
    .eq('is_active', true);

  if (fetchErr) {
    console.error('❌ Supabase 조회 실패:', fetchErr.message);
    process.exit(1);
  }

  console.log(`✅ 총 ${techniques.length}개 기법 로드됨`);

  // --only-new 플래그: 이미 임베딩된 기법 제외
  let targetTechniques = techniques;
  if (onlyNew) {
    console.log('🔍 이미 임베딩된 기법 조회 중...');
    const { data: existing, error: embErr } = await supabase
      .from('technique_embeddings')
      .select('id');

    if (embErr) {
      console.error('❌ technique_embeddings 조회 실패:', embErr.message);
      process.exit(1);
    }

    const embeddedIds = new Set((existing || []).map(r => r.id));
    targetTechniques = techniques.filter(t => !embeddedIds.has(t.id));
    console.log(`⏭️  이미 완료: ${embeddedIds.size}개 → 남은 대상: ${targetTechniques.length}개`);

    if (targetTechniques.length === 0) {
      console.log('✅ 모든 기법이 이미 임베딩되어 있습니다.');
      return;
    }
  }

  // 임베딩 텍스트 준비
  const records = targetTechniques.map(t => ({
    id: t.id,
    text: buildEmbeddingText(t),
  }));

  // 빈 텍스트 경고
  const empty = records.filter(r => !r.text.trim());
  if (empty.length > 0) {
    console.warn(`⚠️  임베딩 텍스트가 비어 있는 기법 ${empty.length}개 — 건너뜁니다.`);
  }
  const validRecords = records.filter(r => r.text.trim());

  // 배치 처리
  const batches = chunkArray(validRecords, BATCH_SIZE);
  let successCount = 0;
  let failCount = 0;

  console.log(`🚀 ${batches.length}개 배치 (배치당 최대 ${BATCH_SIZE}개) 임베딩 시작...`);

  for (let batchIdx = 0; batchIdx < batches.length; batchIdx++) {
    const batch = batches[batchIdx];
    const texts = batch.map(r => r.text);

    process.stdout.write(`  배치 ${batchIdx + 1}/${batches.length} (${batch.length}개) 처리 중...`);

    let embeddings;
    try {
      embeddings = await getEmbeddings(texts);
    } catch (err) {
      console.error(`\n❌ Voyage API 오류 (배치 ${batchIdx + 1}):`, err.message);
      failCount += batch.length;
      continue;
    }

    // Supabase upsert 데이터 구성
    const upsertRows = batch.map((record, i) => ({
      id: record.id,
      embedding: embeddings[i],
      embedded_text: record.text,
      updated_at: new Date().toISOString(),
    }));

    const { error: upsertErr } = await supabase
      .from('technique_embeddings')
      .upsert(upsertRows, { onConflict: 'id' });

    if (upsertErr) {
      console.error(`\n❌ Supabase upsert 오류 (배치 ${batchIdx + 1}):`, upsertErr.message);
      failCount += batch.length;
    } else {
      successCount += batch.length;
      console.log(` ✅ 완료`);
    }

    // 무료 플랜 3 RPM 제한 대응 — 21초 대기
    if (batchIdx < batches.length - 1) {
      process.stdout.write(`  ⏳ rate limit 대기 중 (21초)...`);
      await new Promise(r => setTimeout(r, 21000));
      process.stdout.write(` 완료\n`);
    }
  }

  console.log('\n=== 임베딩 생성 완료 ===');
  console.log(`✅ 성공: ${successCount}개`);
  if (failCount > 0) console.log(`❌ 실패: ${failCount}개`);
  if (empty.length > 0) console.log(`⚠️  건너뜀 (빈 텍스트): ${empty.length}개`);
  console.log(`📊 총 처리: ${techniques.length}개`);
}

main().catch(err => {
  console.error('❌ 예상치 못한 오류:', err);
  process.exit(1);
});
