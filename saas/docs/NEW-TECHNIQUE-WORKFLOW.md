# 새 테크닉/카테고리 추가 워크플로우

## 필수 순서 (생략 불가)

### STEP 1: 사전 검증
```
/validate-technique-completeness <새 테크닉 name_en>
```

### STEP 2: seed_techniques.json 추가
- body_region enum 확인
- symptom_tags[] — technique_tags 마스터의 tag_key만 사용
- evidence_level enum 확인

### STEP 3: 새 symptom 태그 필요 시
technique_tags 마스터에 먼저 INSERT:
```sql
INSERT INTO technique_tags (tag_type, tag_key, label_ko, label_en)
VALUES ('symptom', 'new_tag_key', '한국어명', 'English Name');
```

### STEP 4: DB 업로드
seed.sql 재생성 또는 직접 INSERT

### STEP 5: 관계 동기화 (절대 필수)
```
/sync-technique-relations <name_en>
```
→ `.jarvis/saas/pending_indications_sync.sql` 생성됨  
→ Supabase SQL Editor에서 실행

### STEP 6: 검증 쿼리
```sql
SELECT name_ko, recommendation_score
FROM v_technique_recommendations
WHERE technique_id = '<새 technique ID>'
ORDER BY recommendation_score DESC;
```

결과가 나오면 완료. 빈 결과면 STEP 3-5 재확인.

---

## 자주 하는 실수

| 실수 | 결과 | 방지법 |
|------|------|--------|
| symptom_tags에 없는 tag_key 입력 | JOIN 실패, 관계 미생성 | /validate 먼저 실행 |
| technique_indications 동기화 누락 | 추천에서 제외됨 | /sync 항상 실행 |
| body_region enum 오타 | INSERT 에러 | 위 enum 목록 참조 |
| is_published=false 유지 | 뷰에서 필터링됨 | 업로드 후 true 설정 |
