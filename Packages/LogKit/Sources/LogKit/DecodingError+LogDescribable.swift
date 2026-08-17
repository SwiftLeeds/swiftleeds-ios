import Foundation

/// `DecodingError` renders readably on macOS but reflects into a dump on iOS, so logs would
/// otherwise differ by platform. The debug description is dropped: it restates the case, and for a
/// corrupted body it can quote the bytes the server sent.
extension DecodingError: LogDescribable {
    public var logDescription: String {
        switch self {
        case let .keyNotFound(key, context):
            "keyNotFound \(Self.path(context, appending: key.stringValue))"
        case let .typeMismatch(type, context):
            "typeMismatch \(Self.path(context)) expected \(type)"
        case let .valueNotFound(type, context):
            "valueNotFound \(Self.path(context)) expected \(type)"
        case .dataCorrupted:
            "dataCorrupted"
        @unknown default:
            "\(self)"
        }
    }

    private static func path(_ context: Context, appending key: String? = nil) -> String {
        let components = context.codingPath.map(\.stringValue) + [key].compactMap { $0 }
        return components.isEmpty ? "(root)" : components.joined(separator: ".")
    }
}
