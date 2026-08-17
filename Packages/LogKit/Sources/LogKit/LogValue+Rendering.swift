extension Sequence<LogField> {
    /// Renders every field except secrets as `name=value` pairs, in the order they were written.
    ///
    /// Hashed values are already tokenised by the time a destination receives them, so this joins
    /// what it is given without consulting a salt.
    ///
    /// `package` rather than `public`: it is a convenience for destinations we ship, not part of
    /// the contract a caller needs.
    package var renderedWithoutSecrets: String {
        filter { $0.sensitivity != .secret }
            .map { "\(String($0.name))=\($0.value.rendered)" }
            .joined(separator: " ")
    }

    /// Renders only the secret fields, for a destination trusted to redact them.
    ///
    /// Empty unless the destination was built with ``SecretPolicy/passThrough``.
    ///
    /// **Never make this `public`.** It returns secret values in plain text, so publishing it would
    /// hand every importer the leak this package exists to prevent.
    package var renderedSecrets: String {
        filter { $0.sensitivity == .secret }
            .map { "\(String($0.name))=\($0.value.rendered)" }
            .joined(separator: " ")
    }
}

extension LogValue {
    /// Flattens the value to text.
    ///
    /// Lives in core rather than in a destination because correlation tokens are digests of this
    /// exact form. If a destination flattened differently, the same value would hash two ways.
    ///
    /// Dictionary keys are sorted, so the same contents always produce the same text.
    ///
    /// `package` rather than `public` until something outside this package needs it.
    package var rendered: String {
        switch self {
        case let .string(value):
            value
        case let .integer(value):
            String(value)
        case let .double(value):
            String(value)
        case let .boolean(value):
            String(value)
        case let .array(values):
            "[" + values.map(\.rendered).joined(separator: ", ") + "]"
        case let .dictionary(values):
            "[" + values
                .map { (String($0.key), $0.value.rendered) }
                .sorted { $0.0 < $1.0 }
                .map { "\($0.0): \($0.1)" }
                .joined(separator: ", ") + "]"
        }
    }
}
