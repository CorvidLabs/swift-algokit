@preconcurrency import Foundation
public import Algorand

// MARK: - Atomic Transaction Composer

/**
     A fluent builder for creating and submitting atomic transaction groups.

     Use the `atomic()` method on `AlgoKit` to create a new composer:

     ```swift
     try await algokit.atomic()
         .pay(from: alice.address, to: bob.address, amount: .algos(5))
         .transferAsset(assetID, from: bob.address, to: alice.address, amount: 1000)
         .build()
         .signedBy([alice, bob])
         .submit()
     ```
 */
public actor AtomicTransactionComposer {

    // MARK: - Properties

    private let algokit: AlgoKit
    private var transactions: [any Transaction] = []

    // MARK: - Initialization

    /**
     Creates a new atomic transaction composer.
     - Parameter algokit: The AlgoKit client to use for fetching transaction parameters
     */
    public init(algokit: AlgoKit) {
        self.algokit = algokit
    }

    // MARK: - Builder Methods

    /**
     Adds a payment transaction to the group.
     - Parameters:
       - sender: The sender address
       - receiver: The receiver address
       - amount: The amount to send
       - note: Optional note to include
     - Returns: Self for method chaining
     */
    @discardableResult
    public func pay(
        from sender: Address,
        to receiver: Address,
        amount: MicroAlgos,
        note: String? = nil
    ) async throws -> Self {
        let params = try await algokit.transactionParams()

        let tx = PaymentTransaction(
            sender: sender,
            receiver: receiver,
            amount: amount,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash,
            note: note?.data(using: .utf8)
        )

        transactions.append(tx)
        return self
    }

    /**
     Adds an asset transfer transaction to the group.
     - Parameters:
       - assetID: The asset ID to transfer
       - sender: The sender address
       - receiver: The receiver address
       - amount: The amount in base units
     - Returns: Self for method chaining
     */
    @discardableResult
    public func transferAsset(
        _ assetID: UInt64,
        from sender: Address,
        to receiver: Address,
        amount: UInt64
    ) async throws -> Self {
        let params = try await algokit.transactionParams()

        let tx = AssetTransferTransaction(
            sender: sender,
            receiver: receiver,
            assetID: assetID,
            amount: amount,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        transactions.append(tx)
        return self
    }

    /**
     Adds an asset opt-in transaction to the group.
     - Parameters:
       - assetID: The asset ID to opt into
       - account: The account address opting in
     - Returns: Self for method chaining
     */
    @discardableResult
    public func optInToAsset(
        _ assetID: UInt64,
        from account: Address
    ) async throws -> Self {
        let params = try await algokit.transactionParams()

        let tx = AssetOptInTransaction(
            sender: account,
            assetID: assetID,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        transactions.append(tx)
        return self
    }

    /**
     Adds an application call transaction to the group.
     - Parameters:
       - appID: The application ID to call
       - sender: The sender address
       - arguments: Optional application arguments
     - Returns: Self for method chaining
     */
    @discardableResult
    public func callApplication(
        _ appID: UInt64,
        from sender: Address,
        arguments: [Data]? = nil
    ) async throws -> Self {
        let params = try await algokit.transactionParams()

        let tx = ApplicationCallTransaction.call(
            sender: sender,
            applicationID: appID,
            appArguments: arguments,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        transactions.append(tx)
        return self
    }

    /**
     Adds a custom transaction to the group.
     - Parameter transaction: The transaction to add
     - Returns: Self for method chaining
     */
    @discardableResult
    public func add(_ transaction: any Transaction) -> Self {
        transactions.append(transaction)
        return self
    }

    /// Builds and returns the result for signing.
    /// - Returns: The atomic transaction result ready for signing
    public func build() throws -> AtomicTransactionResult {
        let group = try AtomicTransactionGroup(transactions: transactions)
        return AtomicTransactionResult(group: group, algokit: algokit)
    }
}

// MARK: - Atomic Transaction Result

/// Represents a built atomic transaction group ready for signing.
public struct AtomicTransactionResult: Sendable {

    // MARK: - Properties

    private let group: AtomicTransactionGroup
    private let algokit: AlgoKit

    // MARK: - Initialization

    /**
     Creates a new atomic transaction result.
     - Parameters:
       - group: The transaction group
       - algokit: The AlgoKit client
     */
    init(group: AtomicTransactionGroup, algokit: AlgoKit) {
        self.group = group
        self.algokit = algokit
    }

    // MARK: - Public Methods

    /**
     Signs the transaction group with the provided accounts.
     - Parameter signers: The accounts to sign with (must match transaction order)
     - Returns: The signed atomic transaction result
     */
    public func signedBy(_ signers: [Account]) async throws -> SignedAtomicTransactionResult {
        guard signers.count == group.transactions.count else {
            throw AlgorandError.invalidTransaction("Number of signers must match number of transactions")
        }

        var accounts: [Int: Account] = [:]
        for (index, account) in signers.enumerated() {
            accounts[index] = account
        }

        let signed = try SignedAtomicTransactionGroup.sign(group, with: accounts)
        return SignedAtomicTransactionResult(signedGroup: signed, algokit: algokit)
    }

    /**
     Signs the transaction group with a mapping of indices to accounts.
     - Parameter signers: The accounts indexed by transaction position
     - Returns: The signed atomic transaction result
     */
    public func signedBy(_ signers: [Int: Account]) async throws -> SignedAtomicTransactionResult {
        let signed = try SignedAtomicTransactionGroup.sign(group, with: signers)
        return SignedAtomicTransactionResult(signedGroup: signed, algokit: algokit)
    }
}

// MARK: - Signed Atomic Transaction Result

/// Represents a signed atomic transaction group ready for submission.
public struct SignedAtomicTransactionResult: Sendable {

    // MARK: - Properties

    private let signedGroup: SignedAtomicTransactionGroup
    private let algokit: AlgoKit

    // MARK: - Initialization

    /**
     Creates a new signed atomic transaction result.
     - Parameters:
       - signedGroup: The signed transaction group
       - algokit: The AlgoKit client
     */
    init(signedGroup: SignedAtomicTransactionGroup, algokit: AlgoKit) {
        self.signedGroup = signedGroup
        self.algokit = algokit
    }

    // MARK: - Public Methods

    /// Submits the transaction group to the network.
    /// - Returns: The transaction ID
    public func submit() async throws -> String {
        try await algokit.algodClient.sendTransactionGroup(signedGroup)
    }

    /**
     Submits the transaction group and waits for confirmation.
     - Parameter timeout: Maximum rounds to wait (default: 10)
     - Returns: The confirmed transaction
     */
    public func submitAndWait(timeout: UInt64 = 10) async throws -> PendingTransaction {
        let txid = try await submit()
        return try await algokit.waitForConfirmation(txid, timeout: timeout)
    }
}

// MARK: - AlgoKit Extension

public extension AlgoKit {
    /**
     Creates a new atomic transaction composer for building transaction groups.

     Example usage:
     ```swift
     try await algokit.atomic()
         .pay(from: alice.address, to: bob.address, amount: .algos(5))
         .transferAsset(assetID, from: bob.address, to: alice.address, amount: 1000)
         .build()
         .signedBy([alice, bob])
         .submit()
     ```

     - Returns: A new atomic transaction composer
     */
    func atomic() -> AtomicTransactionComposer {
        AtomicTransactionComposer(algokit: self)
    }
}
