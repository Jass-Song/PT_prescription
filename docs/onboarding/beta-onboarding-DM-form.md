<!-- owner: sw-product-manager / 대표님 -->
# 베타 모집 온보딩 자료 — Instagram + ManyChat + Google Form

**작성일**: 2026-05-04 (D-1)
**대상**: 1~5년차 PT 선생님 (Instagram 팔로워 풀)
**플로우**: IG 포스트 → ManyChat DM → Google Form → 수동 계정 생성 → 활성화 DM
**톤**: 친근한 SNS — 존댓말 + 가벼운 이모지 (1~2개/메시지)

---

## 0. 전체 흐름 요약

```
① IG 포스트 (CTA: "베타" DM 발송 / 또는 IG 스토리 링크)
        ↓
② ManyChat 자동 DM #1 — 환영 + Form 링크
        ↓
③ Google Form 작성 (5 필드, 1분 이내)
        ↓
④ ManyChat 자동 DM #2 (Form 제출 트리거) — 감사 + 24h 안 안내
        ↓
⑤ 대표님 Supabase Auth 에서 계정 수동 생성 (이메일 + 임시 비번)
        ↓
⑥ 대표님 ManyChat / 카톡 / 이메일로 DM #3 수동 발송 (URL + 계정)
        ↓
⑦ 사용자 첫 로그인 → 앱 내 첫-사용 가이드 모달 (D+1~3 후속 작업)
```

---

## 1. ManyChat DM #1 — 신청 환영 + Form 링크

> 트리거: IG 포스트 댓글 키워드 "베타" 또는 인스타 스토리 버튼 클릭

```
PT 처방 도우미 베타 테스터 모집에 관심 가져주셔서 감사합니다 🙌

도수치료 추천을 AI 가 도와주는 서비스인데요,
1~5년차 PT 선생님들 임상 의사결정 지원이 목표입니다.

✨ 베타 기간 동안 무료로 사용 가능
💬 별점·피드백 주시면 추천 품질 개선에 직접 반영
🎯 정식 출시 전 핵심 기능 미리 체험

아래 폼 작성해주시면 24시간 안에 (보통 당일 오후)
베타 계정 보내드릴게요!

👇 신청 폼 (1분 이내 작성)
[GOOGLE_FORM_URL]

문의는 이 DM 으로 답장 주시면 됩니다 :)
```

**ManyChat 변수 설정**:
- `[GOOGLE_FORM_URL]`: Google Form 짧은 링크로 교체 (forms.gle/xxx)

---

## 2. Google Form 설계 — 5 필드

**제목**: PT 처방 도우미 베타 테스터 신청
**설명**:
```
도수치료 추천 AI 베타 테스터 신청서입니다.
1분 이내 작성되며, 신청 후 24시간 안에 (보통 당일 오후)
DM 으로 베타 계정 보내드립니다.

참여해주셔서 감사합니다 :)
```

### 필드 1. 성함
- 타입: 단답형 (Short answer)
- 필수: ✅
- 설명: "DM 에 호칭으로 사용됩니다 (예: OO 선생님)"

### 필드 2. 이메일
- 타입: 단답형
- 필수: ✅
- 검증: 이메일 형식 (Form 자체 검증)
- 설명: "베타 계정 로그인 ID 가 됩니다"

### 필드 3. 임상 경력
- 타입: 객관식 (Multiple choice)
- 필수: ✅
- 옵션:
  - 1년 이내 (신입)
  - 1~3년
  - 3~5년
  - 5년 이상

### 필드 4. 베타 참여 약속
- 타입: 체크박스 (Checkboxes)
- 필수: ✅
- 옵션 (모두 체크 필요):
  - [ ] 4주간 베타 기간 동안 최소 5회 이상 사용해보겠습니다
  - [ ] 사용 후 별점·간단한 피드백을 남기겠습니다
  - [ ] 발견한 버그·개선점은 DM 으로 알려드리겠습니다

