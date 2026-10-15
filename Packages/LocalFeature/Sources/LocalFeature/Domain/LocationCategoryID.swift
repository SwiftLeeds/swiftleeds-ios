import Foundation

/// The identity of a kind of place, assigned by the backend.
public struct LocationCategoryID: Equatable, Hashable, Sendable {
    /// The identifier.
    fileprivate let storage: UUID

    /// Creates a category identity.
    /// - Parameter value: The identifier.
    public init(_ value: UUID) {
        self.storage = value
    }
}
