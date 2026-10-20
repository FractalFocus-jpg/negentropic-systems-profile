# R144-S256 QEW-2 Cross-Provider Rehearsal

This branch contains a frozen cross-provider evaluation rehearsal for the Quorum Epistemic Witness architecture.

The workflow runs on Ubuntu 22.04, Ubuntu 24.04, and Windows 2022. Each provider generates an independent runtime seed and ephemeral Ed25519 evaluator/custody keys, undergoes an actual process interruption, resumes from persisted evidence, performs a fresh replay, and is checked by a separately written verifier. The aggregate job verifies the frozen criteria across all three providers.

This is external-infrastructure, same-party evidence. It is not unaffiliated independent evaluation, does not validate the scientific truth of the witnessed subject, and does not establish unrestricted universal implementation superiority.
