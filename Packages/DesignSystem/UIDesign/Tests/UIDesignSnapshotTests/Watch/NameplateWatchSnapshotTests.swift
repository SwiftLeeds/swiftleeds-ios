#if os(watchOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct NameplateWatchSnapshotTests {
    /// A made-up name, held in a variable so it binds to the initializer that
    /// does not localize.
    private static let name = "Ada Archer"

    /// A made-up company, shown as the detail line.
    private static let company = "Northern Software"

    /// The name in parts, so the avatar can abbreviate it.
    private static let nameComponents = PersonNameComponents(
        givenName: "Ada",
        familyName: "Archer",
    )

    /// A made-up name long enough to wrap or truncate on the smallest screen.
    private static let longName = "Alexandria Montgomery-Fitzgerald"

    /// The long name in parts, so the avatar can abbreviate it.
    private static let longNameComponents = PersonNameComponents(
        givenName: "Alexandria",
        familyName: "Montgomery-Fitzgerald",
    )

    @Test func nameplate() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(Self.nameComponents))
        }

        assertSnapshots(of: view)
    }

    @Test func longName() {
        let view = Nameplate(Self.longName, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(Self.longNameComponents))
        }

        assertSnapshots(of: view)
    }

    @Test func withoutDetail() {
        let view = Nameplate(Self.name) {
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(Self.nameComponents))
        }

        assertSnapshots(of: view)
    }

    @Test func prominentStyle() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.nameComponents))
        }
        .nameplateStyle(.prominent)

        assertSnapshots(of: view)
    }

    @Test func withStatus() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(
                url: nil,
                size: AvatarSize.medium,
                status: AvatarStatus("Checked in"),
                fallback: .initials(Self.nameComponents),
            )
        }

        assertSnapshots(of: view)
    }

    @Test func withStatusAndLongName() {
        let view = Nameplate(Self.longName, detail: Self.company) {
            Avatar(
                url: nil,
                size: AvatarSize.medium,
                status: AvatarStatus("Checked in"),
                fallback: .initials(Self.longNameComponents),
            )
        }

        assertSnapshots(of: view)
    }

    @Test func withStatusAndBoldText() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(
                url: nil,
                size: AvatarSize.medium,
                status: AvatarStatus("Checked in"),
                fallback: .initials(Self.nameComponents),
            )
        }
        .environment(\.legibilityWeight, .bold)

        assertSnapshots(of: view)
    }

    @Test func withStatusAndIncreasedContrast() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(
                url: nil,
                size: AvatarSize.medium,
                status: AvatarStatus("Checked in"),
                fallback: .initials(Self.nameComponents),
            )
        }
        .environment(\._colorSchemeContrast, .increased)

        assertSnapshots(of: view)
    }

    @Test func withStatusRightToLeft() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(
                url: nil,
                size: AvatarSize.medium,
                status: AvatarStatus("Checked in"),
                fallback: .initials(Self.nameComponents),
            )
        }
        .environment(\.layoutDirection, .rightToLeft)

        assertSnapshots(of: view)
    }

    @Test func withStatusRedacted() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(
                url: nil,
                size: AvatarSize.medium,
                status: AvatarStatus("Checked in"),
                fallback: .initials(Self.nameComponents),
            )
        }
        .redacted(reason: .placeholder)

        assertSnapshots(of: view)
    }

    @Test func withWarningStatus() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(
                url: nil,
                size: AvatarSize.medium,
                status: AvatarStatus(
                    "Waitlisted",
                    icon: Icon(.exclamationmarkCircleFill),
                    family: .warning,
                ),
                fallback: .initials(Self.nameComponents),
            )
        }

        assertSnapshots(of: view)
    }

    @Test func redacted() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(Self.nameComponents))
        }
        .redacted(reason: .placeholder)

        assertSnapshots(of: view)
    }

    @Test func redactedProminent() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.nameComponents))
        }
        .nameplateStyle(.prominent)
        .redacted(reason: .placeholder)

        assertSnapshots(of: view)
    }

    @Test func increasedContrast() {
        let view = Nameplate(Self.name, detail: Self.company) {
            Avatar(url: nil, size: AvatarSize.medium, fallback: .initials(Self.nameComponents))
        }
        .environment(\._colorSchemeContrast, .increased)

        assertSnapshots(of: view)
    }
}
#endif
