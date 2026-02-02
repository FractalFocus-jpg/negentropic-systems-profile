<#
Google Drive Sync (sanitized ASCII)

Reality check: this project currently relies on **Google Drive for Desktop** as the sync substrate.
This script is therefore local-first and does NOT call Drive APIs.

It:
- Verifies that the expected local mirror exists (C:\Users\alexl\My Drive)
- Verifies key vault directories exist
- Logs a timestamped status line into the Obsidian vault log

Safe: no secrets printed, no network.
#>

param(
  [switch]$DryRun = $true
)

$ErrorActionPreference = 'SilentlyContinue'

$vaultRoot = 'C:\Users\alexl\the living tapestry'
$driveRoot = 'C:\Users\alexl\My Drive'

Write-Host "Google Drive Sync (local-first)" -ForegroundColor Cyan
Write-Host ("Vault: {0}" -f $vaultRoot) -ForegroundColor Gray
Write-Host ("Drive mirror: {0}" -f $driveRoot) -ForegroundColor Gray

$driveOk = Test-Path $driveRoot
$vaultOk = Test-Path $vaultRoot

$pathsToCheck = @(
  Join-Path $vaultRoot 'OS\\logs',
  Join-Path $vaultRoot 'OS\\agents',
  Join-Path $vaultRoot 'NEGENTROPIC_PORTAL'
)

$missing = @()
foreach ($p in $pathsToCheck) {
  if (!(Test-Path $p)) { $missing += $p }
}

$logFile = Join-Path $vaultRoot ("OS\\logs\\{0}.md" -f (Get-Date -Format 'yyyy-MM-dd'))

function Append-Log($line) {
  try {
    $dir = Split-Path $logFile
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Add-Content -Path $logFile -Value $line
  } catch {}
}

$ts = Get-Date -Format 'HH:mm:ss'

if (-not $vaultOk) {
  Write-Host "Vault missing" -ForegroundColor Yellow
  Append-Log "`n## [DRIVE SYNC] - $ts`nStatus: Vault missing at $vaultRoot"
  exit 1
}

if (-not $driveOk) {
  Write-Host "Drive mirror not detected (Google Drive for Desktop not running/synced)." -ForegroundColor Yellow
  Append-Log "`n## [DRIVE SYNC] - $ts`nStatus: Drive mirror missing at $driveRoot (check Google Drive for Desktop)."
  exit 0
}

if ($missing.Count -gt 0) {
  Write-Host "Vault structure degraded (missing expected paths)." -ForegroundColor Yellow
  $missing | ForEach-Object { Write-Host ("Missing: {0}" -f $_) -ForegroundColor DarkYellow }
  Append-Log "`n## [DRIVE SYNC] - $ts`nStatus: Vault degraded (missing paths)."
  exit 0
}

Write-Host "OK - local mirror present; vault structure OK." -ForegroundColor Green
Append-Log "`n## [DRIVE SYNC] - $ts`nStatus: OK (local mirror present; API sync not used)."

exit 0
