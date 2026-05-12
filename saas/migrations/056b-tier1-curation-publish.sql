-- ============================================================
-- Migration 056b — Tier 1 큐레이션 86 is_published 시드
-- ============================================================
-- 목적: 베타 출시 추천 풀 정의.
--      docs/clinical-tier1-curation-list-2026-05-12.md §2 (80 큐레이션)
--      + §4.1 P0 6 신규 (056a 적용 완료 전제) = 총 86 abbreviation.
--      카테고리별: Maitland 23 / Mulligan 16 / MFR 12 / TrP 13 / 운동 22.
--
--      AI 추천 시스템은 `is_active = true AND is_published = true` 인 row 만
--      후보로 사용(recommend.js 필터 가정). 본 마이그는 그 시드.
--
-- 멱등성·롤백:
--   1) UPDATE … SET is_published = false WHERE is_published = true   (전체 reset)
--   2) UPDATE … SET is_published = true  WHERE abbreviation IN (86)  (큐레이션 시드)
--   → 본 마이그는 재실행해도 동일 최종 상태(86 published)를 보장한다.
--   → 큐레이션 변경 시 본 파일의 abbreviation 리스트만 수정 후 재실행.
--
-- 전제: 056a 가 먼저 실행되어 lumbar P0 6 abbreviation 이 존재해야 한다.
--      누락 시 본 마이그가 ''86 매치'' 검증에서 EXCEPTION 으로 중단된다.
--
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- Author : sw-db-architect | 2026-05-12
-- ============================================================

BEGIN;

-- ----------------------------------------------------------------
-- 1) 전체 reset (안전) — 기존 published 일괄 해제
-- ----------------------------------------------------------------
UPDATE techniques
   SET is_published = false,
       updated_at   = NOW()
 WHERE is_published = true;


-- ----------------------------------------------------------------
-- 2) 86 큐레이션 is_published = true
-- ----------------------------------------------------------------
-- 카테고리별 분포 (총 86):
--   Maitland (category_joint_mobilization) : 23  (cervical 4 + shoulder 6 + knee 4 + hip 3 + ankle_foot 3 + lumbar 3 [056a])
--   Mulligan (category_mulligan)           : 16  (cervical 3 + shoulder 3 + knee 3 + hip 2 + ankle_foot 2 + lumbar 3 [056a])
--   MFR (category_mfr)                     : 12  (cervical 3 + lumbar 3 + shoulder 2 + knee 1 + hip 2 + ankle_foot 1)
--   TrP (category_trigger_point)           : 13  (cervical 4 + lumbar 3 + shoulder 2 + knee 1 + hip 2 + ankle_foot 1)
--   NM  (category_ex_neuromuscular)        : 8
--   RES (category_ex_resistance)           : 7
--   BW  (category_ex_bodyweight)           : 7   (운동 합계 22)

