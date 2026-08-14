import LogKit

extension LogValue {
    /// Flattens a value for a destination that can only carry text.
    var rendered: String {
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

extension Sequence<LogField> {
    /// Renders fields as `name=value` pairs in the order they were written,
    /// replacing hashed values with their correlation token.
    ///
    /// Secrets are excluded: they are rendered separately so unified logging
    /// can redact them.
    func rendered(salt: LogSalt) -> String {
        compactMap { field in
            switch field.sensitivity {
            case .open:
                "\(String(field.name))=\(field.value.rendered)"
            case .hashed:
                "\(String(field.name))=\(String(CorrelationToken(field.value.rendered, salt: salt)))"
            case .secret:
                nil
            }
        }
        .joined(separator: " ")
    }

    /// Renders only the secret values, for an interpolation the system redacts.
    var renderedSecrets: String {
        filter { $0.sensitivity == .secret }
            .map { "\(String($0.name))=\($0.value.rendered)" }
            .joined(separator: " ")
    }
}
