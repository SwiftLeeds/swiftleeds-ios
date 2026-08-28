#if os(iOS)
import AuthenticationFeature
import AuthenticationUI
import Foundation
import SnapshotTesting
import Testing

@MainActor
@Suite struct ProfileCardContentSnapshotTests {
    @Test func loaded() throws {
        let view = ProfileCardContent(state: .loaded(try makeProfile()), retry: {}, signOut: {})

        assertSnapshots(of: view.snapshotCard())
    }

    @Test func failed() {
        let view = ProfileCardContent(state: .failed, retry: {}, signOut: {})

        assertSnapshots(of: view.snapshotCard())
    }

    @Test func failedNarrow() {
        let view = ProfileCardContent(state: .failed, retry: {}, signOut: {})

        assertSnapshots(of: view.snapshotCard(width: 200))
    }

    @Test func failedTiny() {
        let view = ProfileCardContent(state: .failed, retry: {}, signOut: {})

        assertSnapshots(of: view.snapshotCard(width: 130))
    }

    // The host never resolves, so the avatar always renders its placeholder.
    // A URL that could load would make the reference depend on the network.
    private func makeProfile() throws -> Profile {
        Profile(
            name: PersonNameComponents(givenName: "Ada", familyName: "Lovelace"),
            emailAddress: "ada@example.com",
            avatarURL: try #require(URL(string: "https://example.invalid/avatar.png")),
            ticketReference: "ABCD-1",
            ticketSlug: try TicketSlug("ti_abc")
        )
    }
}
#endif
