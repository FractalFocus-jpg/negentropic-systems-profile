#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTIFACT_DIR="${PACKAGE_DIR}/artifacts"
mkdir -p "${ARTIFACT_DIR}"

if [[ -z "${DATABENTO_API_KEY:-}" ]]; then
  printf '%s\n' "DATABENTO_API_KEY_PRESENT=no" > "${ARTIFACT_DIR}/q02_run11_setup_preflight_status.txt"
  printf '%s\n' "Q02_RUN11_SETUP_PREFLIGHT_BLOCKED_MISSING_DATABENTO_API_KEY"
  exit 2
fi

printf '%s\n' "DATABENTO_API_KEY_PRESENT=yes" > "${ARTIFACT_DIR}/q02_run11_setup_preflight_status.txt"

python -m pip install --quiet --disable-pip-version-check "databento>=0.81.0"
python "${PACKAGE_DIR}/q02_run11_protected_setup_preflight.py"

printf '%s\n' "Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_COMPLETE"
