# Sentinel Audit - Security and Health Check
# Alias for sentinel.ps1

$ErrorActionPreference = "Stop"

Write-Host "Running Sentinel Security Audit..." -ForegroundColor Cyan

# Run the main sentinel script
$sentinelScript = Join-Path $PSScriptRoot "sentinel.ps1"

if (Test-Path $sentinelScript) {
    & $sentinelScript
} else {
    Write-Host "Error: sentinel.ps1 not found" -ForegroundColor Red
    exit 1
}
