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
        @Dependency(\.remoteScheduleStore) var remote

        return try await remote.fetch(request)
    }
}
