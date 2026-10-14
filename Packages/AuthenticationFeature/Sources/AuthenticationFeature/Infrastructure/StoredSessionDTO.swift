import Foundation

struct StoredSessionDTO: Codable {
    let token: String
}

extension StoredSessionDTO {
    init(_ session: Session) {
        self.init(token: String(session.token))
    }

    /// The stored session, or `nil` if what was stored is no longer valid.
    var session: Session? {
        guard let token = try? SessionToken(token) else { return nil }
        return Session(token: token)
    }
}
