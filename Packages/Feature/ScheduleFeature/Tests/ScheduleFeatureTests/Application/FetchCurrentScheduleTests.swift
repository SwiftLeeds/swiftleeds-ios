import Dependencies
import ScheduleApplication
import ScheduleDomain
import Testing

/// Unit tests of the repository call `FetchCurrentSchedule` makes.
@Suite struct FetchCurrentScheduleTests {
    /// The current schedule has no event id, so the spy sees `nil`.
    @Test func whenFetchingTheCurrentSchedule_shouldAskTheRepositoryForNoEvent() async throws {
        let spy = ScheduleRepositorySpy()

        _ = try await withDependencies {
            $0.scheduleRepository = .recording(into: spy, answering: try .fixture())
        } operation: {
            try await FetchCurrentSchedule.liveValue()
        }

        #expect(await spy.events == [nil])
    }
}
