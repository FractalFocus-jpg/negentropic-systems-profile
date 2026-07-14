#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import os
import platform
import sys
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from pathlib import Path
from typing import Any


PACKAGE_DIR = Path(__file__).resolve().parent
FROZEN_DIR = PACKAGE_DIR / "frozen"
ARTIFACT_DIR = PACKAGE_DIR / "artifacts"

ANTECEDENT_ROOTS = FROZEN_DIR / "q02_run11_antecedent_custody_roots_003.json"
FROZEN_SCOPE = FROZEN_DIR / "q02_run11_frozen_scope_003.json"
STATIC_AUDIT = FROZEN_DIR / "q02_run11_static_audit_003.json"
PACKAGE_MANIFEST = FROZEN_DIR / "q02_run11_package_manifest_003.json"

STATUS = "Q02_RUN11_AUTHENTICATED_METADATA_PREFLIGHT_EXECUTED_RECEIPTS_PENDING_SEMANTIC_VALIDATION_CAPITAL_AUTHORITY_FALSE"
NEGATIVE_ACTIONS = {
    "timeseries_request": False,
    "batch_submission": False,
    "download": False,
    "purchase": False,
    "alpaca": False,
    "paper_trade": False,
    "live_trade": False,
    "order_submission": False,
    "profitability_inference": False,
    "capital_authority": False,
    "trading_authority": False,
}
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


def verify_static_hashes() -> dict[str, str]:
    manifest = read_json(PACKAGE_MANIFEST)
    paths = {
        "antecedent_roots": ANTECEDENT_ROOTS,
        "frozen_scope": FROZEN_SCOPE,
        "static_audit": STATIC_AUDIT,
        "metadata_runner": PACKAGE_DIR / "q02_run11_metadata_runner_003.py",
        "postsetup_validator": PACKAGE_DIR / "q02_run11_postsetup_validator_003.py",
        "ast_audit": PACKAGE_DIR / "tools" / "q02_run11_ast_call_surface_audit_003.py",
    }
    actual = {name: sha256_file(path) for name, path in paths.items()}
    for name, digest in actual.items():
        if manifest["sha256"][name] != digest:
            raise SystemExit(f"FROZEN_HASH_MISMATCH:{name}")
    actual["package_manifest"] = sha256_file(PACKAGE_MANIFEST)
    return actual


def verify_runtime() -> None:
    if platform.python_implementation() != "CPython" or platform.python_version() != "3.12.13":
        raise SystemExit(f"RUNTIME_MISMATCH:{platform.python_implementation()} {platform.python_version()}")


def child(scope: dict[str, Any], name: str) -> dict[str, Any]:
    for item in scope["children"]:
        if item["name"] == name:
            return item
    raise KeyError(name)


class CallGate:
    def __init__(self) -> None:
        self.calls: list[str] = []

    def record(self, call_name: str) -> None:
        expected = ALLOWED_CALLS[len(self.calls)] if len(self.calls) < len(ALLOWED_CALLS) else None
        if call_name != expected:
            raise SystemExit(f"AUTHENTICATED_CALL_ORDER_VIOLATION:{call_name}:expected:{expected}")
        self.calls.append(call_name)

    def complete(self) -> None:
        if self.calls != ALLOWED_CALLS:
            raise SystemExit("AUTHENTICATED_CALLS_INCOMPLETE")


def check_symbology(name: str, response: dict[str, Any]) -> dict[str, Any]:
    status = response.get("status")
    not_found = response.get("not_found") or []
    partial = response.get("partial") or []
    if status != 0:
        raise SystemExit(f"{name}_SYMBOLOGY_STATUS_NONZERO:{status}")
    if not_found:
        raise SystemExit(f"{name}_SYMBOLOGY_NOT_FOUND:{not_found}")
    return {
        "status_zero": True,
        "not_found_empty": True,
        "partial": partial,
        "partial_requires_contract_role_adjudication": bool(partial),
        "final_pass_declared": False,
    }


