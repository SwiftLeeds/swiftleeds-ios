import Foundation

public struct EmailAddress: Hashable, Sendable {
    public enum ParsingError: Error, Equatable {
        case empty
    }

    private let storage: String

    /// Creates an email address from the given string, trimming surrounding whitespace.
    /// - Parameter value: The email address.
    /// - Throws: ``ParsingError/empty`` if `value` is empty once trimmed.
    public init(_ value: String) throws(ParsingError) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw .empty }
        self.storage = trimmed
    }

    fileprivate var stringValue: String { storage }
}

extension String {
    /// Creates a string from an email address.
    /// - Parameter email: The email address to convert.
    public init(_ email: EmailAddress) {
        self = email.stringValue
    }
}

// Redacted so the address can't leak via logs, interpolation, or reflection.
extension EmailAddress: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { "•••" }
    public var debugDescription: String { description }
}
