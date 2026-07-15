# Q02 Run 11 Authenticated Preflight Semantic Adjudication 001

## Controls

- NETWORK_ACCESS = FALSE
- DATABENTO_CALLS = FALSE
- SETUP_LAUNCHER_RERUN = FALSE
- BATCH_SUBMISSION = FALSE
- DOWNLOAD = FALSE
- PURCHASE = FALSE
- CAPITAL_AUTHORITY = FALSE
- TRADING_AUTHORITY = FALSE
- PROTECTED_SETUP_EXECUTION = SUCCEEDED
- AGENT_PHASE_LAUNCHER_RERUN = BLOCKED_DATABENTO_API_KEY_ABSENT_AS_EXPECTED

## Input artifact checksum verification

Recomputed SHA-256 for every artifact named by `Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_003/artifacts/checksum_manifest.json`: PASS. The checksum manifest file itself was also hashed: `6e8bbf8a39b1f419af007934fca34cca9c500c1a22edefaaeb812f542747f64a`.

## Numerical authority

The sole numerical authority is:

- `Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_003/artifacts/arcx_cost_count_billable_size_receipt.json`
- `Q02_RUN11_CODEX_PROTECTED_SETUP_PREFLIGHT_003/artifacts/glbx_cost_count_billable_size_receipt.json`

## Symbology adjudication

- ARCX: status = 0; not_found = []; partial = [].
- GLBX: status = 0; not_found = []. ESH0 and ESM0 mappings are preserved exactly.
- ESH0 ends on 2020-04-05 while the request extends through 2020-04-16 exclusive.
- ESH0_FULL_INTERVAL_COVERAGE = FALSE.
- ESH0_ESM0_CONTRACT_ROLE = PENDING_OPERATOR_LOCK.
- PARTIAL_REQUIRES_CONTRACT_ROLE_ADJUDICATION = TRUE.
- No roll-switch rule was inferred.

## Degraded dates

- ARCX.PILLAR: 2020-04-06.
- GLBX.MDP3: 2020-02-27, 2020-02-28.
- pending = []; missing = [].
- DEGRADED_DATES_ALLOWED_FOR_PILOT = FALSE.
- DEGRADED_DATES_ALLOWED_FOR_PRIMARY_INFERENCE = FALSE.
- DEGRADED_DATES_REQUIRE_EXPLICIT_WAIVER = TRUE.

## Full-scope estimates and gate

- ARCX_COST_USD = "27.614303505421"; ARCX_RECORD_COUNT = 441229652; ARCX_BILLABLE_BYTES = 24708860512.
- GLBX_COST_USD = "95.778743939102"; GLBX_RECORD_COUNT = 1020254397; GLBX_BILLABLE_BYTES = 57134246232.
- TOTAL_ESTIMATED_COST_USD = "123.393047444523"; TOTAL_RECORD_COUNT = 1461484049; TOTAL_BILLABLE_BYTES = 81843106744.
- TOTAL_BILLABLE_GIB = 76.22233288735151.
- THREE_COPY_CUSTODY_GIB = 228.66699866205454.
- PREVIOUS_50_GB_FULL_SCOPE_GATE = FAIL.
- WORKING_SPACE_REQUIREMENT = UNVALIDATED_PENDING_REAL_MBO_PILOT.

## Clean pilot draft

The smallest deterministic clean pilot is limited to non-degraded dates and is for pipeline qualification only. It tests DBN decoding, snapshot initialization, both adapters, source-to-derived lineage, Run 11 bucket conservation, primary/shadow agreement, and restart determinism. PILOT_ESTIMATE_REFRESH_REQUIRED = TRUE.

## Terminal verdict

Q02_RUN11_AUTHENTICATED_METADATA_PREFLIGHT_STRUCTURAL_PASS_ESH0_CONTRACT_ROLE_PENDING_DEGRADED_DATES_IDENTIFIED_CLEAN_PILOT_DRAFTED_PILOT_ESTIMATE_REFRESH_REQUIRED_CAPITAL_AUTHORITY_FALSE
