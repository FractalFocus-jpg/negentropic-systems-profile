#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
from pathlib import Path


PACKAGE_DIR = Path(__file__).resolve().parent
ARTIFACT_DIR = PACKAGE_DIR / "artifacts"
EXPECTED_OUTPUTS = [
    "arcx_symbology_receipt.json",
    "glbx_symbology_receipt.json",
    "arcx_dataset_condition_receipt.json",
    "glbx_dataset_condition_receipt.json",
    "arcx_cost_count_billable_size_receipt.json",
    "glbx_cost_count_billable_size_receipt.json",
    "canonical_preflight_manifest.json",
    "execution_report.json",
    "file_inventory.json",
    "checksum_manifest.json",
]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    files = sorted(path.name for path in ARTIFACT_DIR.iterdir() if path.is_file())
    if files != sorted(EXPECTED_OUTPUTS):
        raise SystemExit(f"OUTPUT_SET_MISMATCH:{files}")
    checksums = read_json(ARTIFACT_DIR / "checksum_manifest.json")["sha256"]
    for name in EXPECTED_OUTPUTS[:-1]:
        if checksums[name] != sha256_file(ARTIFACT_DIR / name):
            raise SystemExit(f"CHECKSUM_MISMATCH:{name}")
    report = read_json(ARTIFACT_DIR / "execution_report.json")
    if report.get("status") != "Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_PASS":
        raise SystemExit("EXECUTION_REPORT_NOT_PASS")
    if report.get("api_key_included") is not False:
        raise SystemExit("API_KEY_INCLUSION_FLAG_INVALID")
    if report.get("capital_action_performed") is not False:
        raise SystemExit("CAPITAL_ACTION_FLAG_INVALID")
    print(json.dumps({"status": "Q02_RUN11_POSTSETUP_OFFLINE_VALIDATION_PASS", "artifact_count": len(files), "api_key_included": False}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
