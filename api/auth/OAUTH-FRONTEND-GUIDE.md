# OAuth Social Login — Frontend Integration Guide

> **For**: sw-frontend-dev  
> **Written by**: sw-auth-specialist  
> **Date**: 2026-05-03  
> **Scope**: Google + Kakao OAuth via Supabase

---

## Overview

Supabase handles the full OAuth redirect flow. The frontend only needs to call
`supabase.auth.signInWithOAuth(...)`. After authentication, Supabase redirects
back to `/api/auth/callback`, which exchanges the PKCE code and then redirects
to the app root with the session embedded in the URL fragment. The Supabase JS
client picks up the session automatically via `onAuthStateChange`.

---

## 1. Trigger Google OAuth (frontend JS)

Add this function to `index.html` (inside the `<script>` section, near `doLogin`):

```js
async function doLoginGoogle() {
  if (!supabaseClient) return;
  const btn = document.getElementById('btnLoginGoogle');
  if (btn) { btn.disabled = true; btn.textContent = '연결 중...'; }

  const { error } = await supabaseClient.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: 'https://pt-prescription.vercel.app/api/auth/callback',
      queryParams: {
        access_type: 'offline',  // request refresh_token
        prompt: 'consent',
      },
    },
  });

  if (error) {
    console.error('[OAuth] Google login error:', error.message);
    if (btn) { btn.disabled = false; btn.textContent = 'Google로 로그인'; }
  }
  // On success, browser navigates away — no further JS needed here.
}
```

Recommended button HTML (place below the existing login form):

```html
<button id="btnLoginGoogle" onclick="doLoginGoogle()"
  style="width:100%;padding:10px;margin-top:8px;border:1.5px solid #dadce0;
         border-radius:8px;background:#fff;cursor:pointer;font-size:14px;
         display:flex;align-items:center;justify-content:center;gap:8px;">
  <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg"
       width="18" height="18" />
  Google로 로그인
</button>
```

---

## 2. Trigger Kakao OAuth (frontend JS)

```js
async function doLoginKakao() {
  if (!supabaseClient) return;
  const btn = document.getElementById('btnLoginKakao');
  if (btn) { btn.disabled = true; btn.textContent = '연결 중...'; }

  const { error } = await supabaseClient.auth.signInWithOAuth({
    provider: 'kakao',
    options: {
      redirectTo: 'https://pt-prescription.vercel.app/api/auth/callback',
    },
  });

  if (error) {
    console.error('[OAuth] Kakao login error:', error.message);
    if (btn) { btn.disabled = false; btn.textContent = 'Kakao로 로그인'; }
  }
}
```

Recommended button HTML:

```html
<button id="btnLoginKakao" onclick="doLoginKakao()"
  style="width:100%;padding:10px;margin-top:8px;border:none;
         border-radius:8px;background:#FEE500;cursor:pointer;font-size:14px;
         display:flex;align-items:center;justify-content:center;gap:8px;">
  <img src="https://developers.kakao.com/assets/img/about/logos/kakaolink/kakaolink_btn_medium.png"
       width="18" height="18" />
  Kakao로 로그인
</button>
```

---

## 3. Handle auth errors returned from callback

After OAuth callback, the app URL may contain `?auth_error=...`. Add this
near the top of `initApp()`:

```js
// Check for OAuth errors returned by /api/auth/callback
const urlParams = new URLSearchParams(window.location.search);
const authErr = urlParams.get('auth_error');
if (authErr) {
  // Show user-facing error on screen0
  const errEl = document.getElementById('loginError');
  if (errEl) {
    const msgs = {
      exchange_failed: '소셜 로그인 처리 중 오류가 발생했습니다. 다시 시도해주세요.',
      no_code: '인증 코드가 없습니다. 다시 시도해주세요.',
      server_error: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
    };
    errEl.textContent = msgs[authErr] || '로그인 중 오류가 발생했습니다.';
    errEl.style.display = 'block';
  }
  // Clean URL
  window.history.replaceState({}, '', window.location.pathname);
}
```

