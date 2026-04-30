// KMO 도수치료 테크닉 추천 엔진
// 입력: { body_part, purpose_tags, target_tags, contraindications_present }
// 출력: 상위 5개 추천 테크닉 (score 순)

const TECHNIQUES_DB = require('./techniques-db');

/**
 * 테크닉 추천 함수
 *
 * @param {Object} query
 * @param {string}   query.body_part               - 신체 부위 키 (예: "lumbar", "shoulder")
 * @param {string[]} query.purpose_tags             - 치료 목적 태그 배열 (예: ["pain_relief", "rom_improvement"])
 * @param {string[]} query.target_tags              - 환자 상태 태그 배열 (예: ["chronic", "athlete"])
 * @param {string[]} query.contraindications_present - 현재 환자의 금기 키워드 배열 (예: ["골절", "불안정성"])
 * @param {number}   [query.topN=5]                 - 반환할 최대 테크닉 수
 *
 * @returns {Array} 스코어 포함 테크닉 배열 (내림차순 정렬)
 */
function recommendTechniques(query) {
  const {
    body_part,
    purpose_tags = [],
    target_tags = [],
    contraindications_present = [],
    topN = 5
  } = query;

  return TECHNIQUES_DB
    .filter(t => {
      // 1. 부위 매칭 (body_part 지정 시)
      if (body_part && t.body_part !== body_part) return false;

      // 2. 금기증 필터 — 환자 금기 키워드가 테크닉 금기 목록에 포함되면 제외
      if (contraindications_present.length > 0) {
        const hasContraindication = contraindications_present.some(c =>
          t.contraindications.some(tc =>
            tc.toLowerCase().includes(c.toLowerCase()) ||
            c.toLowerCase().includes(tc.toLowerCase())
          )
        );
        if (hasContraindication) return false;
      }

      return true;
    })
    .map(t => {
      let score = 0;

      // 기본 가중치 40% — 임상 근거 및 사용 빈도 반영
      score += t.recommendation_weight * 0.40;

      // 목적 태그 매칭 30%
      const purposeMatch = purpose_tags.filter(p => t.purpose_tags.includes(p)).length;
      const purposeScore = purpose_tags.length > 0
        ? (purposeMatch / purpose_tags.length) * 0.30
        : 0.15; // 목적 미지정 시 기본 0.15 부여
      score += purposeScore;

      // 대상 태그 매칭 20%
      const targetMatch = target_tags.filter(tg => t.target_tags.includes(tg)).length;
      const targetScore = target_tags.length > 0
        ? (targetMatch / target_tags.length) * 0.20
        : 0.10; // 대상 미지정 시 기본 0.10 부여
      score += targetScore;

      // 근거 수준 보정 10%
      const evidenceBonus = { high: 0.10, medium: 0.05, low: 0.01 };
      score += evidenceBonus[t.evidence_level] || 0;

      // 소수점 3자리 반올림
      const finalScore = Math.round(score * 1000) / 1000;

      // 적응증 매칭률 계산 (UI 표시용)
      const totalTags = purpose_tags.length + target_tags.length;
      const matchedTags = purposeMatch + targetMatch;
      const matchPct = totalTags > 0 ? Math.round((matchedTags / totalTags) * 100) : 50;

      return {
        ...t,
        score: finalScore,
        match_pct: matchPct,
        matched_purpose: purpose_tags.filter(p => t.purpose_tags.includes(p)),
        matched_target: target_tags.filter(tg => t.target_tags.includes(tg))
      };
    })
    .filter(t => t.score > 0)
    .sort((a, b) => {
      // 1차 정렬: score 내림차순
      if (b.score !== a.score) return b.score - a.score;
      // 2차 정렬: recommendation_weight 내림차순 (동점 시)
      return b.recommendation_weight - a.recommendation_weight;
    })
    .slice(0, topN);
}

/**
 * 사용 가능한 부위 목록 반환
 */
function getBodyParts() {
  const parts = {};
  TECHNIQUES_DB.forEach(t => {
    if (!parts[t.body_part]) {
      parts[t.body_part] = t.body_part_label;
    }
  });
  return parts;
}

/**
 * 카테고리별 테크닉 통계
 */
function getStats() {
  const catA = TECHNIQUES_DB.filter(t => t.category === 'A').length;
  const catB = TECHNIQUES_DB.filter(t => t.category === 'B').length;
  const bodyParts = [...new Set(TECHNIQUES_DB.map(t => t.body_part))].length;
  return { total: TECHNIQUES_DB.length, categoryA: catA, categoryB: catB, bodyParts };
}

// 모듈 내보내기
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { recommendTechniques, getBodyParts, getStats };
}

// ──────────────────────────────────────
// CLI 테스트 (node recommend.js 실행 시)
// ──────────────────────────────────────
if (require.main === module) {
  console.log('\n=== KMO 도수치료 테크닉 추천 엔진 테스트 ===\n');

  const stats = getStats();
  console.log(`데이터베이스: 총 ${stats.total}개 테크닉 (A: ${stats.categoryA}개, B: ${stats.categoryB}개), ${stats.bodyParts}개 부위\n`);

  // 테스트 1: 요추 + ROM 개선 + 만성
  console.log('--- 테스트 1: 요추 + ROM 개선 + 만성 ---');
  const result1 = recommendTechniques({
    body_part: 'lumbar',
    purpose_tags: ['rom_improvement'],
    target_tags: ['chronic']
  });
  result1.forEach((t, i) => {
    console.log(`${i+1}. [${t.category}] ${t.name_ko} | Score: ${t.score} | Match: ${t.match_pct}%`);
  });

  // 테스트 2: 어깨 + 통증 감소 + 아급성
  console.log('\n--- 테스트 2: 어깨 + 통증 감소 + 아급성 ---');
  const result2 = recommendTechniques({
    body_part: 'shoulder',
    purpose_tags: ['pain_relief'],
    target_tags: ['subacute']
  });
  result2.forEach((t, i) => {
    console.log(`${i+1}. [${t.category}] ${t.name_ko} | Score: ${t.score} | Match: ${t.match_pct}%`);
  });

  // 테스트 3: 발목 + 기능 회복 + 운동선수
  console.log('\n--- 테스트 3: 발목 + 기능 회복 + 운동선수 ---');
  const result3 = recommendTechniques({
    body_part: 'ankle_foot',
    purpose_tags: ['functional_recovery'],
    target_tags: ['athlete']
  });
  result3.forEach((t, i) => {
    console.log(`${i+1}. [${t.category}] ${t.name_ko} | Score: ${t.score} | Match: ${t.match_pct}%`);
  });

  // 테스트 4: 금기증 필터 테스트 — 골절 있는 경추 환자
  console.log('\n--- 테스트 4: 금기증 필터 — 경추 + 골절 있는 환자 ---');
  const result4 = recommendTechniques({
    body_part: 'cervical',
    purpose_tags: ['pain_relief'],
    target_tags: ['subacute'],
    contraindications_present: ['골절']
  });
  result4.forEach((t, i) => {
    console.log(`${i+1}. [${t.category}] ${t.name_ko} | Score: ${t.score} (금기 필터 적용됨)`);
  });
  if (result4.length === 0) console.log('  → 금기증으로 인해 추천 불가');

  console.log('\n=== 테스트 완료 ===\n');
}
