import XCTest
@testable import AlgoKit
import Algorand

final class ApplicationTransactionTests: XCTestCase {

    private let genesisID = "testnet-v1.0"
    private let genesisHash = Data(repeating: 0, count: 32)

    private func makeAccount() throws -> Account {
        let algokit = AlgoKit(network: .testnet)
        return try algokit.generateAccount()
    }

    // MARK: - Application Call (NoOp)

    func test_applicationCall_buildsWithArguments() throws {
        let caller = try makeAccount()
        let arg1 = "hello".data(using: .utf8)!
        let arg2 = "world".data(using: .utf8)!

        let tx = ApplicationCallTransaction.call(
            sender: caller.address,
            applicationID: 12345,
            appArguments: [arg1, arg2],
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, caller.address)
        XCTAssertEqual(tx.applicationID, 12345)
    }

    func test_applicationCall_buildsWithoutArguments() throws {
        let caller = try makeAccount()

        let tx = ApplicationCallTransaction.call(
            sender: caller.address,
            applicationID: 99999,
            firstValid: 500,
            lastValid: 1500,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.applicationID, 99999)
    }

    func test_applicationCall_withForeignApps() throws {
        let caller = try makeAccount()

        let tx = ApplicationCallTransaction.call(
            sender: caller.address,
            applicationID: 12345,
            foreignApps: [111, 222, 333],
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, caller.address)
        XCTAssertEqual(tx.applicationID, 12345)
    }

    func test_applicationCall_withForeignAssets() throws {
        let caller = try makeAccount()

        let tx = ApplicationCallTransaction.call(
            sender: caller.address,
            applicationID: 12345,
            foreignAssets: [444, 555],
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, caller.address)
    }

    func test_applicationCall_withAccounts() throws {
        let caller = try makeAccount()
        let extra = try makeAccount()

        let tx = ApplicationCallTransaction.call(
            sender: caller.address,
            applicationID: 12345,
            accounts: [extra.address],
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, caller.address)
    }

    // MARK: - Application Opt-In

    func test_applicationOptIn_buildsCorrectly() throws {
        let account = try makeAccount()

        let tx = ApplicationCallTransaction.optIn(
            sender: account.address,
            applicationID: 67890,
            firstValid: 100,
            lastValid: 1100,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, account.address)
        XCTAssertEqual(tx.applicationID, 67890)
    }

    func test_applicationOptIn_withArguments() throws {
        let account = try makeAccount()
        let arg = "opt-in-data".data(using: .utf8)!

        let tx = ApplicationCallTransaction.optIn(
            sender: account.address,
            applicationID: 67890,
            appArguments: [arg],
            firstValid: 100,
            lastValid: 1100,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.applicationID, 67890)
    }

    // MARK: - Application Close Out

    func test_applicationCloseOut_buildsCorrectly() throws {
        let account = try makeAccount()

        let tx = ApplicationCallTransaction.closeOut(
            sender: account.address,
            applicationID: 11111,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, account.address)
        XCTAssertEqual(tx.applicationID, 11111)
    }

    func test_applicationCloseOut_withArguments() throws {
        let account = try makeAccount()
        let arg = "close-data".data(using: .utf8)!

        let tx = ApplicationCallTransaction.closeOut(
            sender: account.address,
            applicationID: 11111,
            appArguments: [arg],
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.applicationID, 11111)
    }

    // MARK: - Application Update

    func test_applicationUpdate_buildsCorrectly() throws {
        let account = try makeAccount()
        let approval = Data([0x01, 0x20, 0x01, 0x01, 0x22])
        let clearState = Data([0x01, 0x20, 0x01, 0x01, 0x22])

        let tx = ApplicationCallTransaction.update(
            sender: account.address,
            applicationID: 22222,
            approvalProgram: approval,
            clearStateProgram: clearState,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, account.address)
        XCTAssertEqual(tx.applicationID, 22222)
    }

    func test_applicationUpdate_withArguments() throws {
        let account = try makeAccount()
        let approval = Data([0x01])
        let clearState = Data([0x01])
        let arg = "update-arg".data(using: .utf8)!

        let tx = ApplicationCallTransaction.update(
            sender: account.address,
            applicationID: 22222,
            approvalProgram: approval,
            clearStateProgram: clearState,
            appArguments: [arg],
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.applicationID, 22222)
    }

