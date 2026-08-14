import CryptoKit
import Foundation
import LogKit

/// A short, stable stand-in for a value that must not be readable.
///
/// The same value and salt always produce the same token, so occurrences can be
/// matched across log lines, and the value cannot be recovered from the token
/// without the salt. Computed per field rather than over a group, so one
/// value's token does not change when a neighbouring field does.
///
/// Salted because the values we log come from small spaces: a ticket reference
/// has under two million possibilities, and the attendee list is already known
/// to us, so an unsalted digest would be reversible by simply trying every
/// candidate.
struct CorrelationToken {
    /// How much of the digest to keep, in bytes.
    ///
    /// HMAC-SHA256 produces 32 bytes. Keeping 8 of them leaves 64 bits, where a
    /// coin-flip chance of any two values colliding needs roughly five billion
    /// distinct values (the birthday bound, about 2^32). We log nothing close
    /// to that, and a 16-character token keeps a log line readable where a
    /// 64-character one would not.
    private static let keptByteCount = 8

    private let storage: String

    /// Derives a token for `value`, keyed by `salt`.
    ///
    /// Uses HMAC rather than hashing the salt and value concatenated, because
    /// HMAC is the standard construction for keying a digest and is not
    /// susceptible to length-extension.
    init(_ value: String, salt: LogSalt) {
        let code = HMAC<SHA256>.authenticationCode(
            for: Data(value.utf8),
            using: SymmetricKey(data: Data(salt))
        )

        storage = code
            .prefix(Self.keptByteCount)
            .map(\.hexadecimalPair)
            .joined()
    }

    fileprivate var stringValue: String { storage }
}

extension String {
    init(_ token: CorrelationToken) {
        self = token.stringValue
    }
}

private extension UInt8 {
    /// The byte as exactly two lowercase hexadecimal digits.
    ///
    /// The zero padding is load-bearing, not cosmetic: without it `0x0a` would
    /// render as `a`, so tokens would vary in length and two different byte
    /// sequences could produce the same string.
    var hexadecimalPair: String {
        String(format: "%02x", self)
    }
}
