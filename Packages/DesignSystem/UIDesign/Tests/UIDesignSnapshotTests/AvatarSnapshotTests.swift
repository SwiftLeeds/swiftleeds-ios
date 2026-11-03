#if os(iOS)
import Foundation
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct AvatarSnapshotTests {
    /// Six made-up people whose initials differ, so the image can tell them apart.
    private static let people = [
        PersonNameComponents(givenName: "Ada", familyName: "Archer"),
        PersonNameComponents(givenName: "Blake", familyName: "Brooks"),
        PersonNameComponents(givenName: "Casey", familyName: "Cole"),
        PersonNameComponents(givenName: "Devon", familyName: "Drake"),
        PersonNameComponents(givenName: "Ellis", familyName: "East"),
        PersonNameComponents(givenName: "Frankie", familyName: "Fox"),
    ]

    /// A pale gradient that stands in for a photo of a bright scene.
    private static let palePhoto = LinearGradient(
        colors: [.white, Color(white: 0.92)],
        startPoint: .top,
        endPoint: .bottom,
    )

    /// A dark gradient that stands in for a photo of a dim scene.
    private static let darkPhoto = LinearGradient(
        colors: [.black, Color(white: 0.12)],
        startPoint: .top,
        endPoint: .bottom,
    )

    @Test func sizes() {
        let view = HStack(alignment: .bottom, spacing: Spacing.lg) {
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
        let view = HStack(alignment: .bottom, spacing: Spacing.lg) {
            Avatar(url: nil, size: AvatarSize.small)
            Avatar(url: nil, size: AvatarSize.xLarge)
        }

        assertSnapshots(of: view)
    }

    // Every size, because the letters are smallest where a caller is most likely to put them.
    @Test func initialsFallback() {
        let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")
        let view = HStack(alignment: .bottom, spacing: Spacing.lg) {
            Avatar(url: nil, size: AvatarSize.small, fallback: .initials(name))
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(name))
            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(name))
            Avatar(url: nil, size: AvatarSize.xLarge, fallback: .initials(name))
        }

        assertSnapshots(of: view)
    }

    // Six people, so the image shows that the initials alone tell them apart.
    @Test func initialsFallbackTellsPeopleApart() {
        let view = HStack(spacing: Spacing.lg) {
            ForEach(Self.people, id: \.self) { name in
                Avatar(url: nil, size: AvatarSize.large, fallback: .initials(name))
            }
        }

        assertSnapshots(of: view)
    }

    @Test func initialsFallbackWithNothingToAbbreviate() {
        let view = Avatar(url: nil, size: AvatarSize.xLarge, fallback: .initials(.init()))

        assertSnapshots(of: view)
    }

    /// Checks every size, because the mark's size follows the avatar's.
    @Test func status() {
        let view = avatarsWithStatus().padding(Spacing.lg)

        assertSnapshots(of: view)
    }

    /// Checks every size and one avatar without a status, because the mark's size follows the
    /// avatar's.
    @Test func roundedStyle() {
        let view = HStack(alignment: .bottom, spacing: Spacing.lg) {
            Avatar(url: nil, size: AvatarSize.xLarge)

            avatarsWithStatus()
        }
        .padding(Spacing.lg)
        .avatarStyle(.rounded)

        assertSnapshots(of: view)
    }

    /// Checks that the mark moves to the other corner in a right-to-left language.
    @Test func roundedStyleRightToLeft() {
        let view = avatarsWithStatus()
            .padding(Spacing.lg)
            .avatarStyle(.rounded)
            .environment(\.layoutDirection, .rightToLeft)

        assertSnapshots(of: view)
    }

    /// Checks every fallback, because each draws something a redaction would
    /// otherwise turn into a rectangle sitting inside the avatar's shape.
    @Test func redacted() {
        let view = redactedAvatars()

        assertSnapshots(of: view)
    }

    /// Checks the same three fallbacks in the rounded style, because a style changes the skeleton.
    @Test func roundedStyleRedacted() {
        let view = redactedAvatars().avatarStyle(.rounded)

        assertSnapshots(of: view)
    }

    /// Checks both styles on both grouped surfaces, because each surface hides something.
    ///
    /// In light mode the fallback's disc matches `groupedSurface`, and a pale photo fades into
    /// `secondaryGroupedSurface`. In dark mode the disc matches `secondaryGroupedSurface`, and a
    /// dark photo fades into `groupedSurface`.
    @Test func groupedSurfaces() {
        let view = VStack(spacing: 0) {
            avatarRow(on: .groupedSurface)
            avatarRow(on: .secondaryGroupedSurface)
            avatarRow(on: .groupedSurface).avatarStyle(.rounded)
            avatarRow(on: .secondaryGroupedSurface).avatarStyle(.rounded)
        }

        assertColorSpecimenSnapshots(of: view)
    }

    /// Returns a row of four avatars on a surface: initials, a pale photo, a dark photo and a
    /// redacted one.
    ///
    /// - Parameter surface: The surface the row sits on.
    /// - Returns: A padded row of four large avatars on the surface.
    private func avatarRow(on surface: BrandShapeStyle) -> some View {
        let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")

        return HStack(spacing: Spacing.lg) {
            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(name))

            Avatar(url: nil, size: AvatarSize.large) { Self.palePhoto }

            Avatar(url: nil, size: AvatarSize.large) { Self.darkPhoto }

            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(name))
                .redacted(reason: .placeholder)
        }
        .padding(Spacing.lg)
        .background(surface)
    }

    /// Returns a row of three avatars with different fallbacks, drawn as placeholders.
    ///
    /// - Returns: A redacted row of a symbol, initials and a custom mark.
    private func redactedAvatars() -> some View {
        let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")

        return HStack(spacing: Spacing.lg) {
            Avatar(url: nil, size: AvatarSize.large)

            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(name))

            Avatar(url: nil, size: AvatarSize.large) {
                Image(icon: .locked)
                    .foregroundStyle(.secondaryText)
            }
        }
        .redacted(reason: .placeholder)
    }

    /// Returns a row of the four avatar sizes, each with a status mark.
    ///
    /// - Returns: A row of four avatars, smallest first.
    private func avatarsWithStatus() -> some View {
        HStack(alignment: .bottom, spacing: Spacing.lg) {
            Avatar(url: nil, size: AvatarSize.small, status: AvatarStatus("Checked in"))
            Avatar(url: nil, size: AvatarSize.medium, status: AvatarStatus("Checked in"))
            Avatar(url: nil, size: AvatarSize.large, status: AvatarStatus("Checked in"))
            Avatar(
                url: nil,
                size: AvatarSize.xLarge,
                status: AvatarStatus(
                    "Waitlisted",
                    icon: Icon(.exclamationmarkCircleFill),
                    family: .warning,
                ),
            )
        }
    }

    /// Returns an avatar with a flat fill, so the image shows only its shape, size and outline.
    ///
    /// - Parameter size: The size to draw the avatar at.
    /// - Returns: An avatar of the given size filled with a flat color.
    private func avatar(size: AvatarSize) -> some View {
        Avatar(url: nil, size: size) {
            Rectangle().fill(.secondarySurface)
        }
    }
}
#endif
