#!/usr/bin/env python3
from __future__ import annotations
import ast, hashlib, json, os
from pathlib import Path
PACKAGE_DIR=Path(__file__).resolve().parent; FROZEN_DIR=PACKAGE_DIR/'frozen'; ARTIFACT_DIR=PACKAGE_DIR/'artifacts'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def load(p): return json.loads(p.read_text(encoding='utf-8'))
def validate_fixture_mode():
    assert 'DATABENTO_API_KEY' not in os.environ, 'validator must be credential-free'
    scope=load(FROZEN_DIR/'frozen_pilot_scope.json'); assert scope['pilot_id']=='Q02_RUN11_MBO_PIPELINE_PILOT_001'
    manifest=load(FROZEN_DIR/'package_manifest.json'); assert manifest['pilot_capital_authority'] is False and manifest['trading_authority'] is False
    roots=load(FROZEN_DIR/'antecedent_roots.json')
    assert roots['semantic_adjudication_receipt.json']=='f36aba424b7d87b6e5ebe66b9fe6408d9e24dcb1fa3a868190edc00659fe6128'
    return True
def validate_artifacts_if_present():
    cm=ARTIFACT_DIR/'checksum_manifest.json'
    if not cm.exists(): return 'NO_AUTHENTICATED_ARTIFACTS_PRESENT_FIXTURE_ONLY'
    for item in load(cm)['sha256']:
        assert sha(ARTIFACT_DIR/item['path'])==item['sha256'], item['path']
    return 'AUTHENTICATED_ARTIFACTS_VALID'
if __name__=='__main__':
    validate_fixture_mode(); print(validate_artifacts_if_present()); print('Q02_RUN11_PILOT_ESTIMATE_004_CREDENTIAL_FREE_VALIDATOR_PASS')
