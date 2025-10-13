# ⬢ Notification System — Live Alerts to Obsidian + CLI
# Monitors system health and broadcasts hiccups/errors

param(
    [string]$Message = "",
    [string]$Level = "INFO",  # INFO, WARN, ERROR, SUCCESS
    [switch]$Monitor = $false,
    [int]$IntervalSeconds = 60
)

$ErrorActionPreference = "Stop"

$vaultRoot = "C:\Users\alexl\the living tapestry"
$alertsPath = Join-Path $vaultRoot "alerts"

# Create alerts directory if needed
if (!(Test-Path $alertsPath)) {
    New-Item -ItemType Directory -Path $alertsPath -Force | Out-Null
}

function Send-Alert {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Color mapping
    $colors = @{
        "INFO" = "Cyan"
        "WARN" = "Yellow"
        "ERROR" = "Red"
        "SUCCESS" = "Green"
    }
    
    $icons = @{
        "INFO" = "ℹ️"
        "WARN" = "⚠️"
        "ERROR" = "❌"
        "SUCCESS" = "✅"
    }
    
    # CLI broadcast
    $color = $colors[$Level]
    $icon = $icons[$Level]
    
    Write-Host "`n$icon [$Level] $timestamp" -ForegroundColor $color
    Write-Host "   $Message" -ForegroundColor White
    
    # Obsidian alert
    $todayAlert = Join-Path $alertsPath "$(Get-Date -Format 'yyyy-MM-dd').md"
    
    $alertEntry = @"

## [$Level] — $timestamp

$Message

---

"@
    
    if (!(Test-Path $todayAlert)) {
        $header = @"
---
type: alerts
date: $(Get-Date -Format 'yyyy-MM-dd')
tags: [alerts, notifications, system]
---

# System Alerts — $(Get-Date -Format 'yyyy-MM-dd')

**Live notification stream from Living Tapestry OS**

---

"@
        $header | Out-File -FilePath $todayAlert -Encoding UTF8
    }
    
    Add-Content -Path $todayAlert -Value $alertEntry -Encoding UTF8
    
    # Also log to main log
    $mainLog = Join-Path $vaultRoot "OS\logs\$(Get-Date -Format 'yyyy-MM-dd').md"
    if (Test-Path $mainLog) {
        $logEntry = @"

## [ALERT] — $timestamp
**Level**: $Level  
**Message**: $Message

"@
        Add-Content -Path $mainLog -Value $logEntry -Encoding UTF8
    }
    
    return @{
        timestamp = $timestamp
        level = $Level
        message = $Message
        alert_file = $todayAlert
    }
}

function Get-SystemHealth {
    $health = @{
        timestamp = (Get-Date).ToString("o")
        overall = "UNKNOWN"
        issues = @()
        metrics = @{}
    }
    
    # Check dashboard
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5055/snapshot.json" -TimeoutSec 3
        $dashData = $response.Content | ConvertFrom-Json
        $health.metrics.plv = $dashData.plv
        $health.metrics.dashboard = "OPERATIONAL"
        
        # Check PLV threshold
        if ($dashData.plv -lt 0.55) {
            $health.issues += "Low coherence: PLV = $($dashData.plv) (< 0.55)"
        }
    } catch {
        $health.metrics.dashboard = "OFFLINE"
        $health.issues += "Dashboard offline (localhost:5055)"
    }
    
    # Check agents
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
    
    $health.metrics.active_agents = "$activeCount/7"
    
    if ($activeCount -eq 0) {
        $health.issues += "No agents active (0/7)"
    }
    
    # Check disk space
    $drive = Get-PSDrive C
    $percentFree = [math]::Round(($drive.Free / ($drive.Free + $drive.Used)) * 100, 1)
    $health.metrics.disk_free_percent = $percentFree
    
    if ($percentFree -lt 10) {
        $health.issues += "Critical disk space: $percentFree% free"
    } elseif ($percentFree -lt 20) {
        $health.issues += "Low disk space: $percentFree% free"
    }
    
    # Determine overall health
    $criticalIssues = $health.issues | Where-Object { $_ -like "*Critical*" -or $_ -like "*offline*" }
    
    if ($criticalIssues.Count -gt 0) {
        $health.overall = "CRITICAL"
    } elseif ($health.issues.Count -gt 0) {
        $health.overall = "DEGRADED"
    } else {
        $health.overall = "HEALTHY"
    }
    
    return $health
}

