/// The identity of a sponsor, assigned by the backend.
public struct SponsorID: Equatable, Hashable, Sendable {
    /// The identifier.
    fileprivate let storage: String

    /// Creates a sponsor identity.
    /// - Parameter value: The identifier the backend sent.
    public init(_ value: String) {
        self.storage = value
    }
}
