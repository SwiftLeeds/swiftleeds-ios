/// The code that identifies an HTTP response status.
package struct HTTPStatusCode: Equatable, Hashable, Sendable {
    fileprivate let value: Int

    package init(_ value: Int) {
        self.value = value
    }
}

extension HTTPStatusCode: Comparable {
    package static func < (lhs: HTTPStatusCode, rhs: HTTPStatusCode) -> Bool {
        lhs.value < rhs.value
    }
}

extension HTTPStatusCode: ExpressibleByIntegerLiteral {
    package init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Int {
    package init(_ code: HTTPStatusCode) {
        self = code.value
    }
}
