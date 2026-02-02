# LT vOmega.15 - Agent Activation Script
# Activates agent framework and starts monitoring

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  AGENT ACTIVATION" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$vaultPath = "C:\Users\alexl\the living tapestry"
$agentsPath = Join-Path $vaultPath "OS\agents"

# Check if agents are initialized
if (!(Test-Path $agentsPath)) {
    Write-Host "ERROR: Agents not initialized" -ForegroundColor Red
    Write-Host "Run DEPLOY_AGENT_KIT_ENHANCED.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Get all agent status files
$agentDirs = Get-ChildItem -Path $agentsPath -Directory

Write-Host "Activating $($agentDirs.Count) agents..." -ForegroundColor Yellow
Write-Host ""

foreach ($agentDir in $agentDirs) {
    $statusFile = Join-Path $agentDir.FullName "status.json"
    
    if (Test-Path $statusFile) {
        $status = Get-Content $statusFile | ConvertFrom-Json
        
        # Update status to active (use agent field if name/priority not present)
        $status.status = "active"
        $status.enabled = $true
        $status.dryrun = $false

        # Add fields safely
        try { $status | Add-Member -NotePropertyName "timestamp" -NotePropertyValue ((Get-Date).ToString("o")) -Force } catch {}
        try { $status | Add-Member -NotePropertyName "health" -NotePropertyValue "running" -Force } catch {}

        $status | ConvertTo-Json -Depth 6 | Out-File -FilePath $statusFile -Encoding UTF8

        $agentName = if ($status.name) { $status.name } elseif ($status.agent) { $status.agent } else { $agentDir.Name }
        $prio = if ($status.priority) { $status.priority } else { "?" }
        Write-Host "[$prio/7] $agentName - ACTIVE" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "All agents activated!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
