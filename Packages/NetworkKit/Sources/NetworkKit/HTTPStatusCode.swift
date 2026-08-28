/// The code that identifies an HTTP response status.
public struct HTTPStatusCode: Equatable, Hashable, Sendable {
    fileprivate let value: Int

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
    public init(_ code: HTTPStatusCode) {
        self = code.value
    }
}
