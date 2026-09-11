/// A sponsor's identity, assigned by the server.
///
/// Typed so it cannot be passed where a `JobID` belongs.
public struct SponsorID: Equatable, Hashable, Sendable {
    fileprivate let storage: String

    public init(_ value: String) {
        self.storage = value
    }
}
