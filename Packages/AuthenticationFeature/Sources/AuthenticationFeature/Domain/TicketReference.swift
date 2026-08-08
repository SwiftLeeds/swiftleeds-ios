public struct TicketReference: Hashable, Sendable {
    public enum ParsingError: Error, Equatable {
        case invalidFormat
    }

    private let storage: String

    /// Creates a ticket reference from the given string, normalising it to the
    /// canonical `XXXX-#` form. The hyphen is optional in the input.
    /// - Parameter value: The ticket reference.
    /// - Throws: ``ParsingError/invalidFormat`` if `value` is not a valid ticket reference.
    public init(_ value: String) throws(ParsingError) {
        let canonical = value
            .wholeMatch(of: /([A-Z0-9]{4})-?([0-9]{1,2})/)
            .map { match in "\(match.output.1)-\(match.output.2)" }

        guard let canonical else { throw .invalidFormat }

        self.storage = canonical
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
