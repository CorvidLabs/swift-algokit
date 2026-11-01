---
change: run-the-specsync-archive-gate-before-every-ci-job
artifact: context
---

# Context

This change is part of the org-wide rollout of CorvidLabs/spec-sync#832, approved
by 0xLeif. That pull request (merged as 106aaa43d0bcf049f19b173ddb63815a25c3f931)
added an archive gate to the spec-sync GitHub Action: with
`archive-gate-only: 'true'` it runs only `.github/scripts/archive-readiness.sh`
(bash + python3, no binary download) and fails when any change under
`.specsync/changes/` is still open. The goal is that every SpecSync change is
archived before a pull request merges, and that CI runs nothing else until it is.

Published spec-sync v6.1.1 and older ignore the new input, so the workflows pin
the commit rather than a release tag. Branch protection, an org ruleset that
requires a check named `Archive`, is configured separately; a skipped job counts
as passing, so merge blocking relies on that ruleset.

At the base commit four changes are already open on `main` (CHG-0001, CHG-0002,
CHG-0003 and the swift-algorand 0.4 change), all accepted but not archived. They
belong to other owners and are not touched here, so the new Archive check stays
red until they are archived. `specsync change audit --strict` already reports
them as stale on `main` before this change.