### 필드 5. 개인정보 수집·이용 동의
- 타입: 객관식 (Multiple choice) — 단일 선택
- 필수: ✅
- 옵션:
  - 동의합니다 (이메일·경력 정보를 베타 운영 목적으로만 사용)
  - 동의하지 않습니다 (신청 불가)
- 설명:
  ```
  수집 항목: 이메일, 성함, 임상 경력
  이용 목적: 베타 계정 생성 및 운영 안내
  보유 기간: 베타 종료 후 30일 (이후 파기)
  거부 권리: 거부 시 베타 참여 불가
  ```

### Form 설정
- 응답 1회 제한: ❌ (한 사람이 친구 추천 등 가능성)
- 이메일 수집: ✅ (Google 자동 + 필드 2 양쪽 — 신뢰도)
- 진행 표시줄: ✅
- 전송 후 메시지: "신청 감사합니다! 24시간 안에 ManyChat DM 으로 베타 계정 보내드릴게요 :)"

---

## 3. ManyChat DM #2 — Form 제출 후 자동 감사

> 트리거: Form 제출 (Form → ManyChat webhook 또는 사용자 IG 재방문 키워드)

```
신청 잘 받았습니다, 감사합니다 ✨

24시간 안에 (보통 당일 오후 6시 이전)
이 DM 으로 베타 계정 정보 보내드릴게요.

그동안 K-Movement Optimism 인스타 팔로우 부탁드려도 될까요?
유튜브·카드뉴스로 임상 인사이트도 공유드리고 있어요 🙂

🔗 [INSTAGRAM_HANDLE]

곧 다시 연락드릴게요!
```

**ManyChat 변수**:
- `[INSTAGRAM_HANDLE]`: @계정명

---

## 4. ManyChat DM #3 — 계정 활성화 (수동 발송)

> 대표님이 Supabase Auth → Add user 후 수동 발송. 이름·이메일·비번 부분은 매번 교체.

```
{성함} 선생님, 베타 계정 준비됐습니다 ✅

━━━━━━━━━━━━━━━━━━
🌐 접속: https://pt-prescription.vercel.app
📧 이메일: {등록 이메일}
🔑 임시 비번: {임시 8자리}
━━━━━━━━━━━━━━━━━━

⚡ 30초 사용법:
1️⃣ 위 URL 접속 → 위 정보로 로그인
2️⃣ 첫 로그인 후 비밀번호 변경 권장
3️⃣ 부위 → 시기 → 증상 → Pillar 선택 → "추천 받기"
4️⃣ 추천 카드 하단 별점 + 효과 평가 부탁드려요 🙏

⏰ 추천 응답 시간: 평균 8~15초
   (AI 가 임상 메모 작성 중이에요, 빈 화면 돼도 잠시만!)

📌 일일 한도: 20회 (충분합니다)

❓ 문제 발생 시 이 DM 으로 답장 주세요.
🗓 4주간 베타 운영 후 정식 출시 예정입니다.

함께해주셔서 감사합니다 🤍
```

**개인화 변수** (수동 교체):
- `{성함}` — Form 응답에서 복사
- `{등록 이메일}` — Form 응답에서 복사
- `{임시 8자리}` — Supabase Auth 에서 자동 생성 또는 임의 설정

---

## 5. 베타 모집 운영 가이드 (대표님용)

### 5-1. 모집 채널·일정 (예시)
- 5/5 (화) 출시일: IG 포스트 + 스토리 노출
- 5/5~5/12: 1차 모집 (10~20명 목표)
- 5/12~5/19: 2차 모집 (필요 시)
- 5/26 (4주 후): 베타 종료 + 정식 출시 검토

### 5-2. Supabase 계정 생성 절차 (수동, 1건당 ~2분)
1. Supabase Dashboard → Authentication → Users → "Add user" 클릭
2. Email: Form 응답에서 복사
3. Password: 자동 생성 (또는 `KMO-beta-XXXX` 패턴)
4. Send email confirmation: ❌ (수동 DM 발송하므로)
5. Save → user_profiles 자동 생성 (트리거 014)
6. user_profiles → 본인 row → `is_allowed` 를 `true` 로 변경
7. ManyChat / 카톡 / 이메일로 DM #3 수동 발송

