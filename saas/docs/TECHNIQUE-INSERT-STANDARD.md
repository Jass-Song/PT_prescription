# TECHNIQUE-INSERT-STANDARD.md

PT 처방 도우미 — 신규 기법 마이그레이션 SQL 표준 명세서  
모든 `INSERT INTO techniques` 구문은 아래 표준을 반드시 따라야 한다.

---

## 1. 필수 컬럼 목록

| 순서 | 컬럼명 | 타입 | 설명 |
|------|--------|------|------|
| 1 | `category` | TEXT | category_key 문자열 (예: `'category_joint_mobilization'`) |
| 2 | `category_id` | UUID | 서브쿼리로 조회 — 직접 UUID 입력 금지 |
| 3 | `subcategory` | TEXT | 기법 분류 소제목 (예: `'Maitland — GHJ'`) |
| 4 | `name_ko` | TEXT | 한국어 기법명 |
| 5 | `name_en` | TEXT | 영어 기법명 |
| 6 | `abbreviation` | TEXT | ON CONFLICT 키 — 명명 규칙 참고 (§8) |
| 7 | `body_region` | body_region ENUM | ENUM 캐스트 필수 (예: `'shoulder'::body_region`) |
| 8 | `body_segment` | TEXT | 세부 해부학 구조 (예: `'GHJ 후방 관절낭'`) |
| 9 | `patient_position` | TEXT | 환자 포지션 — 허용 용어 참고 (§안전 규칙) |
| 10 | `therapist_position` | TEXT | 치료사 포지션 설명 |
| 11 | `contact_point` | TEXT | 접촉 부위 설명 |
| 12 | `direction` | TEXT | 가동 방향 설명 |
| 13 | `technique_steps` | JSONB | 5단계 JSON 배열 — §2 형식 준수 |
| 14 | `purpose_tags` | TEXT[] | 치료 목적 태그 — §3 형식 |
| 15 | `target_tags` | TEXT[] | 적용 시기 태그 — §3 형식 |
| 16 | `symptom_tags` | TEXT[] | 적응 증상 태그 — §3 형식 |
| 17 | `contraindication_tags` | TEXT[] | 금기 태그 — §3 형식 |
| 18 | `evidence_level` | evidence_level ENUM | §4 허용 값 |
| 19 | `clinical_notes` | TEXT | 임상 팁 — 단정 표현 금지, "~할 수 있다" 형식 |
| 20 | `absolute_contraindications` | TEXT | 절대 금기 (쉼표 구분 문자열) |
| 21 | `relative_contraindications` | TEXT | 상대 금기 (쉼표 구분 문자열) |
| 22 | `is_active` | BOOLEAN | `true` |
| 23 | `is_published` | BOOLEAN | `true` |

---

## 2. technique_steps JSONB 형식

- 반드시 **5단계** (step 1–5)
- 각 단계: `{"step": N, "instruction": "한국어 설명 텍스트"}`
- 전체 배열: `'[{...},{...},{...},{...},{...}]'::jsonb`

```sql
'[
  {"step":1,"instruction":"첫 번째 단계 설명."},
  {"step":2,"instruction":"두 번째 단계 설명."},
  {"step":3,"instruction":"세 번째 단계 설명."},
  {"step":4,"instruction":"네 번째 단계 설명."},
  {"step":5,"instruction":"다섯 번째 단계 설명."}
]'::jsonb
```

> 주의: instruction 텍스트 안에 홑따옴표(`'`)가 포함되면 반드시 `''`(이중)로 이스케이프해야 한다. §7 SQL 안전 규칙 참고.

---

## 3. Tags 배열 형식

PostgreSQL TEXT 배열 문자열 표기법:

```sql
'{"tag1","tag2","tag3"}'
```

빈 태그 배열: `'{}'`  
단일 태그: `'{"tag1"}'`

### 권장 태그 값

**purpose_tags:**
- `pain_relief`, `rom_improvement`, `functional_improvement`, `tissue_remodeling`
- `trigger_point_release`, `neurodynamic_mobilization`, `patient_education`

**target_tags (적용 시기):**
- `acute`, `subacute`, `chronic`

**symptom_tags:** 자유 형식 영문 snake_case (예: `shoulder_pain`, `flexion_restriction`)

