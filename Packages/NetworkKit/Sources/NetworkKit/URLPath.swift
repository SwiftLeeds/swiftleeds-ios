/// The path that locates a resource under a base URL.
public struct URLPath: Equatable, Hashable, Sendable {
    fileprivate let value: String

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
    public init(_ path: URLPath) {
        self = path.value
    }
}
