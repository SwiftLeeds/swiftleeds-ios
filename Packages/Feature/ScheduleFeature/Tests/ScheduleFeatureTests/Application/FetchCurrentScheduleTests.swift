import Dependencies
import ScheduleApplication
import ScheduleDomain
import Testing

/// Unit tests of the repository call `FetchCurrentSchedule` makes.
@Suite struct FetchCurrentScheduleTests {
    /// The current schedule has no event id, so the recorder sees `nil`.
    @Test func whenFetchingTheCurrentSchedule_shouldAskTheRepositoryForNoEvent() async throws {
        let recorder = EventRecorder()

        _ = try await withDependencies {
            $0.scheduleRepository = .recording(into: recorder, answering: try .fixture())
        } operation: {
            try await FetchCurrentSchedule.liveValue()
        }

        #expect(await recorder.events == [nil])
    }
}
