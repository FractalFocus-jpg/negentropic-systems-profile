#!/usr/bin/env python3
"""
Chroma Vector DB Integration for Living Tapestry OS
Indexes Obsidian vault content for semantic search
"""

import os
import sys
import json
from datetime import datetime
from pathlib import Path
from typing import List, Dict
import hashlib

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

try:
    import chromadb
    from chromadb.config import Settings
except ImportError:
    print("❌ chromadb not installed. Installing...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "chromadb"])
    import chromadb
    from chromadb.config import Settings

class ChromaIntegration:
    def __init__(self, vault_path: str, chroma_host: str = "localhost", chroma_port: int = 8000):
        self.vault_path = Path(vault_path)
        self.chroma_host = chroma_host
        self.chroma_port = chroma_port
        
        # Initialize Chroma client
        try:
            self.client = chromadb.HttpClient(
                host=chroma_host,
                port=chroma_port,
                settings=Settings(anonymized_telemetry=False)
            )
            self.connected = True
        except Exception as e:
            print(f"⚠️  Chroma server not available: {e}")
            print("    Falling back to persistent local storage...")
            chroma_dir = self.vault_path.parent / ".chroma_db"
            chroma_dir.mkdir(exist_ok=True)
            self.client = chromadb.PersistentClient(
                path=str(chroma_dir),
                settings=Settings(anonymized_telemetry=False)
            )
            self.connected = False
        
        # Get or create collection
        self.collection = self.client.get_or_create_collection(
            name="living_tapestry",
            metadata={"description": "Living Tapestry OS knowledge base"}
        )
        
        # Create reports directory
        self.reports_dir = self.vault_path / "OS" / "reports"
        self.reports_dir.mkdir(parents=True, exist_ok=True)
    
    def test_connection(self) -> bool:
        """Test Chroma connection"""
        try:
            # Try to get collection info
            count = self.collection.count()
            connection_type = "HTTP Server" if self.connected else "Local Storage"
            print(f"✅ Connected to Chroma ({connection_type})")
            print(f"   Collection: {self.collection.name}")
            print(f"   Documents: {count}")
            return True
        except Exception as e:
            print(f"❌ Connection test failed: {e}")
            return False
    
    def index_vault(self, source_dirs: List[str] = None) -> bool:
        """Index vault content into Chroma"""
        try:
            if source_dirs is None:
                source_dirs = ["OS", "media", "confluence", "linear"]
            
            print(f"🔍 Indexing vault: {self.vault_path}")
            print(f"   Directories: {', '.join(source_dirs)}")
            
            documents = []
            metadatas = []
            ids = []
            
            for dir_name in source_dirs:
                dir_path = self.vault_path / dir_name
                if not dir_path.exists():
                    continue
                
                # Find all markdown files
                md_files = list(dir_path.rglob("*.md"))
                print(f"   Found {len(md_files)} files in {dir_name}/")
                
                for md_file in md_files:
                    try:
                        # Read file
                        content = md_file.read_text(encoding='utf-8')
                        
                        # Skip empty files
                        if len(content.strip()) < 10:
                            continue
                        
                        # Generate unique ID
                        file_id = hashlib.md5(str(md_file).encode()).hexdigest()
                        
                        # Extract metadata
                        metadata = {
                            "source": str(md_file.relative_to(self.vault_path)),
                            "directory": dir_name,
                            "filename": md_file.name,
                            "modified": datetime.fromtimestamp(md_file.stat().st_mtime).isoformat(),
                            "size": len(content)
                        }
                        
                        documents.append(content)
                        metadatas.append(metadata)
                        ids.append(file_id)
                        
                    except Exception as e:
                        print(f"⚠️  Error reading {md_file}: {e}")
                        continue
            
            if not documents:
                print("⚠️  No documents to index")
                return True
            
            print(f"\n📦 Indexing {len(documents)} documents...")
            
            # Add to collection (upsert to handle updates)
            self.collection.upsert(
                documents=documents,
                metadatas=metadatas,
                ids=ids
            )
            
            print(f"✅ Indexed {len(documents)} documents")
            
            # Generate report
            self._generate_report(len(documents), source_dirs)
            
            return True
            
        except Exception as e:
            print(f"❌ Indexing failed: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def search(self, query: str, n_results: int = 5) -> List[Dict]:
        """Search indexed content"""
        try:
            results = self.collection.query(
                query_texts=[query],
                n_results=n_results
            )
            
            # Format results
            formatted = []
            for i, doc_id in enumerate(results['ids'][0]):
                formatted.append({
                    "id": doc_id,
                    "document": results['documents'][0][i],
                    "metadata": results['metadatas'][0][i],
                    "distance": results['distances'][0][i] if 'distances' in results else None
                })
            
            return formatted
            
        except Exception as e:
            print(f"❌ Search failed: {e}")
            return []
    
    def _generate_report(self, doc_count: int, source_dirs: List[str]) -> None:
        """Generate indexing status report"""
        report_path = self.reports_dir / "chroma_index.md"
        
        # Get collection stats
        total_count = self.collection.count()
        
        content = f"""---
type: integration_report
service: chroma
timestamp: {datetime.now().isoformat()}
documents_indexed: {doc_count}
total_documents: {total_count}
---

# Chroma Vector DB Status

**Last Index**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Documents Indexed**: {doc_count}  
**Total in Collection**: {total_count}  
**Status**: ✅ OPERATIONAL  
**Connection**: {"HTTP Server" if self.connected else "Local Storage"}

## Indexed Directories

"""
        
        for dir_name in source_dirs:
            dir_path = self.vault_path / dir_name
            if dir_path.exists():
                file_count = len(list(dir_path.rglob("*.md")))
                content += f"- **{dir_name}/**: {file_count} files\n"
        
        content += f"""

## Search Example

Try searching your vault:

```python
from scripts.integrations.chroma_sync import ChromaIntegration

chroma = ChromaIntegration(r'{self.vault_path}')
results = chroma.search("your query here", n_results=5)

for result in results:
    print(f"File: {{result['metadata']['source']}}")
    print(f"Content: {{result['document'][:200]}}...")
    print()
```

---

**Vault**: {self.vault_path}  
**Collection**: {self.collection.name}  
**Next Sync**: Automated via Weaver agent
"""
        
        report_path.write_text(content, encoding='utf-8')
        print(f"📄 Report saved: {report_path}")

def main():
    """Main entry point"""
    import argparse
    from dotenv import load_dotenv
    
    parser = argparse.ArgumentParser(description='Chroma Vector DB Integration')
    parser.add_argument('--test', action='store_true', help='Test connection only')
    parser.add_argument('--index', action='store_true', help='Index vault content')
    parser.add_argument('--search', type=str, help='Search query')
    parser.add_argument('--source', type=str, help='Comma-separated source dirs (default: OS,media,confluence,linear)')
    args = parser.parse_args()
    
    # Load environment variables
    repo_root = Path(__file__).parent.parent.parent
    env_path = repo_root / '.env.local'
    load_dotenv(env_path)
    
    # Get configuration
    vault_path = os.getenv('VAULT_PATH', r'C:\Users\alexl\the living tapestry')
    
    # Parse source directories
    source_dirs = None
    if args.source:
        source_dirs = [s.strip() for s in args.source.split(',')]
    
    # Initialize integration
    print("⬢ Chroma Vector DB Integration - Living Tapestry OS")
    print("=" * 50)
    
    chroma = ChromaIntegration(vault_path)
    
    # Test connection
    if not chroma.test_connection():
        sys.exit(1)
    
    if args.test:
        print("✅ Connection test passed")
        sys.exit(0)
    
    # Handle search
    if args.search:
        print(f"\n🔍 Searching for: {args.search}")
        results = chroma.search(args.search, n_results=5)
        
        for i, result in enumerate(results, 1):
            print(f"\n--- Result {i} ---")
            print(f"File: {result['metadata']['source']}")
            print(f"Preview: {result['document'][:200]}...")
            if result['distance']:
                print(f"Distance: {result['distance']:.4f}")
        
        sys.exit(0)
    
    # Index if requested or default behavior
    if args.index or not (args.test or args.search):
        success = chroma.index_vault(source_dirs)
        sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
