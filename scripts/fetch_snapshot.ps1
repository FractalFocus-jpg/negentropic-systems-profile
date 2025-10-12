# Coherence Snapshot Script
# Fetches data from dashboard and writes to Obsidian vault

param(
  [string]$JsonUrl = "http://localhost:5055/snapshot.json",
  [string]$VaultPath = "C:\Users\alexl\the living tapestry",
  [string]$RunsRel = "runs"
)

Write-Host "`nFETCHING COHERENCE SNAPSHOT..." -ForegroundColor Cyan

# Ensure runs directory exists
$RunsPath = Join-Path $VaultPath $RunsRel
if (!(Test-Path $RunsPath)) {
    New-Item -ItemType Directory -Path $RunsPath | Out-Null
}

# Fetch JSON
Write-Host "Connecting to $JsonUrl..." -ForegroundColor Gray
try {
    $resp = Invoke-WebRequest -Uri $JsonUrl -UseBasicParsing -TimeoutSec 10
    $data = $resp.Content | ConvertFrom-Json
    Write-Host "SUCCESS: Received $($data.Count) samples" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to connect" -ForegroundColor Red
    Write-Host "Ensure dashboard is running at http://localhost:5055" -ForegroundColor Yellow
    exit 1
}

if ($data.Count -eq 0) {
    Write-Host "WARNING: Buffer is empty" -ForegroundColor Yellow
    Write-Host "Click Start button in dashboard UI" -ForegroundColor Yellow
    exit 0
}

# Compute statistics
Write-Host "Computing statistics..." -ForegroundColor Gray
$values = @($data | ForEach-Object { [double]$_.c })
$samples = $values.Count
$mean = [Math]::Round(($values | Measure-Object -Average).Average, 4)
$min = [Math]::Round(($values | Measure-Object -Minimum).Minimum, 4)
$max = [Math]::Round(($values | Measure-Object -Maximum).Maximum, 4)

# Standard deviation
$avg = ($values | Measure-Object -Average).Average
$variance = ($values | ForEach-Object { [Math]::Pow(($_ - $avg), 2) } | Measure-Object -Sum).Sum / $samples
$std = [Math]::Round([Math]::Sqrt($variance), 4)

Write-Host "   Samples: $samples" -ForegroundColor White
Write-Host "   Mean:    $mean" -ForegroundColor Cyan
Write-Host "   Range:   $min - $max" -ForegroundColor Gray
Write-Host "   StdDev:  $std" -ForegroundColor Gray

# Prepare data
$timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
$isoTime = (Get-Date -Format s)
$notePath = Join-Path $RunsPath "coherence-log-$timestamp.md"
$preview = ($data | Select-Object -First 10 | ConvertTo-Json -Depth 4)

# Determine status
if ($mean -ge 0.85) {
    $status = "Perfect"
    $assessment = "Excellent coherence! System operating at optimal threshold."
} elseif ($mean -ge 0.70) {
    $status = "Healthy"
    $assessment = "Healthy coherence. System stable within optimal range."
} elseif ($mean -ge 0.55) {
    $status = "Monitor"
    $assessment = "Moderate coherence. Watch for drift toward chaos threshold."
} else {
    $status = "Warning"
    $assessment = "Low coherence detected. System approaching chaotic regime."
}

# Create markdown - USING PROPER HERE-STRING FORMAT
$markdown = @"
---
type: coherence-log
created: $isoTime
source: $JsonUrl
samples: $samples
c_mean: $mean
c_min: $min
c_max: $max
c_std: $std
status: $status
sphere: 5
tags: [coherence-log, dashboard, sphere-5]
---

# Coherence Log - $timestamp

Captured from Self-Observing Dashboard

## Statistics

| Metric | Value |
|--------|-------|
| Samples | $samples |
| Mean PLV | $mean |
| Min / Max | $min - $max |
| Std Dev | $std |
| Status | $status |

## Assessment

Mean PLV: $mean

$assessment

## Raw Data (First 10 Samples)

``````json
$preview
``````

## Links

Dashboard: http://localhost:5055
System: [[systems/inference-engine-prime]]
Index: [[dashboards/coherence-index]]

Generated: $isoTime
Sphere: 5 (Simulations)

#coherence-log #dashboard #sphere-5
"@

# Write file
$markdown | Out-File -FilePath $notePath -Encoding UTF8

# Report success
Write-Host "`nSUCCESS: Snapshot saved!" -ForegroundColor Green
Write-Host "Location: $notePath" -ForegroundColor White
Write-Host "`nSUMMARY:" -ForegroundColor Magenta
Write-Host "   Status: $status" -ForegroundColor White
Write-Host "   Mean: $mean" -ForegroundColor Cyan

if ($mean -ge 0.85) {
    Write-Host "   System coherence optimal!" -ForegroundColor Green
} elseif ($mean -lt 0.55) {
    Write-Host "   WARNING: Below threshold!" -ForegroundColor Red
}

Write-Host "`nSnapshot complete!`n" -ForegroundColor Cyan
