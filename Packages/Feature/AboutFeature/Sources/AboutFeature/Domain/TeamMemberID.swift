/// The identity of a team member.
///
/// The backend sends no identifier, so the member's name serves as one.
public struct TeamMemberID: Equatable, Hashable, Sendable {
    /// The member's name.
    private let storage: String

    /// Creates an identity from the member's name.
    /// - Parameter name: The member's name, as the backend sends it.
    public init(_ name: String) {
        self.storage = name
    }
}
