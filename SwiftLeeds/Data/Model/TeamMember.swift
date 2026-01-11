import Foundation

struct Team: Codable {
    let teamMembers: [TeamMember]
}

struct TeamMember: Codable, Identifiable {
    let name: String
    let role: String?
    let linkedInURL: String?
    let twitterURL: String?
    let slackURL: String?
    let photoURL: String?
    
    var id: String { name }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case role
        case linkedInURL = "linkedin"
        case twitterURL = "twitter"
        case slackURL = "slack"
        case photoURL = "imageURL"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        linkedInURL = try container.decodeIfPresent(String.self, forKey: .linkedInURL)
        twitterURL = try container.decodeIfPresent(String.self, forKey: .twitterURL)
        slackURL = try container.decodeIfPresent(String.self, forKey: .slackURL)
        
        if let imageURL = try container.decodeIfPresent(String.self, forKey: .photoURL) {
            photoURL = imageURL.hasPrefix("/") ? "https://swiftleeds.co.uk\(imageURL)" : imageURL
        } else {
            photoURL = nil
        }
    }
    
    init(
        name: String,
        role: String?,
        linkedInURL: String?,
        twitterURL: String?,
        slackURL: String?,
        photoURL: String?
    ) {
        self.name = name
        self.role = role
        self.linkedInURL = linkedInURL
        self.twitterURL = twitterURL
        self.slackURL = slackURL
        self.photoURL = photoURL
    }
}
