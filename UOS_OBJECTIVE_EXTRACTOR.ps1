<#
UOS_OBJECTIVE_EXTRACTOR.ps1
Local-first, token-free objective extraction from Drive mirror.

Reads:
  C:\Users\alexl\the living tapestry\drive_mirror
Writes:
  C:\Users\alexl\the living tapestry\OS\objectives\OBJECTIVE_INBOX.md
State:
  C:\Users\alexl\the living tapestry\OS\state\drive_objectives_state.json

Strategy:
- Only process files new/changed since last run (LastWriteTimeUtc)
- For text-like files, capture a short preview (first ~40 lines)
- For other types, capture metadata only
- Never deletes anything
#>

param(
  [string]$VaultRoot = 'C:\Users\alexl\the living tapestry',
  [string]$MirrorRel = 'drive_mirror'
)

$ErrorActionPreference = 'Stop'

$mirror = Join-Path $VaultRoot $MirrorRel
$stateDir = Join-Path $VaultRoot 'OS\state'
$objectiveDir = Join-Path $VaultRoot 'OS\objectives'
$statePath = Join-Path $stateDir 'drive_objectives_state.json'
$outPath = Join-Path $objectiveDir 'OBJECTIVE_INBOX.md'

New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
New-Item -ItemType Directory -Force -Path $objectiveDir | Out-Null

$now = Get-Date
$nowIso = $now.ToString('yyyy-MM-ddTHH:mm:ss.ffffzzz')

$lastUtc = [DateTime]::MinValue
if (Test-Path -LiteralPath $statePath) {
  try {
    $st = (Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json)
    if ($st.lastScanUtc) { $lastUtc = [DateTime]::Parse($st.lastScanUtc).ToUniversalTime() }
  } catch {}
}

if (!(Test-Path -LiteralPath $mirror)) {
  # Mirror may not exist yet; create it
  New-Item -ItemType Directory -Force -Path $mirror | Out-Null
}

$textExt = @('.md','.txt','.csv','.tsv','.json','.yaml','.yml','.log')

$changed = Get-ChildItem -LiteralPath $mirror -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.LastWriteTimeUtc -gt $lastUtc } |
  Sort-Object LastWriteTimeUtc -Descending |
  Select-Object -First 200

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('---')
$lines.Add('type: objective_inbox')
$lines.Add('generated: ' + $nowIso)
$lines.Add('source: drive_mirror incremental scan')
$lines.Add('---')
$lines.Add('')
$lines.Add('# Objective Inbox (from Drive mirror)')
$lines.Add('')
$lines.Add("Last scan UTC: $($lastUtc.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))")
$lines.Add("This run: $nowIso")
$lines.Add('')

if (($changed | Measure-Object).Count -eq 0) {
  $lines.Add('- No new/changed files since last scan.')
} else {
  $i = 0
  foreach ($f in $changed) {
    $i++
    $rel = $f.FullName.Substring($mirror.Length).TrimStart('\\')
    $ext = $f.Extension.ToLowerInvariant()
    $lines.Add("## [$i] $($f.Name)")
    $lines.Add('- Path: ' + $f.FullName)
    $lines.Add('- Modified: ' + $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))
    $lines.Add('- Size: ' + $f.Length)

    if ($textExt -contains $ext -and $f.Length -le 2MB) {
      $lines.Add('')
      $lines.Add('Preview (first ~40 lines):')
      $lines.Add('```')
      try {
        (Get-Content -LiteralPath $f.FullName -TotalCount 40 -ErrorAction Stop) | ForEach-Object { $lines.Add($_) }
      } catch {
        $lines.Add('[preview error]')
      }
      $lines.Add('```')
    }

    $lines.Add('')
  }
}

$lines | Out-File -LiteralPath $outPath -Encoding UTF8

@{
  lastScanUtc = $now.ToUniversalTime().ToString('o')
  lastScanLocal = $now.ToString('o')
  changedCount = ($changed | Measure-Object).Count
} | ConvertTo-Json -Depth 4 | Out-File -LiteralPath $statePath -Encoding UTF8
