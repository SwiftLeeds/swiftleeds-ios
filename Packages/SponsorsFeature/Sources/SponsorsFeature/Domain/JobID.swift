import Foundation

/// The identity of a job a sponsor advertises, assigned by the backend.
public struct JobID: Equatable, Hashable, Sendable {
    /// The identifier.
    fileprivate let storage: UUID

    /// Creates a job identity.
    /// - Parameter value: The identifier the backend sent.
    public init(_ value: UUID) {
        self.storage = value
    }
}
