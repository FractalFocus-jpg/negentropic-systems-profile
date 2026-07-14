#!/usr/bin/env bash
set -euo pipefail
set +x
umask 077

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTIFACT_DIR="${PACKAGE_DIR}/artifacts"
RUNNER="${PACKAGE_DIR}/q02_run11_metadata_runner_003.py"
VALIDATOR="${PACKAGE_DIR}/q02_run11_postsetup_validator_003.py"
AST_AUDIT="${PACKAGE_DIR}/tools/q02_run11_ast_call_surface_audit_003.py"

EXPECTED_ANTECEDENT_ROOTS_SHA256="a9d1e1f705fef8520ce46585b86fed4dc5cfd2918bc8cb7e7c8cd7ad19188a9f"
EXPECTED_FROZEN_SCOPE_SHA256="787f3c413c3406030b15d42135a2fc39cde8c7ca9cee5fecc4c64f8d31089789"
EXPECTED_STATIC_AUDIT_SHA256="8598a7016908a32e515f16ee86585e6af99252c26f901d854bc7d7289a75aa4b"
EXPECTED_METADATA_RUNNER_SHA256="d880a0243895e075da4fe0f2db38a463f358a7fd468917fea92dbf09103d85fa"
EXPECTED_POSTSETUP_VALIDATOR_SHA256="6ba6898f67ef21f140176496d2ddc8825dc14ec682d6a9227feac34a2082da3a"
EXPECTED_AST_AUDIT_SHA256="c02d0e3db86662e1afc0f0f386847b62d194a2c4b1c4dbcbbdb79f8481c1cf29"
EXPECTED_PACKAGE_MANIFEST_SHA256="69ab112a057bc2e1c50d563a7728f7ee2a51dee18cafdd34ad214fddd1500e65"

hash_file() {
  env -u DATABENTO_API_KEY python - "$1" <<'PY'
import hashlib, pathlib, sys
print(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest())
PY
}

verify_hash() {
  local label="$1"
  local path="$2"
  local expected="$3"
  local actual
  actual="$(hash_file "$path")"
  if [[ "$actual" != "$expected" ]]; then
    printf '%s\n' "Q02_RUN11_003_SETUP_HASH_MISMATCH:${label}"
    exit 2
  fi
}

if [[ -z "${DATABENTO_API_KEY:-}" ]]; then
  printf '%s\n' "Q02_RUN11_003_SETUP_BLOCKED:DATABENTO_API_KEY_PRESENT=no"
  exit 2
fi

_DATABENTO_API_KEY_SETUP_ONLY="${DATABENTO_API_KEY}"
unset DATABENTO_API_KEY

verify_hash "antecedent_roots" "${PACKAGE_DIR}/frozen/q02_run11_antecedent_custody_roots_003.json" "${EXPECTED_ANTECEDENT_ROOTS_SHA256}"
verify_hash "frozen_scope" "${PACKAGE_DIR}/frozen/q02_run11_frozen_scope_003.json" "${EXPECTED_FROZEN_SCOPE_SHA256}"
verify_hash "static_audit" "${PACKAGE_DIR}/frozen/q02_run11_static_audit_003.json" "${EXPECTED_STATIC_AUDIT_SHA256}"
verify_hash "metadata_runner" "${RUNNER}" "${EXPECTED_METADATA_RUNNER_SHA256}"
verify_hash "postsetup_validator" "${VALIDATOR}" "${EXPECTED_POSTSETUP_VALIDATOR_SHA256}"
verify_hash "ast_audit" "${AST_AUDIT}" "${EXPECTED_AST_AUDIT_SHA256}"
verify_hash "package_manifest" "${PACKAGE_DIR}/frozen/q02_run11_package_manifest_003.json" "${EXPECTED_PACKAGE_MANIFEST_SHA256}"

env -u DATABENTO_API_KEY python - <<'PY'
import platform
if platform.python_implementation() != "CPython" or platform.python_version() != "3.12.13":
    raise SystemExit(f"Q02_RUN11_003_SETUP_BLOCKED:RUNTIME_MISMATCH:{platform.python_implementation()} {platform.python_version()}")
PY

env -u DATABENTO_API_KEY python "${AST_AUDIT}" "${RUNNER}" >/dev/null
env -u DATABENTO_API_KEY python -m pip install --quiet --disable-pip-version-check "databento==0.81.0"

DATABENTO_API_KEY="${_DATABENTO_API_KEY_SETUP_ONLY}" python "${RUNNER}"
unset DATABENTO_API_KEY
unset _DATABENTO_API_KEY_SETUP_ONLY

env -u DATABENTO_API_KEY python "${VALIDATOR}" >/dev/null

printf '%s\n' "Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_003_COMPLETE"
