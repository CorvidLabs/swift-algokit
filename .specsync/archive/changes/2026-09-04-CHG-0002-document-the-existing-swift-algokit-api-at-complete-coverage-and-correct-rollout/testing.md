---
change: CHG-0002-document-the-existing-swift-algokit-api-at-complete-coverage-and-correct-rollout
artifact: testing
---

# Testing

`REQ-algokit-001` is covered by predefined/custom configuration and client-availability tests.
`REQ-algokit-002` is covered by account, status, parameter, pending, and confirmation unit or authorized localnet tests.
`REQ-algokit-003` is covered by the no-indexer error and custom-indexer tests.
`REQ-algokit-004` is covered by payment and key-registration construction/signing tests.
`REQ-algokit-005` is covered by `ApplicationTransactionTests`.
`REQ-algokit-006` is covered by `AssetTransactionTests`.
`REQ-algokit-007` is covered by direct/group signing and mismatch tests.
`REQ-algokit-008` is covered by `AtomicComposerTests`.
`REQ-algokit-009` is covered by MicroAlgos conversion and boundary tests.
`REQ-algokit-010` is covered by the native build, deterministic suite, strict SpecSync check, and hosted Trust checks.

Run `specsync check --strict --require-coverage 100 --force`, `specsync agents status`, `fledge trust doctor`,
`fledge lanes run verify`, and `fledge trust verify`. The deterministic lane is expected to build the package and run
113 tests. Live `LocalnetTests` require a managed localnet and remain independently authorized; this change does not
claim they ran when that environment is unavailable.
