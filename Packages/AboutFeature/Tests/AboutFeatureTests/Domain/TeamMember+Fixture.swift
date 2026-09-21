import AboutFeature
import Foundation
import Testing

extension TeamMember {
    static func fixture(
        name: String = "Adam Rush",
        role: String? = "Founder and Host",
        links: [SocialLink] = []
    ) throws -> Self {
        TeamMember(
            id: TeamMemberID(name),
            name: name,
            role: role,
            photoURL: try #require(URL(string: "https://example.com/img/team/rush.jpg")),
            links: links
        )
    }
}
