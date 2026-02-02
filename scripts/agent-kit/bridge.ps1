# Agent Kit Bridge (sanitized ASCII version)
# Purpose: initialize bridge config + basic connectivity tests

param(
    [switch]$Initialize = $false,
    [switch]$SyncContext = $false,
    [switch]$TestConnection = $false
)

$ErrorActionPreference = "Stop"

$repoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"
$vaultRoot = "C:\Users\alexl\the living tapestry"

$agentKitPath = Join-Path $repoRoot "scripts\agent-kit"
$bridgeConfigPath = Join-Path $agentKitPath "bridge_config.json"

function Ensure-Dir($p) {
    if (!(Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

function Load-AgentKitConfig {
    $cfgPath = Join-Path $agentKitPath "bridge_config.json"
    if (Test-Path $cfgPath) {
        try { return (Get-Content $cfgPath -Raw | ConvertFrom-Json) } catch { return $null }
    }
    return $null
}

if ($Initialize) {
    Write-Host "Initializing Agent Kit Bridge..." -ForegroundColor Cyan

    Ensure-Dir $agentKitPath
    Ensure-Dir (Join-Path $vaultRoot "alerts")
    Ensure-Dir (Join-Path $vaultRoot "OS\logs")

    # Minimal config (expand later)
    $bridgeConfig = @{ 
        initialized = (Get-Date).ToString("o")
        orchestrator = "clawdbot"
        vault_root = $vaultRoot
        repo_root = $repoRoot
        security_mode = "confirm"
        audit_enabled = $true
    } | ConvertTo-Json -Depth 10

    $bridgeConfig | Out-File -FilePath $bridgeConfigPath -Encoding utf8

    Write-Host "Bridge configuration saved" -ForegroundColor Green
    Write-Host ("Location: {0}" -f $bridgeConfigPath) -ForegroundColor Gray
}

if ($SyncContext) {
    Write-Host "SyncContext is not implemented in this minimal bridge yet." -ForegroundColor Yellow
    Write-Host "(We can add it back once encoding issues are resolved.)" -ForegroundColor Gray
}

if ($TestConnection) {
    Write-Host "Testing local services..." -ForegroundColor Cyan

    $urls = @(
        "http://localhost:5055/snapshot.json",
        "http://localhost:3001/health",
        "http://localhost:3002/health",
        "http://localhost:3003/health",
        "http://localhost:3004/health",
        "http://localhost:3005/health",
        "http://localhost:3006/health"
    )

    foreach ($u in $urls) {
        try {
            $r = Invoke-WebRequest -Uri $u -TimeoutSec 3 -UseBasicParsing
            Write-Host ("OK  {0} ({1})" -f $u,$r.StatusCode) -ForegroundColor Green
        } catch {
            Write-Host ("FAIL {0}" -f $u) -ForegroundColor Yellow
        }
    }
}

# Default: show status
if (!$Initialize -and !$SyncContext -and !$TestConnection) {
    Write-Host "Agent Kit Bridge Status" -ForegroundColor Cyan
    if (Test-Path $bridgeConfigPath) {
        Write-Host "Status: Initialized" -ForegroundColor Green
        try {
            $cfg = Get-Content $bridgeConfigPath -Raw | ConvertFrom-Json
            Write-Host ("Initialized: {0}" -f $cfg.initialized) -ForegroundColor Gray
            Write-Host ("Security: {0}" -f $cfg.security_mode) -ForegroundColor Gray
        } catch {
            Write-Host "(Could not parse bridge_config.json)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Status: Not initialized" -ForegroundColor Yellow
        Write-Host "Run: .\\scripts\\agent-kit\\bridge.ps1 -Initialize" -ForegroundColor Gray
    }
}

Write-Host "Agent Kit Bridge ready" -ForegroundColor Green
