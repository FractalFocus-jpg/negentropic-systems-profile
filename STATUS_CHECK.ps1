# ⬢ System Status Check — Complete Health Report

param(
    [switch]$Detailed = $false,
    [switch]$JsonOutput = $false
)

$ErrorActionPreference = "Stop"

$banner = @"

  ⬢ LIVING TAPESTRY OS vΩ ⬢
  System Status Check
  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"@

if (!$JsonOutput) {
    Write-Host $banner -ForegroundColor Cyan
}

$vaultRoot = "C:\Users\alexl\the living tapestry"
$repoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"

# Collect system status
$status = @{
    timestamp = (Get-Date).ToString("o")
    overall_health = "UNKNOWN"
    components = @{}
    metrics = @{}
    recommendations = @()
}

# Check Dashboard
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5055/snapshot.json" -TimeoutSec 3
    $dashData = $response.Content | ConvertFrom-Json
    $status.components.dashboard = @{
        status = "OPERATIONAL"
        plv = $dashData.plv
        samples = $dashData.samples
    }
    $status.metrics.plv = $dashData.plv
} catch {
    $status.components.dashboard = @{status = "OFFLINE"}
    $status.recommendations += "Start dashboard: .\START_DASHBOARD.bat"
}

# Check Agents
$agentsPath = Join-Path $vaultRoot "OS\agents"
$agents = @("Sentinel", "Weaver", "Hermes", "Scribe", "Ledger", "Janus", "Choir")
$agentStatus = @{}

foreach ($agent in $agents) {
    $statusFile = Join-Path $agentsPath "$agent\status.json"
    if (Test-Path $statusFile) {
        $agentData = Get-Content $statusFile | ConvertFrom-Json
        $agentStatus[$agent] = $agentData.status
    } else {
        $agentStatus[$agent] = "not_initialized"
    }
}

$status.components.agents = $agentStatus
$activeAgents = ($agentStatus.Values | Where-Object { $_ -eq "active" }).Count
$status.metrics.active_agents = "$activeAgents/7"

if ($activeAgents -eq 0) {
    $status.recommendations += "Activate agents: .\ACTIVATE_AGENTS.ps1 -DryRun:`$false"
}

# Check OAuth
$envFile = Join-Path $repoRoot ".env.local"
$oauthStatus = @{
    google = $false
    tiktok = $false
    instagram = $false
}

if (Test-Path $envFile) {
    $envContent = Get-Content $envFile -Raw
    $oauthStatus.google = $envContent -match "GMAIL_CLIENT_ID=.+\w"
    $oauthStatus.tiktok = $envContent -match "TIKTOK_CLIENT_KEY=.+\w"
    $oauthStatus.instagram = $envContent -match "IG_APP_ID=.+\w"
}

$status.components.oauth = $oauthStatus
$oauthCount = ($oauthStatus.Values | Where-Object { $_ }).Count
$status.metrics.oauth_configured = "$oauthCount/3"

if ($oauthCount -eq 0) {
    $status.recommendations += "Configure OAuth: .\scripts\auth\OAUTH_WIZARD.ps1"
}

# Check Scheduled Tasks
$taskStatus = @{}
$tasks = @("TapestryCoherenceSnapshot", "TapestryCDIHourly")

foreach ($taskName in $tasks) {
    try {
        $task = schtasks /Query /TN $taskName /FO LIST 2>$null
        $taskStatus[$taskName] = if ($task) { "SCHEDULED" } else { "NOT_FOUND" }
    } catch {
        $taskStatus[$taskName] = "NOT_FOUND"
    }
}

$status.components.scheduled_tasks = $taskStatus

# Check Vault Structure
$criticalPaths = @(
    "OS\OS_MANIFEST.yaml",
    "OS\STATUS_DASHBOARD.md",
    "ops\UOS Command Center.md",
    "dashboards\coherence-index.md"
)

$vaultIntegrity = $true
foreach ($path in $criticalPaths) {
    $fullPath = Join-Path $vaultRoot $path
    if (!(Test-Path $fullPath)) {
        $vaultIntegrity = $false
        break
    }
}

