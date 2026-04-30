# 9개 시나리오 검증 매트릭스

> recommend.js 추천 API 기능 검증용 시나리오 테이블  
> 검증 결과: ⬜ 미검증 / ✅ 통과 / ❌ 실패

---

## 검증 환경

- **엔드포인트**: `https://pt-prescription.vercel.app/api/recommend`
- **인증**: Bearer JWT 필요 (Supabase 로그인 후 access_token 사용)
- **최종 업데이트**: 2026-04-30

---

## 시나리오 매트릭스

| # | region | acuity | symptom | 예상 주요 카테고리 | 검증 결과 | 비고 |
|---|--------|--------|---------|-----------------|---------|------|
| 1 | cervical | 급성 | 움직임 시 통증 | mulligan, mdt, scs | ⬜ 미검증 | |
| 2 | cervical | 만성 | 방사통 | d_neural, mulligan, mdt | ⬜ 미검증 | |
| 3 | cervical | 아급성 | 안정 시 통증 | scs, mdt, pne | ⬜ 미검증 | |
| 4 | lumbar | 급성 | 움직임 시 통증 | mulligan, mdt, scs | ⬜ 미검증 | |
| 5 | lumbar | 만성 | 방사통 | d_neural, mdt, art | ⬜ 미검증 | |
| 6 | lumbar | 아급성 | 안정 시 통증 | scs, trigger_point, mdt | ⬜ 미검증 | |
| 7 | cervical | 급성 | 방사통 | d_neural, mdt, mulligan | ⬜ 미검증 | |
| 8 | lumbar | 만성 | 움직임 시 통증 | joint_mobilization, mfr, art | ⬜ 미검증 | |
| 9 | cervical | 만성 | 움직임 시 통증 | joint_mobilization, mfr, pne | ⬜ 미검증 | |

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
