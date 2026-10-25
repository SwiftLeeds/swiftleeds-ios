import Dependencies
import Foundation
import ScheduleApplication
import ScheduleDomain
import Testing

/// Unit tests of `FetchSchedule`.
@Suite struct FetchScheduleTests {
    /// The result is the schedule of the event asked for.
    @Test func whenFetchingOneEvent_shouldReturnScheduleOfThatEvent() async throws {
        let eventID = UUID()
        let expected = try Schedule.fixture(eventID: eventID)
        var repository = ScheduleRepository.testValue
        repository.fetchSchedule = { requested async throws(ScheduleFetchError) -> Schedule in
            guard requested == eventID else {
                reportIssue("fetchSchedule asked for \(requested), expected \(eventID)")
                throw .unknown
            }
            return expected
        }

        let schedule = try await withDependencies {
            $0.scheduleRepository = repository
        } operation: {
            try await FetchSchedule.liveValue(for: eventID)
        }

        #expect(schedule.data.event.id == eventID)
    }
}
