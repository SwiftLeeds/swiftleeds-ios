import Foundation

/// Mixed into hashed values so their tokens cannot be reversed by guessing.
///
/// Required rather than defaulted, because the lifetime is a decision: a salt generated per run
/// correlates within one launch, a stored salt correlates across launches on one device.
public struct LogSalt: Hashable, Sendable {
    private let storage: Data

    public init(_ value: Data) {
        self.storage = value
    }

    public static func random(byteCount: Int = 16) -> LogSalt {
        var generator = SystemRandomNumberGenerator()
        let bytes = (0..<byteCount).map { _ in UInt8.random(in: .min ... .max, using: &generator) }
        return LogSalt(Data(bytes))
    }

    fileprivate var dataValue: Data { storage }
}

extension Data {
    public init(_ salt: LogSalt) {
        self = salt.dataValue
    }
}
