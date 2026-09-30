---
change: support-swift-algorand-0-4-algokit-network-throws-because-the-configuration-factories-it-calls-now-throw
artifact: design
---

# Design

The only change in the library is `try` on the three preset factories and `throws` on the init.
Callers of `AlgoKit(network:)` must add `try`, which is source-breaking, so the release should be
0.1.0. The tests and README gain `try`, and test functions that now throw are marked `throws`.
The committed `Package.resolved` moves to swift-algorand 0.4.0, so CI builds the new pairing.
