#!/usr/bin/env python3
"""
Google Drive Comprehensive Probe
Tests: My Drive + Shared Drives with includeItemsFromAllDrives
"""

import os
import json
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from datetime import datetime

def load_creds():
    """Load credentials from .env.local"""
    env_path = r"C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local"
    
    creds_dict = {}
    with open(env_path, 'r', encoding='utf-8') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                parts = line.strip().split('=', 1)
                if len(parts) == 2:
                    creds_dict[parts[0]] = parts[1]
    
    # Use the latest refresh token (last one in file)
    refresh_token = creds_dict.get('GDRIVE_REFRESH_TOKEN', '')
    client_id = creds_dict.get('GDRIVE_CLIENT_ID', '')
    client_secret = creds_dict.get('GDRIVE_CLIENT_SECRET', '')
    
    creds = Credentials(
        token=None,
        refresh_token=refresh_token,
        client_id=client_id,
        client_secret=client_secret,
        token_uri='https://oauth2.googleapis.com/token',
        scopes=['https://www.googleapis.com/auth/drive.readonly']
    )
    
    return creds

def main():
    print("=" * 70)
    print("GOOGLE DRIVE COMPREHENSIVE PROBE")
    print("=" * 70)
    print()
    
    creds = load_creds()
    service = build('drive', 'v3', credentials=creds)
    
    results = {
        "timestamp": datetime.now().isoformat(),
        "tests": []
    }
    
    # TEST 1: List 25 most recent files (all drives)
    print("TEST 1: Most Recent Files (All Drives)")
    print("-" * 70)
    try:
        response = service.files().list(
            pageSize=25,
            orderBy='modifiedTime desc',
            fields='files(id, name, mimeType, modifiedTime, driveId, owners)',
            includeItemsFromAllDrives=True,
            supportsAllDrives=True,
            corpora='allDrives'
        ).execute()
        
        files = response.get('files', [])
        print(f"Found: {len(files)} files")
        
        for f in files[:10]:
            drive_type = "Shared Drive" if f.get('driveId') else "My Drive"
            print(f"  - {f['name']} [{drive_type}]")
        
        results['tests'].append({
            "name": "Recent Files (All Drives)",
            "status": "SUCCESS",
            "count": len(files)
        })
        print()
        
    except Exception as e:
        print(f"ERROR: {e}")
        results['tests'].append({
            "name": "Recent Files (All Drives)",
            "status": "FAILED",
            "error": str(e)
        })
        print()
    
    # TEST 2: List Shared Drives
    print("TEST 2: Shared Drives")
    print("-" * 70)
    try:
        response = service.drives().list(
            pageSize=10,
            fields='drives(id, name)'
        ).execute()
        
        drives = response.get('drives', [])
        print(f"Found: {len(drives)} shared drives")
        
        for d in drives:
            print(f"  - {d['name']} (ID: {d['id']})")
        
        results['tests'].append({
            "name": "Shared Drives",
            "status": "SUCCESS",
            "count": len(drives),
            "drives": [{"name": d['name'], "id": d['id']} for d in drives]
        })
        print()
        
    except Exception as e:
        print(f"ERROR: {e}")
        results['tests'].append({
            "name": "Shared Drives",
            "status": "FAILED",
            "error": str(e)
        })
        print()
    
    # TEST 3: Search for "Living" OR "Tapestry"
    print("TEST 3: Search 'Living' OR 'Tapestry'")
    print("-" * 70)
    try:
        query = "name contains 'Living' or name contains 'Tapestry'"
        response = service.files().list(
            q=query,
            pageSize=25,
            fields='files(id, name, mimeType, webViewLink, driveId)',
            includeItemsFromAllDrives=True,
            supportsAllDrives=True,
            corpora='allDrives'
        ).execute()
        
        files = response.get('files', [])
        print(f"Found: {len(files)} matches")
        
        for f in files:
            drive_type = "Shared Drive" if f.get('driveId') else "My Drive"
            print(f"  - {f['name']} [{drive_type}]")
            if 'webViewLink' in f:
                print(f"    Link: {f['webViewLink']}")
        
        results['tests'].append({
            "name": "Search Living/Tapestry",
            "status": "SUCCESS",
            "count": len(files),
            "files": [{"name": f['name'], "id": f['id']} for f in files]
        })
        print()
        
    except Exception as e:
        print(f"ERROR: {e}")
        results['tests'].append({
            "name": "Search Living/Tapestry",
            "status": "FAILED",
            "error": str(e)
        })
        print()
    
    # Save results
    output_path = r"C:\Users\alexl\the living tapestry\OS\reports\drive_probe.json"
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, 'w') as f:
        json.dump(results, f, indent=2)
    
    # Create markdown report
    md_path = r"C:\Users\alexl\the living tapestry\OS\reports\drive_probe.md"
    with open(md_path, 'w') as f:
        f.write("# Google Drive Probe Results\n\n")
        f.write(f"**Timestamp**: {results['timestamp']}\n\n")
        
        for test in results['tests']:
            f.write(f"## {test['name']}\n")
            f.write(f"**Status**: {test['status']}\n")
            if 'count' in test:
                f.write(f"**Count**: {test['count']}\n")
            if 'error' in test:
                f.write(f"**Error**: {test['error']}\n")
            f.write("\n")
    
    print("=" * 70)
    print("Results saved to:")
    print(f"  JSON: {output_path}")
    print(f"  MD: {md_path}")
    print("=" * 70)

if __name__ == '__main__':
    main()
