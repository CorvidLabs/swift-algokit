---
id: CHG-0003-install-all-four-agent-integrations-and-order-the-standalone-specsync-workflow-v
state: accepted
type: migration
base_commit: ed08f33e5df68d3cc5065f4501bc7126e47d0a36
---

# Install all four agent integrations and order the standalone SpecSync workflow verification after the Trust action

## Intent

Install all four agent integrations and order the standalone SpecSync workflow verification after the Trust action

## Affected Canonical Specs

- None

## Acceptance Criteria

- All four agent integrations report installed; the standalone SpecSync verification step runs after the Trust action; strict SpecSync validation at the committed 100% threshold passes; fledge trust doctor and fledge trust verify pass.

## No-spec Rationale

This change configures repository governance integrations and CI execution order without changing the documented Swift AlgoKit product behavior or public API.
