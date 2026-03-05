import XCTest
@testable import AlgoKit
import Algorand

final class IndexerAndNetworkTests: XCTestCase {

    // MARK: - Indexer Guard Clause Tests

    func test_searchTransactions_throwsWithoutIndexer() async {
        let config = AlgorandConfiguration.custom(
            algodURL: URL(string: "https://node.example.com")!,
            indexerURL: nil,
            apiToken: "test"
        )
        let algokit = AlgoKit(configuration: config)

        do {
            _ = try await algokit.searchTransactions()
            XCTFail("Expected error when indexer is not configured")
        } catch {
            // Expected: Indexer client not configured
        }
    }

    func test_searchAssets_throwsWithoutIndexer() async {
        let config = AlgorandConfiguration.custom(
            algodURL: URL(string: "https://node.example.com")!,
            indexerURL: nil,
            apiToken: "test"
        )
        let algokit = AlgoKit(configuration: config)

        do {
            _ = try await algokit.searchAssets()
            XCTFail("Expected error when indexer is not configured")
        } catch {
            // Expected: Indexer client not configured
        }
    }

    func test_getAsset_throwsWithoutIndexer() async {
        let config = AlgorandConfiguration.custom(
            algodURL: URL(string: "https://node.example.com")!,
            indexerURL: nil,
            apiToken: "test"
        )
        let algokit = AlgoKit(configuration: config)

        do {
            _ = try await algokit.getAsset(12345)
            XCTFail("Expected error when indexer is not configured")
        } catch {
            // Expected: Indexer client not configured
        }
    }

    func test_getApplication_throwsWithoutIndexer() async {
        let config = AlgorandConfiguration.custom(
            algodURL: URL(string: "https://node.example.com")!,
            indexerURL: nil,
            apiToken: "test"
        )
        let algokit = AlgoKit(configuration: config)

        do {
            _ = try await algokit.getApplication(12345)
            XCTFail("Expected error when indexer is not configured")
        } catch {
            // Expected: Indexer client not configured
        }
    }

    // MARK: - Network Configuration Tests

    func test_customConfig_withoutIndexer() async {
        let config = AlgorandConfiguration.custom(
            algodURL: URL(string: "https://node.example.com")!,
            indexerURL: nil,
            apiToken: "test"
        )
        let algokit = AlgoKit(configuration: config)

        let indexer = await algokit.indexerClient
        XCTAssertNil(indexer)
    }

    func test_customConfig_withIndexer() async {
        let config = AlgorandConfiguration.custom(
            algodURL: URL(string: "https://node.example.com")!,
            indexerURL: URL(string: "https://indexer.example.com")!,
            apiToken: "test"
        )
        let algokit = AlgoKit(configuration: config)

        let indexer = await algokit.indexerClient
        XCTAssertNotNil(indexer)
    }

    func test_testnet_hasIndexer() async {
        let algokit = AlgoKit(network: .testnet)
        let indexer = await algokit.indexerClient
        XCTAssertNotNil(indexer)
    }

    func test_mainnet_hasIndexer() async {
        let algokit = AlgoKit(network: .mainnet)
        let indexer = await algokit.indexerClient
        XCTAssertNotNil(indexer)
    }

    func test_localnet_hasIndexer() async {
        let algokit = AlgoKit(network: .localnet)
        let indexer = await algokit.indexerClient
        XCTAssertNotNil(indexer)
    }

    // MARK: - Configuration URL Tests

    func test_customConfig_preservesURL() async {
        let url = URL(string: "https://my-custom-node.example.com")!
        let config = AlgorandConfiguration.custom(
            algodURL: url,
            indexerURL: nil,
            apiToken: "my-token"
        )
        let algokit = AlgoKit(configuration: config)

        let storedConfig = await algokit.configuration
        XCTAssertEqual(storedConfig.algodURL, url)
    }

    func test_customNetworkInit_works() {
        let algodURL = URL(string: "https://custom-algod.example.com")!
        let indexerURL = URL(string: "https://custom-indexer.example.com")!
        let algokit = AlgoKit(network: .custom(algodURL: algodURL, indexerURL: indexerURL))
        XCTAssertNotNil(algokit)
    }

    // MARK: - Key Registration Transaction Tests (Extended)

    func test_keyRegistration_onlineWithStateProofKey() throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try algokit.generateAccount()

