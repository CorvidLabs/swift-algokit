import XCTest
@testable import AlgoKit
import Algorand

final class AlgoKitTests: XCTestCase {

    // MARK: - MicroAlgos Convenience Tests

    func test_microAlgos_algosConvertsCorrectly() {
        let oneAlgo = MicroAlgos.algos(1.0)
        XCTAssertEqual(oneAlgo.value, 1_000_000)

        let halfAlgo = MicroAlgos.algos(0.5)
        XCTAssertEqual(halfAlgo.value, 500_000)

        let tenAlgos = MicroAlgos.algos(10.0)
        XCTAssertEqual(tenAlgos.value, 10_000_000)
    }

    func test_microAlgos_microAlgosPreservesValue() {
        let micro = MicroAlgos.microAlgos(12345)
        XCTAssertEqual(micro.value, 12345)

        let zero = MicroAlgos.microAlgos(0)
        XCTAssertEqual(zero.value, 0)

        let large = MicroAlgos.microAlgos(1_000_000_000)
        XCTAssertEqual(large.value, 1_000_000_000)
    }

    func test_microAlgos_algosProperty() {
        let micro = MicroAlgos(1_500_000)
        XCTAssertEqual(micro.algos, 1.5)

        let oneMicro = MicroAlgos(1)
        XCTAssertEqual(oneMicro.algos, 0.000001)
    }

    func test_microAlgos_fractionalAlgos() {
        let amount = MicroAlgos.algos(0.123456)
        XCTAssertEqual(amount.value, 123456)
    }

    // MARK: - Initialization Tests

    func test_init_createsClientWithTestnet() {
        let algokit = AlgoKit(network: .testnet)
        XCTAssertNotNil(algokit)
    }

    func test_init_createsClientWithMainnet() {
        let algokit = AlgoKit(network: .mainnet)
        XCTAssertNotNil(algokit)
    }

    func test_init_createsClientWithLocalnet() {
        let algokit = AlgoKit(network: .localnet)
        XCTAssertNotNil(algokit)
    }

    func test_init_createsClientWithConfiguration() async {
        let algokit = AlgoKit(network: .testnet)
        let config = await algokit.configuration
        XCTAssertNotNil(config.algodURL)
        XCTAssertNotNil(config.indexerURL)
    }

    func test_init_customConfiguration() {
        let customURL = URL(string: "https://custom-node.example.com")!
        let indexerURL = URL(string: "https://custom-indexer.example.com")!
        let config = AlgorandConfiguration.custom(
            algodURL: customURL,
            indexerURL: indexerURL,
            apiToken: "test-token"
        )
        let algokit = AlgoKit(configuration: config)
        XCTAssertNotNil(algokit)
    }

    func test_init_hasAlgodClient() async {
        let algokit = AlgoKit(network: .testnet)
        let client = await algokit.algodClient
        XCTAssertNotNil(client)
    }

    func test_init_hasIndexerClient() async {
        let algokit = AlgoKit(network: .testnet)
        let indexer = await algokit.indexerClient
        XCTAssertNotNil(indexer)
    }

    // MARK: - Account Tests

    func test_generateAccount_createsValidAccount() async throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try await algokit.generateAccount()

