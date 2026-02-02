#!/usr/bin/env python3
"""
Linear Integration for Living Tapestry OS
Syncs issues, projects, and tasks with Obsidian vault
"""

import os
import sys
import json
import requests
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

class LinearIntegration:
    def __init__(self, api_key: str, vault_path: str):
        self.api_key = api_key
        self.vault_path = Path(vault_path)
        self.base_url = "https://api.linear.app/graphql"
        self.headers = {
            "Authorization": api_key,
            "Content-Type": "application/json"
        }
        
        # Create reports directory
        self.reports_dir = self.vault_path / "OS" / "reports"
        self.reports_dir.mkdir(parents=True, exist_ok=True)
        
    def query(self, query_text: str, variables: Optional[Dict] = None) -> Dict:
        """Execute GraphQL query"""
        payload = {"query": query_text}
        if variables:
            payload["variables"] = variables
            
        response = requests.post(
            self.base_url,
            headers=self.headers,
            json=payload
        )
        response.raise_for_status()
        return response.json()
    
    def test_connection(self) -> bool:
        """Test Linear API connection"""
        try:
            query = """
            query {
                viewer {
                    id
                    name
                    email
                }
            }
            """
            result = self.query(query)
            
            if "data" in result and "viewer" in result["data"]:
                viewer = result["data"]["viewer"]
                print(f"✅ Connected to Linear as: {viewer['name']} ({viewer['email']})")
                return True
            else:
                print(f"❌ Connection failed: {result}")
                return False
                
        except Exception as e:
            print(f"❌ Connection error: {e}")
            return False
    
    def get_my_issues(self, limit: int = 50) -> List[Dict]:
        """Get issues assigned to me"""
        try:
            query = """
            query MyIssues($limit: Int!) {
                viewer {
                    assignedIssues(first: $limit) {
                        nodes {
                            id
                            identifier
                            title
                            description
                            priority
                            state {
                                name
                                type
                            }
                            project {
                                name
                            }
                            createdAt
                            updatedAt
                            url
                        }
                    }
                }
            }
            """
            result = self.query(query, {"limit": limit})
            
            if "data" in result:
                return result["data"]["viewer"]["assignedIssues"]["nodes"]
            return []
            
        except Exception as e:
            print(f"❌ Failed to get issues: {e}")
            return []
    
    def sync_to_obsidian(self) -> bool:
        """Sync Linear issues to Obsidian vault"""
        try:
            print("🔄 Syncing Linear issues to Obsidian...")
            
            issues = self.get_my_issues()
            
            if not issues:
                print("⚠️  No issues found")
                return True
            
            # Create Linear directory in vault
            linear_dir = self.vault_path / "linear"
            linear_dir.mkdir(exist_ok=True)
            
            synced_count = 0
            
            for issue in issues:
                # Create markdown file for each issue
                filename = f"{issue['identifier']}-{self._sanitize_filename(issue['title'])}.md"
                filepath = linear_dir / filename
                
                # Generate markdown content
                content = self._generate_issue_markdown(issue)
                
                # Write to file
                filepath.write_text(content, encoding='utf-8')
                synced_count += 1
            
            print(f"✅ Synced {synced_count} issues to {linear_dir}")
            
            # Generate status report
            self._generate_report(issues)
            
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
    
    def _generate_issue_markdown(self, issue: Dict) -> str:
        """Generate markdown content for an issue"""
        content = f"""---
type: linear_issue
id: {issue['id']}
identifier: {issue['identifier']}
title: "{issue['title']}"
priority: {issue.get('priority', 'None')}
state: {issue['state']['name']}
project: {issue.get('project', {}).get('name', 'None')}
created: {issue['createdAt']}
updated: {issue['updatedAt']}
url: {issue['url']}
---

# {issue['identifier']}: {issue['title']}

**Status**: {issue['state']['name']} ({issue['state']['type']})  
**Priority**: {issue.get('priority', 'None')}  
**Project**: {issue.get('project', {}).get('name', 'None')}  
**URL**: [{issue['identifier']}]({issue['url']})

## Description

{issue.get('description', 'No description provided')}

---

**Synced**: {datetime.now().isoformat()}  
**Source**: Linear API  
**Agent**: Scribe (Living Tapestry OS)
"""
        return content
    
    def _generate_report(self, issues: List[Dict]) -> None:
        """Generate sync status report"""
        report_path = self.reports_dir / "linear_status.md"
        
        # Count by state
        states = {}
        for issue in issues:
            state = issue['state']['name']
            states[state] = states.get(state, 0) + 1
        
        content = f"""---
type: integration_report
service: linear
timestamp: {datetime.now().isoformat()}
issue_count: {len(issues)}
---

# Linear Integration Status

**Last Sync**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Total Issues**: {len(issues)}  
**Status**: ✅ OPERATIONAL

## Issues by State

"""
        
        for state, count in sorted(states.items(), key=lambda x: x[1], reverse=True):
            content += f"- **{state}**: {count}\n"
        
        content += f"""

## Recent Issues

| ID | Title | State | Priority |
|----|-------|-------|----------|
"""
        
        for issue in issues[:10]:
            title_short = issue['title'][:50] + ('...' if len(issue['title']) > 50 else '')
            content += f"| {issue['identifier']} | {title_short} | {issue['state']['name']} | {issue.get('priority', 'None')} |\n"
        
        content += f"""

---

**Vault**: {self.vault_path}  
**Synced Files**: {len(issues)}  
**Next Sync**: Automated via Scribe agent
"""
        
        report_path.write_text(content, encoding='utf-8')
        print(f"📄 Report saved: {report_path}")

def main():
    """Main entry point"""
    import argparse
    from dotenv import load_dotenv
    
    parser = argparse.ArgumentParser(description='Linear Integration for Living Tapestry OS')
    parser.add_argument('--test', action='store_true', help='Test connection only')
    parser.add_argument('--sync', action='store_true', help='Sync issues to Obsidian')
    args = parser.parse_args()
    
    # Load environment variables
    repo_root = Path(__file__).parent.parent.parent
    env_path = repo_root / '.env.local'
    load_dotenv(env_path)
    
    # Get configuration
    api_key = os.getenv('LINEAR_API_KEY')
    vault_path = os.getenv('VAULT_PATH', r'C:\Users\alexl\the living tapestry')
    
    if not api_key:
        print("❌ LINEAR_API_KEY not found in .env.local")
        print("📋 Get your API key: https://linear.app/settings/api")
        sys.exit(1)
    
    # Initialize integration
    print("⬢ Linear Integration - Living Tapestry OS")
    print("=" * 50)
    
    linear = LinearIntegration(api_key, vault_path)
    
    # Test connection
    if not linear.test_connection():
        sys.exit(1)
    
    if args.test:
        print("✅ Connection test passed")
        sys.exit(0)
    
    # Sync if requested or default behavior
    if args.sync or not args.test:
        success = linear.sync_to_obsidian()
        sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
