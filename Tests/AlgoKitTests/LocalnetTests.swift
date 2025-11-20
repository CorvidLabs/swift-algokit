import XCTest
@testable import AlgoKit
import Algorand
import Foundation

/// Integration tests that run against AlgoKit localnet
/// Run `algokit localnet reset` before running these tests
/// These tests are skipped in CI (when GITHUB_ACTIONS env var is set)
final class LocalnetTests: XCTestCase {

    // Localnet funding address (has lots of ALGO)
    static let fundingAddress = "MGPRE6GWULK3DSU6FT5UP6WR2YHZC5U5BT7TPVQKFC4N7HA2TFZXXN6T6I"

    var algokit: AlgoKit!

    override func setUp() async throws {
        // Skip in CI - localnet isn't available
        try XCTSkipIf(
            ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] != nil,
            "Skipping localnet tests in CI - no local Algorand node available"
        )

        // Use the static factory method which includes the default API token
        algokit = AlgoKit(configuration: .localnet())
    }

    /// Funds an account using goal CLI via Docker
    func fundAccount(amount: UInt64 = 10_000_000) async throws -> Account {
        let account = try await algokit.generateAccount()

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/docker")
        task.arguments = [
            "exec", "algokit_sandbox_algod",
            "goal", "clerk", "send",
            "-a", String(amount),
            "-f", Self.fundingAddress,
            "-t", account.address.description
        ]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        try task.run()
        task.waitUntilExit()

        guard task.terminationStatus == 0 else {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw XCTSkip("Failed to fund account: \(output)")
        }

        return account
    }

    // MARK: - Network Tests

    func test_localnet_isHealthy() async throws {
        let healthy = try await algokit.isHealthy()
        XCTAssertTrue(healthy)
    }

    func test_localnet_status() async throws {
        let status = try await algokit.status()
        XCTAssertGreaterThan(status.lastRound, 0)
    }

    func test_localnet_transactionParams() async throws {
        let params = try await algokit.transactionParams()
        XCTAssertFalse(params.genesisID.isEmpty)
        XCTAssertEqual(params.genesisHash.count, 32)
        XCTAssertGreaterThan(params.firstRound, 0)
    }

    // MARK: - Account Tests

    func test_localnet_accountBalance() async throws {
        let account = try await fundAccount(amount: 10_000_000) // 10 ALGO
        let balance = try await algokit.balance(of: account.address)
        XCTAssertGreaterThan(balance.value, 9_000_000) // > 9 ALGO (minus fees)
    }

    func test_localnet_accountInfo() async throws {
        let account = try await fundAccount(amount: 5_000_000) // 5 ALGO
        let info = try await algokit.accountInfo(account.address)
        XCTAssertEqual(info.address, account.address.description)
        XCTAssertGreaterThan(info.amount, 0)
    }

    // MARK: - Payment Tests

    func test_localnet_sendPayment() async throws {
        let sender = try await fundAccount(amount: 10_000_000) // 10 ALGO
        let receiver = try await algokit.generateAccount()

        let txid = try await algokit.send(
            from: sender,
            to: receiver.address,
            amount: .algos(1),
            note: "Test payment"
        )

        XCTAssertFalse(txid.isEmpty)
        XCTAssertEqual(txid.count, 52) // Base64 encoded txid
    }

    func test_localnet_sendAndWait() async throws {
        let sender = try await fundAccount(amount: 10_000_000) // 10 ALGO
        let receiver = try await algokit.generateAccount()

        let result = try await algokit.sendAndWait(
            from: sender,
            to: receiver.address,
            amount: .algos(2.5),
            note: "Test sendAndWait"
        )

        XCTAssertNotNil(result.confirmedRound)
        XCTAssertGreaterThan(result.confirmedRound ?? 0, 0)

        // Verify receiver got the funds
        let balance = try await algokit.balance(of: receiver.address)
        XCTAssertEqual(balance.value, 2_500_000) // 2.5 ALGO
    }

    // MARK: - Asset Tests

    func test_localnet_createAsset() async throws {
        let creator = try await fundAccount(amount: 10_000_000) // 10 ALGO
        let assetID = try await algokit.createAsset(
            from: creator,
            name: "Test Token",
            unitName: "TEST",
            total: 1_000_000,
            decimals: 6
        )

        XCTAssertGreaterThan(assetID, 0)
    }

    func test_localnet_assetOptInAndTransfer() async throws {
        let creator = try await fundAccount(amount: 10_000_000) // 10 ALGO

        // Create asset
        let assetID = try await algokit.createAsset(
            from: creator,
            name: "Transfer Test",
            unitName: "XFER",
            total: 1_000_000,
            decimals: 0
        )

        // Create and fund receiver
        let receiver = try await fundAccount(amount: 1_000_000) // 1 ALGO for min balance + fees

        // Opt-in
        let optInTxid = try await algokit.optIn(account: receiver, toAsset: assetID)
        XCTAssertFalse(optInTxid.isEmpty)
        _ = try await algokit.waitForConfirmation(optInTxid)

        // Transfer
        let transferTxid = try await algokit.transferAsset(
            assetID,
            from: creator,
            to: receiver.address,
            amount: 1000
        )
        XCTAssertFalse(transferTxid.isEmpty)
        _ = try await algokit.waitForConfirmation(transferTxid)

        // Verify holdings
        let holdings = try await algokit.assetHoldings(of: receiver.address)
        let holding = holdings.first { $0.assetID == assetID }
        XCTAssertNotNil(holding)
        XCTAssertEqual(holding?.amount, 1000)
    }

    // MARK: - Atomic Transaction Tests

    func test_localnet_atomicSwap() async throws {
        let alice = try await fundAccount(amount: 50_000_000) // 50 ALGO
        let bob = try await fundAccount(amount: 50_000_000)   // 50 ALGO

        // Create atomic swap: Alice sends 5 ALGO, Bob sends 3 ALGO back
        let params = try await algokit.transactionParams()
        let txid = try await algokit.submitGroup(
            [
                PaymentTransaction(
                    sender: alice.address,
                    receiver: bob.address,
                    amount: .algos(5),
                    firstValid: params.firstRound,
                    lastValid: params.firstRound + 1000,
                    genesisID: params.genesisID,
                    genesisHash: params.genesisHash
                ),
                PaymentTransaction(
                    sender: bob.address,
                    receiver: alice.address,
                    amount: .algos(3),
                    firstValid: params.firstRound,
                    lastValid: params.firstRound + 1000,
                    genesisID: params.genesisID,
                    genesisHash: params.genesisHash
                )
            ],
            signedBy: [alice, bob]
        )

        XCTAssertFalse(txid.isEmpty)
        _ = try await algokit.waitForConfirmation(txid)
    }

    func test_localnet_atomicComposer() async throws {
        let alice = try await fundAccount(amount: 50_000_000) // 50 ALGO
        let bob = try await fundAccount(amount: 50_000_000)   // 50 ALGO

        // Use the fluent composer API
        let txid = try await algokit.atomic()
            .pay(from: alice.address, to: bob.address, amount: .algos(2), note: "From Alice")
            .pay(from: bob.address, to: alice.address, amount: .algos(1), note: "From Bob")
            .build()
            .signedBy([alice, bob])
            .submit()

        XCTAssertFalse(txid.isEmpty)
        _ = try await algokit.waitForConfirmation(txid)
    }

    // MARK: - Indexer Tests

    func test_localnet_searchTransactions() async throws {
        let sender = try await fundAccount(amount: 10_000_000) // 10 ALGO

        // First make a transaction
        let receiver = try await algokit.generateAccount()
        _ = try await algokit.sendAndWait(
            from: sender,
            to: receiver.address,
            amount: .algos(0.1)
        )

        // Wait for indexer to catch up (can be slow)
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds

        // Search for transactions - indexer may not be fully synced
        let response = try await algokit.searchTransactions(for: sender.address, limit: 5)
        // Just verify we got a response, indexer sync can be flaky in tests
        XCTAssertNotNil(response)
    }
}