if ($Message -ne "") {
    # Send single alert
    $result = Send-Alert -Message $Message -Level $Level
    Write-Host "   📄 Alert saved to: $($result.alert_file)" -ForegroundColor Gray
    exit 0
}

if ($Monitor) {
    Write-Host "`n🔔 Notification System — Monitoring Mode" -ForegroundColor Cyan
    Write-Host "   Interval: $IntervalSeconds seconds" -ForegroundColor Gray
    Write-Host "   Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    $lastHealth = "UNKNOWN"
    
    while ($true) {
        $health = Get-SystemHealth
        
        # Alert on health changes
        if ($health.overall -ne $lastHealth) {
            if ($health.overall -eq "CRITICAL") {
                Send-Alert -Message "System health: CRITICAL. Issues: $($health.issues -join '; ')" -Level "ERROR" | Out-Null
            } elseif ($health.overall -eq "DEGRADED") {
                Send-Alert -Message "System health: DEGRADED. Issues: $($health.issues -join '; ')" -Level "WARN" | Out-Null
            } elseif ($health.overall -eq "HEALTHY" -and $lastHealth -ne "UNKNOWN") {
                Send-Alert -Message "System health: HEALTHY. All issues resolved." -Level "SUCCESS" | Out-Null
            }
            
            $lastHealth = $health.overall
        }
        
        # Alert on specific issues
        foreach ($issue in $health.issues) {
            if ($issue -like "*Critical*" -or $issue -like "*offline*") {
                Send-Alert -Message $issue -Level "ERROR" | Out-Null
            } elseif ($issue -like "*Low*") {
                Send-Alert -Message $issue -Level "WARN" | Out-Null
            }
        }
        
        # Status update
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Health: $($health.overall) | PLV: $($health.metrics.plv) | Agents: $($health.metrics.active_agents)" -ForegroundColor Gray
        
        Start-Sleep -Seconds $IntervalSeconds
    }
}

# Default: Show notification status
Write-Host "`n🔔 Notification System" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Write-Host "`n📊 Current Status:" -ForegroundColor Yellow
$health = Get-SystemHealth

$healthColor = switch ($health.overall) {
    "HEALTHY" { "Green" }
    "DEGRADED" { "Yellow" }
    "CRITICAL" { "Red" }
    default { "Gray" }
}

Write-Host "   Overall Health: " -NoNewline
Write-Host $health.overall -ForegroundColor $healthColor

Write-Host "`n📈 Metrics:" -ForegroundColor Yellow
foreach ($metric in $health.metrics.GetEnumerator()) {
    Write-Host "   $($metric.Key): $($metric.Value)" -ForegroundColor Gray
}

if ($health.issues.Count -gt 0) {
    Write-Host "`n⚠️  Issues Detected:" -ForegroundColor Yellow
    foreach ($issue in $health.issues) {
        Write-Host "   • $issue" -ForegroundColor Red
    }
} else {
    Write-Host "`n✅ No issues detected" -ForegroundColor Green
}

Write-Host "`n📂 Alert Location: $alertsPath" -ForegroundColor Cyan
Write-Host "`n🎯 Usage:" -ForegroundColor Cyan
Write-Host "   Send alert: -Message 'Your message' -Level INFO|WARN|ERROR|SUCCESS" -ForegroundColor Gray
Write-Host "   Monitor: -Monitor -IntervalSeconds 60" -ForegroundColor Gray
