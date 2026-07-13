---
spec: algokit.spec.md
---

## Key Decisions

- Preserve Algorand SDK models and errors at the boundary rather than introducing parallel wrapper types.
- Keep client and composer state actor-isolated and use async/await for network operations.
- Leave localnet ownership, account funding, and node availability outside the library.
- Keep explicit access to `algodClient` and `indexerClient` for operations not covered by the convenience facade.

## Files to Read First

- `Sources/AlgoKit/AlgoKit.swift` for client construction and ownership.
- `Sources/AlgoKit/AlgoKit+Transaction.swift` for signing, grouping, and confirmation.
- `Sources/AlgoKit/AtomicTransactionComposer.swift` for the fluent atomic workflow.
- The operation-specific extensions for exact transaction fields and error behavior.

## Current Status

- The canonical contract reflects the existing implementation; this governance migration changes no product code.
- Deterministic unit tests cover transaction construction, signing, configuration, indexer absence, and composition.
- Live localnet tests remain opt-in because they require a reachable node and funded accounts.

## Notes

- Suggested transaction validity is consistently `firstRound ... firstRound + 1000`.
- The composer permits one transaction at build time when the upstream group type accepts it.
- `configureAsset` forwards optional addresses as supplied; callers are responsible for intended authority changes.
