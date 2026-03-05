import XCTest
@testable import AlgoKit
import Algorand

final class AssetTransactionTests: XCTestCase {

    private let genesisID = "testnet-v1.0"
    private let genesisHash = Data(repeating: 0, count: 32)

    private func makeAccount() throws -> Account {
        let algokit = AlgoKit(network: .testnet)
        return try algokit.generateAccount()
    }

    // MARK: - Asset Create Transaction

    func test_assetCreate_withFullParams() throws {
        let creator = try makeAccount()
        let manager = try makeAccount()
        let reserve = try makeAccount()
        let freeze = try makeAccount()
        let clawback = try makeAccount()

        let assetParams = AssetParams(
            total: 10_000_000,
            decimals: 8,
            unitName: "FULL",
            assetName: "Full Asset",
            url: "https://example.com",
            manager: manager.address,
            reserve: reserve.address,
            freeze: freeze.address,
            clawback: clawback.address
        )

        let tx = AssetCreateTransaction(
            sender: creator.address,
            assetParams: assetParams,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, creator.address)
        XCTAssertEqual(tx.assetParams.total, 10_000_000)
        XCTAssertEqual(tx.assetParams.decimals, 8)
        XCTAssertEqual(tx.assetParams.unitName, "FULL")
        XCTAssertEqual(tx.assetParams.assetName, "Full Asset")
    }

    func test_assetCreate_nftParams() throws {
        let creator = try makeAccount()

        let assetParams = AssetParams(
            total: 1,
            decimals: 0,
            unitName: "NFT",
            assetName: "My NFT",
            url: "ipfs://QmTest",
            manager: creator.address,
            reserve: creator.address
        )

        let tx = AssetCreateTransaction(
            sender: creator.address,
            assetParams: assetParams,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.assetParams.total, 1)
        XCTAssertEqual(tx.assetParams.decimals, 0)
    }

    func test_assetCreate_withMetadataHash() throws {
        let creator = try makeAccount()
        let metadataHash = Data(repeating: 0xAB, count: 32)

        let assetParams = AssetParams(
            total: 1000,
            decimals: 0,
            unitName: "META",
            assetName: "Meta Asset",
            metadataHash: metadataHash,
            manager: creator.address,
            reserve: creator.address
        )

        let tx = AssetCreateTransaction(
            sender: creator.address,
            assetParams: assetParams,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.assetParams.metadataHash, metadataHash)
    }

