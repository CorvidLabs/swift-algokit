# swift-algokit

[![CI](https://img.shields.io/github/actions/workflow/status/CorvidLabs/swift-algokit/ci.yml?label=CI&branch=main)](https://github.com/CorvidLabs/swift-algokit/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/CorvidLabs/swift-algokit)](https://github.com/CorvidLabs/swift-algokit/blob/main/LICENSE)
[![Version](https://img.shields.io/github/v/release/CorvidLabs/swift-algokit)](https://github.com/CorvidLabs/swift-algokit/releases)

> **Pre-1.0 Notice**: This SDK is under active development. The API may change between minor versions until 1.0. Not yet audited by a third-party security firm.

A high-level Swift client for the Algorand blockchain. Built on [swift-algorand](https://github.com/CorvidLabs/swift-algorand) with Swift 6 and async/await.

## Features

- **Effortless Setup** - Connect to testnet, mainnet, or localnet with a single line
- **Simplified Transactions** - Send payments without manual parameter fetching
- **Asset Management** - Create, transfer, and manage ASAs with intuitive methods
- **Application Support** - Deploy and interact with smart contracts
- **Atomic Transactions** - Build transaction groups with a fluent DSL
- **Actor-Based** - Thread-safe by design using Swift concurrency
- **Multi-Platform** - iOS 15+, macOS 11+, tvOS 15+, watchOS 8+, visionOS 1+, Linux

## Installation

### Swift Package Manager

Add AlgoKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/CorvidLabs/swift-algokit.git", from: "0.0.1")
]

// Add the dependency to your target:
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "AlgoKit", package: "swift-algokit")
    ]
)
```

Or add it via Xcode:
1. File > Add Package Dependencies
2. Enter: `https://github.com/CorvidLabs/swift-algokit.git`

## Documentation

- **[Getting Started](documentation/GETTING_STARTED.md)** - Step-by-step guide for your first transaction
- **[Quick Start](documentation/QUICKSTART.md)** - Test the SDK in 5 minutes
- **[Testing Guide](documentation/TESTING.md)** - Comprehensive testing instructions
- **[Security](documentation/SECURITY.md)** - Best practices for production use
- **[Contributing](CONTRIBUTING.md)** - How to contribute to the project

## Quick Start

```swift
import AlgoKit

// Connect to a network
let algokit = AlgoKit(network: .testnet)

// Generate or recover an account
let account = try algokit.generateAccount()
// or: let account = try algokit.account(from: "your mnemonic...")

// Check balance
let balance = try await algokit.balance(of: account.address)
print("Balance: \(balance.algos) ALGO")

// Send a payment
let result = try await algokit.sendAndWait(
    from: account,
    to: receiver,
    amount: .algos(1.5),
    note: "Hello Algorand!"
)
print("Confirmed in round \(result.confirmedRound!)")
```

## Usage

### Network Configuration

```swift
// Predefined networks
let testnet = AlgoKit(network: .testnet)
let mainnet = AlgoKit(network: .mainnet)
let localnet = AlgoKit(network: .localnet)

// Custom endpoint
let custom = AlgoKit(configuration: .custom(
    algodURL: URL(string: "https://my-node.com")!,
    indexerURL: URL(string: "https://my-indexer.com")!,
    apiToken: "my-api-token"
))
```

### Asset Operations

```swift
// Create a fungible token
let assetID = try await algokit.createAsset(
    from: creator,
    name: "My Token",
    unitName: "MTK",
    total: 1_000_000,
    decimals: 6
)

// Opt-in to receive the asset
_ = try await algokit.optIn(account: receiver, toAsset: assetID)

// Transfer tokens
_ = try await algokit.transferAsset(
    assetID,
    from: sender,
    to: receiver.address,
    amount: 1000
)

// Check holdings
let holdings = try await algokit.assetHoldings(of: account.address)
```

### Atomic Transaction Groups

```swift
try await algokit.atomic()
    .pay(from: alice.address, to: bob.address, amount: .algos(5))
    .transferAsset(assetID, from: bob.address, to: alice.address, amount: 1000)
    .build()
    .signedBy([alice, bob])
    .submit()
```

### Application Operations

```swift
// Create an application
let appID = try await algokit.createApplication(
    from: creator,
    approvalProgram: approvalBytecode,
    clearStateProgram: clearBytecode,
    globalStateSchema: StateSchema(numUints: 1, numByteSlices: 1),
    localStateSchema: StateSchema(numUints: 0, numByteSlices: 0)
)

// Call the application
_ = try await algokit.callApplication(
    appID,
    from: caller,
    arguments: [Data("hello".utf8)]
)

// Opt-in to the application
_ = try await algokit.optInToApplication(appID, from: user)
```

### Advanced Usage

Access the underlying clients for custom transaction building:

```swift
// Direct access to AlgodClient
let params = try await algokit.algodClient.transactionParams()

// Build custom transaction
let tx = PaymentTransaction(
    sender: account.address,
    receiver: receiver,
    amount: .algos(1),
    firstValid: params.firstRound,
    lastValid: params.firstRound + 1000,
    genesisID: params.genesisID,
    genesisHash: params.genesisHash
)

// Submit via wrapper
let txid = try await algokit.submit(tx, signedBy: account)
```

## API Reference

### Account Operations

- `generateAccount()` - Create a new random account
- `account(from:)` - Recover an account from mnemonic
- `balance(of:)` - Get account balance
- `accountInfo(_:)` - Get full account information

### Payment Operations

- `send(from:to:amount:note:)` - Send Algos
- `sendAndWait(from:to:amount:note:timeout:)` - Send and wait for confirmation

### Asset Operations

- `createAsset(from:name:unitName:total:decimals:...)` - Create an ASA
- `optIn(account:toAsset:)` - Opt into an asset
- `transferAsset(_:from:to:amount:)` - Transfer an asset
- `assetHoldings(of:)` - Get asset holdings
- `closeOutAsset(_:from:to:)` - Close out of an asset
- `freezeAsset(_:from:target:frozen:)` - Freeze/unfreeze asset holdings
- `configureAsset(_:from:manager:reserve:freeze:clawback:)` - Update asset config
- `destroyAsset(_:from:)` - Destroy an asset
- `clawbackAsset(_:from:target:to:amount:)` - Claw back assets

### Application Operations

- `createApplication(from:approvalProgram:clearStateProgram:...)` - Create an app
- `callApplication(_:from:arguments:...)` - Call an app
- `optInToApplication(_:from:arguments:)` - Opt into an app
- `closeOutApplication(_:from:arguments:)` - Close out from an app
- `updateApplication(_:from:approvalProgram:clearStateProgram:...)` - Update an app
- `deleteApplication(_:from:arguments:)` - Delete an app

### Transaction Utilities

- `transactionParams()` - Get suggested transaction parameters
- `waitForConfirmation(_:timeout:)` - Wait for transaction confirmation
- `pendingTransaction(_:)` - Get pending transaction status
- `submit(_:signedBy:)` - Sign and submit a transaction
- `submitGroup(_:signedBy:)` - Sign and submit an atomic group

### Indexer Operations

- `searchTransactions(for:limit:)` - Search transactions
- `searchAssets(name:limit:)` - Search assets
- `getAsset(_:)` - Get asset information
- `getApplication(_:)` - Get application information

## Testing

The SDK supports testing against three networks:

### LocalNet (Recommended for Development)

```bash
# Start local Algorand network with Docker
docker-compose up -d

# Run integration tests
ALGORAND_NETWORK=localnet swift test

# Manual testing
ALGORAND_NETWORK=localnet swift run algokit-example
```

### TestNet (Public Test Network)

```bash
# Create account and get test funds
ALGORAND_NETWORK=testnet swift run algokit-example
# Fund at: https://bank.testnet.algorand.network/

# Test with your account
export ALGORAND_MNEMONIC="your 25 word mnemonic"
ALGORAND_NETWORK=testnet SEND_TRANSACTION=1 swift run algokit-example
```

### MainNet (Production)

```bash
# Read-only queries (safe)
ALGORAND_NETWORK=mainnet swift run algokit-example
```

See [Testing Guide](documentation/TESTING.md) for detailed testing instructions.

## Requirements

- Swift 6.0+
- iOS 15.0+ / macOS 11.0+ / tvOS 15.0+ / watchOS 8.0+ / visionOS 1.0+
- Linux (with Swift 6.0+)
- Docker (optional, for localnet testing)

## License

MIT License - See LICENSE file for details

## Examples

The repository includes runnable examples:

- Payment transaction examples
- Asset creation and management
- Application deployment and interaction
- Atomic transaction groups

Run the examples:
```bash
# Run with TestNet
ALGORAND_NETWORK=testnet swift run algokit-example

# Run with LocalNet
docker-compose up -d
ALGORAND_NETWORK=localnet swift run algokit-example
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Resources

- [Algorand Developer Portal](https://developer.algorand.org)
- [Algorand REST API](https://developer.algorand.org/docs/rest-apis/algod/)
- [Indexer API](https://developer.algorand.org/docs/rest-apis/indexer/)
- [swift-algorand](https://github.com/CorvidLabs/swift-algorand) - The underlying SDK

## Credits

Built with inspiration from the Swift Algorand SDK ecosystem and modern Swift best practices.
