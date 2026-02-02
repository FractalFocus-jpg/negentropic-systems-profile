"""Agent Service (minimal)

Purpose:
- Provide a real HTTP listener per agent (ports 3001-3007) with /health
- Allow triggering the agent's existing PowerShell scripts via /run

This is not "full autonomy" yet; it's the reliable online spine so the mesh is actually running.
"""

import os
import json
import subprocess
from datetime import datetime

from flask import Flask, jsonify, request

AGENT_NAME = os.environ.get("AGENT_NAME", "agent")
PORT = int(os.environ.get("PORT", "3000"))
REPO_ROOT = os.environ.get("REPO_ROOT", r"C:\Users\alexl\Desktop\tapestry-codex-starter")
VAULT_ROOT = os.environ.get("VAULT_ROOT", r"C:\Users\alexl\the living tapestry")

# Map agent -> script(s)
SCRIPT_MAP = {
    "sentinel": [r"scripts\\agents\\sentinel.ps1"],
    "weaver": [r"scripts\\agents\\weaver_sync.ps1"],
    "scribe": [r"scripts\\agents\\scribe.ps1"],
    "hermes": [r"scripts\\agents\\hermes.ps1"],
    "ledger": [r"scripts\\agents\\nightly.ps1"],
    "janus": [],
    "choir": [],
}

app = Flask(__name__)


def now_iso():
    return datetime.now().astimezone().isoformat(timespec="seconds")


def run_powershell(ps1_rel: str):
    ps1 = os.path.join(REPO_ROOT, ps1_rel)
    if not os.path.exists(ps1):
        return {"ok": False, "error": f"missing script: {ps1}"}

    cmd = [
        "powershell.exe",
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        ps1,
    ]

    try:
        p = subprocess.run(cmd, cwd=REPO_ROOT, capture_output=True, text=True, timeout=300)
        return {
            "ok": p.returncode == 0,
            "code": p.returncode,
            "stdout": (p.stdout or "")[-8000:],
            "stderr": (p.stderr or "")[-8000:],
        }
    except subprocess.TimeoutExpired:
        return {"ok": False, "error": "timeout"}


@app.get("/health")
def health():
    return jsonify(
        {
            "agent": AGENT_NAME,
            "port": PORT,
            "timestamp": now_iso(),
            "repo_root": REPO_ROOT,
            "vault_root": VAULT_ROOT,
            "scripts": SCRIPT_MAP.get(AGENT_NAME.lower(), []),
        }
    )


@app.post("/run")
def run():
    # Optional: allow specifying which script, else run default list
    body = request.get_json(silent=True) or {}
    scripts = body.get("scripts")

    if scripts:
        if not isinstance(scripts, list):
            return jsonify({"ok": False, "error": "scripts must be a list"}), 400
        to_run = scripts
    else:
        to_run = SCRIPT_MAP.get(AGENT_NAME.lower(), [])

    results = []
    for ps1_rel in to_run:
        results.append({"script": ps1_rel, "result": run_powershell(ps1_rel)})

    return jsonify({"ok": True, "agent": AGENT_NAME, "timestamp": now_iso(), "results": results})


if __name__ == "__main__":
    print(f"[{AGENT_NAME}] starting on http://127.0.0.1:{PORT}")
    app.run(host="127.0.0.1", port=PORT)
