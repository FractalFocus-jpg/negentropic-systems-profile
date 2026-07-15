#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import os
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any

PACKAGE_DIR = Path(__file__).resolve().parent
FROZEN_DIR = PACKAGE_DIR / 'frozen'
ARTIFACT_DIR = PACKAGE_DIR / 'artifacts'
EXPECTED_ARTIFACTS = [
    'arcx_estimate_receipt.json',
    'glbx_estimate_receipt.json',
    'canonical_manifest.json',
    'execution_report.json',
    'file_inventory.json',
    'checksum_manifest.json',
]
EXPECTED_ORDER = [
    'ARCX.metadata.get_cost',
    'ARCX.metadata.get_record_count',
    'ARCX.metadata.get_billable_size',
    'GLBX.metadata.get_cost',
    'GLBX.metadata.get_record_count',
    'GLBX.metadata.get_billable_size',
]
AUTHORITY_FLAGS = [
    'estimate_is_authority',
    'pilot_batch_authority',
    'pilot_download_authority',
    'pilot_purchase_authority',
    'pilot_capital_authority',
    'trading_authority',
    'max_cost_usd_constructed',
]


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load(path: Path) -> Any:
    return json.loads(path.read_text(encoding='utf-8'))


def expected_request(scope: dict[str, Any], venue: str) -> dict[str, Any]:
    child = scope['children'][venue]
    return {
        'dataset': child['dataset'],
        'start': child['start_inclusive'],
        'end': child['end_exclusive'],
        'symbols': child['symbols'],
        'schema': child['schema'],
        'stype_in': scope['stype_in'],
    }


def validate_fixture_mode() -> bool:
    assert 'DATABENTO_API_KEY' not in os.environ, 'validator must be credential-free'
    scope = load(FROZEN_DIR / 'frozen_pilot_scope.json')
    assert scope['pilot_id'] == 'Q02_RUN11_MBO_PIPELINE_PILOT_001'
    manifest = load(FROZEN_DIR / 'package_manifest.json')
    assert manifest['pilot_capital_authority'] is False and manifest['trading_authority'] is False
    roots = load(FROZEN_DIR / 'antecedent_roots.json')
    assert roots['semantic_adjudication_receipt.json'] == 'f36aba424b7d87b6e5ebe66b9fe6408d9e24dcb1fa3a868190edc00659fe6128'
    return True


def validate_receipt(scope: dict[str, Any], venue: str, receipt: dict[str, Any]) -> list[str]:
    assert receipt['venue'] == venue
    assert receipt['request'] == expected_request(scope, venue)
    assert receipt['authenticated_invocations'] == [f'{venue}.metadata.get_cost', f'{venue}.metadata.get_record_count', f'{venue}.metadata.get_billable_size']
    responses = receipt['responses']
    assert isinstance(responses['metadata.get_cost'], str) and responses['metadata.get_cost'] == str(responses['metadata.get_cost'])
    assert isinstance(responses['metadata.get_record_count'], int) and not isinstance(responses['metadata.get_record_count'], bool)
    assert isinstance(responses['metadata.get_billable_size'], int) and not isinstance(responses['metadata.get_billable_size'], bool)
    observed = datetime.fromisoformat(receipt['observation_timestamp_utc'])
    expires = datetime.fromisoformat(receipt['expires_at_utc'])
    assert expires == observed + timedelta(seconds=300)
    assert receipt['estimate_max_age_seconds'] == 300
    for flag in AUTHORITY_FLAGS:
        assert receipt[flag] is False, flag
    text = json.dumps(receipt, sort_keys=True).lower()
    assert 'databento_api_key' not in text and 'api_key' not in text and 'secret' not in text and 'credential' not in text
    return receipt['authenticated_invocations']


def validate_artifacts_if_present() -> str:
    if not ARTIFACT_DIR.exists():
        return 'NO_AUTHENTICATED_ARTIFACTS_PRESENT_FIXTURE_ONLY'
    actual = sorted(path.name for path in ARTIFACT_DIR.iterdir() if path.is_file())
    assert actual == sorted(EXPECTED_ARTIFACTS), actual
    scope = load(FROZEN_DIR / 'frozen_pilot_scope.json')
    arcx = load(ARTIFACT_DIR / 'arcx_estimate_receipt.json')
    glbx = load(ARTIFACT_DIR / 'glbx_estimate_receipt.json')
    order = validate_receipt(scope, 'ARCX', arcx) + validate_receipt(scope, 'GLBX', glbx)
    assert order == EXPECTED_ORDER
    manifest = load(ARTIFACT_DIR / 'canonical_manifest.json')
    assert manifest['allowed_authenticated_invocations'] == EXPECTED_ORDER
    assert manifest['observation_order'] == EXPECTED_ORDER
    assert manifest['negative_authority'] == {'batch_submission': False, 'download': False, 'purchase': False, 'capital_authority': False, 'trading_authority': False}
    report = load(ARTIFACT_DIR / 'execution_report.json')
    assert report['status'] == 'Q02_RUN11_PILOT_ESTIMATE_AUTHENTICATED_METADATA_EXECUTED_RECEIPTS_PENDING_OFFLINE_VALIDATION_CAPITAL_AUTHORITY_FALSE'
    inventory = load(ARTIFACT_DIR / 'file_inventory.json')
    assert [item['path'] for item in inventory['files']] == EXPECTED_ARTIFACTS[:4]
    for item in inventory['files']:
        assert isinstance(item['bytes'], int) and item['bytes'] == (ARTIFACT_DIR / item['path']).stat().st_size
    checksum = load(ARTIFACT_DIR / 'checksum_manifest.json')
    assert [item['path'] for item in checksum['sha256']] == EXPECTED_ARTIFACTS[:5]
    for item in checksum['sha256']:
        assert sha(ARTIFACT_DIR / item['path']) == item['sha256'], item['path']
    return 'AUTHENTICATED_ARTIFACTS_VALID'


if __name__ == '__main__':
    validate_fixture_mode()
    print(validate_artifacts_if_present())
    print('Q02_RUN11_PILOT_ESTIMATE_004_CREDENTIAL_FREE_VALIDATOR_PASS')
