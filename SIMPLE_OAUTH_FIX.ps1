# OAuth Fix - SIMPLE VERSION
# No complex logic, just the essentials

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  OAuth Loop Fix - Simple Version" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$repoPath = "C:\Users\alexl\Desktop\tapestry-codex-starter"
$envPath = "$repoPath\.env.local"
$templatePath = "$repoPath\.env.local.template"

# Step 1: Check if .env.local needs fixing
Write-Host "Checking .env.local..." -ForegroundColor Yellow

if (Test-Path $envPath) {
    $content = Get-Content $envPath -Raw
    
    if ($content -match "DIAGNOSTIC REPORT") {
        Write-Host "Found diagnostic report - backing up..." -ForegroundColor Yellow
        Move-Item $envPath "$envPath.backup" -Force
        Write-Host "Backed up to .env.local.backup" -ForegroundColor Green
    }
}

# Step 2: Copy template if needed
if (-not (Test-Path $envPath)) {
    Write-Host "Creating .env.local from template..." -ForegroundColor Yellow
    Copy-Item $templatePath $envPath
    Write-Host "Created .env.local" -ForegroundColor Green
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Step 1: Add Your Credentials" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Go to: https://console.cloud.google.com/apis/credentials" -ForegroundColor White
Write-Host ""

$clientId = Read-Host "Paste your Google OAuth CLIENT ID (or press Enter to skip)"

if ($clientId) {
    $clientSecret = Read-Host "Paste your Google OAuth CLIENT SECRET"
    
    Write-Host ""
    Write-Host "Adding credentials to .env.local..." -ForegroundColor Yellow
    
    $googleCreds = @"

# Google OAuth - Added by OAuth Fix
GMAIL_CLIENT_ID=$clientId
GMAIL_CLIENT_SECRET=$clientSecret
GCAL_CLIENT_ID=$clientId
GCAL_CLIENT_SECRET=$clientSecret
GDRIVE_CLIENT_ID=$clientId
GDRIVE_CLIENT_SECRET=$clientSecret
GPHOTOS_CLIENT_ID=$clientId
GPHOTOS_CLIENT_SECRET=$clientSecret
YOUTUBE_CLIENT_ID=$clientId
YOUTUBE_CLIENT_SECRET=$clientSecret
"@
    
    Add-Content -Path $envPath -Value $googleCreds
    Write-Host "Credentials saved!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Step 2: Generate Tokens" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will open your browser to get the REFRESH TOKEN" -ForegroundColor White
Write-Host "(This is what fixes the loop!)" -ForegroundColor Yellow
Write-Host ""

$generate = Read-Host "Generate tokens now? (y/n)"

if ($generate -eq "y") {
    $tokenScript = "$repoPath\GENERATE_GOOGLE_TOKENS.ps1"
    
    if (Test-Path $tokenScript) {
        Write-Host "Running token generator..." -ForegroundColor Yellow
        & $tokenScript
    }
    else {
        Write-Host "Token generator not found" -ForegroundColor Red
        Write-Host ""
        Write-Host "Manual option:" -ForegroundColor Yellow
        Write-Host "1. Run: .\scripts\auth\run_oauth_youtube.ps1" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Done!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Check if tokens saved: notepad .env.local" -ForegroundColor White
Write-Host "2. Activate agents: .\ACTIVATE_AGENTS.ps1" -ForegroundColor White
Write-Host ""
