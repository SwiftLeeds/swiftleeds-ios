/// The name of a single logged field.
public struct FieldName: Hashable, Sendable, ExpressibleByStringLiteral {
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
    public init(_ name: FieldName) {
        self = name.stringValue
    }
}
