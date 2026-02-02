# OAuth Token Generator for Google Services
# Generates refresh tokens and saves to .env.local

param(
    [string]$CredentialsPath = ".\google_credentials.json"
)

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  GOOGLE OAUTH TOKEN GENERATOR" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if credentials exist
if (!(Test-Path $CredentialsPath)) {
    Write-Host "ERROR: google_credentials.json not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "INSTRUCTIONS:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://console.cloud.google.com/apis/credentials" -ForegroundColor Gray
    Write-Host "2. Click on your OAuth 2.0 Client ID" -ForegroundColor Gray
    Write-Host "3. Click 'DOWNLOAD JSON'" -ForegroundColor Gray
    Write-Host "4. Save as: google_credentials.json" -ForegroundColor Gray
    Write-Host "5. Run this script again" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Install required Python packages
Write-Host "Checking Python packages..." -ForegroundColor Yellow
pip install --quiet google-auth-oauthlib google-auth-httplib2 2>$null

Write-Host ""
Write-Host "Starting OAuth flow..." -ForegroundColor Yellow
Write-Host "Your browser will open shortly" -ForegroundColor Gray
Write-Host ""

# Python OAuth script
$pythonScript = @'
import json
from google_auth_oauthlib.flow import InstalledAppFlow
from pathlib import Path

SCOPES = [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/photoslibrary.readonly',
    'https://www.googleapis.com/auth/youtube.upload'
]

def main():
    print("Opening browser for authorization...")
    print("Please sign in with: alexliantonio43@gmail.com\n")
    
    flow = InstalledAppFlow.from_client_secrets_file(
        'google_credentials.json',
        SCOPES
    )
    
    creds = flow.run_local_server(port=8080)
    
    print("\n" + "="*60)
    print("SUCCESS! OAuth tokens generated")
    print("="*60 + "\n")
    
    # Read credentials for client ID/secret
    with open('google_credentials.json', 'r') as f:
        creds_data = json.load(f)
        client_id = creds_data['installed']['client_id']
        client_secret = creds_data['installed']['client_secret']
    
    # Save tokens
    with open('.env_tokens.txt', 'w') as f:
        f.write(f"GMAIL_REFRESH_TOKEN={creds.refresh_token}\n")
        f.write(f"GCAL_REFRESH_TOKEN={creds.refresh_token}\n")
        f.write(f"GDRIVE_REFRESH_TOKEN={creds.refresh_token}\n")
        f.write(f"GPHOTOS_REFRESH_TOKEN={creds.refresh_token}\n")
        f.write(f"YOUTUBE_REFRESH_TOKEN={creds.refresh_token}\n")
    
    print("Tokens saved to: .env_tokens.txt")
    print("Copy these lines to your .env.local file\n")
    
    with open('.env_tokens.txt', 'r') as f:
        print(f.read())

if __name__ == '__main__':
    main()
'@

$pythonScript | Out-File -FilePath "oauth_flow.py" -Encoding UTF8

# Run Python script
python oauth_flow.py

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "NEXT STEP: Update .env.local" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Tokens are in: .env_tokens.txt" -ForegroundColor Yellow
    Write-Host "Copy them to your .env.local file" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "ERROR: OAuth flow failed" -ForegroundColor Red
    Write-Host "Check that you:" -ForegroundColor Yellow
    Write-Host "  1. Signed in with alexliantonio43@gmail.com" -ForegroundColor Gray
    Write-Host "  2. Approved all permissions" -ForegroundColor Gray
    Write-Host "  3. Have test user added to consent screen" -ForegroundColor Gray
    Write-Host ""
}

# Cleanup
Remove-Item "oauth_flow.py" -ErrorAction SilentlyContinue
