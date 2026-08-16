# Contributing to Universal Operating System Console

Thank you for your interest in contributing! This project implements a living protocol for coherence measurement and negentropic knowledge capture.

## Getting Started

1. **Fork and clone** the repository
2. **Set up environment**:
   ```bash
   python -m venv .venv
   .venv\Scripts\activate  # Windows
   pip install -r requirements.txt
   ```
3. **Verify dashboard runs**:
   ```bash
   python src/tapestry/self_observing_dashboard.py
   # Visit http://localhost:5055
   ```

## Development Workflow

### Branch Strategy
- `main` — stable releases and explicitly integrated governance/documentation only
- `dev` — integration branch
- `feature/*` — new features
- `fix/*` — bug fixes
- `docs/*` — documentation updates
- `eidolen/*`, `formal/*`, or experiment-specific branches — evidence carriers when explicitly declared below

Normal product/development work branches from `dev` and targets `dev` first. Evidence-carrying research PRs may target `main` as a fixed comparison base **only when they remain draft/unmerged and are explicitly marked as evidence carriers**. They do not become product authority merely because CI passes.

### Commit Messages (Conventional Commits)
```
feat: add CDI visualization to dashboard
fix: resolve snapshot timestamp timezone issue
docs: update README with Phase 7 lattice info
chore: upgrade dependencies to patch CVEs
test: add unit tests for PLV calculation
```

### Pull Request Process
1. Create feature branch from `dev` for normal development.
2. Write clear, atomic commits.
3. Ensure dashboard still runs (`localhost:5055` returns valid JSON) when relevant.
4. Update documentation if API changes.
5. Submit PR with:
   - Clear description of changes
   - Link to related issue (if any)
   - Evidence of testing (screenshot, log output, etc.)
   - Explicit authority/claim ceiling when the PR carries research, financial, security, or deployment artifacts

## Evidence-Carrying Research PR Governance

Research/formal/benchmark PRs follow an additive, fail-closed lineage protocol.

### Required metadata
Every official evidence-carrying PR should state, when applicable:
- stable experiment/formal ID;
- exact parent and side-parent bindings;
- frozen source/protocol digest;
- runtime/toolchain version;
- invocation count and same-ID rerun count;
- first terminal (`PASS`, `FAIL`, `MIXED`, `ERROR`, `TIMEOUT`, or `UNRESOLVED` grammar);
- artifact/receipt digest;
- claim ceiling;
- whether the PR is an evidence carrier or an integration candidate.

### First-terminal preservation
- A failed, mixed, error, timeout, or unresolved official run is never rewritten into a pass.
- Do **not** rerun the same frozen stable ID to repair a terminal.
- Repairs require a new additive successor ID, new frozen source/protocol where applicable, and an explicit parent link to the preserved terminal.
- Historical failures remain visible even when an additive successor later passes.

### Draft evidence carriers
- Evidence-only PRs remain draft/unmerged unless an explicit later integration decision is made.
- CI success is evidence of the declared check only; it is not integration authority, empirical truth, external reproduction, production superiority, legal/IP validation, or economic authority.
- Parallel formalizations with distinct stable IDs may coexist. Do not collapse them into one history after the fact.

### Formal proof boundary
Machine compilation/proof establishes only the encoded theorem under its explicit assumptions. It does not by itself establish:
- empirical premises;
- implementation-to-world correspondence;
- attack/threat-model completeness;
- independent or unaffiliated reproduction;
- production superiority;
- open mathematical conjectures beyond the exact formalized statements.

### Financial and execution authority
Estimates, simulations, benchmark outputs, or draft acquisition artifacts are **not** purchase/trading/capital authority. Any financial or external execution requires a separate present-tense authorization and any declared fresh-data/operator-ceiling requirements.

### No interpretive rescue
If a frozen definition, metric, baseline, or terminal loses, the loss remains a loss. Fix the next version additively; do not redefine the scored parent after seeing the outcome.

## Code Standards

### Python
- Follow PEP 8 style guide
- Use type hints where practical
- Add docstrings for public functions
- Keep functions focused and small

### PowerShell
- Include copyright header
- Use approved verbs (Get-, Set-, New-, etc.)
- Add parameter descriptions
- Handle errors gracefully

### Documentation
- Write in clear, concise English
- Use Markdown formatting
- Include code examples
- Link related concepts

## Testing Requirements

Before submitting PR:
- [ ] Dashboard starts without errors
- [ ] JSON endpoint returns valid data
- [ ] Snapshots write successfully
- [ ] CDI tracker runs without crashes
- [ ] No regressions in existing features

For evidence-carrying PRs also verify:
- [ ] Stable ID and parents are explicit
- [ ] Frozen digest is checked before execution
- [ ] First terminal is preserved
- [ ] Same-ID rerun count is explicit
- [ ] Receipts/artifacts are retained and hashed where available
- [ ] Claim ceiling is explicit

## Security

- Never commit secrets, API keys, or credentials
- Validate all user inputs
- Sanitize file paths
- Review dependencies for CVEs
- See [SECURITY.md](SECURITY.md) for full policy

## Licensing

By contributing, you agree that:
- Public artifacts (docs, specs) fall under LICENSE-public.txt (CC BY-NC 4.0)
- Engine code falls under LICENSE-commercial.txt (proprietary)
- You have the right to submit your contribution
- Your contribution complies with these terms

## Questions?

- Check [README.md](README.md) first
- Review existing issues/discussions
- Ask questions in discussion thread before opening issue
- For security issues, email security@new-illuminati.local (private disclosure)

## Project Philosophy

This system embodies:
- **Coherence** — phase-locked, harmonious operation
- **Negentropy** — capture and crystallize knowledge
- **Compassion** — technology in service of human flourishing
- **Computability** — measurable, reproducible, testable
- **Return** — corrections are additive and lineage-preserving
- **Authority discipline** — capability, proof, authority, and external closure are distinct

Every contribution should honor these principles.

## Governance

- **Maintainer**: @FractalFocus-jpg (Alexander Liantonio)
- **Decision making**: Benevolent dictator model (for now)
- **Certification**: Required for production deployments
- **Research rule**: No preserved first terminal, no claim-changing experiment
- **Research rule**: No proof, no authority; no external independence, no independent superiority
- **Roadmap**: See [ops/UOS Command Center.md] in vault

## Attribution

Contributors will be acknowledged in:
- CONTRIBUTORS.md (to be created)
- Release notes
- Git commit history

Thank you for contributing to the Universal Operating System! 🜂

---

**Questions or need help?** Open a discussion thread.

**Found a bug?** Check existing issues, then open a new one with reproduction steps.

**Have an idea?** Start with a discussion before coding to ensure alignment with project goals.
