#if os(watchOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

/// The reference images of the avatar on the Watch.
@MainActor
@Suite(.snapshots(record: .never)) struct AvatarWatchSnapshotTests {
    /// A made-up person whose initials the avatar shows.
    private static let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")

    /// Shows the avatar with the person's initials in place of a photo.
    @Test func initialsFallback() {
        let view = Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.name))

        assertSnapshots(of: view)
    }

    /// Shows the avatar with a person symbol in place of a photo.
    @Test func symbolFallback() {
        let view = Avatar(url: nil, size: AvatarSize.large)

        assertSnapshots(of: view)
    }

    /// Shows the avatar with a status mark beside the initials.
    @Test func statusMark() {
        let view = Avatar(
            url: nil,
            size: AvatarSize.large,
            status: AvatarStatus("Checked in"),
            fallback: .initials(Self.name),
        )

        assertSnapshots(of: view)
    }

    /// Shows the avatar as a loading placeholder.
    @Test func redacted() {
        let view = Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.name))
            .redacted(reason: .placeholder)

        assertSnapshots(of: view)
    }

    /// Shows the avatar with its edge drawn, as Increase Contrast asks.
    @Test func increasedContrast() {
        let view = Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.name))
            .environment(\._colorSchemeContrast, .increased)

        assertSnapshots(of: view)
    }
}
#endif
