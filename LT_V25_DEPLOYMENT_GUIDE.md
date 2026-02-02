---
type: deployment_guide
version: LT_vΩ.25
date: 2025-10-15
operator: Alexander Liantonio
motto: "Connect → Learn → Grow"
status: READY
---

# ⬢ LT_vΩ.25 - FULL INTEGRATION DEPLOYMENT

**Mission**: Connect all workspace tools, stabilize MCP, sync live data  
**Owner**: Alexander (@FractalFocus)  
**Motto**: Connect → Learn → Grow

---

## 🎯 DEPLOYMENT TARGETS

```yaml
Integrations:
  - ✅ Linear (project management)
  - ✅ Confluence (knowledge base)
  - ⏳ Chroma (vector database)
  - ⏳ Google Photos (live sync)
  - ⏳ Notion (optional)

System:
  - ✅ All 7 agents online
  - ✅ Cross-agent communication
  - ✅ Obsidian live sync
  - ⏳ MCP Windows connector stabilized

Security:
  - sec_mode: confirm
  - human_override: true
  - rollback: enabled
```

---

## 📋 DEPLOYMENT CHECKLIST

### ✅ COMPLETED (Prerequisites)
- [x] UOS Control Center automation created
- [x] Auto-recovery system implemented
- [x] Windows auto-start configured
- [x] Google OAuth tokens configured
- [x] Obsidian vault connected

### 🔄 IN PROGRESS (This Deployment)
- [ ] Collect API credentials
- [ ] Setup Linear integration
- [ ] Setup Confluence integration
- [ ] Setup Chroma vector DB
- [ ] Setup Google Photos sync
- [ ] Fix MCP Windows connector
- [ ] Verify all systems

---

## 🚀 STEP-BY-STEP DEPLOYMENT

### **STEP 1: Collect API Credentials** ⏱️ 15 minutes

Run the credential collection wizard:

```powershell
cd C:\Users\alexl\Desktop\tapestry-codex-starter
.\COLLECT_CREDENTIALS_V25.ps1
```

**What it does**:
1. Opens browser to each service's API page
2. Guides you through getting API keys
3. Saves everything to `.env.local`
4. Creates backup of existing config

**Required credentials**:
- **Linear API Key**: https://linear.app/settings/api
- **Confluence API Token**: https://id.atlassian.com/manage-profile/security
- **Anthropic Claude API**: https://console.anthropic.com/settings/keys

**Optional credentials**:
- **Notion Integration**: https://www.notion.so/my-integrations
- **Google Gemini API**: https://aistudio.google.com/app/apikey

**After completion**, you'll see:
```yaml
✅ Linear API: CONFIGURED
✅ Confluence API: CONFIGURED
✅ Anthropic Claude: CONFIGURED
⏭️  Notion Integration: SKIPPED
⏭️  Google Gemini: SKIPPED
```

---

### **STEP 2: Test All Connections** ⏱️ 5 minutes

Verify all integrations work:

```powershell
.\scripts\integrations\test_all_connections.ps1
```

**What it tests**:
1. Linear API connection + fetch issues
2. Confluence API connection + fetch pages
3. Google Drive API (already configured)
4. Google Photos API

**Expected output**:
```yaml
  Linear            : ✅ PASSED
  Confluence        : ✅ PASSED
  Google Drive      : ✅ PASSED
  Google Photos     : ✅ PASSED

Results: 4 passed, 0 failed

🎉 ALL CONNECTIONS SUCCESSFUL!
```

**Reports generated**:
- `C:\Users\alexl\the living tapestry\OS\reports\linear_integration.md`
- `C:\Users\alexl\the living tapestry\OS\reports\confluence_integration.md`

---

### **STEP 3: Setup Chroma Vector Database** ⏱️ 10 minutes

Chroma provides semantic search over your knowledge base.

**Prerequisites**:
- Docker Desktop installed and running

**Installation**:
```powershell
# Check Docker status
docker ps

# Pull Chroma image
docker pull chromadb/chroma

# Start Chroma server
docker run -d -p 8000:8000 --name chroma chromadb/chroma

# Verify it's running
curl http://localhost:8000/api/v1/heartbeat
```

