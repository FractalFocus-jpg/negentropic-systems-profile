#!/usr/bin/env bash
set -euo pipefail
set +x
umask 077

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTIFACT_DIR="${PACKAGE_DIR}/artifacts"
RUNNER="${PACKAGE_DIR}/q02_run11_metadata_runner_002.py"

EXPECTED_QUALIFICATION_SHA256="8c960ca84a4ceca42dd2967f41d63fa5d21c88bc91b6dcb3f59e33873cb63dad"
EXPECTED_FROZEN_SCOPE_SHA256="eff01435e0ab054d947a929b62ffcd18ee3ea8c79a8459b5a3171d1185fd731d"
EXPECTED_STATIC_AUDIT_SHA256="968ca02d8f564e48f654fa9013933af3bbfcf0d0ef7befcdb64a357b26a5ed76"
EXPECTED_MARKET_INPUT_CONTRACT_SHA256="a4a53679bb1028345ff49b671d04de9ef9b46b865a1c1ef3a9db289af3105963"
EXPECTED_METADATA_RUNNER_SHA256="b9b0385922e390fb7584a0a955ea771c9afcbfa893d286a134be3ee2dd140139"
EXPECTED_PACKAGE_MANIFEST_SHA256="929b768b33fe44d6eb4a167f7a277c63f6824ef98251095a208df3159f57b345"

hash_file() {
  python - "$1" <<'PY'
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
    printf '%s\n' "Q02_RUN11_SETUP_HASH_MISMATCH:${label}"
    exit 2
  fi
}

if [[ -z "${DATABENTO_API_KEY:-}" ]]; then
  printf '%s\n' "Q02_RUN11_SETUP_BLOCKED:DATABENTO_API_KEY_PRESENT=no"
  exit 2
fi

verify_hash "qualification" "${PACKAGE_DIR}/frozen/q02_run11_qualification_002.json" "${EXPECTED_QUALIFICATION_SHA256}"
verify_hash "frozen_scope" "${PACKAGE_DIR}/frozen/q02_run11_frozen_scope_002.json" "${EXPECTED_FROZEN_SCOPE_SHA256}"
verify_hash "static_audit" "${PACKAGE_DIR}/frozen/q02_run11_static_audit_002.json" "${EXPECTED_STATIC_AUDIT_SHA256}"
verify_hash "market_input_contract" "${PACKAGE_DIR}/frozen/q02_run11_market_input_contract_002.json" "${EXPECTED_MARKET_INPUT_CONTRACT_SHA256}"
verify_hash "metadata_runner" "${RUNNER}" "${EXPECTED_METADATA_RUNNER_SHA256}"
verify_hash "package_manifest" "${PACKAGE_DIR}/frozen/q02_run11_package_manifest_002.json" "${EXPECTED_PACKAGE_MANIFEST_SHA256}"

python - <<'PY'
import platform, sys
if platform.python_implementation() != "CPython" or platform.python_version() != "3.12.13":
    raise SystemExit(f"Q02_RUN11_SETUP_BLOCKED:RUNTIME_MISMATCH:{platform.python_implementation()} {platform.python_version()}")
PY

python -m pip install --quiet --disable-pip-version-check "databento==0.81.0"
python "${RUNNER}"
unset DATABENTO_API_KEY

python - "${ARTIFACT_DIR}" <<'PY'
import hashlib, json, pathlib, sys
artifact_dir = pathlib.Path(sys.argv[1])
expected = sorted([
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
])
actual = sorted(p.name for p in artifact_dir.iterdir() if p.is_file())
if actual != expected:
    raise SystemExit(f"Q02_RUN11_OUTPUT_SET_MISMATCH:{actual}")
checksums = json.loads((artifact_dir / "checksum_manifest.json").read_text())["sha256"]
for name in expected:
    if name == "checksum_manifest.json":
        continue
    digest = hashlib.sha256((artifact_dir / name).read_bytes()).hexdigest()
    if checksums.get(name) != digest:
        raise SystemExit(f"Q02_RUN11_OUTPUT_HASH_MISMATCH:{name}")
report = json.loads((artifact_dir / "execution_report.json").read_text())
if report.get("capital_action_performed") is not False:
    raise SystemExit("Q02_RUN11_CAPITAL_ACTION_FLAG_INVALID")
PY

printf '%s\n' "Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_002_COMPLETE"
