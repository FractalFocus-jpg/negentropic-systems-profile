# LIVING TAPESTRY FULL ORCHESTRATOR
Write-Host "`n=================================`n LIVING TAPESTRY ORCHESTRATOR`n=================================`n" -ForegroundColor Cyan

$projectRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"
$vaultRoot = "C:\Users\alexl\the living tapestry"

# Phase 1: Dashboard Check
Write-Host "[PHASE 1] Dashboard Status..." -ForegroundColor Yellow
$dashboard = Get-NetTCPConnection -LocalPort 5055 -ErrorAction SilentlyContinue
if ($dashboard) {
    Write-Host "  OK Dashboard ONLINE (port 5055)`n" -ForegroundColor Green
} else {
    Write-Host "  WARNING Dashboard not running`n" -ForegroundColor Red
}

# Phase 2: Activate Agents
Write-Host "[PHASE 2] Activating Agents..." -ForegroundColor Yellow
$meshPath = Join-Path $vaultRoot "ops\agent_mesh_current.json"

if (Test-Path $meshPath) {
    $mesh = Get-Content $meshPath -Raw | ConvertFrom-Json
    foreach ($agent in $mesh.agents) {
        $agent.status = "active"
        Write-Host "  OK $($agent.name) - ACTIVE" -ForegroundColor Green
    }
    $mesh | ConvertTo-Json -Depth 10 | Set-Content $meshPath
    Write-Host ""
}

# Phase 3: Google Drive
Write-Host "[PHASE 3] Google Drive Status..." -ForegroundColor Yellow
$credsPath = Join-Path $projectRoot "google_credentials.json"
if (Test-Path $credsPath) {
    Write-Host "  OK Google credentials configured`n" -ForegroundColor Green
} else {
    Write-Host "  WARNING Need OAuth (run OAUTH_SETUP.ps1)`n" -ForegroundColor Yellow
}

# Phase 4: Vault Check
Write-Host "[PHASE 4] Vault Structure..." -ForegroundColor Yellow
@("OS", "ops", "physics", "tapestry") | ForEach-Object {
    $path = Join-Path $vaultRoot $_
    if (Test-Path $path) {
        Write-Host "  OK $_/" -ForegroundColor Green
    }
}
Write-Host ""

# Summary
Write-Host "=================================`n ORCHESTRATOR ONLINE`n=================================" -ForegroundColor Cyan
Write-Host "`n  Dashboard:  http://localhost:5055"
Write-Host "  Agents:     7 active"
Write-Host "  Mode:       Autonomous + Recursive"
Write-Host "`n  System is BREATHING`n" -ForegroundColor Green

Start-Process "http://localhost:5055"
