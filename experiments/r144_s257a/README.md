# R144-S257A - Public-Beacon Blind Quorum Rehearsal

This branch freezes the seed-discretion protocol, provider wrapper, selection-bias study, and quorum-threshold model before a future League of Entropy drand beacon is acquired.

The workflow waits for and cryptographically verifies a future beacon with `drand-client@1.4.2`, derives a shared seed from the beacon and frozen commit, and runs the frozen R144-S256 QEW-2 candidate on GitHub-hosted Ubuntu 22.04, Ubuntu 24.04, and Windows Server 2022. It preserves actual interruption, exact resume, fresh replay, a separately written verifier, and the full-collusion boundary.

This is same-party, public-randomness-seeded external-infrastructure evidence. It is not unaffiliated evaluator-owned validation and does not validate the underlying scientific subject.