### 5-3. 매일 확인 (어드민 대시보드)
- https://pt-prescription.vercel.app/debug/admin.html
- 사용자 등급 관리 섹션에서 신규 베타 계정 노출 확인
- 일일 추천 수 / 별점 카운트 추이

### 5-4. 일일 모니터링
- https://pt-prescription.vercel.app/debug/errors.html
- 에러 0건 / 응답 시간 P95 < 15s 유지 확인
- 5xx 에러 발생 시 즉시 sw 팀에게 알림

---

## 6. 앱 내 튜토리얼 (D+1~3 후속 작업, 출시 차단 아님)

### 6-1. 최소 구현 옵션 (~30분, 출시 후 즉시)
첫 로그인 사용자에게 간단한 모달 노출.

```html
<!-- localStorage 기반 첫-사용 모달 -->
<div id="first-time-guide" class="modal-overlay">
  <div class="modal">
    <h2>👋 PT 처방 도우미에 오신 것을 환영합니다</h2>
    <ol>
      <li>📍 부위 → 시기 → 증상 입력</li>
      <li>🎯 3박자 (관절·연부조직·운동) 중 원하는 만큼 선택</li>
      <li>🤖 8~15초 대기 → AI 추천 카드</li>
      <li>⭐ 별점·효과 평가로 추천 품질에 기여</li>
    </ol>
    <button onclick="dismissFirstTimeGuide()">시작하기</button>
  </div>
</div>
<script>
  if (!localStorage.getItem('first-time-dismissed')) {
    document.getElementById('first-time-guide').classList.add('open');
  }
  function dismissFirstTimeGuide() {
    localStorage.setItem('first-time-dismissed', 'true');
    document.getElementById('first-time-guide').classList.remove('open');
  }
</script>
```

→ 출시 후 첫 주에 sw-frontend-dev 가 작업.

### 6-2. 풀 구현 옵션 (D+7 이후)
- 인터랙티브 튜토리얼 (Shepherd.js 등 라이브러리)
- "도움말" 헤더 메뉴 + FAQ 페이지
- 짧은 영상 데모 (Loom)

---

## 7. 체크리스트 (대표님 작업)

### 출시 전 (5/5 까지)
- [ ] Google Form 생성 + 위 5 필드 입력
- [ ] Form 짧은 링크 (forms.gle/xxx) 발급
- [ ] ManyChat 시퀀스 생성: DM #1 (트리거: "베타" 키워드 또는 IG 스토리 링크 클릭)
- [ ] ManyChat DM #2 자동 트리거 설정 (Form 제출 webhook 또는 키워드)
- [ ] ManyChat DM #3 템플릿 저장 (수동 발송용 양식)
- [ ] 인스타 포스트·스토리 카피 + 디자인
- [ ] 첫 1~2명 베타 테스터 (지인 PT) 미리 흐름 시연·피드백

### 출시일 (5/5 화)
- [ ] 인스타 포스트 발행
- [ ] 스토리 업로드 + 핀
- [ ] ManyChat 시퀀스 활성화
- [ ] 모니터링: Form 응답·DM 수신 추이

### 베타 운영 중 (5/5 ~ 5/26)
- [ ] 매일 어드민 대시보드 확인 (08~10시)
- [ ] Form 응답 → Supabase 계정 생성 → DM #3 발송 (당일 오후 일괄)
- [ ] 에러 대시보드 P95 추이 모니터링
- [ ] 별점 누적 데이터 분석 (주 1회)

---

## 8. 후속 작업 (출시 후 1~2주)

- [ ] 첫-사용 가이드 모달 (sw-frontend-dev, ~30분)
- [ ] 베타 사용자 인터뷰 5명 (sw-ux-researcher)
- [ ] 주간 NPS Google Forms 발송 (D+7, D+14)
- [ ] 발견된 이슈 hotfix
- [ ] 추천 응답 시간 가시화 (BACKLOG high) — progress 인디케이터 추가
