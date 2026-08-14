package struct AttendeeName: Equatable, Hashable, Sendable {
    private let storage: String

    package init(_ value: String) {
        self.storage = value
    }

    fileprivate var stringValue: String { storage }
}

extension String {
    package init(_ name: AttendeeName) {
        self = name.stringValue
    }
}

// Redacted so the attendee's name can't leak via logs or string interpolation.
extension AttendeeName: CustomStringConvertible, CustomDebugStringConvertible {
    package var description: String { "•••" }
    package var debugDescription: String { description }
}
