# 🜂 SAPPHIRE v2.5 — Daily Digest & Safety Watcher
# Runs at 09:00 daily
# Checks EMERGENCY_STOP, generates summary, updates log

Param(
    [string]$VaultLogs = "C:\Users\alexl\the living tapestry\systems\logs",
    [string]$ProjectRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$date = Get-Date -Format "yyyy-MM-dd"
$logFile = Join-Path $VaultLogs "$date.md"

# Check EMERGENCY_STOP
$emergencyFile = Join-Path $ProjectRoot "EMERGENCY_STOP"
if (Test-Path $emergencyFile) {
    Write-Host "🛑 EMERGENCY_STOP ACTIVE - All automation PAUSED" -ForegroundColor Red
    @"

## ⚠️ EMERGENCY STOP — $timestamp
**Status**: ALL AUTOMATION PAUSED
**File**: $emergencyFile
**Action Required**: Remove file to resume operations

"@ | Add-Content -Path $logFile -Encoding UTF8
    exit 0
}

# Collect metrics
Write-Host "📊 Generating Daily Digest..." -ForegroundColor Cyan

# Get dashboard status
try {
    $dashResponse = Invoke-RestMethod -Uri "http://localhost:5055/snapshot.json" -TimeoutSec 3
    $dashStatus = "✅ Operational"
    $meanPLV = [math]::Round($dashResponse.mean, 4)
    $samples = $dashResponse.samples
} catch {
    $dashStatus = "⚠️ Offline"
    $meanPLV = "N/A"
    $samples = 0
}

# Count recent snapshots
$runsPath = Join-Path $ProjectRoot "src\tapestry\runs"
$recentRuns = (Get-ChildItem $runsPath -Filter "*.json" | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }).Count

# Count queued posts
$outboxPath = Join-Path $VaultLogs "..\..\tapestry\queues\outbox"
$queuedPosts = 0
if (Test-Path $outboxPath) {
    $queuedPosts = (Get-ChildItem $outboxPath -Recurse -Filter "*.md" | Where-Object { $_.Name -like "post-*" }).Count
}

# Generate digest
$digest = @"

## 📊 Daily Digest — $timestamp

### System Health
- **Dashboard**: $dashStatus
- **Mean PLV**: $meanPLV (last $samples samples)
- **Snapshots (24h)**: $recentRuns
- **EMERGENCY_STOP**: ❌ Not active

### Content Pipeline
- **Queued Posts**: $queuedPosts
- **Auto-Post**: ❌ Disabled (review mode)

### Next Actions
- [ ] Review queued posts in ops\UOS Command Center
- [ ] Check dashboard coherence trends
- [ ] Run CDI analysis if needed

---

"@

# Write to log
if (!(Test-Path $logFile)) {
    @"
---
type: daily_ops
date: $date
---
# Daily Operations — $date

"@ | Out-File -FilePath $logFile -Encoding UTF8
}

$digest | Add-Content -Path $logFile -Encoding UTF8

Write-Host "✅ Daily digest written to: $logFile" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Dashboard: $dashStatus" -ForegroundColor Gray
Write-Host "  Mean PLV: $meanPLV" -ForegroundColor Gray
Write-Host "  Snapshots (24h): $recentRuns" -ForegroundColor Gray
Write-Host "  Queued Posts: $queuedPosts" -ForegroundColor Gray
