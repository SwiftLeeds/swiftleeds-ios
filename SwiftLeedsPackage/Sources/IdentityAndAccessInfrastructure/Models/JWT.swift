struct JWT: Equatable, Hashable, Sendable {
    public var stringValue: String { rawValue }

    public var dataValue: Data { Data(self.rawValue.utf8) }

    private let rawValue: String

    #warning("Handle parsing in init, not `decodeJWTClaims()`")
    init?(_ stringValue: String) {
        guard stringValue.split(separator: ".").count == 3 else { return nil }
        self.rawValue = stringValue
    }
}

import Foundation

struct JWTClaims {
    let expiresAt: Date
}

func decodeJWTClaims(_ jwt: JWT) -> JWTClaims? {
    let segments = jwt.stringValue.split(separator: ".")
    guard segments.count == 3 else { return nil }
    var base64 = String(segments[1])
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    while base64.count % 4 != 0 {
        base64.append("=")
    }
    guard
        let data = Data(base64Encoded: base64),
        let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let exp = object["exp"] as? TimeInterval
    else {
        return nil
    }
    return JWTClaims(expiresAt: Date(timeIntervalSince1970: exp))
}
