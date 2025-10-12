# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.4+    | :white_check_mark: |
| 2.0-2.3 | :white_check_mark: |
| < 2.0   | :x:                |

## Reporting a Vulnerability

**DO NOT** open public issues for security vulnerabilities.

Instead, please report security issues privately to:
**security@new-illuminati.local** (placeholder - update when available)

Or via GitHub Security Advisory:
https://github.com/FractalFocus-jpg/tapestry-codex-starter/security/advisories/new

## Security Measures

### Repository
- [ ] Enable 2FA for all maintainers
- [ ] GitHub Code Scanning enabled
- [ ] Dependabot security updates enabled
- [ ] Branch protection rules enforced
- [ ] Signed commits (future)

### Code
- No hardcoded secrets or credentials
- Windows Credential Manager for sensitive data
- Execution policy checks in PowerShell scripts
- Input validation on all file paths
- SHA-256 verification for imported media

### Deployment
- Dashboard runs on localhost only (127.0.0.1:5055)
- No external network exposure by default
- File permissions respect Windows ACLs
- Vault access requires explicit directory allowlist

### Data Privacy
- No telemetry without explicit consent
- Local-first architecture (no cloud dependencies)
- Git synchronization user-controlled
- Coherence data never leaves local machine

## Security Checklist for Contributors

Before submitting PRs:
- [ ] No credentials in code or config files
- [ ] All file paths validated/sanitized
- [ ] PowerShell scripts include execution policy headers
- [ ] No SQL injection vectors
- [ ] No command injection vulnerabilities
- [ ] Dependencies reviewed for known CVEs

## Threat Model

**In Scope:**
- Local privilege escalation
- File path traversal attacks
- Malicious file imports
- Dependency vulnerabilities

**Out of Scope (localhost-only):**
- Remote code execution (no network exposure)
- CSRF attacks (no web authentication)
- XSS (read-only dashboard)

## Response Timeline

- Initial response: Within 48 hours
- Severity assessment: Within 7 days
- Patch timeline: Based on severity
  - Critical: 7 days
  - High: 30 days
  - Medium: 90 days
  - Low: Best effort

## Security Contact

- **Email**: security@new-illuminati.local (placeholder)
- **GitHub**: @FractalFocus-jpg
- **PGP Key**: (to be added)

**Last Updated**: 2025-10-12
