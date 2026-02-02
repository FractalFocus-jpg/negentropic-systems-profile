<#
UOS_DRIVE_INBOX_SYNC.ps1
Mirrors a local Google Drive sync folder (objectives inbox) into the Obsidian vault inbox.
No OAuth required (uses the local synced filesystem).

Default mapping:
  C:\Users\alexl\My Drive\inbox  ->  C:\Users\alexl\the living tapestry\inbox

Copies new/updated files. Does NOT delete anything from either side.
Writes a small sync log entry to OS/logs.
#>

param(
  [string]$DriveInbox = 'C:\Users\alexl\My Drive\inbox',
  [string]$VaultInbox = 'C:\Users\alexl\the living tapestry\inbox',
  [string]$VaultRoot  = 'C:\Users\alexl\the living tapestry'
)

$ErrorActionPreference = 'Stop'

$ts = Get-Date
$iso = $ts.ToString('yyyy-MM-ddTHH:mm:ss.ffffzzz')

New-Item -ItemType Directory -Force -Path $DriveInbox | Out-Null
New-Item -ItemType Directory -Force -Path $VaultInbox | Out-Null

$src = Get-ChildItem -LiteralPath $DriveInbox -Recurse -File -ErrorAction SilentlyContinue
$copied = 0

foreach ($f in $src) {
  $rel = $f.FullName.Substring($DriveInbox.Length).TrimStart('\\')
  $dest = Join-Path $VaultInbox $rel
  $destDir = Split-Path -Parent $dest
  if (!(Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }

  $doCopy = $true
  if (Test-Path -LiteralPath $dest) {
    $d = Get-Item -LiteralPath $dest
    # copy only if source is newer or size differs
    if ($d.Length -eq $f.Length -and $d.LastWriteTimeUtc -ge $f.LastWriteTimeUtc) {
      $doCopy = $false
    }
  }

  if ($doCopy) {
    Copy-Item -LiteralPath $f.FullName -Destination $dest -Force
    $copied++
  }
}

# Log (append)
$logsPath = Join-Path $VaultRoot 'OS\logs'
New-Item -ItemType Directory -Force -Path $logsPath | Out-Null
$todayLog = Join-Path $logsPath (Get-Date -Format 'yyyy-MM-dd')
$todayLog = $todayLog + '.md'

$entry = @"

## [DRIVE_INBOX_SYNC] - $iso
- Source: $DriveInbox
- Target: $VaultInbox
- Files scanned: $($src.Count)
- Files copied/updated: $copied
"@

Add-Content -LiteralPath $todayLog -Value $entry -Encoding UTF8
