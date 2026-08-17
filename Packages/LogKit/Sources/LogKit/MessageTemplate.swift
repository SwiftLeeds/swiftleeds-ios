/// The literal skeleton of a message: text, then each gap and the text following it.
///
/// Deliberately holds no values. An event's interpolated values live in its fields, where
/// classification reaches them; if they were stored here a destination could read a secret straight
/// off the message.
public struct MessageTemplate: Hashable, Sendable, ExpressibleByStringLiteral {
    /// A gap in the message and the literal text that follows it.
    package struct Gap: Hashable, Sendable {
        package let placeholder: FieldName
        package let trailingText: String

        package init(placeholder: FieldName, trailingText: String) {
            self.placeholder = placeholder
            self.trailingText = trailingText
        }
    }

    package let leadingText: String
    package let gaps: [Gap]

    package init(leadingText: String, gaps: [Gap] = []) {
        self.leadingText = leadingText
        self.gaps = gaps
    }

    public init(stringLiteral value: String) {
        self.init(leadingText: value)
    }
}

extension MessageTemplate {
    /// Stands in for a value the destination was not trusted to see.
    package static let redactionMarker = "<redacted>"

    /// Fills each gap with the matching field's value, in the order they were written.
    ///
    /// A gap whose field is absent renders as ``redactionMarker``. That is the normal outcome for a
    /// secret: classification removes it before the destination is handed the event.
    package func rendered(with fields: LogFields) -> String {
        let valuesByName = Dictionary(
            fields.map { ($0.name, $0.value.rendered) },
            uniquingKeysWith: { first, _ in first }
        )

        return gaps.reduce(into: leadingText) { text, gap in
            text += valuesByName[gap.placeholder] ?? Self.redactionMarker
            text += gap.trailingText
        }
    }
}
