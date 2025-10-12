# 🜂 Google Photos Library API OAuth Flow

Param([string]$EnvFile = ".env.local")
$ErrorActionPreference = "Stop"

# Load environment
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
        }
    }
}

$clientId = $env:GPHOTOS_CLIENT_ID
$clientSecret = $env:GPHOTOS_CLIENT_SECRET
$redirectUri = $env:GPHOTOS_REDIRECT_URI

if (-not $clientId -or -not $clientSecret) {
    Write-Error "GPHOTOS_CLIENT_ID and GPHOTOS_CLIENT_SECRET must be set in .env.local"
    exit 1
}

Write-Host "🜂 Google Photos OAuth Flow" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prerequisites:" -ForegroundColor Yellow
Write-Host "1. Enable Photos Library API in Google Cloud Console"
Write-Host "2. Create OAuth 2.0 credentials"
Write-Host "3. Add redirect URI: $redirectUri"
Write-Host "4. Scopes: photoslibrary.readonly"
Write-Host ""

$scope = "https://www.googleapis.com/auth/photoslibrary.readonly"
$state = -join ((65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})
$authUrl = "https://accounts.google.com/o/oauth2/v2/auth?client_id=$clientId&redirect_uri=$redirectUri&scope=$scope&response_type=code&access_type=offline&state=$state"

Start-Process $authUrl
Write-Host "Paste redirect URL:" -ForegroundColor Green
$redirectedUrl = Read-Host

if ($redirectedUrl -match '[?&]code=([^&]+)') {
    $code = $matches[1]
} else {
    Write-Error "Could not extract code"
    exit 1
}

$tokenUrl = "https://oauth2.googleapis.com/token"
$body = @{
    code = $code
    client_id = $clientId
    client_secret = $clientSecret
    redirect_uri = $redirectUri
    grant_type = "authorization_code"
}

$response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"

$tokenFile = "secrets/gphotos.token"
@{
    access_token = $response.access_token
    refresh_token = $response.refresh_token
    token_type = $response.token_type
    expires_in = $response.expires_in
    scope = $response.scope
    created_at = (Get-Date).ToString("o")
    sync_token = ""
} | ConvertTo-Json | Out-File -FilePath $tokenFile -Encoding UTF8

Write-Host ""
Write-Host "✅ Google Photos tokens stored: $tokenFile" -ForegroundColor Green
Write-Host "Access Token (masked): ****$($response.access_token.Substring($response.access_token.Length - 8))" -ForegroundColor Green
