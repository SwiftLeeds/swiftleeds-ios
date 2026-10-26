#if os(iOS)
import AuthenticationUI
import SwiftUI
import Testing

@MainActor
@Suite struct AvatarSnapshotTests {
    /// A row with an initials avatar and a person avatar.
    private var row: some View {
        HStack(spacing: 16) {
            initialsAvatar
                .frame(width: 56, height: 56)

            personAvatar
                .frame(width: 56, height: 56)
        }
        .font(.title2.weight(.semibold))
        .foregroundStyle(Color.accentColor)
    }

    /// An avatar that shows the initials "AL".
    private var initialsAvatar: some View {
        Avatar(url: nil) {
            Text(verbatim: "AL")
        }
    }

    /// An avatar that shows a person symbol.
    private var personAvatar: some View {
        Avatar(url: nil) {
            Image(systemName: "person")
        }
    }

    @Test func sizes() {
        let view = HStack(spacing: 16) {
            initialsAvatar
                .font(.largeTitle.weight(.semibold))
                .frame(width: 88, height: 88)

            initialsAvatar
                .font(.title2.weight(.semibold))
                .frame(width: 56, height: 56)

            personAvatar
                .font(.title2.weight(.semibold))
                .frame(width: 56, height: 56)

            personAvatar
                .font(.subheadline.weight(.semibold))
                .frame(width: 40, height: 40)
        }
        .foregroundStyle(Color.accentColor)

        assertSnapshots(of: view.snapshotCard())
    }

    @Test func styles() {
        let view = VStack(alignment: .leading, spacing: 20) {
            row
            row.avatarStyle(.rounded)
            row.avatarStyle(.rounded(cornerRadius: 4))
        }

        assertSnapshots(of: view.snapshotCard())
    }
}
#endif
