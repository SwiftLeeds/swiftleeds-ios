/// A media type from the IANA registry, written as type/subtype.
///
/// Any value is representable through `init(_:)`; the named constants cover
/// what the app sends.
public struct MediaType: Equatable, Hashable, Sendable {
    /// The subtypes of the application top-level type (RFC 6838) that the app uses.
    public struct Application: Sendable {
        public let json = MediaType("application/json")
    }

    fileprivate let value: String

    public init(_ value: String) {
        self.value = value
    }
}

// A top-level type arrives with its first used subtype; the subtype
// registry is open-ended.
extension MediaType {
    public static let application = Application()
}

extension String {
    public init(_ mediaType: MediaType) {
        self = mediaType.value
    }
}
