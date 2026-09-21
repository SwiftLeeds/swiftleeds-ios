import AboutFeature
import Foundation
import Testing

extension TeamMember {
    static var fixture: TeamMember {
        get throws {
            TeamMember(
                id: TeamMemberID("Member One"),
                name: "Member One",
                role: "Organizer",
                photoURL: try #require(URL(string: "https://photos.example.invalid/member-one.jpg")),
                links: []
            )
        }
    }
}
