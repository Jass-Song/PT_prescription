-- ============================================================
-- Migration 011 — 기법 평가 테이블 생성
-- K-Movement Optimism — PT Prescription Feedback System
-- 생성일: 2026-04-25
-- 실행: https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql
-- ============================================================
-- 목적:
--   추천된 기법에 대해 치료사가 임상 환경(부위·시기·증상)별 평가를 저장
--   데이터 누적 후 알고리즘 pre-filter 전환 여부 판단 기준으로 활용
--
-- 전환 기준 (50건 누적 도달 시 알림 권고):
--   · 특정 기법 × 특정 환경(region+acuity) 피드백 ≥ 5건 + 평균 rating ≥ 4.0
--     → 해당 환경의 가중치 신뢰 가능 판단
--   · 전체 feedback 누적 ≥ 50건
--     → 알고리즘 pre-filter 전환 검토 시점
-- ============================================================

CREATE TABLE IF NOT EXISTS technique_feedback (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  technique  TEXT NOT NULL,       -- 기법 한국어 명칭
  category   TEXT,                -- category_key (ex: category_joint_mobilization)
  region     TEXT,                -- 경추 / 요추
  acuity     TEXT,                -- 급성 / 아급성 / 만성
  symptom    TEXT,                -- 움직임 시 통증 / 안정 시 통증 / 방사통
  rating     INTEGER CHECK (rating BETWEEN 1 AND 5),
  notes      TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS 활성화
ALTER TABLE technique_feedback ENABLE ROW LEVEL SECURITY;

-- anon 키로 INSERT 허용 (치료사가 로그인 없이 평가 저장)
CREATE POLICY "anon_insert" ON technique_feedback
  FOR INSERT TO anon WITH CHECK (true);

-- 인증된 사용자만 SELECT 허용 (관리자 분석용)
CREATE POLICY "auth_select" ON technique_feedback
  FOR SELECT TO authenticated USING (true);

-- ============================================================
-- 검증 쿼리 (실행 후 확인)
-- SELECT * FROM technique_feedback LIMIT 5;
-- ============================================================
