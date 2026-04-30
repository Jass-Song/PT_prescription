/**
 * KMO SaaS — Supabase Migration Script
 *
 * 용도:
 *   1. service_role key로 schema.sql 실행 (DDL)
 *   2. seed_techniques.json → techniques 테이블 REST API upsert
 *
 * 실행 방법:
 *   SUPABASE_SERVICE_KEY=<service_role_key> node pt-prescription/saas/migrate.js
 *
 * 또는 anon key만 있는 경우 (테이블 이미 존재 시 시드만):
 *   SEED_ONLY=true node pt-prescription/saas/migrate.js
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

// ─── 설정 ───────────────────────────────────────────────────────────────────
const SUPABASE_URL = 'https://gnusyjnviugpofvaicbv.supabase.co';
const ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdudXN5am52aXVncG9mdmFpY2J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcwMzQxOTMsImV4cCI6MjA5MjYxMDE5M30.a52myh41qHEt9jnfxBh7009tQ35ZGNIm_C93HQa6x_g';

const SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || null;
const SEED_ONLY   = process.env.SEED_ONLY === 'true';

const ACTIVE_KEY  = SERVICE_KEY || ANON_KEY;

const __dir = path.join(__dirname);

// ─── 유틸 ────────────────────────────────────────────────────────────────────
function request(options, body = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, body: data }); }
      });
    });
    req.on('error', reject);
    if (body) req.write(typeof body === 'string' ? body : JSON.stringify(body));
    req.end();
  });
}

function makeOptions(method, path, extraHeaders = {}) {
  const url = new URL(SUPABASE_URL);
  return {
    hostname: url.hostname,
    path: path,
    method: method,
    headers: {
      'Content-Type': 'application/json',
      'apikey': ACTIVE_KEY,
      'Authorization': `Bearer ${ACTIVE_KEY}`,
      'Prefer': 'return=minimal',
      ...extraHeaders
    }
  };
}

// ─── 1. 테이블 존재 여부 확인 ────────────────────────────────────────────────
async function checkTableExists() {
  const opts = makeOptions('GET', '/rest/v1/techniques?select=id&limit=1');
  const res = await request(opts);
  return res.status !== 404;
}

// ─── 2. Supabase Management API로 SQL 실행 (service_role 필요) ───────────────
async function executeSqlViaManagementApi(sql) {
  if (!SERVICE_KEY) {
    throw new Error('SERVICE_KEY가 없습니다. SUPABASE_SERVICE_KEY 환경변수를 설정하세요.');
  }
  // Supabase Management API: POST /pg/query (project ref 기반)
  const projectRef = 'gnusyjnviugpofvaicbv';
  const options = {
    hostname: 'api.supabase.com',
    path: `/v1/projects/${projectRef}/database/query`,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SERVICE_KEY}`,
    }
  };
  const res = await request(options, { query: sql });
  return res;
}

// ─── 3. 테크닉 시드 데이터 upsert (REST API) ──────────────────────────────────
async function seedTechniques() {
  const raw = fs.readFileSync(path.join(__dir, 'seed_techniques.json'), 'utf8');
  const techniques = JSON.parse(raw);

  console.log(`\n[시드] ${techniques.length}개 테크닉 upsert 시작...`);

  // RLS 우회를 위해 service_key 사용 권장
  // anon key는 RLS에 막힐 수 있음 — techniques 테이블의 INSERT policy 확인 필요
  const BATCH_SIZE = 10;
  let successCount = 0;
  let failCount = 0;

  for (let i = 0; i < techniques.length; i += BATCH_SIZE) {
    const batch = techniques.slice(i, i + BATCH_SIZE).map(t => {
      // JSON 필드를 문자열로 변환 (REST API는 JSONB를 객체로 받음)
      const row = { ...t };
      delete row.id; // uuid는 DB에서 자동 생성
      // technique_steps, key_references는 JSONB — 객체 그대로 전달
      return row;
    });

    const opts = makeOptions('POST', '/rest/v1/techniques', {
      'Prefer': 'resolution=ignore-duplicates,return=minimal'
    });

    const bodyStr = JSON.stringify(batch);
    const optsWithLength = {
      ...opts,
      headers: {
        ...opts.headers,
        'Content-Length': Buffer.byteLength(bodyStr)
      }
    };

    const res = await request(optsWithLength, bodyStr);
    const batchEnd = Math.min(i + BATCH_SIZE, techniques.length);

    if (res.status === 201 || res.status === 200 || res.status === 204) {
      successCount += (batchEnd - i);
      console.log(`  ✓ 배치 ${i + 1}–${batchEnd} 성공 (HTTP ${res.status})`);
    } else {
      failCount += (batchEnd - i);
      console.error(`  ✗ 배치 ${i + 1}–${batchEnd} 실패 (HTTP ${res.status}):`, JSON.stringify(res.body).slice(0, 200));
    }
  }

  console.log(`\n[시드 완료] 성공: ${successCount}, 실패: ${failCount}`);
  return { successCount, failCount };
}

// ─── 메인 ────────────────────────────────────────────────────────────────────
async function main() {
  console.log('=== KMO SaaS Supabase Migration ===');
  console.log(`URL: ${SUPABASE_URL}`);
  console.log(`Key 종류: ${SERVICE_KEY ? 'service_role' : 'anon (제한됨)'}`);
  console.log(`모드: ${SEED_ONLY ? 'SEED_ONLY' : 'FULL (schema + seed)'}`);

  // 1. 테이블 존재 여부 확인
  const tableExists = await checkTableExists();
  console.log(`\n[체크] techniques 테이블: ${tableExists ? '존재' : '없음'}`);

  if (!tableExists && SEED_ONLY) {
    console.error('\n[오류] 테이블이 없습니다. schema.sql을 먼저 실행해야 합니다.');
    console.error('       Supabase 대시보드 > SQL Editor에서 schema.sql을 실행하세요.');
    process.exit(1);
  }

  // 2. 스키마 생성 (service_role + 테이블 없을 때)
  if (!tableExists && !SEED_ONLY) {
    if (!SERVICE_KEY) {
      console.error('\n[오류] schema.sql 실행에는 SERVICE_KEY가 필요합니다.');
      console.error('       SUPABASE_SETUP_GUIDE.md를 참고하세요.');
      process.exit(1);
    }
    console.log('\n[스키마] schema.sql 실행 중...');
    const schemaSql = fs.readFileSync(path.join(__dir, 'schema.sql'), 'utf8');
    try {
      const res = await executeSqlViaManagementApi(schemaSql);
      if (res.status === 200 || res.status === 201) {
        console.log('[스키마] 성공');
      } else {
        console.error('[스키마] 실패:', JSON.stringify(res.body).slice(0, 300));
        process.exit(1);
      }
    } catch (e) {
      console.error('[스키마] 오류:', e.message);
      process.exit(1);
    }
  }

  // 3. 시드 데이터 삽입
  if (tableExists || !SEED_ONLY) {
    await seedTechniques();
  }

  console.log('\n=== 완료 ===');
}

main().catch(e => {
  console.error('예상치 못한 오류:', e);
  process.exit(1);
});
