# COLLECT_CREDENTIALS_V25.ps1
# LT_vΩ.25 - Interactive API Credential Collection
# Guides user through getting all necessary API keys

param(
    [switch]$SkipOptional = $false
)

$ErrorActionPreference = "Continue"
$repoRoot = Split-Path -Parent $PSScriptRoot
$envPath = Join-Path $repoRoot ".env.local"

Write-Host ""
Write-Host "⬢ LT_vΩ.25 - CREDENTIAL COLLECTION WIZARD" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This wizard will help you collect API keys for:" -ForegroundColor White
Write-Host "  • Linear (project management)" -ForegroundColor Gray
Write-Host "  • Confluence (knowledge base)" -ForegroundColor Gray
Write-Host "  • Notion (databases)" -ForegroundColor Gray
Write-Host "  • Anthropic Claude (AI)" -ForegroundColor Gray
Write-Host "  • Google Gemini (AI)" -ForegroundColor Gray
Write-Host ""

# Backup existing .env.local
if (Test-Path $envPath) {
    $backupPath = "$envPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $envPath $backupPath
    Write-Host "✅ Backed up .env.local to: $backupPath" -ForegroundColor Green
    Write-Host ""
}

# Function to update or add env variable
function Update-EnvVariable {
    param(
        [string]$Key,
        [string]$Value
    )
    
    $content = Get-Content $envPath -Raw
    
    # Check if key exists
    if ($content -match "(?m)^$Key=.*$") {
        # Replace existing value
        $content = $content -replace "(?m)^$Key=.*$", "$Key=$Value"
    } else {
        # Append new key
        $content += "`n$Key=$Value"
    }
    
    Set-Content -Path $envPath -Value $content -NoNewline
}

# Function to prompt for credential with instructions
function Get-Credential-Interactive {
    param(
        [string]$Service,
        [string]$EnvKey,
        [string]$Instructions,
        [string]$URL,
        [bool]$Required = $true
    )
    
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "🔑 $Service" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host $Instructions -ForegroundColor White
    Write-Host ""
    
    if ($URL) {
        Write-Host "📍 URL: $URL" -ForegroundColor Cyan
        Write-Host ""
        $openBrowser = Read-Host "Open this URL in browser? (Y/n)"
        if ($openBrowser -ne 'n' -and $openBrowser -ne 'N') {
            Start-Process $URL
            Write-Host "  ✅ Opened in browser" -ForegroundColor Green
            Write-Host ""
        }
    }
    
    Write-Host "Paste your $Service here:" -ForegroundColor Cyan
    Write-Host "(Press Enter to skip if you don't have it yet)" -ForegroundColor Gray
    Write-Host ""
    
    $value = Read-Host "  $EnvKey"
    
    if ([string]::IsNullOrWhiteSpace($value)) {
        if ($Required) {
            Write-Host "  ⚠️  SKIPPED - This is required for full functionality!" -ForegroundColor Yellow
        } else {
            Write-Host "  ⏭️  Skipped (optional)" -ForegroundColor Gray
        }
        return $null
    } else {
        Update-EnvVariable -Key $EnvKey -Value $value
        Write-Host "  ✅ Saved to .env.local" -ForegroundColor Green
        return $value
    }
}

# ============================================================================
# LINEAR API KEY
# ============================================================================

$linearKey = Get-Credential-Interactive `
    -Service "Linear API Key" `
    -EnvKey "LINEAR_API_KEY" `
    -Instructions @"
Linear is a project management tool for tracking tasks and issues.

Steps to get your Linear API key:
1. Go to Linear Settings → API
2. Click 'Personal API keys'
3. Click 'Create key'
4. Name it: 'LivingTapestry_OS'
5. Copy the generated key
"@ `
    -URL "https://linear.app/settings/api" `
    -Required $true

# If Linear key provided, also get team ID
if ($linearKey) {
    Write-Host ""
    Write-Host "To find your Linear Team ID:" -ForegroundColor White
    Write-Host "1. Go to your Linear workspace" -ForegroundColor Gray
    Write-Host "2. Look at the URL: linear.app/TEAM_KEY/..." -ForegroundColor Gray
    Write-Host "3. The TEAM_KEY is usually 3-4 letters (e.g., 'ENG', 'PRD')" -ForegroundColor Gray
    Write-Host ""
    $teamId = Read-Host "  LINEAR_TEAM_ID (or press Enter to skip)"
    if (-not [string]::IsNullOrWhiteSpace($teamId)) {
        Update-EnvVariable -Key "LINEAR_TEAM_ID" -Value $teamId
        Write-Host "  ✅ Saved LINEAR_TEAM_ID" -ForegroundColor Green
    }
}

# ============================================================================
# CONFLUENCE API TOKEN
# ============================================================================

$confluenceToken = Get-Credential-Interactive `
    -Service "Confluence API Token" `
    -EnvKey "CONFLUENCE_API_TOKEN" `
    -Instructions @"
Confluence is Atlassian's knowledge base / wiki platform.

