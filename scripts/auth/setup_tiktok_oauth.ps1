# ⬢ OAuth Setup — TikTok (@fractalfocus)
# TikTok for Developers API

param(
    [switch]$ShowInstructions = $false
)

$ErrorActionPreference = "Stop"

Write-Host "`n⬢ TikTok OAuth Setup (@fractalfocus)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

if ($ShowInstructions) {
    Write-Host "`n📖 INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://developers.tiktok.com/"
    Write-Host "2. Create app: 'Living Tapestry OS'"
    Write-Host "3. Add redirect URI: http://localhost:8080/tiktok/callback"
    Write-Host "4. Request these scopes:"
    Write-Host "   - user.info.basic"
    Write-Host "   - video.upload"
    Write-Host "   - video.publish"
    Write-Host "5. Get Client Key and Client Secret"
    Write-Host ""
    Write-Host "⚠️  NOTE: TikTok may require app review before posting"
    Write-Host "   Start in sandbox/test mode"
    Write-Host ""
    Write-Host "Press any key when ready..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Write-Host "`n🔐 Enter TikTok OAuth Credentials:" -ForegroundColor Green

$clientKey = Read-Host "Client Key"
$clientSecret = Read-Host "Client Secret" -AsSecureString
$clientSecretPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret)
)

$redirectUri = "http://localhost:8080/tiktok/callback"
$state = [System.Guid]::NewGuid().ToString()
$scope = "user.info.basic,video.upload"

# Build authorization URL
$authUrl = "https://www.tiktok.com/v2/auth/authorize/?" +
    "client_key=$clientKey&" +
    "scope=$scope&" +
    "response_type=code&" +
    "redirect_uri=$([uri]::EscapeDataString($redirectUri))&" +
    "state=$state"

Write-Host "`n🌐 Opening browser..." -ForegroundColor Cyan
Start-Process $authUrl

Write-Host "⏳ Waiting for callback..." -ForegroundColor Yellow

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()

$context = $listener.GetContext()
$request = $context.Request
$response = $context.Response

$code = $request.QueryString["code"]
$returnedState = $request.QueryString["state"]

if ($returnedState -ne $state) {
    Write-Host "❌ State mismatch!" -ForegroundColor Red
    $listener.Stop()
    exit 1
}

$html = "<html><body><h1>✅ TikTok OAuth Complete!</h1><p>Close this window.</p></body></html>"
$buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
$response.ContentLength64 = $buffer.Length
$response.OutputStream.Write($buffer, 0, $buffer.Length)
$response.Close()
$listener.Stop()

Write-Host "✅ Authorization code received!" -ForegroundColor Green

# Exchange for token
$tokenUrl = "https://open.tiktokapis.com/v2/oauth/token/"
$body = @{
    client_key = $clientKey
    client_secret = $clientSecretPlain
    code = $code
    grant_type = "authorization_code"
    redirect_uri = $redirectUri
} | ConvertTo-Json

$headers = @{
    "Content-Type" = "application/json"
}

try {
    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -Headers $headers
    
    $envFile = "C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local"
    $envContent = @"

# TikTok OAuth (@fractalfocus) - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
TIKTOK_CLIENT_KEY=$clientKey
TIKTOK_CLIENT_SECRET=$clientSecretPlain
TIKTOK_ACCESS_TOKEN=$($tokenResponse.access_token)
TIKTOK_REFRESH_TOKEN=$($tokenResponse.refresh_token)
TIKTOK_EXPIRES_IN=$($tokenResponse.expires_in)
"@

    Add-Content -Path $envFile -Value $envContent
    
    Write-Host "`n✅ TikTok OAuth Complete!" -ForegroundColor Green
    Write-Host "📄 Credentials saved to .env.local" -ForegroundColor Gray
    Write-Host "🎯 Account: @fractalfocus" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Token exchange failed: $_" -ForegroundColor Red
    exit 1
}
