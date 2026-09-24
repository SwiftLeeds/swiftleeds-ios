/// The literal skeleton of a message.
///
/// Leading text, then each gap and the literal text that follows it.
///
/// Deliberately holds no values. An event's interpolated values live in its
/// fields, where classification reaches them; if they were stored here a
/// destination could read a secret straight off the message.
public struct MessageTemplate: Hashable, Sendable, ExpressibleByStringLiteral {
    /// A gap in the message and the literal text that follows it.
    package struct Gap: Hashable, Sendable {
        /// The name the gap's value is filled from.
        package let placeholder: FieldName

        /// The literal text between this gap and the next one, or the end.
        package let trailingText: String

        /// Creates a gap.
        package init(placeholder: FieldName, trailingText: String) {
            self.placeholder = placeholder
            self.trailingText = trailingText
        }
    }

    /// The literal text before the first gap, or the whole message when there
    /// are no gaps.
    package let leadingText: String

    /// The gaps, in the order they were written.
    package let gaps: [Gap]

    /// Creates a template, holding no gaps unless some are given.
    ///
    /// - Parameters:
    ///   - leadingText: The literal text before the first gap.
    ///   - gaps: The gaps, in the order they were written.
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
    ///
    /// - Parameter fields: The fields to read gap values from.
    package func rendered(with fields: LogFields) -> String {
        gaps.reduce(into: leadingText) { text, gap in
            text += Self.text(for: gap.placeholder, in: fields)
            text += gap.trailingText
        }
    }

    /// Returns the text for one gap, or the redaction marker.
    ///
    /// A secret never reaches the sentence, whether or not its field survived
    /// classification. A destination trusted to hold secrets still receives
    /// the value, through whatever channel it redacts. The sentence is not
    /// that channel: `Log.unified` writes it as public.
    ///
    /// - Parameters:
    ///   - placeholder: The gap's name, matched against a field's name.
    ///   - fields: The fields to search.
    private static func text(for placeholder: FieldName, in fields: LogFields) -> String {
        guard let field = fields.first(where: { $0.name == placeholder }) else {
            return redactionMarker
        }

        return field.sensitivity == .secret ? redactionMarker : field.value.rendered
    }
}
