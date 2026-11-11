#if os(watchOS)
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct BadgeWatchSnapshotTests {
    /// A neutral badge, a teal badge with an icon and the four statuses, stacked.
    private var badges: some View {
        VStack(spacing: .xs) {
            Badge("Workshop")
            Badge("Workshop", icon: Icon(.hammerFill)).badgePalette(.teal)
            Badge("Confirmed", status: .success)
            Badge("Few seats", status: .warning)
            Badge("Cancelled", status: .error)
            Badge("New", status: .info)
        }
    }

    @Test func tinted() {
        assertSnapshots(of: badges.badgeStyle(.tinted))
    }

    @Test func filled() {
        assertSnapshots(of: badges.badgeStyle(.filled))
    }
}
#endif
