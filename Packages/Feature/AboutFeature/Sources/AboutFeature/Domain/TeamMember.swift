import Foundation

/// A volunteer who runs the conference.
public struct TeamMember: Equatable, Hashable, Identifiable, Sendable {
    public let id: TeamMemberID

    /// The member's name.
    public let name: String

    /// What the member does for the conference. Some members have no role.
    public let role: String?

    /// The address of the member's photo.
    public let photoURL: URL

    /// Where to reach the member, in the order to show them.
    public let links: [SocialLink]

    /// Creates a team member.
    public init(id: TeamMemberID, name: String, role: String?, photoURL: URL, links: [SocialLink]) {
        self.id = id
        self.name = name
        self.role = role
        self.photoURL = photoURL
        self.links = links
    }
}
