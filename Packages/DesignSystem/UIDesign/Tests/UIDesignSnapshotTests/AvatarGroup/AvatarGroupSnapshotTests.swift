#if os(iOS)
import Foundation
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct AvatarGroupSnapshotTests {
    /// Six made-up people whose initials differ, so the image can tell them apart.
    private static let people = [
        PersonNameComponents(givenName: "Ada", familyName: "Archer"),
        PersonNameComponents(givenName: "Blake", familyName: "Brooks"),
        PersonNameComponents(givenName: "Casey", familyName: "Cole"),
        PersonNameComponents(givenName: "Devon", familyName: "Drake"),
        PersonNameComponents(givenName: "Ellis", familyName: "East"),
        PersonNameComponents(givenName: "Frankie", familyName: "Fox"),
    ]

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
}
#endif
