---
change: run-the-specsync-archive-gate-before-every-ci-job
artifact: testing
---

# Testing

- Each edited workflow parses with
  `ruby -e 'require "psych"; Psych.safe_load(File.read(ARGV[0]))'`, and the job
  graph shows `archive-gate` with no needs and every other job needing it
  directly (`build`, `macOS`, `trust`, `ubuntu`) or transitively (`deploy` via
  `build`).
- `bash .github/scripts/archive-readiness.sh .` from CorvidLabs/spec-sync at the
  pinned commit fails while changes are open under `.specsync/changes/`, which is
  the gate working as designed; it passes once every change is archived.
- `specsync change audit --strict` and `specsync check --strict` (6.0.0, the
  version CI pins) are run locally; failures already present on `main` from the
  preexisting stale accepted changes are reported, not fixed here.
- In CI, the `Archive` check appears on the pull request and the other jobs run
  only after it succeeds.
