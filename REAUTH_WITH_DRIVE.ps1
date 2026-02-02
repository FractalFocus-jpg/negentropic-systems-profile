# Complete OAuth Re-Auth with ALL Scopes
# Generates tokens for Gmail, Calendar, Drive, Photos, YouTube

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  COMPLETE GOOGLE OAUTH - ALL SERVICES" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$credPath = "C:\Users\alexl\Desktop\tapestry-codex-starter\google_credentials.json"

if (!(Test-Path $credPath)) {
    Write-Host "ERROR: google_credentials.json not found" -ForegroundColor Red
    exit 1
}

Write-Host "Creating OAuth flow with ALL scopes..." -ForegroundColor Yellow
Write-Host "Scopes:" -ForegroundColor Gray
Write-Host "  - Gmail (read)" -ForegroundColor Gray
Write-Host "  - Calendar (full)" -ForegroundColor Gray
Write-Host "  - Drive (read)" -ForegroundColor Gray  
Write-Host "  - Photos (read)" -ForegroundColor Gray
Write-Host "  - YouTube (upload)" -ForegroundColor Gray
Write-Host ""

# Create Python script for OAuth with all scopes
$pythonScript = @'
import json
import os
from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/drive.readonly',
    'https://www.googleapis.com/auth/photoslibrary.readonly',
    'https://www.googleapis.com/auth/youtube.upload'
]

def main():
    creds_file = 'google_credentials.json'
    
    flow = InstalledAppFlow.from_client_secrets_file(
        creds_file, SCOPES)
    
    creds = flow.run_local_server(port=8080)
    
    # Save refresh token
    refresh_token = creds.refresh_token
    
    print("\n" + "="*60)
    print("SUCCESS! OAuth tokens generated")
    print("="*60)
    print(f"\nRefresh Token: {refresh_token[:50]}...")
    
    # Save to file
    with open('.env_tokens_complete.txt', 'w') as f:
        f.write("# OAuth Refresh Tokens - ALL SCOPES\n")
        f.write(f"# Generated: 2025-10-14\n")
        f.write(f"# Scopes: Gmail, Calendar, Drive, Photos, YouTube\n\n")
        f.write(f"GMAIL_REFRESH_TOKEN={refresh_token}\n")
        f.write(f"GCAL_REFRESH_TOKEN={refresh_token}\n")
        f.write(f"GDRIVE_REFRESH_TOKEN={refresh_token}\n")
        f.write(f"GPHOTOS_REFRESH_TOKEN={refresh_token}\n")
        f.write(f"YOUTUBE_REFRESH_TOKEN={refresh_token}\n")
    
    print("\nTokens saved to: .env_tokens_complete.txt")
    print("="*60)

if __name__ == '__main__':
    main()
'@

$pythonScript | Out-File -FilePath "oauth_complete.py" -Encoding UTF8

Write-Host "Running OAuth flow..." -ForegroundColor Yellow
Write-Host "Your browser will open - sign in and approve ALL permissions" -ForegroundColor Cyan
Write-Host ""

python oauth_complete.py

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "  SUCCESS!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    
    # Read the tokens
    $tokens = Get-Content ".env_tokens_complete.txt"
    
    # Append to .env.local
    $envPath = "C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local"
    "" | Add-Content $envPath
    "# OAuth Tokens - Complete Re-Auth ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))" | Add-Content $envPath
    $tokens | Add-Content $envPath
    
    Write-Host "Tokens added to .env.local" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next: Test Drive API again" -ForegroundColor Yellow
    Write-Host "  python test_drive_api.py" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Red
    Write-Host "  ERROR" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "OAuth flow failed. Check:" -ForegroundColor Yellow
    Write-Host "  1. Test user added: alexliantonio43@gmail.com" -ForegroundColor Gray
    Write-Host "  2. All APIs enabled in Google Cloud Console" -ForegroundColor Gray
    Write-Host "  3. Port 8080 not in use" -ForegroundColor Gray
}
