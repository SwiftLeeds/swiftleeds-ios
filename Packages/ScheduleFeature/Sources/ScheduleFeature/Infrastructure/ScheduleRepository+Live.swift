import Dependencies
import Foundation

extension ScheduleRepository: DependencyKey {
    package static var liveValue: ScheduleRepository { live }

    static var live: ScheduleRepository {
        ScheduleRepository(
            fetchCurrentSchedule: { () async throws(ScheduleFetchError) -> Schedule in
                try await schedule(for: .current)
            },
            fetchSchedule: { event async throws(ScheduleFetchError) -> Schedule in
                try await schedule(for: .event(event))
            }
        )
    }

    private static func schedule(
        for request: ScheduleRequest
    ) async throws(ScheduleFetchError) -> Schedule {
        @Dependency(\.localScheduleStore) var local
        @Dependency(\.remoteScheduleStore) var remote
        @Dependency(\.date) var date

        if let stored = local.load(request), stored.isFresh(at: date.now) {
            return stored.schedule
        }

        let schedule = try await remote.fetch(request)
        let stored = StoredSchedule(schedule: schedule, storedAt: date.now)
        local.save(stored, request)

        if request == .current {
            local.save(stored, .event(schedule.data.event.id))
        }

        return schedule
    }
}
