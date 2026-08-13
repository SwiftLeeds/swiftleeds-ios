/// Identifies the app a log came from, conventionally its bundle identifier.
///
/// Injected rather than defaulted: this project ships as more than one app.
public struct LogSubsystem: Hashable, Sendable, ExpressibleByStringLiteral {
    private let storage: String

    public init(_ value: String) {
        self.storage = value
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    fileprivate var stringValue: String { storage }
}

extension String {
    public init(_ subsystem: LogSubsystem) {
        self = subsystem.stringValue
    }
}