**contraindication_tags:** 금기 키워드 영문 snake_case (예: `fracture`, `joint_infection`)

---

## 4. evidence_level 허용 값

| 값 | 의미 | 주로 사용하는 카테고리 |
|----|------|----------------------|
| `level_1a` | 체계적 고찰 + 메타분석 | — |
| `level_1b` | 단일 RCT | — |
| `level_2a` | 준실험 연구 | — |
| `level_2b` | 코호트·케이스 시리즈 | JM, Mulligan |
| `level_3` | 케이스 리포트 | DFM (심부마찰) |
| `level_4` | 전문가 의견 / 케이스 시리즈 | MFR, ART, CTM, TrP |
| `level_5` | 전통적 관례 | — |
| `expert_consensus` | 전문가 합의 | PNE, MDT 일부 |

사용 예시: `'level_2b'::evidence_level`

---

## 5. body_region 허용 값

| ENUM 값 | 한국어 |
|---------|--------|
| `cervical` | 경추 |
| `thoracic` | 흉추 |
| `lumbar` | 요추 |
| `sacroiliac` | 천장관절 |
| `shoulder` | 어깨 관절 |
| `elbow` | 팔꿈치 관절 |
| `wrist_hand` | 손목·손 |
| `hip` | 엉덩 관절 |
| `knee` | 무릎 관절 |
| `ankle_foot` | 발목 관절 |
| `full_body` | 전신 |
| `NULL` | 범용 기법 (특정 부위 없음) |

사용 예시: `'shoulder'::body_region`  
범용: `NULL`로 사용 (ENUM 캐스트 없음)

---

## 6. ON CONFLICT 패턴 (필수)

모든 INSERT 뒤에 반드시 아래 패턴을 붙여야 한다. (idempotent 재실행 보장)

```sql
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();
```

---

## 7. SQL 안전 규칙

### 홑따옴표 이스케이프 (가장 흔한 실수)

SQL 문자열 리터럴 내부에서 `'`(홑따옴표)는 반드시 `''`(이중)로 이스케이프해야 한다.

```sql
-- ❌ 잘못된 예 (syntax error 발생)
'NRS 4~5 수준의 '시원하게 아픈' 느낌이 적절하다.'

-- ✅ 올바른 예
'NRS 4~5 수준의 ''시원하게 아픈'' 느낌이 적절하다.'
```

주로 문제 발생 위치:
- `technique_steps` → `instruction` 값 안에 한글 인용 표현이 있을 때
- `clinical_notes` 안에 인용 표현이 있을 때

### 환자 포지션 금지·허용 표현

| 금지 (옛 의학 용어) | 허용 (쉬운 한국어) |
|-------------------|-----------------|
| 앙와위 | 바로 눕기 |
| 측와위 | 옆으로 눕기 |
| 복와위 | 엎드려 눕기 |
| 좌위 | 앉은 자세 |

### clinical_notes 문체 규칙

단정 표현 금지, 반드시 가능성 표현 사용:

| 금지 | 허용 |
|------|------|
| "효과적이다" | "효과를 기대할 수 있다" |
| "원인이다" | "원인일 수 있다" |
| "치료된다" | "개선될 가능성이 있다" |

---

## 8. abbreviation 명명 규칙

형식: `[부위코드]-[카테고리코드]-[세부명]`

### 부위 코드

| 부위 | 코드 |
|------|------|
| 어깨 관절 | `SH` |
| 무릎 관절 | `KN` |
| 엉덩 관절 | `HIP` |
| 발목 관절 | `ANK` |
| 경추 | `CERV` |
| 요추 | `LUMB` |

### 카테고리 코드

| 카테고리 | 코드 |
|---------|------|
| Maitland JM | `JM` |
| Mulligan | `MUL` |
| MFR | `MFR` |
| ART | `ART` |
| CTM | `CTM` |
| 심부마찰(DFM) | `DFM` |
| 트리거포인트 | `TrP` |

### 예시

```
SH-JM-GHJ-POST   → 어깨-JM-GHJ후방
KN-MUL-FLEX      → 무릎-Mulligan-굴곡
HIP-MFR-Psoas    → 엉덩-MFR-장요근
ANK-TrP-Gast     → 발목-TrP-비복근
DFM-AchillesTend → 아킬레스건 심부마찰 (부위 생략 가능)
ART-PsoasHip     → 장요근 ART (부위 생략 가능)
```

