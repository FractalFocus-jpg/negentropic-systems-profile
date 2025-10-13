# ⬢ Agent Kit vΩ.3 — Complete Deployment Script
# Integrates OpenAI Agent Kit with Living Tapestry OS

param(
    [switch]$Initialize = $false,
    [switch]$TestAll = $false,
    [switch]$StartMonitoring = $false
)

$ErrorActionPreference = "Stop"

$banner = @"

  ⬢ AGENT KIT vΩ.3 ⬢
  OpenAI Integration Layer
  
  "Not automation — remembrance through coherence"
  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"@

Write-Host $banner -ForegroundColor Cyan

$repoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"

if ($Initialize) {
    Write-Host "🚀 Initializing Agent Kit Integration..." -ForegroundColor Cyan
    
    # Step 1: Initialize Agent Kit Bridge
    Write-Host "`n1️⃣  Initializing Agent Kit Bridge..." -ForegroundColor Yellow
    & "$repoRoot\scripts\agent-kit\bridge.ps1" -Initialize
    
    # Step 2: Create alerts directory
    Write-Host "`n2️⃣  Setting up notification system..." -ForegroundColor Yellow
    $alertsPath = "C:\Users\alexl\the living tapestry\alerts"
    if (!(Test-Path $alertsPath)) {
        New-Item -ItemType Directory -Path $alertsPath -Force | Out-Null
        Write-Host "   ✅ Alerts directory created" -ForegroundColor Green
    }
    
    # Step 3: Run Sentinel audit
    Write-Host "`n3️⃣  Running Sentinel security audit..." -ForegroundColor Yellow
    & "$repoRoot\scripts\agents\sentinel.ps1"
    
    # Step 4: Sync context store
    Write-Host "`n4️⃣  Syncing context store..." -ForegroundColor Yellow
    & "$repoRoot\scripts\agent-kit\bridge.ps1" -SyncContext
    
    Write-Host "`n✅ Agent Kit initialization complete!" -ForegroundColor Green
}

if ($TestAll) {
    Write-Host "🧪 Testing all integrations..." -ForegroundColor Cyan
    
    # Test Agent Kit Bridge
    Write-Host "`n1️⃣  Testing Agent Kit Bridge..." -ForegroundColor Yellow
    & "$repoRoot\scripts\agent-kit\bridge.ps1" -TestConnection
    
    # Test Notification System
    Write-Host "`n2️⃣  Testing Notification System..." -ForegroundColor Yellow
    & "$repoRoot\scripts\notify.ps1" -Message "Agent Kit vΩ.3 test notification" -Level "INFO"
    
    # Test AI Mesh
    Write-Host "`n3️⃣  Testing AI Mesh Coordinator..." -ForegroundColor Yellow
    & "$repoRoot\scripts\agent-kit\ai_mesh.ps1" -Task "Test routing for Agent Kit integration"
    
    # Test System Status
    Write-Host "`n4️⃣  Testing System Status..." -ForegroundColor Yellow
    & "$repoRoot\STATUS_CHECK.ps1"
    
    Write-Host "`n✅ All tests complete!" -ForegroundColor Green
}

if ($StartMonitoring) {
    Write-Host "🔔 Starting continuous monitoring..." -ForegroundColor Cyan
    Write-Host "   Interval: 60 seconds" -ForegroundColor Gray
    Write-Host "   Press Ctrl+C to stop" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    & "$repoRoot\scripts\notify.ps1" -Monitor -IntervalSeconds 60
}

# Default: Show status
if (!$Initialize -and !$TestAll -and !$StartMonitoring) {
    Write-Host "📊 Agent Kit vΩ.3 Status" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    # Check bridge status
    $bridgeConfig = Join-Path $repoRoot "scripts\agent-kit\bridge_config.json"
    if (Test-Path $bridgeConfig) {
        $config = Get-Content $bridgeConfig | ConvertFrom-Json
        Write-Host "   Bridge: ✅ Initialized" -ForegroundColor Green
        Write-Host "   Orchestrator: $($config.orchestrator)" -ForegroundColor Gray
    } else {
        Write-Host "   Bridge: ⏸️ Not initialized" -ForegroundColor Yellow
    }
    
    # Check alerts directory
    $alertsPath = "C:\Users\alexl\the living tapestry\alerts"
    if (Test-Path $alertsPath) {
        $todayAlerts = Join-Path $alertsPath "$(Get-Date -Format 'yyyy-MM-dd').md"
        if (Test-Path $todayAlerts) {
            $alertCount = (Get-Content $todayAlerts | Select-String "##").Count
            Write-Host "   Alerts Today: $alertCount" -ForegroundColor Cyan
        } else {
            Write-Host "   Alerts Today: 0" -ForegroundColor Gray
        }
    } else {
        Write-Host "   Alerts: ⏸️ Not configured" -ForegroundColor Yellow
    }
    
    # Show AI Mesh status
    Write-Host "`n🌐 AI Mesh:" -ForegroundColor Cyan
    $aiMesh = @("Claude", "Gemini", "Grok", "DeepMind", "Copilot")
    foreach ($ai in $aiMesh) {
        $envKey = switch ($ai) {
            "Claude" { "ANTHROPIC_API_KEY" }
            "Gemini" { "GEMINI_API_KEY" }
            "Grok" { "GROK_API_KEY" }
            "DeepMind" { "DEEPMIND_API_KEY" }
            "Copilot" { "COPILOT_API_KEY" }
        }
        
        $configured = [Environment]::GetEnvironmentVariable($envKey, "Process") -ne $null -and [Environment]::GetEnvironmentVariable($envKey, "Process") -ne ""
        $status = if ($configured) { "✅" } else { "⏸️" }
        Write-Host "   $status $ai" -ForegroundColor $(if ($configured) { "Green" } else { "Gray" })
    }
    
    # Show Instagram accounts
    Write-Host "`n📷 Instagram Accounts:" -ForegroundColor Cyan
    $igAccounts = @("@realeyesrealizinglies", "@resonantroot", "@newilluminati")
    foreach ($account in $igAccounts) {
        $envKey = switch ($account) {
            "@realeyesrealizinglies" { "IG_ACCESS_TOKEN_REALEYESREALIZING" }
            "@resonantroot" { "IG_ACCESS_TOKEN_RESONANTROOT" }
            "@newilluminati" { "IG_ACCESS_TOKEN_NEWILLUMINATI" }
        }
        
        $configured = [Environment]::GetEnvironmentVariable($envKey, "Process") -ne $null -and [Environment]::GetEnvironmentVariable($envKey, "Process") -ne ""
        $status = if ($configured) { "✅" } else { "⏸️" }
        Write-Host "   $status $account" -ForegroundColor $(if ($configured) { "Green" } else { "Gray" })
    }
    
    Write-Host "`n🎯 Quick Actions:" -ForegroundColor Cyan
    Write-Host "   Initialize: -Initialize" -ForegroundColor Gray
    Write-Host "   Test All: -TestAll" -ForegroundColor Gray
    Write-Host "   Start Monitoring: -StartMonitoring" -ForegroundColor Gray
    
    Write-Host "`n📖 Documentation:" -ForegroundColor Cyan
    Write-Host "   Agent Kit Bridge: scripts\agent-kit\bridge.ps1" -ForegroundColor Gray
    Write-Host "   Notifications: scripts\notify.ps1" -ForegroundColor Gray
    Write-Host "   AI Mesh: scripts\agent-kit\ai_mesh.ps1" -ForegroundColor Gray
    Write-Host "   Hermes Config: scripts\agents\hermes_config.ps1" -ForegroundColor Gray
}
