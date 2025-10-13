# ⬢ Agent Kit Bridge — OpenAI Agent Kit Integration Layer
# Connects Living Tapestry OS vΩ with OpenAI Agent Kit

param(
    [switch]$Initialize = $false,
    [switch]$SyncContext = $false,
    [switch]$TestConnection = $false
)

$ErrorActionPreference = "Stop"

Write-Host "`n⬢ Agent Kit Bridge — OpenAI Integration" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$vaultRoot = "C:\Users\alexl\the living tapestry"
$repoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"
$agentKitPath = Join-Path $repoRoot "scripts\agent-kit"

# Load environment
$envFile = Join-Path $repoRoot ".env.local"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([A-Z_]+)=(.*)$') {
            $name = $matches[1]
            $value = $matches[2]
            if ($value -and $value -ne "") {
                [Environment]::SetEnvironmentVariable($name, $value, "Process")
            }
        }
    }
}

# Agent Kit configuration
$agentKitConfig = @{
    orchestrator = "Claude"
    ai_mesh = @("Gemini", "Grok", "DeepMind", "Copilot")
    context_store = Join-Path $vaultRoot "OS\context-store"
    notifications = Join-Path $vaultRoot "alerts"
    vault = $vaultRoot
}

Write-Host "📊 Agent Kit Configuration:" -ForegroundColor Yellow
Write-Host "   Orchestrator: $($agentKitConfig.orchestrator)" -ForegroundColor Gray
Write-Host "   AI Mesh: $($agentKitConfig.ai_mesh -join ', ')" -ForegroundColor Gray
Write-Host "   Context Store: $($agentKitConfig.context_store)" -ForegroundColor Gray
Write-Host "   Vault: $($agentKitConfig.vault)" -ForegroundColor Gray

if ($Initialize) {
    Write-Host "`n🔧 Initializing Agent Kit Bridge..." -ForegroundColor Cyan
    
    # Create context store directory
    if (!(Test-Path $agentKitConfig.context_store)) {
        New-Item -ItemType Directory -Path $agentKitConfig.context_store -Force | Out-Null
        Write-Host "   ✅ Context store created" -ForegroundColor Green
    }
    
    # Create notifications directory
    if (!(Test-Path $agentKitConfig.notifications)) {
        New-Item -ItemType Directory -Path $agentKitConfig.notifications -Force | Out-Null
        Write-Host "   ✅ Notifications directory created" -ForegroundColor Green
    }
    
    # Create bridge configuration file
    $bridgeConfig = @{
        initialized = (Get-Date).ToString("o")
        orchestrator = $agentKitConfig.orchestrator
        ai_mesh = $agentKitConfig.ai_mesh
        context_store = $agentKitConfig.context_store
        vault_root = $agentKitConfig.vault
        security_mode = "confirm"
        human_override = $true
        audit_enabled = $true
    } | ConvertTo-Json -Depth 10
    
    $bridgeConfigPath = Join-Path $agentKitPath "bridge_config.json"
    $bridgeConfig | Out-File -FilePath $bridgeConfigPath -Encoding UTF8
    
    Write-Host "   ✅ Bridge configuration saved" -ForegroundColor Green
    Write-Host "   📄 Location: $bridgeConfigPath" -ForegroundColor Gray
}

