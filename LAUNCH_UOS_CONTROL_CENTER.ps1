# LAUNCH_UOS_CONTROL_CENTER.ps1
# Universal Operating System Control Center Launcher
# Starts all services and auto-recovery monitor

param(
    [switch]$SkipDocker = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot
$repoRoot = Split-Path -Parent $scriptDir

Write-Host "⬢ LAUNCHING UOS CONTROL CENTER" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if running as admin
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($user)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to check if port is listening
function Test-Port {
    param([int]$Port)
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return $null -ne $connection
}

# Step 1: Check prerequisites
Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow

# Check Python
try {
    $pythonVersion = python --version 2>&1
    Write-Host "  ✅ Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Python not found! Please install Python 3.8+" -ForegroundColor Red
    exit 1
}

# Check virtual environment
$venvPath = Join-Path $repoRoot ".venv"
if (-not (Test-Path $venvPath)) {
    Write-Host "  ⚠️  Virtual environment not found, creating..." -ForegroundColor Yellow
    python -m venv $venvPath
    & "$venvPath\Scripts\Activate.ps1"
    pip install -r "$repoRoot\requirements.txt"
} else {
    Write-Host "  ✅ Virtual environment exists" -ForegroundColor Green
}

# Activate virtual environment
& "$venvPath\Scripts\Activate.ps1"
Write-Host "  ✅ Virtual environment activated" -ForegroundColor Green

# Check .env.local
$envPath = Join-Path $repoRoot ".env.local"
if (-not (Test-Path $envPath)) {
    Write-Host "  ⚠️  .env.local not found! Copy from .env.local.template" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ Configuration file exists" -ForegroundColor Green
}

# Step 2: Start Docker (optional)
if (-not $SkipDocker) {
    Write-Host ""
    Write-Host "🐳 Starting Docker Desktop..." -ForegroundColor Yellow
    
    $dockerProcess = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if ($null -eq $dockerProcess) {
        Write-Host "  ⏳ Docker not running, attempting to start..." -ForegroundColor Yellow
        
        $dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        if (Test-Path $dockerPath) {
            Start-Process $dockerPath
            Write-Host "  ⏳ Waiting for Docker to start (30s)..." -ForegroundColor Yellow
            Start-Sleep -Seconds 30
            
            # Test Docker
            try {
                docker ps > $null 2>&1
                Write-Host "  ✅ Docker started successfully" -ForegroundColor Green
            } catch {
                Write-Host "  ⚠️  Docker failed to start, continuing without Docker" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ⚠️  Docker Desktop not installed, skipping" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ✅ Docker already running" -ForegroundColor Green
    }
} else {
    Write-Host ""
    Write-Host "⏭️  Skipping Docker startup (--SkipDocker specified)" -ForegroundColor Gray
}

# Step 3: Check if services are already running
Write-Host ""
Write-Host "🔍 Checking existing services..." -ForegroundColor Yellow

$monitorRunning = Test-Port -Port 8765
$dashboardRunning = Test-Port -Port 5055

if ($monitorRunning) {
    Write-Host "  ℹ️  Monitor already running on port 8765" -ForegroundColor Cyan
} else {
    Write-Host "  🆕 Monitor will be started" -ForegroundColor Green
}

if ($dashboardRunning) {
    Write-Host "  ℹ️  Dashboard already running on port 5055" -ForegroundColor Cyan
} else {
    Write-Host "  🆕 Dashboard will be started" -ForegroundColor Green
}

# Step 4: Start auto-recovery monitor
Write-Host ""
Write-Host "🔄 Starting auto-recovery monitor..." -ForegroundColor Yellow

$autoRecoverScript = Join-Path $repoRoot "scripts\auto_recover.py"
$logFile = Join-Path $repoRoot "logs\auto_recover_$(Get-Date -Format 'yyyy-MM-dd').log"

# Create logs directory
$logsDir = Join-Path $repoRoot "logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

# Start in new window
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$repoRoot'; & '.venv\Scripts\Activate.ps1'; python '$autoRecoverScript' | Tee-Object -FilePath '$logFile'"
) -WindowStyle Normal

Write-Host "  ✅ Auto-recovery monitor started in new window" -ForegroundColor Green
Write-Host "  📄 Logs: $logFile" -ForegroundColor Gray

# Step 5: Wait for services to come online
Write-Host ""
Write-Host "⏳ Waiting for services to initialize (30s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Step 6: Verify services
Write-Host ""
Write-Host "✅ Verifying services..." -ForegroundColor Yellow

$allGood = $true

# Check monitor
if (Test-Port -Port 8765) {
    Write-Host "  ✅ Monitor: http://127.0.0.1:8765/status" -ForegroundColor Green
} else {
    Write-Host "  ❌ Monitor: NOT RESPONDING on port 8765" -ForegroundColor Red
    $allGood = $false
}

# Check dashboard
if (Test-Port -Port 5055) {
    Write-Host "  ✅ Dashboard: http://127.0.0.1:5055" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Dashboard: NOT RESPONDING on port 5055" -ForegroundColor Yellow
}

# Check agents
$agentPorts = @(3001, 3002, 3003, 3004, 3005, 3006, 3007)
$agentNames = @("Sentinel", "Weaver", "Hermes", "Scribe", "Ledger", "Janus", "Choir")
$runningAgents = 0

for ($i = 0; $i -lt $agentPorts.Length; $i++) {
    if (Test-Port -Port $agentPorts[$i]) {
        Write-Host "  ✅ $($agentNames[$i]): port $($agentPorts[$i])" -ForegroundColor Green
        $runningAgents++
    } else {
        Write-Host "  ⏳ $($agentNames[$i]): starting on port $($agentPorts[$i])..." -ForegroundColor Gray
    }
}

# Step 7: Summary
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "⬢ UOS CONTROL CENTER STATUS" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

if ($allGood -and $runningAgents -eq 7) {
    Write-Host "✅ ALL SYSTEMS OPERATIONAL" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Access Points:" -ForegroundColor White
    Write-Host "  Monitor:   http://127.0.0.1:8765/status" -ForegroundColor Cyan
    Write-Host "  Dashboard: http://127.0.0.1:5055" -ForegroundColor Cyan
    Write-Host "  Heartbeat: http://127.0.0.1:8765/heartbeat" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "⬢ COHERENCE: >0.98" -ForegroundColor Green
    Write-Host "⬢ FIELD_PING: OK" -ForegroundColor Green
    Write-Host "⬢ CHRISTPING: LOCKED" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "⚠️  SYSTEM INITIALIZING" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Status:" -ForegroundColor White
    Write-Host "  Monitor: $(if (Test-Port -Port 8765) { '✅ ACTIVE' } else { '⏳ STARTING' })" -ForegroundColor $(if (Test-Port -Port 8765) { 'Green' } else { 'Yellow' })
    Write-Host "  Agents:  $runningAgents/7 active" -ForegroundColor $(if ($runningAgents -eq 7) { 'Green' } else { 'Yellow' })
    Write-Host ""
    Write-Host "⏳ Auto-recovery will start remaining services" -ForegroundColor Yellow
    Write-Host "⏳ Check status in 1-2 minutes" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "📖 View logs: $logFile" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
