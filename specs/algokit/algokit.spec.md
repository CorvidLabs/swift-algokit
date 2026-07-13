---
module: algokit
version: 3
status: stable
files:
  - Sources/AlgoKit/AlgoKit+Account.swift
  - Sources/AlgoKit/AlgoKit+Application.swift
  - Sources/AlgoKit/AlgoKit+Asset.swift
  - Sources/AlgoKit/AlgoKit+Indexer.swift
  - Sources/AlgoKit/AlgoKit+KeyRegistration.swift
  - Sources/AlgoKit/AlgoKit+Network.swift
  - Sources/AlgoKit/AlgoKit+Payment.swift
  - Sources/AlgoKit/AlgoKit+Transaction.swift
  - Sources/AlgoKit/AlgoKit.swift
  - Sources/AlgoKit/AtomicTransactionComposer.swift
  - Sources/AlgoKit/Extensions/MicroAlgos+Convenience.swift
db_tables: []
depends_on: []
---

# AlgoKit

## Purpose

`AlgoKit` is an actor-based Swift facade over `swift-algorand`. It configures algod and optional indexer clients,
constructs and signs common Algorand transactions, submits individual or atomic groups, and exposes confirmation,
account, network, and indexer queries. It does not own keys, run a node, or hide the underlying Algorand types.

## Public API

### Exported Types and State

| API | Contract |
|-----|----------|
| `AlgoKit` | Actor that owns an immutable configuration plus algod and optional indexer clients. |
| `configuration` | Configuration used to construct the clients. |
| `algodClient` | Direct access to the configured algod client. |
| `indexerClient` | Direct access to the configured indexer client, or `nil` when no indexer URL exists. |
| `AtomicTransactionComposer` | Actor that accumulates unsigned transactions for one atomic group. |
| `AtomicTransactionResult` | Sendable built group awaiting signer assignment. |
| `SignedAtomicTransactionResult` | Sendable signed group awaiting submission. |
| `init` | Constructs `AlgoKit`, composer, and result values from their documented dependencies. |

### Exported Account, Network, and Query Operations

| API | Contract |
|-----|----------|
| `generateAccount` | Generates a random Algorand account. |
| `account` | Recovers an account from a 25-word mnemonic or propagates mnemonic validation failure. |
| `balance` | Fetches account information from algod and returns its amount as `MicroAlgos`. |
| `accountInfo` | Returns full algod account information. |
| `status` | Returns the current algod node status. |
| `isHealthy` | Returns true after a successful algod status request and otherwise propagates the request error. |
| `searchTransactions` | Searches the configured indexer by optional address and limit. |
| `searchAssets` | Searches the configured indexer by optional name and limit. |
| `getAsset` | Fetches one asset from the configured indexer. |
| `getApplication` | Fetches one application from the configured indexer. |

### Exported Transaction Operations

| API | Contract |
|-----|----------|
| `transactionParams` | Fetches current suggested transaction parameters from algod. |
| `waitForConfirmation` | Waits up to the supplied round timeout for a transaction identifier. |
| `pendingTransaction` | Fetches pending transaction status by identifier. |
| `submit` | Signs one transaction with one account and submits it. |
| `submitGroup` | Requires one signer per transaction, creates and signs an atomic group, and submits it. |
| `send` | Builds, signs, and submits a payment using suggested parameters and an optional UTF-8 note. |
| `sendAndWait` | Sends a payment and waits for confirmation. |
| `goOnline` | Builds, signs, and submits an online key-registration transaction. |
| `goOffline` | Builds, signs, and submits an offline key-registration transaction. |

### Exported Application Operations

| API | Contract |
|-----|----------|
| `createApplication` | Builds and submits an application-create transaction, waits, and returns its application index. |
| `callApplication` | Submits a NoOp call with optional arguments, accounts, foreign references, and boxes. |
| `optInToApplication` | Submits an application opt-in call. |
| `closeOutApplication` | Submits an application close-out call. |
| `updateApplication` | Submits replacement approval and clear-state programs. |
| `deleteApplication` | Submits an application deletion call. |

