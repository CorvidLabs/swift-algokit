---
change: support-swift-algorand-0-4-algokit-network-throws-because-the-configuration-factories-it-calls-now-throw
artifact: tasks
---

# Tasks

- [x] `init(network:)` throws
- [x] Tests and README use `try`
- [x] Package.resolved on swift-algorand 0.4.0
- [x] Spec text, delta, change log
- [x] Definition approval (0xLeif, 2026-09-30)

Follow-up after merge, on Leif's go: tag release 0.1.0. The init change is source-breaking for callers of `AlgoKit(network:)`.
