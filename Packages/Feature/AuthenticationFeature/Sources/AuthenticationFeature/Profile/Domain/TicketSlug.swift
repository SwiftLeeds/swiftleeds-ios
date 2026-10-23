import Foundation

/// An opaque identifier for a ticket, as issued by the ticketing provider.
public struct TicketSlug: Equatable, Hashable, Sendable {
    /// The reason a string cannot become a ticket slug.
    public enum ParsingError: Error, Equatable {
        /// An empty string, or one of only whitespace.
        case empty
    }

    /// The identifier, trimmed.
    fileprivate let storage: String

    /// Creates a ticket slug, trimming surrounding whitespace.
    /// - Parameter value: The identifier issued by the ticketing provider.
    /// - Throws: ``ParsingError/empty`` if `value` is empty once trimmed.
    public init(_ value: String) throws(ParsingError) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw .empty }
        self.storage = trimmed
    }
}

extension String {
    /// Creates a string from a ticket slug.
    /// - Parameter ticketSlug: The ticket slug to convert.
    public init(_ ticketSlug: TicketSlug) {
        self = ticketSlug.storage
    }
}
