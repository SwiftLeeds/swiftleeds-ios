#if os(iOS)
import ScheduleUI
import SwiftUI
import Testing

@MainActor
@Suite struct CommonTileButtonSnapshotTests {
    @Test func iconOnGradient() {
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
