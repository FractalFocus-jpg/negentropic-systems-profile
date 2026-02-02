# Sentinel (sanitized ASCII version)
# Purpose: basic security/health checks without fancy formatting.

param(
  [string]$VaultRoot = "C:\Users\alexl\the living tapestry"
)

$ErrorActionPreference = "Continue"

Write-Host "Sentinel - Security & Health Monitor" -ForegroundColor Cyan
Write-Host ("Timestamp: {0}" -f (Get-Date).ToString("o")) -ForegroundColor Gray

# Basic vault checks
$checks = @(
  "OS\\STATUS_DASHBOARD.md",
  "OS\\OS_MANIFEST.yaml",
  "ops\\UOS Command Center.md"
)

$missing = @()
foreach ($rel in $checks) {
  $p = Join-Path $VaultRoot $rel
  if (!(Test-Path $p)) { $missing += $rel }
}

if ($missing.Count -gt 0) {
  Write-Host "Vault integrity: DEGRADED" -ForegroundColor Yellow
  $missing | ForEach-Object { Write-Host (" - missing: {0}" -f $_) -ForegroundColor Yellow }
} else {
  Write-Host "Vault integrity: OK" -ForegroundColor Green
}

# Agent ports (best-effort)
$ports = @(3001,3002,3003,3004,3005,3006,5055)
foreach ($port in $ports) {
  try {
    $c = Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction Stop
    if ($c) { Write-Host ("Listening: {0}" -f $port) -ForegroundColor Green }
  } catch {
    Write-Host ("Not listening: {0}" -f $port) -ForegroundColor Yellow
  }
}

Write-Host "Sentinel complete" -ForegroundColor Green
