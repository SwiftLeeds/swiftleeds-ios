import CryptoKit
import Foundation

/// A short, stable stand-in for a value that must not be readable.
///
/// The same value and salt always produce the same token, so occurrences can
/// be matched across log lines. Computed per field, so one value's token does
/// not change when a neighboring field does.
///
/// Salted because the values we log come from small spaces: an unsalted digest
/// of a ticket reference would be reversible by trying every candidate.
struct CorrelationToken {
    /// Bytes of the digest to keep. 64 bits is far more than the volume we log
    /// needs, and keeps a token readable at 16 characters.
    private static let keptByteCount = 8

    /// The token, as lowercase hexadecimal digits.
    private let storage: String

    /// Creates a token standing in for the given value.
    ///
    /// Keyed with HMAC rather than hashing salt and value concatenated, which
    /// would be open to length-extension.
    ///
    /// - Parameters:
    ///   - value: The text to stand in for.
    ///   - salt: Mixed in so the token cannot be reversed by guessing.
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

    /// The token, as lowercase hexadecimal digits.
    fileprivate var stringValue: String { storage }
}

extension String {
    /// Creates a string holding the token's digits.
    ///
    /// - Parameter token: The token to read the digits from.
    init(_ token: CorrelationToken) {
        self = token.stringValue
    }
}

private extension UInt8 {
    /// The byte as exactly two lowercase hexadecimal digits.
    ///
    /// The zero padding is load-bearing: without it `0x0a` renders as `a`, so
    /// two different byte sequences could produce the same string.
    var hexadecimalPair: String {
        String(format: "%02x", self)
    }
}
