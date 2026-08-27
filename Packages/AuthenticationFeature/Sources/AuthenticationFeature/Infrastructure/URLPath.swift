/// The path that locates a resource under a base URL.
package struct URLPath: Equatable, Hashable, Sendable {
    fileprivate let value: String

    package init(_ value: String) {
        self.value = value
    }
}

extension URLPath: ExpressibleByStringLiteral {
    package init(stringLiteral value: String) {
        self.init(value)
    }
}

extension String {
    package init(_ path: URLPath) {
        self = path.value
    }
}
