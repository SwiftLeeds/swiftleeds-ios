/// The fixed part of a logged event.
///
/// Backed by `StaticString` so it can never carry interpolated data. That keeps
/// messages searchable, and lets a destination treat them as safe to show in full.
public struct LogMessage: Hashable, Sendable, ExpressibleByStringLiteral {
    public typealias StringLiteralType = StaticString

    private let storage: StaticString

    public init(_ value: StaticString) {
        self.storage = value
    }

    public init(stringLiteral value: StaticString) {
        self.init(value)
    }

    public static func == (lhs: LogMessage, rhs: LogMessage) -> Bool {
        lhs.storage.description == rhs.storage.description
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage.description)
    }

    fileprivate var staticValue: StaticString { storage }
}

extension LogMessage {
    /// The template an event stores for this message.
    package var template: MessageTemplate {
        MessageTemplate(leadingText: storage.description)
    }
}

extension StaticString {
    public init(_ message: LogMessage) {
        self = message.staticValue
    }
}

extension String {
    public init(_ message: LogMessage) {
        self = message.staticValue.description
    }
}
