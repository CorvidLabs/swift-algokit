---
change: CHG-0002-document-the-existing-swift-algokit-api-at-complete-coverage-and-correct-rollout
artifact: context
---

# Context

The first rollout change installed SpecSync and Trust in advisory contract mode because the repository had no
canonical requirement companion. That left source and exported API coverage at zero percent and did not make public
documentation or governance policy part of the change lifecycle. This documentation-only correction records the
existing package contract at complete coverage while preserving all product source and tests unchanged.

The package contains eleven Swift implementation files. Its stable surface is an actor-based facade over
`swift-algorand`: client construction, account and network queries, common payment/application/asset/key-registration
transactions, atomic transaction composition, signing/submission, and unit conveniences. Deterministic tests exercise
transaction construction and signing without network access; live localnet tests remain an explicit integration
boundary.
