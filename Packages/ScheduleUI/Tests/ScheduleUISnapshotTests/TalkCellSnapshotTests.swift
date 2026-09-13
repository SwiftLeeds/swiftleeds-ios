#if os(iOS)
import ScheduleFeature
import ScheduleUI
import Testing

@MainActor
@Suite struct TalkCellSnapshotTests {
    @Test func oneSpeaker() {
        let presentation = Presentation.oneSpeaker
        let view = TalkCell(
            time: "11:00",
            details: presentation.title,
            speakers: presentation.speakers
        )

        assertTileSnapshots(of: view, width: fullTileWidth)
    }

    @Test func twoSpeakers() {
        let presentation = Presentation.twoSpeakers
        let view = TalkCell(
            time: "13:30",
            details: presentation.title,
            speakers: presentation.speakers
        )

        assertTileSnapshots(of: view, width: fullTileWidth)
    }

    @Test func noSpeakers() {
        let view = TalkCell(time: "12:00", details: "Lunch")

        assertTileSnapshots(of: view, width: fullTileWidth)
    }
}
#endif
