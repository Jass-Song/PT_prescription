# Supabase 설정 가이드 — KMO SaaS

생성일: 2026-04-24

---

## 현황 요약

| 항목 | 상태 | 비고 |
|------|------|------|
| Supabase 프로젝트 | 연결됨 | gnusyjnviugpofvaicbv |
| techniques 테이블 | **없음** | schema.sql 실행 필요 |
| 시드 데이터 | 대기 중 | 테이블 생성 후 migrate.js 실행 |
| anon key INSERT | RLS 제한 | service_role key 또는 대시보드 필요 |

---

## STEP 1: schema.sql 실행 (대시보드)

> anon key로는 DDL(CREATE TABLE, CREATE TYPE 등) 실행 불가.
> Supabase 대시보드 SQL 에디터를 사용합니다.

1. [https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql/new](https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql/new) 접속
2. 좌측 상단 `New query` 클릭
3. `.jarvis/saas/schema.sql` 파일 전체 내용 붙여넣기
4. `Run` (Ctrl+Enter) 클릭
5. 하단에 `Success. No rows returned` 확인

**포함 내용:**
- ENUM 타입 4개 (technique_category, evidence_level, body_region, rating_outcome, tag_type)
- 테이블 8개 (techniques, technique_tags, ratings, technique_stats, usage_logs, user_favorites, user_profiles, community_cases)
- 인덱스, 뷰, 함수, 트리거, RLS 정책
- technique_tags 초기 태그 데이터 (목적/대상/증상/금기 35개)

---

## STEP 2: service_role key 확인

> 시드 데이터 삽입 시 RLS를 우회하려면 service_role key가 필요합니다.

1. [https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/settings/api](https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/settings/api) 접속
2. `Project API keys` 섹션에서 `service_role` key 복사
3. 아래 STEP 3에서 사용

---

## STEP 3: 시드 데이터 삽입

### 방법 A: Node.js 스크립트 (권장)

schema.sql 실행 완료 후:

```bash
cd "C:/project/PT/KMovement Optimism"

# service_role key로 실행 (RLS 우회)
SUPABASE_SERVICE_KEY=<service_role_key> node .jarvis/saas/migrate.js

# 또는 대시보드에서 schema.sql 실행 완료 + RLS 임시 비활성화 후 anon key로
SEED_ONLY=true node .jarvis/saas/migrate.js
```

### 방법 B: 대시보드 SQL 에디터

1. `.jarvis/saas/seed.sql` 파일 전체 내용 복사
2. SQL 에디터에 붙여넣고 `Run`
3. `42 rows affected` 확인

---

## STEP 4: 완료 확인

SQL 에디터에서 실행:

```sql
-- 테이블 수 확인
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- techniques 시드 확인
SELECT name_ko, category, body_region, evidence_level
FROM techniques
ORDER BY created_at
LIMIT 10;

-- technique_tags 확인
SELECT tag_type, COUNT(*) FROM technique_tags GROUP BY tag_type;
```

예상 결과:
- 테이블 8개
- techniques 42개
- technique_tags 35개

---

## RLS 정책 요약

| 테이블 | SELECT | INSERT | UPDATE | DELETE |
|--------|--------|--------|--------|--------|
| techniques | 인증 사용자 모두 | is_verified=true | 본인 생성만 | - |
| ratings | 본인 또는 공유됨 | 본인만 | 본인만 | 본인만 |
| usage_logs | 본인만 | 본인만 | - | - |
| user_favorites | 본인만 | 본인만 | 본인만 | 본인만 |
| user_profiles | 인증 사용자 모두 | 본인만 | 본인만 | - |
| community_cases | 공개 또는 본인 | 본인만 | 본인만 | 본인만 |

> 시드 데이터(techniques)는 `is_published=false`로 삽입됩니다.
> 공개 전환: `UPDATE techniques SET is_published=true WHERE id='...'`

---

## 트러블슈팅

### "relation does not exist" 오류
schema.sql이 실행되지 않은 상태입니다. STEP 1을 먼저 완료하세요.

### "new row violates row-level security policy" 오류
anon key로 INSERT 시도 시 발생합니다. service_role key 사용 또는 대시보드 SQL 에디터로 seed.sql을 직접 실행하세요.

### "type already exists" 오류
이미 schema.sql을 일부 실행한 경우입니다. `DROP TYPE ... CASCADE` 후 재실행하거나, seed.sql만 실행하세요.
