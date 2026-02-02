# Create Missing Photos Import Script
# Wraps Python Google Photos import

Write-Host "Running Google Photos import..." -ForegroundColor Cyan

$scriptPath = Join-Path $PSScriptRoot "media\import_google_photos.py"

if (Test-Path $scriptPath) {
    python $scriptPath
} else {
    Write-Host "Error: import_google_photos.py not found" -ForegroundColor Red
    Write-Host "Expected: $scriptPath" -ForegroundColor Yellow
    exit 1
}
