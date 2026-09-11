---
change: CHG-0003-install-all-four-agent-integrations-and-order-the-standalone-specsync-workflow-v
artifact: design
---

# Design

Keep one required job named `trust`. After checkout, Swift setup, and comparison
range calculation, execute the immutable Trust action first. Execute the
immutable SpecSync action immediately afterward with strict validation, 100%
coverage, and lifecycle enforcement enabled.

Retain the generated integration files in their standard directories so each
supported agent discovers the same repository-local SpecSync guidance. Do not
duplicate product requirements in agent-specific files.

The ordering change is intentionally narrow: no permissions, triggers, runner,
tool setup, pins, policy settings, source files, or canonical specs change.
