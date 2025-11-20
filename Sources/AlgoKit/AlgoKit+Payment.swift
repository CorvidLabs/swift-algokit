import Algorand

// MARK: - Payment Operations

public extension AlgoKit {
    /// Sends Algos from one account to another.
    /// - Parameters:
    ///   - sender: The account to send from
    ///   - receiver: The address to send to
    ///   - amount: The amount to send
    ///   - note: Optional note to include
    /// - Returns: The transaction ID
    func send(
        from sender: Account,
        to receiver: Address,
        amount: MicroAlgos,
        note: String? = nil
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = PaymentTransaction(
            sender: sender.address,
            receiver: receiver,
            amount: amount,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash,
            note: note?.data(using: .utf8)
        )

        let signedTx = try SignedTransaction.sign(tx, with: sender)
        return try await algodClient.sendTransaction(signedTx)
    }

    /// Sends Algos and waits for confirmation.
    /// - Parameters:
    ///   - sender: The account to send from
    ///   - receiver: The address to send to
    ///   - amount: The amount to send
    ///   - note: Optional note to include
    ///   - timeout: Maximum rounds to wait for confirmation (default: 10)
    /// - Returns: The confirmed transaction result
    func sendAndWait(
        from sender: Account,
        to receiver: Address,
        amount: MicroAlgos,
        note: String? = nil,
        timeout: UInt64 = 10
    ) async throws -> PendingTransaction {
        let txid = try await send(from: sender, to: receiver, amount: amount, note: note)
        return try await waitForConfirmation(txid, timeout: timeout)
    }
}
