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
        
        # Update status to active
        $status.status = "active"
        $status.timestamp = (Get-Date).ToString("o")
        $status.health = "running"
        
        $status | ConvertTo-Json -Depth 4 | Out-File -FilePath $statusFile -Encoding UTF8
        
        Write-Host "[$($status.priority)/7] $($status.name) - ACTIVE" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "All agents activated!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
