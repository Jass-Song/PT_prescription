-- ============================================================
-- Migration 004c — techniques 카테고리 값 업데이트
-- K-Movement Optimism — Category Hierarchy Restructure
-- ============================================================
-- ⚠️  실행 순서: 004a → 004b 완료 후 이 파일 실행
--     004a: 신규 ENUM 값 추가 (커밋 필수)
--     004b: technique_categories 재구조화 (parent_key, 신규 카테고리)
-- ============================================================

-- STEP 1: category_a_joint_mobilization → category_joint_mobilization
UPDATE techniques
SET category = 'category_joint_mobilization',
    category_id = (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
    updated_at = NOW()
WHERE category = 'category_a_joint_mobilization';

-- STEP 2: category_b_mulligan → category_mulligan
UPDATE techniques
SET category = 'category_mulligan',
    category_id = (SELECT id FROM technique_categories WHERE category_key = 'category_mulligan'),
    updated_at = NOW()
WHERE category = 'category_b_mulligan';

-- STEP 3: category_e_soft_tissue + subcategory='IASTM' → category_iastm
UPDATE techniques
SET category = 'category_iastm',
    category_id = (SELECT id FROM technique_categories WHERE category_key = 'category_iastm'),
    updated_at = NOW()
WHERE category = 'category_e_soft_tissue'
  AND subcategory = 'IASTM';

-- STEP 4: category_e_soft_tissue + subcategory='MFR' → category_mfr
UPDATE techniques
SET category = 'category_mfr',
    category_id = (SELECT id FROM technique_categories WHERE category_key = 'category_mfr'),
    updated_at = NOW()
WHERE category = 'category_e_soft_tissue'
  AND subcategory = 'MFR';

-- 검증 쿼리 (실행 후 확인용)
-- SELECT category, COUNT(*) FROM techniques GROUP BY category ORDER BY category;
-- 기대값: category_iastm=9, category_joint_mobilization=20, category_mfr=17, category_mulligan=22
