/// The team as the backend sends it. Data only.
package struct TeamDTO: Decodable {
    package let teamMembers: [MemberDTO]

    package init(teamMembers: [MemberDTO]) {
        self.teamMembers = teamMembers
    }

    package struct MemberDTO: Decodable {
        package enum CodingKeys: String, CodingKey {
            case name
            case role
            case linkedin
            case twitter
            case slack
            case imageURL
        }

        package let name: String
        package let role: String?
        package let linkedin: String?
        package let twitter: String?
        package let slack: String?
        package let imageURL: String

        package init(
            name: String,
            role: String?,
            linkedin: String?,
            twitter: String?,
            slack: String?,
            imageURL: String
        ) {
            self.name = name
            self.role = role
            self.linkedin = linkedin
            self.twitter = twitter
            self.slack = slack
            self.imageURL = imageURL
        }
    }
}
