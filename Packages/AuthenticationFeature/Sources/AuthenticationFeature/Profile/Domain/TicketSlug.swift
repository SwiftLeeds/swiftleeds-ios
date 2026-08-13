import Foundation

/// An opaque identifier for a ticket, as issued by the ticketing provider.
public struct TicketSlug: Equatable, Hashable, Sendable {
    public enum ParsingError: Error, Equatable {
        case empty
    }

    private let storage: String

    /// Creates a ticket slug from the given string, trimming surrounding whitespace.
    /// - Parameter value: The identifier issued by the ticketing provider.
    /// - Throws: ``ParsingError/empty`` if `value` is empty once trimmed.
    public init(_ value: String) throws(ParsingError) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw .empty }
        self.storage = trimmed
    }

    fileprivate var stringValue: String { storage }
}

extension String {
    /// Creates a string from a ticket slug.
    /// - Parameter ticketSlug: The ticket slug to convert.
    public init(_ ticketSlug: TicketSlug) {
        self = ticketSlug.stringValue
    }
}
