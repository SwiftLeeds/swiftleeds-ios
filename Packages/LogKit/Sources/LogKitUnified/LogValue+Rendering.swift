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
    /// Renders fields as `name=value` pairs, keeping the order they were written.
    var rendered: String {
        map { "\(String($0.name))=\($0.value.rendered)" }.joined(separator: " ")
    }
}
