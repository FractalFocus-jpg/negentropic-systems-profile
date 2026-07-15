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
env -u DATABENTO_API_KEY python - <<'PY'
import platform
if platform.python_implementation() != 'CPython' or platform.python_version() != '3.12.13':
    raise SystemExit(f"RUNTIME_MISMATCH_REQUIRES_CPYTHON_3.12.13:{platform.python_implementation()} {platform.python_version()}")
PY
env -u DATABENTO_API_KEY python "${AST_AUDIT}" "${RUNNER}"
env -u DATABENTO_API_KEY python -m pip install --quiet --disable-pip-version-check 'databento==0.81.0'
DATABENTO_API_KEY="${_SECRET}" python "${RUNNER}"
unset DATABENTO_API_KEY _SECRET
env -u DATABENTO_API_KEY python "${VALIDATOR}"
echo "Q02_RUN11_CONTRACT_ROLE_AND_PILOT_LOCK_PASS_"
echo "PILOT_ESTIMATE_PACKAGE_004_READY_"
echo "NO_EXTERNAL_ACTION_"
echo "CAPITAL_AUTHORITY_FALSE"
