# BETA-DEVOPS-CHECKLIST.md
<!-- owner: sw-devops -->

Vercel deployment environment check before beta test + beta participant access control guide

Created: 2026-04-30 | Owner: sw-devops

---

## 1. How to Verify Vercel Dashboard Environment Variables

```
1. https://vercel.com/dashboard → Select PT_prescription project
2. Settings → Environment Variables
3. Verify the following variables are registered in the Production environment:

[ ] SUPABASE_URL
[ ] SUPABASE_SERVICE_ROLE_KEY
[ ] VOYAGE_API_KEY

4. If any variable is missing, copy the value from the .env file and register it
   ⚠️  Note: .env file is local only — must be registered separately in Vercel
   ⚠️  Note: SUPABASE_ANON_KEY is not currently in .env (skip if unnecessary, check Supabase Dashboard if needed)
```

### Current .env Verification Results

| Variable | Status | Notes |
|--------|------|------|
| `SUPABASE_URL` | ✅ Set | `https://gnusyjnviugpofvaicbv.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | ✅ Set | JWT token format confirmed |
| `VOYAGE_API_KEY` | ✅ Set | `pa-Selo...` format confirmed |
| `SUPABASE_ANON_KEY` | ⚠️ Not in .env | Check Supabase Dashboard and register if needed |
| `ANTHROPIC_API_KEY` | ⚠️ Not in .env | Must register in Vercel if used in recommend.js etc. |

> ⚠️ **Important**: Even if API keys exist in the `.env` file, Vercel requires separate registration. Since `.env` is not committed to GitHub, manual registration in Vercel is required.

---

## 2. Beta Access Control Options (2 options compared)

### Option A: Vercel Password Protection (Recommended — fastest)

```
1. Vercel Dashboard → PT_prescription → Settings → Security
2. "Password Protection" section → Enable
3. Set a password (e.g., kmo-beta-2026)
4. Share URL + password with beta participants

URL: https://pt-prescription.vercel.app
Password: (your configured value)
```

**Advantages:**
- Vercel built-in feature — no code changes required
- Server-side protection (cannot be bypassed client-side)
- Easy management (instant ON/OFF from Vercel Dashboard)

**Disadvantages:**
- Requires Vercel Pro plan (not available on free plan)
- Check current plan: https://vercel.com/account

---

### Option B: Client-side Beta Code Entry Screen (Free — recommended alternative)

Add the following code to `index.html` immediately after the opening `<body>` tag:

```html
<!-- Beta Gate -->
<div id="beta-gate" style="display:none; position:fixed; inset:0; background:#f0f4f8; z-index:9999; display:flex; align-items:center; justify-content:center; flex-direction:column; gap:16px; font-family:sans-serif;">
  <h2 style="color:#1a365d; margin:0;">PT Prescription Assistant Beta</h2>
  <p style="color:#4a5568; margin:0;">Enter your beta participation code</p>
  <input id="beta-input" type="text" placeholder="Beta code" style="padding:10px 16px; border:2px solid #cbd5e0; border-radius:8px; font-size:16px; width:240px; text-align:center;">
  <button onclick="checkBetaCode()" style="padding:10px 24px; background:#2b6cb0; color:white; border:none; border-radius:8px; font-size:16px; cursor:pointer;">Enter</button>
  <p id="beta-error" style="color:#e53e3e; margin:0; display:none;">Invalid code</p>
</div>

<script>
  const BETA_CODE = 'KMO-BETA-2026'; // changeable
  const KEY = 'beta_access';
  
  function checkBetaCode() {
    const input = document.getElementById('beta-input').value.trim().toUpperCase();
    if (input === BETA_CODE) {
      localStorage.setItem(KEY, 'valid');
      document.getElementById('beta-gate').style.display = 'none';
    } else {
      document.getElementById('beta-error').style.display = 'block';
    }
  }
  
  // Check on page load
  if (localStorage.getItem(KEY) !== 'valid') {
    document.getElementById('beta-gate').style.display = 'flex';
  }
  
  // Enter key support
  document.getElementById('beta-input').addEventListener('keyup', e => {
    if (e.key === 'Enter') checkBetaCode();
  });
</script>
```

**Beta code**: `KMO-BETA-2026` (changeable if needed)

**Advantages:**
- Free, immediately implementable
- Manage beta participants by sharing the code only
- Instantly go public by removing the code when beta ends

**Disadvantages:**
- Client-side protection (can be bypassed with developer tools)
- Purpose is "access convenience control" rather than security

---

## 3. API Rate Limit Status

```
Current setting: 20 requests/day (api/recommend.js)
Recommended during beta test: maintain 20~30 requests/day
Monitoring: check usage at /debug/admin.html
```

### Beta Period Monitoring Points
- **429 error frequency**: check at `/debug/errors.html`
- **Daily usage trend**: check at `/debug/admin.html`
- **If 429 frequency is high**: recommend separating the limit value in `api/recommend.js` as an environment variable

### Adjusting Limit via Environment Variable (recommended improvement)
```javascript
// api/recommend.js current
const DAILY_LIMIT = 20;

// Improved: read from environment variable
const DAILY_LIMIT = parseInt(process.env.DAILY_LIMIT) || 20;
```
Adjustable without code changes by setting `DAILY_LIMIT=30` etc. in Vercel Dashboard.

---

## 4. Post-Deployment Health Check URLs

| Item | URL |
|------|-----|
| Main app | https://pt-prescription.vercel.app |
| Admin dashboard | https://pt-prescription.vercel.app/debug/admin.html |
| Error log | https://pt-prescription.vercel.app/debug/errors.html |
| Debug home | https://pt-prescription.vercel.app/debug/index.html |

---

## 5. vercel.json Current Configuration Summary

```json
{
  "version": 2,
  "functions": {
    "api/*.js": { "maxDuration": 60 }  // 60 second timeout
  },
  "routes": [
    { "src": "/api/(.*)", "dest": "/api/$1" },
    { "src": "/(.*)", "dest": "/$1" }
  ]
}
```

**Status**: Normal — no changes required

---

## 6. Pre-Beta Deployment Final Checklist

```
[ ] Verify 4 Vercel environment variables are registered (SUPABASE_URL, SERVICE_ROLE_KEY, VOYAGE_API_KEY, ANTHROPIC_API_KEY)
[ ] Select and apply beta access control method (Option A or B)
[ ] Verify access to /debug/admin.html
[ ] Verify access to /debug/errors.html
[ ] Run 1 test of the recommendation feature
[ ] Confirm normal response without 429 errors
[ ] Share URL + access code with beta participants
```
