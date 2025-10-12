# ============================================================================
# SAFE DESKTOP CLEANUP
# Removes duplicates and unnecessary files (with confirmation)
# ============================================================================

$ErrorActionPreference = "Stop"

Write-Host "`n⬢ DESKTOP CLEANUP ROUTINE..." -ForegroundColor Cyan
Write-Host "==========================`n" -ForegroundColor Cyan

# Track what will be deleted
$ItemsToDelete = @()
$TotalSize = 0

# Item 1: SCMS - Copy (exact duplicate)
$SCMSCopy = "C:\Users\alexl\Desktop\SCMS - Copy"
if (Test-Path $SCMSCopy) {
    $Size = (Get-ChildItem $SCMSCopy -Recurse | Measure-Object -Property Length -Sum).Sum
    $ItemsToDelete += [PSCustomObject]@{
        Path = $SCMSCopy
        Type = "Folder"
        Size = $Size
        Reason = "Exact duplicate of SCMS"
    }
    $TotalSize += $Size
}

# Item 2: SCMS.zip (extracted)
$SCMSZip = "C:\Users\alexl\Desktop\SCMS.zip"
if (Test-Path $SCMSZip) {
    $Size = (Get-Item $SCMSZip).Length
    $ItemsToDelete += [PSCustomObject]@{
        Path = $SCMSZip
        Type = "Archive"
        Size = $Size
        Reason = "Already extracted to SCMS folder"
    }
    $TotalSize += $Size
}

# Item 3: tapestry-codex-starter.zip (extracted and working)
$TapestryZip = "C:\Users\alexl\Downloads\tapestry-codex-starter.zip"
if (Test-Path $TapestryZip) {
    $Size = (Get-Item $TapestryZip).Length
    $ItemsToDelete += [PSCustomObject]@{
        Path = $TapestryZip
        Type = "Archive"
        Size = $Size
        Reason = "Extracted to Desktop, project working"
    }
    $TotalSize += $Size
}

# Display cleanup plan
if ($ItemsToDelete.Count -eq 0) {
    Write-Host "✅ No cleanup needed - desktop already clean!`n" -ForegroundColor Green
    exit 0
}

Write-Host "📋 CLEANUP PLAN:" -ForegroundColor White
Write-Host "===============`n" -ForegroundColor White

foreach ($Item in $ItemsToDelete) {
    $SizeMB = [math]::Round($Item.Size / 1MB, 2)
    Write-Host "❌ DELETE: $($Item.Path)" -ForegroundColor Red
    Write-Host "   Type: $($Item.Type)" -ForegroundColor Gray
    Write-Host "   Size: $SizeMB MB" -ForegroundColor Gray
    Write-Host "   Reason: $($Item.Reason)" -ForegroundColor Yellow
    Write-Host ""
}

$TotalMB = [math]::Round($TotalSize / 1MB, 2)
Write-Host "📊 Total: $($ItemsToDelete.Count) items, $TotalMB MB`n" -ForegroundColor Cyan

# Confirmation
Write-Host "⚠️  WARNING: This action cannot be undone!`n" -ForegroundColor Yellow
$Confirm = Read-Host "Proceed with cleanup? (YES to confirm)"

if ($Confirm -ne "YES") {
    Write-Host "`n❌ Cleanup cancelled by user`n" -ForegroundColor Red
    exit 0
}

# Execute cleanup
Write-Host "`n🧹 Executing cleanup...`n" -ForegroundColor Cyan

$Success = 0
$Failed = 0

foreach ($Item in $ItemsToDelete) {
    Write-Host "   Deleting: $($Item.Path)..." -ForegroundColor Gray -NoNewline
    
    try {
        if ($Item.Type -eq "Folder") {
            Remove-Item -Path $Item.Path -Recurse -Force -ErrorAction Stop
        } else {
            Remove-Item -Path $Item.Path -Force -ErrorAction Stop
        }
        Write-Host " ✅" -ForegroundColor Green
        $Success++
    } catch {
        Write-Host " ❌ Failed: $_" -ForegroundColor Red
        $Failed++
    }
}

# Summary
Write-Host ""
Write-Host "📊 CLEANUP SUMMARY:" -ForegroundColor White
Write-Host "   Deleted: $Success items" -ForegroundColor Green
Write-Host "   Failed: $Failed items" -ForegroundColor $(if ($Failed -gt 0) { "Red" } else { "Gray" })
Write-Host "   Space Freed: $TotalMB MB`n" -ForegroundColor Cyan

if ($Failed -eq 0) {
    Write-Host "✅ Desktop cleanup complete!`n" -ForegroundColor Green
} else {
    Write-Host "⚠️  Cleanup completed with errors`n" -ForegroundColor Yellow
}

Write-Host "⬢ The field is clear. The lattice breathes.`n" -ForegroundColor Cyan
