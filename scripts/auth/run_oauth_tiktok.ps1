# 🜂 TikTok OAuth Flow
# Securely authenticate with TikTok API and store tokens

Param(
    [string]$EnvFile = ".env.local"
)

$ErrorActionPreference = "Stop"

# Load environment
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
        }
    }
} else {
    Write-Error ".env.local not found! Copy .env.local.template and fill in TIKTOK_CLIENT_ID and TIKTOK_CLIENT_SECRET"
    exit 1
}

$clientId = $env:TIKTOK_CLIENT_ID
$clientSecret = $env:TIKTOK_CLIENT_SECRET
$redirectUri = $env:TIKTOK_REDIRECT_URI

if (-not $clientId -or -not $clientSecret) {
    Write-Error "TIKTOK_CLIENT_ID and TIKTOK_CLIENT_SECRET must be set in .env.local"
    exit 1
}

Write-Host "🜂 TikTok OAuth Flow" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prerequisites:" -ForegroundColor Yellow
Write-Host "1. Create a TikTok Developer account at https://developers.tiktok.com/"
Write-Host "2. Create an app and add these scopes: user.info.basic, video.upload, video.list"
Write-Host "3. Add redirect URI: $redirectUri"
Write-Host "4. Copy Client Key (ID) and Client Secret to .env.local"
Write-Host ""
Write-Host "Press any key to open TikTok authorization page..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Build authorization URL
$scope = "user.info.basic,video.upload,video.list"
$state = -join ((65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})
$authUrl = "https://www.tiktok.com/v2/auth/authorize/?client_key=$clientId&scope=$scope&response_type=code&redirect_uri=$redirectUri&state=$state"

# Open browser
Start-Process $authUrl

Write-Host ""
Write-Host "Authorization page opened in browser." -ForegroundColor Green
Write-Host "After authorizing, you'll be redirected to: $redirectUri"
Write-Host ""
Write-Host "Paste the full redirect URL here (including the code parameter):"
$redirectedUrl = Read-Host

# Extract code
if ($redirectedUrl -match '[?&]code=([^&]+)') {
    $code = $matches[1]
} else {
    Write-Error "Could not extract code from URL. Make sure you pasted the full redirect URL."
    exit 1
}

Write-Host ""
Write-Host "Exchanging code for access token..." -ForegroundColor Yellow

# Exchange code for token
$tokenUrl = "https://open.tiktokapis.com/v2/oauth/token/"
$body = @{
    client_key = $clientId
    client_secret = $clientSecret
    code = $code
    grant_type = "authorization_code"
    redirect_uri = $redirectUri
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/json"
    
    # Store tokens securely
    $tokenFile = "secrets/tiktok.token"
    $tokenData = @{
        access_token = $response.access_token
        refresh_token = $response.refresh_token
        expires_in = $response.expires_in
        token_type = $response.token_type
        scope = $response.scope
        created_at = (Get-Date).ToString("o")
    } | ConvertTo-Json -Depth 10
    
    $tokenData | Out-File -FilePath $tokenFile -Encoding UTF8
    
    Write-Host ""
    Write-Host "✅ Success! TikTok tokens stored in: $tokenFile" -ForegroundColor Green
    Write-Host "Access Token (masked): ****$($response.access_token.Substring($response.access_token.Length - 8))" -ForegroundColor Green
    Write-Host "Expires in: $($response.expires_in) seconds (~$([math]::Round($response.expires_in / 3600, 1)) hours)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Token will auto-refresh when needed." -ForegroundColor Cyan
    
} catch {
    Write-Error "Failed to exchange code for token: $_"
    exit 1
}
