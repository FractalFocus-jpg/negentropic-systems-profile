<#
Starts minimal HTTP services for all 7 agents (ports 3001-3007).
These provide /health and /run endpoints so the mesh is *actually online*.
#>

param(
  [string]$RepoRoot = 'C:\Users\alexl\Desktop\tapestry-codex-starter'
)

$ErrorActionPreference = 'Stop'

$py = Join-Path $RepoRoot '.venv\Scripts\python.exe'
if (!(Test-Path -LiteralPath $py)) { throw "Missing venv python: $py" }

$svc = Join-Path $RepoRoot 'scripts\agents\agent_service.py'
if (!(Test-Path -LiteralPath $svc)) { throw "Missing: $svc" }

$agents = @(
  @{ name='sentinel'; port=3001 },
  @{ name='weaver';   port=3002 },
  @{ name='janus';    port=3003 },
  @{ name='hermes';   port=3004 },
  @{ name='scribe';   port=3005 },
  @{ name='ledger';   port=3006 },
  @{ name='choir';    port=3007 }
)

foreach ($a in $agents) {
  $port = $a.port
  $name = $a.name

  $listening = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($listening) {
    Write-Host "[$name] already listening on $port" -ForegroundColor Yellow
    continue
  }

  Write-Host "Starting [$name] on port $port..." -ForegroundColor Cyan
  $cmd = "`$env:AGENT_NAME='$name'; `$env:PORT='$port'; `$env:REPO_ROOT='$RepoRoot'; `$env:VAULT_ROOT='C:\\Users\\alexl\\the living tapestry'; & '$py' '$svc'"
  Start-Process -FilePath "powershell.exe" -WorkingDirectory $RepoRoot -WindowStyle Hidden -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-Command',$cmd) | Out-Null
}

Write-Host "Agent services start requested." -ForegroundColor Green
Write-Host "Check health endpoints:" -ForegroundColor Gray
Write-Host "  http://localhost:3001/health (sentinel)" -ForegroundColor Gray
Write-Host "  http://localhost:3002/health (weaver)" -ForegroundColor Gray
Write-Host "  http://localhost:3003/health (janus)" -ForegroundColor Gray
Write-Host "  http://localhost:3004/health (hermes)" -ForegroundColor Gray
Write-Host "  http://localhost:3005/health (scribe)" -ForegroundColor Gray
Write-Host "  http://localhost:3006/health (ledger)" -ForegroundColor Gray
Write-Host "  http://localhost:3007/health (choir)" -ForegroundColor Gray
