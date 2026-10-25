import Dependencies
import Foundation
import ScheduleApplication
import ScheduleDomain
import Testing

/// Unit tests of the repository call `FetchSchedule` makes.
@Suite struct FetchScheduleTests {
    /// The event id passes through to the repository unchanged.
    @Test func whenFetchingOneEvent_shouldAskTheRepositoryForThatEvent() async throws {
        let spy = ScheduleRepositorySpy()
        let event = UUID()

        _ = try await withDependencies {
            $0.scheduleRepository = .recording(into: spy, answering: try .fixture())
        } operation: {
            try await FetchSchedule.liveValue(for: event)
        }

        #expect(await spy.events == [event])
    }
}
