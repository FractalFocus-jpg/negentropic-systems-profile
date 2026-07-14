#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import os
import platform
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


PACKAGE_DIR = Path(__file__).resolve().parent
FROZEN_DIR = PACKAGE_DIR / "frozen"
ARTIFACT_DIR = PACKAGE_DIR / "artifacts"

QUALIFICATION = FROZEN_DIR / "q02_run11_qualification_002.json"
FROZEN_SCOPE = FROZEN_DIR / "q02_run11_frozen_scope_002.json"
STATIC_AUDIT = FROZEN_DIR / "q02_run11_static_audit_002.json"
MARKET_INPUT_CONTRACT = FROZEN_DIR / "q02_run11_market_input_contract_002.json"
PACKAGE_MANIFEST = FROZEN_DIR / "q02_run11_package_manifest_002.json"

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

ALLOWED_CALLS = [
    "ARCX.symbology.resolve",
    "ARCX.metadata.get_dataset_condition",
    "ARCX.metadata.get_cost",
    "ARCX.metadata.get_record_count",
    "ARCX.metadata.get_billable_size",
    "GLBX.symbology.resolve",
    "GLBX.metadata.get_dataset_condition",
    "GLBX.metadata.get_cost",
    "GLBX.metadata.get_record_count",
    "GLBX.metadata.get_billable_size",
]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: Any) -> None:
    path.write_text(json.dumps(value, indent=2, sort_keys=True, default=str), encoding="utf-8")


def canonical_hash(value: Any) -> str:
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(",", ":"), default=str).encode()).hexdigest()


def verify_static_hashes() -> dict[str, str]:
    manifest = read_json(PACKAGE_MANIFEST)
    expected = manifest["sha256"]
    paths = {
        "qualification": QUALIFICATION,
        "frozen_scope": FROZEN_SCOPE,
        "static_audit": STATIC_AUDIT,
        "market_input_contract": MARKET_INPUT_CONTRACT,
    }
    actual = {name: sha256_file(path) for name, path in paths.items()}
    for name, digest in actual.items():
        if expected[name] != digest:
            raise SystemExit(f"FROZEN_HASH_MISMATCH:{name}")
    actual["package_manifest"] = sha256_file(PACKAGE_MANIFEST)
    return actual


def verify_runtime() -> None:
    if platform.python_implementation() != "CPython" or platform.python_version() != "3.12.13":
        raise SystemExit(f"RUNTIME_MISMATCH: require CPython 3.12.13 got {platform.python_implementation()} {platform.python_version()}")


class CallGate:
    def __init__(self) -> None:
        self.calls: list[str] = []

    def record(self, call_name: str) -> None:
        expected = ALLOWED_CALLS[len(self.calls)] if len(self.calls) < len(ALLOWED_CALLS) else None
        if call_name != expected:
            raise SystemExit(f"AUTHENTICATED_CALL_ORDER_VIOLATION:{call_name}:expected:{expected}")
        self.calls.append(call_name)

    def assert_complete(self) -> None:
        if self.calls != ALLOWED_CALLS:
            raise SystemExit("AUTHENTICATED_CALL_COUNT_OR_ORDER_INCOMPLETE")


def safe_client() -> Any:
    key_present = bool(os.environ.get("DATABENTO_API_KEY", "").strip())
    if not key_present:
        raise SystemExit("DATABENTO_API_KEY_MISSING")
    import databento as db

    if getattr(db, "__version__", None) != "0.81.0":
        raise SystemExit(f"DATABENTO_VERSION_MISMATCH:{getattr(db, '__version__', None)}")
    return db.Historical(os.environ["DATABENTO_API_KEY"])


def child_by_name(scope: dict[str, Any], name: str) -> dict[str, Any]:
    for child in scope["children"]:
        if child["name"] == name:
            return child
    raise KeyError(name)


