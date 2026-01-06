@preconcurrency import Foundation
public import Algorand

/**
 A high-level client for interacting with the Algorand blockchain.

 `AlgoKit` simplifies common blockchain operations including account management,
 payments, and asset operations with a clean, Swift-native API.

 ## Requirements

 - iOS 15.0+ / macOS 11.0+ / tvOS 15.0+ / watchOS 8.0+ / visionOS 1.0+
 - Swift 6.0+

 ## Key Features

 - **Effortless Setup**: Connect to testnet, mainnet, or localnet with a single line
 - **Simplified Transactions**: Send payments without manual parameter fetching
 - **Asset Management**: Create, transfer, and manage ASAs with intuitive methods
 - **Type-Safe**: Leverages Swift's type system for compile-time safety
 - **Actor-Based**: Thread-safe by design using Swift concurrency
 - **Power User Access**: Direct access to underlying `AlgodClient` when needed

 ## Getting Started

 ```swift
 // Connect to a network
 let algokit = AlgoKit(network: .testnet)

 // Recover an account from mnemonic
 let account = try algokit.account(from: "abandon abandon abandon...")

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

 Connect to predefined networks or custom endpoints:

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

 Create and manage Algorand Standard Assets (ASAs):

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

 Execute multiple transactions atomically:

 ```swift
 let params = try await algokit.transactionParams()

 let tx1 = PaymentTransaction(
     sender: alice.address,
     receiver: bob.address,
     amount: .algos(5),
     firstValid: params.firstRound,
     lastValid: params.firstRound + 1000,
     genesisID: params.genesisID,
     genesisHash: params.genesisHash
 )

 let tx2 = PaymentTransaction(
     sender: bob.address,
     receiver: alice.address,
     amount: .algos(3),
     firstValid: params.firstRound,
     lastValid: params.firstRound + 1000,
     genesisID: params.genesisID,
     genesisHash: params.genesisHash
 )

 // Submit as atomic group - all succeed or all fail
 let txid = try await algokit.submitGroup(
     [tx1, tx2],
     signedBy: [alice, bob]
 )
 ```

 ## Advanced Usage

 Access the underlying clients for custom transaction building:

 ```swift
 let algokit = AlgoKit(network: .testnet)

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
 */
public actor AlgoKit {

    // MARK: - Properties

    /// The configuration used by this client
    public let configuration: AlgorandConfiguration

    /// The underlying algod client
    public let algodClient: AlgodClient

    /// The underlying indexer client (if available)
    public let indexerClient: IndexerClient?

    // MARK: - Initialization

    /**
     Creates a new AlgoKit client with the specified configuration.
     - Parameter configuration: The configuration to use
     */
    public init(configuration: AlgorandConfiguration) {
        self.configuration = configuration
        self.algodClient = AlgodClient(baseURL: configuration.algodURL, apiToken: configuration.apiToken)

        if let indexerURL = configuration.indexerURL {
            self.indexerClient = IndexerClient(baseURL: indexerURL, apiToken: configuration.apiToken)
        } else {
            self.indexerClient = nil
        }
    }

    /**
     Creates a new AlgoKit client for the specified network.
     - Parameter network: The network to connect to
     */
    public init(network: AlgorandConfiguration.Network) {
        let configuration: AlgorandConfiguration
        switch network {
        case .localnet:
            configuration = .localnet()
        case .testnet:
            configuration = .testnet()
        case .mainnet:
            configuration = .mainnet()
        case .custom(let algodURL, let indexerURL):
            configuration = .custom(algodURL: algodURL, indexerURL: indexerURL)
        }
        self.init(configuration: configuration)
    }
}
