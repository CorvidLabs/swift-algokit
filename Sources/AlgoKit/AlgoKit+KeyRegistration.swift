import Algorand
import Foundation

// MARK: - Key Registration Operations

public extension AlgoKit {
    /**
     Registers an account online for consensus participation.
     - Parameters:
       - account: The account to register online
       - voteKey: The vote public key (32 bytes)
       - selectionKey: The selection public key (32 bytes)
       - stateProofKey: The state proof key (64 bytes, optional)
       - voteFirst: First round for participation
       - voteLast: Last round for participation
       - voteKeyDilution: Key dilution parameter
     - Returns: The transaction ID
     */
    func goOnline(
        _ account: Account,
        voteKey: Data,
        selectionKey: Data,
        stateProofKey: Data? = nil,
        voteFirst: UInt64,
        voteLast: UInt64,
        voteKeyDilution: UInt64
    ) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = KeyRegistrationTransaction.online(
            sender: account.address,
            votePK: voteKey,
            selectionPK: selectionKey,
            voteFirst: voteFirst,
            voteLast: voteLast,
            voteKeyDilution: voteKeyDilution,
            stateProofPK: stateProofKey,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }

    /**
     Takes an account offline (stops consensus participation).
     - Parameter account: The account to take offline
     - Returns: The transaction ID
     */
    func goOffline(_ account: Account) async throws -> String {
        let params = try await algodClient.transactionParams()

        let tx = KeyRegistrationTransaction.offline(
            sender: account.address,
            firstValid: params.firstRound,
            lastValid: params.firstRound + 1000,
            genesisID: params.genesisID,
            genesisHash: params.genesisHash
        )

        let signedTx = try SignedTransaction.sign(tx, with: account)
        return try await algodClient.sendTransaction(signedTx)
    }
}
