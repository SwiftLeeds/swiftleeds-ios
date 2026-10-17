#if os(iOS)
import ScheduleUI
import Testing

@MainActor
@Suite struct ActivityViewSnapshotTests {
    @Test func coffeeBreak() {
        let view = ActivityView(activity: .coffeeBreak)

        assertScreenSnapshots(of: view)
    }

    @Test func registration() {
        let view = ActivityView(activity: .registration)

        assertScreenSnapshots(of: view)
    }
}
#endif
