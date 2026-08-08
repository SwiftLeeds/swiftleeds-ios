public struct TicketReference: Hashable, Sendable {
    public enum ParsingError: Error, Equatable {
        case invalidFormat
    }

    private let storage: String

    /// Creates a ticket reference from the given string.
    /// - Parameter value: The ticket reference.
    /// - Throws: ``ParsingError/invalidFormat`` if `value` is not a valid ticket reference.
    public init(_ value: String) throws(ParsingError) {
        guard value.wholeMatch(of: /[A-Z0-9]{4}-[0-9]{1,2}/) != nil else {
            throw .invalidFormat
        }
        self.storage = value
    }

    fileprivate var stringValue: String { storage }
}

extension String {
    /// Creates a string from a ticket reference.
    /// - Parameter ticketReference: The ticket reference to convert.
    public init(_ ticketReference: TicketReference) {
        self = ticketReference.stringValue
    }
}