UPDATE techniques
   SET is_published = true,
       updated_at   = NOW()
 WHERE abbreviation IN (
   -- ──────────────────────────────────────────────────────────────
   -- §2.1 Maitland (category_joint_mobilization) — 23
   --   cervical 4
   'JM-CX-PA-C', 'JM-CX-PA-U', 'JM-CX-Rot', 'JM-CX-LatFx',
   --   shoulder 6
   'SH-JM-GHJ-INF', 'SH-JM-GHJ-POST', 'SH-JM-GHJ-ANT', 'SH-JM-GHJ-ABD',
   'SH-JM-STJ-INF', 'SH-JM-ACJ-PA',
   --   knee 4
   'KN-JM-TFJ-PA', 'KN-JM-TFJ-AP', 'KN-JM-PFJ-INF', 'KN-JM-PFJ-MED',
   --   hip 3
   'HIP-JM-TRACT', 'HIP-JM-AP', 'HIP-JM-INF',
   --   ankle_foot 3
   'ANK-JM-TCJ-PA', 'ANK-JM-TCJ-TRACT', 'ANK-JM-STJ-MED',
   --   lumbar 3 (056a 신규)
   'JM-LX-PA-C', 'JM-LX-PA-U', 'JM-LX-Rot',

   -- ──────────────────────────────────────────────────────────────
   -- §2.2 Mulligan (category_mulligan) — 16
   --   cervical 3
   'MUL-CX-SNAG-Rot', 'MUL-CX-SNAG-Ext', 'MUL-CX-SNAG-HA',
   --   shoulder 3
   'SH-MUL-FLEX', 'SH-MUL-ABD', 'SH-MUL-ER',
   --   knee 3
   'KN-MUL-FLEX', 'KN-MUL-EXT', 'KN-MUL-Pat',
   --   hip 2
   'HIP-MUL-FLEX', 'HIP-MUL-IR',
   --   ankle_foot 2
   'ANK-MUL-DF', 'ANK-MUL-INV',
   --   lumbar 3 (056a 신규)
   'MUL-LX-SNAG-Flex', 'MUL-LX-SNAG-Ext', 'MUL-LX-SLR-MWM',

   -- ──────────────────────────────────────────────────────────────
   -- §2.3 MFR (category_mfr) — 12
   --   cervical 3
   'MFR-Scalenes', 'MFR-LevScap', 'Suboccipital MFR',
   --   lumbar 3
   'Lumbar MFR', 'LumbMFR-Psoas', 'LumbMFR-Pir',
   --   shoulder 2
   'SH-MFR-PecMin', 'SH-MFR-Infra',
   --   knee 1
   'KN-MFR-Quad',
   --   hip 2
   'HIP-MFR-GluMed', 'HIP-MFR-Pir',
   --   ankle_foot 1
   'ANK-MFR-GastSol',

   -- ──────────────────────────────────────────────────────────────
   -- §2.4 TrP (category_trigger_point) — 13
   --   cervical 4
   'UT-TrP', 'LevScap-TrP', 'Scalenes-TrP', 'SubOcc-TrP',
   --   lumbar 3
   'QL-TPR', 'LumbTrP-MF', 'LumbTrP-Pir',
   --   shoulder 2
   'IS-TrP', 'SH-TrP-Sub',
   --   knee 1
   'KN-TrP-VMO',
   --   hip 2
   'HIP-TrP-TFL', 'HIP-TrP-GluMed',
   --   ankle_foot 1
   'ANK-TrP-Peron',

   -- ──────────────────────────────────────────────────────────────
   -- §2.5 NM (category_ex_neuromuscular) — 8
   'DCFT', 'CervPropRetraining', 'MCE',
   'SH-EX-NM-PNF-D2', 'SH-EX-NM-Proprio',
   'KN-EX-NM-SLB', 'HIP-EX-NM-PelvStab', 'ANK-EX-NM-SEBT',

   -- ──────────────────────────────────────────────────────────────
   -- §2.6 RES (category_ex_resistance) — 7
   'CervStrengthening',
   'SH-EX-RES-ER', 'SH-EX-RES-ScapRetract',
   'KN-EX-RES-TKE',
   'HIP-EX-RES-GluMed', 'HIP-EX-RES-GluMax',
   'ANK-EX-RES-Peron',

   -- ──────────────────────────────────────────────────────────────
   -- §2.7 BW (category_ex_bodyweight) — 7
   'McGill-Big3', 'GradedActivity',
   'SH-EX-BW-Pendulum', 'SH-EX-BW-WallSlide',
   'KN-EX-BW-MiniSquat',
   'HIP-EX-BW-Bridge', 'HIP-EX-BW-Clam'
 );


-- ----------------------------------------------------------------
-- 3) 검증 — published 카운트 86 일치 확인
-- ----------------------------------------------------------------
DO $$
DECLARE
  v_pub_count    INT;
  v_curated_hits INT;
  v_missing      TEXT;
