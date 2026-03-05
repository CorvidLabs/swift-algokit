import XCTest
@testable import AlgoKit
import Algorand

final class AtomicComposerTests: XCTestCase {

    private let genesisID = "testnet-v1.0"
    private let genesisHash = Data(repeating: 0, count: 32)

    private func makeAccount() async throws -> Account {
        let algokit = AlgoKit(network: .testnet)
        return try await algokit.generateAccount()
    }

    // MARK: - AtomicTransactionComposer Builder

    func test_composer_addCustomTransaction() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let tx = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let composer = await algokit.atomic()
        let returned = await composer.add(tx)
        XCTAssertNotNil(returned)
    }

    func test_composer_addMultipleCustomTransactions() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let tx2 = PaymentTransaction(
            sender: bob.address,
            receiver: alice.address,
            amount: .algos(2),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let composer = await algokit.atomic()
        let _ = await composer.add(tx1)
        let result = await composer.add(tx2)
        XCTAssertNotNil(result)
    }

    func test_composer_buildWithCustomTransactions() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(5),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let tx2 = PaymentTransaction(
            sender: bob.address,
            receiver: alice.address,
            amount: .algos(3),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let composer = await algokit.atomic()
        let _ = await composer.add(tx1)
        let _ = await composer.add(tx2)
        let result = try await composer.build()
        XCTAssertNotNil(result)
    }

    func test_composer_buildSingleTransaction() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let tx = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let composer = await algokit.atomic()
        let _ = await composer.add(tx)
        let result = try await composer.build()
        XCTAssertNotNil(result)
    }

    func test_composer_addMixedTransactionTypes() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let payTx = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let assetTx = AssetOptInTransaction(
            sender: bob.address,
            assetID: 12345,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let composer = await algokit.atomic()
        let _ = await composer.add(payTx)
        let _ = await composer.add(assetTx)
        let result = try await composer.build()
        XCTAssertNotNil(result)
    }

    // MARK: - AtomicTransactionResult Signing

    func test_result_signedByArray() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(5),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let tx2 = PaymentTransaction(
            sender: bob.address,
            receiver: alice.address,
            amount: .algos(3),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let composer = await algokit.atomic()
        let _ = await composer.add(tx1)
        let _ = await composer.add(tx2)
        let result = try await composer.build()

        let signed = try await result.signedBy([alice, bob])
        XCTAssertNotNil(signed)
    }

    func test_result_signedByDictionary() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(5),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let tx2 = PaymentTransaction(
            sender: bob.address,
            receiver: alice.address,
            amount: .algos(3),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let composer = await algokit.atomic()
        let _ = await composer.add(tx1)
        let _ = await composer.add(tx2)
        let result = try await composer.build()

        let signed = try await result.signedBy([0: alice, 1: bob])
        XCTAssertNotNil(signed)
    }

    func test_result_signedByArrayMismatchThrows() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(5),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let tx2 = PaymentTransaction(
            sender: bob.address,
            receiver: alice.address,
            amount: .algos(3),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let composer = await algokit.atomic()
        let _ = await composer.add(tx1)
        let _ = await composer.add(tx2)
        let result = try await composer.build()

        // Only provide 1 signer for 2 transactions
        do {
            _ = try await result.signedBy([alice])
            XCTFail("Expected error for mismatched signer count")
        } catch {
            // Expected: Number of signers must match number of transactions
        }
    }

    // MARK: - AtomicTransactionGroup

    func test_group_multipleTransactionsHaveGroupID() async throws {
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let tx2 = PaymentTransaction(
            sender: bob.address,
            receiver: alice.address,
            amount: .algos(2),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let tx3 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(3),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let group = try AtomicTransactionGroup(transactions: [tx1, tx2, tx3])
        XCTAssertEqual(group.transactions.count, 3)
        XCTAssertNotNil(group.groupID)
    }

    func test_group_differentTransactionsProduceDifferentGroupIDs() async throws {
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(1),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let tx2 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(2),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let group1 = try AtomicTransactionGroup(transactions: [tx1])
        let group2 = try AtomicTransactionGroup(transactions: [tx2])

        XCTAssertNotEqual(group1.groupID, group2.groupID)
    }

    func test_group_signWithPartialSigners_throws() async throws {
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(5),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let tx2 = PaymentTransaction(
            sender: bob.address,
            receiver: alice.address,
            amount: .algos(3),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let group = try AtomicTransactionGroup(transactions: [tx1, tx2])

        // Partial signing (missing signer for index 1) should throw
        do {
            _ = try SignedAtomicTransactionGroup.sign(group, with: [0: alice])
            XCTFail("Expected error for missing signer")
        } catch {
            // Expected: No account provided for transaction at index 1
        }
    }

    // MARK: - Transaction Group Validation

    func test_submitGroup_mismatchThrows() async throws {
        let algokit = AlgoKit(network: .testnet)
        let alice = try await makeAccount()
        let bob = try await makeAccount()

        let tx1 = PaymentTransaction(
            sender: alice.address,
            receiver: bob.address,
            amount: .algos(5),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let tx2 = PaymentTransaction(
            sender: bob.address,
            receiver: alice.address,
            amount: .algos(3),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        // 2 transactions but only 1 signer
        do {
            _ = try await algokit.submitGroup([tx1, tx2], signedBy: [alice])
            XCTFail("Expected error for mismatched counts")
        } catch {
            // Expected: Number of transactions must match number of signers
        }
    }
}
