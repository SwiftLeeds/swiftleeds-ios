/// A media type from the IANA registry, written as type/subtype.
///
/// Any value is representable through `init(_:)`; the named constants cover
/// what the app sends.
public struct MediaType: Equatable, Hashable, Sendable {
    /// The application top-level type's subtypes the app uses (RFC 6838).
    public struct Application: Sendable {
        /// JSON, as `application/json`.
        public let json = MediaType("application/json")
    }

    /// The type and subtype.
    fileprivate let value: String

    /// Creates a media type.
    /// - Parameter value: The type and subtype, as `type/subtype`.
    public init(_ value: String) {
        self.value = value
    }
}

extension MediaType {
    /// The application subtypes the app sends.
    public static let application = Application()
}

extension String {
    /// Creates a string from a media type.
    /// - Parameter mediaType: The media type to convert.
    public init(_ mediaType: MediaType) {
        self = mediaType.value
    }
}
