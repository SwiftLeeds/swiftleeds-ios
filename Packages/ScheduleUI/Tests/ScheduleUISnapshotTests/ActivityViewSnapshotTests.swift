#if os(iOS)
import ScheduleFeature
import ScheduleUI
import SwiftUI
import Testing

@MainActor
@Suite struct ActivityViewSnapshotTests {
    @Test func coffeeBreak() {
        let view = ActivityView(activity: .coffeeBreak)

        assertScreenSnapshots(of: view)
    }
}
#endif
