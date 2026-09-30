---
change: support-swift-algorand-0-4-algokit-network-throws-because-the-configuration-factories-it-calls-now-throw
artifact: context
---

# Context

swift-algorand 0.4.0 made the `AlgorandConfiguration` factories (`.localnet()`, `.testnet()`,
`.mainnet()`) throwing. `AlgoKit.init(network:)` calls them without `try`, so AlgoKit 0.0.2 does
not compile once a package resolves swift-algorand 0.4. swift-algochat works around this by
capping swift-algorand below 0.4.0, and that cap in turn blocks corvid-bot (on swift-algorand
0.4.0) from depending on swift-algochat for AlgoChat voting (corvid-bot #210). Leif chose to fix
this upstream first (2026-09-30).
