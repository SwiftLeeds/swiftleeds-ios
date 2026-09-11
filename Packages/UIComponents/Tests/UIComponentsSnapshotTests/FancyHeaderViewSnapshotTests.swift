#if os(iOS)
import SharedAssets
import SnapshotTesting
import SwiftUI
import Testing
import UIComponents

@MainActor
@Suite struct FancyHeaderViewSnapshotTests {
    @Test func fallbackIcon() {
        let view = FancyHeaderView(title: "About")

        assertHeaderSnapshots(of: view)
    }

    @Test func suppliedImage() {
        let view = FancyHeaderView(title: "Sponsors", foregroundImage: Image.swiftLeedsIcon)

        assertHeaderSnapshots(of: view)
    }

    @Test func longTitle() {
        let view = FancyHeaderView(
            title: "A title long enough to wrap onto a second line",
            foregroundImage: Image.swiftLeedsIcon
        )

        assertHeaderSnapshots(of: view)
    }
}
#endif
