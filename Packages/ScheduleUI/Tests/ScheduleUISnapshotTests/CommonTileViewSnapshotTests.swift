#if os(iOS)
import ScheduleUI
import SwiftUI
import Testing

@MainActor
@Suite struct CommonTileViewSnapshotTests {
    @Test func secondaryText() {
        let view = CommonTileView(
            primaryText: "Twitter",
            secondaryText: "@alexfletcher",
            secondaryColor: Color.primary
        )

        assertTileSnapshots(of: view, width: fullTileWidth)
    }

    @Test func iconAndChevron() {
        let view = CommonTileView(
            icon: "video.fill",
            primaryText: "Watch video",
            showChevron: true,
            secondaryColor: Color.primary
        )

        assertTileSnapshots(of: view, width: fullTileWidth)
    }
}
#endif
