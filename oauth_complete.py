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
