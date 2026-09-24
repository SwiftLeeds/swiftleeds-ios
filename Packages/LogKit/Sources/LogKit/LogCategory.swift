/// The area of the app an event came from, used to filter and group logs.
///
/// Any string literal compiles, so a typo makes a second category rather than
/// a compiler error. Each module declares its own as statics on this type, in
/// a file named `LogCategories.swift`, and call sites use those instead of
/// literals.
public struct LogCategory: Hashable, Sendable, ExpressibleByStringLiteral {
    /// The name.
    private let storage: String

    /// Creates a category.
    ///
    /// - Parameter value: The name.
    public init(_ value: String) {
        self.storage = value
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    /// The name.
    fileprivate var stringValue: String { storage }
}

extension String {
    /// Creates a string holding the category's name.
    ///
    /// - Parameter category: The category to read the name from.
    public init(_ category: LogCategory) {
        self = category.stringValue
    }
}