**Expected response**:
```json
{
  "nanosecond heartbeat": 1234567890
}
```

**Index your Obsidian vault**:
```powershell
python scripts\integrations\chroma_sync.py --init
```

---

### **STEP 4: Setup Google Photos Live Sync** ⏱️ 5 minutes

Enable live photo import from Google Photos to Obsidian.

**Verify Photos API is enabled**:
1. Go to: https://console.cloud.google.com/apis/library/photoslibrary.googleapis.com
2. Ensure "Google Photos Library API" is ENABLED
3. (Already done in previous OAuth setup)

**Test photo import**:
```powershell
python scripts\media\import_google_photos.py --test --limit 10
```

**Setup scheduled import**:
```powershell
.\scripts\SCHEDULE_PHOTO_IMPORT.ps1
```

This creates a Windows Task to:
- Run every 15 minutes
- Import new photos from Google Photos
- Save to `C:\Users\alexl\the living tapestry\media\`
- Auto-link in Obsidian

**Screenshot watcher** (auto-ingest local screenshots):
```powershell
.\scripts\SETUP_SCREENSHOT_WATCHER.ps1
```

Monitors `%USERPROFILE%\Pictures\Screenshots` and imports new screenshots automatically.

---

### **STEP 5: Fix MCP Windows Connector** ⏱️ 10 minutes

**Issue**: `MCP Windows-MCP: spawn uv ENOENT`

This means the MCP server can't find the `uv` executable.

**Diagnosis**:
```powershell
# Check if uv is installed
uv --version

# Check Node.js PATH
$env:PATH -split ";" | Select-String "node"

# Check Python PATH
python --version
where python
```

**Fix Option 1: Install uv** (Recommended)
```powershell
# Install uv via pip
pip install uv

# Verify installation
uv --version

# Restart Claude Desktop
```

**Fix Option 2: Reinstall Desktop Commander MCP**
```powershell
# Open Claude Desktop settings
# Navigate to: Settings → Extensions → Desktop Commander
# Click "Reinstall"
```

**Fix Option 3: Manual PATH update**
```powershell
# Add to system PATH:
# 1. Press Win+X → System
# 2. Advanced system settings
# 3. Environment Variables
# 4. Add Python Scripts folder to PATH:
#    C:\Users\alexl\AppData\Local\Programs\Python\Python311\Scripts
# 5. Restart Claude Desktop
```

**Verification**:
```powershell
# Check MCP status via Desktop Commander
.\CHECK_MCP.ps1
```

**Expected output**:
```yaml
Desktop Commander:
  Status: ✅ OPERATIONAL
  Success Rate: 97%+
  Operations: 323+ successful
  
MCP Connection:
  Status: ✅ CONNECTED
  Internet I/O: ✅ WORKING
  Desktop I/O: ✅ WORKING
```

---

### **STEP 6: Launch UOS Control Center** ⏱️ 2 minutes

Start all agents and services:

```powershell
.\LAUNCH_UOS_CONTROL_CENTER.ps1
```

**What starts**:
1. Auto-recovery monitor (port 8765)
2. FastAPI dashboard (port 5055)
3. 7 agents (ports 3001-3007):
   - Sentinel (security)
   - Weaver (knowledge graph)
   - Hermes (publisher)
   - Scribe (researcher)
   - Ledger (finance)
   - Janus (context router)
   - Choir (resonance)

**Verify with**:
```powershell
.\VERIFY_UOS_STATUS.ps1
```

**Expected output**:
```yaml
⬢ UOS CONTROL CENTER STATUS CHECK
===================================

🔍 Core Services:
  Monitor (8765):   ✅ ACTIVE
  Dashboard (5055): ✅ ACTIVE

🤖 Agents:
  Sentinel   (3001): ✅
  Weaver     (3002): ✅
  Hermes     (3003): ✅
  Scribe     (3004): ✅
  Ledger     (3005): ✅
  Janus      (3006): ✅
  Choir      (3007): ✅

