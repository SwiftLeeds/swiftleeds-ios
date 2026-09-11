import Foundation

/// A job's identity, assigned by the server.
///
/// Typed so it cannot be passed where a `SponsorID` belongs.
public struct JobID: Equatable, Hashable, Sendable {
    fileprivate let storage: UUID

    public init(_ value: UUID) {
        self.storage = value
    }
}
