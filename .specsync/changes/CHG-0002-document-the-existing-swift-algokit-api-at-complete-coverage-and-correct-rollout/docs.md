---
change: CHG-0002-document-the-existing-swift-algokit-api-at-complete-coverage-and-correct-rollout
artifact: docs
---

# Docs

The new companion documents only behavior already implemented and described by the source and tests. It explicitly
records signer-count failures, indexer absence, missing creation indices, current transaction validity windows, asset
authority behavior, atomic ordering, and the localnet verification boundary. It contains no roadmap claims, sample
identifiers, unimplemented features, TODOs, or placeholder approval statements.

Public README content remains unchanged. The workflow continues to demonstrate mutable `@v1` and `@v5` only in
public guidance; executable workflow references use the approved immutable release commits.
