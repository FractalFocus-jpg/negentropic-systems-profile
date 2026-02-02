# CHECK_API_KEYS.ps1
# Diagnostic script to check which API keys are configured

$envPath = Join-Path $PSScriptRoot ".env.local"

if (-not (Test-Path $envPath)) {
    Write-Host "ERROR: .env.local not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "LT_vOmega.25 - API KEY DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Read .env.local
$envLines = Get-Content $envPath

# Target keys for vOmega.25 integration
$requiredKeys = @(
    @{Name="LINEAR_API_KEY"; Category="Workspace"},
    @{Name="CONFLUENCE_API_TOKEN"; Category="Workspace"},
    @{Name="CONFLUENCE_URL"; Category="Workspace"},
    @{Name="CONFLUENCE_USER"; Category="Workspace"},
    @{Name="NOTION_API_KEY"; Category="Workspace"},
    @{Name="ANTHROPIC_API_KEY"; Category="AI"},
    @{Name="GEMINI_API_KEY"; Category="AI"},
    @{Name="GPHOTOS_CLIENT_ID"; Category="Google"},
    @{Name="GPHOTOS_CLIENT_SECRET"; Category="Google"},
    @{Name="GPHOTOS_REFRESH_TOKEN"; Category="Google"}
)

# Check each key
$missingKeys = @()
$presentKeys = @()

foreach ($keyInfo in $requiredKeys) {
    $keyName = $keyInfo.Name
    $found = $false
    
    foreach ($line in $envLines) {
        if ($line -like "$keyName=*") {
            $value = $line.Substring($keyName.Length + 1).Trim()
            if ($value -ne "") {
                $presentKeys += $keyInfo
                Write-Host "  OK: $keyName" -ForegroundColor Green
                $found = $true
                break
            }
        }
    }
    
    if (-not $found) {
        $missingKeys += $keyInfo
        Write-Host "  MISS: $keyName" -ForegroundColor Red
    }
}

# Summary by category
Write-Host ""
Write-Host "SUMMARY" -ForegroundColor White
Write-Host "=======" -ForegroundColor White
Write-Host ""

$categories = $requiredKeys | Select-Object -ExpandProperty Category -Unique

foreach ($category in $categories) {
    $categoryKeys = $requiredKeys | Where-Object { $_.Category -eq $category }
    $presentCount = ($presentKeys | Where-Object { $_.Category -eq $category }).Count
    $totalCount = $categoryKeys.Count
    
    $status = if ($presentCount -eq $totalCount) { "OK" } elseif ($presentCount -gt 0) { "PARTIAL" } else { "MISSING" }
    $color = if ($presentCount -eq $totalCount) { "Green" } elseif ($presentCount -gt 0) { "Yellow" } else { "Red" }
    
    Write-Host "$status - $category`: $presentCount/$totalCount configured" -ForegroundColor $color
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan

if ($missingKeys.Count -eq 0) {
    Write-Host "SUCCESS: ALL KEYS CONFIGURED" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ready to proceed with LT_vOmega.25 integration!" -ForegroundColor Green
} else {
    Write-Host "WARNING: MISSING $($missingKeys.Count) KEY(S)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host ""
    
    # Group by category for instructions
    $missingByCategory = $missingKeys | Group-Object -Property Category
    
    foreach ($group in $missingByCategory) {
        Write-Host "$($group.Name):" -ForegroundColor Cyan
        
        switch ($group.Name) {
            "Workspace" {
                Write-Host "  - Linear: https://linear.app/settings/api" -ForegroundColor Gray
                Write-Host "  - Confluence: https://id.atlassian.com/manage-profile/security" -ForegroundColor Gray
                Write-Host "  - Notion: https://www.notion.so/my-integrations" -ForegroundColor Gray
            }
            "AI" {
                Write-Host "  - Anthropic: https://console.anthropic.com/settings/keys" -ForegroundColor Gray
                Write-Host "  - Gemini: https://makersuite.google.com/app/apikey" -ForegroundColor Gray
            }
            "Google" {
                Write-Host "  - Run: .\GENERATE_GOOGLE_TOKENS.ps1" -ForegroundColor Gray
                Write-Host "  - Enable Photos API in Google Cloud Console" -ForegroundColor Gray
            }
        }
        Write-Host ""
    }
}

Write-Host ""
