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
- `main` — stable releases only
- `dev` — integration branch
- `feature/*` — new features
- `fix/*` — bug fixes
- `docs/*` — documentation updates

### Commit Messages (Conventional Commits)
```
feat: add CDI visualization to dashboard
fix: resolve snapshot timestamp timezone issue
docs: update README with Phase 7 lattice info
chore: upgrade dependencies to patch CVEs
test: add unit tests for PLV calculation
```

### Pull Request Process
1. Create feature branch from `dev`
2. Write clear, atomic commits
3. Ensure dashboard still runs (`localhost:5055` returns valid JSON)
4. Update documentation if API changes
5. Submit PR with:   - Clear description of changes
   - Link to related issue (if any)
   - Evidence of testing (screenshot, log output, etc.)

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

Every contribution should honor these principles.

## Governance

- **Maintainer**: @FractalFocus-jpg (Alexander Liantonio)
- **Decision making**: Benevolent dictator model (for now)
- **Certification**: Required for production deployments
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
