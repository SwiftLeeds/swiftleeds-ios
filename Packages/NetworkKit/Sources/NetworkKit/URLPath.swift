/// The path that locates a resource under a base URL.
public struct URLPath: Equatable, Hashable, Sendable {
    /// The path.
    fileprivate let value: String

    /// Creates a path.
    /// - Parameter value: The path, such as `api/v1/login/ticket`.
    public init(_ value: String) {
        self.value = value
    }
}

extension URLPath: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension String {
    /// Creates a string from a path.
    /// - Parameter path: The path to convert.
    public init(_ path: URLPath) {
        self = path.value
    }
}
