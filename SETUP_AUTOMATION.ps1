# ⬢ Setup Scheduled Automation — Daily & Hourly Tasks

param(
    [switch]$DryRun = $true,
    [switch]$RemoveExisting = $false
)

$ErrorActionPreference = "Stop"

Write-Host "`n⏰ Setting Up Scheduled Automation" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$repoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"

# Define scheduled tasks
$tasks = @(
    @{
        Name = "TapestryCoherenceSnapshot"
        Description = "Capture coherence snapshot every 30 minutes"
        Script = "scripts\fetch_snapshot.ps1"
        Trigger = "MINUTE"
        Interval = 30
        Existing = $true  # Already created
    },
    @{
        Name = "TapestryCDIHourly"
        Description = "Track Cognitive Drift Index hourly"
        Script = "scripts\cdi_tracker.ps1"
        Trigger = "HOURLY"
        Interval = 1
        Existing = $true  # Already created
    },
    @{
        Name = "TapestryWeaverSync"
        Description = "Sync Obsidian vault with data streams (hourly)"
        Script = "scripts\agents\weaver_sync.ps1"
        Trigger = "HOURLY"
        Interval = 1
        Existing = $false
    },
    @{
        Name = "TapestrySentinelAudit"
        Description = "Security and health audit (every 6 hours)"
        Script = "scripts\agents\sentinel.ps1"
        Trigger = "HOURLY"
        Interval = 6
        Existing = $false
    },
    @{
        Name = "TapestrySRLoop"
        Description = "Self-Regenerative Loop (daily at 9 AM)"
        Script = "scripts\SR_LOOP.ps1"
        Trigger = "DAILY"
        Time = "09:00"
        Existing = $false
    },
    @{
        Name = "TapestryHermesDaily"
        Description = "Generate daily post (review mode)"
        Script = "scripts\agents\hermes.ps1 -GeneratePost"
        Trigger = "DAILY"
        Time = "10:00"
        Existing = $false
    },
    @{
        Name = "TapestryScribeResearch"
        Description = "Daily research scan"
        Script = "scripts\agents\scribe.ps1"
        Trigger = "DAILY"
        Time = "11:00"
        Existing = $false
    }
)

Write-Host "📋 Tasks to configure:" -ForegroundColor Yellow
foreach ($task in $tasks) {
    $status = if ($task.Existing) { "[EXISTS]" } else { "[NEW]" }
    Write-Host "   $status $($task.Name)" -ForegroundColor $(if ($task.Existing) { "Gray" } else { "Green" })
    Write-Host "      $($task.Description)" -ForegroundColor DarkGray
}

if ($DryRun) {
    Write-Host "`n⚠️  DRY RUN MODE" -ForegroundColor Yellow
    Write-Host "   No tasks will be created. Use -DryRun:`$false to apply." -ForegroundColor Gray
    exit 0
}

Write-Host "`n🔧 Creating scheduled tasks..." -ForegroundColor Cyan

foreach ($task in $tasks) {
    if ($task.Existing -and !$RemoveExisting) {
        Write-Host "   ⏭️  Skipping: $($task.Name) (already exists)" -ForegroundColor Gray
        continue
    }
    
    if ($RemoveExisting) {
        Write-Host "   🗑️  Removing existing: $($task.Name)" -ForegroundColor Yellow
        schtasks /Delete /TN $task.Name /F 2>$null | Out-Null
    }
    
    $scriptPath = Join-Path $repoRoot $task.Script
    
    if (!(Test-Path $scriptPath)) {
        Write-Host "   ⚠️  Script not found: $scriptPath" -ForegroundColor Yellow
        continue
    }
    
    # Build schtasks command
    $action = "powershell -NoLogo -ExecutionPolicy Bypass -File `"$scriptPath`""
    
    try {
        if ($task.Trigger -eq "MINUTE") {
            $cmd = "schtasks /Create /SC MINUTE /MO $($task.Interval) /TN `"$($task.Name)`" /TR `"$action`" /F"
        } elseif ($task.Trigger -eq "HOURLY") {
            $cmd = "schtasks /Create /SC HOURLY /MO $($task.Interval) /TN `"$($task.Name)`" /TR `"$action`" /F"
        } elseif ($task.Trigger -eq "DAILY") {
            $cmd = "schtasks /Create /SC DAILY /ST $($task.Time) /TN `"$($task.Name)`" /TR `"$action`" /F"
        }
        
        Invoke-Expression $cmd | Out-Null
        Write-Host "   ✅ Created: $($task.Name)" -ForegroundColor Green
        
    } catch {
        Write-Host "   ❌ Failed: $($task.Name) - $_" -ForegroundColor Red
    }
}

# Verify tasks
Write-Host "`n🔍 Verifying tasks..." -ForegroundColor Cyan

$taskList = schtasks /Query /FO CSV | ConvertFrom-Csv
$tapestryTasks = $taskList | Where-Object { $_.TaskName -like "*Tapestry*" }

Write-Host "`n📊 Active Tapestry Tasks:" -ForegroundColor Cyan
foreach ($task in $tapestryTasks) {
    Write-Host "   ✅ $($task.TaskName)" -ForegroundColor Green
    Write-Host "      Status: $($task.Status)" -ForegroundColor Gray
    $nextRun = $task | Select-Object -ExpandProperty "Next Run Time" -ErrorAction SilentlyContinue
    if ($nextRun) {
        Write-Host "      Next Run: $nextRun" -ForegroundColor DarkGray
    }
}

Write-Host "`n✅ Automation setup complete!" -ForegroundColor Green
Write-Host "`n📅 Schedule Summary:" -ForegroundColor Cyan
Write-Host "   Every 30 min: Coherence snapshot" -ForegroundColor Gray
Write-Host "   Every hour: CDI tracking, Weaver sync" -ForegroundColor Gray
Write-Host "   Every 6 hours: Sentinel audit" -ForegroundColor Gray
Write-Host "   Daily 09:00: SR-Loop cycle" -ForegroundColor Gray
Write-Host "   Daily 10:00: Hermes post generation" -ForegroundColor Gray
Write-Host "   Daily 11:00: Scribe research scan" -ForegroundColor Gray

Write-Host "`n🛠️  Manage Tasks:" -ForegroundColor Yellow
Write-Host "   View: schtasks /Query /TN `"Tapestry*`"" -ForegroundColor Gray
Write-Host "   Delete: schtasks /Delete /TN `"TaskName`" /F" -ForegroundColor Gray
Write-Host "   Run Now: schtasks /Run /TN `"TaskName`"" -ForegroundColor Gray
