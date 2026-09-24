/// A logged value, kept typed so a structured destination can preserve numbers
/// as numbers rather than flattening everything to text.
public enum LogValue: Hashable, Sendable {
    /// Text.
    case string(String)
    /// A whole number.
    case integer(Int)
    /// A number with a fractional part.
    case double(Double)
    /// A true or false value.
    case boolean(Bool)
    /// An ordered list of values, which may themselves be lists.
    case array([LogValue])
    /// Values kept under field names, nested inside one field.
    case dictionary([FieldName: LogValue])
}

extension LogValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension LogValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .integer(value)
    }
}

extension LogValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension LogValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }
}
