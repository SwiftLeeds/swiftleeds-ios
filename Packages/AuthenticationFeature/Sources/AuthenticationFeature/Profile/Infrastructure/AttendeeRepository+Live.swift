import Dependencies
import Foundation
import NetworkKit

extension AttendeeRepository: DependencyKey {
    package static var liveValue: AttendeeRepository {
        AttendeeRepository { () async throws(AttendeeFetchError) -> Attendee in
            @Dependency(\.httpClient) var httpClient
            @Dependency(\.attendeeMapper) var attendeeMapper
            let request = Endpoint.ticket.urlRequest()
            let data: Data
            let response: HTTPURLResponse
            do {
                (data, response) = try await httpClient.send(request)
            } catch {
                throw AttendeeFetchError.couldNotReachServer
            }
            do throws(AttendeeMapper.ResponseError) {
                return try attendeeMapper.map(data, response)
            } catch {
                throw AttendeeFetchError(error)
            }
        }
    }
}
