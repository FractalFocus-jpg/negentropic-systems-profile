# Q-02 Run 11 Post-Setup Agent Task

The setup phase should have run:

```bash
bash Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_001/Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_001.sh
```

Agent-phase constraints:

- Do not print, inspect, echo, log, persist, or expose `DATABENTO_API_KEY`.
- Do not assume `DATABENTO_API_KEY` is available during the agent phase; Codex protected secrets are setup-phase only.
- Read only sanitized setup artifacts under `Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_001/artifacts/`.
- No time-series download, batch submission, purchase, Alpaca action, paper trade, or live trade is authorized by this post-setup task.
- Agent internet access may remain off.

Required agent checks:

1. Confirm `Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_001/artifacts/q02_run11_setup_preflight_result.json` exists.
2. Confirm its status is `Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_PASS`.
3. Confirm `api_key_included` is `false`.
4. Summarize the metadata/symbology/cost preview.
5. Stop before any data download or trading action unless a new explicit authorization is provided.
