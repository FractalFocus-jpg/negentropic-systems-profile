<#
UOS_MASTER_STOP.ps1
Stops the Self-Observing Dashboard started by UOS_MASTER_START.ps1.
#>

param(
  [string]$RepoRoot = 'C:\Users\alexl\Desktop\tapestry-codex-starter',
  [int]$Port = 5055
)

$ErrorActionPreference = 'Stop'

$pidFile = Join-Path $RepoRoot 'logs\uos_dashboard_5055.pid'

# Prefer pid file
if (Test-Path -LiteralPath $pidFile) {
  $pid = (Get-Content -LiteralPath $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1)
  if ($pid -and ($pid -as [int])) {
    try {
      Stop-Process -Id ([int]$pid) -Force -ErrorAction Stop
      Write-Host "Stopped dashboard PID=$pid" -ForegroundColor Green
      Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
      exit 0
    } catch {
      Write-Host "PID file found but could not stop PID=$pid (may already be stopped)." -ForegroundColor Yellow
    }
  }
}

# Fallback: kill anything listening on port
$cons = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($cons) {
  foreach ($c in $cons) {
    $p = $c.OwningProcess
    if ($p) {
      Stop-Process -Id $p -Force -ErrorAction SilentlyContinue
      Write-Host "Stopped process $p (port $Port)" -ForegroundColor Green
    }
  }
} else {
  Write-Host "No listener on port $Port" -ForegroundColor Yellow
}
