# BETA-DB-CHECKLIST — DB Check Before Beta Launch

> Created: 2026-04-30  
> Author: sw-db-architect  
> Purpose: Migration 041 execution guide + is_published status query + bulk update SQL

---

## 1. Migration 041 Execution Guide

### Summary
`041-ratings-table.sql` is a migration that **creates the ratings table**.

| Item | Details |
|------|------|
| File | `saas/migrations/041-ratings-table.sql` |
| Purpose | Store per-user technique star rating evaluations (Phase 1 completion) |
| Background | `api/history.js` queries ratings but the table was missing → "⭐ Highly Rated Techniques" tab 500 error |
| Existing data | `technique_feedback` (011) table is preserved — not deleted |

### What Gets Created
- **Table**: `ratings` (user_id FK + technique_id FK + star_rating 1~5)
- **RLS policies**: `ratings_select_own` + `ratings_insert_own` (per-user isolation)
- **3 indexes**: `idx_ratings_user_created`, `idx_ratings_user_star`, `idx_ratings_technique`

### Key Columns
```sql
CREATE TABLE IF NOT EXISTS ratings (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  technique_id    uuid REFERENCES techniques(id) ON DELETE SET NULL,
  technique_label text NOT NULL,   -- fallback when no techniques row exists
  category_key    text,
  region          text,
  acuity          text,
  symptom         text,
  star_rating     integer NOT NULL CHECK (star_rating BETWEEN 1 AND 5),
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now()
);
```

### Execution Steps (Supabase SQL Editor)

> ⚠️ This migration requires **manual execution** — cannot be run via automation scripts

1. Open Supabase Dashboard  
   → `https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv`
2. Left menu → click **SQL Editor**
3. Click **New Query** button
4. Copy and paste the entire contents of `saas/migrations/041-ratings-table.sql`
5. Click **Run** (or Cmd/Ctrl + Enter)
6. Confirm the completion message, then run the validation queries below

### Re-execution Safety

- `CREATE TABLE IF NOT EXISTS` — no error even if table already exists
- `DROP POLICY IF EXISTS` + `CREATE POLICY` — no error even if policy already exists
- `CREATE INDEX IF NOT EXISTS` — no error even if index already exists
- **Conclusion: safe to run multiple times**

---

## 2. is_published Status Query

### Background
- `techniques` table's `is_published` column: `BOOLEAN DEFAULT false`
- RLS policy (005b): `is_published = true OR auth.uid() IS NOT NULL`
- Unauthenticated (anon key) users cannot access techniques where `is_published = false`
- **Migration 012** (2026-04-26) updated all `is_published = false` records to `true`
- All INSERTs after migration 013 are inserted with `is_published = true` (confirmed)

### Status Query (run in Supabase SQL Editor)

```sql
-- 1. Aggregate is_published status
SELECT is_published, COUNT(*) as count 
FROM techniques 
GROUP BY is_published;
```

```sql
-- 2. List of techniques where is_published = false (check names if any exist)
SELECT name_ko, name_en, category_key 
FROM techniques 
WHERE is_published = false 
ORDER BY category_key, name_ko;
```

```sql
-- 3. Published status by category
SELECT category_key, COUNT(*) as total,
       SUM(CASE WHEN is_published = true THEN 1 ELSE 0 END) as published,
       SUM(CASE WHEN is_published = false THEN 1 ELSE 0 END) as unpublished
FROM techniques
GROUP BY category_key
ORDER BY category_key;
```

---

## 3. Bulk Update SQL

> ⚠️ **Must re-confirm the list using the query above before executing**

```sql
-- Publish all techniques with is_published = false before beta launch
-- Before executing: confirm target list with the query above

UPDATE techniques 
SET is_published = true 
WHERE is_published = false;
```

> **Expected**: Since all INSERTs after migration 012 were inserted as `true`, this query will likely affect 0 rows. If the query result is 0 rows, execution is not needed.

---

## 4. Three Validation Queries

### Validation 1 — Confirm ratings table creation

```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'ratings';
```
**Expected result**: 1 row returned for `ratings`

### Validation 2 — Confirm ratings RLS policies

```sql
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'ratings';
```
**Expected result**: 2 policies — `ratings_select_own` (SELECT), `ratings_insert_own` (INSERT)

### Validation 3 — Confirm all techniques are published

```sql
SELECT is_published, COUNT(*) as count 
FROM techniques 
GROUP BY is_published;
```
**Expected result**: Only `is_published = true` rows exist, 0 rows with `false`

---

## 5. Execution Order Checklist

- [ ] Verify access to Supabase SQL Editor
- [ ] Execute **041-ratings-table.sql**
- [ ] Run Validation 1 → confirm ratings table exists
- [ ] Run Validation 2 → confirm 2 RLS policies
- [ ] Run status query (section 2) → check list of is_published = false
- [ ] If false count > 0, run bulk update SQL
- [ ] Run Validation 3 → confirm all techniques have is_published = true

---

## 6. Reference — Supabase Project Information

| Item | Value |
|------|---|
| Project URL | `https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv` |
| SQL Editor | `https://supabase.com/dashboard/project/gnusyjnviugpofvaicbv/sql` |
| Migration file | `pt-prescription/saas/migrations/041-ratings-table.sql` |
