/// The area of the app an event came from, used to filter and group logs.
///
/// Any string literal compiles, so a typo makes a second category rather than a compiler error.
/// Each module declares its own as statics on this type, in a file named `LogCategories.swift`,
/// and call sites use those instead of literals.
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
