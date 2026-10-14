/// The code that identifies an HTTP response status.
public struct HTTPStatusCode: Equatable, Hashable, Sendable {
    /// The code.
    fileprivate let value: Int

    /// Creates a status code.
    /// - Parameter value: The three-digit code the server sent.
    public init(_ value: Int) {
        self.value = value
    }
}

extension HTTPStatusCode: Comparable {
    public static func < (lhs: HTTPStatusCode, rhs: HTTPStatusCode) -> Bool {
        lhs.value < rhs.value
    }
}

extension HTTPStatusCode: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Int {
    /// Creates an integer from a status code.
    /// - Parameter code: The code to convert.
    public init(_ code: HTTPStatusCode) {
        self = code.value
    }
}
