---
change: CHG-0002-document-the-existing-swift-algokit-api-at-complete-coverage-and-correct-rollout
artifact: design
---

# Design

Add one stable `algokit` canonical companion whose file map covers every Swift implementation file and whose public API
tables enumerate each distinct export. Ten normative requirements group the existing behavior by client lifecycle,
queries, payments and keys, applications, assets, direct and composed transactions, units, and compatibility. Test
evidence maps to the five deterministic suites and separately labels the live localnet suite.

Raise the Trust contract threshold to 100 and make README plus governance configuration meaningful SDD inputs. Keep
the unified immutable Trust action and add the immutable SpecSync action as an explicit verified-lifecycle step so the
workflow visibly enforces strict coverage and closing approval. Regenerate Claude, Cursor, Codex, and Gemini
integrations using SpecSync 5.0.1. No source, test, dependency, package, signing, or release behavior changes.
