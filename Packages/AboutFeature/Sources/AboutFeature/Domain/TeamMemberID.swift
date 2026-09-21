/// Identifies a team member. The backend sends no ID, so the member's name serves as one.
public struct TeamMemberID: Equatable, Hashable, Sendable {
    fileprivate let storage: String

    public init(_ name: String) {
        self.storage = name
    }
}
