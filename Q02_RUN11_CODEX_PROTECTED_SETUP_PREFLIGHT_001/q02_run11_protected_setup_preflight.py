#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import os
from datetime import datetime, timezone
from pathlib import Path

import databento as db


PACKAGE_DIR = Path(__file__).resolve().parent
ARTIFACT_DIR = PACKAGE_DIR / "artifacts"
ARTIFACT_DIR.mkdir(parents=True, exist_ok=True)

DATASET = "ARCX.PILLAR"
SYMBOL = "SPY"
START_DATE = "2020-02-03"
END_DATE = "2020-03-18"
START = "2020-02-03T00:00:00"
END_EXCLUSIVE = "2020-03-19T00:00:00"
MAX_COST_USD = 25.0
SCHEMAS = ["mbo", "mbp-1", "mbp-10", "tbbo", "trades"]


def digest(value) -> str:
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(",", ":"), default=str).encode()).hexdigest()


def main() -> int:
    key = os.environ.get("DATABENTO_API_KEY", "").strip()
    if not key:
        raise SystemExit("DATABENTO_API_KEY_MISSING")

    client = db.Historical(key)
    datasets = client.metadata.list_datasets(start_date=START_DATE, end_date=END_DATE)
    dataset_range = client.metadata.get_dataset_range(DATASET)
    schemas = client.metadata.list_schemas(DATASET)
    symbology = client.symbology.resolve(
        dataset=DATASET,
        symbols=[SYMBOL],
        stype_in="raw_symbol",
        stype_out="instrument_id",
        start_date=START_DATE,
        end_date=END_DATE,
    )

    costs = {}
    for schema in SCHEMAS:
        item = {}
        item["cost_usd"] = float(
            client.metadata.get_cost(
                dataset=DATASET,
                start=START,
                end=END_EXCLUSIVE,
                symbols=[SYMBOL],
                schema=schema,
                stype_in="raw_symbol",
            )
        )
        item["under_max_cost_usd"] = item["cost_usd"] <= MAX_COST_USD
        costs[schema] = item

    result = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "status": "Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_PASS",
        "scope": "metadata_symbology_cost_preview_only",
        "api_key_included": False,
        "time_series_download_performed": False,
        "batch_submission_performed": False,
        "purchase_performed": False,
        "alpaca_action_performed": False,
        "paper_trade_performed": False,
        "live_trade_performed": False,
        "dataset": DATASET,
        "symbol": SYMBOL,
        "start_date": START_DATE,
        "end_date_inclusive": END_DATE,
        "end_exclusive": END_EXCLUSIVE,
        "max_cost_usd": MAX_COST_USD,
        "available_datasets": datasets,
        "dataset_range": dataset_range,
        "schemas": schemas,
        "symbology": symbology,
        "cost_preview": costs,
    }
    result["record_hash"] = digest(result)

    json_path = ARTIFACT_DIR / "q02_run11_setup_preflight_result.json"
    md_path = ARTIFACT_DIR / "q02_run11_setup_preflight_result.md"
    json_path.write_text(json.dumps(result, indent=2, default=str), encoding="utf-8")

    cost_lines = "\n".join(
        f"| `{schema}` | ${item['cost_usd']:.6f} | {str(item['under_max_cost_usd']).lower()} |"
        for schema, item in costs.items()
    )
    md_path.write_text(
        f"""# Q-02 Run 11 Protected Setup Preflight

Status: `{result['status']}`

Scope: metadata, symbology, and cost preview only.

No API key is included in this artifact. No time-series download, batch submission, purchase, Alpaca action, paper trade, or live trade was performed.

| Field | Value |
|---|---|
| Dataset | `{DATASET}` |
| Symbol | `{SYMBOL}` |
| Window | `{START_DATE}` through `{END_DATE}` inclusive |
| Cost gate | `${MAX_COST_USD:.2f}` |
| Record hash | `{result['record_hash']}` |

## Cost Preview

| Schema | Cost | Under gate |
|---|---:|---|
{cost_lines}
""",
        encoding="utf-8",
    )

    print(json.dumps({"status": result["status"], "record_hash": result["record_hash"], "api_key_included": False}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
