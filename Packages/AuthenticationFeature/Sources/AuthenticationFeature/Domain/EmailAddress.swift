public struct EmailAddress: Hashable, Sendable {
    private let storage: String

    /// Creates an email address from the given string.
    /// - Parameter value: The email address.
    /// - Throws: ``ParsingError/empty`` if `value` is empty.
    public init(_ value: String) throws(ParsingError) {
        guard !value.isEmpty else { throw .empty }
        self.storage = value
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
