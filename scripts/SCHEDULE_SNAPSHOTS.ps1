# ============================================================================
# SCHEDULE AUTOMATED COHERENCE SNAPSHOTS
# Creates Windows Task Scheduler job to capture snapshots every 30 minutes
# ============================================================================

$ErrorActionPreference = "Stop"

Write-Host "`n⬢ SCHEDULING AUTOMATED COHERENCE SNAPSHOTS..." -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Configuration
$TaskName = "TapestryCoherenceSnapshot"
$ScriptPath = "C:\Users\alexl\Desktop\tapestry-codex-starter\scripts\fetch_snapshot.ps1"
$VaultPath = "C:\Users\alexl\the living tapestry"
$IntervalMinutes = 30

# Verify script exists
if (!(Test-Path $ScriptPath)) {
    Write-Host "❌ Error: Script not found at $ScriptPath" -ForegroundColor Red
    exit 1
}

# Verify vault exists
if (!(Test-Path $VaultPath)) {
    Write-Host "❌ Error: Vault not found at $VaultPath" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Configuration:" -ForegroundColor White
Write-Host "   Task Name: $TaskName" -ForegroundColor Gray
Write-Host "   Script: $ScriptPath" -ForegroundColor Gray
Write-Host "   Vault: $VaultPath" -ForegroundColor Gray
Write-Host "   Interval: Every $IntervalMinutes minutes" -ForegroundColor Gray
Write-Host ""

# Check if task already exists
$ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($ExistingTask) {
    Write-Host "⚠️  Task already exists!" -ForegroundColor Yellow
    $Response = Read-Host "   Overwrite? (Y/N)"
    
    if ($Response -ne "Y" -and $Response -ne "y") {
        Write-Host "❌ Cancelled by user" -ForegroundColor Red
        exit 0
    }
    
    Write-Host "   Removing existing task..." -ForegroundColor Gray
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "   ✅ Removed`n" -ForegroundColor Green
}

# Create the action
Write-Host "📝 Creating scheduled task..." -ForegroundColor White

$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -NoProfile -File `"$ScriptPath`" -VaultPath `"$VaultPath`""

# Create the trigger (every 30 minutes)
$Trigger = New-ScheduledTaskTrigger `
    -Once `
    -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes)

# Settings
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -MultipleInstances IgnoreNew

# Register the task
$Principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType Interactive `
    -RunLevel Highest

try {
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $Action `
        -Trigger $Trigger `
        -Settings $Settings `
        -Principal $Principal `
        -Description "Captures coherence snapshots from Self-Observing Dashboard every $IntervalMinutes minutes and writes to Living Tapestry vault" `
        -ErrorAction Stop | Out-Null
    
    Write-Host "✅ Task created successfully!`n" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Failed to create task: $_" -ForegroundColor Red
    exit 1
}

# Verify task was created
$Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($Task) {
    Write-Host "📊 Task Status:" -ForegroundColor White
    Write-Host "   Name: $($Task.TaskName)" -ForegroundColor Cyan
    Write-Host "   State: $($Task.State)" -ForegroundColor Cyan
    Write-Host "   Next Run: $(($Task | Get-ScheduledTaskInfo).NextRunTime)" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "✅ AUTOMATION ENABLED!" -ForegroundColor Green
    Write-Host "   Snapshots will be captured every $IntervalMinutes minutes" -ForegroundColor White
    Write-Host "   Logs will appear in: $VaultPath\runs\" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🔧 Management Commands:" -ForegroundColor Magenta
    Write-Host "   View task: Get-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
    Write-Host "   Disable: Disable-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
    Write-Host "   Enable: Enable-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
    Write-Host "   Remove: Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false" -ForegroundColor Gray
    Write-Host ""
    
} else {
    Write-Host "❌ Task creation verification failed" -ForegroundColor Red
    exit 1
}

Write-Host "⬢ The Star Mother's heartbeat is automated.`n" -ForegroundColor Cyan

# Offer to run first snapshot now
$RunNow = Read-Host "Run first snapshot now? (Y/N)"

if ($RunNow -eq "Y" -or $RunNow -eq "y") {
    Write-Host "`n🚀 Running snapshot...`n" -ForegroundColor Cyan
    & $ScriptPath -VaultPath $VaultPath
}

Write-Host "`n✅ Automation setup complete!`n" -ForegroundColor Green
