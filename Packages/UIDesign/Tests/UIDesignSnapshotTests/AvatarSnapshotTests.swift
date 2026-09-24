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
    }

    // Every size, because the letters are smallest where a caller is most likely to put them.
    @Test func initialsFallback() {
        let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")
        let view = HStack(alignment: .bottom, spacing: Spacing.large) {
            Avatar(url: nil, size: AvatarSize.small, fallback: .initials(name))
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(name))
            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(name))
            Avatar(url: nil, size: AvatarSize.xLarge, fallback: .initials(name))
        }

        assertSnapshots(of: view)
    }

    // Six people, so the image shows that the initials alone tell them apart.
    @Test func initialsFallbackTellsPeopleApart() {
        let view = HStack(spacing: Spacing.large) {
            ForEach(Self.people, id: \.self) { name in
                Avatar(url: nil, size: AvatarSize.large, fallback: .initials(name))
            }
        }

        assertSnapshots(of: view)
    }

    private static let people = [
        PersonNameComponents(givenName: "Ada", familyName: "Archer"),
        PersonNameComponents(givenName: "Blake", familyName: "Brooks"),
        PersonNameComponents(givenName: "Casey", familyName: "Cole"),
        PersonNameComponents(givenName: "Devon", familyName: "Drake"),
        PersonNameComponents(givenName: "Ellis", familyName: "East"),
        PersonNameComponents(givenName: "Frankie", familyName: "Fox"),
    ]

    @Test func initialsFallbackWithNothingToAbbreviate() {
        let view = Avatar(url: nil, size: AvatarSize.xLarge, fallback: .initials(.init()))

        assertSnapshots(of: view)
    }

    // The smallest size, the default and the largest.
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

    // Every fallback, because each one draws something a redaction would otherwise turn into a
    // rectangle sitting inside the avatar's shape.
    @Test func redacted() {
        let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")
        let view = HStack(spacing: Spacing.large) {
            Avatar(url: nil, size: AvatarSize.large)

            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(name))

            Avatar(url: nil, size: AvatarSize.large) {
                Image(icon: .locked)
                    .foregroundStyle(.textSecondary)
            }
        }
        .redacted(reason: .placeholder)

        assertSnapshots(of: view)
    }

    // A flat fill, so this suite measures the shape and the size and nothing else.
    private func avatar(size: AvatarSize) -> some View {
        Avatar(url: nil, size: size) {
            Color.secondarySurface
        }
    }
}
#endif
