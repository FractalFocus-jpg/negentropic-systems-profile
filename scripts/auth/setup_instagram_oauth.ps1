# ⬢ OAuth Setup — Instagram (@realeyesrealizinglies)
# Via Facebook Graph API

param(
    [switch]$ShowInstructions = $false
)

$ErrorActionPreference = "Stop"

Write-Host "`n⬢ Instagram OAuth Setup (@realeyesrealizinglies)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

if ($ShowInstructions) {
    Write-Host "`n📖 INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://developers.facebook.com/"
    Write-Host "2. Create app → Type: Business"
    Write-Host "3. Add Instagram Graph API product"
    Write-Host "4. Link Instagram Business Account"
    Write-Host "5. Add redirect: http://localhost:8080/instagram/callback"
    Write-Host "6. Request permissions:"
    Write-Host "   - instagram_basic"
    Write-Host "   - instagram_content_publish"
    Write-Host "   - pages_read_engagement"
    Write-Host "7. Get App ID and App Secret"
    Write-Host ""
    Write-Host "⚠️  Requirements:"
    Write-Host "   - Instagram must be Business/Creator account"
    Write-Host "   - Linked to Facebook Page"
    Write-Host "   - App may need Meta review for publishing"
    Write-Host ""
    Write-Host "Press any key when ready..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Write-Host "`n🔐 Enter Instagram/Facebook OAuth Credentials:" -ForegroundColor Green

$appId = Read-Host "App ID"
$appSecret = Read-Host "App Secret" -AsSecureString
$appSecretPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($appSecret)
)

Write-Host "`n📄 Additional Info Needed:" -ForegroundColor Yellow
$fbPageId = Read-Host "Facebook Page ID (linked to Instagram)"

$redirectUri = "http://localhost:8080/instagram/callback"
$state = [System.Guid]::NewGuid().ToString()
$scope = "instagram_basic,instagram_content_publish,pages_read_engagement,pages_show_list"

# Build authorization URL
$authUrl = "https://www.facebook.com/v18.0/dialog/oauth?" +
    "client_id=$appId&" +
    "redirect_uri=$([uri]::EscapeDataString($redirectUri))&" +
    "scope=$([uri]::EscapeDataString($scope))&" +
    "response_type=code&" +
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

$html = "<html><body><h1>✅ Instagram OAuth Complete!</h1><p>Close this window.</p></body></html>"
$buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
$response.ContentLength64 = $buffer.Length
$response.OutputStream.Write($buffer, 0, $buffer.Length)
$response.Close()
$listener.Stop()

Write-Host "✅ Authorization code received!" -ForegroundColor Green

# Exchange for token
$tokenUrl = "https://graph.facebook.com/v18.0/oauth/access_token?" +
    "client_id=$appId&" +
    "client_secret=$appSecretPlain&" +
    "redirect_uri=$([uri]::EscapeDataString($redirectUri))&" +
    "code=$code"

try {
    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Get
    
    # Get long-lived token
    $longLivedUrl = "https://graph.facebook.com/v18.0/oauth/access_token?" +
        "grant_type=fb_exchange_token&" +
        "client_id=$appId&" +
        "client_secret=$appSecretPlain&" +
        "fb_exchange_token=$($tokenResponse.access_token)"
    
    $longLivedToken = Invoke-RestMethod -Uri $longLivedUrl -Method Get
    
    $envFile = "C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local"
    $envContent = @"

# Instagram OAuth (@realeyesrealizinglies) - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
IG_APP_ID=$appId
IG_APP_SECRET=$appSecretPlain
IG_ACCESS_TOKEN=$($longLivedToken.access_token)
FB_PAGE_ID=$fbPageId
# Note: Long-lived token expires in ~60 days, requires manual refresh
"@

    Add-Content -Path $envFile -Value $envContent
    
    Write-Host "`n✅ Instagram OAuth Complete!" -ForegroundColor Green
    Write-Host "📄 Credentials saved to .env.local" -ForegroundColor Gray
    Write-Host "🎯 Account: @realeyesrealizinglies" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "⚠️  Important:" -ForegroundColor Yellow
    Write-Host "   - Token expires in ~60 days"
    Write-Host "   - Publishing may require app review"
    Write-Host "   - Test in sandbox first"
    
} catch {
    Write-Host "❌ Token exchange failed: $_" -ForegroundColor Red
    Write-Host "   Check that Instagram is linked to Facebook Page" -ForegroundColor Yellow
    exit 1
}
