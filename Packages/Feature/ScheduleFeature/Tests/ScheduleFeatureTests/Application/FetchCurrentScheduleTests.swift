import Dependencies
import Foundation
import ScheduleApplication
import ScheduleDomain
import Testing

/// Unit tests of `FetchCurrentSchedule`.
@Suite struct FetchCurrentScheduleTests {
    /// The result is the current schedule the repository fetches.
    @Test func whenFetchingCurrentSchedule_shouldReturnCurrentSchedule() async throws {
        let eventID = UUID()
        let expected = try Schedule.fixture(eventID: eventID)
        var repository = ScheduleRepository.testValue
        repository.fetchCurrentSchedule = { expected }

        let schedule = try await withDependencies {
            $0.scheduleRepository = repository
        } operation: {
            try await FetchCurrentSchedule.liveValue()
        }

        #expect(schedule.data.event.id == eventID)
    }
}
