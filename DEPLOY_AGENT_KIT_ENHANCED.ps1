# LT vOmega.15 - Enhanced Agent Deployment
# Full agent lattice wiring with status loop

param(
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  LIVING TAPESTRY - Agent Deployment" -ForegroundColor Cyan
Write-Host "  Version: Omega.15" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Paths
$projectPath = "C:\Users\alexl\Desktop\tapestry-codex-starter"
$vaultPath = "C:\Users\alexl\the living tapestry"
$logPath = Join-Path $projectPath "logs"
$alertsPath = Join-Path $vaultPath "alerts"
$agentsPath = Join-Path $vaultPath "OS\agents"

# Ensure directories exist
@($logPath, $alertsPath, $agentsPath) | ForEach-Object {
    if (!(Test-Path $_)) {
        New-Item -Path $_ -ItemType Directory -Force | Out-Null
        Write-Host "Created: $_" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "STEP 1: Validating Prerequisites" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor DarkCyan

# Check .env.local
$envPath = Join-Path $projectPath ".env.local"
if (!(Test-Path $envPath)) {
    Write-Host "WARNING: .env.local not found" -ForegroundColor Yellow
    Write-Host "Run OAUTH_SETUP.ps1 first for full functionality" -ForegroundColor Yellow
} else {
    Write-Host "Config: OK" -ForegroundColor Green
}

# Check vault
if (!(Test-Path $vaultPath)) {
    Write-Host "ERROR: Vault not found at $vaultPath" -ForegroundColor Red
    exit 1
}
Write-Host "Vault: OK" -ForegroundColor Green

Write-Host ""
Write-Host "STEP 2: Creating Agent Lattice" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

# Define agents with full configuration
$agents = @(
    @{
        name = "Sentinel"
        priority = 1
        port = 3001
        functions = @("audit", "ip_protect", "pii_guard", "security")
        mode = "confirm"
        status = "initialized"
    },
    @{
        name = "Weaver"
        priority = 2
        port = 3002
        functions = @("vault_sync", "drive_sync", "media_index", "exif")
        mode = "auto"
        status = "initialized"
    },
    @{
        name = "Hermes"
        priority = 3
        port = 3004
        functions = @("draft", "route", "approve", "publish")
        mode = "review"
        status = "initialized"
    },
    @{
        name = "Scribe"
        priority = 4
        port = 3005
        functions = @("research", "archive", "transcript", "log")
        mode = "auto"
        status = "initialized"
    },
    @{
        name = "Ledger"
        priority = 5
        port = 3006
        functions = @("finance", "budget", "resonance", "approval")
        mode = "confirm"
        status = "initialized"
    },
    @{
        name = "Janus"
        priority = 6
        port = 3003
        functions = @("context", "tone", "theme", "audience")
        mode = "auto"
        status = "initialized"
    },
    @{
        name = "Choir"
        priority = 7
        port = 3002
        functions = @("ai_mesh", "refine", "consensus", "token")
        mode = "auto"
        status = "initialized"
    }
)

# Create agent directories and status files
foreach ($agent in $agents) {
    $agentDir = Join-Path $agentsPath $agent.name
    
    if (!(Test-Path $agentDir)) {
        New-Item -Path $agentDir -ItemType Directory -Force | Out-Null
    }
    
    # Create status.json
    $statusFile = Join-Path $agentDir "status.json"
    $statusData = @{
        name = $agent.name
        priority = $agent.priority
        port = $agent.port
        functions = $agent.functions
        mode = $agent.mode
        status = $agent.status
        timestamp = (Get-Date).ToString("o")
        health = "ready"
        uptime = 0
    }
    
    $statusData | ConvertTo-Json -Depth 4 | Out-File -FilePath $statusFile -Encoding UTF8
    
    Write-Host "[$($agent.priority)/7] $($agent.name) - Initialized (port $($agent.port))" -ForegroundColor Green
}

Write-Host ""
Write-Host "STEP 3: Configuring Routes" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

# Create routing configuration
$routeConfig = @{
    routes = @{
        resonance = @("@resonantroot")
        illumination = @("@newilluminati")
        consciousness = @("@realeyesrealizinglies")
        video = @("tiktok", "youtube")
    }
    defaults = @{
        approval_required = @("@newilluminati", "@realeyesrealizinglies", "tiktok", "youtube")
        auto_approve = @("@resonantroot")
    }
    cadence = @{
        resonance = "PT6H"
        illumination = "P1D"
        consciousness = "P1D"
    }
    windows = @{
        quiet_hours = @("23:00-07:00")
    }
}

$routeConfigPath = Join-Path $agentsPath "hermes\route_config.json"
$routeConfig | ConvertTo-Json -Depth 4 | Out-File -FilePath $routeConfigPath -Encoding UTF8

Write-Host "Route Configuration: Created" -ForegroundColor Green
Write-Host "  - Resonance -> @resonantroot (auto-approve)" -ForegroundColor Gray
Write-Host "  - Illumination -> @newilluminati (manual)" -ForegroundColor Gray
Write-Host "  - Consciousness -> @realeyesrealizinglies (manual)" -ForegroundColor Gray
Write-Host ""

Write-Host "STEP 4: Creating Agent Mesh Topology" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

# Create mesh topology
$meshTopology = @{
    version = "omega.15"
    timestamp = (Get-Date).ToString("o")
    agents = $agents
    integrations = @{
        google = @("Drive", "Photos", "Gmail", "Calendar", "YouTube")
        social = @("Instagram", "TikTok", "YouTube", "Quora")
        workspace = @("Linear", "Confluence", "Notion", "GitHub")
        ai_mesh = @("Claude", "Gemini", "Grok", "DeepMind", "Copilot")
    }
    metrics = @{
        belief_drift = 0.73
        resonance_ratio = 0.91
        coherence_index = "computing"
    }
}

$meshPath = Join-Path $vaultPath "ops\agent_mesh_current.json"
$meshTopology | ConvertTo-Json -Depth 5 | Out-File -FilePath $meshPath -Encoding UTF8

Write-Host "Agent Mesh Topology: Saved" -ForegroundColor Green
Write-Host "  Location: ops\agent_mesh_current.json" -ForegroundColor Gray
Write-Host ""

Write-Host "STEP 5: Deployment Summary" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

Write-Host "Agents Initialized: 7/7" -ForegroundColor Green
Write-Host "Routes Configured: 4" -ForegroundColor Green
Write-Host "Mesh Topology: Wired" -ForegroundColor Green
Write-Host ""

# Log deployment
$logFile = Join-Path $logPath "deploy_$((Get-Date).ToString('yyyyMMdd_HHmmss')).txt"
$logContent = @"
LIVING TAPESTRY DEPLOYMENT LOG
================================
Timestamp: $(Get-Date -Format "o")
Version: Omega.15
Project: $projectPath
Vault: $vaultPath

AGENTS DEPLOYED:
$($agents | ForEach-Object { "  - $($_.name) (priority $($_.priority), port $($_.port))" } | Out-String)

ROUTES CONFIGURED:
  - @resonantroot (auto-approve, PT6H cadence)
  - @newilluminati (manual, P1D cadence)
  - @realeyesrealizinglies (manual, P1D cadence)
  - TikTok/YouTube (manual)

STATUS: INITIALIZED
NEXT: Run STATUS_CHECK.ps1 to verify
"@

$logContent | Out-File -FilePath $logFile -Encoding UTF8

Write-Host "Log saved: $logFile" -ForegroundColor Green
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Verify: .\STATUS_CHECK.ps1" -ForegroundColor Yellow
Write-Host "2. OAuth: .\OAUTH_SETUP.ps1" -ForegroundColor Yellow
Write-Host "3. Activate: .\ACTIVATE_AGENTS.ps1" -ForegroundColor Yellow
Write-Host "4. Monitor: Dashboard at localhost:5055" -ForegroundColor Yellow
Write-Host ""
Write-Host "Agent lattice wired successfully!" -ForegroundColor Cyan
Write-Host ""
