import Foundation

public struct EmailAddress: Hashable, Sendable {
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

    public enum ParsingError: Error, Equatable {
        case empty
    }
}

extension String {
    /// Creates a string from an email address.
    /// - Parameter email: The email address to convert.
    public init(_ email: EmailAddress) {
        self = email.stringValue
    }
}
