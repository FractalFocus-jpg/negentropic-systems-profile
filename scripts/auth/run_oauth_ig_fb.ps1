# 🜂 Instagram Graph API OAuth Flow
# Via Facebook App + Business Account

Param([string]$EnvFile = ".env.local")
$ErrorActionPreference = "Stop"

# Load .env.local
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
        }
    }
}

$appId = $env:IG_APP_ID
$appSecret = $env:IG_APP_SECRET
$redirectUri = $env:IG_REDIRECT_URI

if (-not $appId -or -not $appSecret) {
    Write-Error "IG_APP_ID and IG_APP_SECRET must be set in .env.local"
    exit 1
}

Write-Host "🜂 Instagram Graph API OAuth" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prerequisites:" -ForegroundColor Yellow
Write-Host "1. Create Facebook App at https://developers.facebook.com/"
Write-Host "2. Add Instagram Graph API product"
Write-Host "3. Convert Instagram to Business account"
Write-Host "4. Add scopes: instagram_basic, instagram_content_publish"
Write-Host "5. Set redirect URI: $redirectUri"
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$scope = "instagram_basic,instagram_content_publish,pages_show_list,pages_read_engagement"
$state = -join ((65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})
$authUrl = "https://www.facebook.com/v18.0/dialog/oauth?client_id=$appId&redirect_uri=$redirectUri&scope=$scope&response_type=code&state=$state"

Start-Process $authUrl
Write-Host "Paste the redirect URL after authorizing:" -ForegroundColor Green
$redirectedUrl = Read-Host

if ($redirectedUrl -match '[?&]code=([^&]+)') {
    $code = $matches[1]
} else {
    Write-Error "Could not extract code"
    exit 1
}

# Exchange for token
$tokenUrl = "https://graph.facebook.com/v18.0/oauth/access_token?client_id=$appId&redirect_uri=$redirectUri&client_secret=$appSecret&code=$code"
$response = Invoke-RestMethod -Uri $tokenUrl -Method Get

# Get long-lived token
$longTokenUrl = "https://graph.facebook.com/v18.0/oauth/access_token?grant_type=fb_exchange_token&client_id=$appId&client_secret=$appSecret&fb_exchange_token=$($response.access_token)"
$longToken = Invoke-RestMethod -Uri $longTokenUrl -Method Get

$tokenFile = "secrets/instagram.token"
@{
    access_token = $longToken.access_token
    token_type = $longToken.token_type
    expires_in = $longToken.expires_in
    created_at = (Get-Date).ToString("o")
} | ConvertTo-Json | Out-File -FilePath $tokenFile -Encoding UTF8

Write-Host ""
Write-Host "✅ Instagram tokens stored: $tokenFile" -ForegroundColor Green
Write-Host "Access Token (masked): ****$($longToken.access_token.Substring($longToken.access_token.Length - 8))" -ForegroundColor Green
