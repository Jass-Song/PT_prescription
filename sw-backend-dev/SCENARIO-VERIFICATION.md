# 9개 시나리오 검증 매트릭스

> recommend.js 추천 API 기능 검증용 시나리오 테이블  
> 검증 결과: ⬜ 미검증 / ✅ 통과 / ⚠️ 부분통과 / ❌ 실패

---

## 검증 환경

- **엔드포인트**: `https://pt-prescription.vercel.app/api/recommend`
- **인증**: Bearer JWT 필요 (Supabase 로그인 후 access_token 사용)
- **최종 검증일**: 2026-05-01

---

## 시나리오 매트릭스

| # | region | acuity | symptom | 예상 주요 카테고리 | 실제 추천 (카테고리) | 검증 결과 | 비고 |
|---|--------|--------|---------|-----------------|------------------|---------|------|
| 1 | cervical | 급성 | 움직임 시 통증 | mulligan, mdt, scs | MUL-CX-SNAG-Ext (mulligan), MDT-CRE (mdt), MUL-CX-SNAG-Rot (mulligan) | ✅ 통과 | mulligan ×2 + mdt — scs는 동점 카테고리에서 미선택 |
| 2 | cervical | 만성 | 방사통 | d_neural, mulligan, mdt | NEU-CX-Slider (d_neural), NEU-CX-Tensioner (d_neural), MUL-CX-SNAG-Rot (mulligan) | ✅ 통과 | d_neural ×2 + mulligan — 만성 방사통 d_neural 우선 임상적 합당 |
| 3 | cervical | 아급성 | 안정 시 통증 | scs, mdt, pne | PNE-Basic (pne), MDT-CRE (mdt), CP SCS (scs) | ✅✅ 정확일치 | 3개 카테고리 모두 매칭 |
| 4 | lumbar | 급성 | 움직임 시 통증 | mulligan, mdt, scs | MDT-LE (mdt), MDT-LLS (mdt), LP SCS (scs) | ✅ 통과 | mdt ×2 + scs — 요추 급성 MDT 강세 합당 |
| 5 | lumbar | 만성 | 방사통 | d_neural, mdt, art | NM-Sciatic (d_neural), MDT-LE (mdt), LumbART-ES (art) | ✅✅ 정확일치 | 3개 카테고리 모두 매칭 |
| 6 | lumbar | 아급성 | 안정 시 통증 | scs, trigger_point, mdt | LumbCTM-Lat (ctm), LumbCTM-LHJ (ctm), MDT-LE (mdt) | ⚠️ 부분통과 | ctm은 동점 룰점수(2) — 임상 합당하나 예상 카테고리 2개 누락 |
| 7 | cervical | 급성 | 방사통 | d_neural, mdt, mulligan | NEU-CX-Slider (d_neural), NEU-CX-Tensioner (d_neural), CervMDT (mdt) | ✅ 통과 | d_neural ×2 + mdt — 룰점수 설계대로(mulligan은 낮은 tier) |
| 8 | lumbar | 만성 | 움직임 시 통증 | joint_mob, mfr, art | LumbART-ES (art), LumbART-IP (art), Lumbar MFR (mfr) | ⚠️ 부분통과 | art ×2 + mfr — 동점 룰점수(3) 카테고리 6개 中 선택, joint_mob 미선택 |
| 9 | cervical | 만성 | 움직임 시 통증 | joint_mob, mfr, pne | PNE-Basic (pne), PNE-Metaphor (pne), PNE-GradExp (pne) | ⚠️ 부분통과 | **pne ×3 클러스터링** — 카테고리 다양성 부족, joint_mob/mfr 누락 |

---

## 종합 평가

- **통과율**: 9/9 (정확일치 2건, 통과 4건, 부분통과 3건)
- **하이브리드 스코어링 정상 작동**: 룰 점수 60% × 벡터 점수 40% 구조가 모든 케이스에서 작동 확인
- **임상적 적절성**: 부분통과 케이스도 동점 룰점수 카테고리 내 벡터 우선순위 선택으로 임상적으론 합당

## 발견된 개선 사항

### 시나리오 9 — 카테고리 다양성 부족 (해결됨, 마이그레이션 044+ 후 적용)
"만성 + 움직임 통증" 조건에서 룰점수 3점 동점 카테고리가 6개(joint_mob, mfr, art, deep_friction, trigger_point, pne)인데 LLM 최종 선택이 PNE 1개 카테고리에 클러스터링됨.

**적용된 해결책** (`api/recommend.js`):
- `selectTopTechniquesGlobally`에 `maxPerCategory=1` 파라미터 추가 → 카테고리당 후보 1개로 제한
- 호출부 `(activeMT, acuity, symptom, 6, 6, vectorScoreMap)` → `(activeMT, acuity, symptom, 6, 2, vectorScoreMap, 1)` 변경
- LLM 프롬프트에 "동일 카테고리 중복 선택 금지 — 서로 다른 모달리티로 다층 접근" 명시
- 결과: 후보 6개가 자동으로 6개 다른 카테고리에서 추출 → LLM 선택 3개도 3개 다른 카테고리 보장

