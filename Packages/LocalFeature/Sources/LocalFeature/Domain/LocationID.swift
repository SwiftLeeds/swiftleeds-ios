import Foundation

/// The identity of a place near the conference, assigned by the backend.
public struct LocationID: Equatable, Hashable, Sendable {
    /// The identifier.
    fileprivate let storage: UUID

    /// Creates a location identity.
    /// - Parameter value: The identifier.
    public init(_ value: UUID) {
        self.storage = value
    }
}
