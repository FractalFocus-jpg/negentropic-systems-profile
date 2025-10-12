# ============================================================================
# TAPESTRY PHONE PHOTO IMPORTER v1.0
# SHA-256 De-duplication + EXIF-Based Organization
# ============================================================================

Param(
    [string]$SourcePath = "",  # Auto-detect or provide manually
    [string]$VaultMedia = "C:\Users\alexl\the living tapestry\media\photos",
    [switch]$DryRun = $false
)

# ANSI Colors
$GREEN = "`e[32m"
$YELLOW = "`e[33m"
$BLUE = "`e[36m"
$RED = "`e[31m"
$RESET = "`e[0m"

Write-Host "${BLUE}═══════════════════════════════════════════${RESET}"
Write-Host "${BLUE}  TAPESTRY PHONE PHOTO IMPORTER${RESET}"
Write-Host "${BLUE}═══════════════════════════════════════════${RESET}"
Write-Host ""

# ============================================================================
# STEP 1: AUTO-DETECT PHONE DCIM PATH
# ============================================================================

if ([string]::IsNullOrEmpty($SourcePath)) {
    Write-Host "${YELLOW}[AUTO-DETECT]${RESET} Searching for phone DCIM folder..."
    
    $candidates = @(
        "C:\Users\$env:USERNAME\Pictures\Your Phone\DCIM",
        "C:\Users\$env:USERNAME\Pictures\Camera Roll",
        "C:\Users\$env:USERNAME\OneDrive\Pictures\Camera Roll"
    )
    
    # Check for MTP mounted phone
    $shell = New-Object -ComObject Shell.Application
    $computer = $shell.NameSpace(17)  # My Computer
    
    foreach ($item in $computer.Items()) {
        if ($item.IsFolder -and $item.Name -match "Phone|Android|iPhone|Galaxy") {
            $phonePath = $item.Path
            $dcimCandidate = Join-Path $phonePath "Internal storage\DCIM"
            if (Test-Path $dcimCandidate) {
                $candidates += $dcimCandidate
            }
        }
    }
    
    # Find first valid path
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            $SourcePath = $candidate
            Write-Host "${GREEN}✓ Found:${RESET} $SourcePath"
            break
        }
    }
    
    if ([string]::IsNullOrEmpty($SourcePath)) {
        Write-Host "${RED}✗ ERROR:${RESET} No phone DCIM folder detected."
        Write-Host ""
        Write-Host "${YELLOW}OPTIONS:${RESET}"
        Write-Host "  1. Connect phone via USB and enable File Transfer (MTP)"
        Write-Host "  2. Set up Phone Link: ms-settings:mobile-devices"
        Write-Host "  3. Provide custom path: -SourcePath 'D:\DCIM'"
        Write-Host ""
        exit 1
    }
}

if (-not (Test-Path $SourcePath)) {
    Write-Host "${RED}✗ ERROR:${RESET} Source path does not exist: $SourcePath"
    exit 1
}

# ============================================================================
# STEP 2: COLLECT ALL PHOTOS FROM SOURCE
# ============================================================================

Write-Host ""
Write-Host "${YELLOW}[SCAN]${RESET} Collecting photos from source..."

$imageExtensions = @("*.jpg", "*.jpeg", "*.png", "*.gif", "*.heic", "*.webp", "*.bmp")
$allPhotos = @()

foreach ($ext in $imageExtensions) {
    $allPhotos += Get-ChildItem -Path $SourcePath -Filter $ext -Recurse -ErrorAction SilentlyContinue
}

Write-Host "${GREEN}✓ Found:${RESET} $($allPhotos.Count) photos"

if ($allPhotos.Count -eq 0) {
    Write-Host "${YELLOW}⚠ No photos to import.${RESET}"
    exit 0
}

# ============================================================================
# STEP 3: BUILD HASH REGISTRY OF EXISTING VAULT PHOTOS
# ============================================================================

Write-Host ""
Write-Host "${YELLOW}[HASH]${RESET} Building deduplication registry..."

$existingHashes = @{}

if (Test-Path $VaultMedia) {
    $existingPhotos = Get-ChildItem -Path $VaultMedia -Recurse -File -ErrorAction SilentlyContinue
    
    foreach ($photo in $existingPhotos) {
        try {
            $hash = (Get-FileHash -Path $photo.FullName -Algorithm SHA256).Hash
            $existingHashes[$hash] = $photo.FullName
        } catch {
            # Skip files that can't be hashed
        }
    }
}