def main() -> int:
    ARTIFACT_DIR.mkdir(parents=True, exist_ok=True)
    for path in ARTIFACT_DIR.glob("*"):
        if path.is_file():
            path.unlink()

    verify_runtime()
    frozen_hashes = verify_static_hashes()
    qualification = read_json(QUALIFICATION)
    scope = read_json(FROZEN_SCOPE)
    static_audit = read_json(STATIC_AUDIT)
    market_contract = read_json(MARKET_INPUT_CONTRACT)

    if static_audit["permitted_authenticated_invocations_exact_order"] != ALLOWED_CALLS:
        raise SystemExit("STATIC_AUDIT_CALL_LIST_MISMATCH")
    if market_contract["allowed_schema"] != "mbo":
        raise SystemExit("MARKET_INPUT_CONTRACT_SCHEMA_MISMATCH")

    client = safe_client()
    gate = CallGate()
    generated_at = datetime.now(timezone.utc).isoformat()

    receipts: dict[str, Any] = {}
    for name in ["ARCX", "GLBX"]:
        child = child_by_name(scope, name)
        prefix = name.lower()
        gate.record(f"{name}.symbology.resolve")
        sym = client.symbology.resolve(
            dataset=child["dataset"],
            symbols=child["symbols"],
            stype_in="raw_symbol",
            stype_out="instrument_id",
            start_date=child["acquisition_start"][:10],
            end_date=child["acquisition_end_exclusive"][:10],
        )
        receipts[f"{prefix}_symbology"] = {
            "receipt_type": f"{name}_SYMBOLOGY_RECEIPT",
            "generated_at": generated_at,
            "dataset": child["dataset"],
            "symbols": child["symbols"],
            "schema": child["schema"],
            "result": sym,
            "api_key_included": False,
        }

        gate.record(f"{name}.metadata.get_dataset_condition")
        condition = client.metadata.get_dataset_condition(
            dataset=child["dataset"],
            start_date=child["acquisition_start"][:10],
            end_date=child["acquisition_end_exclusive"][:10],
        )
        receipts[f"{prefix}_dataset_condition"] = {
            "receipt_type": f"{name}_DATASET_CONDITION_RECEIPT",
            "generated_at": generated_at,
            "dataset": child["dataset"],
            "start_date": child["acquisition_start"][:10],
            "end_date": child["acquisition_end_exclusive"][:10],
            "condition": condition,
            "api_key_included": False,
        }

        gate.record(f"{name}.metadata.get_cost")
        cost = client.metadata.get_cost(
            dataset=child["dataset"],
            start=child["acquisition_start"],
            end=child["acquisition_end_exclusive"],
            symbols=child["symbols"],
            schema=child["schema"],
            stype_in="raw_symbol",
        )
        gate.record(f"{name}.metadata.get_record_count")
        record_count = client.metadata.get_record_count(
            dataset=child["dataset"],
            start=child["acquisition_start"],
            end=child["acquisition_end_exclusive"],
            symbols=child["symbols"],
            schema=child["schema"],
            stype_in="raw_symbol",
        )
        gate.record(f"{name}.metadata.get_billable_size")
        billable_size = client.metadata.get_billable_size(
            dataset=child["dataset"],
            start=child["acquisition_start"],
            end=child["acquisition_end_exclusive"],
            symbols=child["symbols"],
            schema=child["schema"],
            stype_in="raw_symbol",
        )
        receipts[f"{prefix}_cost_count_billable_size"] = {
            "receipt_type": f"{name}_COST_COUNT_BILLABLE_SIZE_RECEIPT",
            "generated_at": generated_at,
            "dataset": child["dataset"],
            "symbols": child["symbols"],
            "schema": child["schema"],
            "start": child["acquisition_start"],
            "end_exclusive": child["acquisition_end_exclusive"],
            "cost_usd": float(cost),
            "record_count": int(record_count),
            "billable_size_bytes": int(billable_size),
            "api_key_included": False,
        }

    gate.assert_complete()
    os.environ.pop("DATABENTO_API_KEY", None)

    output_map = {
        "arcx_symbology_receipt.json": receipts["arcx_symbology"],
        "glbx_symbology_receipt.json": receipts["glbx_symbology"],
        "arcx_dataset_condition_receipt.json": receipts["arcx_dataset_condition"],
        "glbx_dataset_condition_receipt.json": receipts["glbx_dataset_condition"],
        "arcx_cost_count_billable_size_receipt.json": receipts["arcx_cost_count_billable_size"],
        "glbx_cost_count_billable_size_receipt.json": receipts["glbx_cost_count_billable_size"],
    }

    canonical_preflight_manifest = {
        "artifact_type": "Q02_RUN11_CANONICAL_PREFLIGHT_MANIFEST",
        "generated_at": generated_at,
        "qualification_id": qualification["id"],
        "scope_id": scope["id"],
        "static_audit_id": static_audit["id"],
        "market_input_contract_id": market_contract["id"],
        "api_request_filter_timestamp": scope["api_request_filter_timestamp"],
        "scientific_alignment_timestamp": scope["scientific_alignment_timestamp"],
        "authenticated_invocation_count": len(gate.calls),
        "authenticated_invocations": gate.calls,
        "prohibited_actions_performed": [],
        "api_key_included": False,
        "frozen_hashes": frozen_hashes,
    }
    output_map["canonical_preflight_manifest.json"] = canonical_preflight_manifest

    execution_report = {
        "artifact_type": "Q02_RUN11_EXECUTION_REPORT",
        "generated_at": generated_at,
        "status": "Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_PASS",
        "runner": "q02_run11_metadata_runner_002.py",
        "authenticated_invocation_count": len(gate.calls),
        "exact_call_gate_passed": True,
        "credential_unset_after_use": "DATABENTO_API_KEY" not in os.environ,
        "download_performed": False,
        "purchase_performed": False,
        "capital_action_performed": False,
        "profitability_inference_performed": False,
        "api_key_included": False,
    }
    output_map["execution_report.json"] = execution_report

    for filename in EXPECTED_OUTPUTS[:8]:
        write_json(ARTIFACT_DIR / filename, output_map[filename])

    inventory = {
        "artifact_type": "Q02_RUN11_FILE_INVENTORY",
        "generated_at": generated_at,
        "files": [
            {"name": filename, "bytes": (ARTIFACT_DIR / filename).stat().st_size}
            for filename in EXPECTED_OUTPUTS[:8]
        ],
    }
    write_json(ARTIFACT_DIR / "file_inventory.json", inventory)

    checksum_manifest = {
        "artifact_type": "Q02_RUN11_CHECKSUM_MANIFEST",
        "generated_at": generated_at,
        "sha256": {
            filename: sha256_file(ARTIFACT_DIR / filename)
            for filename in EXPECTED_OUTPUTS[:9]
        },
    }
    write_json(ARTIFACT_DIR / "checksum_manifest.json", checksum_manifest)

    final_files = sorted(path.name for path in ARTIFACT_DIR.iterdir() if path.is_file())
    if final_files != sorted(EXPECTED_OUTPUTS):
        raise SystemExit(f"OUTPUT_SET_MISMATCH:{final_files}")

    print(json.dumps({"status": execution_report["status"], "authenticated_invocations": len(gate.calls), "api_key_included": False}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
