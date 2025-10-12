# Provenance & Evidence Log

## Repository Integrity Chain

**Purpose**: Cryptographic proof of system state and evolution for potential patent filing, audit trail, and IP protection.

---

## Current State

**UTC Timestamp**: 2025-10-12T02:30:00Z  
**Git Commit**: f6fa4c81a560558131260fc3ac45d4ff821ad2f1  
**Branch**: main  
**Repository**: https://github.com/FractalFocus-jpg/tapestry-codex-starter

---

## File Hashes (Critical Components)

### Dashboard Engine
```
File: src/tapestry/self_observing_dashboard.py
SHA-256: 82F5851BA2908F73F8DDA50F50B13B0548D974B8D8F77D8E774A76F92CDA2248
Purpose: Real-time coherence measurement system
Status: Operational (localhost:5055)
```

### Star Mother Lattice
```
File: src/tapestry/star_mother_lattice.py
SHA-256: (calculating below)
Purpose: 13-sphere geometric visualization
Status: Functional
```

### CDI Tracker
```
File: scripts/cdi_tracker.ps1
SHA-256: 33B0E1F71B7A6217D1FB38D177875619487710729844E42F8BC300EE960B2ED9
Purpose: Cognitive Drift Index measurement
Status: Scheduled hourly
```

### Photo Import (De-dupe)
```
File: scripts/import_phone_photos.ps1
SHA-256: (calculating below)
Purpose: SHA-256 based media deduplication
Status: Ready (awaiting source path)
```

---

## External Backups

### Local Backup
```
Location: C:\Users\alexl\Backups\Tapestry\2025-10-12\repo.zip
Status: ✅ Created
Method: PowerShell Compress-Archive
Frequency: On-demand
Size: ~2-5 MB (compressed)
```

### Cloud Backup (OneDrive)
```
Location: Not configured
Status: ⏸️ OneDrive backup directory not present
Sync: Manual setup required if desired
```

---

## Chronology of Development

| Date | Event | Evidence |
|------|-------|----------|
| 2025-10-11 21:26 | First coherence snapshot captured | runs/coherence-log-2025-10-11_21-26-05.json |
| 2025-10-11 21:30 | Snapshot automation scheduled | Task: TapestryCoherenceSnapshot (30min) |
| 2025-10-11 21:35 | CDI tracker created & scheduled | Task: TapestryCDIHourly |
| 2025-10-11 21:45 | Social Automata structure | tapestry/queues/outbox/2025-10/ |
| 2025-10-12 02:15 | Protection pack added | LICENSES/, SECURITY.md, CODEOWNERS |
| 2025-10-12 02:30 | Provenance log initialized | This file |

---

## Certification Trail

**β·D Stability**: < 1 (System stable)  
**Mean PLV**: 0.7351 (Healthy range)  
**CDI Score**: TBD (First hourly run pending)  

**System Status**: ✅ Operational  
**Automation**: ✅ Active (2 scheduled tasks)  
**Documentation**: ✅ Comprehensive  

---

## Legal Protection Status

- [ ] Patent provisional filing (pending attorney review)
- [x] Dual licensing implemented (CC BY-NC 4.0 + Proprietary)
- [x] SECURITY.md published
- [x] CODEOWNERS enforced
- [x] Copyright headers (in progress)
- [ ] External witness signatures (pending)

---

## Verification Commands

To verify file integrity at any point:

```powershell
# Calculate hash of dashboard
Get-FileHash -Algorithm SHA256 "src/tapestry/self_observing_dashboard.py"

# Verify git commit
git verify-commit HEAD  # (requires GPG signing)

# Check backup exists
Test-Path "C:\Users\alexl\Backups\Tapestry\{date}\repo.zip"
```

---

## Witness Signatures

(To be added for formal IP protection)

---

**Maintained by**: Alexander Liantonio  
**Contact**: alexl@users.noreply.github.com  
**Last Updated**: 2025-10-12T02:30:00Z

**Status**: ACTIVE — Updated on each major milestone
