import Dependencies
import Foundation

extension AttendeeRepository: DependencyKey {
    package static var liveValue: AttendeeRepository {
        AttendeeRepository { () async throws(AttendeeFetchError) -> Attendee in
            @Dependency(\.httpClient) var httpClient
            @Dependency(\.apiConfiguration) var apiConfiguration
            let request = URLRequest(url: Endpoint.profile.url(baseURL: apiConfiguration.baseURL))
            let data: Data
            let response: HTTPURLResponse
            do {
                (data, response) = try await httpClient.send(request)
            } catch {
                throw AttendeeFetchError.unknown
            }
            return try AttendeeMapper.map(data, response)
        }
    }
}
