import ScheduleFeature
import Testing

@Suite struct ScheduleDataTests {
    @Test func whenBuiltWithNoDays_shouldRefuseIt() {
        #expect(throws: Schedule.Data.ParsingError.noDays) {
            try Schedule.Data(event: .fixture(), events: [], days: [])
        }
    }

    @Test func whenBuiltWithADay_shouldKeepIt() throws {
        let schedule = try Schedule.fixture()

        #expect(schedule.data.days.count == 1)
    }
}
