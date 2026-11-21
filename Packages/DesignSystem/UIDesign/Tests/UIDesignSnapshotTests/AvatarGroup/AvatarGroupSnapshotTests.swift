#if os(iOS)
import Foundation
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct AvatarGroupSnapshotTests {
    /// A group style that draws the content in a fixed frame, so a test can tell it from the default.
    private struct FixedFrameAvatarGroupStyle: AvatarGroupStyle {
        /// The width of the frame, in points.
        static let width: CGFloat = 160

        /// The height of the frame, in points.
        static let height: CGFloat = 60

        func makeBody(configuration: Configuration) -> some View {
            HStack { configuration.content }
                .frame(width: Self.width, height: Self.height)
                .border(Color.primary)
        }
    }

    /// A group style that draws the color scheme it reads from the environment as a word.
    private struct ColorSchemeAvatarGroupStyle: AvatarGroupStyle {
        /// The color scheme the style reads from the environment.
        @Environment(\.colorScheme) private var colorScheme

        func makeBody(configuration: Configuration) -> some View {
            Text(colorScheme == .dark ? "dark" : "light")
        }
    }

    /// Six made-up people whose initials differ, so the image can tell them apart.
    private static let people = [
        PersonNameComponents(givenName: "Ada", familyName: "Archer"),
        PersonNameComponents(givenName: "Blake", familyName: "Brooks"),
        PersonNameComponents(givenName: "Casey", familyName: "Cole"),
        PersonNameComponents(givenName: "Devon", familyName: "Drake"),
        PersonNameComponents(givenName: "Ellis", familyName: "East"),
        PersonNameComponents(givenName: "Frankie", familyName: "Fox"),
    ]

    /// Three avatars with initials, the group the style tests draw in their own style.
    private static var threeAvatars: some View {
        AvatarGroup {
            ForEach(people.prefix(3), id: \.self) { name in
                Avatar(url: nil, size: .small, fallback: .initials(name))
            }
        }
    }

    @Test func whenThreeAvatars_shouldDrawSideBySide() {
        let view = AvatarGroup {
            ForEach(Self.people.prefix(3), id: \.self) { name in
                Avatar(url: nil, size: .small, fallback: .initials(name))
            }
        }
        .padding(.lg)
        .background(.surface)

        assertSnapshots(of: view)
    }

    @Test func whenOneOrTwoAvatars_shouldDrawEach() {
        let view = VStack(alignment: .leading, spacing: Spacing.lg) {
            AvatarGroup {
                Avatar(url: nil, size: .small, fallback: .initials(Self.people[0]))
            }

            AvatarGroup {
                ForEach(Self.people.prefix(2), id: \.self) { name in
                    Avatar(url: nil, size: .small, fallback: .initials(name))
                }
            }
        }
        .padding(.lg)
        .background(.surface)

        assertSnapshots(of: view)
    }

    @Test func whenAvatarsHaveStatuses_shouldShowEachMark() {
        let view = AvatarGroup {
            Avatar(
                url: nil,
                size: .small,
                status: AvatarStatus("Checked in"),
                fallback: .initials(Self.people[0]),
            )

            Avatar(
                url: nil,
                size: .small,
                status: AvatarStatus(
                    "Waitlisted",
                    icon: Icon(.exclamationmarkCircleFill),
                    family: .warning,
                ),
                fallback: .initials(Self.people[1]),
            )

            Avatar(url: nil, size: .small, fallback: .initials(Self.people[2]))
        }
        .padding(.lg)
        .background(.surface)

        assertSnapshots(of: view)
    }

    @Test func whenStyleReadsColorScheme_shouldSeeTheCurrentScheme() {
        let view = Self.threeAvatars
            .avatarGroupStyle(ColorSchemeAvatarGroupStyle())
            .padding(.lg)
            .background(.surface)

        assertSpecimenSnapshots(of: view)
    }

    @Test func whenStyleIsSetOnParent_shouldReachGroup() {
        let view = VStack { Self.threeAvatars }
            .avatarGroupStyle(FixedFrameAvatarGroupStyle())
            .padding(.lg)
            .background(.surface)

        assertSpecimenSnapshots(of: view)
    }
}
#endif
