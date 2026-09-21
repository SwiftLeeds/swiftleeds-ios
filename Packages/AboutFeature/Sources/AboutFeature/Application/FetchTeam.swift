import Dependencies

public struct FetchTeam: Sendable {
    private var perform: @Sendable () async throws(TeamFetchError) -> [TeamMember]

    public init(perform: @escaping @Sendable () async throws(TeamFetchError) -> [TeamMember]) {
        self.perform = perform
    }

    public func callAsFunction() async throws(TeamFetchError) -> [TeamMember] {
        try await perform()
    }
}

extension FetchTeam: DependencyKey {
    public static var liveValue: FetchTeam {
        FetchTeam { () async throws(TeamFetchError) -> [TeamMember] in
            @Dependency(\.teamRepository) var teamRepository
            return try await teamRepository.fetch()
        }
    }

    public static let testValue = FetchTeam(
        perform: { () async throws(TeamFetchError) -> [TeamMember] in
            reportIssue("FetchTeam is unimplemented")
            throw .unknown
        }
    )
}

extension DependencyValues {
    public var fetchTeam: FetchTeam {
        get { self[FetchTeam.self] }
        set { self[FetchTeam.self] = newValue }
    }
}