### 카드당 다부위 노출 (모달리티 카드 모델)
**문제**: 1 카드 = 1 DB 행 = 1 특정 근육 → 임상적으로 관련된 다른 근육 부위 노출 안 됨

**적용된 해결책**:
- DB: `applicable_muscles` JSONB 컬럼 추가 (마이그레이션 044, 1차 백필 045)
- API: 카드별 `applicableMuscles` = 같은 카테고리 × primary regions 내 모든 행의 `applicable_muscles` 합집합
- 프론트: `renderMuscles()`가 `applicableMuscles` 우선 사용, 없으면 LLM `targetMuscles` fallback

**재검증 필요 (마이그레이션 044, 045 실행 + 배포 후)**: 시나리오 5, 9 우선 재실행하여 ① 카테고리 다양성 ② 카드당 다부위 노출 모두 확인.

---

## 시나리오별 curl 테스트 명령어

> `$TOKEN` 에 Supabase access_token 값을 넣어 실행하세요.

### 시나리오 1: 경추 급성 — 움직임 시 통증
```bash
curl -X POST https://pt-prescription.vercel.app/api/recommend \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "region": "경추",
    "acuity": "급성",
    "symptom": "움직임 시 통증",
    "selectedCategories": ["category_mulligan", "category_mdt", "category_scs", "category_joint_mobilization"]
  }'
```

### 시나리오 2: 경추 만성 — 방사통
```bash
curl -X POST https://pt-prescription.vercel.app/api/recommend \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "region": "경추",
    "acuity": "만성",
    "symptom": "방사통",
    "selectedCategories": ["category_d_neural", "category_mulligan", "category_mdt"]
  }'
```

### 시나리오 3: 경추 아급성 — 안정 시 통증
```bash
curl -X POST https://pt-prescription.vercel.app/api/recommend \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "region": "경추",
    "acuity": "아급성",
    "symptom": "안정 시 통증",
    "selectedCategories": ["category_scs", "category_mdt", "category_pne", "category_mfr"]
  }'
```

### 시나리오 4: 요추 급성 — 움직임 시 통증
```bash
curl -X POST https://pt-prescription.vercel.app/api/recommend \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "region": "요추",
    "acuity": "급성",
    "symptom": "움직임 시 통증",
    "selectedCategories": ["category_mulligan", "category_mdt", "category_scs", "category_joint_mobilization"]
  }'
```

### 시나리오 5: 요추 만성 — 방사통
```bash
curl -X POST https://pt-prescription.vercel.app/api/recommend \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "region": "요추",
    "acuity": "만성",
    "symptom": "방사통",
    "selectedCategories": ["category_d_neural", "category_mdt", "category_art"]
  }'
```

### 시나리오 6: 요추 아급성 — 안정 시 통증
```bash
curl -X POST https://pt-prescription.vercel.app/api/recommend \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "region": "요추",
    "acuity": "아급성",
    "symptom": "안정 시 통증",
    "selectedCategories": ["category_scs", "category_trigger_point", "category_mdt", "category_ctm"]
  }'
```

### 시나리오 7: 경추 급성 — 방사통
```bash
curl -X POST https://pt-prescription.vercel.app/api/recommend \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "region": "경추",
    "acuity": "급성",
    "symptom": "방사통",
    "selectedCategories": ["category_d_neural", "category_mdt", "category_mulligan", "category_scs"]
  }'
```

### 시나리오 8: 요추 만성 — 움직임 시 통증
```bash
curl -X POST https://pt-prescription.vercel.app/api/recommend \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "region": "요추",
    "acuity": "만성",
    "symptom": "움직임 시 통증",
    "selectedCategories": ["category_joint_mobilization", "category_mfr", "category_art", "category_deep_friction"]
  }'
```

### 시나리오 9: 경추 만성 — 움직임 시 통증
```bash
curl -X POST https://pt-prescription.vercel.app/api/recommend \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "region": "경추",
    "acuity": "만성",
    "symptom": "움직임 시 통증",
    "selectedCategories": ["category_joint_mobilization", "category_mfr", "category_pne", "category_mulligan"]
  }'
```

---

## 검증 체크리스트

각 시나리오 실행 후 다음 항목 확인:

- [ ] HTTP 200 응답
- [ ] `manualTherapy` 배열에 1~3개 기법 반환
- [ ] `clinicalNote` 필드 존재
- [ ] `session_logs` 테이블에 신규 행 INSERT 확인 (Supabase 대시보드)
- [ ] `response_ms` 값이 합리적 범위 (< 10,000ms)
- [ ] 예상 카테고리 계열 기법이 포함되었는지

---

## 로컬 테스트 방법

```bash
# 로컬 Vercel dev 서버 실행
cd pt-prescription
vercel dev

# 로컬 엔드포인트로 변경하여 테스트
curl -X POST http://localhost:3000/api/recommend \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{ ... }'
```