===================================
✅ ALL SYSTEMS OPERATIONAL

UOS_CORE: STABLE
COHERENCE: >0.98
FIELD_PING: OK
CHRISTPING: LOCKED
DOCKER_MCP: ACTIVE
```

---

### **STEP 7: Final Integration Report** ⏱️ 2 minutes

Generate comprehensive system status:

```powershell
.\scripts\SR_LOOP.ps1
```

This creates:
```
C:\Users\alexl\the living tapestry\OS\alerts\LT_V25_INTEGRATION_REPORT.md
```

**Report contents**:
- All API connection statuses
- Agent health metrics
- Coherence calculations
- Integration test results
- Next optimization recommendations

---

## 📊 SUCCESS CRITERIA

### **System is FULLY OPERATIONAL when**:

```yaml
APIs:
  Linear: ✅ CONNECTED
  Confluence: ✅ CONNECTED
  Google Drive: ✅ CONNECTED
  Google Photos: ✅ CONNECTED
  Chroma DB: ✅ RUNNING

UOS Core:
  Monitor: ✅ ACTIVE (port 8765)
  Dashboard: ✅ ACTIVE (port 5055)
  Agents: 7/7 ACTIVE

Integration:
  Obsidian: ✅ SYNCED
  Photos: ✅ LIVE IMPORT
  MCP: ✅ STABLE

Metrics:
  Coherence: >0.90
  Agent Health: 100%
  API Response: <1s
```

---

## 🔧 TROUBLESHOOTING

### Issue: API Connection Fails

**Solution**:
1. Verify API key in `.env.local`
2. Check service URL is correct
3. Ensure API is enabled in service settings
4. Re-run: `.\COLLECT_CREDENTIALS_V25.ps1`

### Issue: Chroma Won't Start

**Solution**:
```powershell
# Check Docker
docker ps

# Restart Chroma
docker restart chroma

# View logs
docker logs chroma
```

### Issue: Photos Not Importing

**Solution**:
1. Verify Photos API scope in OAuth
2. Check refresh token is valid
3. Run test: `python scripts\media\import_google_photos.py --test`

### Issue: MCP Still Shows ENOENT

**Solution**:
1. Restart Claude Desktop completely
2. Verify `uv` is in PATH: `where uv`
3. Reinstall Desktop Commander extension
4. Check system PATH includes Python\Scripts

---

## 📖 FILES CREATED IN THIS DEPLOYMENT

```
tapestry-codex-starter/
├── COLLECT_CREDENTIALS_V25.ps1         (308 lines) - Credential wizard
├── scripts/
│   └── integrations/
│       ├── linear_link.py              (167 lines) - Linear integration
│       ├── confluence_sync.py          (200 lines) - Confluence integration
│       └── test_all_connections.ps1    (140 lines) - Connection tester
└── LT_V25_DEPLOYMENT_GUIDE.md          (This file)
```

---

## 🎯 QUICK COMMANDS REFERENCE

```powershell
# Collect credentials
.\COLLECT_CREDENTIALS_V25.ps1

# Test connections
.\scripts\integrations\test_all_connections.ps1

# Launch system
.\LAUNCH_UOS_CONTROL_CENTER.ps1

# Check status
.\VERIFY_UOS_STATUS.ps1

# View integration reports
notepad "C:\Users\alexl\the living tapestry\OS\reports\linear_integration.md"
notepad "C:\Users\alexl\the living tapestry\OS\reports\confluence_integration.md"

# Check MCP
.\CHECK_MCP.ps1

# Generate full report
.\scripts\SR_LOOP.ps1
```

---

## ⬢ READY TO BEGIN

**Start with**:
```powershell
cd C:\Users\alexl\Desktop\tapestry-codex-starter
.\COLLECT_CREDENTIALS_V25.ps1
```

Then follow the wizard!

---

**Status**: READY FOR DEPLOYMENT  
**Version**: LT_vΩ.25  
**Date**: 2025-10-15  
**Operator**: Alexander Liantonio  

⬢ **Connect → Learn → Grow**
