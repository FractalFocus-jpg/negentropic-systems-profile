#!/usr/bin/env python3
"""Google Drive API Probe - Test connectivity and search"""

import os
import json
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

def main():
    # Read credentials from .env.local
    env_path = r"C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local"
    
    creds_dict = {}
    with open(env_path, 'r') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                creds_dict[key] = value
    
    # Build credentials object
    creds = Credentials(
        token=None,
        refresh_token=creds_dict.get('GDRIVE_REFRESH_TOKEN'),
        client_id=creds_dict.get('GDRIVE_CLIENT_ID'),
        client_secret=creds_dict.get('GDRIVE_CLIENT_SECRET'),
        token_uri='https://oauth2.googleapis.com/token',
        scopes=['https://www.googleapis.com/auth/drive.readonly']
    )
    
    print("="*60)
    print("GOOGLE DRIVE API PROBE")
    print("="*60)
    print()
    
    try:
        service = build('drive', 'v3', credentials=creds)
        
        # Test 1: List root files
        print("TEST 1: List 25 root files")
        print("-"*60)
        results = service.files().list(
            pageSize=25,
            fields="files(id, name, mimeType, modifiedTime)"
        ).execute()
        
        files = results.get('files', [])
        print(f"Found {len(files)} files:")
        for f in files[:10]:  # Show first 10
            print(f"  - {f['name']} ({f['mimeType']})")
        print()
        
        # Test 2: Search for "Living Tapestry"
        print("TEST 2: Search for 'Living Tapestry'")
        print("-"*60)
        results = service.files().list(
            q="name contains 'Living Tapestry'",
            pageSize=25,
            fields="files(id, name, mimeType, modifiedTime, webViewLink)"
        ).execute()
        
        files = results.get('files', [])
        print(f"Found {len(files)} matches:")
        for f in files:
            print(f"  - {f['name']}")
            print(f"    ID: {f['id']}")
            print(f"    Link: {f.get('webViewLink', 'N/A')}")
        print()
        
        # Test 3: Recent files (last 7 days)
        print("TEST 3: Files modified in last 7 days")
        print("-"*60)
        results = service.files().list(
            q="modifiedTime > '2025-10-07T00:00:00'",
            pageSize=25,
            orderBy="modifiedTime desc",
            fields="files(id, name, mimeType, modifiedTime)"
        ).execute()
        
        files = results.get('files', [])
        print(f"Found {len(files)} recent files:")
        for f in files[:10]:
            print(f"  - {f['name']} (modified: {f['modifiedTime']})")
        print()
        
        # Test 4: Shared drives
        print("TEST 4: List Shared Drives")
        print("-"*60)
        try:
            results = service.drives().list(pageSize=10).execute()
            drives = results.get('drives', [])
            print(f"Found {len(drives)} shared drives:")
            for d in drives:
                print(f"  - {d['name']} (ID: {d['id']})")
        except Exception as e:
            print(f"  Shared drives not accessible: {e}")
        print()
        
        print("="*60)
        print("✅ DRIVE API FUNCTIONAL")
        print("="*60)
        
        # Write results
        output = {
            "status": "success",
            "root_files_count": len(results.get('files', [])),
            "living_tapestry_matches": len(files),
            "test_timestamp": "2025-10-14T21:30:00Z"
        }
        
        output_path = r"C:\Users\alexl\the living tapestry\research\drive_probe.md"
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, 'w') as f:
            f.write("# Google Drive API Probe Results\n\n")
            f.write(f"**Timestamp**: 2025-10-14\n\n")
            f.write(f"## Summary\n\n")
            f.write(f"- ✅ Drive API accessible\n")
            f.write(f"- Root files found: {output['root_files_count']}\n")
            f.write(f"- 'Living Tapestry' matches: {output['living_tapestry_matches']}\n")
        
        print(f"\nResults saved to: {output_path}")
        
    except Exception as e:
        print(f"❌ ERROR: {e}")
        print(f"\nError type: {type(e).__name__}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()