---

## 9. 완성 기법 INSERT 예시 (SH-JM-GHJ-POST)

```sql
INSERT INTO techniques (
  category, category_id, subcategory,
  name_ko, name_en, abbreviation,
  body_region, body_segment,
  patient_position, therapist_position, contact_point, direction,
  technique_steps,
  purpose_tags, target_tags, symptom_tags, contraindication_tags,
  evidence_level, clinical_notes,
  absolute_contraindications, relative_contraindications,
  is_active, is_published
) VALUES (
  'category_joint_mobilization',
  (SELECT id FROM technique_categories WHERE category_key = 'category_joint_mobilization'),
  'Maitland — GHJ',
  '견관절 GHJ 후방 글라이드', 'Shoulder Posterior GHJ Glide', 'SH-JM-GHJ-POST',
  'shoulder'::body_region, 'GHJ 후방 관절낭',
  '옆으로 눕기(환측 위) 또는 앉은 자세, 팔 몸통 옆에 편히 이완',
  '환자 옆쪽 또는 뒤쪽에 위치하여 상완골두 전방면에 엄지 또는 손바닥 접촉 준비',
  '상완골두 전방면 (엄지 또는 손바닥)',
  '전방 PA 글라이드 (Grade I–IV)',
  '[{"step":1,"instruction":"환자를 환측이 위로 향하는 옆으로 눕기 또는 앉은 자세로 위치시키고, 팔이 몸통 옆에서 편안하게 이완되도록 한다."},{"step":2,"instruction":"치료사는 환자 옆쪽 또는 뒤쪽에 서서 한 손으로 견갑골 후방면을 가볍게 안정화하고, 반대 손 엄지 또는 손바닥을 상완골두 전방면에 부드럽게 접촉한다."},{"step":3,"instruction":"Grade에 따라 힘을 조절한다. Grade I–II는 관절 저항이 느껴지기 전 범위에서 소진폭 리듬 가동, Grade III–IV는 관절 끝 범위에서 대진폭 또는 소진폭 가동을 적용한다."},{"step":4,"instruction":"상완골두를 전방 방향으로 리듬감 있게 밀어주며, 관절낭의 이완 반응을 촉진한다. 시술 중 환자의 통증 및 저항 변화를 지속적으로 확인한다."},{"step":5,"instruction":"30초–1분 시술 후 재평가하여 외전과 바깥쪽으로 돌리기 범위의 변화를 확인한다. 필요 시 Grade 조정 후 2–3세트 반복한다."}]'::jsonb,
  '{"pain_relief","rom_improvement"}',
  '{"subacute","chronic"}',
  '{"shoulder_pain","external_rotation_restriction","abduction_restriction"}',
  '{"fracture","joint_infection","malignancy","acute_inflammation"}',
  'level_2b'::evidence_level,
  '후방 관절낭 단축이 의심될 때 적용 가능성이 높다. Grade I–II는 통증 억제 효과를 기대할 수 있고, Grade III–IV는 관절낭 이완 및 ROM 회복을 목표로 할 수 있다. 유착성 관절낭염 아급성기에 가장 많이 활용되는 기법 중 하나일 수 있다.',
  'fracture, joint_infection, malignancy',
  'acute_inflammation, severe_osteoporosis, anticoagulant_therapy',
  true, true
)
ON CONFLICT (abbreviation) WHERE abbreviation IS NOT NULL DO UPDATE SET
  name_ko = EXCLUDED.name_ko, name_en = EXCLUDED.name_en,
  body_region = EXCLUDED.body_region, technique_steps = EXCLUDED.technique_steps,
  purpose_tags = EXCLUDED.purpose_tags, target_tags = EXCLUDED.target_tags,
  symptom_tags = EXCLUDED.symptom_tags, contraindication_tags = EXCLUDED.contraindication_tags,
  evidence_level = EXCLUDED.evidence_level, clinical_notes = EXCLUDED.clinical_notes,
  absolute_contraindications = EXCLUDED.absolute_contraindications,
  relative_contraindications = EXCLUDED.relative_contraindications,
  is_published = EXCLUDED.is_published, updated_at = NOW();
```

---

*최종 업데이트: 2026-04-28 — sw-db-architect*
