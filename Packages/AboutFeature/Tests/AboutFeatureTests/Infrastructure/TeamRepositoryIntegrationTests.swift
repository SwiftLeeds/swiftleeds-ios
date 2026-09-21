import AboutFeature
import Dependencies
import Foundation
import NetworkKit
import Testing

// Drives the composed `liveValue` with only the transport stubbed.
@Suite struct TeamRepositoryIntegrationTests {
    @Test func whenServerReturnsValidTeam_shouldReturnMembers() async throws {
        let data = TeamJSON.team(TeamJSON.member(name: "Adam Rush"), TeamJSON.member(name: "Paul Willis"))

        let members = try await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
        } operation: {
            try await TeamRepository.liveValue.fetch()
        }

        #expect(members.map(\.name) == ["Adam Rush", "Paul Willis"])
    }

    @Test func whenRequestThrows_shouldThrowCouldNotReachServer() async throws {
        await withDependencies {
            $0.httpClient = .failing(with: URLError(.notConnectedToInternet))
        } operation: {
            await #expect(throws: TeamFetchError.couldNotReachServer) {
                try await TeamRepository.liveValue.fetch()
            }
        }
    }
}
