# 🔧 QUICK FIX - OAuth Loop Repair
# Automates the diagnosis and repair of OAuth configuration

param(
    [switch]$DiagnoseOnly = $false,
    [switch]$AutoFix = $false
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "⬢═══════════════════════════════════════════════════════════⬢" -ForegroundColor Cyan
Write-Host "   LIVING TAPESTRY OS - OAuth Loop Quick Fix" -ForegroundColor Cyan
Write-Host "⬢═══════════════════════════════════════════════════════════⬢" -ForegroundColor Cyan
Write-Host ""

$repoPath = "C:\Users\alexl\Desktop\tapestry-codex-starter"
$envPath = "$repoPath\.env.local"
$templatePath = "$repoPath\.env.local.template"
$secretsPath = "$repoPath\secrets"

# Diagnosis
Write-Host "🔍 DIAGNOSIS" -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

$issues = @()
$fixes = @()

# Check 1: .env.local exists
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath -Raw
    Write-Host "✅ .env.local found" -ForegroundColor Green
    
    # Check if it's the diagnostic file (wrong file)
    if ($envContent -match "DIAGNOSTIC REPORT") {
        $issues += ".env.local is a diagnostic report, not config file"
        $fixes += "Recreate .env.local from template"
        Write-Host "❌ .env.local is diagnostic report (not real config)" -ForegroundColor Red
    }
    
    # Check for CLIENT_ID
    if ($envContent -match "GMAIL_CLIENT_ID=(\S+)" -and $Matches[1] -ne "") {
        Write-Host "✅ Google CLIENT_ID found" -ForegroundColor Green
    } else {
        $issues += "No Google CLIENT_ID in .env.local"
        $fixes += "Add Google OAuth credentials"
        Write-Host "❌ No Google CLIENT_ID" -ForegroundColor Red
    }
    
    # Check for REFRESH_TOKEN (the critical missing piece)
    if ($envContent -match "GMAIL_REFRESH_TOKEN=(\S+)" -and $Matches[1] -ne "" -and $Matches[1] -ne "GMAIL_REFRESH_TOKEN=") {
        Write-Host "✅ Google REFRESH_TOKEN found" -ForegroundColor Green
    } else {
        $issues += "No REFRESH_TOKEN - THIS IS THE LOOP CAUSE"
        $fixes += "Run OAuth token generation script"
        Write-Host "❌ No REFRESH_TOKEN (LOOP CAUSE!)" -ForegroundColor Red
    }
    
} else {
    $issues += ".env.local does not exist"
    $fixes += "Create .env.local from template"
    Write-Host "❌ .env.local not found" -ForegroundColor Red
}

# Check 2: google_credentials.json
if (Test-Path "$repoPath\google_credentials.json") {
    Write-Host "✅ google_credentials.json found" -ForegroundColor Green
} else {
    $issues += "google_credentials.json not found"
    $fixes += "Download from Google Cloud Console"
    Write-Host "❌ google_credentials.json missing" -ForegroundColor Red
}

