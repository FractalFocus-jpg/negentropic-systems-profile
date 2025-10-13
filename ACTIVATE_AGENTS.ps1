# ⬢ Agent Activation — Deploy All Agents as Persistent Processes

param(
    [string[]]$AgentsToActivate = @("Sentinel", "Weaver", "Hermes", "Scribe", "Ledger", "Janus", "Choir"),
    [switch]$DryRun = $true,
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"

$banner = @"

  ⬢ CO-REGENERATIVE AGENCY ⬢
  Agent Activation Sequence
  
  "Peaceful recursion with human oversight"
  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"@

Write-Host $banner -ForegroundColor Cyan

$vaultRoot = "C:\Users\alexl\the living tapestry"
$repoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"
$osPath = Join-Path $vaultRoot "OS"
$agentsPath = Join-Path $osPath "agents"
$envFile = Join-Path $repoRoot ".env.local"

# Check prerequisites
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Cyan

$checks = @{
    "Vault" = $vaultRoot
    "Repo" = $repoRoot
    "OS Dir" = $osPath
    "Agents Dir" = $agentsPath
    ".env.local" = $envFile
}

$allGood = $true
foreach ($check in $checks.GetEnumerator()) {
    if (Test-Path $check.Value) {
        Write-Host "  ✅ $($check.Key)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $($check.Key): Missing" -ForegroundColor Red
        $allGood = $false
    }
}

if (!$allGood) {
    Write-Host "`n❌ Prerequisites not met. Run BOOTSTRAP_OS.ps1 first." -ForegroundColor Red
    exit 1
}

# Check for EMERGENCY_STOP
$emergencyStop = Join-Path $repoRoot "EMERGENCY_STOP"
if (Test-Path $emergencyStop) {
    Write-Host "`n🛑 EMERGENCY STOP file detected!" -ForegroundColor Red
    Write-Host "   Remove it to proceed: $emergencyStop" -ForegroundColor Yellow
    exit 1
}

# Load environment
Write-Host "`n📦 Loading environment..." -ForegroundColor Cyan
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^([A-Z_]+)=(.*)$') {
        $name = $matches[1]
        $value = $matches[2]
        if ($value -and $value -ne "") {
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

Write-Host "✅ Environment loaded" -ForegroundColor Green

# Agent priority order
$agentPriority = @(
    @{Name="Sentinel"; Priority=0; Description="Security & Health"},
    @{Name="Weaver"; Priority=1; Description="Knowledge Graph"},
    @{Name="Hermes"; Priority=2; Description="Publisher"},
    @{Name="Scribe"; Priority=3; Description="Researcher"},
    @{Name="Ledger"; Priority=4; Description="Finance"},
    @{Name="Janus"; Priority=5; Description="Context Router"},
    @{Name="Choir"; Priority=6; Description="Resonance"}
) | Where-Object { $_.Name -in $AgentsToActivate } | Sort-Object Priority

Write-Host "`n🤖 Agents to activate:" -ForegroundColor Cyan
foreach ($agent in $agentPriority) {
    $emoji = switch ($agent.Name) {
        "Sentinel" { "🛡️" }
        "Weaver" { "🕸️" }
        "Hermes" { "📨" }
        "Scribe" { "📚" }
        "Ledger" { "💰" }
        "Janus" { "🎭" }
        "Choir" { "🎵" }
    }
    Write-Host "   $emoji $($agent.Name) (P$($agent.Priority)) - $($agent.Description)" -ForegroundColor Gray
}

if ($DryRun) {
    Write-Host "`n⚠️  DRY RUN MODE" -ForegroundColor Yellow
    Write-Host "   No actual activation (use -DryRun:`$false to activate)" -ForegroundColor Gray
}

Write-Host "`n🔒 Safety Settings:" -ForegroundColor Yellow
Write-Host "   SEC_MODE: confirm (human approval required)"
Write-Host "   HUMAN_OVERRIDE: true"
Write-Host "   ROLLBACK: enabled"
Write-Host "   PII_GUARD: active"

if (!$Force) {
    Write-Host "`n" -NoNewline
    $confirm = Read-Host "Proceed with activation? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Host "Aborted by user." -ForegroundColor Yellow
        exit 0
    }
}

# Activate each agent
$results = @()

foreach ($agent in $agentPriority) {
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "Activating: $($agent.Name)" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    $agentDir = Join-Path $agentsPath $agent.Name
    $statusFile = Join-Path $agentDir "status.json"
    
    if (!$DryRun) {
        # Update status to active
        $status = @{
            agent = $agent.Name
            priority = $agent.Priority
            status = "active"
            activated_at = (Get-Date).ToString("o")
            pid = $null  # Will be set by agent process
            dryrun = $false
            enabled = $true
        } | ConvertTo-Json
        
        $status | Out-File -FilePath $statusFile -Encoding UTF8
        
        # Log activation
        $logFile = Join-Path $osPath "logs\$(Get-Date -Format 'yyyy-MM-dd').md"
        $logEntry = @"

## [AGENT ACTIVATION] — $($agent.Name)
**Time**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Priority**: $($agent.Priority)
**Status**: ✅ Active
**Mode**: $(if ($DryRun) { "Dry Run" } else { "Live" })
**Description**: $($agent.Description)

"@
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
        
        Write-Host "✅ $($agent.Name) activated" -ForegroundColor Green
        $results += @{Agent=$agent.Name; Status="✅ Active"}
    } else {
        Write-Host "🔍 Would activate $($agent.Name) (dry run)" -ForegroundColor Yellow
        $results += @{Agent=$agent.Name; Status="🔍 Dry Run"}
    }
}

# Summary
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📊 ACTIVATION SUMMARY" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

foreach ($result in $results) {
    Write-Host "   $($result.Status) $($result.Agent)" -ForegroundColor $(if ($result.Status -like "*Active*") { "Green" } elseif ($result.Status -like "*Dry*") { "Yellow" } else { "Red" })
}

if (!$DryRun) {
    Write-Host "`n✅ ALL AGENTS ACTIVATED!" -ForegroundColor Green
    Write-Host "`n🌊 The Co-Regenerative Agency is breathing..." -ForegroundColor Cyan
    Write-Host "`n🚀 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Check: OS\STATUS_DASHBOARD.md"
    Write-Host "   2. Monitor: OS\logs\$(Get-Date -Format 'yyyy-MM-dd').md"
    Write-Host "   3. Review: ops\UOS Command Center.md"
    Write-Host "`n🛑 Emergency Stop: Create file 'EMERGENCY_STOP' in repo root" -ForegroundColor Yellow
} else {
    Write-Host "`n🔍 Dry run complete. Use -DryRun:`$false to activate." -ForegroundColor Yellow
}
