#if os(iOS)
import ScheduleFeature
import ScheduleUI
import SwiftUI
import Testing

@MainActor
@Suite struct ScreenSnapshotTests {
    @Test func aDayOfSlots() {
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

    @Test func aDayWithNoSlots() {
        let view = NavigationStack {
            DayView(slots: [], showSlido: false)
        }

        assertScreenSnapshots(of: view)
    }

    @Test func aTalkWithOneSpeaker() {
        let view = SpeakerView(presentation: .oneSpeaker, showSlido: false)

        assertScreenSnapshots(of: view)
    }

    // Slido only shows on the day, so its button needs its own case.
    @Test func aTalkDuringTheConference() {
        let view = SpeakerView(presentation: .oneSpeaker, showSlido: true)

        assertScreenSnapshots(of: view)
    }

    @Test func aTalkWithTwoSpeakers() {
        let view = SpeakerView(presentation: .twoSpeakers, showSlido: false)

        assertScreenSnapshots(of: view)
    }

    @Test func anActivity() {
        let view = ActivityView(activity: .coffeeBreak)

        assertScreenSnapshots(of: view)
    }
}
#endif
