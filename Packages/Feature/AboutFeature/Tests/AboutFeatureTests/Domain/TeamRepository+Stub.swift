import AboutFeature

extension TeamRepository {
    static func returning(_ members: [TeamMember]) -> TeamRepository {
        TeamRepository { members }
    }

    static func failing(with error: TeamFetchError) -> TeamRepository {
        TeamRepository { () async throws(TeamFetchError) -> [TeamMember] in
            throw error
        }
    }
}
