import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// The conference an app is built for, which sets its brand color and tints its surfaces.
///
/// Views read the brand from the environment. An app sets it once at its root, and a preview or a
/// test sets it with `.environment(\.brand, .kotlinLeeds)`.
package enum Brand: CaseIterable, Equatable, Hashable, Sendable {
    /// A job a color does for a brand, named as the catalog names it.
    private enum Role {
        /// The color behind a screen.
        case surface
        /// The color behind grouped content on a screen.
        case secondarySurface
        /// The color behind content grouped inside grouped content.
        case tertiarySurface

        /// The name of the role's color set for elevated content, such as `elevatedSurface`.
        var elevatedName: String {
            let name = "\(self)"
            return "elevated" + name.prefix(1).uppercased() + name.dropFirst()
        }
    }

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

    /// The color behind a screen.
    ///
    /// It keeps the lightness of Apple's background and takes a faint hint of the brand hue.
    /// In a sheet on iOS, it lifts in dark mode as Apple's background does.
    package var surface: Color { color(for: .surface) }

    /// The color behind grouped content on a screen.
    ///
    /// It keeps the lightness of Apple's secondary background and takes a faint hint of the brand hue.
    /// In a sheet on iOS, it lifts in dark mode as Apple's secondary background does.
    package var secondarySurface: Color { color(for: .secondarySurface) }

    /// The color behind content grouped inside grouped content.
    ///
    /// It keeps the lightness of Apple's tertiary background and takes a faint hint of the brand hue.
    /// In a sheet on iOS, it lifts in dark mode as Apple's tertiary background does.
    package var tertiarySurface: Color { color(for: .tertiarySurface) }

    /// The name this brand's color sets start with in the catalog.
    private var catalogName: String {
        switch self {
        case .swiftLeeds: "swiftLeeds"
        case .kotlinLeeds: "kotlinLeeds"
        }
    }

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

    /// Returns the catalog color of this brand for a role.
    ///
    /// On iOS, the color lifts in an elevated container, such as a sheet. Elsewhere it does not.
    ///
    /// - Parameter role: The job the color does.
    /// - Returns: The color, named after the brand and the role.
    private func color(for role: Role) -> Color {
        let base = resource(named: "\(catalogName)-\(role)")
        #if canImport(UIKit)
        let elevated = resource(named: "\(catalogName)-\(role.elevatedName)")
        let provider = UIColor { traits in
            let chosen = traits.userInterfaceLevel == .elevated ? elevated : base
            return UIColor(resource: chosen).resolvedColor(with: traits)
        }
        return Color(provider)
        #else
        return Color(base)
        #endif
    }

    /// Returns a color set of this package's catalog.
    ///
    /// - Parameter name: The name of the color set.
    /// - Returns: The set as a resource.
    private func resource(named name: String) -> ColorResource {
        ColorResource(name: name, bundle: .module)
    }
}