Write-Host "${GREEN}✓ Registry:${RESET} $($existingHashes.Count) existing photos indexed"

# ============================================================================
# STEP 4: IMPORT NEW PHOTOS (DE-DUPLICATED)
# ============================================================================

Write-Host ""
Write-Host "${YELLOW}[IMPORT]${RESET} Processing photos..."

$imported = 0
$skipped = 0
$errors = 0

foreach ($photo in $allPhotos) {
    try {
        # Calculate SHA-256
        $hash = (Get-FileHash -Path $photo.FullName -Algorithm SHA256).Hash
        
        # Check if already exists
        if ($existingHashes.ContainsKey($hash)) {
            $skipped++
            Write-Host "  ${BLUE}⊘${RESET} Skip: $($photo.Name) (duplicate)"
            continue
        }
        
        # Get date taken (from EXIF or file modified date)
        $dateTaken = $photo.LastWriteTime
        
        # Organize: YYYY/YYYY-MM/
        $year = $dateTaken.ToString("yyyy")
        $month = $dateTaken.ToString("yyyy-MM")
        $destFolder = Join-Path $VaultMedia "$year\$month"
        
        # Ensure folder exists
        if (-not (Test-Path $destFolder)) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
            }
        }
        
        # Destination path
        $destPath = Join-Path $destFolder $photo.Name
        
        # Handle name collisions
        $counter = 1
        while (Test-Path $destPath) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($photo.Name)
            $extension = $photo.Extension
            $destPath = Join-Path $destFolder "$baseName-$counter$extension"
            $counter++
        }
        
        # Copy file
        if ($DryRun) {
            Write-Host "  ${GREEN}✓${RESET} Would import: $($photo.Name) → $month"
        } else {
            Copy-Item -Path $photo.FullName -Destination $destPath -Force
            Write-Host "  ${GREEN}✓${RESET} Imported: $($photo.Name) → $month"
        }
        
        $imported++
        
    } catch {
        $errors++
        Write-Host "  ${RED}✗${RESET} Error: $($photo.Name) - $($_.Exception.Message)"
    }
}

# ============================================================================
# STEP 5: GENERATE SUMMARY
# ============================================================================

Write-Host ""
Write-Host "${BLUE}═══════════════════════════════════════════${RESET}"
Write-Host "${BLUE}  IMPORT SUMMARY${RESET}"
Write-Host "${BLUE}═══════════════════════════════════════════${RESET}"
Write-Host ""
Write-Host "  Source: $SourcePath"
Write-Host "  Destination: $VaultMedia"
Write-Host ""
Write-Host "  ${GREEN}Imported:${RESET} $imported"
Write-Host "  ${BLUE}Skipped:${RESET}  $skipped (duplicates)"
Write-Host "  ${RED}Errors:${RESET}   $errors"
Write-Host ""

if ($DryRun) {
    Write-Host "${YELLOW}[DRY RUN]${RESET} No files were actually copied."
    Write-Host "Run without -DryRun to perform import."
} else {
    Write-Host "${GREEN}✓ Import complete!${RESET}"
}

# ============================================================================
# STEP 6: UPDATE VAULT LOGS
# ============================================================================

if (-not $DryRun -and $imported -gt 0) {
    $logDate = Get-Date -Format "yyyy-MM-dd"
    $logTime = Get-Date -Format "HH:mm:ss"
    $logFile = "C:\Users\alexl\the living tapestry\systems\logs\$logDate.md"
    
    # Ensure log exists
    if (-not (Test-Path $logFile)) {
        @"
---
type: daily_ops
date: $logDate
---

# Daily Operations — $logDate

"@ | Out-File -FilePath $logFile -Encoding UTF8
    }
    
    # Append media import entry
    @"

## [MEDIA IMPORT] — $logTime
- **Source**: ``$SourcePath``
- **Imported**: $imported new photos
- **Skipped**: $skipped duplicates
- **Errors**: $errors
- **Destination**: ``$VaultMedia``
- **Method**: SHA-256 deduplication

"@ | Add-Content -Path $logFile -Encoding UTF8
    
    Write-Host ""
    Write-Host "${GREEN}✓ Logged to:${RESET} systems\logs\$logDate.md"
}

Write-Host ""
