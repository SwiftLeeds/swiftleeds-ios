import Dependencies
import Foundation

package struct ScheduleRepository: Sendable {
    package var fetchCurrentSchedule: @Sendable () async throws(ScheduleFetchError) -> Schedule
    package var fetchSchedule: @Sendable (UUID) async throws(ScheduleFetchError) -> Schedule

    package init(
        fetchCurrentSchedule: @escaping @Sendable () async throws(ScheduleFetchError) -> Schedule,
        fetchSchedule: @escaping @Sendable (UUID) async throws(ScheduleFetchError) -> Schedule
    ) {
        self.fetchCurrentSchedule = fetchCurrentSchedule
        self.fetchSchedule = fetchSchedule
    }
}

extension ScheduleRepository: TestDependencyKey {
    package static let testValue = ScheduleRepository(
        fetchCurrentSchedule: { () async throws(ScheduleFetchError) -> Schedule in
            reportIssue("ScheduleRepository.fetchCurrentSchedule is unimplemented")
            throw .unknown
        },
        fetchSchedule: { _ async throws(ScheduleFetchError) -> Schedule in
            reportIssue("ScheduleRepository.fetchSchedule is unimplemented")
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
