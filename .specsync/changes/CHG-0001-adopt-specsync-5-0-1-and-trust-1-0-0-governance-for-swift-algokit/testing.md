---
change: CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-governance-for-swift-algokit
artifact: testing
---

# Testing

Run `specsync check --strict --force` at threshold 0, `specsync agents status`, `fledge trust doctor`, and `fledge lanes run verify`. The blocking lane builds the package and passes 113 deterministic tests. Live `LocalnetTests` remain independently authorized and are not run by Trust without a managed localnet.
