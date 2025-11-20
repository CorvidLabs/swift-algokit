import Algorand

// MARK: - Indexer Operations

public extension AlgoKit {
    /// Searches for transactions.
    /// - Parameters:
    ///   - address: Filter by address
    ///   - limit: Maximum number of results
    /// - Returns: The transactions response
    func searchTransactions(
        for address: Address? = nil,
        limit: Int = 10
    ) async throws -> TransactionsResponse {
        guard let indexer = indexerClient else {
            throw AlgorandError.networkError("Indexer client not configured")
        }
        return try await indexer.searchTransactions(address: address, limit: limit)
    }

    /// Searches for assets.
    /// - Parameters:
    ///   - name: Filter by asset name
    ///   - limit: Maximum number of results
    /// - Returns: The assets response
    func searchAssets(
        name: String? = nil,
        limit: Int = 10
    ) async throws -> AssetsResponse {
        guard let indexer = indexerClient else {
            throw AlgorandError.networkError("Indexer client not configured")
        }
        return try await indexer.searchAssets(limit: limit, name: name)
    }

    /// Gets asset information by ID.
    /// - Parameter assetID: The asset ID
    /// - Returns: The asset response
    func getAsset(_ assetID: UInt64) async throws -> AssetResponse {
        guard let indexer = indexerClient else {
            throw AlgorandError.networkError("Indexer client not configured")
        }
        return try await indexer.asset(assetID)
    }

    /// Gets application information by ID.
    /// - Parameter appID: The application ID
    /// - Returns: The application response
    func getApplication(_ appID: UInt64) async throws -> ApplicationResponse {
        guard let indexer = indexerClient else {
            throw AlgorandError.networkError("Indexer client not configured")
        }
        return try await indexer.application(appID)
    }
}
