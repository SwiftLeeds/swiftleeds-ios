import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// The conference an app is built for, which sets its brand color and tints its surfaces.
///
/// Views read the brand from the environment. An app sets it once at its root, and a preview or a
/// test sets it with `.environment(\.brand, .kotlinLeeds)`.
public enum Brand: CaseIterable, Equatable, Hashable, Sendable {
    /// A job a color does for a brand, named as the catalog names it.
    private enum Role {
        /// The color for the main background of an interface.
        case surface
        /// The color for content layered on top of the main background.
        case secondarySurface
        /// The color for content layered on top of secondary backgrounds.
        case tertiarySurface
        /// The color for the main background of a grouped interface.
        case groupedSurface
        /// The color for text or a symbol on a surface.
        case text
        /// The color for a filled shape behind `onSolid`.
        case solid
        /// The color for text or a symbol on `solid`.
        case onSolid
        /// The color for a pale fill behind `text`.
        case subtle

        /// The name of the role's color set for elevated content, such as `elevatedSurface`.
        ///
        /// It is `nil` for a role with no elevated set, which is every role but a surface.
        var elevatedName: String? {
            switch self {
            case .surface: elevatedPrefixedName
            case .secondarySurface: elevatedPrefixedName
            case .tertiarySurface: elevatedPrefixedName
            case .groupedSurface: elevatedPrefixedName
            case .text: nil
            case .solid: nil
            case .onSolid: nil
            case .subtle: nil
            }
        }

        /// The role's name with `elevated` in front, such as `elevatedSurface`.
        private var elevatedPrefixedName: String {
            let name = "\(self)"
            return "elevated" + name.prefix(1).uppercased() + name.dropFirst()
        }
    }

    /// The reason a declaration is not a brand.
    public enum ParsingError: Error, Equatable {
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

    /// The color for the main background of an interface.
    ///
    /// It keeps the lightness of Apple's background and takes a faint hint of the brand hue.
    /// In a sheet on iOS, it lifts in dark mode as Apple's background does.
    package var surface: Color { color(for: .surface) }

    /// The color for content layered on top of the main background.
    ///
    /// It keeps the lightness of Apple's secondary background and takes a faint hint of the brand hue.
    /// In a sheet on iOS, it lifts in dark mode as Apple's secondary background does.
    package var secondarySurface: Color { color(for: .secondarySurface) }

    /// The color for content layered on top of secondary backgrounds.
    ///
    /// It keeps the lightness of Apple's tertiary background and takes a faint hint of the brand hue.
    /// In a sheet on iOS, it lifts in dark mode as Apple's tertiary background does.
    package var tertiarySurface: Color { color(for: .tertiarySurface) }

    /// The color for the main background of a grouped interface.
    ///
    /// It keeps the lightness of Apple's grouped background and takes a faint hint of the brand hue.
    /// In a sheet on iOS, it lifts in dark mode as Apple's grouped background does.
    package var groupedSurface: Color { color(for: .groupedSurface) }

    /// The color for text or a symbol on a surface, such as a link or a section title.
    ///
    /// It reaches 4.5:1 against ``surface`` and ``secondarySurface``, and against ``subtle``.
    package var text: Color { color(for: .text) }

    /// The color for a filled shape behind ``onSolid``, such as a button.
    ///
    /// ``onSolid`` reaches 4.5:1 against it. It marks the brand, so it has no contrast floor against a
    /// surface.
    package var solid: Color { color(for: .solid) }

    /// The color for text or a symbol on ``solid``.
    ///
    /// It reaches 4.5:1 against ``solid``.
    package var onSolid: Color { color(for: .onSolid) }

    /// The color for a pale fill behind ``text``, such as a badge.
    ///
    /// ``text`` reaches 4.5:1 against it.
    package var subtle: Color { color(for: .subtle) }

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
    public init(infoDictionary: [String: Any]) throws(ParsingError) {
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
    /// On iOS, a surface lifts in an elevated container, such as a sheet. Elsewhere it does not, and
    /// no other role does.
    ///
    /// - Parameter role: The job the color does.
    /// - Returns: The color, named after the brand and the role.
    private func color(for role: Role) -> Color {
        let base = resource(named: "\(catalogName)-\(role)")
        #if canImport(UIKit)
        guard let elevatedName = role.elevatedName else { return Color(base) }
        let elevated = resource(named: "\(catalogName)-\(elevatedName)")
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
