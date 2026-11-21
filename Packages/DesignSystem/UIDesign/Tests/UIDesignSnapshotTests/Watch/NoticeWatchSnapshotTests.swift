#if os(watchOS)
import SFSafeSymbols
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct NoticeWatchSnapshotTests {
    /// A notice with a title, a description and a bordered action, at the top of the screen.
    ///
    /// A Watch screen first shows the top of its content, so the picture shows what a person sees
    /// before they scroll. A `ScrollView` draws nothing in a render with no host, so a frame that
    /// aligns the notice to the top stands in for it.
    private var screen: some View {
        Notice(
            "You're offline",
            icon: Icon(.wifiSlash),
            description: Text("The schedule shows what was saved. It updates when you reconnect."),
        ) {
            Button("Try Again") {}
                .buttonStyle(.bordered)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @Test func whenNoticeHasAction_shouldDrawBorderedActionBelowText() {
        assertSnapshots(of: screen)
    }

    @Test func whenContrastIsIncreased_shouldDrawBorderedActionBelowText() {
        let view = screen.environment(\._colorSchemeContrast, .increased)
        assertSnapshots(of: view)
    }
}
#endif