### Exported Asset Operations

| API | Contract |
|-----|----------|
| `createAsset` | Creates an ASA, defaulting manager and reserve to the creator, waits, and returns its asset index. |
| `optIn` | Submits the zero-value self-transfer required to opt an account into an ASA. |
| `transferAsset` | Signs and submits an ASA transfer. |
| `assetHoldings` | Returns account asset holdings, using an empty array when algod omits the field. |
| `closeOutAsset` | Sends the remaining holding to the recipient and closes the sender holding. |
| `freezeAsset` | Freezes or unfreezes a target holding using the supplied authority account. |
| `configureAsset` | Updates the ASA manager, reserve, freeze, and clawback addresses. |
| `destroyAsset` | Submits an ASA destruction transaction. |
| `clawbackAsset` | Moves ASA units from a target to a destination using the clawback authority. |

### Exported Atomic Composition and Units

| API | Contract |
|-----|----------|
| `atomic` | Creates an empty composer bound to the current `AlgoKit` actor. |
| `pay` | Appends a payment transaction to the composer and returns the composer. |
| `optInToAsset` | Appends an ASA opt-in transaction to the composer and returns the composer. |
| `add` | Appends a caller-built transaction and returns the composer. |
| `build` | Assigns an atomic group and returns an unsigned result. |
| `signedBy` | Signs a built group from an ordered account array or transaction-index mapping. |
| `submitAndWait` | Submits a signed group and waits for its first transaction confirmation. |
| `algos` | Converts a `Double` ALGO amount to `MicroAlgos`. |
| `microAlgos` | Constructs `MicroAlgos` from its base-unit `UInt64` amount. |

## Invariants

1. `AlgoKit` and its composer are actors; mutable composer state does not cross an actor boundary unsafely.
2. Every constructed transaction uses current suggested parameters, a validity window ending 1,000 rounds later, and
   the suggested genesis identifier and hash.
3. Operations that submit on behalf of an account sign with that account before network submission.
4. Atomic array signing and direct group submission require the signer count to match transaction count.
5. Indexer queries fail explicitly when the configuration contains no indexer URL.
6. Asset and application creation fail when confirmation lacks the corresponding created index.

## Behavioral Examples

- `AlgoKit(network: .testnet)` exposes both algod and indexer clients from the testnet configuration.
- `sendAndWait(from:to:amount:)` submits a signed payment and returns its confirmed pending-transaction record.
- `atomic().pay(...).transferAsset(...).build().signedBy([alice, bob])` constructs and signs one ordered group.
- `searchAssets()` on a custom algod-only configuration throws an indexer-not-configured network error.

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Invalid mnemonic | Account recovery propagates the Algorand mnemonic error. |
| Algod or indexer request failure | The asynchronous operation propagates the client error. |
| Missing indexer client | Indexer operations throw `AlgorandError.networkError`. |
| Missing created application or asset index | Creation throws `AlgorandError.networkError` after confirmation. |
| Transaction/signer count mismatch | `submitGroup` and array-based `signedBy` throw `AlgorandError.invalidTransaction`. |
| Invalid atomic group or signature | Group construction or signing propagates the Algorand error. |

## Dependencies

- `swift-algorand` supplies configuration, clients, accounts, transaction models, signing, responses, and units.
- Foundation supplies `Data`, `URL`, and UTF-8 note conversion.
- Consumers supply credentials, signer accounts, endpoints, transaction values, and authorization for network actions.

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Documented the existing API and behavior at complete source and export coverage. |
| 2026-07-13 | CHG-0002-document-the-existing-swift-algokit-api-at-complete-coverage-and-correct-rollout: Document the existing Swift AlgoKit API at complete coverage and correct rollout policy gaps |
