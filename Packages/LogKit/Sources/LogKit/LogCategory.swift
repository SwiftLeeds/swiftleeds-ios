/// The area of the app an event came from, used to filter and group logs.
public struct LogCategory: Hashable, Sendable, ExpressibleByStringLiteral {
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
    public init(_ category: LogCategory) {
        self = category.stringValue
    }
}
