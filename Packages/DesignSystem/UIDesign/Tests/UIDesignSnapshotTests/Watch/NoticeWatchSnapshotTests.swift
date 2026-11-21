#if os(watchOS)
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct NoticeWatchSnapshotTests {
    /// A notice with a title, a description and an action.
    private var notice: some View {
        Notice(
            "You're offline",
            icon: Icon(.wifiSlash),
            description: Text("The schedule shows what was saved. It updates when you reconnect."),
        ) {
            Button("Try Again") {}
                .buttonStyle(.borderless)
        }
    }

    @Test func whenNoticeHasAction_shouldFitWatchScreen() {
        assertSnapshots(of: notice)
    }

    @Test func whenContrastIsIncreased_shouldFitWatchScreen() {
        let view = notice.environment(\._colorSchemeContrast, .increased)
        assertSnapshots(of: view)
    }
}
#endif
