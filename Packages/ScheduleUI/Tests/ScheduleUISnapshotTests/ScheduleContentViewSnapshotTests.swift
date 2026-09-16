#if os(iOS)
import ScheduleFeature
import ScheduleUI
import Testing

@MainActor
@Suite struct ScheduleContentViewSnapshotTests {
    @Test func loading() {
        let view = ScheduleContentView(state: .loading)

        assertScreenSnapshots(of: view)
    }

    @Test func oneDay() {
        let view = ScheduleContentView(
            state: .loaded(days: [.fixture(named: "Day 1")], showSlido: false)
        )

        assertScreenSnapshots(of: view)
    }

    // Two days add the day headers, which one day does not draw.
    @Test func twoDaysWithThePicker() {
        let conferences: [Schedule.Event] = [.fixture(named: "SwiftLeeds 2025"), .fixture()]
        let view = ScheduleContentView(
            state: .loaded(
                days: [.fixture(named: "Day 1"), .fixture(named: "Day 2")],
                showSlido: true
            ),
            events: conferences,
            currentEvent: conferences.last
        )

        assertScreenSnapshots(of: view)
    }
}
#endif
