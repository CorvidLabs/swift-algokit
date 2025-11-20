import Algorand
import Foundation

// MARK: - Application Operations

public extension AlgoKit {
    /// Creates a new application.
    /// - Parameters:
    ///   - creator: The account creating the application
    ///   - approvalProgram: The approval program bytecode
    ///   - clearStateProgram: The clear state program bytecode
    ///   - globalStateSchema: Schema for global state
    ///   - localStateSchema: Schema for local state
    ///   - appArguments: Optional application arguments
    ///   - extraPages: Optional extra program pages
    /// - Returns: The created application ID
    func createApplication(
        from creator: Account,
        approvalProgram: Data,
        clearStateProgram: Data,
        globalStateSchema: StateSchema,
        localStateSchema: StateSchema,
        appArguments: [Data]? = nil,
        extraPages: UInt64? = nil
    ) async throws -> UInt64 {
        let params = try await algodClient.transactionParams()

        let tx = ApplicationCallTransaction.create(
            sender: creator.address,
            approvalProgram: approvalProgram,
            clearStateProgram: clearStateProgram,
            globalStateSchema: globalStateSchema,
            localStateSchema: localStateSchema,
            appArguments: appArguments,
            extraPages: extraPages,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: creator)
        let txid = try await algodClient.sendTransaction(signedTx)
        let result = try await waitForConfirmation(txid)

        guard let appIndex = result.applicationIndex else {
            throw AlgorandError.networkError("Application creation confirmed but no app index returned")
        }

        return appIndex
    }

    /// Calls an application with NoOp.
    /// - Parameters:
    ///   - appID: The application ID
    ///   - caller: The account calling the application
    ///   - arguments: Optional application arguments
    ///   - accounts: Optional accounts to pass
    ///   - foreignApps: Optional foreign apps
    ///   - foreignAssets: Optional foreign assets
    ///   - boxes: Optional boxes
    /// - Returns: The transaction ID
    func callApplication(
        _ appID: UInt64,
        from caller: Account,
        arguments: [Data]? = nil,
        accounts: [Address]? = nil,
        foreignApps: [UInt64]? = nil,
        foreignAssets: [UInt64]? = nil,
        boxes: [(UInt64, Data)]? = nil
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = ApplicationCallTransaction.call(
            sender: caller.address,
            applicationID: appID,
            appArguments: arguments,
            accounts: accounts,
            foreignApps: foreignApps,
            foreignAssets: foreignAssets,
            boxes: boxes,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: caller)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Opts into an application.
    /// - Parameters:
    ///   - appID: The application ID
    ///   - account: The account opting in
    ///   - arguments: Optional application arguments
    /// - Returns: The transaction ID
    func optInToApplication(
        _ appID: UInt64,
        from account: Account,
        arguments: [Data]? = nil
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = ApplicationCallTransaction.optIn(
            sender: account.address,
            applicationID: appID,
            appArguments: arguments,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Closes out from an application.
    /// - Parameters:
    ///   - appID: The application ID
    ///   - account: The account closing out
    ///   - arguments: Optional application arguments
    /// - Returns: The transaction ID
    func closeOutApplication(
        _ appID: UInt64,
        from account: Account,
        arguments: [Data]? = nil
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = ApplicationCallTransaction.closeOut(
            sender: account.address,
            applicationID: appID,
            appArguments: arguments,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Updates an application.
    /// - Parameters:
    ///   - appID: The application ID
    ///   - account: The creator account
    ///   - approvalProgram: New approval program bytecode
    ///   - clearStateProgram: New clear state program bytecode
    ///   - arguments: Optional application arguments
    /// - Returns: The transaction ID
    func updateApplication(
        _ appID: UInt64,
        from account: Account,
        approvalProgram: Data,
        clearStateProgram: Data,
        arguments: [Data]? = nil
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = ApplicationCallTransaction.update(
            sender: account.address,
            applicationID: appID,
            approvalProgram: approvalProgram,
            clearStateProgram: clearStateProgram,
            appArguments: arguments,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Deletes an application.
    /// - Parameters:
    ///   - appID: The application ID
    ///   - account: The creator account
    ///   - arguments: Optional application arguments
    /// - Returns: The transaction ID
    func deleteApplication(
        _ appID: UInt64,
        from account: Account,
        arguments: [Data]? = nil
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = ApplicationCallTransaction.delete(
            sender: account.address,
            applicationID: appID,
            appArguments: arguments,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }
}
