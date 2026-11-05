#if os(watchOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct AvatarWatchSnapshotTests {
    /// A made-up person whose initials the avatar shows.
    private static let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")

    @Test func initialsFallback() {
        let view = Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.name))

        assertSnapshots(of: view)
    }

    @Test func symbolFallback() {
        let view = Avatar(url: nil, size: AvatarSize.large)

        assertSnapshots(of: view)
    }

    @Test func statusMark() {
        let view = Avatar(
            url: nil,
            size: AvatarSize.large,
            status: AvatarStatus("Checked in"),
            fallback: .initials(Self.name),
        )

        assertSnapshots(of: view)
    }

    @Test func redacted() {
        let view = Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.name))
            .redacted(reason: .placeholder)

        assertSnapshots(of: view)
    }

    @Test func increasedContrast() {
        let view = Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.name))
            .environment(\._colorSchemeContrast, .increased)

        assertSnapshots(of: view)
    }
}
#endif
