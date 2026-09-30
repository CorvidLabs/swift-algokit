---
change: support-swift-algorand-0-4-algokit-network-throws-because-the-configuration-factories-it-calls-now-throw
artifact: testing
---

# Testing

`swift test`, with localnet skipped as in CI, passes 125 tests (12 skipped) against swift-algorand
0.4.0. With the dependency pinned to `"0.3.0" ..< "0.4.0"`, the same tree resolves 0.3.2 and also
passes 125 (12 skipped).

## Requirement evidence

| Requirement | Evidence |
|---|---|
| REQ-algokit-001 | `AlgoKitTests`: the network configuration tests and every `try AlgoKit(network:)` construction; the builds against swift-algorand 0.3.2 and 0.4.0. |
