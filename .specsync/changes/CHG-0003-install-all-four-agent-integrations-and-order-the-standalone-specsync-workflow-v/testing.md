---
change: CHG-0003-install-all-four-agent-integrations-and-order-the-standalone-specsync-workflow-v
artifact: testing
---

# Testing

Verification must demonstrate:

- `specsync agents status` reports Claude, Cursor, Codex, and Gemini installed.
- `specsync check --strict --require-coverage 100 --force` passes.
- `fledge trust doctor` reports a healthy installation.
- `fledge trust verify` passes the configured governance and native lanes.
- The workflow diff contains only the intended Trust/SpecSync step ordering
  change.

Hosted validation is not claimed by this artifact; it is evaluated on the
exact pushed pull-request head.
