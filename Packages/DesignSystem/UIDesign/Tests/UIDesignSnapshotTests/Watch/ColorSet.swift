#if os(watchOS)
import Foundation
import SwiftUI

/// A color set of the catalog, read from its `Contents.json` on disk.
struct ColorSet {
    /// The folder name of a color set, without the `.colorset` extension.
    struct Name: CustomStringConvertible, Equatable, Hashable, Sendable {
        /// The folder name as written on disk.
        fileprivate let value: String

        /// The folder name, for failure messages.
        var description: String { value }

        /// Creates a name from a folder name.
        ///
        /// - Parameter value: The folder name of the set, such as `swiftLeeds-text`.
        init(_ value: String) {
            self.value = value
        }
    }

    /// An appearance the catalog gives a universal entry for.
    enum Appearance: Equatable, Sendable {
        /// Dark mode with standard contrast.
        case dark

        /// Dark mode with Increase Contrast.
        case darkIncreasedContrast

        /// The appearances an entry lists for this one, in the order Xcode writes them.
        fileprivate var listed: [AppearanceDTO] {
            switch self {
            case .dark: [AppearanceDTO(appearance: "luminosity", value: "dark")]

            case .darkIncreasedContrast:
                [
                    AppearanceDTO(appearance: "luminosity", value: "dark"),
                    AppearanceDTO(appearance: "contrast", value: "high"),
                ]
            }
        }
    }

    /// The reason a color cannot be read from a set.
    enum LookupError: Error, Equatable {
        /// The set has no universal entry for the appearance.
        case noEntry(Name, Appearance)

        /// The entry is not in Display P3, or a component is not a number.
        case unreadableColor(Name)
    }

    /// One appearance an entry applies to, as `Contents.json` writes it.
    fileprivate struct AppearanceDTO: Decodable, Equatable {
        /// The kind of appearance, such as `luminosity`.
        let appearance: String

        /// The value of the appearance, such as `dark`.
        let value: String
    }

    /// The color of an entry, as `Contents.json` writes it.
    fileprivate struct ColorDTO: Decodable {
        /// The keys of a color in `Contents.json`.
        private enum CodingKeys: String, CodingKey {
            /// The key that names the color space, spelled with a hyphen.
            case colorSpace = "color-space"

            /// The key that holds the components.
            case components = "components"
        }

        /// The color space the components are in, such as `display-p3`.
        let colorSpace: String

        /// The components, keyed by name.
        let components: [String: String]
    }

    /// One entry of a set's `Contents.json`.
    fileprivate struct EntryDTO: Decodable {
        /// The keys of an entry in `Contents.json`.
        private enum CodingKeys: String, CodingKey {
            /// The key that lists the appearances.
            case appearances = "appearances"

            /// The key that holds the color.
            case color = "color"

            /// The key that names the device family.
            case idiom = "idiom"
        }

        /// The appearances the entry applies to, empty for all of them.
        let appearances: [AppearanceDTO]

        /// The color the entry draws.
        let color: ColorDTO

        /// The device family the entry applies to, such as `universal`.
        let idiom: String

        /// Creates an entry from a decoder, reading an absent `appearances` key as none.
        ///
        /// - Parameter decoder: The decoder to read the entry from.
        /// - Throws: An error when a key is missing or has the wrong type.
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            appearances = try container.decodeIfPresent([AppearanceDTO].self, forKey: .appearances) ?? []
            color = try container.decode(ColorDTO.self, forKey: .color)
            idiom = try container.decode(String.self, forKey: .idiom)
        }
    }

    /// The `colors` array of a set's `Contents.json`.
    fileprivate struct ContentsDTO: Decodable {
        /// Every entry of the set.
        let colors: [EntryDTO]
    }

    /// The device family of an entry that applies to every device without an entry of its own.
    private static let universalIdiom = "universal"

    /// The color space the catalog writes its entries in.
    private static let displayP3 = "display-p3"

    /// The folder name of the set.
    let name: Name

    /// The decoded `Contents.json` of the set.
    fileprivate let contents: ContentsDTO

    /// Reads a set from the catalog of this package.
    ///
    /// - Parameter name: The folder name of the set.
    /// - Throws: An error when the set's `Contents.json` cannot be read or decoded.
    init(named name: Name) throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let file =
            packageRoot
            .appendingPathComponent("Sources/UIDesign/Resources/Colors.xcassets")
            .appendingPathComponent("\(name.value).colorset")
            .appendingPathComponent("Contents.json")
        self.name = name
        contents = try JSONDecoder().decode(ContentsDTO.self, from: Data(contentsOf: file))
    }

    /// Returns the color of the set's universal entry for an appearance.
    ///
    /// - Parameter appearance: The appearance the entry applies to.
    /// - Returns: The entry's color, converted from Display P3.
    /// - Throws: ``LookupError/noEntry(_:_:)`` when the set has no such entry.
    ///   ``LookupError/unreadableColor(_:)`` when the entry's color cannot be read.
    func color(for appearance: Appearance) throws -> Color.Resolved {
        let entry = contents.colors.first {
            $0.idiom == Self.universalIdiom && $0.appearances == appearance.listed
        }
        guard let entry else { throw LookupError.noEntry(name, appearance) }
        guard entry.color.colorSpace == Self.displayP3,
            let red = Float(entry.color.components["red"] ?? ""),
            let green = Float(entry.color.components["green"] ?? ""),
            let blue = Float(entry.color.components["blue"] ?? ""),
            let alpha = Float(entry.color.components["alpha"] ?? "")
        else { throw LookupError.unreadableColor(name) }
        return Color.Resolved(colorSpace: .displayP3, red: red, green: green, blue: blue, opacity: alpha)
    }
}
#endif
