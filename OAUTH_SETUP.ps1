# LT vOmega.14 - OAuth Credential Setup
# Simple and reliable credential collection

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  LIVING TAPESTRY - OAuth Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$envPath = "C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local"

# Create .env.local if it does not exist
if (!(Test-Path $envPath)) {
    Write-Host "Creating .env.local..." -ForegroundColor Yellow
    New-Item -Path $envPath -ItemType File -Force | Out-Null
}

Write-Host "Credentials will be saved to:" -ForegroundColor Green
Write-Host $envPath -ForegroundColor White
Write-Host ""

# Initialize credentials array
$creds = @()

# Google Services
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host "GOOGLE SERVICES" -ForegroundColor Cyan
Write-Host "console.cloud.google.com/apis/credentials" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

$googleClient = Read-Host "Google OAuth Client ID (or Enter to skip)"
if ($googleClient) {
    $googleSecret = Read-Host "Google OAuth Client Secret"
    $creds += "# Google Services"
    $creds += "GMAIL_CLIENT_ID=$googleClient"
    $creds += "GMAIL_CLIENT_SECRET=$googleSecret"
    $creds += "GCAL_CLIENT_ID=$googleClient"
    $creds += "GCAL_CLIENT_SECRET=$googleSecret"
    $creds += "GDRIVE_CLIENT_ID=$googleClient"
    $creds += "GDRIVE_CLIENT_SECRET=$googleSecret"
    $creds += "GPHOTOS_CLIENT_ID=$googleClient"
    $creds += "GPHOTOS_CLIENT_SECRET=$googleSecret"
    $creds += "YOUTUBE_CLIENT_ID=$googleClient"
    $creds += "YOUTUBE_CLIENT_SECRET=$googleSecret"
    $creds += ""
    Write-Host "Stored Google credentials" -ForegroundColor Green
    Write-Host ""
}

# Linear
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host "LINEAR" -ForegroundColor Cyan  
Write-Host "linear.app/settings/api" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

$linearKey = Read-Host "Linear API Key (or Enter to skip)"
if ($linearKey) {
    $creds += "# Linear"
    $creds += "LINEAR_API_KEY=$linearKey"
    $creds += ""
    Write-Host "Stored Linear credentials" -ForegroundColor Green
    Write-Host ""
}

# Confluence
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host "CONFLUENCE" -ForegroundColor Cyan  
Write-Host "id.atlassian.com/manage-profile/security" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

$confToken = Read-Host "Confluence API Token (or Enter to skip)"
if ($confToken) {
    $confUrl = Read-Host "Confluence URL (e.g. yourorg.atlassian.net)"
    $creds += "# Confluence"
    $creds += "CONFLUENCE_API_TOKEN=$confToken"
    $creds += "CONFLUENCE_BASE_URL=$confUrl"
    $creds += "CONFLUENCE_EMAIL=alexliantonio43@gmail.com"
    $creds += ""
    Write-Host "Stored Confluence credentials" -ForegroundColor Green
    Write-Host ""
}

# Notion
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host "NOTION" -ForegroundColor Cyan
Write-Host "notion.so/my-integrations" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

$notionKey = Read-Host "Notion Integration Secret (or Enter to skip)"
if ($notionKey) {
    $creds += "# Notion"
    $creds += "NOTION_INTEGRATION_SECRET=$notionKey"
    $creds += ""
    Write-Host "Stored Notion credentials" -ForegroundColor Green
    Write-Host ""
}

# Anthropic
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host "ANTHROPIC (Claude)" -ForegroundColor Cyan
Write-Host "console.anthropic.com/settings/keys" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

$anthropicKey = Read-Host "Anthropic API Key (or Enter to skip)"
if ($anthropicKey) {
    $creds += "# Anthropic"
    $creds += "ANTHROPIC_API_KEY=$anthropicKey"
    $creds += ""
    Write-Host "Stored Anthropic credentials" -ForegroundColor Green
    Write-Host ""
}

# Gemini
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host "GOOGLE GEMINI" -ForegroundColor Cyan
Write-Host "makersuite.google.com/app/apikey" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host ""

$geminiKey = Read-Host "Gemini API Key (or Enter to skip)"
if ($geminiKey) {
    $creds += "# Gemini"
    $creds += "GEMINI_API_KEY=$geminiKey"
    $creds += ""
    Write-Host "Stored Gemini credentials" -ForegroundColor Green
    Write-Host ""
}

# Write all credentials to file
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "SAVING CREDENTIALS" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$creds | Out-File -FilePath $envPath -Encoding UTF8

Write-Host "Saved to: $envPath" -ForegroundColor Green
$credCount = ($creds | Where-Object { $_ -match "=" }).Count
Write-Host "Total credentials: $credCount" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Review file:  notepad '$envPath'" -ForegroundColor Yellow
Write-Host "2. Deploy:       .\DEPLOY_AGENT_KIT.ps1" -ForegroundColor Yellow
Write-Host "3. Monitor:      http://localhost:5055" -ForegroundColor Yellow
Write-Host ""

Write-Host "OAuth setup complete!" -ForegroundColor Cyan
Write-Host ""
