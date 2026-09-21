import Dependencies
import Foundation
import NetworkKit

extension TeamRepository: DependencyKey {
    package static var liveValue: TeamRepository {
        TeamRepository { () async throws(TeamFetchError) -> [TeamMember] in
            @Dependency(\.httpClient) var httpClient

            do {
                let (data, _) = try await httpClient.send(Endpoint.team.urlRequest())
                let team = try JSONDecoder().decode(TeamDTO.self, from: data)
                return try TeamMapper.live.map(team)
            } catch {
                throw TeamFetchError.unknown
            }
        }
    }
}