    // MARK: - Application Delete

    func test_applicationDelete_buildsCorrectly() throws {
        let account = try makeAccount()

        let tx = ApplicationCallTransaction.delete(
            sender: account.address,
            applicationID: 33333,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, account.address)
        XCTAssertEqual(tx.applicationID, 33333)
    }

    func test_applicationDelete_withArguments() throws {
        let account = try makeAccount()
        let arg = "delete-arg".data(using: .utf8)!

        let tx = ApplicationCallTransaction.delete(
            sender: account.address,
            applicationID: 33333,
            appArguments: [arg],
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.applicationID, 33333)
    }

    // MARK: - Application Create

    func test_applicationCreate_buildsCorrectly() throws {
        let creator = try makeAccount()
        let approval = Data([0x01, 0x20, 0x01, 0x01, 0x22])
        let clearState = Data([0x01, 0x20, 0x01, 0x01, 0x22])

        let tx = ApplicationCallTransaction.create(
            sender: creator.address,
            approvalProgram: approval,
            clearStateProgram: clearState,
            globalStateSchema: StateSchema(numUint: 1, numByteSlice: 1),
            localStateSchema: StateSchema(numUint: 0, numByteSlice: 0),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, creator.address)
    }

    func test_applicationCreate_withExtraPages() throws {
        let creator = try makeAccount()
        let approval = Data(repeating: 0x01, count: 100)
        let clearState = Data([0x01])

        let tx = ApplicationCallTransaction.create(
            sender: creator.address,
            approvalProgram: approval,
            clearStateProgram: clearState,
            globalStateSchema: StateSchema(numUint: 10, numByteSlice: 5),
            localStateSchema: StateSchema(numUint: 2, numByteSlice: 1),
            extraPages: 1,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, creator.address)
    }

    func test_applicationCreate_withArguments() throws {
        let creator = try makeAccount()
        let approval = Data([0x01])
        let clearState = Data([0x01])
        let arg = "init".data(using: .utf8)!

        let tx = ApplicationCallTransaction.create(
            sender: creator.address,
            approvalProgram: approval,
            clearStateProgram: clearState,
            globalStateSchema: StateSchema(numUint: 1, numByteSlice: 0),
            localStateSchema: StateSchema(numUint: 0, numByteSlice: 0),
            appArguments: [arg],
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, creator.address)
    }

    // MARK: - Transaction Signing

    func test_applicationCall_canBeSigned() throws {
        let caller = try makeAccount()

        let tx = ApplicationCallTransaction.call(
            sender: caller.address,
            applicationID: 12345,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: caller)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    func test_applicationOptIn_canBeSigned() throws {
        let account = try makeAccount()

        let tx = ApplicationCallTransaction.optIn(
            sender: account.address,
            applicationID: 12345,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: account)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    func test_applicationCloseOut_canBeSigned() throws {
        let account = try makeAccount()

        let tx = ApplicationCallTransaction.closeOut(
            sender: account.address,
            applicationID: 12345,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: account)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    func test_applicationDelete_canBeSigned() throws {
        let account = try makeAccount()

        let tx = ApplicationCallTransaction.delete(
            sender: account.address,
            applicationID: 12345,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: account)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    func test_applicationUpdate_canBeSigned() throws {
        let account = try makeAccount()
        let approval = Data([0x01])
        let clearState = Data([0x01])

        let tx = ApplicationCallTransaction.update(
            sender: account.address,
            applicationID: 12345,
            approvalProgram: approval,
            clearStateProgram: clearState,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: account)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    func test_applicationCreate_canBeSigned() throws {
        let creator = try makeAccount()
        let approval = Data([0x01])
        let clearState = Data([0x01])

        let tx = ApplicationCallTransaction.create(
            sender: creator.address,
            approvalProgram: approval,
            clearStateProgram: clearState,
            globalStateSchema: StateSchema(numUint: 1, numByteSlice: 0),
            localStateSchema: StateSchema(numUint: 0, numByteSlice: 0),
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: creator)
        XCTAssertFalse(signed.signature.isEmpty)
    }
}
