#if os(iOS)
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct AvatarSnapshotTests {
    @Test func sizes() {
        let view = HStack(alignment: .bottom, spacing: Spacing.large) {
            avatar(size: AvatarSize.small)
            avatar(size: AvatarSize.medium)
            avatar(size: AvatarSize.large)
            avatar(size: AvatarSize.xLarge)
        }

        assertSnapshots(of: view)
    }

    // The smallest size as well as the largest: the mark is sized from the avatar, and only the
    // smallest one shows whether it overflows at the accessibility text sizes.
    @Test func symbolFallback() {
        let view = HStack(alignment: .bottom, spacing: Spacing.large) {
            Avatar(url: nil, size: AvatarSize.small)
            Avatar(url: nil, size: AvatarSize.xLarge)
        }

        assertSnapshots(of: view)
        assertCompactSnapshots(of: view)
    }

    // Every size, because the letters are smallest where a caller is most likely to put them.
    @Test func initialsFallback() {
        let name = PersonNameComponents(givenName: "Member", familyName: "One")
        let view = HStack(alignment: .bottom, spacing: Spacing.large) {
            Avatar(url: nil, size: AvatarSize.small, fallback: .initials(name))
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(name))
            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(name))
            Avatar(url: nil, size: AvatarSize.xLarge, fallback: .initials(name))
        }

        assertSnapshots(of: view)
        assertCompactSnapshots(of: view)
    }

    @Test func initialsFallbackWithNothingToAbbreviate() {
        let view = Avatar(url: nil, size: AvatarSize.xLarge, fallback: .initials(.init()))

        assertSnapshots(of: view)
    }

    // Includes the smallest size, where the doc says the mark is too small to read. The image is
    // there so a reviewer sees that rather than taking the sentence on trust.
    @Test func status() {
        let view = HStack(alignment: .bottom, spacing: Spacing.large) {
            Avatar(url: nil, size: AvatarSize.small, status: AvatarStatus("Checked in"))
            Avatar(url: nil, size: AvatarSize.medium, status: AvatarStatus("Checked in"))
            Avatar(
                url: nil,
                size: AvatarSize.xLarge,
                status: AvatarStatus(
                    "Waitlisted",
                    icon: Icon(.exclamationmarkCircleFill),
                    tint: .warning
                )
            )
        }

        assertSnapshots(of: view)
    }

    // One with a status, because a square's corner sits further from its edge than a circle's.
    @Test func roundedStyle() {
        let view = HStack(spacing: Spacing.large) {
            Avatar(url: nil, size: AvatarSize.xLarge)

            Avatar(url: nil, size: AvatarSize.xLarge, status: AvatarStatus("Checked in"))

            Avatar(url: nil, size: AvatarSize.xLarge)
                .avatarStyle(.rounded(cornerRadius: CornerRadius.small))
        }
        .avatarStyle(.rounded)

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
