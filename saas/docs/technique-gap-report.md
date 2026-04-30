# Technique Gap Report
Generated: 2026-04-25

## 요약
- **전체 테크닉 수**: 42개
- **필수 필드 누락**: 0개 ✅
- **symptom_tags 비어있는 테크닉**: 9개 ⚠️
- **마스터에 없는 tag_key 사용**: 0개 ✅
- **technique_steps 미완성**: 0개 ✅
- **key_references 없는 테크닉**: 0개 ✅
- **종합 품질 점수**: 96%

---

## 카테고리별 현황
- **Category A (관절가동술)**: 20개
- **Category B (Mulligan Concept)**: 22개

---

## 🟡 TIER 2 — 단기 보완 필요 (symptom_tags 비어있는 9개 테크닉)

| # | 테크닉명 | body_region | 문제 | 권장 태그 |
|---|---------|------------|------|---------|
| 11 | 팔꿈치 전방 활주 가동술 (굴곡 개선) | elbow | symptom_tags 비어있음 | `lateral_epicondylalgia`, `elbow_pain`(신규) |
| 12 | 요수근 관절 후방 활주 가동술 | wrist_hand | symptom_tags 비어있음 | `wrist_pain`(신규) |
| 13 | 중수지절 관절 트랙션 + 배측 활주 | wrist_hand | symptom_tags 비어있음 | `hand_finger_pain`(신규) |
| 26 | 늑골 SNAG | rib | symptom_tags 비어있음 | `rib_pain`(신규) |
| 34 | 팔꿈치 굴곡 MWM | elbow | symptom_tags 비어있음 | `lateral_epicondylalgia`, `elbow_pain`(신규) |
| 35 | 손목 MWM | wrist_hand | symptom_tags 비어있음 | `wrist_pain`(신규) |
| 36 | 손가락 MWM | wrist_hand | symptom_tags 비어있음 | `hand_finger_pain`(신규) |
| 40 | 경비관절 MWM | knee | symptom_tags 비어있음 | `knee_oa`, `patellofemoral`, `tibiofibular_dysfunction`(신규) |
| 42 | 발가락 MTP MWM | ankle_foot | symptom_tags 비어있음 | `ankle_pain_general`(신규) |

---

## 신규 Symptom 태그 등록 권고 (6개)

technique_tags 마스터에 추가 후 위 테크닉에 할당 필요:

| tag_key | label_ko | label_en | 적용 테크닉 |
|---------|---------|---------|-----------|
| `elbow_pain` | 팔꿈치 통증 | Elbow Pain | #11, #34 |
| `wrist_pain` | 손목 통증 | Wrist Pain | #12, #35 |
| `hand_finger_pain` | 손/손가락 통증 | Hand/Finger Pain | #13, #36 |
| `rib_pain` | 늑골 통증 | Rib Pain | #26 |
| `ankle_pain_general` | 발목/발 통증 | Ankle/Foot Pain | #42 |
| `tibiofibular_dysfunction` | 경비관절 기능장애 | Tibiofibular Dysfunction | #40 |

---

## 필수 필드 검사 결과 (모두 양호)

| 필드 | 완성도 |
|-----|--------|
| name_ko | 42/42 ✅ |
| name_en | 42/42 ✅ |
| description | 42/42 ✅ |
| patient_position | 42/42 ✅ |
| direction | 42/42 ✅ |
| body_region (유효 enum) | 42/42 ✅ |
| category (유효 enum) | 42/42 ✅ |
| evidence_level (유효 enum) | 42/42 ✅ |
| key_references | 42/42 ✅ |
| clinical_notes | 42/42 ✅ |
| contraindication_tags | 42/42 ✅ |

---

## 신체 부위별 테크닉 분포

| body_region | 테크닉 수 | 상태 |
|------------|---------|------|
| cervical | 6 | ✅ |
| shoulder | 6 | ✅ |
| knee | 5 | ✅ |
| lumbar | 4 | ✅ |
| elbow | 4 | ⚠️ 2개 symptom_tags 누락 |
| wrist_hand | 4 | ⚠️ 3개 symptom_tags 누락 |
| hip | 4 | ✅ |
| ankle_foot | 4 | ⚠️ 1개 symptom_tags 누락 |
| thoracic | 3 | 🟡 향후 보강 권고 |
| sacroiliac | 1 | 🟡 향후 보강 권고 |
| rib | 1 | ⚠️ 1개 symptom_tags 누락 |

---

## 🟢 TIER 3 — 장기 품질 개선

1. **Thoracic / Sacroiliac 커버 강화**: 현재 각 3개, 1개 — 추가 테크닉 개발 고려
2. **참고문헌 강화**: 현재 평균 1.1개/테크닉 → 2개 이상 목표 (RCT/체계적 고찰 우선)
3. **purpose_tags 일관성**: `stabilization` 태그 적용 대상 재검토 (#26 늑골 SNAG 등)

---

## 업로드 시 체크리스트

새 테크닉 추가 전:
1. `/validate-technique-completeness <name_en>` 실행
2. 새 symptom이 필요하면 technique_tags에 먼저 INSERT
3. DB 업로드
4. `/sync-technique-relations <name_en>` 실행
5. `v_technique_recommendations` 뷰에서 결과 확인
