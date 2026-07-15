#!/usr/bin/env bash
set -euo pipefail
set +x
umask 077
PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="${PACKAGE_DIR}/pilot_metadata_runner_004.py"
VALIDATOR="${PACKAGE_DIR}/credential_free_validator_004.py"
AST_AUDIT="${PACKAGE_DIR}/tools/ast_call_surface_audit_004.py"
if [[ -z "${DATABENTO_API_KEY:-}" ]]; then echo "Q02_RUN11_PILOT_ESTIMATE_004_BLOCKED:DATABENTO_API_KEY_REQUIRED"; exit 2; fi
_SECRET="${DATABENTO_API_KEY}"; unset DATABENTO_API_KEY
python_hash_gate() {
  env -u DATABENTO_API_KEY python - "$PACKAGE_DIR" <<'PY'
import hashlib, json, sys
from pathlib import Path
package = Path(sys.argv[1])
manifest = json.loads((package / 'checksum_manifest.json').read_text(encoding='utf-8'))
required = {
    'pilot_metadata_runner_004.py',
    'credential_free_validator_004.py',
    'tools/ast_call_surface_audit_004.py',
    'frozen/antecedent_roots.json',
    'frozen/frozen_pilot_scope.json',
    'frozen/package_manifest.json',
    'frozen/static_audit.json',
    'Q02_RUN11_POSTSETUP_AGENT_TASK_004.md',
    'file_inventory.json',
    'checksum_manifest.json',
}
seen = {item['path']: item['sha256'] for item in manifest['sha256']}
missing = sorted(required - set(seen))
if missing:
    raise SystemExit(f'HASH_GATE_MISSING:{missing}')
for rel in sorted(required - {'checksum_manifest.json'}):
    actual = hashlib.sha256((package / rel).read_bytes()).hexdigest()
    if actual != seen[rel]:
        raise SystemExit(f'HASH_GATE_MISMATCH:{rel}:{actual}:{seen[rel]}')
print('Q02_RUN11_PACKAGE_HASH_GATES_PASS')
PY
}
python_hash_gate
env -u DATABENTO_API_KEY python - <<'PY'
import platform
if platform.python_implementation() != 'CPython' or platform.python_version() != '3.12.13':
    raise SystemExit(f"RUNTIME_MISMATCH_REQUIRES_CPYTHON_3.12.13:{platform.python_implementation()} {platform.python_version()}")
PY
env -u DATABENTO_API_KEY python "${AST_AUDIT}" "${RUNNER}"
DATABENTO_API_KEY="${_SECRET}" python "${RUNNER}"
unset DATABENTO_API_KEY _SECRET
env -u DATABENTO_API_KEY python "${VALIDATOR}"
echo "Q02_RUN11_PILOT_ESTIMATE_AUTHENTICATED_METADATA_EXECUTED_RECEIPTS_PENDING_OFFLINE_VALIDATION_CAPITAL_AUTHORITY_FALSE"
echo "NO_EXTERNAL_ACTION_"
echo "CAPITAL_AUTHORITY_FALSE"
