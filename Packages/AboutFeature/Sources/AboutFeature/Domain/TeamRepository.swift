import Dependencies

/// The source of the conference team.
package struct TeamRepository: Sendable {
    /// Fetches the conference team.
    /// - Throws: A ``TeamFetchError`` when the request fails or the response cannot be read.
    package var fetch: @Sendable () async throws(TeamFetchError) -> [TeamMember]

    /// Creates a repository.
    package init(fetch: @escaping @Sendable () async throws(TeamFetchError) -> [TeamMember]) {
        self.fetch = fetch
    }
}

extension TeamRepository: TestDependencyKey {
    /// A repository that reports an issue, then throws ``TeamFetchError/unknown``.
    package static let testValue = TeamRepository(
        fetch: { () async throws(TeamFetchError) -> [TeamMember] in
            reportIssue("TeamRepository.fetch is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    /// The team repository the current context uses.
    package var teamRepository: TeamRepository {
        get { self[TeamRepository.self] }
        set { self[TeamRepository.self] = newValue }
    }
}
