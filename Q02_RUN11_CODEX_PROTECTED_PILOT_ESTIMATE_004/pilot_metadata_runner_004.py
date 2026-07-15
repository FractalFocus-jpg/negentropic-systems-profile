#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import os
import platform
import shutil
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from pathlib import Path
from typing import Any

PACKAGE_DIR = Path(__file__).resolve().parent
ARTIFACT_DIR = PACKAGE_DIR / 'artifacts'
FROZEN_DIR = PACKAGE_DIR / 'frozen'
ALLOWED = [
    ('ARCX', 'metadata.get_cost'),
    ('ARCX', 'metadata.get_record_count'),
    ('ARCX', 'metadata.get_billable_size'),
    ('GLBX', 'metadata.get_cost'),
    ('GLBX', 'metadata.get_record_count'),
    ('GLBX', 'metadata.get_billable_size'),
]


def write_json(path: Path, obj: Any) -> None:
    path.write_text(json.dumps(obj, indent=2, sort_keys=True, default=str) + '\n', encoding='utf-8')


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def request(scope: dict[str, Any], venue: str) -> dict[str, Any]:
    child = scope['children'][venue]
    return {
        'dataset': child['dataset'],
        'start': child['start_inclusive'],
        'end': child['end_exclusive'],
        'symbols': child['symbols'],
        'schema': child['schema'],
        'stype_in': scope['stype_in'],
    }


def lossless_cost(value: Any) -> str:
    if isinstance(value, Decimal):
        return format(value, 'f')
    return str(value)


def require_int(value: Any, name: str) -> int:
    if isinstance(value, bool) or not isinstance(value, int):
        raise SystemExit(f'{name}_MUST_BE_INTEGER')
    return value


def main() -> None:
    if platform.python_implementation() != 'CPython' or platform.python_version() != '3.12.13':
        raise SystemExit('RUNTIME_MISMATCH_REQUIRES_CPYTHON_3.12.13')
    if not os.environ.get('DATABENTO_API_KEY'):
        raise SystemExit('DATABENTO_API_KEY_REQUIRED_FOR_AUDITED_RUNNER_ONLY')

    import databento as db

    if getattr(db, '__version__', None) != '0.81.0':
        raise SystemExit('DATABENTO_VERSION_MISMATCH')

    scope = json.loads((FROZEN_DIR / 'frozen_pilot_scope.json').read_text(encoding='utf-8'))
    client = db.Historical(os.environ['DATABENTO_API_KEY'])

    tmp_dir = PACKAGE_DIR / '.artifacts.tmp'
    if tmp_dir.exists():
        shutil.rmtree(tmp_dir)
    tmp_dir.mkdir(mode=0o700)

    receipts: dict[str, str] = {}
    observation_order: list[str] = []
    for venue in ('ARCX', 'GLBX'):
        req = request(scope, venue)
        created = datetime.now(timezone.utc)
        expires = created + timedelta(seconds=300)
        responses = {
            'metadata.get_cost': lossless_cost(client.metadata.get_cost(dataset=req['dataset'], start=req['start'], end=req['end'], symbols=req['symbols'], schema=req['schema'], stype_in=req['stype_in'])),
            'metadata.get_record_count': require_int(client.metadata.get_record_count(dataset=req['dataset'], start=req['start'], end=req['end'], symbols=req['symbols'], schema=req['schema'], stype_in=req['stype_in']), 'record_count'),
            'metadata.get_billable_size': require_int(client.metadata.get_billable_size(dataset=req['dataset'], start=req['start'], end=req['end'], symbols=req['symbols'], schema=req['schema'], stype_in=req['stype_in']), 'billable_size'),
        }
        invocation_order = [f'{venue}.{method}' for method in responses]
        observation_order.extend(invocation_order)
        receipt = {
            'venue': venue,
            'request': req,
            'authenticated_invocations': invocation_order,
            'responses': responses,
            'observation_timestamp_utc': created.isoformat(),
            'expires_at_utc': expires.isoformat(),
            'estimate_max_age_seconds': 300,
            'estimate_is_authority': False,
            'pilot_batch_authority': False,
            'pilot_download_authority': False,
            'pilot_purchase_authority': False,
            'pilot_capital_authority': False,
            'trading_authority': False,
            'max_cost_usd_constructed': False,
        }
        out = tmp_dir / f'{venue.lower()}_estimate_receipt.json'
        write_json(out, receipt)
        receipts[venue] = out.name

    manifest = {
        'package_id': 'Q02_RUN11_CODEX_PROTECTED_PILOT_ESTIMATE_004',
        'pilot_id': scope['pilot_id'],
        'receipts': receipts,
        'allowed_authenticated_invocations': [f'{v}.{m}' for v, m in ALLOWED],
        'observation_order': observation_order,
        'negative_authority': {
            'batch_submission': False,
            'download': False,
            'purchase': False,
            'capital_authority': False,
            'trading_authority': False,
        },
    }
    write_json(tmp_dir / 'canonical_manifest.json', manifest)
    write_json(tmp_dir / 'execution_report.json', {
        'status': 'Q02_RUN11_PILOT_ESTIMATE_AUTHENTICATED_METADATA_EXECUTED_RECEIPTS_PENDING_OFFLINE_VALIDATION_CAPITAL_AUTHORITY_FALSE',
        'completed_at_utc': datetime.now(timezone.utc).isoformat(),
    })
    expected = [
        'arcx_estimate_receipt.json',
        'glbx_estimate_receipt.json',
        'canonical_manifest.json',
        'execution_report.json',
    ]
    write_json(tmp_dir / 'file_inventory.json', {'files': [{'path': name, 'bytes': (tmp_dir / name).stat().st_size} for name in expected]})
    expected.append('file_inventory.json')
    write_json(tmp_dir / 'checksum_manifest.json', {'sha256': [{'path': name, 'sha256': sha(tmp_dir / name)} for name in expected]})

    if ARTIFACT_DIR.exists():
        shutil.rmtree(ARTIFACT_DIR)
    tmp_dir.replace(ARTIFACT_DIR)


if __name__ == '__main__':
    main()
