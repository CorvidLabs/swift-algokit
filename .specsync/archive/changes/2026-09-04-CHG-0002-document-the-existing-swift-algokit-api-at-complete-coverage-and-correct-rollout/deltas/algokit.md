## MODIFIED

### REQUIREMENT REQ-algokit-001

`AlgoKit` SHALL construct an algod client for every configuration and an indexer client only when an indexer URL is present.

Acceptance Criteria

- Predefined networks use their matching configuration factories.
- Custom configurations preserve optional indexer availability.

### REQUIREMENT REQ-algokit-002

Account balance, account information, node status, pending-transaction, parameter, and confirmation operations SHALL delegate to the configured algod client and propagate failures.

Acceptance Criteria

- Balance returns `MicroAlgos` and health succeeds only after a status response.

### REQUIREMENT REQ-algokit-003

Indexer search and lookup operations SHALL require a configured indexer client.

Acceptance Criteria

- An algod-only configuration produces an explicit network error.

### REQUIREMENT REQ-algokit-004

Payment and participation-key operations SHALL use current suggested parameters, sign with the supplied account, and submit the resulting transaction.

Acceptance Criteria

- Notes use UTF-8 and participation parameters are forwarded unchanged.

### REQUIREMENT REQ-algokit-005

The library SHALL construct and submit create, NoOp, opt-in, close-out, update, and delete application calls with the caller-supplied programs and references.

Acceptance Criteria

- Creation returns its confirmed index or throws when that index is absent.

### REQUIREMENT REQ-algokit-006

The library SHALL construct and submit create, opt-in, transfer, close-out, freeze, configure, destroy, and clawback ASA transactions using the supplied authority account.

Acceptance Criteria

- Creation defaults manager and reserve and returns its confirmed asset index.

### REQUIREMENT REQ-algokit-007

Direct submission SHALL sign a transaction with its supplied account, while grouped submission SHALL reject a signer count that differs from the transaction count.

Acceptance Criteria

- Valid groups are signed in order; mismatched counts fail before submission.

### REQUIREMENT REQ-algokit-008

The composer SHALL append payments, asset transfers, asset opt-ins, application calls, and custom transactions in call order and build them as one atomic group.

Acceptance Criteria

- Append methods chain, both signer forms work, and signed groups can submit.

### REQUIREMENT REQ-algokit-009

The `MicroAlgos` conveniences SHALL construct values from ALGO `Double` amounts and microALGO `UInt64` base units.

Acceptance Criteria

- Fractional ALGO and exact base-unit conversions preserve upstream behavior.

### REQUIREMENT REQ-algokit-010

The package SHALL retain its declared Apple platform floors, Swift 6 package manifest, public Algorand type exposure, actor isolation, and sendable transaction result values.

Acceptance Criteria

- The package builds under its manifest and retains actor-isolated mutable state.
