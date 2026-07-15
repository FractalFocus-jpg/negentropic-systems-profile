#!/usr/bin/env python3
from __future__ import annotations
import hashlib, json, os, platform
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
PACKAGE_DIR=Path(__file__).resolve().parent; ARTIFACT_DIR=PACKAGE_DIR/'artifacts'; FROZEN_DIR=PACKAGE_DIR/'frozen'
ALLOWED=[('ARCX','metadata.get_cost'),('ARCX','metadata.get_record_count'),('ARCX','metadata.get_billable_size'),('GLBX','metadata.get_cost'),('GLBX','metadata.get_record_count'),('GLBX','metadata.get_billable_size')]

def write_json(p:Path,o:Any): p.write_text(json.dumps(o,indent=2,sort_keys=True,default=str)+'\n',encoding='utf-8')
def sha(p:Path): return hashlib.sha256(p.read_bytes()).hexdigest()
def request(scope, venue):
    c=scope['children'][venue]
    return {'dataset':c['dataset'],'symbols':c['symbols'],'schema':c['schema'],'start':c['start_inclusive'],'end':c['end_exclusive'],'stype_in':scope['stype_in'],'stype_out':scope['stype_out'],'encoding':scope['encoding'],'compression':scope['compression'],'split_duration':scope['split_duration'],'split_size':scope['split_size_bytes'],'split_symbols':c['split_symbols']}
def main():
    if platform.python_implementation()!='CPython' or platform.python_version()!='3.12.13': raise SystemExit('RUNTIME_MISMATCH_REQUIRES_CPYTHON_3.12.13')
    if not os.environ.get('DATABENTO_API_KEY'): raise SystemExit('DATABENTO_API_KEY_REQUIRED_FOR_AUDITED_RUNNER_ONLY')
    import databento as db
    if getattr(db,'__version__',None)!='0.81.0': raise SystemExit('DATABENTO_VERSION_MISMATCH')
    scope=json.loads((FROZEN_DIR/'frozen_pilot_scope.json').read_text()); client=db.Historical(os.environ['DATABENTO_API_KEY'])
    ARTIFACT_DIR.mkdir(exist_ok=True)
    receipts={}
    for venue in ('ARCX','GLBX'):
        req=request(scope,venue); meta=client.metadata
        responses={'metadata.get_cost':meta.get_cost(**req),'metadata.get_record_count':meta.get_record_count(**req),'metadata.get_billable_size':meta.get_billable_size(**req)}
        receipt={'venue':venue,'request':req,'authenticated_invocations':[f'{venue}.{k}' for k in responses],'responses':responses,'created_at_utc':datetime.now(timezone.utc).isoformat(),'estimate_max_age_seconds':300,'estimate_is_authority':False,'pilot_batch_authority':False,'pilot_download_authority':False,'pilot_purchase_authority':False,'pilot_capital_authority':False,'trading_authority':False,'max_cost_usd_constructed':False}
        out=ARTIFACT_DIR/f'{venue.lower()}_estimate_receipt.json'; write_json(out,receipt); receipts[venue]=out.name
    manifest={'package_id':'Q02_RUN11_CODEX_PROTECTED_PILOT_ESTIMATE_004','pilot_id':scope['pilot_id'],'receipts':receipts,'allowed_authenticated_invocations':[f'{v}.{m}' for v,m in ALLOWED],'negative_authority':{'batch_submission':False,'download':False,'purchase':False,'capital_authority':False,'trading_authority':False}}
    write_json(ARTIFACT_DIR/'canonical_manifest.json',manifest)
    write_json(ARTIFACT_DIR/'execution_report.json',{'status':'ESTIMATE_RECEIPTS_CREATED_STOPPED_NO_BATCH_NO_DOWNLOAD_NO_PURCHASE','completed_at_utc':datetime.now(timezone.utc).isoformat()})
    files=sorted([p for p in ARTIFACT_DIR.iterdir() if p.is_file() and p.name not in ('file_inventory.json','checksum_manifest.json')])
    write_json(ARTIFACT_DIR/'file_inventory.json',{'files':[{'path':p.name,'bytes':p.stat().st_size} for p in files]})
    files.append(ARTIFACT_DIR/'file_inventory.json')
    write_json(ARTIFACT_DIR/'checksum_manifest.json',{'sha256':[{'path':p.name,'sha256':sha(p)} for p in files]})
if __name__=='__main__': main()
