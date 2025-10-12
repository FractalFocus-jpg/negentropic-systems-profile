# Cognitive Drift Index (CDI) Tracker
# Monitors process switching and computes drift score

Param(
  [int]$WindowSec = 60,
  [string]$VaultLogs = "C:\Users\alexl\the living tapestry\systems\logs"
)

if (!(Test-Path $VaultLogs)) { 
    New-Item -ItemType Directory -Path $VaultLogs | Out-Null 
}

$start = Get-Date
$switches = 0
$lastProc = (Get-Process | Sort-Object CPU -Descending | Select-Object -First 1).ProcessName

$endTime = (Get-Date).AddSeconds($WindowSec)
while ((Get-Date) -lt $endTime) {
  Start-Sleep -Milliseconds 800
  $top = (Get-Process | Sort-Object CPU -Descending | Select-Object -First 1).ProcessName
  if ($top -ne $lastProc) { 
    $switches++
    $lastProc = $top 
  }
}

# Simple CDI (0-1) based on normalized switches
# ~30 switches/min => 1.0 (high drift)
# ~0 switches/min => 0.0 (perfect focus)
$cdi = [Math]::Min(1.0, [Math]::Round($switches / 30.0, 3))

$stamp = (Get-Date).ToString("yyyy-MM-dd")
$logFile = Join-Path $VaultLogs ("{0}.md" -f $stamp)

# Create log file if doesn't exist
if (!(Test-Path $logFile)) {
  @"
---
type: daily_ops
date: $stamp
---
# Daily Operations - $stamp

"@ | Out-File -Encoding UTF8 $logFile
}

# Append CDI sample
@"

## CDI Sample - $((Get-Date).ToString("HH:mm:ss"))
- window_sec: $WindowSec
- switches: $switches
- cdi: $cdi

"@ | Add-Content -Path $logFile -Encoding UTF8

Write-Output "CDI=$cdi (switches=$switches in ${WindowSec}s) -> $logFile"
