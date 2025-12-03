import Algorand

// MARK: - Account Operations

public extension AlgoKit {
    /**
     Creates a new random account.
     - Returns: A new randomly generated account
     - Throws: `AlgorandError.encodingError` if key derivation fails
     */
    func generateAccount() throws -> Account {
        try Account()
    }

    /**
     Recovers an account from a mnemonic.
     - Parameter mnemonic: The 25-word mnemonic phrase
     - Returns: The recovered account
     - Throws: `AlgorandError.invalidMnemonic` if the mnemonic is invalid
     */
    func account(from mnemonic: String) throws -> Account {
        try Account(mnemonic: mnemonic)
    }

    /**
     Gets the balance of an account in microAlgos.
     - Parameter address: The account address
     - Returns: The account balance
     */
    func balance(of address: Address) async throws -> MicroAlgos {
        let info = try await algodClient.accountInformation(address)
        return MicroAlgos(info.amount)
    }

    /**
     Gets full account information.
     - Parameter address: The account address
     - Returns: The account information
     */
    func accountInfo(_ address: Address) async throws -> AccountInformation {
        try await algodClient.accountInformation(address)
    }
}
