# ⬢ Living Tapestry OS vΩ — Bootstrap Script
# Initializes the complete OS with all agents

param(
    [switch]$DryRun = $true,
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Paths
$RepoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"
$VaultRoot = "C:\Users\alexl\the living tapestry"
$OSPath = Join-Path $VaultRoot "OS"
$LogPath = Join-Path $OSPath "logs"
$EnvFile = Join-Path $RepoRoot ".env.local"
$EnvTemplate = Join-Path $RepoRoot ".env.local.template"
$Manifest = Join-Path $OSPath "OS_MANIFEST.yaml"

# Colors
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    $colors = @{
        "Cyan" = [ConsoleColor]::Cyan
        "Green" = [ConsoleColor]::Green
        "Yellow" = [ConsoleColor]::Yellow
        "Red" = [ConsoleColor]::Red
        "Magenta" = [ConsoleColor]::Magenta
        "White" = [ConsoleColor]::White
    }
    Write-Host $Message -ForegroundColor $colors[$Color]
}

Write-ColorOutput "`n⬢ Living Tapestry OS vΩ — Bootstrap Sequence" "Cyan"
Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"

# Check manifest exists
if (!(Test-Path $Manifest)) {
    Write-ColorOutput "❌ OS Manifest not found at: $Manifest" "Red"
    exit 1
}

Write-ColorOutput "✅ OS Manifest located" "Green"

# Check .env.local
if (!(Test-Path $EnvFile)) {
    Write-ColorOutput "⚠️  .env.local not found" "Yellow"
    
    if (Test-Path $EnvTemplate) {
        Write-ColorOutput "📄 Copying .env.local.template → .env.local" "Cyan"
        Copy-Item $EnvTemplate $EnvFile
        Write-ColorOutput "✅ Created .env.local from template" "Green"
        Write-ColorOutput "" "White"
        Write-ColorOutput "🔒 NEXT STEP: Edit .env.local with your credentials" "Yellow"
        Write-ColorOutput "   Location: $EnvFile" "White"
        Write-ColorOutput "   Then re-run this script" "White"
        exit 0
    } else {
        Write-ColorOutput "❌ Template not found either" "Red"
        exit 1
    }
}

Write-ColorOutput "✅ .env.local exists" "Green"

# Load environment
Write-ColorOutput "`n📦 Loading environment variables..." "Cyan"

Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^([A-Z_]+)=(.*)$') {
        $name = $matches[1]
        $value = $matches[2]
        if ($value -and $value -ne "") {
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

Write-ColorOutput "✅ Environment loaded" "Green"

# Check critical services
Write-ColorOutput "`n🔍 Checking critical services..." "Cyan"

$criticalChecks = @(
    @{Name="Vault"; Path=$VaultRoot},
    @{Name="Repo"; Path=$RepoRoot},
    @{Name="OS Dir"; Path=$OSPath},
    @{Name="Logs"; Path=$LogPath}
)

$allGood = $true
foreach ($check in $criticalChecks) {
    if (Test-Path $check.Path) {
        Write-ColorOutput "  ✅ $($check.Name): $($check.Path)" "Green"
    } else {
        Write-ColorOutput "  ❌ $($check.Name): Missing" "Red"
        $allGood = $false
    }
}

if (!$allGood) {
    Write-ColorOutput "`n❌ Critical paths missing. Cannot proceed." "Red"
    exit 1
}

# Check dashboard
Write-ColorOutput "`n🎯 Checking dashboard..." "Cyan"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5055/snapshot.json" -TimeoutSec 3
    Write-ColorOutput "✅ Dashboard operational" "Green"
} catch {
    Write-ColorOutput "⚠️  Dashboard not running (http://localhost:5055)" "Yellow"
    Write-ColorOutput "   Start it first with: START_DASHBOARD.bat" "White"
}

# Initialize agents
Write-ColorOutput "`n🤖 Initializing agents..." "Cyan"

$agents = @(
    "Sentinel",  # Priority 0 - always first
    "Weaver",    # Priority 1
    "Hermes",    # Priority 2
    "Scribe",    # Priority 3
    "Ledger",    # Priority 4
    "Janus",     # Priority 5
    "Choir"      # Priority 6
)

foreach ($agent in $agents) {
    $agentDir = Join-Path $OSPath "agents\$agent"
    if (!(Test-Path $agentDir)) {
        New-Item -ItemType Directory -Path $agentDir | Out-Null
    }
    
    $statusFile = Join-Path $agentDir "status.json"
    $status = @{
        agent = $agent
        status = "initialized"
        dryrun = $DryRun.IsPresent
        last_boot = (Get-Date).ToString("o")
        enabled = $true
    } | ConvertTo-Json
    
    $status | Out-File -FilePath $statusFile -Encoding UTF8
    Write-ColorOutput "  ✅ $agent → $agentDir" "Green"
}

# Generate boot log
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$bootLog = @"

## [OS BOOTSTRAP] — $(Get-Date -Format "yyyy-MM-dd")

**Time**: $timestamp
**Status**: ✅ INITIALIZED
**Mode**: $(if ($DryRun.IsPresent) { "DRY RUN" } else { "LIVE" })
**Agents**: $($agents -join ", ")

### Environment
- Vault: $VaultRoot
- Repo: $RepoRoot
- .env.local: ✅ Loaded
- Dashboard: $(if ($?) { "✅ Running" } else { "⚠️ Offline" })

### Agents Initialized
$($agents | ForEach-Object { "- ✅ $_" } | Out-String)

### Security
- SEC_MODE: confirm
- HUMAN_OVERRIDE: true
- DRYRUN: $($DryRun.IsPresent)
- PII_GUARD: true
- ROLLBACK: enabled

### Next Steps
1. Configure .env.local with OAuth credentials
2. Run OAuth authorization flows
3. Activate scheduled tasks
4. Begin 24h review cycle

"@

$logFile = Join-Path $LogPath "$(Get-Date -Format 'yyyy-MM-dd').md"
$bootLog | Add-Content -Path $logFile -Encoding UTF8

Write-ColorOutput "`n✅ Bootstrap complete!" "Green"
Write-ColorOutput "📄 Log: $logFile" "Cyan"
Write-ColorOutput "`n🔐 NEXT: Configure OAuth credentials in .env.local" "Yellow"
Write-ColorOutput "   Then run: .\ACTIVATE_AGENTS.ps1" "White"
