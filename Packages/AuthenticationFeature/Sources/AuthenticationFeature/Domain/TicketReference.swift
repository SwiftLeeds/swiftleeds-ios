import Foundation

public struct TicketReference: Hashable, Sendable {
    public enum ParsingError: Error, Equatable {
        case invalidFormat
    }

    private let storage: String

    /// Creates a ticket reference from the given string, normalising it to the
    /// canonical `XXXX-#` form. Surrounding whitespace is trimmed, the hyphen is
    /// optional, and the input is case-insensitive.
    /// - Parameter value: The ticket reference.
    /// - Throws: ``ParsingError/invalidFormat`` if `value` is not a valid ticket reference.
    public init(_ value: String) throws(ParsingError) {
        self.storage = try value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .wholeMatch(of: /([A-Z0-9]{4})-?([0-9]{1,2})/)
            .map { match in "\(match.output.1)-\(match.output.2)" }
            .unwrap(orThrow: ParsingError.invalidFormat)
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

// Redacted so the reference can't leak via logs, interpolation, or reflection.
extension TicketReference: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { "•••" }
    public var debugDescription: String { description }
}
