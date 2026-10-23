import Foundation

/// The token the backend issues when an attendee signs in.
package struct SessionToken: Equatable, Hashable, Sendable {
    /// The reason a string cannot become a session token.
    package enum ParsingError: Error, Equatable {
        /// An empty string, or one of only whitespace.
        case empty
    }

    /// The token, trimmed.
    fileprivate let storage: String

    /// Creates a session token, trimming surrounding whitespace.
    /// - Parameter value: The token text.
    /// - Throws: ``ParsingError/empty`` if `value` is blank once trimmed.
    package init(_ value: String) throws(ParsingError) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw .empty }
        storage = trimmed
    }
}

extension String {
    /// Creates a string from a session token.
    /// - Parameter token: The session token to convert.
    package init(_ token: SessionToken) {
        self = token.storage
    }
}
