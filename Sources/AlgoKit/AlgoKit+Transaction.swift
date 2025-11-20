import Algorand

// MARK: - Transaction Utilities

public extension AlgoKit {
    /// Gets current transaction parameters.
    /// - Returns: The suggested transaction parameters
    func transactionParams() async throws -> TransactionParams {
        try await algodClient.transactionParams()
    }

    /// Waits for a transaction to be confirmed.
    /// - Parameters:
    ///   - txid: The transaction ID
    ///   - timeout: Maximum rounds to wait (default: 10)
    /// - Returns: The confirmed transaction
    func waitForConfirmation(
        _ txid: String,
        timeout: UInt64 = 10
    ) async throws -> PendingTransaction {
        try await algodClient.waitForConfirmation(transactionID: txid, timeout: timeout)
    }

    /// Gets the status of a pending transaction.
    /// - Parameter txid: The transaction ID
    /// - Returns: The pending transaction status
    func pendingTransaction(_ txid: String) async throws -> PendingTransaction {
        try await algodClient.pendingTransaction(txid)
    }

    /// Signs and submits a transaction.
    /// - Parameters:
    ///   - transaction: The transaction to submit
    ///   - account: The account to sign with
    /// - Returns: The transaction ID
    func submit(
        _ transaction: any Transaction,
        signedBy account: Account
    ) async throws -> String {
        let signedTx = try SignedTransaction.sign(transaction, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Signs and submits an atomic transaction group.
    /// - Parameters:
    ///   - transactions: The transactions to group and submit
    ///   - signers: The accounts to sign with (must match transaction order)
    /// - Returns: The transaction ID of the first transaction
    func submitGroup(
        _ transactions: [any Transaction],
        signedBy signers: [Account]
    ) async throws -> String {
        guard transactions.count == signers.count else {
            throw AlgorandError.invalidTransaction("Number of transactions must match number of signers")
        }

        let group = try AtomicTransactionGroup(transactions: transactions)

        var accounts: [Int: Account] = [:]
        for (index, account) in signers.enumerated() {
            accounts[index] = account
        }

        let signedGroup = try SignedAtomicTransactionGroup.sign(group, with: accounts)
        return try await algodClient.sendTransactionGroup(signedGroup)
    }
}
