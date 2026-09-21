import Foundation

// Payloads shaped like the real `api/v2/team` response. The backend leaves out a key whose
// value is nil, so an absent value is a missing key, never `null`.
enum TeamJSON {
    static func team(_ members: String...) -> Data {
        Data("{\"teamMembers\":[\(members.joined(separator: ","))]}".utf8)
    }

    static func member(
        name: String = "Adam Rush",
        role: String? = "Founder and Host",
        linkedin: String? = nil,
        twitter: String? = nil,
        slack: String? = "https://swiftleeds.slack.com/rush",
        imageURL: String = "/img/team/rush.jpg"
    ) -> String {
        let fields: [(key: String, value: String?)] = [
            ("name", name),
            ("role", role),
            ("twitter", twitter),
            ("linkedin", linkedin),
            ("slack", slack),
            ("imageURL", imageURL),
        ]
        let present = fields.compactMap { field in field.value.map { "\"\(field.key)\": \"\($0)\"" } }
        return "{\(present.joined(separator: ", ")), \"core\": true}"
    }
}
