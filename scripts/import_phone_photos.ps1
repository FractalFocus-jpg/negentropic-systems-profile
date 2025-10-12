# Copyright (c) 2025 Alexander Liantonio.
# All rights reserved. Licensed under dual terms — see LICENSES/.

Param(
  [string]$Source = "C:\Users\alexl\Pictures\Your Phone\DCIM",
  [string]$Target = "C:\Users\alexl\the living tapestry\media\photos",
  [string]$Manifest = "C:\Users\alexl\the living tapestry\media\photos\manifest.csv"
)

Write-Host "=== DCIM Photo Import with SHA-256 De-duplication ===" -ForegroundColor Cyan

# Auto-detect source path with fallbacks
if (!(Test-Path $Source)) {
  Write-Host "Primary path not found: $Source" -ForegroundColor Yellow
  $fallbacks = @(
    "C:\Users\alexl\Pictures\Camera Roll",
    "C:\Users\alexl\Pictures\Your Phone\Internal Storage\DCIM"
  )
  foreach ($p in $fallbacks) {
    if (Test-Path $p) {
      $Source = $p
      Write-Host "Using fallback: $Source" -ForegroundColor Green
      break
    }
  }
  if (!(Test-Path $Source)) {
    Write-Host "ERROR: No valid source path found!" -ForegroundColor Red
    exit 1
  }
}

# Ensure target directory exists
if (!(Test-Path $Target)) {  New-Item -ItemType Directory -Path $Target -Force | Out-Null
}

# Initialize manifest if missing
if (!(Test-Path $Manifest)) {
  "hash,src,name,ts,exif_date" | Out-File -FilePath $Manifest -Encoding utf8
  Write-Host "Created new manifest: $Manifest" -ForegroundColor Green
}

# Load System.Drawing for EXIF extraction
Add-Type -AssemblyName System.Drawing

function Get-ExifDate($path) {
  try {
    $img = [System.Drawing.Image]::FromFile($path)
    $prop = $img.PropertyItems | Where-Object { $_.Id -eq 0x9003 } # DateTimeOriginal
    if ($prop) {
      $txt = ([System.Text.Encoding]::ASCII.GetString($prop.Value)).Trim([char]0)
      $img.Dispose()
      return [datetime]::ParseExact($txt,"yyyy:MM:dd HH:mm:ss",$null)
    } else {
      $img.Dispose()
      return $null
    }
  } catch {
    return $null
  }
}

Write-Host "Scanning source: $Source" -ForegroundColor Cyan
$imported = 0
$skipped = 0
Get-ChildItem -Path $Source -Recurse -Include *.jpg,*.jpeg,*.png,*.heic,*.mp4,*.mov -ErrorAction SilentlyContinue | ForEach-Object {
  $f = $_.FullName
  Write-Host "Processing: $($_.Name)" -NoNewline
  
  try {
    # Calculate SHA-256 hash
    $sha = (Get-FileHash -Algorithm SHA256 -Path $f).Hash
    
    # Quick de-dupe check in manifest
    if (Select-String -Path $Manifest -Pattern $sha -Quiet) {
      Write-Host " [SKIP - duplicate]" -ForegroundColor Yellow
      $skipped++
      return
    }

    # Extract EXIF date or use file date
    $ex = Get-ExifDate $f
    if (!$ex) { $ex = $_.LastWriteTime }
    
    # Generate year/month folder structure
    $year = $ex.ToString("yyyy")
    $month = $ex.ToString("yyyy-MM")
    $outDir = Join-Path $Target "$year\$month"
    
    if (!(Test-Path $outDir)) {
      New-Item -ItemType Directory -Path $outDir | Out-Null
    }

    # Generate unique filename with timestamp + hash prefix
    $name = "{0}_{1}{2}" -f $ex.ToString("yyyyMMdd_HHmmss"), $sha.Substring(0,8), $_.Extension
    $destPath = Join-Path $outDir $name    
    # Copy file to vault
    Copy-Item -Path $f -Destination $destPath -Force
    
    # Log to manifest
    "$sha,$f,$name,$([DateTime]::UtcNow.ToString('u')),$($ex.ToString('u'))" | Add-Content $Manifest -Encoding utf8
    
    Write-Host " [IMPORTED]" -ForegroundColor Green
    $imported++
    
  } catch {
    Write-Host " [ERROR: $($_.Exception.Message)]" -ForegroundColor Red
  }
}

Write-Host "`n=== Import Complete ===" -ForegroundColor Cyan
Write-Host "Imported: $imported new files" -ForegroundColor Green
Write-Host "Skipped: $skipped duplicates" -ForegroundColor Yellow
Write-Host "Target: $Target" -ForegroundColor Cyan
Write-Host "Manifest: $Manifest" -ForegroundColor Cyan
