const fs = require('fs');

function parseTableField(content, fieldName) {
    const lines = content.split('\n');
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.indexOf('| ' + fieldName) >= 0) {
            const parts = line.split('|').map(p => p.trim()).filter(p => p.length > 0);
            if (parts.length >= 2) return parts[1];
        }
    }
    return null;
}

function extractCheckedTags(content, sectionTitle) {
    const lines = content.split('\n');
    let inSection = false;
    const tags = [];
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.indexOf('### ' + sectionTitle) >= 0) { inSection = true; continue; }
        if (inSection) {
            if (line.startsWith('### ') || line.startsWith('---')) break;
            const m = line.match(/^- \[x\] (\w+)/);
            if (m) tags.push(m[1]);
        }
    }
    return tags;
}

function extractAbsContra(content) {
    const lines = content.split('\n');
    let inSection = false;
    const tags = [];
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.indexOf('절대 금기') >= 0 && line.indexOf('**') >= 0) { inSection = true; continue; }
        if (inSection) {
            if (line.indexOf('상대 금기') >= 0 && line.indexOf('**') >= 0) break;
            if (line.trim().startsWith('---')) break;
            const m = line.match(/^- \[x\] (\w+)/);
            if (m) tags.push(m[1]);
        }
    }
    return tags;
}

function extractRelContra(content) {
    const lines = content.split('\n');
    let inSection = false;
    const tags = [];
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.indexOf('상대 금기') >= 0 && line.indexOf('**') >= 0) { inSection = true; continue; }
        if (inSection) {
            if (line.trim().startsWith('---') || (line.startsWith('## ') && !line.startsWith('### '))) break;
            const m = line.match(/^- \[x\] (\w+)/);
            if (m) tags.push(m[1]);
        }
    }
    return tags;
}

function extractEvidenceLevel(content) {
    const lines = content.split('\n');
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.indexOf('근거 수준') >= 0) {
            const parts = line.split('|').map(p => p.trim()).filter(p => p.length > 0);
            if (parts.length >= 2) {
                const val = parts[1].toLowerCase();
                if (val.indexOf('1a') >= 0) return 'level_1a';
                if (val.indexOf('1b') >= 0) return 'level_1b';
                if (val.indexOf('2a') >= 0) return 'level_2a';
                if (val.indexOf('2b') >= 0) return 'level_2b';
                if (val.indexOf('level_3') >= 0) return 'level_3';
                if (val.indexOf('4') >= 0 && val.indexOf('5') >= 0) return 'level_5';
                if (val.indexOf('level_4') >= 0) return 'level_4';
                if (val.indexOf('level_5') >= 0) return 'level_5';
                if (val.indexOf('3') >= 0) return 'level_3';
                if (val.indexOf('4') >= 0) return 'level_4';
            }
        }
    }
    return 'level_5';
}

function mapBodyRegion(raw) {
    if (!raw) return 'full_spine';
    const r = raw.toLowerCase();
    if (r.indexOf('ankle') >= 0 || r.indexOf('plantar') >= 0) return 'ankle_foot';
    if (r === 'foot' || r.startsWith('foot')) return 'ankle_foot';
    if (r.startsWith('cervical') || r.startsWith('neck')) return 'cervical';
    if (r.startsWith('lumbar')) return 'lumbar';
    if (r.indexOf('sacrum') >= 0 || r.indexOf('sacral') >= 0 || r.indexOf('pelvis') >= 0) return 'sacroiliac';
    if (r.startsWith('shoulder') || r.startsWith('pec')) return 'shoulder';
    if (r.startsWith('elbow')) return 'elbow';
    if (r.startsWith('knee')) return 'knee';
    if (r.startsWith('hip')) return 'hip';
    if (r.startsWith('thoracic') || r.startsWith('thorax')) return 'thoracic';
    if (r.startsWith('rib')) return 'rib';
    if (r.indexOf('abdom') >= 0) return 'lumbar';
    if (r.indexOf('cervical') >= 0) return 'cervical';
    if (r.indexOf('lumbar') >= 0) return 'lumbar';
    if (r.indexOf('hip') >= 0) return 'hip';
    if (r.indexOf('knee') >= 0) return 'knee';
    if (r.indexOf('shoulder') >= 0) return 'shoulder';
    if (r.indexOf('elbow') >= 0) return 'elbow';
    if (r.indexOf('thoracic') >= 0) return 'thoracic';
    if (r.indexOf('foot') >= 0) return 'ankle_foot';
    if (r.indexOf('wrist') >= 0 || r.indexOf('forearm') >= 0) return 'wrist_hand';
    return 'full_spine';
}

