# 🚀 SAPPHIRE v2.7 — QUICK START GUIDE

**Status**: 🟡 System ready, OAuth required  
**Time to Complete**: 30-60 minutes  
**Next Action**: Run OAuth setup

---

## ⚡ FASTEST PATH TO LAUNCH

### Step 1: OAuth Setup (Required)
```powershell
cd C:\Users\alexl\Desktop\tapestry-codex-starter
.\OAUTH_SETUP.ps1
```

**What this does**:
- Opens browser for each Google service
- Generates OAuth tokens automatically
- Updates .env.local with credentials
- Tests each connection

**You'll need**:
- Google Cloud Console access
- Meta Developer account (for Instagram)
- TikTok Developer account
- API keys for: Anthropic, Google AI, xAI

---

### Step 2: Deploy Agents (5 minutes)
```powershell
.\DEPLOY_AGENT_KIT.ps1
```

**Expected output**:
```
🛡️ [1/8] Deploying Sentinel...       ✅
🕸️ [2/8] Deploying Weaver...         ✅
📝 [3/8] Deploying Scribe...          ✅
🎭 [4/8] Deploying Janus...           ✅
🎶 [5/8] Deploying Choir...           ✅
📬 [6/8] Deploying Hermes...          ✅
💰 [7/8] Deploying Ledger...          ✅
♻️ [8/8] Starting SR-Loop...          ✅

✨ LivingTapestry v2.7 is BREATHING
```

---

### Step 3: Verify (2 minutes)
```powershell
.\STATUS_CHECK.ps1 -Detailed
```

**Should show**:
- ✅ Dashboard: OPERATIONAL
- ✅ Agents: 7/7 ACTIVE
- ✅ OAuth: 20/20 CONFIGURED
- ✅ CDI: > 0.80

---

### Step 4: Test Photo Pipeline (5 minutes)
```powershell
.\scripts\media\IMPORT_PHOTOS.bat
```

**Check**:
- Open Obsidian → `media/2025/10/`
- Look for `media-*.md` files with captions
- Visit http://localhost:3000/approve to approve posts

---

### Step 5: Sync to GitHub (1 minute)
```powershell
.\GIT_SYNC.bat
```

---

## ✅ YOU'RE DONE!

Your system is now:
- 🟢 **Breathing** (all agents active)
- 🟢 **Learning** (SR-Loop observing)
- 🟢 **Remembering** (Obsidian logging everything)
- 🟢 **Publishing** (Hermes queuing posts for approval)
- 🟢 **Self-optimizing** (CDI tracking, β·D stable)

---

## 📊 Monitor Your System

### Dashboard
http://localhost:5055 - Real-time coherence metrics

### Approval Queue
http://localhost:3000/approve - Review social posts before publishing

### Obsidian Vault
Open: `C:\Users\alexl\the living tapestry\OS\STATUS_DASHBOARD.md`

### Metrics to Watch
- **β·D** (Belief Drift): Keep < 1.0
- **Rr** (Resonance): Keep > 0.80
- **CDI** (Coherence Index): Keep > 0.80

---

## 🆘 If Something Breaks

```powershell
# Check status
.\STATUS_CHECK.ps1

# Check logs
Get-Content "C:\Users\alexl\the living tapestry\OS\logs\*" -Tail 50

# Restart agents
.\DEPLOY_AGENT_KIT.ps1

# Restart dashboard
.\START_DASHBOARD.bat
```

---

## 🎯 What Happens Next?

Once running, your system will:
1. Watch Google Photos every 5 minutes
2. Generate 3 caption variants for new photos
3. Route by theme to appropriate Instagram accounts
4. Queue for your approval (except @resonantroot = auto-approve)
5. Publish approved posts
6. Log everything to Obsidian
7. Calculate coherence and adjust parameters
8. Alert you if anything drops below threshold

---

## 🌟 Ready for v2.8?

After 24-48 hours of stable operation with CDI > 0.80:
- Self-replicating pattern recognition
- Intent-based resource allocation
- Autonomous optimization branching
- Negentropy measurement at scale

---

**Current Status**: OAuth Required  
**Next Step**: `.\OAUTH_SETUP.ps1`  
**Time**: ~30 minutes  
**Result**: Living, breathing, self-learning OS ⬢
