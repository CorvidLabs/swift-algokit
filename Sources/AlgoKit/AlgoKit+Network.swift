import Algorand

// MARK: - Network Status

public extension AlgoKit {
    /// Gets the current node status.
    /// - Returns: The node status
    func status() async throws -> NodeStatus {
        try await algodClient.status()
    }

    /// Checks if the network is healthy.
    /// - Returns: `true` if the node is responsive
    func isHealthy() async throws -> Bool {
        _ = try await algodClient.status()
        return true
    }
}
