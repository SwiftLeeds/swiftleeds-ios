import Dependencies
import Foundation
import NetworkKit

extension ScheduleRepository: DependencyKey {
    package static var liveValue: ScheduleRepository { live }

    static var live: ScheduleRepository {
        ScheduleRepository(
            fetchCurrentSchedule: { () async throws(ScheduleFetchError) -> Schedule in
                try await schedule(for: nil)
            },
            fetchSchedule: { event async throws(ScheduleFetchError) -> Schedule in
                try await schedule(for: event)
            }
        )
    }

    private static func schedule(for event: UUID?) async throws(ScheduleFetchError) -> Schedule {
        @Dependency(\.httpClient) var httpClient
        @Dependency(\.scheduleMapper) var scheduleMapper

        let data: Foundation.Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await httpClient.send(Endpoint.schedule(event: event).urlRequest())
        } catch {
            throw ScheduleFetchError.couldNotReachServer
        }

        do throws(ScheduleMapper.ResponseError) {
            return try scheduleMapper.map(data, response)
        } catch {
            switch error {
            case .unexpectedStatus:
                throw ScheduleFetchError.unknown
            case .couldNotDecode:
                throw ScheduleFetchError.invalidResponse
            }
        }
    }
}
