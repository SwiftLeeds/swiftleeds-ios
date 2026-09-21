import AboutFeature
import Foundation
import Testing

extension TeamMember {
    static func fixture(
        name: String = "Member One",
        role: String? = "Organizer",
        links: [SocialLink] = []
    ) throws -> Self {
        TeamMember(
            id: TeamMemberID(name),
            name: name,
            role: role,
            photoURL: try #require(URL(string: "https://example.com/img/team/member-one.jpg")),
            links: links
        )
    }
}
