# Q-02 Run 11 Post-Setup Agent Task 002

Setup command:

```bash
bash Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_002/Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_002.sh
```

Agent-phase constraints:

- Remain credential-free and offline.
- Do not print, inspect, echo, log, persist, or expose `DATABENTO_API_KEY`.
- Do not assume `DATABENTO_API_KEY` is available during the agent phase.
- Read only sanitized artifacts under `Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_002/artifacts/`.
- No time-series methods, batch methods, download, purchase, capital action, order submission, paper trading, live trading, Alpaca action, or profitability inference is authorized.

Required post-setup validation:

```bash
python Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_002/q02_run11_postsetup_validator_002.py
```

Then summarize only:

- ARCX symbology receipt
- GLBX symbology receipt
- ARCX dataset-condition receipt
- GLBX dataset-condition receipt
- ARCX cost/count/billable-size receipt
- GLBX cost/count/billable-size receipt
- canonical preflight manifest
- execution report
- file inventory
- checksum manifest

