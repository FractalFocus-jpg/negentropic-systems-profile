#!/usr/bin/env python3
"""
Google Photos API - Continuous Ingest
Imports recent photos to Obsidian vault with EXIF data
"""

import os
import json
import requests
from datetime import datetime, timedelta
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

def load_creds():
    """Load Google Photos credentials"""
    env_path = r"C:\Users\alexl\Desktop\tapestry-codex-starter\.env.local"
    
    creds_dict = {}
    with open(env_path, 'r', encoding='utf-8') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                parts = line.strip().split('=', 1)
                if len(parts) == 2:
                    creds_dict[parts[0]] = parts[1]
    
    refresh_token = creds_dict.get('GPHOTOS_REFRESH_TOKEN', '')
    client_id = creds_dict.get('GPHOTOS_CLIENT_ID', '')
    client_secret = creds_dict.get('GPHOTOS_CLIENT_SECRET', '')
    
    creds = Credentials(
        token=None,
        refresh_token=refresh_token,
        client_id=client_id,
        client_secret=client_secret,
        token_uri='https://oauth2.googleapis.com/token',
        scopes=['https://www.googleapis.com/auth/photoslibrary.readonly']
    )
    
    return creds

def main():
    print("=" * 70)
    print("GOOGLE PHOTOS INGEST")
    print("=" * 70)
    print()
    
    # Load credentials and build service
    creds = load_creds()
    
    # Refresh the token
    from google.auth.transport.requests import Request
    creds.refresh(Request())
    
    # Use requests library for Photos API (no official Python client)
    headers = {
        'Authorization': f'Bearer {creds.token}',
        'Content-Type': 'application/json'
    }
    
    # Get recent media items (last 30 days)
    print("Fetching recent photos...")
    
    # Create date filter for last 30 days
    now = datetime.now()
    start_date = now - timedelta(days=30)
    
    filter_body = {
        "pageSize": 50,
        "filters": {
            "dateFilter": {
                "ranges": [{
                    "startDate": {
                        "year": start_date.year,
                        "month": start_date.month,
                        "day": start_date.day
                    },
                    "endDate": {
                        "year": now.year,
                        "month": now.month,
                        "day": now.day
                    }
                }]
            }
        }
    }
    
    response = requests.post(
        'https://photoslibrary.googleapis.com/v1/mediaItems:search',
        headers=headers,
        json=filter_body
    )
    
    if response.status_code != 200:
        print(f"ERROR: {response.status_code}")
        print(response.text)
        return
    
    data = response.json()
    media_items = data.get('mediaItems', [])
    
    print(f"Found {len(media_items)} recent photos")
    print()
    
    # Create vault directories
    vault_media = r"C:\Users\alexl\the living tapestry\media"
    os.makedirs(vault_media, exist_ok=True)
    
    # Process first 5 photos for this test
    imported = []
    
    for i, item in enumerate(media_items[:5]):
        media_id = item['id']
        filename = item['filename']
        mime_type = item['mimeType']
        creation_time = item.get('mediaMetadata', {}).get('creationTime', '')
        
        print(f"Processing: {filename}")
        
        # Create date-based directory structure
        if creation_time:
            dt = datetime.fromisoformat(creation_time.replace('Z', '+00:00'))
            year_month = dt.strftime('%Y/%m')
        else:
            year_month = datetime.now().strftime('%Y/%m')
        
        photo_dir = os.path.join(vault_media, year_month)
        os.makedirs(photo_dir, exist_ok=True)
        
        # Create markdown note for photo
        note_path = os.path.join(photo_dir, f"media-{media_id[:8]}.md")
        
        with open(note_path, 'w', encoding='utf-8') as f:
            f.write(f"# {filename}\n\n")
            f.write(f"**ID**: {media_id}\n")
            f.write(f"**Type**: {mime_type}\n")
            f.write(f"**Created**: {creation_time}\n")
            f.write(f"**Download**: {item.get('productUrl', 'N/A')}\n")
            f.write(f"\n")
            f.write(f"## Metadata\n\n")
            
            metadata = item.get('mediaMetadata', {})
            f.write(f"```json\n")
            f.write(json.dumps(metadata, indent=2))
            f.write(f"\n```\n")
        
        imported.append({
            "id": media_id,
            "filename": filename,
            "note": note_path,
            "created": creation_time
        })
    
    # Create import log
    log_path = r"C:\Users\alexl\the living tapestry\OS\reports\photos_ingest.md"
    
    with open(log_path, 'w') as f:
        f.write("# Google Photos Ingest Report\n\n")
        f.write(f"**Timestamp**: {datetime.now().isoformat()}\n")
        f.write(f"**Total Found**: {len(media_items)}\n")
        f.write(f"**Imported**: {len(imported)}\n\n")
        
        f.write("## Imported Photos\n\n")
        for photo in imported:
            f.write(f"- {photo['filename']}\n")
            f.write(f"  - Note: `{photo['note']}`\n")
            f.write(f"  - Created: {photo['created']}\n")
        
        f.write("\n## Status\n\n")
        f.write("✅ Photos Library API accessible\n")
        f.write("✅ Media items retrieved successfully\n")
        f.write("✅ Markdown notes created\n")
    
    print()
    print("=" * 70)
    print(f"Imported {len(imported)} photos")
    print(f"Report: {log_path}")
    print("=" * 70)

if __name__ == '__main__':
    main()
