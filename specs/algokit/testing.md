---
spec: algokit.spec.md
---

## Automated Testing

| Test File | Type | What It Covers |
|-----------|------|----------------|
| `Tests/AlgoKitTests/AlgoKitTests.swift` | Deterministic unit | Configurations, accounts, units, core transaction construction, signing, and groups. |
| `Tests/AlgoKitTests/ApplicationTransactionTests.swift` | Deterministic unit | Every application transaction variant, optional fields, and signing. |
| `Tests/AlgoKitTests/AssetTransactionTests.swift` | Deterministic unit | ASA creation, opt-in, transfer, freeze, configuration, destruction, clawback, and signing. |
| `Tests/AlgoKitTests/AtomicComposerTests.swift` | Deterministic unit | Composer order, custom transactions, builds, signer forms, group identifiers, and mismatch failures. |
| `Tests/AlgoKitTests/IndexerAndNetworkTests.swift` | Deterministic unit | Indexer absence/configuration, network configuration, keys, payments, accounts, and units. |
| `Tests/AlgoKitTests/LocalnetTests.swift` | Integration | Live status, accounts, payments, assets, atomic groups, composer, and indexer search against localnet. |

## Verification Mapping

| Requirement | Evidence |
|-------------|----------|
| `REQ-algokit-001` | Configuration tests in `AlgoKitTests` and `IndexerAndNetworkTests`. |
| `REQ-algokit-002` | Deterministic client-state tests plus authorized `LocalnetTests`. |
| `REQ-algokit-003` | Four no-indexer error tests and custom indexer configuration tests. |
| `REQ-algokit-004` | Payment and key-registration construction/signing tests. |
| `REQ-algokit-005` | `ApplicationTransactionTests`. |
| `REQ-algokit-006` | `AssetTransactionTests`. |
| `REQ-algokit-007` | Signing/group tests and explicit mismatch tests. |
| `REQ-algokit-008` | `AtomicComposerTests`. |
| `REQ-algokit-009` | MicroAlgos conversion and boundary tests. |
| `REQ-algokit-010` | `swift build`, deterministic `swift test`, and hosted Trust checks. |

## Manual and Hosted Validation

- Run `fledge lanes run verify` for the committed deterministic build and test lane.
- Run live `LocalnetTests` only when a managed localnet is available; they are not silently represented as passing.
- Require the pull-request `trust` job and retained hosted analysis to pass before merge.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| Missing indexer URL | Every indexer query throws before making a request. |
| Signer count mismatch | Group submission and ordered result signing reject the input. |
| Missing creation index | Asset or application creation throws after confirmation. |
| Empty asset list | `assetHoldings` returns `[]`. |
| Optional transaction fields omitted | The corresponding upstream transaction properties remain absent or use documented defaults. |
