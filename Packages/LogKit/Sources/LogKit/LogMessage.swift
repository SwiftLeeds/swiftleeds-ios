/// A message as it was written at the call site.
///
/// Built only from a string literal or an interpolation, so its literal text always comes from
/// source. There is deliberately no initialiser taking a runtime `String`: that is the single door
/// keeping data out of the message itself. Interpolated values do not stay here, they become
/// fields, where classification reaches them.
public struct LogMessage: Sendable, ExpressibleByStringInterpolation {
    package let template: MessageTemplate
    package let values: LogFields

    public init(stringLiteral value: String) {
        template = MessageTemplate(leadingText: value)
        values = LogFields()
    }

    public init(stringInterpolation: Interpolation) {
        template = MessageTemplate(
            leadingText: stringInterpolation.leadingText,
            gaps: stringInterpolation.gaps
        )
        values = LogFields(stringInterpolation.values)
    }
}

extension LogMessage {
    /// Collects the literal text and the interpolated values as the compiler walks the message.
    public struct Interpolation: StringInterpolationProtocol {
        public typealias StringLiteralType = String

        package var leadingText = ""
        package var gaps: [MessageTemplate.Gap] = []
        package var values: [LogField] = []

        public init(literalCapacity: Int, interpolationCount: Int) {
            gaps.reserveCapacity(interpolationCount)
            values.reserveCapacity(interpolationCount)
        }

        public mutating func appendLiteral(_ literal: String) {
            guard let last = gaps.indices.last else {
                leadingText += literal
                return
            }

            gaps[last] = MessageTemplate.Gap(
                placeholder: gaps[last].placeholder,
                trailingText: gaps[last].trailingText + literal
            )
        }

        /// Records an interpolated value.
        ///
        /// - Parameters:
        ///   - value: The value to log.
        ///   - name: What a destination recording fields separately should call it. Display only:
        ///     the gap's identity is its position, so two values sharing a name stay distinct.
        ///   - privacy: How freely the value may travel. Deliberately has no default, so a value
        ///     cannot be published by forgetting to classify it.
        public mutating func appendInterpolation(
            _ value: some LogValueRepresentable,
            name: String? = nil,
            privacy: Sensitivity
        ) {
            append(value, name: name, privacy: privacy)
        }

        /// Records an interpolated error, described by ``LogDescribable`` where it conforms.
        ///
        /// A separate overload because `any Error` cannot conform to `LogValueRepresentable`.
        public mutating func appendInterpolation(
            _ error: any Error,
            name: String? = nil,
            privacy: Sensitivity
        ) {
            append(String(logDescribing: error), name: name, privacy: privacy)
        }

        private mutating func append(
            _ value: some LogValueRepresentable,
            name: String?,
            privacy: Sensitivity
        ) {
            let placeholder = FieldName.positional(GapIndex(gaps.count), label: name)

            gaps.append(MessageTemplate.Gap(placeholder: placeholder, trailingText: ""))
            values.append(LogField(placeholder, value, privacy))
        }
    }
}
