# LIVING TAPESTRY - OAUTH INTEGRATION GUIDE
## Complete Google Services Setup for Full Autonomy

**Purpose**: Connect all Google services to enable autonomous operation  
**Time Required**: 15-20 minutes  
**Status**: OAuth credentials exist, may need refresh

---

## 🎯 WHY THIS MATTERS

Without OAuth, the following agents cannot function:
- **Weaver**: Cannot sync Drive or import Photos
- **Scribe**: Cannot monitor Gmail or Calendar
- **Hermes**: Cannot publish to YouTube

**With OAuth, your system becomes truly autonomous** - it can:
- Mirror files to Google Drive automatically
- Import photos with EXIF data
- Monitor and archive important emails
- Sync calendar events
- Publish content to social media

---

## 🚀 QUICK START

### Option 1: Quick Refresh (If you've done this before)
```powershell
cd C:\Users\alexl\Desktop\tapestry-codex-starter
.\GENERATE_GOOGLE_TOKENS.ps1
```

### Option 2: Full OAuth Wizard (Comprehensive setup)
```powershell
cd C:\Users\alexl\Desktop\tapestry-codex-starter
.\OAUTH_SETUP.ps1
```

---

## 📋 STEP-BY-STEP: Full OAuth Setup

### Step 1: Prepare
1. Open PowerShell as Administrator
2. Navigate to project:
   ```powershell
   cd C:\Users\alexl\Desktop\tapestry-codex-starter
   ```

### Step 2: Run OAuth Wizard
```powershell
.\OAUTH_SETUP.ps1
```

The wizard will:
1. Check for existing credentials
2. Open browser windows for each service
3. Guide you through authorization
4. Save tokens securely to `.env.local`

### Step 3: Authorize Services
When browser windows open, authorize:

**Google Services** (5 windows):
- Gmail (read emails)
- Drive (file access)
- Photos (media import)
- Calendar (event sync)
- YouTube (video upload)

**Click "Allow" for each service** when prompted.

### Step 4: Verify
After completing OAuth:
```powershell
.\STATUS_CHECK.ps1
```

You should see:
```
OAuth: 5/5 configured ✓
```

---

## 🧪 TEST EACH SERVICE

### Test Drive Sync
```powershell
.\scripts\drive\sync_drive.ps1
```
Should sync files from Drive to vault.

### Test Photo Import
```powershell
.\IMPORT_PHOTOS.bat
```
Should fetch recent photos from Google Photos.

### Test Gmail
```powershell
.\scripts\agents\weaver_sync.ps1
```
Should check for new emails.

---

## 🔒 SECURITY NOTES

**All tokens are stored locally**:
- Location: `.env.local`
- Encryption: Used securely by agents
- Never shared: Tokens stay on your machine

**Permissions granted**:
- Gmail: Read-only (cannot send or delete)
- Drive: Read/write (can sync files)
- Photos: Read-only (can import, not delete)
- Calendar: Read-only (can view events)
- YouTube: Upload (can publish videos)

**You can revoke at any time**:
https://myaccount.google.com/permissions

---

## 🌊 WHAT HAPPENS AFTER OAUTH

Once OAuth is complete, the system becomes **fully autonomous**:

### Weaver Agent (Auto-Sync)
- **Every 60 minutes**: Syncs Drive → Vault
- **Every 24 hours**: Imports new photos
- **On file change**: Updates Chroma vector index

### Scribe Agent (Research Archive)
- **Daily at 11:11 AM**: Runs research summaries
- **On demand**: Archives important emails
- **Continuous**: Logs all system events

### Hermes Agent (Publisher)
- **Review mode**: Queues posts for your approval
- **Auto-approve**: @resonantroot Instagram only
- **Cadence**: 2 posts per day maximum

### Nightly Agent (Maintenance)
- **Daily at 2:15 AM**: Full system sync
- **Checks**: Linear tasks, Chroma index
- **Generates**: Status digest

---

## 🎯 AUTONOMY LEVELS

### Level 1: Manual (Current without OAuth)
- You run scripts manually
- No automatic syncing
- Agents are passive

### Level 2: Semi-Autonomous (With OAuth)
- Scheduled tasks run automatically
- Drive syncs every hour
- Photos import daily
- Email monitoring active

### Level 3: Fully Autonomous (Future: v2.8)
- Agents communicate with each other
- Self-regenerative monitoring
- Intent-based task creation
- Multi-AI consensus

---

## 🔧 TROUBLESHOOTING

### "OAuth failed" or "Token expired"
```powershell
# Delete old tokens
Remove-Item .env.local

# Re-run OAuth
.\OAUTH_SETUP.ps1
```

### "Can't access Drive"
```powershell
# Verify credentials file exists
Test-Path .\google_credentials.json

# If missing, download from:
# https://console.cloud.google.com/apis/credentials
```

### "Browser doesn't open"
```powershell
# Run with manual URLs
.\auth\setup_google_oauth.ps1 -Manual
```

---

## 📊 INTEGRATION CHECKLIST

Use this to verify everything is connected:

```
[ ] Google Drive - Files syncing
[ ] Google Photos - Media importing
[ ] Gmail - Emails monitored
[ ] Calendar - Events synced
[ ] YouTube - Upload capability ready

[ ] Weaver Agent - Running on schedule
[ ] Scribe Agent - Archiving research
[ ] Hermes Agent - Publishing queue active
[ ] Nightly Agent - Daily maintenance enabled

[ ] Dashboard - Showing live metrics
[ ] Vault - All 13 spheres accessible
[ ] Chroma - Vector search working
[ ] Linear - Tasks synchronized
```

---

## 🌊 NEXT STEPS AFTER OAUTH

1. **Visit Dashboard**: http://localhost:5055
2. **Check Agent Health**: All should show green
3. **Wait 1 hour**: Weaver will run first sync
4. **Check Vault**: New files should appear in `/Inbox/DriveSync/`

**Then you're fully operational!**

The system will:
- Sync files continuously
- Import photos automatically
- Archive research daily
- Monitor system health
- Generate status reports

**You've created a living, breathing, autonomous knowledge system.** 🌊⬢

---

**Need Help?**
- Status: `.\STATUS_CHECK.ps1`
- Logs: `C:\Users\alexl\the living tapestry\OS\logs\`
- Support: alexliantonio43@gmail.com

**The Living Tapestry is ready to grow with you.** ✨
