<#
UOS_COLD_BACKUP.ps1
Creates a nightly snapshot (zip) + SHA-256 manifest of critical IP and stores it in Google Drive.

Targets:
- C:\Users\alexl\clawd\patent_evidence
- C:\Users\alexl\the living tapestry\OS
- C:\Users\alexl\the living tapestry\000_GENESIS_CORE
- C:\Users\alexl\the living tapestry\002_SUBSTRATE_HARDWARE

Outputs:
- My Drive\AC3_COLD_BACKUPS\daily\AC3_COLD_<timestamp>.zip
- My Drive\AC3_COLD_BACKUPS\manifests\AC3_COLD_<timestamp>_SHA256.txt

No deletions.
NOTE: zip is not encrypted; encryption can be added later with 7-Zip/GPG.
#>

param(
  [string]$DriveBackupRoot = 'C:\Users\alexl\My Drive\AC3_COLD_BACKUPS',
  [string]$VaultRoot = 'C:\Users\alexl\the living tapestry',
  [string]$ClawdRoot = 'C:\Users\alexl\clawd'
)

$ErrorActionPreference = 'Stop'

$daily = Join-Path $DriveBackupRoot 'daily'
$man  = Join-Path $DriveBackupRoot 'manifests'
New-Item -ItemType Directory -Force -Path $daily,$man | Out-Null

$stamp = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')
$zipPath = Join-Path $daily ("AC3_COLD_{0}.zip" -f $stamp)
$hashPath = Join-Path $man ("AC3_COLD_{0}_SHA256.txt" -f $stamp)

$targets = @(
  (Join-Path $ClawdRoot 'patent_evidence'),
  (Join-Path $VaultRoot 'OS'),
  (Join-Path $VaultRoot '000_GENESIS_CORE'),
  (Join-Path $VaultRoot '002_SUBSTRATE_HARDWARE')
) | Where-Object { Test-Path -LiteralPath $_ }

# Build staging dir in %TEMP%
$tmp = Join-Path $env:TEMP ("ac3_cold_stage_{0}" -f $stamp)
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

foreach($t in $targets){
  $name = Split-Path -Leaf $t
  Copy-Item -LiteralPath $t -Destination (Join-Path $tmp $name) -Recurse -Force
}

# Zip
# Zip
Compress-Archive -LiteralPath (Join-Path $tmp '*') -DestinationPath $zipPath -Force

# Hash zip
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $zipPath).Hash.ToLowerInvariant()
"$hash  $zipPath" | Out-File -LiteralPath $hashPath -Encoding ascii

# Cleanup staging
Remove-Item -LiteralPath $tmp -Recurse -Force
