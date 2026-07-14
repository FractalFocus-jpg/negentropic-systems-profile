#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
from datetime import date
from pathlib import Path


PACKAGE_DIR = Path(__file__).resolve().parent
ARTIFACT_DIR = PACKAGE_DIR / "artifacts"
EXPECTED_CALLS = [
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
NEGATIVE_FIELDS = [
    "timeseries_request",
    "batch_submission",
    "download",
    "purchase",
    "alpaca",
    "paper_trade",
    "live_trade",
    "order_submission",
    "profitability_inference",
    "capital_authority",
    "trading_authority",
]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def read_json(name: str):
    return json.loads((ARTIFACT_DIR / name).read_text(encoding="utf-8"))


def condition_dates(receipt) -> set[str]:
    out = set()
    for row in receipt["response"]:
        for key in ("date", "start_date", "end_date"):
            if key in row and row[key]:
                out.add(str(row[key])[:10])
    return out


def validate_symbology(name: str, receipt, expected_request: dict) -> None:
    if receipt["request"] != expected_request:
        raise SystemExit(f"{name}_SYMBOLOGY_REQUEST_MISMATCH")
    response = receipt["response"]
    if response.get("status") != 0:
        raise SystemExit(f"{name}_SYMBOLOGY_STATUS_NONZERO")
    if response.get("not_found"):
        raise SystemExit(f"{name}_SYMBOLOGY_NOT_FOUND")
    if "result" not in response:
        raise SystemExit(f"{name}_SYMBOLOGY_RESULT_MISSING")
    validation = receipt["semantic_validation"]
    if response.get("partial") and validation.get("partial_requires_contract_role_adjudication") is not True:
        raise SystemExit(f"{name}_PARTIAL_NOT_ADJUDICATION_MARKED")


def validate_condition(name: str, receipt, expected_request: dict) -> None:
    if receipt["request"] != expected_request:
        raise SystemExit(f"{name}_CONDITION_REQUEST_MISMATCH")
    if not isinstance(receipt.get("response"), list):
        raise SystemExit(f"{name}_CONDITION_RESPONSE_NOT_LIST")
    if receipt["semantic_validation"].get("calendar_and_waiver_validation_required") is not True:
        raise SystemExit(f"{name}_CONDITION_NO_CALENDAR_WAIVER_FLAG")
    if receipt["semantic_validation"].get("final_pass_declared") is not False:
        raise SystemExit(f"{name}_CONDITION_FINAL_PASS_DECLARED")


def validate_cost(name: str, receipt, expected_request: dict) -> None:
    if receipt["request"] != expected_request:
        raise SystemExit(f"{name}_COST_REQUEST_MISMATCH")
    if not isinstance(receipt.get("cost_usd_lossless"), str):
        raise SystemExit(f"{name}_LOSSLESS_COST_MISSING")
    if not isinstance(receipt.get("record_count"), int):
        raise SystemExit(f"{name}_RECORD_COUNT_INVALID")
    if not isinstance(receipt.get("billable_bytes"), int):
        raise SystemExit(f"{name}_BILLABLE_BYTES_INVALID")


def main() -> int:
    files = sorted(path.name for path in ARTIFACT_DIR.iterdir() if path.is_file())
    if files != sorted(EXPECTED_OUTPUTS):
        raise SystemExit(f"OUTPUT_SET_MISMATCH:{files}")
    checksums = read_json("checksum_manifest.json")["sha256"]
    for name in EXPECTED_OUTPUTS[:-1]:
        if checksums.get(name) != sha256_file(ARTIFACT_DIR / name):
            raise SystemExit(f"CHECKSUM_MISMATCH:{name}")

    validate_symbology("ARCX", read_json("arcx_symbology_receipt.json"), {
        "dataset": "ARCX.PILLAR", "symbols": ["SPY"], "schema": "mbo",
        "start_date": "2020-01-02", "end_date_exclusive": "2020-04-16",
        "stype_in": "raw_symbol", "stype_out": "instrument_id"
    })
    validate_symbology("GLBX", read_json("glbx_symbology_receipt.json"), {
        "dataset": "GLBX.MDP3", "symbols": ["ESH0", "ESM0"], "schema": "mbo",
        "start_date": "2020-01-01", "end_date_exclusive": "2020-04-16",
        "stype_in": "raw_symbol", "stype_out": "instrument_id"
    })
    validate_condition("ARCX", read_json("arcx_dataset_condition_receipt.json"), {
        "dataset": "ARCX.PILLAR", "start_date": "2020-01-02", "end_date_inclusive": "2020-04-15"
    })
    validate_condition("GLBX", read_json("glbx_dataset_condition_receipt.json"), {
        "dataset": "GLBX.MDP3", "start_date": "2020-01-01", "end_date_inclusive": "2020-04-15"
    })
    validate_cost("ARCX", read_json("arcx_cost_count_billable_size_receipt.json"), {
        "dataset": "ARCX.PILLAR", "symbols": ["SPY"], "schema": "mbo",
        "start": "2020-01-02T00:00:00Z", "end_exclusive": "2020-04-16T00:00:00Z",
        "stype_in": "raw_symbol"
    })
    validate_cost("GLBX", read_json("glbx_cost_count_billable_size_receipt.json"), {
        "dataset": "GLBX.MDP3", "symbols": ["ESH0", "ESM0"], "schema": "mbo",
        "start": "2020-01-01T00:00:00Z", "end_exclusive": "2020-04-15T21:00:00Z",
        "stype_in": "raw_symbol"
    })
    report = read_json("execution_report.json")
    if report.get("authenticated_invocations") != EXPECTED_CALLS:
        raise SystemExit("AUTHENTICATED_CALLS_MISMATCH")
    for field in NEGATIVE_FIELDS:
        if report["negative_actions"].get(field) is not False:
            raise SystemExit(f"NEGATIVE_ACTION_FLAG_INVALID:{field}")
    print(json.dumps({"status": "Q02_RUN11_POSTSETUP_OFFLINE_VALIDATION_PASS", "artifact_count": len(files)}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
