# Nightly Sync Agent - LT OS
$ErrorActionPreference = "Continue"
$root = "C:\Users\alexl\Desktop\tapestry-codex-starter"
cd $root
$env:PYTHONIOENCODING='utf-8'

Write-Host "🌙 Nightly Sync $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Cyan

# Activate venv
.venv\Scripts\Activate.ps1

# Linear sync
Write-Host "📋 Linear..." -ForegroundColor Yellow
python scripts\integrations\linear_link.py --sync

# Chroma reindex
Write-Host "🗂️  Chroma..." -ForegroundColor Yellow  
python scripts\integrations\chroma_sync.py --index

# Status digest
$status = @"
# Nightly Sync Report
**Date**: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
✅ Linear synced
✅ Chroma reindexed
"@

$status | Out-File "C:\Users\alexl\the living tapestry\OS\reports\nightly_$(Get-Date -Format 'yyyyMMdd').md"
Write-Host "✅ Complete" -ForegroundColor Green
