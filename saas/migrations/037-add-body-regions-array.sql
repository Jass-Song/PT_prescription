-- ============================================================
-- Migration 037 — body_regions text[] 다중 부위 지원 컬럼 추가
-- 배경: NEU-SH-Median/Radial/Ulnar가 shoulder 및 cervical 방사통 모두에 적용
--       body_region(단일 enum)으로는 다중 부위 지원 불가
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================

-- 1) body_regions 배열 컬럼 추가
ALTER TABLE techniques
  ADD COLUMN IF NOT EXISTS body_regions text[] DEFAULT '{}';

-- 2) 기존 body_region 값을 body_regions로 이전
UPDATE techniques
SET body_regions = ARRAY[body_region::text]
WHERE body_region IS NOT NULL
  AND (body_regions IS NULL OR body_regions = '{}');

-- 3) 진단: 이전 결과 확인
SELECT abbreviation, name_ko, body_region, body_regions
FROM techniques
WHERE body_region IS NOT NULL
ORDER BY body_region, abbreviation
LIMIT 20;

-- 4) NEU-SH-Median/Radial/Ulnar → shoulder + cervical 동시 등록
UPDATE techniques
SET
  body_regions = ARRAY['shoulder', 'cervical'],
  updated_at   = NOW()
WHERE abbreviation IN ('NEU-SH-Median', 'NEU-SH-Radial', 'NEU-SH-Ulnar');

-- 5) 수정 결과 확인
SELECT abbreviation, name_ko, body_region, body_regions, target_tags
FROM techniques
WHERE abbreviation IN ('NEU-SH-Median', 'NEU-SH-Radial', 'NEU-SH-Ulnar');