def condition_adjudication(condition: list[dict[str, Any]]) -> dict[str, Any]:
    flagged = []
    for row in condition:
        text = json.dumps(row, sort_keys=True, default=str).lower()
        if any(token in text for token in ["degraded", "pending", "missing"]):
            flagged.append(row)
    return {
        "all_returned_dates_and_conditions_preserved": True,
        "flagged_for_adjudication": flagged,
        "calendar_and_waiver_validation_required": True,
        "final_pass_declared": False,
    }


def lossless_number(value: Any) -> str:
    return str(Decimal(str(value)))


def main() -> int:
    ARTIFACT_DIR.mkdir(parents=True, exist_ok=True)
    for path in ARTIFACT_DIR.glob("*"):
        if path.is_file():
            path.unlink()

    verify_runtime()
    frozen_hashes = verify_static_hashes()
    antecedent = read_json(ANTECEDENT_ROOTS)
    scope = read_json(FROZEN_SCOPE)
    static_audit = read_json(STATIC_AUDIT)
    if static_audit["runner_status"] != STATUS:
        raise SystemExit("STATIC_AUDIT_STATUS_MISMATCH")

    key = os.environ.get("DATABENTO_API_KEY", "").strip()
    if not key:
        raise SystemExit("DATABENTO_API_KEY_MISSING")

    import databento as db

    if getattr(db, "__version__", None) != "0.81.0":
        raise SystemExit(f"DATABENTO_VERSION_MISMATCH:{getattr(db, '__version__', None)}")
    client = db.Historical(key)
    gate = CallGate()
    now = datetime.now(timezone.utc)
    generated_at = now.isoformat()
    expires_at = (now + timedelta(seconds=int(scope["expiration_seconds"]))).isoformat()
    outputs: dict[str, Any] = {}

    for name in ["ARCX", "GLBX"]:
        cfg = child(scope, name)
        low = name.lower()
        gate.record(f"{name}.symbology.resolve")
        sym = client.symbology.resolve(
            dataset=cfg["dataset"],
            symbols=cfg["symbols"],
            stype_in="raw_symbol",
            stype_out="instrument_id",
            start_date=cfg["symbology_start_date"],
            end_date=cfg["symbology_end_date_exclusive"],
        )
        outputs[f"{low}_symbology_receipt.json"] = {
            "receipt_type": f"{name}_SYMBOLOGY_RECEIPT",
            "observation_timestamp": generated_at,
            "expiration_timestamp": expires_at,
            "request": {
                "dataset": cfg["dataset"],
                "symbols": cfg["symbols"],
                "schema": cfg["schema"],
                "start_date": cfg["symbology_start_date"],
                "end_date_exclusive": cfg["symbology_end_date_exclusive"],
                "stype_in": "raw_symbol",
                "stype_out": "instrument_id",
            },
            "response": sym,
            "semantic_validation": check_symbology(name, sym),
            "full_date_segmented_mappings_preserved": True,
            "api_key_included": False,
        }

        gate.record(f"{name}.metadata.get_dataset_condition")
        condition = client.metadata.get_dataset_condition(
            dataset=cfg["dataset"],
            start_date=cfg["condition_start_date"],
            end_date=cfg["condition_end_date_inclusive"],
        )
        outputs[f"{low}_dataset_condition_receipt.json"] = {
            "receipt_type": f"{name}_DATASET_CONDITION_RECEIPT",
            "observation_timestamp": generated_at,
            "expiration_timestamp": expires_at,
            "request": {
                "dataset": cfg["dataset"],
                "start_date": cfg["condition_start_date"],
                "end_date_inclusive": cfg["condition_end_date_inclusive"],
            },
            "response": condition,
            "semantic_validation": condition_adjudication(condition),
            "api_key_included": False,
        }

        gate.record(f"{name}.metadata.get_cost")
        cost = client.metadata.get_cost(
            dataset=cfg["dataset"],
            start=cfg["acquisition_start"],
            end=cfg["acquisition_end_exclusive"],
            symbols=cfg["symbols"],
            schema=cfg["schema"],
            stype_in="raw_symbol",
        )
        gate.record(f"{name}.metadata.get_record_count")
        record_count = client.metadata.get_record_count(
            dataset=cfg["dataset"],
            start=cfg["acquisition_start"],
            end=cfg["acquisition_end_exclusive"],
            symbols=cfg["symbols"],
            schema=cfg["schema"],
            stype_in="raw_symbol",
        )
        gate.record(f"{name}.metadata.get_billable_size")
        billable = client.metadata.get_billable_size(
            dataset=cfg["dataset"],
            start=cfg["acquisition_start"],
            end=cfg["acquisition_end_exclusive"],
            symbols=cfg["symbols"],
            schema=cfg["schema"],
            stype_in="raw_symbol",
        )
        outputs[f"{low}_cost_count_billable_size_receipt.json"] = {
            "receipt_type": f"{name}_COST_COUNT_BILLABLE_SIZE_RECEIPT",
            "observation_timestamp": generated_at,
            "expiration_timestamp": expires_at,
            "request": {
                "dataset": cfg["dataset"],
                "symbols": cfg["symbols"],
                "schema": cfg["schema"],
                "start": cfg["acquisition_start"],
                "end_exclusive": cfg["acquisition_end_exclusive"],
                "stype_in": "raw_symbol",
            },
            "cost_usd": float(cost),
            "cost_usd_lossless": lossless_number(cost),
            "record_count": int(record_count),
            "billable_bytes": int(billable),
            "api_key_included": False,
        }

    gate.complete()
    os.environ.pop("DATABENTO_API_KEY", None)

    outputs["canonical_preflight_manifest.json"] = {
        "artifact_type": "Q02_RUN11_CANONICAL_PREFLIGHT_MANIFEST_003",
        "observation_timestamp": generated_at,
        "expiration_timestamp": expires_at,
        "status": STATUS,
        "antecedent_custody_roots": antecedent,
        "frozen_hashes": frozen_hashes,
        "api_request_filter_timestamp": scope["api_request_filter_timestamp"],
        "scientific_alignment_timestamp": scope["scientific_alignment_timestamp"],
        "authenticated_invocations": gate.calls,
        "negative_actions": NEGATIVE_ACTIONS,
        "capital_authority": False,
        "final_pass_declared": False,
    }
    outputs["execution_report.json"] = {
        "artifact_type": "Q02_RUN11_EXECUTION_REPORT_003",
        "observation_timestamp": generated_at,
        "expiration_timestamp": expires_at,
        "status": STATUS,
        "authenticated_invocation_count": len(gate.calls),
        "authenticated_invocations": gate.calls,
        "credential_unset_after_use": "DATABENTO_API_KEY" not in os.environ,
        "negative_actions": NEGATIVE_ACTIONS,
        "api_key_included": False,
    }

    for filename in EXPECTED_OUTPUTS[:8]:
        write_json(ARTIFACT_DIR / filename, outputs[filename])

    inventory = {
        "artifact_type": "Q02_RUN11_FILE_INVENTORY_003",
        "observation_timestamp": generated_at,
        "files": [{"name": name, "bytes": (ARTIFACT_DIR / name).stat().st_size} for name in EXPECTED_OUTPUTS[:8]],
    }
    write_json(ARTIFACT_DIR / "file_inventory.json", inventory)
    checksum = {
        "artifact_type": "Q02_RUN11_CHECKSUM_MANIFEST_003",
        "observation_timestamp": generated_at,
        "sha256": {name: sha256_file(ARTIFACT_DIR / name) for name in EXPECTED_OUTPUTS[:9]},
    }
    write_json(ARTIFACT_DIR / "checksum_manifest.json", checksum)
    final = sorted(path.name for path in ARTIFACT_DIR.iterdir() if path.is_file())
    if final != sorted(EXPECTED_OUTPUTS):
        raise SystemExit(f"OUTPUT_SET_MISMATCH:{final}")
    print(json.dumps({"status": STATUS, "authenticated_invocations": len(gate.calls), "capital_authority": False, "api_key_included": False}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
