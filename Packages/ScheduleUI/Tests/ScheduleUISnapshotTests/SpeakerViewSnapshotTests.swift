#if os(iOS)
import ScheduleFeature
import ScheduleUI
import SwiftUI
import Testing

@MainActor
@Suite struct SpeakerViewSnapshotTests {
    @Test func oneSpeaker() {
        let view = SpeakerView(presentation: .oneSpeaker, showSlido: false)

        assertScreenSnapshots(of: view)
    }

    // Slido only shows on the day, so its button needs its own case.
    @Test func duringConference() {
        let view = SpeakerView(presentation: .oneSpeaker, showSlido: true)

        assertScreenSnapshots(of: view)
    }

    @Test func twoSpeakers() {
        let view = SpeakerView(presentation: .twoSpeakers, showSlido: false)

        assertScreenSnapshots(of: view)
    }
}
#endif
