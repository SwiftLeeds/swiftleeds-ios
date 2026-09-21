/// A volunteer who runs the conference.
public struct TeamMember: Equatable, Hashable, Identifiable, Sendable {
    public let id: TeamMemberID
    public let name: String

    /// What the member does for the conference. Some members have no role.
    public let role: String?

    public init(id: TeamMemberID, name: String, role: String?) {
        self.id = id
        self.name = name
        self.role = role
    }
}
