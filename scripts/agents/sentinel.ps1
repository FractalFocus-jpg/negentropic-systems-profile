# ⬢ Sentinel Agent — Security & Health Monitor
# Continuous monitoring, audits, rollback capability

param(
    [switch]$FullAudit = $false,
    [switch]$QuickCheck = $true
)

$ErrorActionPreference = "Stop"

Write-Host "`n🛡️  Sentinel — Security & Health Monitor" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$vaultRoot = "C:\Users\alexl\the living tapestry"
$repoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"
$sentinelPath = Join-Path $vaultRoot "OS\agents\Sentinel"

# Security checks
$checks = @{
    "EMERGENCY_STOP" = $false
    "Dashboard" = $false
    "Vault_Integrity" = $false
    "Token_Status" = $false
    "Agent_Health" = $false
    "Disk_Space" = $false
}

Write-Host "🔍 Running security checks..." -ForegroundColor Yellow

# Check for EMERGENCY_STOP
$emergencyFile = Join-Path $repoRoot "EMERGENCY_STOP"
if (Test-Path $emergencyFile) {
    Write-Host "   🛑 EMERGENCY STOP ACTIVE!" -ForegroundColor Red
    $checks."EMERGENCY_STOP" = "ACTIVE"
} else {
    Write-Host "   ✅ No emergency stop" -ForegroundColor Green
    $checks."EMERGENCY_STOP" = "OK"
}

# Check dashboard
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5055/snapshot.json" -TimeoutSec 3
    Write-Host "   ✅ Dashboard operational" -ForegroundColor Green
    $checks."Dashboard" = "OK"
} catch {
    Write-Host "   ⚠️  Dashboard offline" -ForegroundColor Yellow
    $checks."Dashboard" = "OFFLINE"
}

# Check vault integrity
$criticalPaths = @(
    (Join-Path $vaultRoot "OS\OS_MANIFEST.yaml"),
    (Join-Path $vaultRoot "OS\STATUS_DASHBOARD.md"),
    (Join-Path $vaultRoot "ops\UOS Command Center.md")
)

$allPresent = $true
foreach ($path in $criticalPaths) {
    if (!(Test-Path $path)) {
        $allPresent = $false
        Write-Host "   ⚠️  Missing: $path" -ForegroundColor Yellow
    }
}

if ($allPresent) {
    Write-Host "   ✅ Vault integrity OK" -ForegroundColor Green
    $checks."Vault_Integrity" = "OK"
} else {
    Write-Host "   ⚠️  Vault integrity issues" -ForegroundColor Yellow
    $checks."Vault_Integrity" = "DEGRADED"
}

# Check OAuth tokens
$envFile = Join-Path $repoRoot ".env.local"
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile -Raw
    
    $hasGoogle = $envContent -match "GMAIL_CLIENT_ID=.+\w"
    $hasTikTok = $envContent -match "TIKTOK_CLIENT_KEY=.+\w"
    $hasInstagram = $envContent -match "IG_APP_ID=.+\w"
    
    $tokenCount = ($hasGoogle, $hasTikTok, $hasInstagram | Where-Object { $_ }).Count
    
    if ($tokenCount -gt 0) {
        Write-Host "   ✅ OAuth tokens: $tokenCount/3 configured" -ForegroundColor Green
        $checks."Token_Status" = "$tokenCount/3"
    } else {
        Write-Host "   ⏸️  No OAuth tokens configured" -ForegroundColor Yellow
        $checks."Token_Status" = "NONE"
    }
} else {
    Write-Host "   ⚠️  .env.local not found" -ForegroundColor Yellow
    $checks."Token_Status" = "NO_CONFIG"
}

# Check agent health
$agentsPath = Join-Path $vaultRoot "OS\agents"
$agents = @("Sentinel", "Weaver", "Hermes", "Scribe", "Ledger", "Janus", "Choir")
$activeCount = 0

foreach ($agent in $agents) {
    $statusFile = Join-Path $agentsPath "$agent\status.json"
    if (Test-Path $statusFile) {
        $status = Get-Content $statusFile | ConvertFrom-Json
        if ($status.status -eq "active") {
            $activeCount++
        }
    }
}

Write-Host "   ✅ Active agents: $activeCount/7" -ForegroundColor $(if ($activeCount -gt 0) { "Green" } else { "Yellow" })
$checks."Agent_Health" = "$activeCount/7"

# Check disk space
$drive = Get-PSDrive C
$freeGB = [math]::Round($drive.Free / 1GB, 2)
$usedGB = [math]::Round($drive.Used / 1GB, 2)
$percentFree = [math]::Round(($drive.Free / ($drive.Free + $drive.Used)) * 100, 1)

if ($percentFree -lt 10) {
    Write-Host "   ⚠️  Disk space low: $percentFree% free" -ForegroundColor Red
    $checks."Disk_Space" = "LOW"
} elseif ($percentFree -lt 20) {
    Write-Host "   ⚠️  Disk space: $percentFree% free" -ForegroundColor Yellow
    $checks."Disk_Space" = "WARN"
} else {
    Write-Host "   ✅ Disk space: $freeGB GB free ($percentFree%)" -ForegroundColor Green
    $checks."Disk_Space" = "OK"
}

# Determine overall health
$criticalIssues = ($checks.Values | Where-Object { $_ -in @("ACTIVE", "OFFLINE", "DEGRADED", "LOW", "NO_CONFIG") }).Count
$warnings = ($checks.Values | Where-Object { $_ -in @("WARN", "NONE") }).Count

$overallHealth = if ($criticalIssues -gt 0) {
    "⚠️  DEGRADED"
} elseif ($warnings -gt 0) {
    "🟡 WARNINGS"
} else {
    "✅ HEALTHY"
}

# Summary
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📊 SYSTEM HEALTH: $overallHealth" -ForegroundColor $(
    switch ($overallHealth) {
        "✅ HEALTHY" { "Green" }
        "🟡 WARNINGS" { "Yellow" }
        default { "Red" }
    }
)
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

foreach ($check in $checks.GetEnumerator()) {
    $color = switch ($check.Value) {
        "OK" { "Green" }
        {$_ -match "^\d+/\d+$"} { "Cyan" }
        {$_ -in @("OFFLINE", "ACTIVE", "DEGRADED", "LOW", "NO_CONFIG")} { "Red" }
        default { "Yellow" }
    }
    Write-Host "   $($check.Key): " -NoNewline -ForegroundColor Gray
    Write-Host $check.Value -ForegroundColor $color
}

# Log audit
$logFile = Join-Path $vaultRoot "OS\logs\$(Get-Date -Format 'yyyy-MM-dd').md"
$auditLog = @"

## [SENTINEL AUDIT] — $(Get-Date -Format 'HH:mm:ss')

**Overall Health**: $overallHealth

### Checks
$($checks.GetEnumerator() | ForEach-Object { "- $($_.Key): $($_.Value)" } | Out-String)

### Metrics
- Active Agents: $activeCount/7
- OAuth Tokens: $($checks."Token_Status")
- Disk Free: $freeGB GB ($percentFree%)

"@

Add-Content -Path $logFile -Value $auditLog -Encoding UTF8

Write-Host "`n✅ Audit complete" -ForegroundColor Green
Write-Host "📄 Logged to: $logFile" -ForegroundColor Gray
