/// The conference an app is built for, which sets its brand color and tints its surfaces.
///
/// Views read the brand from the environment. An app sets it once at its root, and a preview or a
/// test sets it with `.environment(\.brand, .kotlinLeeds)`.
package enum Brand: CaseIterable, Equatable, Hashable, Sendable {
    /// The reason a declaration is not a brand.
    package enum ParsingError: Error, Equatable {
        /// The text names no brand. It holds the rejected text.
        case unknownBrand(String)
    }

    /// The SwiftLeeds conference, a bright orange.
    case swiftLeeds

    /// The KotlinLeeds conference, a purple.
    case kotlinLeeds

    /// Creates the brand an app declares.
    ///
    /// The text must match exactly: "SwiftLeeds" or "KotlinLeeds", with that case and no spaces.
    ///
    /// - Parameter declaration: The brand name the app declares in its Info.plist.
    /// - Throws: ``ParsingError/unknownBrand(_:)`` when `declaration` names no brand.
    package init(_ declaration: String) throws(ParsingError) {
        switch declaration {
        case "SwiftLeeds":
            self = .swiftLeeds

        case "KotlinLeeds":
            self = .kotlinLeeds

        default:
            throw .unknownBrand(declaration)
        }
    }
}
