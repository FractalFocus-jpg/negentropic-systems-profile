# ⬢ LT_vΩ.25 INTEGRATION GUIDE
# Step-by-step setup for missing API keys

## 🔑 MISSING API KEYS SETUP

### 1️⃣ LINEAR API KEY (5 minutes)

**Steps:**
1. Go to: https://linear.app/settings/api
2. Click "Personal API keys" or "Create new key"
3. Name: `LivingTapestry_OS`
4. Copy the generated key

**Add to .env.local:**
```
LINEAR_API_KEY=lin_api_YOUR_KEY_HERE
```

---

### 2️⃣ CONFLUENCE (10 minutes)

**Steps:**
1. Go to: https://id.atlassian.com/manage-profile/security
2. Create API token named `LivingTapestry_OS`
3. Copy the token

**Also need:**
- Your Confluence base URL (e.g., `https://yourcompany.atlassian.net/wiki`)
- Your Atlassian email

**Add to .env.local:**
```
CONFLUENCE_URL=https://yourcompany.atlassian.net/wiki
CONFLUENCE_USER=your.email@domain.com
CONFLUENCE_API_TOKEN=YOUR_TOKEN_HERE
```

---

### 3️⃣ NOTION API KEY (5 minutes)

**Steps:**
1. Go to: https://www.notion.so/my-integrations
2. Click "+ New integration"
3. Name: `LivingTapestry OS`
4. Select capabilities: Read content, Update content
5. Submit
6. Copy the "Internal Integration Token"

**Add to .env.local:**
```
NOTION_API_KEY=secret_YOUR_KEY_HERE
```

---

### 4️⃣ ANTHROPIC API KEY (5 minutes)

**Steps:**
1. Go to: https://console.anthropic.com/settings/keys
2. Create new key named `LivingTapestry_OS`
3. Copy the key

**Add to .env.local:**
```
ANTHROPIC_API_KEY=sk-ant-YOUR_KEY_HERE
```

---

### 5️⃣ GEMINI API KEY (5 minutes)

**Steps:**
1. Go to: https://makersuite.google.com/app/apikey
2. Create API key (or use existing)
3. Copy the key

**Add to .env.local:**
```
GEMINI_API_KEY=YOUR_KEY_HERE
```

---

## ⚡ QUICK SETUP OPTION

If you want to proceed **right now** with partial functionality:

**Option A - Essential Only (AI Mesh)**
```
ANTHROPIC_API_KEY=...    # For Claude-powered agents
GEMINI_API_KEY=...        # For Gemini integration
```
This enables the AI mesh to function.

**Option B - Workspace Only**
```
LINEAR_API_KEY=...       # For task management
NOTION_API_KEY=...       # For knowledge base
```
This enables workspace integrations.

**Option C - Full Setup**
All 7 keys (recommended for complete functionality)

---

## 🚀 AFTER ADDING KEYS

Run the verification again:
```powershell
.\CHECK_API_KEYS.ps1
```

Then proceed with integration:
```powershell
.\LAUNCH_UOS_CONTROL_CENTER.ps1
```

---

**Current Status:** 3/10 keys configured (Google Photos ready)  
**Next:** Add 7 missing keys following guides above  
**Time Estimate:** 30-40 minutes total