        let voteKey = Data(repeating: 1, count: 32)
        let selectionKey = Data(repeating: 2, count: 32)
        let stateProofKey = Data(repeating: 3, count: 64)

        let tx = KeyRegistrationTransaction.online(
            sender: account.address,
            votePK: voteKey,
            selectionPK: selectionKey,
            voteFirst: 1000,
            voteLast: 3_000_000,
            voteKeyDilution: 10000,
            stateProofPK: stateProofKey,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        XCTAssertEqual(tx.sender, account.address)
        XCTAssertEqual(tx.voteFirst, 1000)
        XCTAssertEqual(tx.voteLast, 3_000_000)
        XCTAssertEqual(tx.voteKeyDilution, 10000)
    }

    func test_keyRegistration_onlineCanBeSigned() throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try algokit.generateAccount()

        let tx = KeyRegistrationTransaction.online(
            sender: account.address,
            votePK: Data(repeating: 1, count: 32),
            selectionPK: Data(repeating: 2, count: 32),
            voteFirst: 1000,
            voteLast: 2_000_000,
            voteKeyDilution: 10000,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        let signed = try SignedTransaction.sign(tx, with: account)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    func test_keyRegistration_offlineCanBeSigned() throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try algokit.generateAccount()

        let tx = KeyRegistrationTransaction.offline(
            sender: account.address,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        let signed = try SignedTransaction.sign(tx, with: account)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    // MARK: - Payment Transaction Tests (Extended)

    func test_paymentTransaction_selfTransfer() throws {
        let algokit = AlgoKit(network: .testnet)
        let account = try algokit.generateAccount()

        let tx = PaymentTransaction(
            sender: account.address,
            receiver: account.address,
            amount: .algos(0),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32)
        )

        XCTAssertEqual(tx.sender, tx.receiver)
        XCTAssertEqual(tx.amount.value, 0)
    }

    func test_paymentTransaction_withEmptyNote() throws {
        let algokit = AlgoKit(network: .testnet)
        let sender = try algokit.generateAccount()
        let receiver = try algokit.generateAccount()

        let tx = PaymentTransaction(
            sender: sender.address,
            receiver: receiver.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: "testnet-v1.0",
            genesisHash: Data(repeating: 0, count: 32),
            note: Data()
        )

        XCTAssertEqual(tx.note, Data())
    }

    func test_paymentTransaction_withLargeNote() throws {
        let algokit = AlgoKit(network: .testnet)
        let sender = try algokit.generateAccount()
        let receiver = try algokit.generateAccount()
        let noteData = Data(repeating: 0x42, count: 1000)

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

        XCTAssertEqual(tx.note?.count, 1000)
    }

    // MARK: - MicroAlgos Extended Tests

    func test_microAlgos_precisionBoundary() {
        // Smallest non-zero amount
        let oneMicro = MicroAlgos.microAlgos(1)
        XCTAssertEqual(oneMicro.algos, 0.000001)

        // Verify round-trip
        let fromAlgos = MicroAlgos.algos(0.000001)
        XCTAssertEqual(fromAlgos.value, 1)
    }

    func test_microAlgos_multipleConversions() {
        let amounts: [(Double, UInt64)] = [
            (0.1, 100_000),
            (0.01, 10_000),
            (0.001, 1_000),
            (1.5, 1_500_000),
            (100.0, 100_000_000),
            (999.999999, 999_999_999),
        ]

        for (algos, expectedMicro) in amounts {
            let micro = MicroAlgos.algos(algos)
            XCTAssertEqual(micro.value, expectedMicro, "Failed for \(algos) ALGO")
        }
    }

    // MARK: - Account Tests (Extended)

    func test_account_multipleRecoveriesAreConsistent() throws {
        let algokit = AlgoKit(network: .testnet)
        let original = try algokit.generateAccount()
        let mnemonic = try original.mnemonic()

        let recovered1 = try algokit.account(from: mnemonic)
        let recovered2 = try algokit.account(from: mnemonic)

        XCTAssertEqual(recovered1.address, recovered2.address)
        XCTAssertEqual(recovered1.publicKey, recovered2.publicKey)
    }

    func test_account_differentAccountsHaveDifferentKeys() throws {
        let algokit = AlgoKit(network: .testnet)

        let accounts = try (0..<5).map { _ in try algokit.generateAccount() }
        let addresses = Set(accounts.map { $0.address.description })

        // All 5 accounts should have unique addresses
        XCTAssertEqual(addresses.count, 5)
    }
}
