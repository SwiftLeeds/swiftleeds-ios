import Foundation

struct CachedSession: Codable {
    let token: String
}

extension CachedSession {
    init(_ session: Session) {
        self.init(token: String(session.token))
    }

    var session: Session {
        Session(token: SessionToken(token))
    }
}
