#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite struct AvatarSnapshotTests {
    @Test func sizes() {
        let view = HStack(alignment: .bottom, spacing: Spacing.large) {
            avatar(size: AvatarSize.small)
            avatar(size: AvatarSize.medium)
            avatar(size: AvatarSize.large)
            avatar(size: AvatarSize.xLarge)
        }

        assertSnapshots(of: view)
    }

    @Test func symbolFallback() {
        let view = Avatar(url: nil, size: AvatarSize.xLarge)

        assertSnapshots(of: view)
        assertCompactSnapshots(of: view)
    }

    @Test func initialsFallback() {
        let name = PersonNameComponents(givenName: "Member", familyName: "One")
        let view = Avatar(url: nil, size: AvatarSize.xLarge, fallback: .initials(name))

        assertSnapshots(of: view)
        assertCompactSnapshots(of: view)
    }

    @Test func status() {
        let view = HStack(spacing: Spacing.large) {
            Avatar(url: nil, size: AvatarSize.medium, status: AvatarStatus("Checked in"))
            Avatar(
                url: nil,
                size: AvatarSize.xLarge,
                status: AvatarStatus("Waitlisted", icon: .warning, tint: .warning)
            )
        }

        assertSnapshots(of: view)
    }

    // A flat fill, so this suite measures the shape and the size and nothing else.
    private func avatar(size: CGFloat) -> some View {
        Avatar(url: nil, size: size) {
            Color.secondarySurface
        }
    }
}
#endif
