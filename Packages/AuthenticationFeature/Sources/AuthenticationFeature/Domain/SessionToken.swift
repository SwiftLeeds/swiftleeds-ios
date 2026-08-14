package struct SessionToken: Equatable, Hashable, Sendable {
    private let storage: String

    package init(_ value: String) {
        self.storage = value
    }

    fileprivate var stringValue: String { storage }
}

extension String {
    package init(_ token: SessionToken) {
        self = token.stringValue
    }
}

// Redacted so the JWT can't leak via logs, interpolation, or reflection.
extension SessionToken: CustomStringConvertible, CustomDebugStringConvertible {
    package var description: String { "•••" }
    package var debugDescription: String { description }
}