Steps to get your Confluence API token:
1. Go to Atlassian account settings
2. Click 'Security' → 'Create and manage API tokens'
3. Click 'Create API token'
4. Label it: 'LivingTapestry_OS'
5. Copy the token (save it - you can't see it again!)
"@ `
    -URL "https://id.atlassian.com/manage-profile/security" `
    -Required $true

# If Confluence token provided, get additional details
if ($confluenceToken) {
    Write-Host ""
    Write-Host "Additional Confluence settings:" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Confluence Base URL (e.g., 'https://yourcompany.atlassian.net/wiki'):" -ForegroundColor Cyan
    $confluenceUrl = Read-Host "  CONFLUENCE_URL"
    if (-not [string]::IsNullOrWhiteSpace($confluenceUrl)) {
        Update-EnvVariable -Key "CONFLUENCE_URL" -Value $confluenceUrl
        Write-Host "  ✅ Saved CONFLUENCE_URL" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Your Atlassian email:" -ForegroundColor Cyan
    $confluenceUser = Read-Host "  CONFLUENCE_USER"
    if (-not [string]::IsNullOrWhiteSpace($confluenceUser)) {
        Update-EnvVariable -Key "CONFLUENCE_USER" -Value $confluenceUser
        Write-Host "  ✅ Saved CONFLUENCE_USER" -ForegroundColor Green
    }
}

# ============================================================================
# NOTION INTEGRATION
# ============================================================================

$notionKey = Get-Credential-Interactive `
    -Service "Notion Integration Secret" `
    -EnvKey "NOTION_API_KEY" `
    -Instructions @"
Notion is a workspace for notes, databases, and wikis.

Steps to get your Notion integration secret:
1. Go to Notion Integrations page
2. Click '+ New integration'
3. Name it: 'LivingTapestry OS'
4. Select workspace
5. Set capabilities: Read content, Update content, Insert content
6. Submit and copy the 'Internal Integration Token'
"@ `
    -URL "https://www.notion.so/my-integrations" `
    -Required $false

# If Notion key provided, explain database setup
if ($notionKey) {
    Write-Host ""
    Write-Host "⚠️  IMPORTANT: Share databases with integration" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "For each Notion database you want to access:" -ForegroundColor White
    Write-Host "1. Open the database in Notion" -ForegroundColor Gray
    Write-Host "2. Click '...' → 'Add connections'" -ForegroundColor Gray
    Write-Host "3. Select 'LivingTapestry OS'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press any key when you've shared your databases..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ============================================================================
# ANTHROPIC CLAUDE API
# ============================================================================

$anthropicKey = Get-Credential-Interactive `
    -Service "Anthropic Claude API Key" `
    -EnvKey "ANTHROPIC_API_KEY" `
    -Instructions @"
Anthropic Claude is the primary AI orchestrator for the UOS.

Steps to get your Anthropic API key:
1. Go to Anthropic Console
2. Sign in / create account
3. Navigate to 'API Keys'
4. Click 'Create Key'
5. Name it: 'LivingTapestry_OS'
6. Copy the key (starts with 'sk-ant-...')
"@ `
    -URL "https://console.anthropic.com/settings/keys" `
    -Required $true

# ============================================================================
# GOOGLE GEMINI API
# ============================================================================

$geminiKey = Get-Credential-Interactive `
    -Service "Google Gemini API Key" `
    -EnvKey "GEMINI_API_KEY" `
    -Instructions @"
Google Gemini provides additional AI capabilities for the mesh.

Steps to get your Gemini API key:
1. Go to Google AI Studio
2. Sign in with Google account
3. Click 'Get API key'
4. Create new key or use existing
5. Copy the key
"@ `
    -URL "https://aistudio.google.com/app/apikey" `
    -Required $false

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📊 CREDENTIAL COLLECTION SUMMARY" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

$summary = @{
    "Linear API" = if ($linearKey) { "✅ CONFIGURED" } else { "❌ MISSING" }
    "Confluence API" = if ($confluenceToken) { "✅ CONFIGURED" } else { "❌ MISSING" }
    "Notion Integration" = if ($notionKey) { "✅ CONFIGURED" } else { "⏭️  SKIPPED" }
    "Anthropic Claude" = if ($anthropicKey) { "✅ CONFIGURED" } else { "❌ MISSING" }
    "Google Gemini" = if ($geminiKey) { "✅ CONFIGURED" } else { "⏭️  SKIPPED" }
}

foreach ($service in $summary.Keys | Sort-Object) {
    $status = $summary[$service]
    $color = if ($status -like "*✅*") { "Green" } elseif ($status -like "*⏭️*") { "Gray" } else { "Yellow" }
    Write-Host "  $($service.PadRight(25)): $status" -ForegroundColor $color
}

Write-Host ""
Write-Host "💾 Configuration saved to: $envPath" -ForegroundColor Cyan
Write-Host ""

# Count configured services
$configured = ($summary.Values | Where-Object { $_ -like "*✅*" }).Count
$total = $summary.Count

if ($configured -eq $total) {
    Write-Host "🎉 ALL SERVICES CONFIGURED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next step: Run integration scripts" -ForegroundColor White
    Write-Host "  .\scripts\integrations\test_all_connections.ps1" -ForegroundColor Cyan
} elseif ($configured -ge 3) {
    Write-Host "✅ Core services configured ($configured/$total)" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can proceed with integration testing." -ForegroundColor White
    Write-Host "Missing services can be added later." -ForegroundColor Gray
} else {
    Write-Host "⚠️  Only $configured/$total services configured" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can re-run this script anytime to add more:" -ForegroundColor White
    Write-Host "  .\COLLECT_CREDENTIALS_V25.ps1" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
