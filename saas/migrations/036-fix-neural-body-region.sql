-- ============================================================
-- Migration 036 — 신경가동술 body_region 진단 & 수정
-- NEU-CX-Slider, NEU-CX-Tensioner body_region → cervical 강제 수정
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

-- 1) 진단: 현재 d_neural 기법 전체 목록 + body_region 확인
SELECT abbreviation, name_ko, body_region, is_active, is_published, target_tags
FROM techniques
WHERE category = 'category_d_neural'
ORDER BY abbreviation;

-- 위 결과 확인 후 아래 UPDATE 실행

-- 2) NEU-CX-Slider / NEU-CX-Tensioner body_region 강제 수정
UPDATE techniques
SET
  body_region = 'cervical'::body_region,
  updated_at  = NOW()
WHERE abbreviation IN ('NEU-CX-Slider', 'NEU-CX-Tensioner');

-- 3) 결과 재확인
SELECT abbreviation, name_ko, body_region, is_active, target_tags
FROM techniques
WHERE category = 'category_d_neural'
ORDER BY body_region, abbreviation;
