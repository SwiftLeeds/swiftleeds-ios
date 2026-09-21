import Dependencies
import Foundation
import NetworkKit

/// Turns the backend's team into team members.
package struct TeamMapper: Sendable {
    /// A value the backend sent could not become part of the model.
    package struct MappingError: Error, Equatable {
        package let member: String
        package let field: TeamDTO.MemberDTO.CodingKeys
        package let value: String

        package init(member: String, field: TeamDTO.MemberDTO.CodingKeys, value: String) {
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
    /// Resolves a photo path against the configured API's base URL.
    package static let live = TeamMapper { team throws(MappingError) in
        try team.teamMembers.map { dto throws(MappingError) in try member(dto) }
    }

    private static func member(_ dto: TeamDTO.MemberDTO) throws(MappingError) -> TeamMember {
        TeamMember(
            id: TeamMemberID(dto.name),
            name: dto.name,
            role: dto.role,
            photoURL: try photoURL(dto)
        )
    }

    private static func photoURL(_ dto: TeamDTO.MemberDTO) throws(MappingError) -> URL {
        @Dependency(\.apiConfiguration) var apiConfiguration

        guard let url = URL(string: dto.imageURL, relativeTo: apiConfiguration.baseURL) else {
            throw MappingError(member: dto.name, field: .imageURL, value: dto.imageURL)
        }
        return url.absoluteURL
    }
}
