---
change: support-swift-algorand-0-4-algokit-network-throws-because-the-configuration-factories-it-calls-now-throw
artifact: requirements
---

# Requirements

- `AlgoKit.init(network:)` SHALL be `throws` and propagate the configuration factory's error.
- `AlgoKit.init(configuration:)` is unchanged.
- The package keeps `from: "0.2.0"` for swift-algorand and builds against 0.3.x and 0.4.x. A
  `try` on a call that doesn't throw is only a warning under 0.3.
- REQ-algokit-001 is updated (delta).
