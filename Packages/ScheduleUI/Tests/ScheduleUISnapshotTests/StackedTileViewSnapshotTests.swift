#if os(iOS)
import ScheduleUI
import SwiftUI
import Testing

@MainActor
@Suite struct StackedTileViewSnapshotTests {
    @Test func titleAndBody() {
        let view = StackedTileView(
            primaryText: "Practical Swift concurrency",
            secondaryText: "What actors buy you, and what they cost.",
            secondaryColor: Color.primary
        )

        assertTileSnapshots(of: view, width: fullTileWidth)
    }
}
#endif