$status.components.vault_integrity = if ($vaultIntegrity) { "OK" } else { "DEGRADED" }

# Check Git Status
try {
    $gitStatus = git -C $repoRoot status --porcelain 2>$null
    $uncommittedChanges = ($gitStatus | Measure-Object -Line).Lines
    $status.components.git = @{
        uncommitted_changes = $uncommittedChanges
        status = if ($uncommittedChanges -eq 0) { "CLEAN" } else { "UNCOMMITTED" }
    }
} catch {
    $status.components.git = @{status = "UNKNOWN"}
}

# Determine overall health
$criticalIssues = 0
if ($status.components.dashboard.status -eq "OFFLINE") { $criticalIssues++ }
if ($activeAgents -eq 0) { $criticalIssues++ }
if (!$vaultIntegrity) { $criticalIssues++ }

$status.overall_health = if ($criticalIssues -eq 0 -and $oauthCount -gt 0) {
    "HEALTHY"
} elseif ($criticalIssues -eq 0) {
    "OPERATIONAL"
} elseif ($criticalIssues -le 2) {
    "DEGRADED"
} else {
    "CRITICAL"
}

# Output
if ($JsonOutput) {
    $status | ConvertTo-Json -Depth 10
} else {
    # Visual output
    $healthColor = switch ($status.overall_health) {
        "HEALTHY" { "Green" }
        "OPERATIONAL" { "Cyan" }
        "DEGRADED" { "Yellow" }
        "CRITICAL" { "Red" }
    }
    
    Write-Host "📊 OVERALL HEALTH: " -NoNewline
    Write-Host $status.overall_health -ForegroundColor $healthColor
    
    Write-Host "`n🎯 COMPONENTS:" -ForegroundColor Cyan
    
    # Dashboard
    $dashStatus = $status.components.dashboard.status
    Write-Host "   Dashboard: " -NoNewline
    Write-Host $dashStatus -ForegroundColor $(if ($dashStatus -eq "OPERATIONAL") { "Green" } else { "Yellow" })
    if ($status.components.dashboard.plv) {
        Write-Host "      PLV: $($status.components.dashboard.plv)" -ForegroundColor Gray
    }
    
    # Agents
    Write-Host "   Agents: " -NoNewline
    Write-Host "$activeAgents/7 active" -ForegroundColor $(if ($activeAgents -gt 0) { "Green" } else { "Yellow" })
    
    if ($Detailed) {
        foreach ($agent in $agentStatus.GetEnumerator()) {
            $color = if ($agent.Value -eq "active") { "Green" } else { "Gray" }
            Write-Host "      $($agent.Key): $($agent.Value)" -ForegroundColor $color
        }
    }
    
    # OAuth
    Write-Host "   OAuth: " -NoNewline
    Write-Host "$oauthCount/3 configured" -ForegroundColor $(if ($oauthCount -gt 0) { "Green" } else { "Yellow" })
    
    # Vault
    Write-Host "   Vault: " -NoNewline
    Write-Host $status.components.vault_integrity -ForegroundColor $(if ($vaultIntegrity) { "Green" } else { "Red" })
    
    # Git
    Write-Host "   Git: " -NoNewline
    Write-Host $status.components.git.status -ForegroundColor $(if ($status.components.git.status -eq "CLEAN") { "Green" } else { "Yellow" })
    
    # Recommendations
    if ($status.recommendations.Count -gt 0) {
        Write-Host "`n💡 RECOMMENDATIONS:" -ForegroundColor Yellow
        foreach ($rec in $status.recommendations) {
            Write-Host "   → $rec" -ForegroundColor Gray
        }
    } else {
        Write-Host "`n✅ All systems operational!" -ForegroundColor Green
    }
    
    Write-Host "`n📍 Quick Actions:" -ForegroundColor Cyan
    Write-Host "   Status Dashboard: [[OS/STATUS_DASHBOARD]]" -ForegroundColor Gray
    Write-Host "   Command Center: [[ops/UOS Command Center]]" -ForegroundColor Gray
    Write-Host "   Today's Log: OS/logs/$(Get-Date -Format 'yyyy-MM-dd').md" -ForegroundColor Gray
}