function getCategoryKey(cat) {
    const map = {
        'ART': 'category_art',
        'CTM': 'category_ctm',
        'DeepFriction': 'category_deep_friction',
        'TriggerPoint': 'category_trigger_point',
        'AnatomyTrains': 'category_anatomy_trains',
        'MDT': 'category_mdt',
        'SCS': 'category_scs'
    };
    return map[cat] || 'category_e_soft_tissue';
}

const basePaths = [
    { path: "C:/project/PT/KMovement Optimism/research/soft-tissue/ART/techniques", cat: 'ART' },
    { path: "C:/project/PT/KMovement Optimism/research/soft-tissue/CTM/techniques", cat: 'CTM' },
    { path: "C:/project/PT/KMovement Optimism/research/soft-tissue/DeepFriction/techniques", cat: 'DeepFriction' },
    { path: "C:/project/PT/KMovement Optimism/research/soft-tissue/TriggerPoint/techniques", cat: 'TriggerPoint' },
    { path: "C:/project/PT/KMovement Optimism/research/special-techniques/AnatomyTrains/techniques", cat: 'AnatomyTrains' },
    { path: "C:/project/PT/KMovement Optimism/research/special-techniques/MDT/techniques", cat: 'MDT' },
    { path: "C:/project/PT/KMovement Optimism/research/special-techniques/SCS/techniques", cat: 'SCS' }
];

const results = [];
basePaths.forEach(item => {
    const files = fs.readdirSync(item.path).filter(f => f.endsWith('.md') && !f.startsWith('00-'));
    files.forEach(f => {
        const content = fs.readFileSync(item.path + '/' + f, 'utf8');
        const r = {
            file: f,
            cat: item.cat,
            categoryKey: getCategoryKey(item.cat),
            nameKo: parseTableField(content, '한국어 이름'),
            nameEn: parseTableField(content, '영문 이름'),
            abbrev: parseTableField(content, '약어'),
            bodyRegionRaw: parseTableField(content, '해당 부위'),
            bodySegment: parseTableField(content, '세부 분절') || parseTableField(content, '세부 구조') || parseTableField(content, '관련 근육'),
            purposeTags: extractCheckedTags(content, '2-1'),
            targetTags: extractCheckedTags(content, '2-2'),
            symptomTags: extractCheckedTags(content, '2-3'),
            absContraTags: extractAbsContra(content),
            relContraTags: extractRelContra(content),
            evidenceLevel: extractEvidenceLevel(content)
        };
        r.bodyRegion = mapBodyRegion(r.bodyRegionRaw || '');
        results.push(r);
    });
});

const outputPath = "C:/project/PT/KMovement Optimism/pt-prescription/saas/scripts/techniques_data.json";
fs.writeFileSync(outputPath, JSON.stringify(results, null, 2));
console.log('Saved ' + results.length + ' techniques to ' + outputPath);
results.forEach(r => {
    const missing = [];
    if (!r.nameKo) missing.push('nameKo');
    if (!r.nameEn) missing.push('nameEn');
    if (!r.abbrev) missing.push('abbrev');
    if (missing.length > 0) console.log('MISSING: ' + r.file + ' -> ' + missing.join(', '));
    else console.log('OK: ' + r.cat + ' | ' + r.abbrev + ' | ' + r.bodyRegion + ' | ev: ' + r.evidenceLevel);
});
