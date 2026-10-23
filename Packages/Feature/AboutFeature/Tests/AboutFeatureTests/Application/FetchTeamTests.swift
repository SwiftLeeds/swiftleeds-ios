import AboutFeature
import Dependencies
import Testing

@Suite struct FetchTeamTests {
    @Test func whenRepositoryReturnsMembers_shouldReturnSameMembers() async throws {
        let expected = [
            try TeamMember.fixture(name: "Member One"),
            try TeamMember.fixture(name: "Member Two"),
        ]

        let members = try await withDependencies {
            $0.teamRepository = .returning(expected)
        } operation: {
            try await FetchTeam.liveValue()
        }

        #expect(members == expected)
    }

    @Test func whenRepositoryThrows_shouldThrowSameError() async {
        await withDependencies {
            $0.teamRepository = .failing(with: .couldNotReachServer)
        } operation: {
            await #expect(throws: TeamFetchError.couldNotReachServer) {
                try await FetchTeam.liveValue()
            }
        }
    }
}
