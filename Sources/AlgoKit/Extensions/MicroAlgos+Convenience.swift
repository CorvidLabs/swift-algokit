public import Algorand

// MARK: - MicroAlgos Convenience

public extension MicroAlgos {
    /// Creates a MicroAlgos value from Algos
    /// - Parameter algos: The amount in Algos
    static func algos(_ algos: Double) -> MicroAlgos {
        MicroAlgos(algos: algos)
    }

    /// Creates a MicroAlgos value from microAlgos
    /// - Parameter microAlgos: The amount in microAlgos
    static func microAlgos(_ microAlgos: UInt64) -> MicroAlgos {
        MicroAlgos(microAlgos)
    }
}
