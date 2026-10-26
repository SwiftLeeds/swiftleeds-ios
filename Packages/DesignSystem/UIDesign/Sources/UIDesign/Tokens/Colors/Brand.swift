/// The conference an app is built for, which sets its brand color and tints its surfaces.
///
/// Views read the brand from the environment. An app sets it once at its root, and a preview or a
/// test sets it with `.environment(\.brand, .kotlinLeeds)`.
package enum Brand: CaseIterable, Equatable, Hashable, Sendable {
    /// The reason a declaration is not a brand.
    package enum ParsingError: Error, Equatable {
        /// The text names no brand. It holds the rejected text.
        case unknownBrand(String)

        /// The entry is not text. It holds a description of the rejected value.
        case notText(String)
    }

    /// The SwiftLeeds conference, a bright orange.
    case swiftLeeds

    /// The KotlinLeeds conference, a purple.
    case kotlinLeeds

    /// The Info.plist key an app declares its brand under.
    package static let infoDictionaryKey = "Brand"

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

    /// Creates the brand an app declares in its Info.plist.
    ///
    /// A dictionary with no brand entry returns ``swiftLeeds``.
    ///
    /// - Parameter infoDictionary: The Info.plist entries, such as `Bundle.infoDictionary`.
    /// - Throws: ``ParsingError/unknownBrand(_:)`` when the entry is text that names no brand.
    ///   ``ParsingError/notText(_:)`` when the entry is not text.
    package init(infoDictionary: [String: Any]) throws(ParsingError) {
        guard let declaration = infoDictionary[Self.infoDictionaryKey] else {
            self = .swiftLeeds
            return
        }
        guard let text = declaration as? String else {
            throw .notText(String(describing: declaration))
        }
        try self.init(text)
    }
}
