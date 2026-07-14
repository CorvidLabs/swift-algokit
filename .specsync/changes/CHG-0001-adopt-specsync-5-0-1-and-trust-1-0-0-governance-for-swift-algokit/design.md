---
change: CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-governance-for-swift-algokit
artifact: design
---

# Design

Adopt SpecSync 5.0.1 with a governance-only no-spec-change rationale and all four integrations. Add a Fledge lane for the Swift build and deterministic suite, explicitly skipping `LocalnetTests`. Trust 1.0.0 runs in the existing Swift 6 Linux container with blocking risk, progressive provenance, advisory coverage, and Atlas disabled. Preserve macOS, Linux, localnet, and Pages boundaries.
