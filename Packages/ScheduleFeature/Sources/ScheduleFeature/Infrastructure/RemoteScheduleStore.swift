import Dependencies
import Foundation
import NetworkKit

/// The schedules the backend holds.
package struct RemoteScheduleStore: Sendable {
    package var fetch: @Sendable (ScheduleRequest) async throws(ScheduleFetchError) -> Schedule

    package init(
        fetch: @escaping @Sendable (ScheduleRequest) async throws(ScheduleFetchError) -> Schedule
    ) {
        self.fetch = fetch
    }
}

extension RemoteScheduleStore: DependencyKey {
    package static var liveValue: RemoteScheduleStore {
        RemoteScheduleStore { request async throws(ScheduleFetchError) -> Schedule in
            @Dependency(\.httpClient) var httpClient
            @Dependency(\.scheduleMapper) var scheduleMapper

            let data: Foundation.Data
            let response: HTTPURLResponse
            do {
                (data, response) = try await httpClient.send(Endpoint.schedule(request).urlRequest())
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

    package static let testValue = RemoteScheduleStore(
        fetch: { _ async throws(ScheduleFetchError) -> Schedule in
            reportIssue("RemoteScheduleStore.fetch is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    package var remoteScheduleStore: RemoteScheduleStore {
        get { self[RemoteScheduleStore.self] }
        set { self[RemoteScheduleStore.self] = newValue }
    }
}
