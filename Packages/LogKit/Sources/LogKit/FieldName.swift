/// Which gap in an interpolated message a value came from.
///
/// Constructible only inside this package, so a caller cannot mint one and shadow a gap.
public struct GapIndex: Hashable, Sendable {
    package let value: Int

    package init(_ value: Int) {
        self.value = value
    }
}

/// The name of a single logged field, and where that name came from.
///
/// The two cases are kept apart deliberately. A gap's identity is assigned by LogKit and a caller
/// cannot construct one, so nothing a caller writes, including a field injected by middleware, can
/// shadow a gap and put the wrong value into a message.
public enum FieldName: Hashable, Sendable, ExpressibleByStringLiteral {
    /// A name a developer wrote.
    case authored(String)

    /// A gap in an interpolated message. `label` names it for a destination that records fields
    /// separately; it is display only and plays no part in identity.
    case positional(GapIndex, label: String?)

    public init(stringLiteral value: String) {
        self = .authored(value)
    }
}

extension String {
    /// The name as a destination should show it.
    ///
    /// A gap with no label falls back to its position, which is why a label is worth giving to
    /// anything a structured destination will key on.
    public init(_ name: FieldName) {
        switch name {
        case let .authored(value):
            self = value
        case let .positional(index, label):
            self = label ?? String(index.value)
        }
    }
}
