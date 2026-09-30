---
id: support-swift-algorand-0-4-algokit-network-throws-because-the-configuration-factories-it-calls-now-throw
state: draft
type: bug_fix
base_commit: 3b4574c9b8e83f879d4d0b6674e0f0dd29056564
---

# Support swift-algorand 0.4: AlgoKit(network:) throws, because the configuration factories it calls now throw

## Intent

Support swift-algorand 0.4: AlgoKit(network:) throws, because the configuration factories it calls now throw

## Affected Canonical Specs

- `algokit`

## Acceptance Criteria

- AlgoKit builds and its tests pass against swift-algorand 0.4.0 and against 0.3.x; AlgoKit(network:) is throwing and propagates the configuration factory's error; AlgoKit(configuration:) is unchanged; the README examples use try.

## No-spec Rationale

Not applicable
