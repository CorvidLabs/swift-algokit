## MODIFIED

### REQUIREMENT REQ-algokit-001

`AlgoKit` SHALL construct an algod client for every configuration and an indexer client only when an indexer URL is present. `init(network:)` SHALL throw when the network's configuration factory throws, and the package SHALL build against swift-algorand 0.3 and 0.4.

Acceptance Criteria

- Predefined networks use their matching configuration factories, and `init(network:)` propagates their errors.
- Custom configurations preserve optional indexer availability.
