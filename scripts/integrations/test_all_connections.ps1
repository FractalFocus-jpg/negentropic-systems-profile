# TEST_ALL_CONNECTIONS_V25.ps1
# Tests all workspace integrations for LT_vΩ.25

$ErrorActionPreference = "Continue"
$repoRoot = Split-Path -Parent $PSScriptRoot
$scriptsPath = Join-Path $repoRoot "scripts\integrations"

Write-Host ""
Write-Host "⬢ LT_vΩ.25 - CONNECTION TEST SUITE" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Activate virtual environment
$venvPath = Join-Path $repoRoot ".venv"
if (Test-Path $venvPath) {
    & "$venvPath\Scripts\Activate.ps1"
    Write-Host "✅ Virtual environment activated" -ForegroundColor Green
} else {
    Write-Host "⚠️  Virtual environment not found at: $venvPath" -ForegroundColor Yellow
    Write-Host "Creating virtual environment..." -ForegroundColor Yellow
    python -m venv $venvPath
    & "$venvPath\Scripts\Activate.ps1"
    pip install -r "$repoRoot\requirements.txt"
    Write-Host "✅ Virtual environment created and activated" -ForegroundColor Green
}

Write-Host ""

# Test results
$results = @{}

# Test Linear
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "🔗 Testing Linear Integration..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

try {
    python "$scriptsPath\linear_link.py"
    $results["Linear"] = "✅ PASSED"
    Write-Host ""
} catch {
    $results["Linear"] = "❌ FAILED"
    Write-Host "❌ Linear test failed: $_" -ForegroundColor Red
    Write-Host ""
}

# Test Confluence
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📚 Testing Confluence Integration..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

try {
    python "$scriptsPath\confluence_sync.py"
    $results["Confluence"] = "✅ PASSED"
    Write-Host ""
} catch {
    $results["Confluence"] = "❌ FAILED"
    Write-Host "❌ Confluence test failed: $_" -ForegroundColor Red
    Write-Host ""
}

# Test Google Drive
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "☁️  Testing Google Drive Integration..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

try {
    python "$repoRoot\test_drive_api.py"
    $results["Google Drive"] = "✅ PASSED"
    Write-Host ""
} catch {
    $results["Google Drive"] = "❌ FAILED"
    Write-Host "❌ Google Drive test failed: $_" -ForegroundColor Red
    Write-Host ""
}

# Test Google Photos
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📸 Testing Google Photos Integration..." -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

try {
    python "$repoRoot\scripts\media\import_google_photos.py" --test
    $results["Google Photos"] = "✅ PASSED"
    Write-Host ""
} catch {
    $results["Google Photos"] = "❌ FAILED"
    Write-Host "❌ Google Photos test failed: $_" -ForegroundColor Red
    Write-Host ""
}

# Summary
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📊 CONNECTION TEST SUMMARY" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

$passCount = 0
$failCount = 0

foreach ($service in $results.Keys | Sort-Object) {
    $status = $results[$service]
    $color = if ($status -like "*✅*") {
        $passCount++
        "Green"
    } else {
        $failCount++
        "Red"
    }
    Write-Host "  $($service.PadRight(20)): $status" -ForegroundColor $color
}

Write-Host ""
Write-Host "Results: $passCount passed, $failCount failed" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "🎉 ALL CONNECTIONS SUCCESSFUL!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "  1. Review integration reports in: C:\Users\alexl\the living tapestry\OS\reports\" -ForegroundColor Cyan
    Write-Host "  2. Launch UOS Control Center: .\LAUNCH_UOS_CONTROL_CENTER.ps1" -ForegroundColor Cyan
    Write-Host "  3. Verify agents: .\VERIFY_UOS_STATUS.ps1" -ForegroundColor Cyan
} else {
    Write-Host "⚠️  Some connections failed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor White
    Write-Host "  1. Verify API keys in .env.local" -ForegroundColor Gray
    Write-Host "  2. Check service URLs and credentials" -ForegroundColor Gray
    Write-Host "  3. Re-run credential collection: .\COLLECT_CREDENTIALS_V25.ps1" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
