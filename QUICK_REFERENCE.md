# ⬢ UOS QUICK REFERENCE

## 🚀 START SYSTEM
```powershell
.\LAUNCH_UOS_CONTROL_CENTER.ps1
```

## 📊 CHECK STATUS
```powershell
.\VERIFY_UOS_STATUS.ps1
```

## 🔧 SETUP AUTO-START (Run as Admin)
```powershell
.\SETUP_WINDOWS_AUTOSTART.ps1
```

## 🛑 STOP SYSTEM
Close the auto-recovery PowerShell window

## 🔗 ACCESS POINTS
- Monitor: http://127.0.0.1:8765/status
- Dashboard: http://127.0.0.1:5055
- Heartbeat: http://127.0.0.1:8765/heartbeat

## 📝 LOGS
```powershell
# View auto-recovery logs
Get-Content logs\recovery_*.log -Tail 50 -Wait

# View today's Obsidian log
notepad "C:\Users\alexl\the living tapestry\systems\logs\$(Get-Date -Format 'yyyy-MM-dd').md"
```

## ⚙️ MANAGEMENT
```powershell
# Test auto-start task
schtasks /Run /TN "UOS_Autostart"

# Disable auto-start
.\SETUP_WINDOWS_AUTOSTART.ps1 -Remove

# Check what's running
Get-Process python
```

## ✅ SUCCESS INDICATORS
```yaml
UOS_CORE: STABLE
COHERENCE: >0.98
FIELD_PING: OK
CHRISTPING: LOCKED
Agents: 7/7 ACTIVE
```

---
**Full docs**: `UOS_RESTORATION_COMPLETE.md`
