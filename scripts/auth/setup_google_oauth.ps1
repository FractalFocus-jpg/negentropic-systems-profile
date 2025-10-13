# ⬢ OAuth Setup — Google Services (All-in-One)
# Handles: Gmail, Calendar, Drive, Photos, YouTube

param(
    [switch]$ShowInstructions = $false
)

$ErrorActionPreference = "Stop"

Write-Host "`n⬢ Google OAuth Setup — All Services" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

if ($ShowInstructions) {
    Write-Host "`n📖 INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://console.cloud.google.com/"
    Write-Host "2. Create project: 'Living-Tapestry-OS'"
    Write-Host "3. Enable APIs:"
    Write-Host "   - Gmail API"
    Write-Host "   - Google Calendar API"
    Write-Host "   - Google Drive API"
    Write-Host "   - Google Photos Library API"
    Write-Host "   - YouTube Data API v3"
    Write-Host "4. Create OAuth 2.0 Client ID (Desktop app)"
    Write-Host "5. Download credentials JSON"
    Write-Host "6. Copy Client ID and Client Secret"
    Write-Host ""
    Write-Host "Press any key when ready..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Write-Host "`n🔐 Enter Google OAuth Credentials:" -ForegroundColor Green

$clientId = Read-Host "Client ID"
$clientSecret = Read-Host "Client Secret" -AsSecureString
$clientSecretPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret)
)

# OAuth 2.0 scopes needed
$scopes = @(
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/gmail.modify",
    "https://www.googleapis.com/auth/calendar.readonly",
    "https://www.googleapis.com/auth/calendar.events",
    "https://www.googleapis.com/auth/drive.readonly",
    "https://www.googleapis.com/auth/drive.file",
    "https://www.googleapis.com/auth/photoslibrary.readonly",
    "https://www.googleapis.com/auth/youtube.readonly",
    "https://www.googleapis.com/auth/youtube.upload"
) -join " "

$redirectUri = "http://localhost:8080"
$state = [System.Guid]::NewGuid().ToString()

# Build authorization URL
$authUrl = "https://accounts.google.com/o/oauth2/v2/auth?" + 
    "client_id=$clientId&" +
    "redirect_uri=$([uri]::EscapeDataString($redirectUri))&" +
    "response_type=code&" +
    "scope=$([uri]::EscapeDataString($scopes))&" +
    "access_type=offline&" +
    "state=$state&" +
    "prompt=consent"

Write-Host "`n🌐 Opening browser for authorization..." -ForegroundColor Cyan
Start-Process $authUrl

Write-Host "`n⏳ Starting local server on port 8080..." -ForegroundColor Yellow
Write-Host "   Waiting for OAuth callback..." -ForegroundColor Gray

# Simple HTTP listener for OAuth callback
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()

Write-Host "✅ Server listening. Authorize in browser..." -ForegroundColor Green

$context = $listener.GetContext()
$request = $context.Request
$response = $context.Response

# Extract authorization code
$code = $request.QueryString["code"]
$returnedState = $request.QueryString["state"]

if ($returnedState -ne $state) {
    Write-Host "❌ State mismatch! Possible CSRF attack." -ForegroundColor Red
    $listener.Stop()
    exit 1
}

# Send success page
$html = @"
<html>
<head><title>OAuth Success</title></head>
<body style='font-family:system-ui;text-align:center;padding:50px;'>
<h1 style='color:#00b894;'>✅ Authorization Complete!</h1>
<p>You can close this window and return to PowerShell.</p>
<p style='color:#636e72;'>Living Tapestry OS vΩ</p>
</body>
</html>
"@

$buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
$response.ContentLength64 = $buffer.Length
$response.OutputStream.Write($buffer, 0, $buffer.Length)
$response.Close()
$listener.Stop()

Write-Host "`n✅ Authorization code received!" -ForegroundColor Green

# Exchange code for tokens
Write-Host "🔄 Exchanging code for access token..." -ForegroundColor Cyan

$tokenUrl = "https://oauth2.googleapis.com/token"
$body = @{
    code = $code
    client_id = $clientId
    client_secret = $clientSecretPlain
    redirect_uri = $redirectUri
    grant_type = "authorization_code"
}

try {
    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body
    
    Write-Host "✅ Tokens received!" -ForegroundColor Green
    
    # Store in .env.local
    $envFile = "C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local"
    $envContent = @"

# Google OAuth (Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
GMAIL_CLIENT_ID=$clientId
GMAIL_CLIENT_SECRET=$clientSecretPlain
GMAIL_REFRESH_TOKEN=$($tokenResponse.refresh_token)

GCAL_CLIENT_ID=$clientId
GCAL_CLIENT_SECRET=$clientSecretPlain
GCAL_REFRESH_TOKEN=$($tokenResponse.refresh_token)

GDRIVE_CLIENT_ID=$clientId
GDRIVE_CLIENT_SECRET=$clientSecretPlain
GDRIVE_REFRESH_TOKEN=$($tokenResponse.refresh_token)

GPHOTOS_CLIENT_ID=$clientId
GPHOTOS_CLIENT_SECRET=$clientSecretPlain
GPHOTOS_REFRESH_TOKEN=$($tokenResponse.refresh_token)

YOUTUBE_CLIENT_ID=$clientId
YOUTUBE_CLIENT_SECRET=$clientSecretPlain
YOUTUBE_REFRESH_TOKEN=$($tokenResponse.refresh_token)
"@

    if (Test-Path $envFile) {
        Add-Content -Path $envFile -Value $envContent
    } else {
        $envContent | Out-File -FilePath $envFile -Encoding UTF8
    }
    
    Write-Host "`n✅ Credentials saved to .env.local" -ForegroundColor Green
    Write-Host "📄 Location: $envFile" -ForegroundColor Gray
    Write-Host "`n🔒 Security Note:" -ForegroundColor Yellow
    Write-Host "   - Refresh token stored (never expires unless revoked)"
    Write-Host "   - Access token expires in $($tokenResponse.expires_in) seconds"
    Write-Host "   - .env.local is git-ignored"
    
    Write-Host "`n✅ Google OAuth Complete!" -ForegroundColor Green
    Write-Host "   All services ready: Gmail, Calendar, Drive, Photos, YouTube" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Token exchange failed: $_" -ForegroundColor Red
    exit 1
}
