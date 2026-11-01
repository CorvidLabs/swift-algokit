---
change: run-the-specsync-archive-gate-before-every-ci-job
artifact: plan
---

# Plan

## Approach

Add one `archive-gate` job, displayed as `Archive`, at the top of `jobs:` in each
workflow that runs on `pull_request` or `push`, and make every other job depend
on it so nothing else runs while a SpecSync change is open.

## Out of scope

- Archiving, reopening or otherwise modifying the preexisting open changes.
- Configuring the org ruleset that requires the `Archive` check.
- Moving the spec-sync pin to a release tag; that follows once a release ships
  the archive gate.
- Any change to build, test, documentation or Trust steps.

## Steps

1. In `docs.yml`, `macOS.yml`, `trust.yml` and `ubuntu.yml`, add the
   `archive-gate` job on `ubuntu-latest` with a 5 minute timeout: check out the
   pull request head (or pushed sha) with `actions/checkout@v5` and
   `persist-credentials: false`, then run
   `CorvidLabs/spec-sync@106aaa43d0bcf049f19b173ddb63815a25c3f931` with
   `archive-gate-only: 'true'`.
2. Add `needs: archive-gate` to every job without `needs` (`build`, `macOS`,
   `trust`, `ubuntu`); `deploy` already needs `build` and reaches the gate
   transitively.
3. Leave every other line unchanged and confirm each file still parses.

## Risks

- While any change is open, every CI job is skipped; that is the intended
  behavior, and the preexisting open changes keep this pull request's Archive
  check red until their owners archive them.
- The pin is a commit on spec-sync `main`, not a release; it must be moved to the
  first release that contains the archive gate.

## Constraints consulted

- AGENTS.md (CorvidLabs trust toolchain): the Trust gate is left in place and not
  weakened, the managed block and generated trust configuration are untouched,
  and `fledge trust verify` remains the completion gate in CI (the `trust` job
  still runs it after the Archive job).
- No canonical spec owns `.github/workflows`, so no spec delta is needed.
