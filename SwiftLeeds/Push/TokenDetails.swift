import Foundation

struct TokenDetails: Encodable {
    let token: String
    var debug: Bool = false

    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }
}

extension TokenDetails {
    init(token: Data) {
        self.token = token.reduce("") { $0 + String(format: "%02x", $1) }
    }
}

extension TokenDetails: CustomStringConvertible {
    var description: String {
        do {
            let data = try Self.encoder.encode(self)
            return String(data: data, encoding: .utf8) ?? "Invalid token"
        } catch {
            return "Invalid token"
        }
    }
}
