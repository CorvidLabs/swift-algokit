import Algorand
import Foundation

// MARK: - Asset Operations

public extension AlgoKit {
    /// Creates a new asset.
    /// - Parameters:
    ///   - creator: The account creating the asset
    ///   - name: The asset name (max 32 characters)
    ///   - unitName: The asset unit name (max 8 characters)
    ///   - total: Total number of base units
    ///   - decimals: Number of decimal places (default: 0)
    ///   - url: Optional URL for more information
    ///   - metadataHash: Optional metadata hash
    ///   - manager: Optional manager address
    ///   - reserve: Optional reserve address
    ///   - freeze: Optional freeze address
    ///   - clawback: Optional clawback address
    /// - Returns: The created asset ID
    func createAsset(
        from creator: Account,
        name: String,
        unitName: String,
        total: UInt64,
        decimals: UInt64 = 0,
        url: String? = nil,
        metadataHash: Data? = nil,
        manager: Address? = nil,
        reserve: Address? = nil,
        freeze: Address? = nil,
        clawback: Address? = nil
    ) async throws -> UInt64 {
        let params = try await algodClient.transactionParams()

        let assetParams = AssetParams(
            total: total,
            decimals: decimals,
            unitName: unitName,
            assetName: name,
            url: url,
            metadataHash: metadataHash,
            manager: manager ?? creator.address,
            reserve: reserve ?? creator.address,
            freeze: freeze,
            clawback: clawback
        )

        let tx = AssetCreateTransaction(
            sender: creator.address,
            assetParams: assetParams,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: creator)
        let txid = try await algodClient.sendTransaction(signedTx)
        let result = try await waitForConfirmation(txid)

        guard let assetIndex = result.assetIndex else {
            throw AlgorandError.networkError("Asset creation confirmed but no asset index returned")
        }

        return assetIndex
    }

    /// Opts an account into an asset.
    /// - Parameters:
    ///   - account: The account to opt in
    ///   - assetID: The asset ID to opt into
    /// - Returns: The transaction ID
    func optIn(
        account: Account,
        toAsset assetID: UInt64
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = AssetOptInTransaction(
            sender: account.address,
            assetID: assetID,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Transfers an asset.
    /// - Parameters:
    ///   - assetID: The asset ID to transfer
    ///   - sender: The account to send from
    ///   - receiver: The address to send to
    ///   - amount: The amount in base units
    /// - Returns: The transaction ID
    func transferAsset(
        _ assetID: UInt64,
        from sender: Account,
        to receiver: Address,
        amount: UInt64
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = AssetTransferTransaction(
            sender: sender.address,
            receiver: receiver,
            assetID: assetID,
            amount: amount,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: sender)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Gets asset holdings for an account.
    /// - Parameter address: The account address
    /// - Returns: Array of asset holdings
    func assetHoldings(of address: Address) async throws -> [AssetHolding] {
        let info = try await algodClient.accountInformation(address)
        return info.assets ?? []
    }

    /// Closes out of an asset, sending all remaining balance to the specified address.
    /// - Parameters:
    ///   - assetID: The asset ID to close out
    ///   - account: The account closing out
    ///   - to: The address to send remaining balance to
    /// - Returns: The transaction ID
    func closeOutAsset(
        _ assetID: UInt64,
        from account: Account,
        to recipient: Address
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = AssetTransferTransaction(
            sender: account.address,
            receiver: recipient,
            assetID: assetID,
            amount: 0,
            closeRemainderTo: recipient,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Freezes or unfreezes an account's holdings of an asset.
    /// - Parameters:
    ///   - assetID: The asset ID
    ///   - account: The freeze authority account
    ///   - target: The account to freeze/unfreeze
    ///   - frozen: Whether to freeze (true) or unfreeze (false)
    /// - Returns: The transaction ID
    func freezeAsset(
        _ assetID: UInt64,
        from account: Account,
        target: Address,
        frozen: Bool
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = AssetFreezeTransaction(
            sender: account.address,
            assetID: assetID,
            freezeAccount: target,
            frozen: frozen,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Updates asset configuration addresses.
    /// - Parameters:
    ///   - assetID: The asset ID to configure
    ///   - account: The current manager account
    ///   - manager: New manager address (nil to clear)
    ///   - reserve: New reserve address (nil to clear)
    ///   - freeze: New freeze address (nil to clear)
    ///   - clawback: New clawback address (nil to clear)
    /// - Returns: The transaction ID
    func configureAsset(
        _ assetID: UInt64,
        from account: Account,
        manager: Address? = nil,
        reserve: Address? = nil,
        freeze: Address? = nil,
        clawback: Address? = nil
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = AssetConfigTransaction.update(
            sender: account.address,
            assetID: assetID,
            manager: manager,
            reserve: reserve,
            freeze: freeze,
            clawback: clawback,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Destroys an asset. Sender must be the manager and hold all units.
    /// - Parameters:
    ///   - assetID: The asset ID to destroy
    ///   - account: The manager account
    /// - Returns: The transaction ID
    func destroyAsset(
        _ assetID: UInt64,
        from account: Account
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = AssetConfigTransaction.destroy(
            sender: account.address,
            assetID: assetID,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Claws back assets from a target account to a destination.
    /// - Parameters:
    ///   - assetID: The asset ID
    ///   - account: The clawback authority account
    ///   - from: The account to claw back from
    ///   - to: The destination address
    ///   - amount: The amount to claw back
    /// - Returns: The transaction ID
    func clawbackAsset(
        _ assetID: UInt64,
        from account: Account,
        target: Address,
        to destination: Address,
        amount: UInt64
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = AssetClawbackTransaction(
            sender: account.address,
            assetID: assetID,
            assetSender: target,
            assetReceiver: destination,
            amount: amount,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }
}