BEGIN
  SELECT COUNT(*) INTO v_pub_count
    FROM techniques
   WHERE is_published = true;

  -- 큐레이션 86 중 실제 DB 에 존재하는 abbreviation 수
  SELECT COUNT(*) INTO v_curated_hits
    FROM techniques
   WHERE abbreviation IN (
     'JM-CX-PA-C','JM-CX-PA-U','JM-CX-Rot','JM-CX-LatFx',
     'SH-JM-GHJ-INF','SH-JM-GHJ-POST','SH-JM-GHJ-ANT','SH-JM-GHJ-ABD','SH-JM-STJ-INF','SH-JM-ACJ-PA',
     'KN-JM-TFJ-PA','KN-JM-TFJ-AP','KN-JM-PFJ-INF','KN-JM-PFJ-MED',
     'HIP-JM-TRACT','HIP-JM-AP','HIP-JM-INF',
     'ANK-JM-TCJ-PA','ANK-JM-TCJ-TRACT','ANK-JM-STJ-MED',
     'JM-LX-PA-C','JM-LX-PA-U','JM-LX-Rot',
     'MUL-CX-SNAG-Rot','MUL-CX-SNAG-Ext','MUL-CX-SNAG-HA',
     'SH-MUL-FLEX','SH-MUL-ABD','SH-MUL-ER',
     'KN-MUL-FLEX','KN-MUL-EXT','KN-MUL-Pat',
     'HIP-MUL-FLEX','HIP-MUL-IR',
     'ANK-MUL-DF','ANK-MUL-INV',
     'MUL-LX-SNAG-Flex','MUL-LX-SNAG-Ext','MUL-LX-SLR-MWM',
     'MFR-Scalenes','MFR-LevScap','Suboccipital MFR',
     'Lumbar MFR','LumbMFR-Psoas','LumbMFR-Pir',
     'SH-MFR-PecMin','SH-MFR-Infra',
     'KN-MFR-Quad',
     'HIP-MFR-GluMed','HIP-MFR-Pir',
     'ANK-MFR-GastSol',
     'UT-TrP','LevScap-TrP','Scalenes-TrP','SubOcc-TrP',
     'QL-TPR','LumbTrP-MF','LumbTrP-Pir',
     'IS-TrP','SH-TrP-Sub',
     'KN-TrP-VMO',
     'HIP-TrP-TFL','HIP-TrP-GluMed',
     'ANK-TrP-Peron',
     'DCFT','CervPropRetraining','MCE',
     'SH-EX-NM-PNF-D2','SH-EX-NM-Proprio',
     'KN-EX-NM-SLB','HIP-EX-NM-PelvStab','ANK-EX-NM-SEBT',
     'CervStrengthening',
     'SH-EX-RES-ER','SH-EX-RES-ScapRetract',
     'KN-EX-RES-TKE',
     'HIP-EX-RES-GluMed','HIP-EX-RES-GluMax',
     'ANK-EX-RES-Peron',
     'McGill-Big3','GradedActivity',
     'SH-EX-BW-Pendulum','SH-EX-BW-WallSlide',
     'KN-EX-BW-MiniSquat',
     'HIP-EX-BW-Bridge','HIP-EX-BW-Clam'
   );

  RAISE NOTICE '056b 결과 — is_published=true 카운트: % (기대 86)', v_pub_count;
  RAISE NOTICE '056b 결과 — 큐레이션 86 중 DB 매치: % (기대 86)', v_curated_hits;

  IF v_curated_hits <> 86 THEN
    -- 누락 abbreviation 식별 (056a 미실행 또는 본문 abbreviation 변경 의심)
    SELECT string_agg(quote_literal(a), ', ' ORDER BY a)
      INTO v_missing
      FROM (
        VALUES
          ('JM-CX-PA-C'),('JM-CX-PA-U'),('JM-CX-Rot'),('JM-CX-LatFx'),
          ('SH-JM-GHJ-INF'),('SH-JM-GHJ-POST'),('SH-JM-GHJ-ANT'),('SH-JM-GHJ-ABD'),('SH-JM-STJ-INF'),('SH-JM-ACJ-PA'),
          ('KN-JM-TFJ-PA'),('KN-JM-TFJ-AP'),('KN-JM-PFJ-INF'),('KN-JM-PFJ-MED'),
          ('HIP-JM-TRACT'),('HIP-JM-AP'),('HIP-JM-INF'),
          ('ANK-JM-TCJ-PA'),('ANK-JM-TCJ-TRACT'),('ANK-JM-STJ-MED'),
          ('JM-LX-PA-C'),('JM-LX-PA-U'),('JM-LX-Rot'),
          ('MUL-CX-SNAG-Rot'),('MUL-CX-SNAG-Ext'),('MUL-CX-SNAG-HA'),
          ('SH-MUL-FLEX'),('SH-MUL-ABD'),('SH-MUL-ER'),
          ('KN-MUL-FLEX'),('KN-MUL-EXT'),('KN-MUL-Pat'),
          ('HIP-MUL-FLEX'),('HIP-MUL-IR'),
          ('ANK-MUL-DF'),('ANK-MUL-INV'),
          ('MUL-LX-SNAG-Flex'),('MUL-LX-SNAG-Ext'),('MUL-LX-SLR-MWM'),
          ('MFR-Scalenes'),('MFR-LevScap'),('Suboccipital MFR'),
          ('Lumbar MFR'),('LumbMFR-Psoas'),('LumbMFR-Pir'),
          ('SH-MFR-PecMin'),('SH-MFR-Infra'),
          ('KN-MFR-Quad'),
          ('HIP-MFR-GluMed'),('HIP-MFR-Pir'),
          ('ANK-MFR-GastSol'),
          ('UT-TrP'),('LevScap-TrP'),('Scalenes-TrP'),('SubOcc-TrP'),
          ('QL-TPR'),('LumbTrP-MF'),('LumbTrP-Pir'),
          ('IS-TrP'),('SH-TrP-Sub'),
          ('KN-TrP-VMO'),
          ('HIP-TrP-TFL'),('HIP-TrP-GluMed'),
          ('ANK-TrP-Peron'),
          ('DCFT'),('CervPropRetraining'),('MCE'),
          ('SH-EX-NM-PNF-D2'),('SH-EX-NM-Proprio'),
          ('KN-EX-NM-SLB'),('HIP-EX-NM-PelvStab'),('ANK-EX-NM-SEBT'),
          ('CervStrengthening'),
          ('SH-EX-RES-ER'),('SH-EX-RES-ScapRetract'),
          ('KN-EX-RES-TKE'),
          ('HIP-EX-RES-GluMed'),('HIP-EX-RES-GluMax'),
          ('ANK-EX-RES-Peron'),
          ('McGill-Big3'),('GradedActivity'),
          ('SH-EX-BW-Pendulum'),('SH-EX-BW-WallSlide'),
          ('KN-EX-BW-MiniSquat'),
          ('HIP-EX-BW-Bridge'),('HIP-EX-BW-Clam')
      ) AS s(a)
      WHERE a NOT IN (SELECT abbreviation FROM techniques WHERE abbreviation IS NOT NULL);
    RAISE EXCEPTION '056b 실패 — 큐레이션 86 중 누락 abbreviation: %', COALESCE(v_missing, '(none)');
  END IF;

  IF v_pub_count <> 86 THEN
    RAISE EXCEPTION '056b 실패 — is_published=true 카운트 불일치 (기대 86, 실제 %)', v_pub_count;
  END IF;
END $$;

COMMIT;

-- ============================================================
-- END OF MIGRATION 056b
-- ============================================================
