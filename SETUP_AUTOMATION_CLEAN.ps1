# Setup Scheduled Automation - Clean Version
# Living Tapestry OS - Scheduled Tasks

param(
    [switch]$DryRun = $false
)

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  SCHEDULED AUTOMATION SETUP" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$repoRoot = "C:\Users\alexl\Desktop\tapestry-codex-starter"
$tasks = @()

# Weaver Sync - Hourly
$tasks += @{
    Name = "LT_WeaverSync"
    Description = "Sync Obsidian vault hourly"
    Script = "$repoRoot\scripts\agents\weaver_sync.ps1"
    Hours = 1
}

# Sentinel Audit - Every 6 hours
$tasks += @{
    Name = "LT_SentinelAudit"
    Description = "Security audit every 6 hours"
    Script = "$repoRoot\scripts\agents\sentinel_audit.ps1"
    Hours = 6
}

# Photos Import - Every 15 minutes
$tasks += @{
    Name = "LT_PhotosImport"
    Description = "Import Google Photos every 15 minutes"
    Script = "$repoRoot\IMPORT_PHOTOS.bat"
    Minutes = 15
}

# SR Loop - Daily
$tasks += @{
    Name = "LT_SRLoop"
    Description = "Self-Regenerative Loop daily"
    Script = "$repoRoot\scripts\SR_LOOP.ps1"
    Daily = $true
    Time = "23:00"
}

if ($DryRun) {
    Write-Host "DRY RUN MODE - No tasks will be created" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($task in $tasks) {
        Write-Host "Would create: $($task.Name)" -ForegroundColor Gray
        Write-Host "  Description: $($task.Description)" -ForegroundColor DarkGray
        Write-Host "  Script: $($task.Script)" -ForegroundColor DarkGray
        
        if ($task.Hours) {
            Write-Host "  Frequency: Every $($task.Hours) hour(s)" -ForegroundColor DarkGray
        } elseif ($task.Minutes) {
            Write-Host "  Frequency: Every $($task.Minutes) minute(s)" -ForegroundColor DarkGray
        } elseif ($task.Daily) {
            Write-Host "  Frequency: Daily at $($task.Time)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
    
    Write-Host "To create these tasks, run with -DryRun:`$false" -ForegroundColor Yellow
    exit 0
}

# Actual task creation
Write-Host "Creating scheduled tasks..." -ForegroundColor Green
Write-Host ""

foreach ($task in $tasks) {
    Write-Host "Creating: $($task.Name)..." -ForegroundColor Cyan
    
    try {
        # Check if task already exists
        $existing = Get-ScheduledTask -TaskName $task.Name -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "  Task already exists - removing old version" -ForegroundColor Yellow
            Unregister-ScheduledTask -TaskName $task.Name -Confirm:$false
        }
        
        # Create trigger based on frequency
        if ($task.Hours) {
            $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours $task.Hours)
        } elseif ($task.Minutes) {
            $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $task.Minutes)
        } elseif ($task.Daily) {
            $trigger = New-ScheduledTaskTrigger -Daily -At $task.Time
        }
        
        # Determine action based on script extension
        if ($task.Script -like "*.ps1") {
            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$($task.Script)`""
        } else {
            $action = New-ScheduledTaskAction -Execute $task.Script
        }
        
        # Register task
        Register-ScheduledTask -TaskName $task.Name -Trigger $trigger -Action $action -Description $task.Description -ErrorAction Stop | Out-Null
        
        Write-Host "  SUCCESS" -ForegroundColor Green
    }
    catch {
        Write-Host "  FAILED: $_" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To view tasks:" -ForegroundColor Yellow
Write-Host "  Get-ScheduledTask | Where-Object {`$_.TaskName -like 'LT_*'}" -ForegroundColor White
Write-Host ""