---

## 4. Dynamically show/hide social buttons (optional)

Use the `/api/auth/providers` endpoint to show buttons only for enabled providers:

```js
async function loadSocialProviders() {
  try {
    const res = await fetch('/api/auth/providers');
    const { providers } = await res.json();
    const googleBtn = document.getElementById('btnLoginGoogle');
    const kakaoBtn = document.getElementById('btnLoginKakao');
    if (googleBtn) googleBtn.style.display = providers.includes('google') ? '' : 'none';
    if (kakaoBtn)  kakaoBtn.style.display  = providers.includes('kakao')  ? '' : 'none';
  } catch (e) {
    // Silently hide social buttons on error
  }
}
// Call inside initApp() after initSupabase()
```

---

## 5. Callback URL to configure

The Supabase JS client passes `redirectTo` to Supabase, which then sends the
user back here after OAuth completes. Register this **exact URL** in both places:

| Where | Value |
|-------|-------|
| Supabase Dashboard → Authentication → URL Configuration → **Redirect URLs** | `https://pt-prescription.vercel.app/api/auth/callback` |
| Supabase Dashboard → Authentication → URL Configuration → **Site URL** | `https://pt-prescription.vercel.app` |

---

## 6. Supabase Dashboard — Provider Setup (Director action required)

### Google

1. Go to **Supabase Dashboard → Authentication → Providers → Google**
2. Enable Google provider
3. Enter **Client ID** and **Client Secret** from [Google Cloud Console](https://console.cloud.google.com/)
   - Create an OAuth 2.0 Client ID (Web application type)
   - Authorized redirect URI: `https://gnusyjnviugpofvaicbv.supabase.co/auth/v1/callback`
4. Save

### Kakao

1. Go to **Supabase Dashboard → Authentication → Providers → Kakao**
2. Enable Kakao provider
3. Enter **REST API Key** and **Client Secret** from [Kakao Developers](https://developers.kakao.com/)
   - Create an application → add Platform (Web) → set site domain: `https://pt-prescription.vercel.app`
   - Activate Kakao Login → add Redirect URI: `https://gnusyjnviugpofvaicbv.supabase.co/auth/v1/callback`
   - Enable **"카카오계정으로 로그인"** in Kakao Login settings
   - Under **동의항목**: enable `account_email` (required for Supabase to link users)
4. Save

---

## 7. Vercel Environment Variables (Director action required)

Add the following to the Vercel project (Settings → Environment Variables):

| Variable | Value | Notes |
|----------|-------|-------|
| `APP_URL` | `https://pt-prescription.vercel.app` | Used by callback.js for redirects |
| `SUPABASE_ANON_KEY` | `<your anon key>` | Already set — verify it exists |
| `OAUTH_GOOGLE_ENABLED` | `true` | Set to `false` to hide Google button |
| `OAUTH_KAKAO_ENABLED` | `true` | Set to `false` to hide Kakao button |

`SUPABASE_URL` and `SUPABASE_SERVICE_KEY` should already be set from the
existing email/password auth implementation.

---

## 8. user_profiles table — Social login note

The existing `user_profiles` table uses `is_allowed` for access control.
Social login users go through the **same approval flow** as email users:

- Supabase creates the user in `auth.users` on first OAuth login
- The existing database trigger on `auth.users` INSERT should auto-create a
  `user_profiles` row with `is_allowed = false`
- The existing `checkAllowedAndEnter()` function in `index.html` handles
  the pending state correctly — **no changes needed** for social login users

If the trigger does not exist yet, check `saas/schema.sql` with sw-db-architect.

---

## Files created by sw-auth-specialist

| File | Purpose |
|------|---------|
| `api/auth/callback.js` | PKCE code exchange + redirect to app |
| `api/auth/providers.js` | Returns enabled OAuth providers list |
| `api/auth/OAUTH-FRONTEND-GUIDE.md` | This guide |
