"""
SAFE_DEMO Redaction Module
Hides sensitive paths, hashes, URLs, and identifiers for public demos.
"""

import re
from typing import Dict, Any, Optional
from pathlib import Path


class Redactor:
    """Redacts sensitive information for safe demo mode."""
    
    # Patterns to redact
    PATTERNS = {
        "path": re.compile(r"[A-Za-z]:\\\[^\s\n]+|/home/[^\s\n]+|/Users/[^\s\n]+"),
        "hash": re.compile(r"[a-f0-9]{32,64}"),
        "email": re.compile(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"),
        "url": re.compile(r"https?://[^\s\n]+"),
        "ip": re.compile(r"\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"),
        "token": re.compile(r"[A-Za-z0-9_-]{20,}"),
    }
    
    REDACTIONS = {
        "path": "[PATH]",
        "hash": "[HASH]",
        "email": "[EMAIL]",
        "url": "[URL]",
        "ip": "[IP]",
        "token": "[TOKEN]",
    }
    
    @classmethod
    def redact_string(cls, text: str) -> str:
        """Redact sensitive patterns from string."""
        if not isinstance(text, str):
            return text
        
        for key, pattern in cls.PATTERNS.items():
            text = pattern.sub(cls.REDACTIONS[key], text)
        return text
    
    @classmethod
    def redact_dict(cls, data: Dict[str, Any]) -> Dict[str, Any]:
        """Recursively redact sensitive data from dict."""
        result = {}
        for key, value in data.items():
            if isinstance(value, str):
                result[key] = cls.redact_string(value)
            elif isinstance(value, dict):
                result[key] = cls.redact_dict(value)
            elif isinstance(value, list):
                result[key] = cls.redact_list(value)
            else:
                result[key] = value
        return result
    
    @classmethod
    def redact_list(cls, data: list) -> list:
        """Recursively redact sensitive data from list."""
        result = []
        for item in data:
            if isinstance(item, str):
                result.append(cls.redact_string(item))
            elif isinstance(item, dict):
                result.append(cls.redact_dict(item))
            elif isinstance(item, list):
                result.append(cls.redact_list(item))
            else:
                result.append(item)
        return result
    
    @classmethod
    def safe_demo_mode(cls, enabled: bool = True):
        """Context manager for safe demo mode."""
        # Set global flag
        import os
        if enabled:
            os.environ["TAPESTRY_SAFE_DEMO"] = "1"
        else:
            os.environ.pop("TAPESTRY_SAFE_DEMO", None)
    
    @classmethod
    def is_safe_demo(cls) -> bool:
        """Check if safe demo mode is enabled."""
        import os
        return os.environ.get("TAPESTRY_SAFE_DEMO") == "1"


def safe_project(data: Dict[str, Any]) -> Dict[str, Any]:
    """Apply safe demo redaction to data projection."""
    if Redactor.is_safe_demo():
        return Redactor.redact_dict(data)
    return data
