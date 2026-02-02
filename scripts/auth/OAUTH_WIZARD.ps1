?# * OAuth Setup Wizard - All Services
# Guides through OAuth for all integrations in priority order

param(
    [string[]]$Services = @("Google", "TikTok", "Instagram"),
    [switch]$SkipExisting = $true
)

$ErrorActionPreference = "Stop"

$banner = @"

  * LIVING TAPESTRY OS vOmega *
  OAuth Configuration Wizard
  
  "Not automation - remembrance through coherence"
  
------------------------------------------------------------

"@

Write-Host $banner -ForegroundColor Cyan

$envFile = "C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local"

# Check if .env.local exists
if (!(Test-Path $envFile)) {
    Write-Host " Creating .env.local from template..." -ForegroundColor Yellow
    $template = "C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local.template"
    
    if (Test-Path $template) {
        Copy-Item $template $envFile
        Write-Host "OK .env.local created" -ForegroundColor Green
    } else {
        Write-Host "ERROR Template not found!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n? Services to configure:" -ForegroundColor Cyan
foreach ($service in $Services) {
    Write-Host "   - $service" -ForegroundColor Gray
}

Write-Host "`n Security Notes:" -ForegroundColor Yellow
Write-Host "   - All credentials stored in .env.local (git-ignored)"
Write-Host "   - OAuth uses localhost redirect (no public exposure)"
Write-Host "   - Tokens can be revoked anytime from provider dashboards"
Write-Host "   - Human confirmation required for all actions (SEC_mode: confirm)"

Write-Host "`n" -NoNewline
$confirm = Read-Host "Ready to begin? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Aborted by user." -ForegroundColor Yellow
    exit 0
}

$results = @()

# Google Services
if ("Google" -in $Services) {
    Write-Host "`n------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host " GOOGLE SERVICES" -ForegroundColor Cyan
    Write-Host "   Gmail, Calendar, Drive, Photos, YouTube" -ForegroundColor Gray
    Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
    
    try {
        & "$PSScriptRoot\setup_google_oauth.ps1" -ShowInstructions
        $results += @{Service="Google"; Status="OK Success"}
    } catch {
        Write-Host "ERROR Google OAuth failed: $_" -ForegroundColor Red
        $results += @{Service="Google"; Status="ERROR Failed"}
    }
    
    Write-Host "`nPress any key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# TikTok
if ("TikTok" -in $Services) {
    Write-Host "`n------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host " TIKTOK" -ForegroundColor Cyan
    Write-Host "   @fractalfocus" -ForegroundColor Gray
    Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
    
    try {
        & "$PSScriptRoot\setup_tiktok_oauth.ps1" -ShowInstructions
        $results += @{Service="TikTok"; Status="OK Success"}
    } catch {
        Write-Host "ERROR TikTok OAuth failed: $_" -ForegroundColor Red
        $results += @{Service="TikTok"; Status="ERROR Failed"}
    }
    
    Write-Host "`nPress any key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Instagram
if ("Instagram" -in $Services) {
    Write-Host "`n------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host " INSTAGRAM" -ForegroundColor Cyan
    Write-Host "   @realeyesrealizinglies" -ForegroundColor Gray
    Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
    
    try {
        & "$PSScriptRoot\setup_instagram_oauth.ps1" -ShowInstructions
        $results += @{Service="Instagram"; Status="OK Success"}
    } catch {
        Write-Host "ERROR Instagram OAuth failed: $_" -ForegroundColor Red
        $results += @{Service="Instagram"; Status="ERROR Failed"}
    }
}

# Summary
Write-Host "`n------------------------------------------------------------" -ForegroundColor Cyan
Write-Host " SETUP SUMMARY" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------" -ForegroundColor Cyan

foreach ($result in $results) {
    Write-Host "   $($result.Status) $($result.Service)" -ForegroundColor $(if ($result.Status -like "*Success*") { "Green" } else { "Red" })
}

$successCount = ($results | Where-Object { $_.Status -like "*Success*" }).Count
$totalCount = $results.Count

Write-Host "`n? Success Rate: $successCount/$totalCount" -ForegroundColor Cyan

if ($successCount -eq $totalCount) {
    Write-Host "`nOK ALL SERVICES CONFIGURED!" -ForegroundColor Green
    Write-Host "`n Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Run: .\BOOTSTRAP_OS.ps1"
    Write-Host "   2. Run: .\ACTIVATE_AGENTS.ps1"
    Write-Host "   3. Check: OS\STATUS_DASHBOARD.md"
} else {
    Write-Host "`nWARN  Some services failed" -ForegroundColor Yellow
    Write-Host "   You can re-run specific services later" -ForegroundColor Gray
}

Write-Host "`n All credentials saved to: $envFile" -ForegroundColor Gray
Write-Host " This file is git-ignored for security" -ForegroundColor Gray
