# Living Tapestry / UOS — Repository Governance

This file is the current repository-level governance surface for evidence-carrying research, formal kernels, benchmarks, and external-action artifacts.

## Precedence

When legacy README language, historical experiment prose, or older branch metadata conflicts with this file, **preserve the historical artifact but use this governance file for current interpretation and new work**. Historical content is not silently rewritten into present truth.

## Core laws

- No Return, No Agency.
- No Proof, No Authority.
- Capability ≠ authority.
- Signal ≠ proof ≠ authority ≠ closure.
- No preserved first terminal, no claim-changing experiment.
- No external independence, no independent superiority.
- Repair successors add to history; they do not rewrite predecessors.

## Return / stability notation

Canonical scalar research notation:

`κ = β D / ρ`

where `β` is amplification, `D` is disturbance/drift/disorder, and `ρ` is return/repair authority.

`κ < 1` is **not** treated as a universal bifurcation theorem for arbitrary systems. It is a conditional/model-specific certificate whose assumptions must be stated. Coupled, nonnormal, switched, continuous-time, nonlinear, stochastic, and other systems require the appropriate domain-specific stability machinery.

Use `spr(K)` for spectral radius when `ρ` is already reserved for return authority.

## Evidence lineage

Every official evidence-producing branch should, where applicable, bind:

- stable ID;
- exact parent(s);
- frozen source/protocol digest;
- runtime/toolchain;
- official invocation count;
- same-ID rerun count;
- first terminal;
- receipt/artifact digest;
- explicit claim ceiling.

Allowed terminal classes include `PASS`, `FAIL`, `MIXED`, `ERROR`, `TIMEOUT`, and `UNRESOLVED` with experiment-specific detail.

### Failure preservation

A failed/error/timeout/unresolved official stable ID is never repaired in place. The correct pattern is:

`parent terminal -> preserved scar -> new additive successor ID -> new frozen source/protocol -> new terminal`

No same-ID interpretive rescue.

## Formal proof boundary

Lean/Coq/Isabelle/other proof-assistant success establishes only the encoded theorem under explicit assumptions. It does not automatically establish empirical premises, implementation/world correspondence, complete threat models, open-problem closure, external mathematical acceptance, or production superiority.

## Evidence-carrying PRs

Evidence-only formal/research PRs should remain **draft and unmerged** unless a later explicit integration decision is made. Their function is to preserve source, workflow, receipts, and terminal state without silently promoting evidence into the stable product branch.

Parallel formalizations with distinct stable IDs may coexist. Do not collapse them retrospectively.

## Product integration

Normal feature/fix/documentation work integrates through `dev`. `main` is the stable branch. Evidence-carrying PRs may use `main` as a fixed comparison base while remaining draft/unmerged.

## External and financial authority

A benchmark, estimate, simulation, proof receipt, draft acquisition, or agent proposal is not purchase/trading/capital/deployment authority. External actions require separate present-tense authorization plus any frozen budget, custody, evaluator, or operator-ceiling requirements.

## Claim ceilings

Unless separately evidenced, repository-local results do not establish:

- unaffiliated external reproduction;
- independent custody;
- production superiority over frontier baselines;
- universal physics or a universal `κ` threshold;
- biological Living Morphology;
- consciousness continuity;
- Organic Superintelligence;
- a Millennium Prize solution;
- guaranteed cultural traction;
- economic self-sufficiency;
- a certified IP valuation;
- Full Universality.

## Universality research grammar

The broad research grammar is:

`Transformation -> Invariant -> Return -> Authority -> Memory -> Breaker`

The formal program searches for maximal surviving transformation families and minimum first-break witnesses (`A_max / b*`) inside explicitly frozen universes. It does not assume a unique greatest survivor class exists.

## Governance self-application

These rules apply to the governance machinery itself. A governance failure is preserved as a governance scar and repaired additively; it is not exempt from the lineage rules it imposes elsewhere.
