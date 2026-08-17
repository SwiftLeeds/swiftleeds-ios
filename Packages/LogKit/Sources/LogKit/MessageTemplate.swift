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

    /// Fills each gap from its own field, in the order they were written.
    package func rendered(with fields: LogFields) -> String {
        gaps.reduce(into: leadingText) { text, gap in
            text += Self.text(for: gap.placeholder, in: fields)
            text += gap.trailingText
        }
    }

    /// A secret never reaches the sentence, whether or not its field survived classification.
    ///
    /// A destination trusted to hold secrets still receives the value, through whatever channel it
    /// redacts. The sentence is not that channel: `Log.unified` writes it as public.
    private static func text(for placeholder: FieldName, in fields: LogFields) -> String {
        guard let field = fields.first(where: { $0.name == placeholder }) else {
            return redactionMarker
        }

        return field.sensitivity == .secret ? redactionMarker : field.value.rendered
    }
}
