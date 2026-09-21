import Foundation

// Payloads shaped like the real `api/v2/team` response.
enum TeamJSON {
    static func team(_ members: String...) -> Data {
        Data("{\"teamMembers\":[\(members.joined(separator: ","))]}".utf8)
    }

    static func member(
        name: String = "Adam Rush",
        slack: String = "https://swiftleeds.slack.com/rush",
        imageURL: String = "/img/team/rush.jpg"
    ) -> String {
        """
        {
          "name": "\(name)",
          "role": "Founder and Host",
          "twitter": null,
          "linkedin": null,
          "slack": "\(slack)",
          "imageURL": "\(imageURL)",
          "core": true
        }
        """
    }
}
