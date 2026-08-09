import Dependencies
import Foundation

extension AttendeeRepository: DependencyKey {
    package static var liveValue: AttendeeRepository {
        AttendeeRepository { () async throws(AttendeeFetchError) -> Attendee in
            @Dependency(\.httpClient) var httpClient
            let data: Data
            let response: HTTPURLResponse
            do {
                (data, response) = try await httpClient.send(URLRequest(url: profileURL))
            } catch {
                throw AttendeeFetchError.unknown
            }
            return try AttendeeMapper.map(data, response)
        }
    }
}

// The backend overloads `GET login/ticket` as the profile endpoint; that quirk is hidden here (the ACL).
// Host hardcoded as a temporary stopgap; move to a config dependency in a follow-up PR.
private let profileURL = URL(string: "https://swiftleeds.co.uk/api/v1/login/ticket")!
