#!/usr/bin/env python3
"""
Confluence Integration for Living Tapestry OS
Syncs Confluence pages with Obsidian vault
"""

import os
import sys
import json
import requests
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional
import base64

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

class ConfluenceIntegration:
    def __init__(self, base_url: str, email: str, api_token: str, vault_path: str):
        self.base_url = base_url.rstrip('/')
        self.email = email
        self.api_token = api_token
        self.vault_path = Path(vault_path)
        
        # Create auth header
        auth_string = f"{email}:{api_token}"
        auth_bytes = auth_string.encode('ascii')
        auth_b64 = base64.b64encode(auth_bytes).decode('ascii')
        
        self.headers = {
            "Authorization": f"Basic {auth_b64}",
            "Content-Type": "application/json",
            "Accept": "application/json"
        }
        
        # Create reports directory
        self.reports_dir = self.vault_path / "OS" / "reports"
        self.reports_dir.mkdir(parents=True, exist_ok=True)
        
    def test_connection(self) -> bool:
        """Test Confluence API connection"""
        try:
            # Try to get spaces to verify connection
            url = f"{self.base_url}/wiki/rest/api/space"
            response = requests.get(url, headers=self.headers, timeout=10)
            
            if response.status_code == 200:
                spaces = response.json()
                space_count = len(spaces.get('results', []))
                print(f"✅ Connected to Confluence ({self.base_url})")
                print(f"   Accessible spaces: {space_count}")
                return True
            else:
                print(f"❌ Connection failed: HTTP {response.status_code}")
                print(f"Response: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Connection error: {e}")
            return False
    
    def get_spaces(self, limit: int = 25) -> List[Dict]:
        """Get list of spaces user has access to"""
        try:
            url = f"{self.base_url}/rest/api/space"
            params = {"limit": limit}
            response = requests.get(url, headers=self.headers, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            return data.get('results', [])
            
        except Exception as e:
            print(f"❌ Failed to get spaces: {e}")
            return []
    
    def get_recent_pages(self, limit: int = 50) -> List[Dict]:
        """Get recently updated pages"""
        try:
            url = f"{self.base_url}/rest/api/content"
            params = {
                "type": "page",
                "status": "current",
                "limit": limit,
                "expand": "space,version,body.storage"
            }
            response = requests.get(url, headers=self.headers, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            return data.get('results', [])
            
        except Exception as e:
            print(f"❌ Failed to get pages: {e}")
            return []
    
    def sync_to_obsidian(self) -> bool:
        """Sync Confluence pages to Obsidian vault"""
        try:
            print("🔄 Syncing Confluence pages to Obsidian...")
            
            pages = self.get_recent_pages()
            
            if not pages:
                print("⚠️  No pages found")
                return True
            
            # Create Confluence directory in vault
            confluence_dir = self.vault_path / "confluence"
            confluence_dir.mkdir(exist_ok=True)
            
            synced_count = 0
            
            for page in pages:
                # Create space subdirectory
                space_key = page['space']['key']
                space_dir = confluence_dir / space_key
                space_dir.mkdir(exist_ok=True)
                
                # Create markdown file for each page
                filename = f"{self._sanitize_filename(page['title'])}.md"
                filepath = space_dir / filename
                
                # Generate markdown content
                content = self._generate_page_markdown(page)
                
                # Write to file
                filepath.write_text(content, encoding='utf-8')
                synced_count += 1
            
            print(f"✅ Synced {synced_count} pages to {confluence_dir}")
            
            # Generate status report
            self._generate_report(pages)
            
            return True
            
        except Exception as e:
            print(f"❌ Sync failed: {e}")
            return False
    
    def _sanitize_filename(self, name: str) -> str:
        """Sanitize filename for cross-platform compatibility"""
        invalid_chars = '<>:"/\\|?*'
        for char in invalid_chars:
            name = name.replace(char, '-')
        return name[:100]  # Limit length
    
    def _generate_page_markdown(self, page: Dict) -> str:
        """Generate markdown content for a page"""
        space = page['space']
        version = page['version']
        
        # Get page URL
        page_id = page['id']
        page_url = f"{self.base_url}/pages/viewpage.action?pageId={page_id}"
        
        # Extract body content (simplified HTML to markdown)
        body_html = page.get('body', {}).get('storage', {}).get('value', 'No content')
        body_text = self._html_to_markdown(body_html)
        
        content = f"""---
type: confluence_page
id: {page['id']}
title: "{page['title']}"
space: {space['name']} ({space['key']})
version: {version['number']}
created: {version.get('when', 'Unknown')}
author: {version.get('by', {}).get('displayName', 'Unknown')}
url: {page_url}
---

# {page['title']}

**Space**: {space['name']}  
**Last Updated**: {version.get('when', 'Unknown')}  
**Version**: {version['number']}  
**URL**: [View in Confluence]({page_url})

---

{body_text}

---

**Synced**: {datetime.now().isoformat()}  
**Source**: Confluence API  
**Agent**: Scribe (Living Tapestry OS)
"""
        return content
    
    def _html_to_markdown(self, html: str) -> str:
        """Simple HTML to Markdown conversion"""
        # This is a simplified converter - for production, use html2text library
        text = html
        
        # Remove common HTML tags (basic cleaning)
        replacements = [
            ('<p>', '\n\n'),
            ('</p>', ''),
            ('<br>', '\n'),
            ('<br/>', '\n'),
            ('<br />', '\n'),
            ('<strong>', '**'),
            ('</strong>', '**'),
            ('<b>', '**'),
            ('</b>', '**'),
            ('<em>', '*'),
            ('</em>', '*'),
            ('<i>', '*'),
            ('</i>', '*'),
            ('<h1>', '\n# '),
            ('</h1>', '\n'),
            ('<h2>', '\n## '),
            ('</h2>', '\n'),
            ('<h3>', '\n### '),
            ('</h3>', '\n'),
        ]
        
        for old, new in replacements:
            text = text.replace(old, new)
        
        # Remove remaining HTML tags
        import re
        text = re.sub('<[^>]+>', '', text)
        
        return text.strip()
    
    def _generate_report(self, pages: List[Dict]) -> None:
        """Generate sync status report"""
        report_path = self.reports_dir / "confluence_status.md"
        
        # Count by space
        spaces = {}
        for page in pages:
            space_name = page['space']['name']
            spaces[space_name] = spaces.get(space_name, 0) + 1
        
        content = f"""---
type: integration_report
service: confluence
timestamp: {datetime.now().isoformat()}
page_count: {len(pages)}
---

# Confluence Integration Status

**Last Sync**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Total Pages**: {len(pages)}  
**Status**: ✅ OPERATIONAL  
**Instance**: {self.base_url}

## Pages by Space

"""
        
        for space, count in sorted(spaces.items(), key=lambda x: x[1], reverse=True):
            content += f"- **{space}**: {count} pages\n"
        
        content += f"""

## Recent Pages

| Title | Space | Last Updated |
|-------|-------|--------------|
"""
        
        for page in pages[:10]:
            title_short = page['title'][:50] + ('...' if len(page['title']) > 50 else '')
            space_key = page['space']['key']
            updated = page['version'].get('when', 'Unknown')[:10]
            content += f"| {title_short} | {space_key} | {updated} |\n"
        
        content += f"""

---

**Vault**: {self.vault_path}  
**Synced Files**: {len(pages)}  
**Next Sync**: Automated via Scribe agent
"""
        
        report_path.write_text(content, encoding='utf-8')
        print(f"📄 Report saved: {report_path}")

def main():
    """Main entry point"""
    import argparse
    from dotenv import load_dotenv
    
    parser = argparse.ArgumentParser(description='Confluence Integration for Living Tapestry OS')
    parser.add_argument('--test', action='store_true', help='Test connection only')
    parser.add_argument('--sync', action='store_true', help='Sync pages to Obsidian')
    args = parser.parse_args()
    
    # Load environment variables
    repo_root = Path(__file__).parent.parent.parent
    env_path = repo_root / '.env.local'
    load_dotenv(env_path)
    
    # Get configuration
    base_url = os.getenv('CONFLUENCE_URL')
    email = os.getenv('CONFLUENCE_USER')
    api_token = os.getenv('CONFLUENCE_API_TOKEN')
    vault_path = os.getenv('VAULT_PATH', r'C:\Users\alexl\the living tapestry')
    
    if not all([base_url, email, api_token]):
        print("❌ Missing Confluence configuration in .env.local")
        print("Required variables:")
        print("  - CONFLUENCE_URL (e.g., https://yourcompany.atlassian.net/wiki)")
        print("  - CONFLUENCE_USER (your email)")
        print("  - CONFLUENCE_API_TOKEN")
        print("📋 Get your API token: https://id.atlassian.com/manage-profile/security")
        sys.exit(1)
    
    # Initialize integration
    print("⬢ Confluence Integration - Living Tapestry OS")
    print("=" * 50)
    
    confluence = ConfluenceIntegration(base_url, email, api_token, vault_path)
    
    # Test connection
    if not confluence.test_connection():
        sys.exit(1)
    
    if args.test:
        # Show available spaces
        print("\n📚 Available Spaces:")
        spaces = confluence.get_spaces()
        for space in spaces:
            print(f"  - {space['name']} ({space['key']})")
        print(f"\n✅ Connection test passed - {len(spaces)} spaces accessible")
        sys.exit(0)
    
    # Sync if requested or default behavior
    if args.sync or not args.test:
        success = confluence.sync_to_obsidian()
        sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
