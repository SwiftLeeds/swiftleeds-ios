#if os(iOS)
import ScheduleFeature
import ScheduleUI
import SwiftUI
import Testing

@MainActor
@Suite struct DayViewSnapshotTests {
    @Test func talksAndBreak() {
        let view = NavigationStack {
            DayView(
                slots: [
                    .fixture(startTime: "09:30", presentation: .oneSpeaker),
                    .fixture(startTime: "10:30", activity: .coffeeBreak),
                    .fixture(startTime: "11:00", presentation: .twoSpeakers),
                ],
                showSlido: false
            )
        }

        assertScreenSnapshots(of: view)
    }
}
#endif
