/**
 * generate_seed_missing.js
 * Generates migration SQL for 55 unmigrated techniques across 7 categories:
 * ART (11), CTM (7), DeepFriction (7), TriggerPoint (11),
 * AnatomyTrains (7), MDT (5), SCS (7)
 */

const fs = require('fs');
const path = require('path');

const data = JSON.parse(fs.readFileSync(
    path.join(__dirname, 'techniques_data.json'), 'utf8'
));

// SQL escape single quotes
function esc(str) {
    if (!str) return '';
    return str.replace(/'/g, "''");
}

// Format array as PostgreSQL text array
function pgArray(arr) {
    if (!arr || arr.length === 0) return "'{}'";
    return "'{" + arr.map(t => '"' + t + '"').join(',') + "}'";
}

// Format JSONB steps — minimal steps since MD files have prose, not numbered steps
function buildSteps(r) {
    // Build basic steps from the technique name as a placeholder
    const steps = [
        { step: 1, instruction: "MD 파일(" + r.file + ")의 시술 방법 4절 참조 — 상세 단계별 절차 포함" },
        { step: 2, instruction: "환자 자세 및 치료사 접촉 위치 확인 후 시작" },
        { step: 3, instruction: "기법 적용 및 환자 반응 모니터링" },
        { step: 4, instruction: "시술 후 재평가 — 통증 NRS, 가동범위 변화 확인" }
    ];
    return "'" + JSON.stringify(steps).replace(/'/g, "''") + "'::jsonb";
}

// Category metadata
const categoryMeta = {
    category_art: {
        nameKo: 'ART (능동적 이완기법)',
        nameEn: 'Active Release Technique',
        subtitleKo: '연부조직 능동 이완 — ART 기반 접근법',
        group: 'group_soft_tissue',
        sortOrder: 3,
        principles: [
            { icon: '🤲', title_ko: '고정 + 능동 운동의 결합', desc_ko: '치료사가 단축된 근육·건·인대에 접촉 압박을 가하면서 환자가 능동적으로 움직이는 복합 기법입니다.' },
            { icon: '🔍', title_ko: '단축 방향 촉진', desc_ko: '시술 전 근육의 단축 방향을 촉진으로 확인하고, 접촉 위치와 운동 방향을 결정합니다.' },
            { icon: '⏱️', title_ko: '반복 횟수 조절', desc_ko: '한 부위에 3~5회 반복이 원칙. 과도한 반복은 조직 자극을 유발합니다.' },
            { icon: '🚫', title_ko: 'DVT 스크리닝 필수', desc_ko: '하지 시술 전 심부정맥혈전증(DVT) 위험 요인을 반드시 확인합니다.' }
        ]
    },
    category_ctm: {
        nameKo: 'CTM (결합조직 마사지)',
        nameEn: 'Connective Tissue Massage',
        subtitleKo: '피하 결합조직 자율신경 반사 기법',
        group: 'group_soft_tissue',
        sortOrder: 4,
        principles: [
            { icon: '🧠', title_ko: '자율신경 반사 기전', desc_ko: '피하 결합조직을 자극하여 척수 분절을 통한 자율신경 반사를 유도합니다.' },
            { icon: '📋', title_ko: '시작 부위 고정', desc_ko: '천추·허리 부위(CTM-SL)에서 시작하는 것이 원칙입니다. 순서를 어기면 자율신경 반응이 과도해질 수 있습니다.' },
            { icon: '⚡', title_ko: '긁기 반응 확인', desc_ko: '피부에 가는 붉은 선(dermographism)이 나타나면 올바른 깊이로 시술 중인 신호입니다.' },
            { icon: '🚫', title_ko: '배 CTM은 마지막', desc_ko: '배 부위(CTM-AB)는 자율신경 반응이 가장 강해 반드시 마지막 단계에만 적용합니다.' }
        ]
    },
    category_deep_friction: {
        nameKo: '심부마찰 마사지',
        nameEn: 'Deep Transverse Friction Massage',
        subtitleKo: 'Cyriax 심부가로마찰 — 건·인대 병변 기법',
        group: 'group_soft_tissue',
        sortOrder: 5,
        principles: [
            { icon: '🔍', title_ko: '병변 정확 촉진', desc_ko: '건 또는 인대의 압통 최대 지점을 엄지·검지로 정확히 촉진하고 시작합니다.' },
            { icon: '↔️', title_ko: '가로 방향 마찰', desc_ko: '섬유 방향에 직각(가로)으로 짧고 깊은 마찰을 가하는 것이 핵심입니다. 섬유 방향으로 문지르는 것이 아닙니다.' },
            { icon: '⏱️', title_ko: '충분한 시간', desc_ko: '한 부위에 최소 5~10분 지속 적용이 원칙입니다. 짧게 여러 곳에 적용하는 것은 효과가 낮습니다.' },
            { icon: '🚫', title_ko: '급성기 금기', desc_ko: '급성 건염이나 인대 파열 초기에는 금기입니다. 아급성~만성기에 적용합니다.' }
        ]
    },
    category_trigger_point: {
        nameKo: '트리거포인트 이완',
        nameEn: 'Trigger Point Release',
        subtitleKo: '근육 내 통증 유발점 허혈성 압박 기법',
        group: 'group_soft_tissue',
        sortOrder: 6,
        principles: [
            { icon: '🔍', title_ko: '팽팽한 띠(Taut Band) 촉진', desc_ko: '근육 내 팽팽한 띠를 먼저 촉진하고, 그 안에서 압통 결절(tender nodule)을 찾습니다.' },
            { icon: '🤲', title_ko: '점진적 압박', desc_ko: '압통이 6~7/10 수준으로 느껴질 때까지 서서히 압박을 증가시킵니다. 강한 통증을 유발하지 않습니다.' },
            { icon: '⏱️', title_ko: '압박 유지 시간', desc_ko: '통증이 3~4/10으로 감소할 때까지 압박을 유지합니다(보통 20~90초). 이완 반응을 기다립니다.' },
            { icon: '🔄', title_ko: '연관통 패턴 확인', desc_ko: '압박 시 특정 방향으로 통증이 퍼지는 연관통 패턴은 올바른 트리거포인트 확인의 지표입니다.' }
        ]
    },
    category_anatomy_trains: {
        nameKo: '근막경선 (Anatomy Trains)',
        nameEn: 'Anatomy Trains — Myofascial Meridians',
        subtitleKo: 'Thomas Myers 근막경선 개념 기반 치료',
        group: 'group_soft_tissue',
        sortOrder: 7,
        principles: [
            { icon: '🗺️', title_ko: '경선 전체 평가', desc_ko: '증상 부위만 보지 않고 해당 경선 전체의 단축 패턴을 평가합니다.' },
            { icon: '🔗', title_ko: '연속성 기반 치료', desc_ko: '증상 부위 원위부(멀리)에서 이완을 시작하여 증상 부위로 접근하는 것이 원칙입니다.' },
            { icon: '⚖️', title_ko: '근거 수준 정직하게 고지', desc_ko: '개별 구성 기법(스트레칭, MFR)에는 근거가 있으나, 경선 전체를 단위로 치료한 RCT는 부족합니다.' },
            { icon: '🔄', title_ko: '동적 평가 병행', desc_ko: '정적 자세 분석보다 움직임 중 경선 단축 패턴을 동적으로 평가하는 것이 더 유용합니다.' }
        ]
    },
    category_mdt: {
        nameKo: 'MDT (맥켄지 방법)',
        nameEn: 'McKenzie Method / MDT',
        subtitleKo: '방향 선호성 기반 반복 운동 치료',
        group: 'group_exercise',
        sortOrder: 4,
        principles: [
            { icon: '🎯', title_ko: '방향 선호성 평가 우선', desc_ko: '반복 운동 검사를 통해 방향 선호성(directional preference)을 먼저 파악합니다. 검사 없이 운동 처방하지 않습니다.' },
            { icon: '📉', title_ko: '집중화 현상 목표', desc_ko: '퍼져있던 통증이 중앙(허리·목)으로 모이는 집중화(centralization) 반응을 목표로 합니다.' },
            { icon: '🔄', title_ko: '반복 운동 원칙', desc_ko: '하루 여러 번 반복이 핵심입니다. 1회 30분 치료보다 하루 10회 자가 운동이 더 효과적입니다.' },
            { icon: '📚', title_ko: '자가관리 교육', desc_ko: '환자 스스로 증상을 관리하고 재발 시 대처할 수 있도록 독립성을 키우는 것이 MDT의 핵심 목표입니다.' }
        ]
    },
    category_scs: {
        nameKo: '스트레인-카운터스트레인',
        nameEn: 'Strain-Counterstrain (SCS)',
        subtitleKo: 'Jones 통증점 반사 억제 기법',
        group: 'group_joint_mobilization',
        sortOrder: 3,
        principles: [
            { icon: '🔍', title_ko: '통증점 촉진', desc_ko: '통증점(tender point)을 촉진하고 0~10점 통증 강도를 확인합니다. 기준 통증이 7 이상이어야 합니다.' },
            { icon: '🛋️', title_ko: '편안한 자세 찾기', desc_ko: '통증점 통증이 3/10 이하로 감소하는 편안한 자세(position of ease)를 찾는 것이 핵심입니다.' },
            { icon: '⏱️', title_ko: '90초 유지', desc_ko: '편안한 자세를 90초간 유지합니다. 반사 억제 기전이 작동하는 데 충분한 시간이 필요합니다.' },
            { icon: '🐢', title_ko: '느린 복귀', desc_ko: '90초 후 중립 자세로 천천히(10~15초) 복귀합니다. 빠른 복귀는 근방추 반사를 재활성화할 수 있습니다.' }
        ]
    }
};

// Generate SQL
let sql = `-- ============================================================
-- K-Movement Optimism — Migration 008
-- 미마이그레이션 테크닉 시드 SQL (55개)
-- 생성일: 2026-04-25
-- 카테고리: ART(11), CTM(7), DeepFriction(7), TriggerPoint(11),
--           AnatomyTrains(7), MDT(5), SCS(7)
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- ⚠️  실행 순서 필수:
--     1단계: 008a-new-categories-enum.sql 먼저 실행 (ENUM 확장 커밋)
--     2단계: 이 파일 실행 (카테고리 7개 + 테크닉 55개 INSERT)
-- ============================================================

-- ============================================================
-- STEP 1: 신규 그룹 카테고리 INSERT (없으면 추가)
-- ============================================================

INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active)
VALUES
  ('group_special', '특수 기법', 'Special Techniques', '전문 임상 적용 특수 접근법', '[]'::jsonb, 5, true)
ON CONFLICT (category_key) DO NOTHING;

-- ============================================================
-- STEP 2: 신규 카테고리 7개 INSERT
-- ============================================================

`;

// Generate category inserts
Object.entries(categoryMeta).forEach(([key, meta]) => {
    const principlesJson = JSON.stringify(meta.principles).replace(/'/g, "''");
    sql += `INSERT INTO technique_categories (category_key, name_ko, name_en, subtitle_ko, basic_principles, sort_order, is_active, parent_key)
VALUES (
  '${key}',
  '${esc(meta.nameKo)}',
  '${esc(meta.nameEn)}',
  '${esc(meta.subtitleKo)}',
  '${principlesJson}'::jsonb,
  ${meta.sortOrder},
  true,
  '${meta.group}'
)
ON CONFLICT (category_key) DO NOTHING;

`;
});

sql += `-- ============================================================
-- STEP 3: 테크닉 INSERT (55개)
-- ============================================================

`;

// Group by category
const byCategory = {};
data.forEach(r => {
    if (!byCategory[r.cat]) byCategory[r.cat] = [];
    byCategory[r.cat].push(r);
});

const catOrder = ['ART', 'CTM', 'DeepFriction', 'TriggerPoint', 'AnatomyTrains', 'MDT', 'SCS'];
let techNum = 0;

catOrder.forEach(cat => {
    const techs = byCategory[cat] || [];
    sql += `-- ────────────────────────────────\n`;
    sql += `-- ${cat} 기법 ${techs.length}개\n`;
    sql += `-- ────────────────────────────────\n\n`;

    techs.forEach(r => {
        techNum++;
        const catKey = r.categoryKey;
        const allContraTags = [...new Set([...r.absContraTags, ...r.relContraTags])];

        // Build clinical notes from contra info
        const clinicalNote = `MD 파일(${r.file}) 임상 팁 참조. 절대 금기: ${r.absContraTags.join(', ') || '없음'}. 상대 금기: ${r.relContraTags.join(', ') || '없음'}.`;

        sql += `-- ${techNum}/${data.length}: ${r.nameKo || r.nameEn}\n`;
        sql += `INSERT INTO techniques (\n`;
        sql += `  category,\n`;
        sql += `  category_id,\n`;
        sql += `  subcategory,\n`;
        sql += `  name_ko, name_en, abbreviation,\n`;
        sql += `  body_region, body_segment,\n`;
        sql += `  patient_position, therapist_position, contact_point, direction,\n`;
        sql += `  technique_steps,\n`;
        sql += `  purpose_tags, target_tags, symptom_tags, contraindication_tags,\n`;
        sql += `  evidence_level,\n`;
        sql += `  clinical_notes,\n`;
        sql += `  absolute_contraindications, relative_contraindications,\n`;
        sql += `  is_active, is_published\n`;
        sql += `) VALUES (\n`;
        sql += `  '${catKey}',\n`;
        sql += `  (SELECT id FROM technique_categories WHERE category_key = '${catKey}'),\n`;
        sql += `  '${cat}',\n`;
        sql += `  '${esc(r.nameKo)}', '${esc(r.nameEn)}', '${esc(r.abbrev)}',\n`;
        sql += `  '${r.bodyRegion}'::body_region, '${esc(r.bodySegment || r.bodyRegionRaw || '')}',\n`;
        sql += `  NULL, NULL, NULL, NULL,\n`;
        sql += `  ${buildSteps(r)},\n`;
        sql += `  ${pgArray(r.purposeTags)}, ${pgArray(r.targetTags)},\n`;
        sql += `  ${pgArray(r.symptomTags)}, ${pgArray(allContraTags)},\n`;
        sql += `  '${r.evidenceLevel}'::evidence_level,\n`;
        sql += `  '${esc(clinicalNote)}',\n`;
        sql += `  '${esc(r.absContraTags.join(', ') || '')}',\n`;
        sql += `  '${esc(r.relContraTags.join(', ') || '')}',\n`;
        sql += `  true, false\n`;
        sql += `)\n`;
        sql += `ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET\n`;
        sql += `  name_ko            = EXCLUDED.name_ko,\n`;
        sql += `  name_en            = EXCLUDED.name_en,\n`;
        sql += `  body_region        = EXCLUDED.body_region,\n`;
        sql += `  technique_steps    = EXCLUDED.technique_steps,\n`;
        sql += `  purpose_tags       = EXCLUDED.purpose_tags,\n`;
        sql += `  target_tags        = EXCLUDED.target_tags,\n`;
        sql += `  symptom_tags       = EXCLUDED.symptom_tags,\n`;
        sql += `  contraindication_tags = EXCLUDED.contraindication_tags,\n`;
        sql += `  evidence_level     = EXCLUDED.evidence_level,\n`;
        sql += `  clinical_notes     = EXCLUDED.clinical_notes,\n`;
        sql += `  absolute_contraindications = EXCLUDED.absolute_contraindications,\n`;
        sql += `  relative_contraindications = EXCLUDED.relative_contraindications,\n`;
        sql += `  updated_at         = NOW();\n\n`;
    });
});

sql += `-- ============================================================
-- 검증 쿼리 (실행 후 확인용)
-- SELECT category, COUNT(*) FROM techniques GROUP BY category ORDER BY category;
-- 기대값: category_art=11, category_ctm=7, category_deep_friction=7,
--         category_trigger_point=11, category_anatomy_trains=7, category_mdt=5, category_scs=7
-- ============================================================
`;

const outputPath = "C:/project/PT/KMovement Optimism/pt-prescription/saas/migrations/008-missing-techniques.sql";
fs.writeFileSync(outputPath, sql, 'utf8');
console.log('Generated: ' + outputPath);
console.log('Total techniques: ' + data.length);
