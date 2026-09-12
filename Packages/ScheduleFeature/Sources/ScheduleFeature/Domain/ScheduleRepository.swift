import Dependencies
import Foundation

/// Reads the schedule. Passing no event asks the backend for the conference it considers current.
package struct ScheduleRepository: Sendable {
    package var fetch: @Sendable (UUID?) async throws(ScheduleFetchError) -> Schedule

    package init(fetch: @escaping @Sendable (UUID?) async throws(ScheduleFetchError) -> Schedule) {
        self.fetch = fetch
    }
}

extension ScheduleRepository: TestDependencyKey {
    package static let testValue = ScheduleRepository(
        fetch: { _ async throws(ScheduleFetchError) -> Schedule in
            reportIssue("ScheduleRepository.fetch is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    package var scheduleRepository: ScheduleRepository {
        get { self[ScheduleRepository.self] }
        set { self[ScheduleRepository.self] = newValue }
    }
}
