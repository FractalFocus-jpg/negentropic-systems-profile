#!/usr/bin/env python3
from __future__ import annotations
import ast, sys
from pathlib import Path
ALLOWED={'get_cost','get_record_count','get_billable_size'}
FORBIDDEN={'get_range','submit_job','download','purchase','place_order','submit_order'}
class Visitor(ast.NodeVisitor):
    def __init__(self): self.calls=[]
    def visit_Call(self,node):
        f=node.func; name=None
        if isinstance(f,ast.Attribute): name=f.attr
        elif isinstance(f,ast.Name): name=f.id
        if name: self.calls.append((name,node.lineno))
        self.generic_visit(node)
def main(path):
    tree=ast.parse(Path(path).read_text(encoding='utf-8')); v=Visitor(); v.visit(tree)
    bad=[(n,l) for n,l in v.calls if n in FORBIDDEN]
    if bad: raise SystemExit(f'FORBIDDEN_CALL_SURFACE:{bad}')
    needed=ALLOWED-{n for n,_ in v.calls}
    if needed: raise SystemExit(f'MISSING_METADATA_CALLS:{sorted(needed)}')
    print('Q02_RUN11_AST_CALL_SURFACE_AUDIT_004_PASS')
if __name__=='__main__': main(sys.argv[1])
