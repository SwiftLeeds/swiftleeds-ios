import Foundation

struct JWT: Equatable, Hashable, Sendable {
    public var stringValue: String { rawValue }

    public var dataValue: Data { Data(self.rawValue.utf8) }

    private let rawValue: String

    #warning("Handle parsing in init, not `decodeJWTClaims()`")
    init?(_ stringValue: String) {
        self.rawValue = stringValue
    }
}
