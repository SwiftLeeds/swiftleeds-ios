import Dependencies
import Foundation
import NetworkKit

/// The conversion from the backend's team to team members.
package struct TeamMapper: Sendable {
    /// A value from the backend that cannot become part of the model.
    package struct MappingError: Error, Equatable {
        package let member: TeamMemberID
        package let field: TeamDTO.MemberDTO.CodingKeys
        package let value: String

        package init(member: TeamMemberID, field: TeamDTO.MemberDTO.CodingKeys, value: String) {
            self.member = member
            self.field = field
            self.value = value
        }
    }

    package var map: @Sendable (TeamDTO) throws(MappingError) -> [TeamMember]

    package init(map: @escaping @Sendable (TeamDTO) throws(MappingError) -> [TeamMember]) {
        self.map = map
    }
}

extension TeamMapper {
    /// The mapper that keeps the team's order.
    ///
    /// It resolves a photo path against the base URL in `apiConfiguration`. It refuses the whole
    /// team when a photo path is empty, or a link is not an http or https web address.
    package static let live = TeamMapper { team throws(MappingError) in
        try team.teamMembers.map { dto throws(MappingError) in try member(dto) }
    }

    private static func member(_ dto: TeamDTO.MemberDTO) throws(MappingError) -> TeamMember {
        let id = TeamMemberID(dto.name)
        return TeamMember(
            id: id,
            name: dto.name,
            role: dto.role,
            photoURL: try photoURL(dto, member: id),
            links: try links(dto, member: id)
        )
    }

    private static func links(_ dto: TeamDTO.MemberDTO, member: TeamMemberID) throws(MappingError) -> [SocialLink] {
        [
            try dto.linkedin.map { link throws(MappingError) in
                SocialLink.linkedIn(try url(link, member: member, field: .linkedin))
            },
            try dto.twitter.map { link throws(MappingError) in
                SocialLink.twitter(try url(link, member: member, field: .twitter))
            },
            try dto.slack.map { link throws(MappingError) in
                SocialLink.slack(try url(link, member: member, field: .slack))
            },
        ]
        .compactMap(\.self)
    }

    private static func url(
        _ link: String,
        member: TeamMemberID,
        field: TeamDTO.MemberDTO.CodingKeys
    ) throws(MappingError) -> URL {
        guard let url = URL(string: link), url.isWebAddress else {
            throw MappingError(member: member, field: field, value: link)
        }
        return url
    }

    private static func photoURL(_ dto: TeamDTO.MemberDTO, member: TeamMemberID) throws(MappingError) -> URL {
        @Dependency(\.apiConfiguration) var apiConfiguration

        guard let url = URL(string: dto.imageURL, relativeTo: apiConfiguration.baseURL) else {
            throw MappingError(member: member, field: .imageURL, value: dto.imageURL)
        }
        return url.absoluteURL
    }
}

private extension URL {
    // `URL(string:)` accepts "twitter.example.com/member" as a relative URL, which a browser cannot open.
    var isWebAddress: Bool {
        guard let scheme = scheme?.lowercased(), let host, !host.isEmpty else { return false }
        return scheme == "http" || scheme == "https"
    }
}

private enum TeamMapperKey: DependencyKey {
    static var liveValue: TeamMapper { .live }
    static var testValue: TeamMapper { liveValue }
}

extension DependencyValues {
    package var teamMapper: TeamMapper {
        get { self[TeamMapperKey.self] }
        set { self[TeamMapperKey.self] = newValue }
    }
}
