import Foundation

struct AboutURLs: Codable {
    let venue: String
    let codeOfConduct: String
    let reportAProblem: String
    let slack: String
    let youtube: String
}

struct AboutData: Codable {
    let urls: AboutURLs
    let truncatedAboutText: String
    let teamMembers: [TeamMember]
}

struct AboutContent: Codable {
    let urls: AboutURLs
    let truncatedAboutText: String
}