    func test_assetCreate_canBeSigned() throws {
        let creator = try makeAccount()

        let assetParams = AssetParams(
            total: 1000,
            decimals: 0,
            unitName: "SIGN",
            assetName: "Signable",
            manager: creator.address,
            reserve: creator.address
        )

        let tx = AssetCreateTransaction(
            sender: creator.address,
            assetParams: assetParams,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: creator)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    // MARK: - Asset Opt-In Transaction

    func test_assetOptIn_setsCorrectFields() throws {
        let account = try makeAccount()

        let tx = AssetOptInTransaction(
            sender: account.address,
            assetID: 99999,
            firstValid: 500,
            lastValid: 1500,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, account.address)
        XCTAssertEqual(tx.assetID, 99999)
    }

    func test_assetOptIn_canBeSigned() throws {
        let account = try makeAccount()

        let tx = AssetOptInTransaction(
            sender: account.address,
            assetID: 12345,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: account)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    // MARK: - Asset Transfer Transaction

    func test_assetTransfer_buildsCorrectly() throws {
        let sender = try makeAccount()
        let receiver = try makeAccount()

        let tx = AssetTransferTransaction(
            sender: sender.address,
            receiver: receiver.address,
            assetID: 54321,
            amount: 500,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, sender.address)
        XCTAssertEqual(tx.receiver, receiver.address)
        XCTAssertEqual(tx.assetID, 54321)
        XCTAssertEqual(tx.amount, 500)
    }

    func test_assetTransfer_withCloseRemainder() throws {
        let sender = try makeAccount()
        let receiver = try makeAccount()
        let closeTarget = try makeAccount()

        let tx = AssetTransferTransaction(
            sender: sender.address,
            receiver: receiver.address,
            assetID: 54321,
            amount: 0,
            closeRemainderTo: closeTarget.address,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.amount, 0)
        XCTAssertEqual(tx.closeRemainderTo, closeTarget.address)
    }

    func test_assetTransfer_zeroAmount() throws {
        let sender = try makeAccount()
        let receiver = try makeAccount()

        let tx = AssetTransferTransaction(
            sender: sender.address,
            receiver: receiver.address,
            assetID: 12345,
            amount: 0,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.amount, 0)
    }

    func test_assetTransfer_largeAmount() throws {
        let sender = try makeAccount()
        let receiver = try makeAccount()

        let tx = AssetTransferTransaction(
            sender: sender.address,
            receiver: receiver.address,
            assetID: 12345,
            amount: UInt64.max,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.amount, UInt64.max)
    }

    func test_assetTransfer_canBeSigned() throws {
        let sender = try makeAccount()
        let receiver = try makeAccount()

        let tx = AssetTransferTransaction(
            sender: sender.address,
            receiver: receiver.address,
            assetID: 12345,
            amount: 100,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: sender)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    // MARK: - Asset Freeze Transaction

    func test_assetFreeze_freezeAccount() throws {
        let freezeAuthority = try makeAccount()
        let target = try makeAccount()

        let tx = AssetFreezeTransaction(
            sender: freezeAuthority.address,
            assetID: 12345,
            freezeAccount: target.address,
            frozen: true,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, freezeAuthority.address)
        XCTAssertEqual(tx.assetID, 12345)
        XCTAssertEqual(tx.freezeAccount, target.address)
        XCTAssertTrue(tx.frozen)
    }

    func test_assetFreeze_unfreezeAccount() throws {
        let freezeAuthority = try makeAccount()
        let target = try makeAccount()

        let tx = AssetFreezeTransaction(
            sender: freezeAuthority.address,
            assetID: 12345,
            freezeAccount: target.address,
            frozen: false,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertFalse(tx.frozen)
    }

    func test_assetFreeze_canBeSigned() throws {
        let freezeAuthority = try makeAccount()
        let target = try makeAccount()

        let tx = AssetFreezeTransaction(
            sender: freezeAuthority.address,
            assetID: 12345,
            freezeAccount: target.address,
            frozen: true,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: freezeAuthority)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    // MARK: - Asset Config Transaction

    func test_assetConfig_update() throws {
        let manager = try makeAccount()
        let newManager = try makeAccount()

        let tx = AssetConfigTransaction.update(
            sender: manager.address,
            assetID: 12345,
            manager: newManager.address,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, manager.address)
        XCTAssertEqual(tx.assetID, 12345)
    }

    func test_assetConfig_destroy() throws {
        let manager = try makeAccount()

        let tx = AssetConfigTransaction.destroy(
            sender: manager.address,
            assetID: 12345,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, manager.address)
        XCTAssertEqual(tx.assetID, 12345)
    }

    func test_assetConfig_canBeSigned() throws {
        let manager = try makeAccount()

        let tx = AssetConfigTransaction.update(
            sender: manager.address,
            assetID: 12345,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: manager)
        XCTAssertFalse(signed.signature.isEmpty)
    }

    // MARK: - Asset Clawback Transaction

    func test_assetClawback_buildsCorrectly() throws {
        let clawbackAuth = try makeAccount()
        let target = try makeAccount()
        let destination = try makeAccount()

        let tx = AssetClawbackTransaction(
            sender: clawbackAuth.address,
            assetID: 12345,
            assetSender: target.address,
            assetReceiver: destination.address,
            amount: 500,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        XCTAssertEqual(tx.sender, clawbackAuth.address)
        XCTAssertEqual(tx.assetID, 12345)
        XCTAssertEqual(tx.assetSender, target.address)
        XCTAssertEqual(tx.assetReceiver, destination.address)
        XCTAssertEqual(tx.amount, 500)
    }

    func test_assetClawback_canBeSigned() throws {
        let clawbackAuth = try makeAccount()
        let target = try makeAccount()
        let destination = try makeAccount()

        let tx = AssetClawbackTransaction(
            sender: clawbackAuth.address,
            assetID: 12345,
            assetSender: target.address,
            assetReceiver: destination.address,
            amount: 100,
            firstValid: 1000,
            lastValid: 2000,
            genesisID: genesisID,
            genesisHash: genesisHash
        )

        let signed = try SignedTransaction.sign(tx, with: clawbackAuth)
        XCTAssertFalse(signed.signature.isEmpty)
    }
}
