/// A media type from the IANA registry, written as type/subtype.
///
/// Any value is representable through `init(_:)`; the named constants cover
/// what the app sends.
package struct MediaType: Equatable, Hashable, Sendable {
    /// The registered subtypes of the application top-level type (RFC 6838).
    package struct Application: Sendable {
        package let json = MediaType("application/json")
    }

    fileprivate let value: String

    package init(_ value: String) {
        self.value = value
    }
}

// Subtypes hang off their top-level type, so a media type reads as the
// registry's own hierarchy: `.application.json`. A top-level type arrives
// with its first used subtype; the subtype registry is open-ended.
extension MediaType {
    package static let application = Application()
}

extension String {
    package init(_ mediaType: MediaType) {
        self = mediaType.value
    }
}
