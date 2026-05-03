<!-- owner: sw-qa-tester -->
# C-3 + C-4 QA 체크리스트 (출시 전 검증)

**생성일**: 2026-05-03
**대상 PR**: #31 (`fc9dc5a`) — main 머지 완료
**전제 조건**: Supabase 에 migration 049 + 050 실행 완료 + verify 스크립트 ✅ 출력 확인 완료
**소요 시간**: 축소판 ~30분 / 풀 시나리오 ~2시간

---

## 0. 전제 조건 (선결)

- [ ] 049 마이그레이션 적용 — `\d ratings` 에서 `outcome` / `indication_accuracy` / `was_ai_recommended` 컬럼 존재 확인
- [ ] 050 마이그레이션 적용 — `\df fn_refresh_technique_stats` 함수 1행 + `\d technique_stats` 에 가중치/카운트 컬럼 존재 확인
- [ ] `verify-recommendation-weight-trigger.sql` 실행 → Messages 패널에 `✅ recommendation_weight ... → ...` / `✅ excellent_count 증가` / `✅ recommendation_weight 감소 확인` 출력 확인
- [ ] Vercel production 배포 완료 (`fc9dc5a` 또는 그 이후 커밋)

→ 모두 ✅ 면 다음 섹션 진행. ❌ 있으면 그 항목 수정 후 재시도.

---

## 1. 별점 + 효과 평가 UI 동작 (필수)

### 1-1. 추천 → 별점 클릭 → 추가 영역 노출

- [ ] production URL 접속 + 로그인
- [ ] 부위 (요추) / 시기 (만성) / 증상 (움직임 시 통증) 입력 → 추천 받기
- [ ] 추천 카드 하단의 별점 ★ 5개 클릭
- [ ] **클릭 직후** 다음 3개 영역 노출 확인:
  - "효과 분류 (선택사항)" — 라디오 6개 (매우 효과적 / 효과적 / 보통 / 효과 미미 / 효과 없음 / 부작용)
  - "적응증 적합도 (1=완전 부적합, 5=완벽 적합, 선택사항)" — 라디오 1~5
  - 메모 textarea + 저장/건너뛰기 버튼

### 1-2. 라디오 토글 동작

- [ ] outcome "효과적" 클릭 → 파란 배경 활성
- [ ] outcome "보통" 클릭 → "효과적" 비활성화 + "보통" 활성 (단일 선택)
- [ ] outcome "보통" 다시 클릭 → 모두 비활성 (재클릭 해제)
- [ ] accuracy 1~5 도 동일 패턴 확인

### 1-3. 건너뛰기 동작

- [ ] 별점 클릭 → 영역 노출 → "건너뛰기" 클릭
- [ ] 별점 별 색·outcome·accuracy 라디오 모두 초기화 + 영역 숨김 확인

---

## 2. 저장 동작 (필수)

### 2-1. 풀 입력 저장

- [ ] 별점 5★ + outcome "매우 효과적" + accuracy 5 + 메모 "테스트" → 저장
- [ ] "✓ 피드백 감사합니다" 표시
- [ ] Supabase ratings 테이블 조회 → 방금 row 1개 확인:
  - `star_rating = 5`
  - `outcome = 'excellent'`
  - `indication_accuracy = 5`
  - `notes = '테스트'`
  - `was_ai_recommended = false` (기본값)

### 2-2. 별점만 저장 (backward compat)

- [ ] 다른 추천 카드에서 별점 4★ 만 클릭 → outcome / accuracy / 메모 모두 비움 → 저장
- [ ] Supabase ratings 테이블에서 row 확인:
  - `star_rating = 4`
  - `outcome IS NULL`
  - `indication_accuracy IS NULL`

### 2-3. 부분 입력 저장

- [ ] 별점 3★ + outcome "보통" 만 (accuracy 비움) → 저장
- [ ] Supabase 확인: `outcome = 'moderate'`, `indication_accuracy IS NULL`

---

## 3. recommendation_weight 자동 갱신 (필수)

위 2-1 / 2-2 / 2-3 INSERT 후:

- [ ] Supabase SQL: `SELECT recommendation_weight, total_ratings, excellent_count, moderate_count, avg_indication_accuracy FROM technique_stats WHERE technique_id = '<위에서 사용한 technique_id>';`
- [ ] `total_ratings` 가 INSERT 횟수만큼 증가 (3 추가했으면 +3)
- [ ] `excellent_count = 1`, `moderate_count = 1` (2-1 + 2-3)
- [ ] `recommendation_weight` 가 0.0000~1.0000 범위 안의 값으로 갱신됨 (NULL 아님)
- [ ] `avg_indication_accuracy` 가 5.00 (2-1 의 accuracy=5 만 비-NULL)

→ 트리거가 정상 발화하면 위 값들이 INSERT 즉시 반영됨.

---

## 4. 회귀 테스트 — 기존 기능 깨지지 않음 (필수)

- [ ] 9-시나리오 중 최소 3개 (대표 케이스):
  - 경추 / 급성 / 움직임통증
  - 요추 / 만성 / 방사통
  - 어깨 (또는 무릎) / 아급성 / 안정통증 (신규 부위 회귀)
- [ ] 각 시나리오에서 추천 카드가 정상 노출되고 카테고리·기법명·임상 메모가 표시됨
- [ ] OAuth 로그인 (Google/Kakao) 버튼 비노출 확인 — `2f09692` 로 일시 비활성 상태이므로
- [ ] 어드민 대시보드 (`/debug/admin.html`) 접속 → 일일 사용량·등급·세션 표시 확인
- [ ] 에러 대시보드 (`/debug/errors.html`) 접속 → 최근 에러 0건 또는 알려진 에러만

---

## 5. 엣지 케이스 (시간 되면)

- [ ] 같은 기법에 같은 사용자가 여러 번 별점 → 모두 저장됨 (UNIQUE 제약 없음 확인)
- [ ] outcome 에 부정한 값 (예: `'invalid'`) 강제 전송 → API 400 에러 (`outcome 값이 유효하지 않습니다`)
- [ ] indication_accuracy 에 6 또는 0 강제 전송 → API 400 에러
- [ ] 별점 0 또는 6 강제 전송 → API 400 에러 (`평점은 1~5 사이의 정수여야 합니다`)
- [ ] 비로그인 상태에서 별점 클릭 → 401 또는 로그인 유도
- [ ] 모바일 (좁은 폭) 에서 outcome 라디오 6개 가로 wrap 확인 + accuracy 5 그리드 깨짐 없음

---

## 6. 결과 기록

각 항목 ✅/❌ 표시 후, 본 파일을 `sw-qa-tester/LOG-2026-05.md` 에 작업 기록 + 발견된 이슈는 별도 backlog 등록.

발견 시 즉시 수정해야 할 항목:
- 트리거 발화 안 함 → 마이그레이션 050 재실행
- outcome 저장 안 됨 → feedback.js / index.html 머지 상태 재확인
- production 에 머지 코드 미반영 → Vercel 배포 로그 확인

---

## 7. D4 결정 — 풀 vs 축소

- **축소판** (~30분): § 0 + § 1-1 / 1-2 / 2-1 / 2-2 / 3 / 4 (핵심 회귀 1개)
- **풀 시나리오** (~2h): 위 모두 + § 5 엣지케이스

축소판이 통과하면 출시 진행, 엣지케이스는 출시 후 D+1~3 에 보강 권장.
