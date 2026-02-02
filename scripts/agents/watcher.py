#!/usr/bin/env python3
"""
Vault Watcher Agent - Living Tapestry OS
Monitors vault for changes and updates Chroma index
"""
import os, sys, time, hashlib
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

class VaultHandler(FileSystemEventHandler):
    def __init__(self, vault_path):
        self.vault = Path(vault_path)
        self.last_update = {}
        
    def on_modified(self, event):
        if event.is_directory or not event.src_path.endswith('.md'):
            return
        path = Path(event.src_path)
        mtime = path.stat().st_mtime
        if self.last_update.get(str(path)) != mtime:
            self.last_update[str(path)] = mtime
            print(f"🔄 Updated: {path.name}")
            os.system(f"python scripts\\integrations\\chroma_sync.py --index")

vault = os.getenv("VAULT_PATH", r"C:\Users\alexl\the living tapestry")
