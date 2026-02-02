<#
UOS_NIGHTLY_OBJECTIVES.ps1
Creates next-day objectives summary from:
- OS/objectives/OBJECTIVE_INBOX.md
- Recent OS logs
- Recent drive mirror changes (by timestamp)

Writes:
- OS/reports/NIGHTLY_OBJECTIVES_YYYY-MM-DD.md

Token-free, local-first.
#>

param(
  [string]$VaultRoot = 'C:\Users\alexl\the living tapestry'
)

$ErrorActionPreference = 'Stop'

$now = Get-Date
$today = $now.ToString('yyyy-MM-dd')
$outDir = Join-Path $VaultRoot 'OS\reports'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$inbox = Join-Path $VaultRoot 'OS\objectives\OBJECTIVE_INBOX.md'
$log = Join-Path $VaultRoot ('OS\logs\' + $today + '.md')
$mirror = Join-Path $VaultRoot 'drive_mirror'

# Collect last 24h changed files (cap)
$since = (Get-Date).AddHours(-24).ToUniversalTime()
$changed = @()
if (Test-Path -LiteralPath $mirror) {
  $changed = Get-ChildItem -LiteralPath $mirror -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTimeUtc -ge $since } |
    Sort-Object LastWriteTimeUtc -Descending |
    Select-Object -First 100
}

# Take top of objective inbox (cap)
$inboxHead = @()
if (Test-Path -LiteralPath $inbox) {
  $inboxHead = Get-Content -LiteralPath $inbox -TotalCount 260 -ErrorAction SilentlyContinue
}

$logTail = @()
if (Test-Path -LiteralPath $log) {
  $logTail = Get-Content -LiteralPath $log -Tail 120 -ErrorAction SilentlyContinue
}

$ts = $now.ToString('yyyy-MM-ddTHH:mm:ss.ffffzzz')
$outPath = Join-Path $outDir ("NIGHTLY_OBJECTIVES_{0}.md" -f $today)

$md = New-Object System.Collections.Generic.List[string]
$md.Add('---')
$md.Add('type: nightly_objectives')
$md.Add('generated: ' + $ts)
$md.Add('window: last 24h')
$md.Add('---')
$md.Add('')
$md.Add('# Nightly Objectives (auto-generated)')
$md.Add('')
$md.Add('## Inputs observed')
$md.Add(('- Drive mirror changes (last 24h): **{0}**' -f ($changed | Measure-Object).Count))
$md.Add(('- Objective inbox present: **{0}**' -f (Test-Path -LiteralPath $inbox)))
$md.Add('')

$md.Add('## Top priorities for tomorrow (draft)')
$md.Add('1) Review new high-signal Drive docs (see list below)')
$md.Add('2) Patent/provenance hygiene: hash + manifest updates for any new core docs')
$md.Add('3) System health: keep gateway+agents stable, reduce CPU hotspots (Docker/MuseHub)')
$md.Add('')

$md.Add('## Suggested schedule (tomorrow)')
$md.Add('- 09:00 - Scan NIGHTLY_OBJECTIVES + new Drive inputs')
$md.Add('- 09:30 - Decide 1-3 execution targets (patent, physics, ops)')
$md.Add('- 10:00 - Deep work block (90m)')
$md.Add('- 13:00 - Ops/admin block (30m)')
$md.Add('- 16:00 - Publish/communicate (if any)')
$md.Add('')

$md.Add('## Execute while asleep (local-only)')
$md.Add('- Keep Drive mirror syncing into vault (UOSDriveFullSync)')
$md.Add('- Keep AC3 live dashboard pulse updating (UOSHeartbeatSync + objective extractor)')
$md.Add('- Generate updated evidence bundle manifests/hashes when new core docs appear (next iteration)')
$md.Add('')

$md.Add('## Recent Drive mirror changes (last 24h, top 100)')
if (($changed | Measure-Object).Count -eq 0) {
  $md.Add('- None detected')
} else {
  foreach ($f in $changed) {
    $md.Add(('- {0} | {1} | {2}' -f $f.LastWriteTime.ToString('MM-dd HH:mm'), $f.Length, $f.FullName))
  }
}
$md.Add('')

$md.Add('## Objective Inbox (head)')
if ($inboxHead.Count -gt 0) {
  $md.Add('```')
  foreach($l in $inboxHead){ $md.Add($l) }
  $md.Add('```')
} else {
  $md.Add('- Missing or empty objective inbox')
}
$md.Add('')

$md.Add('## Recent OS log tail')
if ($logTail.Count -gt 0) {
  $md.Add('```')
  foreach($l in $logTail){ $md.Add($l) }
  $md.Add('```')
} else {
  $md.Add('- No log yet for today')
}

$md | Out-File -LiteralPath $outPath -Encoding UTF8
