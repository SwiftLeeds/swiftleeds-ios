import AboutFeature
import Dependencies
import Foundation
import NetworkKit
import NetworkKitTestSupport
import Testing

// Drives the composed `liveValue` with only the transport stubbed.
@Suite struct TeamRepositoryIntegrationTests {
    @Test func whenServerReturnsValidTeam_shouldReturnMembers() async throws {
        let data = TeamJSON.team(TeamJSON.member(name: "Member One"), TeamJSON.member(name: "Member Two"))

        let members = try await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
        } operation: {
            try await TeamRepository.liveValue.fetch()
        }

        #expect(members.map(\.name) == ["Member One", "Member Two"])
    }

    @Test func whenMemberHasOnlyRequiredKeys_shouldReturnMemberWithNoRoleOrLinks() async throws {
        let data = TeamJSON.team(TeamJSON.member(name: "Member Three", role: nil, slack: nil))

        let members = try await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
        } operation: {
            try await TeamRepository.liveValue.fetch()
        }

        let member = try #require(members.first)
        #expect(member.name == "Member Three")
        #expect(member.role == nil)
        #expect(member.links.isEmpty)
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

    @Test func whenBodyCannotBeDecoded_shouldThrowInvalidResponse() async throws {
        await withDependencies {
            $0.httpClient = .responding(with: Data("nonsense".utf8), statusCode: 200)
        } operation: {
            await #expect(throws: TeamFetchError.invalidResponse) {
                try await TeamRepository.liveValue.fetch()
            }
        }
    }

    @Test(arguments: [404, 500])
    func whenStatusIsNotOK_shouldThrowUnknown(statusCode: Int) async throws {
        let data = TeamJSON.team(TeamJSON.member())

        await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: statusCode)
        } operation: {
            await #expect(throws: TeamFetchError.unknown) {
                try await TeamRepository.liveValue.fetch()
            }
        }
    }

    @Test func whenMapperThrows_shouldThrowInvalidResponse() async throws {
        let data = TeamJSON.team(TeamJSON.member(slack: ""))

        await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
        } operation: {
            await #expect(throws: TeamFetchError.invalidResponse) {
                try await TeamRepository.liveValue.fetch()
            }
        }
    }

    @Test func whenMapperIsReplaced_shouldReturnItsMembers() async throws {
        let data = TeamJSON.team(TeamJSON.member(name: "ignored"))
        let expected = try TeamMember.fixture(name: "From the mapper")

        let members = try await withDependencies {
            $0.httpClient = .responding(with: data, statusCode: 200)
            $0.teamMapper = TeamMapper { _ in [expected] }
        } operation: {
            try await TeamRepository.liveValue.fetch()
        }

        #expect(members == [expected])
    }
}
