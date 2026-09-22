#if os(iOS)
import AboutFeature
import AboutUI
import Dependencies
import Foundation
import Testing

@MainActor
@Suite struct AboutContentViewSnapshotTests {
    @Test func teamLoaded() async throws {
        let team = [try TeamMember.one, try TeamMember.two]

        let viewModel = await loadedViewModel {
            FetchTeam { () async throws(TeamFetchError) -> [TeamMember] in team }
        }

        assertScreenSnapshots(of: AboutContentView(viewModel: viewModel))
    }

    @Test func teamFetchFailed() async {
        let viewModel = await loadedViewModel {
            FetchTeam { () async throws(TeamFetchError) -> [TeamMember] in throw .couldNotReachServer }
        }

        assertScreenSnapshots(of: AboutContentView(viewModel: viewModel))
    }

    private func loadedViewModel(fetchTeam: () -> FetchTeam) async -> AboutViewModel {
        await withDependencies {
            $0.fetchTeam = fetchTeam()
        } operation: {
            let viewModel = AboutViewModel()
            await viewModel.loadIfNeeded()
            return viewModel
        }
    }
}

private extension TeamMember {
    static var one: TeamMember {
        get throws {
            TeamMember(
                id: TeamMemberID("Member One"),
                name: "Member One",
                role: "Organizer",
                photoURL: try photo,
                links: []
            )
        }
    }

    static var two: TeamMember {
        get throws {
            TeamMember(
                id: TeamMemberID("Member Two"),
                name: "Member Two",
                role: "Volunteer",
                photoURL: try photo,
                links: []
            )
        }
    }

    // An `.invalid` host never resolves, so the card shows its initials placeholder every run.
    private static var photo: URL {
        get throws { try #require(URL(string: "https://photos.example.invalid/member.jpg")) }
    }
}
#endif
