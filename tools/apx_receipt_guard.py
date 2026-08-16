#!/usr/bin/env python3
"""Fail-closed validator for APX/EIDOLEN evidence carriers.

This checks lineage/custody metadata only; it does not decide scientific truth.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import tempfile
from pathlib import Path
from typing import Any

TERMINALS = ("PASS_", "MIXED_", "FAIL_", "ERROR_", "TIMEOUT_", "UNRESOLVED_", "BLOCKED_")
STABLE_ID = re.compile(r"^[A-Z0-9][A-Z0-9_.:-]*(?:-[A-Z0-9_.:-]+)+$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def pick(data: dict[str, Any], *keys: str) -> Any:
    for key in keys:
        if key in data:
            return data[key]
    return None


def validate(path: Path, root: Path | None = None) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError("top-level JSON must be an object")
    root = root or path.parent
    sid = str(pick(data, "stable_id", "stableId") or "")
    parent = str(pick(data, "parent", "parent_stable_id", "parentStableId") or "")
    terminal = str(pick(data, "terminal", "first_terminal", "firstTerminal") or "")
    invocations = pick(data, "official_invocation", "official_invocations")
    reruns = pick(data, "same_id_reruns", "reruns")
    ceiling = pick(data, "claim_ceiling", "claim_ceilings")
    checks: dict[str, bool] = {
        "STABLE_ID_PRESENT": bool(sid),
        "STABLE_ID_FORMAT": bool(STABLE_ID.match(sid)),
        "PARENT_PRESENT": bool(parent),
        "TERMINAL_PRESENT": bool(terminal),
        "TERMINAL_GRAMMAR": terminal.startswith(TERMINALS),
        "OFFICIAL_INVOCATION_EXACTLY_ONE": invocations == 1,
        "NO_SAME_ID_RERUN": reruns == 0,
        "CLAIM_CEILING_PRESENT": isinstance(ceiling, (list, str)) and len(ceiling) > 0,
    }
    for label, sha_keys, path_keys in (
        ("SOURCE", ("source_sha256", "source_sha256_runtime"), ("source_path", "source_file")),
        ("PROTOCOL", ("protocol_sha256", "prefreeze_protocol_sha256"), ("protocol_path", "protocol_file")),
        ("TERMINAL_FILE", ("terminal_sha256",), ("terminal_path", "terminal_file")),
    ):
        expected = next((data[k] for k in sha_keys if k in data), None)
        rel = next((data[k] for k in path_keys if k in data), None)
        if expected is None and rel is None:
            continue
        checks[f"{label}_DECLARATION_COMPLETE"] = isinstance(expected, str) and isinstance(rel, str)
        if not checks[f"{label}_DECLARATION_COMPLETE"]:
            continue
        checks[f"{label}_SHA_FORMAT"] = bool(SHA256.match(expected))
        target = (root / rel).resolve()
        checks[f"{label}_FILE_EXISTS"] = target.is_file()
        if target.is_file() and checks[f"{label}_SHA_FORMAT"]:
            checks[f"{label}_SHA_MATCH"] = digest(target) == expected
    return {
        "stable_id": sid,
        "parent": parent,
        "terminal": terminal,
        "checks": checks,
        "status": "PASS" if all(checks.values()) else "FAIL",
    }


def self_test() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        source, protocol = root / "source.py", root / "protocol.txt"
        source.write_text("print('ok')\n", encoding="utf-8")
        protocol.write_text("frozen\n", encoding="utf-8")
        good = {
            "stable_id": "LT-UOS-APX-RECEIPT-GUARD-SELFTEST-S0",
            "parent": "LT-UOS-APX-PARENT-S0",
            "terminal": "PASS_APX_RECEIPT_GUARD_SELFTEST",
            "official_invocation": 1,
            "same_id_reruns": 0,
            "claim_ceiling": ["self-test only"],
            "source_path": "source.py",
            "source_sha256": digest(source),
            "protocol_path": "protocol.txt",
            "protocol_sha256": digest(protocol),
        }
        p = root / "good.json"
        p.write_text(json.dumps(good), encoding="utf-8")
        assert validate(p, root)["status"] == "PASS"
        bad = dict(good, same_id_reruns=1, source_sha256="0" * 64)
        p.write_text(json.dumps(bad), encoding="utf-8")
        report = validate(p, root)
        assert report["status"] == "FAIL"
        assert not report["checks"]["NO_SAME_ID_RERUN"]
        assert not report["checks"]["SOURCE_SHA_MATCH"]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("result", nargs="?", type=Path)
    parser.add_argument("--root", type=Path)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    try:
        if args.self_test:
            self_test()
            print("PASS_APX_RECEIPT_GUARD_SELFTEST")
            return 0
        if not args.result:
            parser.error("result is required unless --self-test is used")
        report = validate(args.result, args.root)
        if args.json:
            print(json.dumps(report, indent=2, sort_keys=True))
        else:
            checks = report["checks"]
            print(f"{report['status']}_APX_RECEIPT_GUARD_{sum(checks.values())}_OF_{len(checks)}")
            failed = [k for k, v in checks.items() if not v]
            if failed:
                print("failed: " + ", ".join(failed), file=sys.stderr)
        return 0 if report["status"] == "PASS" else 1
    except (OSError, ValueError, json.JSONDecodeError, AssertionError) as exc:
        print(f"FAIL_APX_RECEIPT_GUARD: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
