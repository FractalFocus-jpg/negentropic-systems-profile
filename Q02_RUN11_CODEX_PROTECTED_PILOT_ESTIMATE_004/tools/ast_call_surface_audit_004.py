#!/usr/bin/env python3
from __future__ import annotations

import ast
import sys
from pathlib import Path

REQUIRED = [
    'client.metadata.get_cost',
    'client.metadata.get_record_count',
    'client.metadata.get_billable_size',
]
FORBIDDEN_ATTRS = {'timeseries', 'batch', 'symbology', 'submit_job', 'download', 'get_range', 'get_range_async'}
ALLOWED_KEYWORDS = {'dataset', 'start', 'end', 'symbols', 'schema', 'stype_in'}


def dotted(node: ast.AST) -> str | None:
    if isinstance(node, ast.Name):
        return node.id
    if isinstance(node, ast.Attribute):
        base = dotted(node.value)
        return f'{base}.{node.attr}' if base else node.attr
    return None


class Visitor(ast.NodeVisitor):
    def __init__(self) -> None:
        self.calls: list[tuple[str, int, list[str | None]]] = []
        self.forbidden: list[tuple[str, int]] = []

    def visit_Attribute(self, node: ast.Attribute) -> None:
        name = dotted(node)
        if node.attr in FORBIDDEN_ATTRS or name in FORBIDDEN_ATTRS:
            self.forbidden.append((name or node.attr, node.lineno))
        self.generic_visit(node)

    def visit_Name(self, node: ast.Name) -> None:
        if node.id in FORBIDDEN_ATTRS:
            self.forbidden.append((node.id, node.lineno))

    def visit_Call(self, node: ast.Call) -> None:
        name = dotted(node.func)
        if name:
            if any(part in FORBIDDEN_ATTRS for part in name.split('.')):
                self.forbidden.append((name, node.lineno))
            self.calls.append((name, node.lineno, [kw.arg for kw in node.keywords]))
        self.generic_visit(node)


def main(path: str) -> None:
    tree = ast.parse(Path(path).read_text(encoding='utf-8'))
    visitor = Visitor()
    visitor.visit(tree)
    if visitor.forbidden:
        raise SystemExit(f'FORBIDDEN_CALL_SURFACE:{visitor.forbidden}')
    metadata_calls = [call for call in visitor.calls if call[0] in REQUIRED]
    if [call[0] for call in metadata_calls] != REQUIRED:
        raise SystemExit(f'METADATA_CALLS_MUST_BE_EXACT:{[call[0] for call in metadata_calls]}')
    for name, lineno, keywords in metadata_calls:
        if any(keyword is None for keyword in keywords):
            raise SystemExit(f'METADATA_CALL_REJECTS_KWARGS_EXPANSION:{name}:{lineno}')
        bad = sorted(set(keywords) - ALLOWED_KEYWORDS)
        if bad:
            raise SystemExit(f'METADATA_CALL_REJECTS_KEYWORDS:{name}:{lineno}:{bad}')
        if set(keywords) != ALLOWED_KEYWORDS:
            raise SystemExit(f'METADATA_CALL_REQUIRES_KEYWORDS:{name}:{lineno}:{keywords}')
    print('Q02_RUN11_AST_CALL_SURFACE_AUDIT_004_PASS')


if __name__ == '__main__':
    main(sys.argv[1])
