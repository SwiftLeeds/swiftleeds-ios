import Dependencies
import Foundation
import NetworkKit

extension TeamRepository: DependencyKey {
    package static var liveValue: TeamRepository {
        TeamRepository { () async throws(TeamFetchError) -> [TeamMember] in
            @Dependency(\.httpClient) var httpClient
            @Dependency(\.teamMapper) var teamMapper

            let data: Data
            let response: HTTPURLResponse
            do {
                (data, response) = try await httpClient.send(Endpoint.team.urlRequest())
            } catch {
                throw TeamFetchError.couldNotReachServer
            }

            guard response.status == .ok else {
                throw TeamFetchError.unknown
            }

            let team: TeamDTO
            do {
                team = try JSONDecoder().decode(TeamDTO.self, from: data)
            } catch {
                throw TeamFetchError.invalidResponse
            }

            do throws(TeamMapper.MappingError) {
                return try teamMapper.map(team)
            } catch {
                throw TeamFetchError.invalidResponse
            }
        }
    }
}
