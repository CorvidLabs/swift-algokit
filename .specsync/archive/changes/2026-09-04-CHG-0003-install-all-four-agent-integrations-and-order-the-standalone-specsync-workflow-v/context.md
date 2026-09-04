---
change: CHG-0003-install-all-four-agent-integrations-and-order-the-standalone-specsync-workflow-v
artifact: context
---

# Context

Swift AlgoKit already contains the generated SpecSync integrations for Claude,
Cursor, Codex, and Gemini. The rollout workflow also runs the immutable Trust
1.0.0 action and the immutable SpecSync 5.0.1 action in the same `trust` job.

The explicit SpecSync step previously ran before Trust. Trust installs and
validates the toolchain used by the repository gate, so the standalone strict
SpecSync lifecycle check must follow Trust while remaining independently
visible in the hosted job.

This is governance configuration only. It does not alter sources, tests,
package products, public APIs, or the canonical Swift AlgoKit requirements.
