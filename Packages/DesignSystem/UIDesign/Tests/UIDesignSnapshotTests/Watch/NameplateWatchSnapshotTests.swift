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
}
#endif
