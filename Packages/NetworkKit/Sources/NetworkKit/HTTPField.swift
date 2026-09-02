import Foundation

/// One HTTP field: the name and value pair RFC 9110 section 5 calls a field.
///
/// The same field syntax carries a request's headers and a response's, so this
/// type is not tied to either.
public struct HTTPField: Equatable, Hashable, Sendable {
    /// The label that identifies a field's meaning.
    ///
    /// Two names that differ only by case are the same name, per RFC 9110
    /// section 5.1. Extraction keeps the casing the caller gave.
    public struct Name: Equatable, Hashable, Sendable {
        fileprivate let value: String

        public init(_ value: String) {
            self.value = value
        }

        public static func == (lhs: Name, rhs: Name) -> Bool {
            lhs.value.lowercased() == rhs.value.lowercased()
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(value.lowercased())
        }
    }

    /// The data carried under a field name, sent exactly as given.
    public struct Value: Equatable, Hashable, Sendable {
        fileprivate let value: String

        public init(_ value: String) {
            self.value = value
        }
    }

    private let name: Name
    private let value: Value

    init(name: Name, value: Value) {
        self.name = name
        self.value = value
    }

    /// Writes the field onto the request, replacing any field of the same name.
    func attach(to request: inout URLRequest) {
        request.setValue(String(value), forHTTPHeaderField: String(name))
    }
}

// Named for the fields the app sends. Any other name arrives through `init(_:)`.
extension HTTPField.Name {
    public static let accept = HTTPField.Name("Accept")
}

extension HTTPField.Value: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension String {
    public init(_ name: HTTPField.Name) {
        self = name.value
    }

    public init(_ value: HTTPField.Value) {
        self = value.value
    }
}
