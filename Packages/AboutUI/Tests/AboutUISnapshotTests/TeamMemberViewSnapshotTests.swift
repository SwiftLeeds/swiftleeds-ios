#if os(iOS)
import AboutFeature
import AboutUI
import Foundation
import Testing

@MainActor
@Suite struct TeamMemberViewSnapshotTests {
    @Test func roleAndEveryLink() throws {
        let view = TeamMemberView(member: try .memberOne)

        assertGridCellSnapshots(of: view, columns: 2)
    }

    @Test func noRoleOrLinks() throws {
        let view = TeamMemberView(member: try .memberTwo)

        assertGridCellSnapshots(of: view, columns: 2)
    }
}

private extension TeamMember {
    static var memberOne: TeamMember {
        get throws {
            TeamMember(
                id: TeamMemberID("Member One"),
                name: "Member One",
                role: "Organizer",
                photoURL: try photo,
                links: [
                    .linkedIn(try #require(URL(string: "https://linkedin.example.com/member-one"))),
                    .twitter(try #require(URL(string: "https://twitter.example.com/member-one"))),
                    .slack(try #require(URL(string: "https://slack.example.com/member-one"))),
                ]
            )
        }
    }

    static var memberTwo: TeamMember {
        get throws {
            TeamMember(id: TeamMemberID("Member Two"), name: "Member Two", role: nil, photoURL: try photo, links: [])
        }
    }

    // An `.invalid` host never resolves, so the card shows its initials placeholder every run.
    private static var photo: URL {
        get throws { try #require(URL(string: "https://photos.example.invalid/member.jpg")) }
    }
}
#endif
