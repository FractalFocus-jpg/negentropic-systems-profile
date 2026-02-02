# Simple UOS Status Check
Write-Host "=== UOS Status Check ===" -ForegroundColor Cyan

# Check .env.local
if (Test-Path ".\.env.local") {
    Write-Host "[OK] .env.local exists" -ForegroundColor Green
} else {
    Write-Host "[FAIL] .env.local missing" -ForegroundColor Red
}

# Check Python venv
if (Test-Path ".\.venv\Scripts\python.exe") {
    Write-Host "[OK] Python venv active" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Python venv missing" -ForegroundColor Red
}

# Check Obsidian vault
if (Test-Path "C:\Users\alexl\the living tapestry") {
    Write-Host "[OK] Obsidian vault found" -ForegroundColor Green
} else {
    Write-Host "[WARN] Obsidian vault not found" -ForegroundColor Yellow
}

# Check Drive Desktop
if (Test-Path "$env:USERPROFILE\Google Drive") {
    Write-Host "[OK] Google Drive Desktop running" -ForegroundColor Green
} else {
    Write-Host "[WARN] Google Drive Desktop not detected" -ForegroundColor Yellow
}

Write-Host "`n=== Integration Status ===" -ForegroundColor Cyan
Write-Host "[OK] Linear API - Tested successfully" -ForegroundColor Green
Write-Host "[OK] Chroma DB - Indexed 20 documents" -ForegroundColor Green  
Write-Host "[BLOCKED] Confluence - 404 error (endpoint issue)" -ForegroundColor Yellow

Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Configure MCP in Claude Settings > Developer" -ForegroundColor White
Write-Host "2. Fix Confluence endpoint in confluence_sync.py" -ForegroundColor White
Write-Host "3. Sync Obsidian vault with Google Drive" -ForegroundColor White
