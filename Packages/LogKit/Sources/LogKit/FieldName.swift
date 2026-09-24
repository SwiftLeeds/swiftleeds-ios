/// Which gap in an interpolated message a value came from.
///
/// Constructible only inside this package, so a caller cannot mint one and
/// shadow a gap.
public struct GapIndex: Hashable, Sendable {
    /// The gap's position in the message, counted from zero.
    package let value: Int

    /// Creates an index.
    package init(_ value: Int) {
        self.value = value
    }
}

/// The name of a single logged field, and where that name came from.
///
/// The two cases are kept apart deliberately. A gap's identity is assigned by
/// LogKit and a caller cannot construct one, so nothing a caller writes,
/// including a field injected by middleware, can shadow a gap and put the
/// wrong value into a message.
public enum FieldName: Hashable, Sendable, ExpressibleByStringLiteral {
    /// A name a developer wrote.
    case authored(String)

    /// A gap in an interpolated message. `label` names it for a destination
    /// that records fields separately; it is display only and plays no part
    /// in identity.
    case positional(GapIndex, label: String?)

    public init(stringLiteral value: String) {
        self = .authored(value)
    }

    public static func == (lhs: FieldName, rhs: FieldName) -> Bool {
        switch (lhs, rhs) {
        case let (.authored(left), .authored(right)):
            left == right
        case let (.positional(left, _), .positional(right, _)):
            left == right
        case (.authored, .positional):
            false
        case (.positional, .authored):
            false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .authored(value):
            hasher.combine(value)
        case let .positional(index, _):
            hasher.combine(index)
        }
    }
}

extension String {
    /// Creates a string holding the field's name.
    ///
    /// A gap with no label falls back to its position, which is why a label is
    /// worth giving to anything a structured destination will key on.
    ///
    /// - Parameter name: The field name to read the name from.
    public init(_ name: FieldName) {
        switch name {
        case let .authored(value):
            self = value
        case let .positional(index, label):
            self = label ?? String(index.value)
        }
    }
}
