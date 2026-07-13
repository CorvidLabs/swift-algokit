---
change: CHG-0003-install-all-four-agent-integrations-and-order-the-standalone-specsync-workflow-v
artifact: plan
---

# Plan

1. Confirm the generated Claude, Cursor, Codex, and Gemini integrations are
   present in their standard directories.
2. Place the immutable Trust action before the standalone immutable SpecSync
   lifecycle action without changing any other workflow behavior.
3. Validate all four integrations, strict SpecSync coverage, Trust health, and
   the repository's native verification lane.
4. Record verification evidence and closing approval through supported
   SpecSync lifecycle commands.
