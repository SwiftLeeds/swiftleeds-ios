import Dependencies

/// Reads the conference team.
package struct TeamRepository: Sendable {
    package var fetch: @Sendable () async throws(TeamFetchError) -> [TeamMember]

    package init(fetch: @escaping @Sendable () async throws(TeamFetchError) -> [TeamMember]) {
        self.fetch = fetch
    }
}

extension TeamRepository: TestDependencyKey {
    package static let testValue = TeamRepository(
        fetch: { () async throws(TeamFetchError) -> [TeamMember] in
            reportIssue("TeamRepository.fetch is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    package var teamRepository: TeamRepository {
        get { self[TeamRepository.self] }
        set { self[TeamRepository.self] = newValue }
    }
}
