# SETUP_WINDOWS_AUTOSTART.ps1
# Creates Windows Task Scheduler job for UOS Control Center auto-start

param(
    [switch]$Remove = $false,
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot
$repoRoot = Split-Path -Parent $scriptDir

$taskName = "UOS_Autostart"
$taskDescription = "Universal Operating System Control Center - Auto-start on login"

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  This script requires administrator privileges!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run:" -ForegroundColor Yellow
    Write-Host "  powershell -ExecutionPolicy Bypass -File ""$PSCommandPath"" $(if ($Remove) { '-Remove' })" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run the command above." -ForegroundColor Gray
    exit 1
}

Write-Host "⬢ UOS WINDOWS AUTOSTART SETUP" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host ""

# Remove existing task if requested
if ($Remove) {
    Write-Host "🗑️  Removing existing task..." -ForegroundColor Yellow
    
    try {
        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($null -ne $existingTask) {
            if (-not $DryRun) {
                Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
            }
            Write-Host "  ✅ Task '$taskName' removed" -ForegroundColor Green
        } else {
            Write-Host "  ℹ️  Task '$taskName' does not exist" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "  ❌ Error removing task: $_" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "✅ Task removal complete" -ForegroundColor Green
    exit 0
}

# Check if task already exists
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($null -ne $existingTask) {
    Write-Host "⚠️  Task '$taskName' already exists!" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Do you want to replace it? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "Cancelled." -ForegroundColor Gray
        exit 0
    }
    
    if (-not $DryRun) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }
    Write-Host "  ✅ Removed existing task" -ForegroundColor Green
}

# Paths
$launcherScript = Join-Path $repoRoot "LAUNCH_UOS_CONTROL_CENTER.ps1"
$logFile = Join-Path $repoRoot "logs\autostart_$(Get-Date -Format 'yyyy-MM-dd').log"

# Verify launcher exists
if (-not (Test-Path $launcherScript)) {
    Write-Host "❌ Launcher script not found: $launcherScript" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Task Configuration:" -ForegroundColor White
Write-Host "  Name: $taskName" -ForegroundColor Gray
Write-Host "  Description: $taskDescription" -ForegroundColor Gray
Write-Host "  Trigger: At user logon" -ForegroundColor Gray
Write-Host "  Script: $launcherScript" -ForegroundColor Gray
Write-Host "  Log: $logFile" -ForegroundColor Gray
Write-Host ""

if ($DryRun) {
    Write-Host "🧪 DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

# Create the scheduled task
Write-Host "📅 Creating scheduled task..." -ForegroundColor Yellow

# Action: Run PowerShell script
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File ""$launcherScript"" > ""$logFile"" 2>&1"

# Trigger: At user logon
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

# Settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0)

# Principal: Run with highest privileges
$principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType Interactive `
    -RunLevel Highest

# Register the task
if (-not $DryRun) {
    try {
        Register-ScheduledTask `
            -TaskName $taskName `
            -Description $taskDescription `
            -Action $action `
            -Trigger $trigger `
            -Settings $settings `
            -Principal $principal `
            -Force | Out-Null
        
        Write-Host "  ✅ Task registered successfully" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Failed to register task: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  🧪 Would register task (dry run)" -ForegroundColor Yellow
}

# Verify task was created
if (-not $DryRun) {
    $verifyTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($null -ne $verifyTask) {
        Write-Host "  ✅ Task verified in Task Scheduler" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Task verification failed!" -ForegroundColor Red
        exit 1
    }
}

# Summary
Write-Host ""
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "✅ AUTOSTART SETUP COMPLETE" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📖 Details:" -ForegroundColor White
Write-Host "  • Task Name: $taskName" -ForegroundColor Gray
Write-Host "  • Will start UOS Control Center at login" -ForegroundColor Gray
Write-Host "  • Runs with elevated privileges" -ForegroundColor Gray
Write-Host "  • Logs to: $logFile" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Management:" -ForegroundColor White
Write-Host "  View:   taskschd.msc (Task Scheduler)" -ForegroundColor Gray
Write-Host "  Test:   schtasks /Run /TN ""$taskName""" -ForegroundColor Gray
Write-Host "  Remove: .\SETUP_WINDOWS_AUTOSTART.ps1 -Remove" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  Note: UOS will auto-start on your next login!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Would you like to test the task now? (y/N): " -ForegroundColor Cyan -NoNewline
$testNow = Read-Host

if ($testNow -eq 'y' -or $testNow -eq 'Y') {
    Write-Host ""
    Write-Host "🧪 Running task now..." -ForegroundColor Yellow
    
    if (-not $DryRun) {
        schtasks /Run /TN "$taskName" | Out-Null
        Start-Sleep -Seconds 2
        
        Write-Host "  ✅ Task started" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Check the new PowerShell window for UOS Control Center status" -ForegroundColor Cyan
    } else {
        Write-Host "  🧪 Would run task (dry run)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
