#if os(iOS)
import AuthenticationUI
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
@Suite struct NameplateSnapshotTests {
    @Test func prominent() {
        assertSnapshots(of: samples.snapshotCard())
    }

    @Test func compact() {
        assertSnapshots(of: samples.nameplateStyle(.compact).snapshotCard())
    }

    @Test func redacted() {
        let view = Nameplate(
            Text(verbatim: "Ada Lovelace"),
            detail: Text(verbatim: "ada@example.com")
        ) {
            personAvatar
        }
        .redacted(reason: .placeholder)

        assertSnapshots(of: view.snapshotCard())
    }

    @Test func placeholder() {
        assertSnapshots(of: NameplatePlaceholder().snapshotCard())
    }

    @Test func multiLineDetail() {
        let view = Nameplate {
            Text(verbatim: "Ada Lovelace")
        } detail: {
            Text(verbatim: "ada@example.com")
            Text(verbatim: "ABCD-1")
        } icon: {
            initialsAvatar
        }

        assertSnapshots(of: view.snapshotCard())
    }

    @Test func narrow() {
        let view = Nameplate(
            Text(verbatim: "Augusta Ada King-Noel"),
            detail: Text(verbatim: "ada.lovelace@example.com")
        ) {
            initialsAvatar
        }

        assertSnapshots(of: view.snapshotCard(width: 220))
    }

    private var initialsAvatar: some View {
        Avatar(url: nil) {
            Text(verbatim: "AL")
        }
    }

    private var personAvatar: some View {
        Avatar(url: nil) {
            Image(systemName: "person")
        }
    }

    private var samples: some View {
        VStack(alignment: .leading, spacing: 16) {
            Nameplate(
                Text(verbatim: "Ada Lovelace"),
                detail: Text(verbatim: "ada@example.com")
            ) {
                initialsAvatar
            }

            Divider()

            Nameplate(Text("Sign In"), role: .unresolved) {
                personAvatar
            }

            Divider()

            Nameplate(Text(verbatim: "Ada Lovelace")) {
                initialsAvatar
            }
        }
    }
}
#endif
