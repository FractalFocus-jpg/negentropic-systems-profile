#!/usr/bin/env python3
from __future__ import annotations

import ast
import json
import sys
from pathlib import Path


ALLOWED_METHODS = {
    "client.symbology.resolve",
    "client.metadata.get_dataset_condition",
    "client.metadata.get_cost",
    "client.metadata.get_record_count",
    "client.metadata.get_billable_size"
}
PROHIBITED_FRAGMENTS = {
    "client.metadata.list_datasets",
    "client.metadata.get_dataset_range",
    "client.metadata.list_schemas",
    "client.timeseries",
    "client.batch"
}


def dotted(node: ast.AST) -> str:
    parts = []
    cur = node
    while isinstance(cur, ast.Attribute):
        parts.append(cur.attr)
        cur = cur.value
    if isinstance(cur, ast.Name):
        parts.append(cur.id)
    return ".".join(reversed(parts))


def main() -> int:
    runner = Path(sys.argv[1])
    tree = ast.parse(runner.read_text(encoding="utf-8"), filename=str(runner))
    calls = []
    violations = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Call):
            name = dotted(node.func)
            if name.startswith("client."):
                calls.append(name)
                if name not in ALLOWED_METHODS:
                    violations.append(name)
            for fragment in PROHIBITED_FRAGMENTS:
                if name.startswith(fragment):
                    violations.append(name)
    result = {
        "status": "Q02_RUN11_AST_CALL_SURFACE_AUDIT_PASS" if not violations else "Q02_RUN11_AST_CALL_SURFACE_AUDIT_FAIL",
        "client_calls": calls,
        "violations": sorted(set(violations)),
        "allowed_methods": sorted(ALLOWED_METHODS)
    }
    print(json.dumps(result, sort_keys=True))
    return 0 if not violations else 2


if __name__ == "__main__":
    raise SystemExit(main())
