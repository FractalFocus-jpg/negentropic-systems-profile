# SETUP_API_KEYS_WIZARD.ps1
# Interactive wizard to collect and configure all API keys for LT_vΩ.27

param(
    [switch]$SkipConfirmation = $false
)

$ErrorActionPreference = "Stop"
$envPath = Join-Path $PSScriptRoot ".env.local"

Write-Host ""
Write-Host "⬢ LT_vΩ.27 API KEY SETUP WIZARD" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This wizard will help you configure all API keys needed for full integration." -ForegroundColor White
Write-Host ""

if (-not $SkipConfirmation) {
    $response = Read-Host "Ready to begin? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "Cancelled." -ForegroundColor Gray
        exit 0
    }
}

# Function to update .env.local
function Update-EnvKey {
    param(
        [string]$Key,
        [string]$Value
    )
    
    $content = Get-Content $envPath
    $found = $false
    
    for ($i = 0; $i -lt $content.Length; $i++) {
        if ($content[$i] -like "$Key=*") {
            $content[$i] = "$Key=$Value"
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        # Add new key
        $content += "$Key=$Value"
    }
    
    Set-Content -Path $envPath -Value $content -Encoding UTF8
}

# Function to open URL in browser
function Open-Url {
    param([string]$Url)
    Start-Process $Url
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "1️⃣  LINEAR API KEY" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Linear is used for task and issue tracking." -ForegroundColor Gray
Write-Host ""
Write-Host "Opening Linear API settings..." -ForegroundColor Yellow
Open-Url "https://linear.app/settings/api"
Write-Host ""
Write-Host "Steps:" -ForegroundColor White
Write-Host "  1. Log in to Linear" -ForegroundColor Gray
Write-Host "  2. Click 'Personal API keys' or 'Create new key'" -ForegroundColor Gray
Write-Host "  3. Name: LivingTapestry_OS" -ForegroundColor Gray
Write-Host "  4. Copy the generated key" -ForegroundColor Gray
Write-Host ""
$linearKey = Read-Host "Paste LINEAR_API_KEY (or press Enter to skip)"

if ($linearKey) {
    Update-EnvKey -Key "LINEAR_API_KEY" -Value $linearKey
    Write-Host "  ✅ Linear API key saved" -ForegroundColor Green
} else {
    Write-Host "  ⏭️  Skipped" -ForegroundColor Gray
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "2️⃣  CONFLUENCE API TOKEN" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Confluence is used for wiki/documentation sync." -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Confluence URL already configured:" -ForegroundColor Green
Write-Host "   https://newilluminati.atlassian.net/wiki" -ForegroundColor Cyan
Write-Host ""
Write-Host "Opening Atlassian security settings..." -ForegroundColor Yellow
Open-Url "https://id.atlassian.com/manage-profile/security"
Write-Host ""
Write-Host "Steps:" -ForegroundColor White
Write-Host "  1. Log in to Atlassian" -ForegroundColor Gray
Write-Host "  2. Scroll to 'API tokens'" -ForegroundColor Gray
Write-Host "  3. Click 'Create API token'" -ForegroundColor Gray
Write-Host "  4. Label: LivingTapestry_OS" -ForegroundColor Gray
Write-Host "  5. Copy the token" -ForegroundColor Gray
Write-Host ""
$confluenceToken = Read-Host "Paste CONFLUENCE_API_TOKEN (or press Enter to skip)"

if ($confluenceToken) {
    Update-EnvKey -Key "CONFLUENCE_API_TOKEN" -Value $confluenceToken
    Write-Host "  ✅ Confluence API token saved" -ForegroundColor Green
    
    Write-Host ""
    $confluenceEmail = Read-Host "Enter your Atlassian email address"
    if ($confluenceEmail) {
        Update-EnvKey -Key "CONFLUENCE_USER" -Value $confluenceEmail
        Write-Host "  ✅ Confluence email saved" -ForegroundColor Green
    }
} else {
    Write-Host "  ⏭️  Skipped" -ForegroundColor Gray
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "3️⃣  NOTION API KEY" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Notion is used for knowledge base integration." -ForegroundColor Gray
Write-Host ""
Write-Host "Opening Notion integrations..." -ForegroundColor Yellow
Open-Url "https://www.notion.so/my-integrations"
Write-Host ""
Write-Host "Steps:" -ForegroundColor White
Write-Host "  1. Log in to Notion" -ForegroundColor Gray
Write-Host "  2. Click '+ New integration'" -ForegroundColor Gray
Write-Host "  3. Name: LivingTapestry OS" -ForegroundColor Gray
Write-Host "  4. Select capabilities: Read content, Update content" -ForegroundColor Gray
Write-Host "  5. Submit" -ForegroundColor Gray
Write-Host "  6. Copy the 'Internal Integration Token'" -ForegroundColor Gray
Write-Host ""
$notionKey = Read-Host "Paste NOTION_API_KEY (or press Enter to skip)"

if ($notionKey) {
    Update-EnvKey -Key "NOTION_API_KEY" -Value $notionKey
    Write-Host "  ✅ Notion API key saved" -ForegroundColor Green
} else {
    Write-Host "  ⏭️  Skipped" -ForegroundColor Gray
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "4️⃣  ANTHROPIC API KEY (Claude)" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  CRITICAL: Required for AI mesh functionality!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Opening Anthropic console..." -ForegroundColor Yellow
Open-Url "https://console.anthropic.com/settings/keys"
Write-Host ""
Write-Host "Steps:" -ForegroundColor White
Write-Host "  1. Log in to Anthropic Console" -ForegroundColor Gray
Write-Host "  2. Create API key named 'LivingTapestry_OS'" -ForegroundColor Gray
Write-Host "  3. Copy the key (starts with 'sk-ant-')" -ForegroundColor Gray
Write-Host ""
$anthropicKey = Read-Host "Paste ANTHROPIC_API_KEY (or press Enter to skip)"

if ($anthropicKey) {
    Update-EnvKey -Key "ANTHROPIC_API_KEY" -Value $anthropicKey
    Write-Host "  ✅ Anthropic API key saved" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Skipped - AI mesh will not function" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "5️⃣  GEMINI API KEY (Google)" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Gemini provides backup AI capabilities." -ForegroundColor Gray
Write-Host ""
Write-Host "Opening Google AI Studio..." -ForegroundColor Yellow
Open-Url "https://makersuite.google.com/app/apikey"
Write-Host ""
Write-Host "Steps:" -ForegroundColor White
Write-Host "  1. Log in to Google AI Studio" -ForegroundColor Gray
Write-Host "  2. Create API key (or use existing)" -ForegroundColor Gray
Write-Host "  3. Copy the key" -ForegroundColor Gray
Write-Host ""
$geminiKey = Read-Host "Paste GEMINI_API_KEY (or press Enter to skip)"

if ($geminiKey) {
    Update-EnvKey -Key "GEMINI_API_KEY" -Value $geminiKey
    Write-Host "  ✅ Gemini API key saved" -ForegroundColor Green
} else {
    Write-Host "  ⏭️  Skipped" -ForegroundColor Gray
}

# Summary
Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ SETUP COMPLETE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Run diagnostic
Write-Host "Running diagnostic..." -ForegroundColor Yellow
Write-Host ""
& "$PSScriptRoot\CHECK_API_KEYS.ps1"

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "NEXT STEPS" -ForegroundColor White
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Test integrations:" -ForegroundColor White
Write-Host "   python scripts\integrations\linear_link.py --test" -ForegroundColor Cyan
Write-Host "   python scripts\integrations\confluence_sync.py --test" -ForegroundColor Cyan
Write-Host "   python scripts\integrations\chroma_sync.py --test" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Launch UOS Control Center:" -ForegroundColor White
Write-Host "   .\LAUNCH_UOS_CONTROL_CENTER.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Verify status:" -ForegroundColor White
Write-Host "   .\VERIFY_UOS_STATUS.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
