#if os(iOS)
import AuthenticationUI
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
@Suite struct AvatarSnapshotTests {
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
}
#endif
