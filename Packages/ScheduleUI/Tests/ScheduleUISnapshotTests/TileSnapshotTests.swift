#if os(iOS)
import ScheduleUI
import SwiftUI
import Testing

@MainActor
@Suite struct TileSnapshotTests {
    @Test func commonTileWithSecondaryText() {
        let view = CommonTileView(
            primaryText: "Twitter",
            secondaryText: "@alexfletcher",
            secondaryColor: Color.primary
        )

        assertTileSnapshots(of: view, width: fullTileWidth)
    }

    @Test func commonTileWithIconAndChevron() {
        let view = CommonTileView(
            icon: "video.fill",
            primaryText: "Watch video",
            showChevron: true,
            secondaryColor: Color.primary
        )

        assertTileSnapshots(of: view, width: fullTileWidth)
    }

    @Test func stackedTile() {
        let view = StackedTileView(
            primaryText: "Practical Swift concurrency",
            secondaryText: "What actors buy you, and what they cost.",
            secondaryColor: Color.primary
        )

        assertTileSnapshots(of: view, width: fullTileWidth)
    }

    @Test func tileButton() {
        let view = CommonTileButton(
            icon: "questionmark.bubble.fill",
            primaryText: "Ask Questions Now",
            accessibilityHint: "Opens Slido to allow questions to be asked",
            primaryColor: .white,
            secondaryColor: .white.opacity(0.8),
            backgroundStyle: LinearGradient(colors: [.blue, .teal], startPoint: .leading, endPoint: .trailing),
            onTap: {}
        )

        assertTileSnapshots(of: view, width: fullTileWidth)
    }
}
#endif