# Check 3: Secrets directory
if (Test-Path $secretsPath) {
    $tokenFiles = Get-ChildItem "$secretsPath\*.token" -ErrorAction SilentlyContinue
    if ($tokenFiles.Count -gt 0) {
        Write-Host "✅ Token files found: $($tokenFiles.Count)" -ForegroundColor Green
        foreach ($token in $tokenFiles) {
            Write-Host "   - $($token.Name)" -ForegroundColor DarkGray
        }
    } else {
        $issues += "secrets/ directory exists but empty"
        Write-Host "⚠️  secrets/ directory empty (no tokens)" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  secrets/ directory doesn't exist" -ForegroundColor Yellow
}

# Check 4: Agent status
$agentsPath = "C:\Users\alexl\the living tapestry\OS\agents"
if (Test-Path $agentsPath) {
    $agentDirs = Get-ChildItem $agentsPath -Directory
    Write-Host "✅ Agent directories found: $($agentDirs.Count)" -ForegroundColor Green
    
    $activeAgents = 0
    foreach ($agent in $agentDirs) {
        $statusFile = Join-Path $agent.FullName "status.json"
        if (Test-Path $statusFile) {
            $status = Get-Content $statusFile | ConvertFrom-Json
            if ($status.active -eq $true) {
                $activeAgents++
            }
        }
    }
    Write-Host "   Active: $activeAgents / $($agentDirs.Count)" -ForegroundColor DarkGray
} else {
    Write-Host "⚠️  Agent directories not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# Summary
if ($issues.Count -eq 0) {
    Write-Host "✅ ALL CHECKS PASSED - No OAuth loop detected!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your system appears to be configured correctly." -ForegroundColor Green
    exit 0
}

Write-Host "📋 ISSUES FOUND: $($issues.Count)" -ForegroundColor Yellow
Write-Host ""
foreach ($issue in $issues) {
    Write-Host "   • $issue" -ForegroundColor Red
}
Write-Host ""

if ($DiagnoseOnly) {
    Write-Host "🔧 RECOMMENDED FIXES:" -ForegroundColor Cyan
    Write-Host ""
    foreach ($fix in $fixes) {
        Write-Host "   • $fix" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Run without -DiagnoseOnly flag for guided repair" -ForegroundColor Gray
    exit 1
}

# Interactive Fix
Write-Host "🔧 REPAIR OPTIONS" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

if (-not $AutoFix) {
    $response = Read-Host "Would you like to attempt automatic repair? (y/n)"
    if ($response -ne 'y') {
        Write-Host ""
        Write-Host "Manual repair guide: C:\Users\alexl\Desktop\OAUTH_LOOP_FIX_GUIDE.md" -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Write-Host "🔧 STARTING REPAIR..." -ForegroundColor Cyan
Write-Host ""

# Fix 1: Recreate .env.local if it's the diagnostic file
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath -Raw
    if ($envContent -match "DIAGNOSTIC REPORT") {
        Write-Host "→ Backing up diagnostic file..." -ForegroundColor Yellow
        Move-Item $envPath "$envPath.diagnostic.backup" -Force
        Write-Host "✅ Backed up to .env.local.diagnostic.backup" -ForegroundColor Green
        
        Write-Host "→ Creating new .env.local from template..." -ForegroundColor Yellow
        Copy-Item $templatePath $envPath
        Write-Host "✅ New .env.local created" -ForegroundColor Green
        Write-Host ""
    }
}

# Fix 2: Check if we need to prompt for credentials
$envContent = Get-Content $envPath -Raw
if (-not ($envContent -match "GMAIL_CLIENT_ID=(\S+)" -and $Matches[1] -ne "")) {
    Write-Host "→ Need Google OAuth credentials..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📖 Quick Instructions:" -ForegroundColor Cyan
    Write-Host "   1. Go to: https://console.cloud.google.com/apis/credentials" -ForegroundColor Gray
    Write-Host "   2. Click your OAuth 2.0 Client ID" -ForegroundColor Gray
    Write-Host "   3. Copy Client ID and Client Secret" -ForegroundColor Gray
    Write-Host ""
    
    $clientId = Read-Host "Enter Google OAuth Client ID (or press Enter to skip)"
    if ($clientId) {
        $clientSecret = Read-Host "Enter Google OAuth Client Secret"
        
        # Add to .env.local
        $envContent = Get-Content $envPath -Raw
        $envContent += "`n`n# Google OAuth Credentials (Added by Quick Fix)`n"
        $envContent += "GMAIL_CLIENT_ID=$clientId`n"
        $envContent += "GMAIL_CLIENT_SECRET=$clientSecret`n"
        $envContent += "GCAL_CLIENT_ID=$clientId`n"
        $envContent += "GCAL_CLIENT_SECRET=$clientSecret`n"
        $envContent += "GDRIVE_CLIENT_ID=$clientId`n"
        $envContent += "GDRIVE_CLIENT_SECRET=$clientSecret`n"
        $envContent | Set-Content $envPath -Encoding UTF8
        
        Write-Host "✅ Credentials added to .env.local" -ForegroundColor Green
        Write-Host ""
    }
}

# Fix 3: Offer to run OAuth token generation
$envContent = Get-Content $envPath -Raw
if (-not ($envContent -match "GMAIL_REFRESH_TOKEN=(\S+)" -and $Matches[1] -ne "" -and $Matches[1] -ne "GMAIL_REFRESH_TOKEN=")) {
    Write-Host "→ Need to generate REFRESH_TOKEN..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📖 This will:" -ForegroundColor Cyan
    Write-Host "   1. Open your browser for Google sign-in" -ForegroundColor Gray
    Write-Host "   2. Ask you to approve permissions" -ForegroundColor Gray
    Write-Host "   3. Save the refresh token automatically" -ForegroundColor Gray
    Write-Host ""
    
    $generateTokens = Read-Host "Generate tokens now? (y/n)"
    if ($generateTokens -eq 'y') {
        $tokenScript = "$repoPath\GENERATE_GOOGLE_TOKENS.ps1"
        if (Test-Path $tokenScript) {
            Write-Host "→ Running OAuth token generator..." -ForegroundColor Yellow
            & $tokenScript
        } else {
            Write-Host "❌ GENERATE_GOOGLE_TOKENS.ps1 not found" -ForegroundColor Red
            Write-Host "   Try: .\scripts\auth\run_oauth_youtube.ps1" -ForegroundColor Yellow
        }
    } else {
        Write-Host ""
        Write-Host "⚠️  Skipped token generation" -ForegroundColor Yellow
        Write-Host "   Run manually: .\GENERATE_GOOGLE_TOKENS.ps1" -ForegroundColor Gray
        Write-Host ""
    }
}

# Fix 4: Create secrets directory if missing
if (-not (Test-Path $secretsPath)) {
    Write-Host "→ Creating secrets/ directory..." -ForegroundColor Yellow
    New-Item -Path $secretsPath -ItemType Directory -Force | Out-Null
    Write-Host "✅ secrets/ directory created" -ForegroundColor Green
    Write-Host ""
}

# Final status check
Write-Host ""
Write-Host "⬢═══════════════════════════════════════════════════════════⬢" -ForegroundColor Cyan
Write-Host "   REPAIR COMPLETE" -ForegroundColor Cyan
Write-Host "⬢═══════════════════════════════════════════════════════════⬢" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. Verify refresh tokens exist:" -ForegroundColor Gray
Write-Host "      notepad .env.local" -ForegroundColor White
Write-Host ""
Write-Host "   2. Activate agents:" -ForegroundColor Gray
Write-Host "      .\ACTIVATE_AGENTS.ps1" -ForegroundColor White
Write-Host ""
Write-Host "   3. Check status:" -ForegroundColor Gray
Write-Host "      .\STATUS_CHECK.ps1" -ForegroundColor White
Write-Host ""
Write-Host "   4. Start dashboard:" -ForegroundColor Gray
Write-Host "      .\START_DASHBOARD.bat" -ForegroundColor White
Write-Host ""

Write-Host "📖 Full guide: C:\Users\alexl\Desktop\OAUTH_LOOP_FIX_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