        XCTAssertEqual(account.publicKey.count, 32)
        XCTAssertFalse(try account.mnemonic().isEmpty)
    }

    func test_generateAccount_createsUniqueAccounts() async throws {
        let algokit = AlgoKit(network: .testnet)
        let account1 = try await algokit.generateAccount()
        let account2 = try await algokit.generateAccount()

        XCTAssertNotEqual(account1.address, account2.address)
        XCTAssertNotEqual(try account1.mnemonic(), try account2.mnemonic())
    }

    func test_account_recoversFromMnemonic() async throws {
        let algokit = AlgoKit(network: .testnet)
        let account1 = try await algokit.generateAccount()
        let account2 = try await algokit.account(from: account1.mnemonic())

        XCTAssertEqual(account1.address, account2.address)
        XCTAssertEqual(account1.publicKey, account2.publicKey)
    }

    func test_account_mnemonicHas25Words() async throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try await algokit.generateAccount()

        let words = try account.mnemonic().split(separator: " ")
        XCTAssertEqual(words.count, 25)
    }

    func test_account_invalidMnemonicThrows() async {
        let algokit = AlgoKit(network: .testnet)

        do {
            _ = try await algokit.account(from: "invalid mnemonic words")
            XCTFail("Expected error for invalid mnemonic")
        } catch {
            // Expected
        }
    }

    func test_account_addressFormat() async throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try await algokit.generateAccount()

        // Algorand addresses are 58 characters (base32 encoded)
        XCTAssertEqual(account.address.description.count, 58)
    }

    // MARK: - Network Configuration Tests

    func test_testnetConfiguration() {
        let config = AlgorandConfiguration(network: .testnet)
        XCTAssertTrue(config.algodURL.absoluteString.contains("testnet"))
    }

    func test_mainnetConfiguration() {
        let config = AlgorandConfiguration(network: .mainnet)
        XCTAssertTrue(config.algodURL.absoluteString.contains("mainnet"))
    }

    func test_localnetConfiguration() {
        let config = AlgorandConfiguration(network: .localnet)
        XCTAssertTrue(config.algodURL.absoluteString.contains("localhost"))
    }

    // MARK: - AtomicTransactionComposer Tests

    func test_atomic_createsComposer() async {
        let algokit = AlgoKit(network: .testnet)
        let composer = await algokit.atomic()
        XCTAssertNotNil(composer)
    }

    // MARK: - Transaction Signing Tests

    func test_signedTransaction_signsPayment() async throws {
        let algokit = AlgoKit(network: .testnet)
        let sender = try await algokit.generateAccount()
        let receiver = try await algokit.generateAccount()

        // Create a payment transaction with mock params
        let tx = PaymentTransaction(
            sender: sender.address,
            receiver: receiver.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        let signedTx = try SignedTransaction.sign(tx, with: sender)
        XCTAssertNotNil(signedTx)
        XCTAssertFalse(signedTx.signature.isEmpty)
    }

    func test_signedTransaction_differentSignersProduceDifferentSignatures() async throws {
        let algokit = AlgoKit(network: .testnet)
        let sender1 = try await algokit.generateAccount()
        let sender2 = try await algokit.generateAccount()
        let receiver = try await algokit.generateAccount()

        let tx1 = PaymentTransaction(
            sender: sender1.address,
            receiver: receiver.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        let tx2 = PaymentTransaction(
            sender: sender2.address,
            receiver: receiver.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        let signed1 = try SignedTransaction.sign(tx1, with: sender1)
        let signed2 = try SignedTransaction.sign(tx2, with: sender2)

        XCTAssertNotEqual(signed1.signature, signed2.signature)
    }

    // MARK: - Atomic Transaction Group Tests

    func test_atomicGroup_createsValidGroup() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await algokit.generateAccount()
        let bob = try await algokit.generateAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(5),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        let tx2 = PaymentTransaction(
            sender: bob.address,
            receiver: alice.address,
            amount: .algos(3),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        let group = try AtomicTransactionGroup(transactions: [tx1, tx2])
        XCTAssertEqual(group.transactions.count, 2)
        XCTAssertNotNil(group.groupID)
    }

    func test_atomicGroup_requiresMultipleTransactions() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await algokit.generateAccount()
        let bob = try await algokit.generateAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(5),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        // Single transaction should still work
        let group = try AtomicTransactionGroup(transactions: [tx1])
        XCTAssertEqual(group.transactions.count, 1)
    }

    func test_signedAtomicGroup_signsCorrectly() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await algokit.generateAccount()
        let bob = try await algokit.generateAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(5),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        let tx2 = PaymentTransaction(
            sender: bob.address,
            receiver: alice.address,
            amount: .algos(3),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        let group = try AtomicTransactionGroup(transactions: [tx1, tx2])
        let signedGroup = try SignedAtomicTransactionGroup.sign(group, with: [0: alice, 1: bob])

        XCTAssertEqual(signedGroup.signedTransactions.count, 2)
    }

    // MARK: - Asset Transaction Tests

    func test_assetCreateTransaction_buildsCorrectly() async throws {
        let algokit = AlgoKit(network: .testnet)
        let creator = try await algokit.generateAccount()

        let assetParams = AssetParams(
            total: 1_000_000,
            decimals: 6,
            unitName: "TEST",
            assetName: "Test Asset",
            manager: creator.address,
            reserve: creator.address
        )

        let tx = AssetCreateTransaction(
            sender: creator.address,
            assetParams: assetParams,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        XCTAssertEqual(tx.sender, creator.address)
        XCTAssertEqual(tx.assetParams.total, 1_000_000)
        XCTAssertEqual(tx.assetParams.decimals, 6)
    }

    func test_assetOptInTransaction_buildsCorrectly() async throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try await algokit.generateAccount()

        let tx = AssetOptInTransaction(
            sender: account.address,
            assetID: 12345,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        XCTAssertEqual(tx.sender, account.address)
        XCTAssertEqual(tx.assetID, 12345)
    }

    func test_assetTransferTransaction_buildsCorrectly() async throws {
        let algokit = AlgoKit(network: .testnet)
        let sender = try await algokit.generateAccount()
        let receiver = try await algokit.generateAccount()

        let tx = AssetTransferTransaction(
            sender: sender.address,
            receiver: receiver.address,
            assetID: 12345,
            amount: 1000,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        XCTAssertEqual(tx.sender, sender.address)
        XCTAssertEqual(tx.receiver, receiver.address)
        XCTAssertEqual(tx.assetID, 12345)
        XCTAssertEqual(tx.amount, 1000)
    }

    // MARK: - Application Transaction Tests

    func test_applicationCallTransaction_buildsCorrectly() async throws {
        let algokit = AlgoKit(network: .testnet)
        let caller = try await algokit.generateAccount()

        let tx = ApplicationCallTransaction.call(
            sender: caller.address,
            applicationID: 12345,
            appArguments: ["test".data(using: .utf8)!],
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        XCTAssertEqual(tx.sender, caller.address)
        XCTAssertEqual(tx.applicationID, 12345)
    }

    func test_applicationOptInTransaction_buildsCorrectly() async throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try await algokit.generateAccount()

        let tx = ApplicationCallTransaction.optIn(
            sender: account.address,
            applicationID: 12345,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        XCTAssertEqual(tx.sender, account.address)
        XCTAssertEqual(tx.applicationID, 12345)
    }

    // MARK: - Key Registration Transaction Tests

    func test_keyRegistrationOnline_buildsCorrectly() async throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try await algokit.generateAccount()

        let voteKey = Data(repeating: 1, count: 32)
        let selectionKey = Data(repeating: 2, count: 32)

        let tx = KeyRegistrationTransaction.online(
            sender: account.address,
            votePK: voteKey,
            selectionPK: selectionKey,
            voteFirst: 1000,
            voteLast: 2_000_000,
            voteKeyDilution: 10000,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        XCTAssertEqual(tx.sender, account.address)
        XCTAssertEqual(tx.voteFirst, 1000)
        XCTAssertEqual(tx.voteLast, 2_000_000)
    }

    func test_keyRegistrationOffline_buildsCorrectly() async throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try await algokit.generateAccount()

        let tx = KeyRegistrationTransaction.offline(
            sender: account.address,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        XCTAssertEqual(tx.sender, account.address)
        XCTAssertNil(tx.votePK)
        XCTAssertNil(tx.selectionPK)
    }

    // MARK: - Address Tests

    func test_address_validFormat() async throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try await algokit.generateAccount()

        // Address should be valid base32
        let addressString = account.address.description
        XCTAssertFalse(addressString.isEmpty)

        // Should be able to recreate from string
        let recreated = try Address(string: addressString)
        XCTAssertEqual(account.address, recreated)
    }

    func test_address_invalidThrows() {
        do {
            _ = try Address(string: "invalid-address")
            XCTFail("Expected error for invalid address")
        } catch {
            // Expected
        }
    }

    // MARK: - Payment Transaction Tests

    func test_paymentTransaction_withNote() async throws {
        let algokit = AlgoKit(network: .testnet)
        let sender = try await algokit.generateAccount()
        let receiver = try await algokit.generateAccount()

        let noteData = "Hello Algorand!".data(using: .utf8)

        let tx = PaymentTransaction(
            sender: sender.address,
            receiver: receiver.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32),
            note: noteData
        )

        XCTAssertEqual(tx.note, noteData)
    }

    func test_paymentTransaction_withCloseRemainder() async throws {
        let algokit = AlgoKit(network: .testnet)
        let sender = try await algokit.generateAccount()
        let receiver = try await algokit.generateAccount()
        let closeRemainder = try await algokit.generateAccount()

        let tx = PaymentTransaction(
            sender: sender.address,
            receiver: receiver.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32),
            closeRemainderTo: closeRemainder.address
        )

        XCTAssertEqual(tx.closeRemainderTo, closeRemainder.address)
    }

    // MARK: - Edge Cases

    func test_microAlgos_zero() {
        let zero = MicroAlgos.algos(0)
        XCTAssertEqual(zero.value, 0)
        XCTAssertEqual(zero.algos, 0)
    }

    func test_microAlgos_largeAmount() {
        // Max supply is ~10 billion ALGO
        let large = MicroAlgos.algos(10_000_000_000)
        XCTAssertEqual(large.value, 10_000_000_000_000_000)
    }
}
