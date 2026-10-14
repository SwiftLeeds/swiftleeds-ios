import Foundation

package struct SessionToken: Equatable, Hashable, Sendable {
    package enum ParsingError: Error, Equatable {
        case empty
    }

    /// The token, trimmed.
    fileprivate let storage: String

    /// Creates a session token, trimming surrounding whitespace.
    /// - Throws: ``ParsingError/empty`` if `value` is blank once trimmed.
    package init(_ value: String) throws(ParsingError) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw .empty }
        storage = trimmed
    }
}

extension String {
    package init(_ token: SessionToken) {
        self = token.storage
    }
}
