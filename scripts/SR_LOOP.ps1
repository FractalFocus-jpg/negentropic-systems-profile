# ⬢ SR-Loop — Self-Regenerative Loop
# Observe → Compress → Redeploy cycle

param(
    [switch]$ContinuousMode = $false,
    [int]$IntervalMinutes = 60
)

$ErrorActionPreference = "Stop"

Write-Host "`n🌊 SR-LOOP — Self-Regenerative Cycle" -ForegroundColor Cyan
Write-Host "   Observe → Compress → Redeploy" -ForegroundColor Gray
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$vaultRoot = "C:\Users\alexl\the living tapestry"
$repoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"
$logsPath = Join-Path $vaultRoot "OS\logs"

function Invoke-SRCycle {
    $cycleStart = Get-Date
    Write-Host "`n🔄 SR-Cycle $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
    
    # OBSERVE: Gather system state
    Write-Host "   👁️  OBSERVE..." -ForegroundColor Yellow
    
    $observations = @{}
    
    # Check dashboard
    try {
        $dashResponse = Invoke-WebRequest -Uri "http://localhost:5055/snapshot.json" -TimeoutSec 3
        $dashData = $dashResponse.Content | ConvertFrom-Json
        $observations.Dashboard = @{
            Status = "✅ Running"
            LastPLV = $dashData.plv
            Samples = $dashData.samples
        }
        Write-Host "      Dashboard: PLV=$($dashData.plv)" -ForegroundColor Gray
    } catch {
        $observations.Dashboard = @{Status = "❌ Offline"}
    }
    
    # Check agent status
    $agentsPath = Join-Path $vaultRoot "OS\agents"
    $agentStatuses = @()
    $agents = @("Sentinel", "Weaver", "Hermes", "Scribe", "Ledger", "Janus", "Choir")
    
    foreach ($agent in $agents) {
        $statusFile = Join-Path $agentsPath "$agent\status.json"
        if (Test-Path $statusFile) {
            $status = Get-Content $statusFile | ConvertFrom-Json
            $agentStatuses += @{Name=$agent; Status=$status.status}
        }
    }
    $observations.Agents = $agentStatuses
    Write-Host "      Agents: $($agentStatuses.Count) monitored" -ForegroundColor Gray
    
    # Gather logs
    $todayLog = Join-Path $logsPath "$(Get-Date -Format 'yyyy-MM-dd').md"
    if (Test-Path $todayLog) {
        $logContent = Get-Content $todayLog -Raw
        $logLines = $logContent.Split("`n").Count
        $observations.Logs = @{Lines = $logLines; LastUpdate = (Get-Item $todayLog).LastWriteTime}
        Write-Host "      Logs: $logLines lines today" -ForegroundColor Gray
    }
    
    # COMPRESS: Extract patterns & insights
    Write-Host "   🗜️  COMPRESS..." -ForegroundColor Yellow
    
    $insights = @{
        SystemHealth = "Healthy"
        ActiveAgents = ($agentStatuses | Where-Object { $_.Status -eq "active" }).Count
        DormantAgents = ($agentStatuses | Where-Object { $_.Status -ne "active" }).Count
        DashboardStatus = $observations.Dashboard.Status
        CoherenceTrend = "Stable"  # Would analyze PLV history
        RecommendedActions = @()
    }
    
    # Determine recommendations
    if ($observations.Dashboard.Status -like "*Offline*") {
        $insights.RecommendedActions += "Restart dashboard"
        $insights.SystemHealth = "Degraded"
    }
    
    if ($insights.ActiveAgents -eq 0) {
        $insights.RecommendedActions += "Activate agents"
        $insights.SystemHealth = "Dormant"
    }
    
    if ($insights.RecommendedActions.Count -eq 0) {
        $insights.RecommendedActions += "Continue monitoring"
    }
    
    Write-Host "      Health: $($insights.SystemHealth)" -ForegroundColor $(
        switch ($insights.SystemHealth) {
            "Healthy" { "Green" }
            "Stable" { "Green" }
            "Degraded" { "Yellow" }
            default { "Red" }
        }
    )
    
    # REDEPLOY: Update configurations based on insights
    Write-Host "   🚀 REDEPLOY..." -ForegroundColor Yellow
    
    # Update STATUS_DASHBOARD
    $statusDash = Join-Path $vaultRoot "OS\STATUS_DASHBOARD.md"
    if (Test-Path $statusDash) {
        $content = Get-Content $statusDash -Raw
        
        # Update metrics section
        $metricsUpdate = @"
**Coherence**: Last PLV = $($observations.Dashboard.LastPLV ?? "N/A")  
**Active Agents**: $($insights.ActiveAgents)/7  
**System Health**: $($insights.SystemHealth)  
**Last SR-Cycle**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@
        
        # Replace metrics section (simplified for now)
        $content = $content -replace "(?s)## 📊 Current Metrics.*?---", "## 📊 Current Metrics`n`n$metricsUpdate`n`n---"
        $content | Out-File -FilePath $statusDash -Encoding UTF8
        
        Write-Host "      ✅ Updated STATUS_DASHBOARD" -ForegroundColor Green
    }
    
    # Log SR-cycle
    $logEntry = @"

## [SR-CYCLE] — $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

### Observations
- Dashboard: $($observations.Dashboard.Status)
- Active Agents: $($insights.ActiveAgents)/7
- Log Lines Today: $($observations.Logs.Lines ?? 0)

### Insights
- System Health: **$($insights.SystemHealth)**
- Coherence: $($observations.Dashboard.LastPLV ?? "N/A")
- Trend: $($insights.CoherenceTrend)

### Actions
$($insights.RecommendedActions | ForEach-Object { "- $_" } | Out-String)

**Cycle Duration**: $([math]::Round(((Get-Date) - $cycleStart).TotalSeconds, 2))s

"@
    Add-Content -Path $todayLog -Value $logEntry -Encoding UTF8
    
    Write-Host "`n✅ SR-Cycle complete ($([math]::Round(((Get-Date) - $cycleStart).TotalSeconds, 2))s)" -ForegroundColor Green
    
    return $insights
}

# Run cycle
if ($ContinuousMode) {
    Write-Host "🔁 Continuous mode: Running every $IntervalMinutes minutes" -ForegroundColor Cyan
    Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray
    
    while ($true) {
        Invoke-SRCycle
        Write-Host "`n⏸️  Waiting $IntervalMinutes minutes..." -ForegroundColor Yellow
        Start-Sleep -Seconds ($IntervalMinutes * 60)
    }
} else {
    $result = Invoke-SRCycle
    
    Write-Host "`n📊 System Health: $($result.SystemHealth)" -ForegroundColor Cyan
    Write-Host "🎯 Recommended Actions:" -ForegroundColor Yellow
    foreach ($action in $result.RecommendedActions) {
        Write-Host "   • $action" -ForegroundColor Gray
    }
}
