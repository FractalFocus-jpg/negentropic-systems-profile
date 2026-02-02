<#
UOS_DRIVE_FULL_SYNC.ps1
Copies ALL new/updated files from Google Drive sync folder into the Obsidian vault for agent objectives.

Source:  C:\Users\alexl\My Drive
Target:  C:\Users\alexl\the living tapestry\drive_mirror

Safety:
- NO deletions (does not use /MIR)
- Excludes the vault folder already inside My Drive ("the living tapestry") to avoid recursion
#>

param(
  [string]$DriveRoot = 'C:\Users\alexl\My Drive',
  [string]$VaultRoot = 'C:\Users\alexl\the living tapestry',
  [string]$TargetRel = 'drive_mirror'
)

$ErrorActionPreference = 'Stop'

$target = Join-Path $VaultRoot $TargetRel
New-Item -ItemType Directory -Force -Path $target | Out-Null

# Robocopy: copy subdirs, skip older files, tolerate FAT timestamp drift
$excludeDirs = @(
  'the living tapestry',
  '$RECYCLE.BIN',
  'System Volume Information'
)

$xdArgs = @()
foreach($d in $excludeDirs){ $xdArgs += '/XD'; $xdArgs += (Join-Path $DriveRoot $d) }

$logDir = Join-Path $VaultRoot 'OS\logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir ((Get-Date -Format 'yyyy-MM-dd') + '.md')
$iso = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss.ffffzzz')

# /E copy subdirs including empty
# /XO exclude older
# /FFT assume FAT times (2-second granularity) helps with cloud sync
# /R:1 /W:1 minimal retries
# /NFL /NDL reduce noise
$cmd = @('robocopy', "`"$DriveRoot`"", "`"$target`"", '/E','/XO','/FFT','/R:1','/W:1','/NP','/NFL','/NDL') + $xdArgs

$start = Get-Date
& $cmd[0] $cmd[1..($cmd.Count-1)] | Out-Null
$dur = [math]::Round(((Get-Date)-$start).TotalSeconds,2)

Add-Content -LiteralPath $log -Encoding UTF8 -Value ("`r`n`r`n## [DRIVE_FULL_SYNC] - $iso`r`n- Source: $DriveRoot`r`n- Target: $target`r`n- Note: robocopy /E /XO (no deletions), excludes vault recursion`r`n- Duration: ${dur}s`r`n")
