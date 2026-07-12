---
change: CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-governance-for-swift-algokit
artifact: research
---

# Research

The package builds locally and 113 deterministic tests pass. Twelve localnet tests require an independently managed Algokit/Docker environment; without it, nine skip and three make live localhost calls. Existing hosted workflows currently invoke the full suite, while the unified governance gate must remain deterministic and must not silently provision or mutate a localnet.
