import Dependencies

/// Turns the backend's team into team members.
package struct TeamMapper: Sendable {
    package var map: @Sendable (TeamDTO) -> [TeamMember]

    package init(map: @escaping @Sendable (TeamDTO) -> [TeamMember]) {
        self.map = map
    }
}

extension TeamMapper {
    package static let live = TeamMapper { team in
        team.teamMembers.map(member)
    }

    private static func member(_ dto: TeamDTO.MemberDTO) -> TeamMember {
        TeamMember(id: TeamMemberID(dto.name), name: dto.name, role: dto.role)
    }
}
