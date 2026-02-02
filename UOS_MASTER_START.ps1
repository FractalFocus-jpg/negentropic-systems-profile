<#
UOS_MASTER_START.ps1
Starts the Self-Observing Dashboard (port 5055) and prints the URLs.
Non-destructive: does not touch OAuth or scheduled tasks.
#>

param(
  [string]$RepoRoot = 'C:\Users\alexl\Desktop\tapestry-codex-starter',
  [string]$HostIp = '127.0.0.1',
  [int]$Port = 5055
)

$ErrorActionPreference = 'Stop'

$py = Join-Path $RepoRoot '.venv\Scripts\python.exe'
$dashApp = Join-Path $RepoRoot 'src\tapestry\self_observing_dashboard.py'
$pidFile = Join-Path $RepoRoot 'logs\uos_dashboard_5055.pid'

if (!(Test-Path -LiteralPath $py)) { throw "Missing venv python: $py" }
if (!(Test-Path -LiteralPath $dashApp)) { throw "Missing dashboard app: $dashApp" }
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $pidFile) | Out-Null

# If already running, exit cleanly
$already = (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1)
if ($already) {
  Write-Host "Dashboard already listening on port $Port." -ForegroundColor Yellow
  Write-Host "Dashboard: http://localhost:$Port"
  Write-Host "JSON:      http://localhost:$Port/snapshot.json"
  exit 0
}

Write-Host "Starting UOS Self-Observing Dashboard on port $Port..." -ForegroundColor Cyan

$proc = Start-Process -FilePath $py -ArgumentList @($dashApp) -WorkingDirectory (Join-Path $RepoRoot 'src\tapestry') -PassThru
$proc.Id | Out-File -LiteralPath $pidFile -Encoding ascii

Start-Sleep -Seconds 1

$ok = Test-NetConnection -ComputerName 'localhost' -Port $Port -InformationLevel Quiet
if (!$ok) {
  Write-Host "Started process PID=$($proc.Id) but port $Port is not reachable yet." -ForegroundColor Yellow
  Write-Host "Check logs or run: Get-Process -Id $($proc.Id)" -ForegroundColor Yellow
} else {
  Write-Host "ONLINE" -ForegroundColor Green
}

Write-Host "Dashboard: http://localhost:$Port"
Write-Host "JSON:      http://localhost:$Port/snapshot.json"
Write-Host "PID file:  $pidFile"
