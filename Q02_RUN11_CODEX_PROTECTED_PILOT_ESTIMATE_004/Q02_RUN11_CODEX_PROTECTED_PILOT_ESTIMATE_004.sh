#!/usr/bin/env bash
set -euo pipefail
set +x
umask 077

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="${PACKAGE_DIR}/pilot_metadata_runner_004.py"
VALIDATOR="${PACKAGE_DIR}/credential_free_validator_004.py"
AST_AUDIT="${PACKAGE_DIR}/tools/ast_call_surface_audit_004.py"
CHECKSUM_MANIFEST="${PACKAGE_DIR}/checksum_manifest.json"
EXPECTED_CHECKSUM_MANIFEST_SHA256="008ae8586239aeb39b5f26f194a399a8a3464f56fd3d8567ae5fd7b6640de4c3"

cleanup_secret() {
  unset DATABENTO_API_KEY _SECRET || true
}
trap cleanup_secret EXIT

if [[ -z "${DATABENTO_API_KEY:-}" ]]; then
  echo "Q02_RUN11_PILOT_ESTIMATE_004_BLOCKED:DATABENTO_API_KEY_REQUIRED"
  exit 2
fi

_SECRET="${DATABENTO_API_KEY}"
unset DATABENTO_API_KEY

env -u DATABENTO_API_KEY python - "$PACKAGE_DIR" "$EXPECTED_CHECKSUM_MANIFEST_SHA256" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

package = Path(sys.argv[1])
expected_manifest = sys.argv[2]
manifest_path = package / "checksum_manifest.json"
actual_manifest = hashlib.sha256(manifest_path.read_bytes()).hexdigest()
if actual_manifest != expected_manifest:
    raise SystemExit(
        f"HASH_GATE_MANIFEST_MISMATCH:{actual_manifest}:{expected_manifest}"
    )

manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
required = {
    "Q02_RUN11_POSTSETUP_AGENT_TASK_004.md",
    "credential_free_validator_004.py",
    "frozen/antecedent_roots.json",
    "frozen/frozen_pilot_scope.json",
    "frozen/package_manifest.json",
    "frozen/static_audit.json",
    "pilot_metadata_runner_004.py",
    "tools/ast_call_surface_audit_004.py",
    "file_inventory.json",
}
seen = {item["path"]: item["sha256"] for item in manifest["sha256"]}
if set(seen) != required:
    raise SystemExit(
        f"HASH_GATE_FILE_SET_MISMATCH:{sorted(set(seen))}:{sorted(required)}"
    )

for rel in sorted(required):
    path = package / rel
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual != seen[rel]:
        raise SystemExit(f"HASH_GATE_MISMATCH:{rel}:{actual}:{seen[rel]}")

print("Q02_RUN11_PACKAGE_HASH_GATES_PASS")
PY

env -u DATABENTO_API_KEY python - <<'PY'
import platform
if (
    platform.python_implementation() != "CPython"
    or platform.python_version() != "3.12.13"
):
    raise SystemExit(
        "RUNTIME_MISMATCH_REQUIRES_CPYTHON_3.12.13:"
        f"{platform.python_implementation()} {platform.python_version()}"
    )
PY

env -u DATABENTO_API_KEY python -m py_compile "$RUNNER" "$VALIDATOR" "$AST_AUDIT"
env -u DATABENTO_API_KEY python -m pip install \
  --quiet --disable-pip-version-check "databento==0.81.0"

env -u DATABENTO_API_KEY python - <<'PY'
import databento as db
if getattr(db, "__version__", None) != "0.81.0":
    raise SystemExit(
        f"DATABENTO_VERSION_MISMATCH:{getattr(db, '__version__', None)}"
    )
PY

env -u DATABENTO_API_KEY python "$AST_AUDIT" "$RUNNER"

DATABENTO_API_KEY="${_SECRET}" python "$RUNNER"
unset DATABENTO_API_KEY _SECRET

env -u DATABENTO_API_KEY python "$VALIDATOR"

echo "Q02_RUN11_PILOT_ESTIMATE_AUTHENTICATED_METADATA_EXECUTED_OFFLINE_VALIDATION_PASS_CAPITAL_AUTHORITY_FALSE"
echo "NO_BATCH_DOWNLOAD_PURCHASE_CAPITAL_OR_TRADING_ACTION"
