import Foundation

public struct Speaker: Codable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let biography: String
    public let profileImage: String
    public let organisation: String
    public let twitter: String?

    public init(
        id: UUID,
        name: String,
        biography: String,
        profileImage: String,
        organisation: String,
        twitter: String?
    ) {
        self.id = id
        self.name = name
        self.biography = biography
        self.profileImage = profileImage
        self.organisation = organisation
        self.twitter = twitter
    }
}

// MARK: - Formatting helpers
extension Array where Element == Speaker {
    public var joinedNames: String {
        ListFormatter.localizedString(byJoining: self.map { $0.name })
    }

    public var joinedOrganisations: String {
        let organisations = Set(self.map { $0.organisation })
        return ListFormatter.localizedString(byJoining: organisations.map { $0 })
    }
}