if ($SyncContext) {
    Write-Host "`n🔄 Syncing Context Store ↔ Obsidian..." -ForegroundColor Cyan
    
    # Sync recent activity to context store
    $recentLogs = Get-ChildItem -Path "$vaultRoot\OS\logs" -Filter "*.md" -File |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 3
    
    $contextData = @{
        synced_at = (Get-Date).ToString("o")
        recent_logs = @()
        agent_status = @{}
        system_health = "UNKNOWN"
    }
    
    foreach ($log in $recentLogs) {
        $contextData.recent_logs += @{
            file = $log.Name
            path = $log.FullName
            modified = $log.LastWriteTime.ToString("o")
        }
    }
    
    # Get agent status
    $agentsPath = Join-Path $vaultRoot "OS\agents"
    $agents = @("Sentinel", "Weaver", "Hermes", "Scribe", "Ledger", "Janus", "Choir")
    
    foreach ($agent in $agents) {
        $statusFile = Join-Path $agentsPath "$agent\status.json"
        if (Test-Path $statusFile) {
            $status = Get-Content $statusFile | ConvertFrom-Json
            $contextData.agent_status[$agent] = $status.status
        }
    }
    
    # Check dashboard
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5055/snapshot.json" -TimeoutSec 3
        $dashData = $response.Content | ConvertFrom-Json
        $contextData.dashboard = @{
            plv = $dashData.plv
            samples = $dashData.samples
            status = "OPERATIONAL"
        }
    } catch {
        $contextData.dashboard = @{status = "OFFLINE"}
    }
    
    # Save context snapshot
    $contextSnapshot = Join-Path $agentKitConfig.context_store "context-$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $contextData | ConvertTo-Json -Depth 10 | Out-File -FilePath $contextSnapshot -Encoding UTF8
    
    Write-Host "   ✅ Context synced" -ForegroundColor Green
    Write-Host "   📄 Snapshot: $contextSnapshot" -ForegroundColor Gray
    Write-Host "   📊 Recent logs: $($contextData.recent_logs.Count)" -ForegroundColor Gray
    Write-Host "   🤖 Agent status captured: $($contextData.agent_status.Count)/7" -ForegroundColor Gray
}

if ($TestConnection) {
    Write-Host "`n🔍 Testing Agent Kit Connection..." -ForegroundColor Cyan
    
    $tests = @{
        "Vault Access" = Test-Path $vaultRoot
        "Context Store" = Test-Path $agentKitConfig.context_store
        "Notifications" = Test-Path $agentKitConfig.notifications
        "Bridge Config" = Test-Path (Join-Path $agentKitPath "bridge_config.json")
        "Dashboard" = $false
    }
    
    # Test dashboard
    try {
        Invoke-WebRequest -Uri "http://localhost:5055/snapshot.json" -TimeoutSec 3 | Out-Null
        $tests."Dashboard" = $true
    } catch {
        $tests."Dashboard" = $false
    }
    
    Write-Host "   Test Results:" -ForegroundColor Yellow
    foreach ($test in $tests.GetEnumerator()) {
        $status = if ($test.Value) { "✅ PASS" } else { "❌ FAIL" }
        $color = if ($test.Value) { "Green" } else { "Red" }
        Write-Host "      $status $($test.Key)" -ForegroundColor $color
    }
    
    $passCount = ($tests.Values | Where-Object { $_ }).Count
    Write-Host "`n   Overall: $passCount/$($tests.Count) tests passed" -ForegroundColor Cyan
}

# Default: Show status
if (!$Initialize -and !$SyncContext -and !$TestConnection) {
    Write-Host "`n📊 Agent Kit Bridge Status:" -ForegroundColor Cyan
    
    $bridgeConfigPath = Join-Path $agentKitPath "bridge_config.json"
    if (Test-Path $bridgeConfigPath) {
        $config = Get-Content $bridgeConfigPath | ConvertFrom-Json
        Write-Host "   Status: ✅ Initialized" -ForegroundColor Green
        Write-Host "   Initialized: $($config.initialized)" -ForegroundColor Gray
        Write-Host "   Orchestrator: $($config.orchestrator)" -ForegroundColor Gray
        Write-Host "   Security: $($config.security_mode)" -ForegroundColor Yellow
    } else {
        Write-Host "   Status: ⏸️ Not initialized" -ForegroundColor Yellow
        Write-Host "   Run: -Initialize to set up bridge" -ForegroundColor Gray
    }
    
    Write-Host "`n🎯 Actions:" -ForegroundColor Cyan
    Write-Host "   -Initialize      → Set up Agent Kit bridge" -ForegroundColor Gray
    Write-Host "   -SyncContext     → Sync Obsidian ↔ Context Store" -ForegroundColor Gray
    Write-Host "   -TestConnection  → Test all connections" -ForegroundColor Gray
}

Write-Host "`n✅ Agent Kit Bridge ready" -ForegroundColor Green
