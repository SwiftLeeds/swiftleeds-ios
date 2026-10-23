import Foundation

/// The code that identifies an attendee's ticket, in `XXXX-#` form.
public struct TicketReference: Equatable, Hashable, Sendable {
    /// The reason a string cannot become a ticket reference.
    public enum ParsingError: Error, Equatable {
        /// A string that is not four letters or digits, then one or two digits.
        case invalidFormat
    }

    /// The reference, in `XXXX-#` form.
    fileprivate let storage: String

    /// Creates a ticket reference, normalizing it to the `XXXX-#` form.
    ///
    /// Surrounding whitespace is trimmed, the hyphen is optional, and the input
    /// is case-insensitive.
    /// - Parameter value: The ticket reference.
    /// - Throws: ``ParsingError/invalidFormat`` if `value` is not a valid
    ///   ticket reference.
    public init(_ value: String) throws(ParsingError) {
        self.storage =
            try value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .wholeMatch(of: /([A-Z0-9]{4})-?([0-9]{1,2})/)
            .map { match in "\(match.output.1)-\(match.output.2)" }
            .unwrap(orThrow: ParsingError.invalidFormat)
    }
}

extension String {
    /// Creates a string from a ticket reference.
    /// - Parameter ticketReference: The ticket reference to convert.
    public init(_ ticketReference: TicketReference) {
        self = ticketReference.storage
    }
}
