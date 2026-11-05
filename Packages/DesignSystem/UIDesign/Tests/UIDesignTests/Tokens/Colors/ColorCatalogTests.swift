import Foundation
import Testing

/// Tests that every color set in the catalog draws the same on the Watch as in dark mode.
///
/// The Watch has one appearance, always dark. A set with no Watch entry falls back to its light
/// value there, so the test reads the catalog's files.
struct ColorCatalogTests {
    /// One appearance a catalog entry applies to, such as dark mode.
    private struct Appearance: Decodable, Equatable {
        /// The kind of appearance, such as `luminosity`.
        let appearance: String

        /// The value of the appearance, such as `dark`.
        let value: String
    }

    /// The color an entry draws.
    private struct Color: Decodable, Equatable {
        /// The keys of a color in `Contents.json`.
        private enum CodingKeys: String, CodingKey {
            case colorSpace = "color-space"
            case components = "components"
        }

        /// The color space the components are in.
        let colorSpace: String

        /// The components, keyed by name.
        let components: [String: String]
    }

    /// One entry of a color set's `Contents.json`.
    private struct Entry: Decodable {
        /// The keys of an entry in `Contents.json`.
        private enum CodingKeys: String, CodingKey {
            case appearances = "appearances"
            case color = "color"
            case idiom = "idiom"
        }

        /// The appearances the entry applies to, empty for all of them.
        let appearances: [Appearance]

        /// The color the entry draws.
        let color: Color

        /// The device family the entry applies to.
        let idiom: String

        /// Creates an entry from a decoder, reading an absent `appearances` key as none.
        ///
        /// - Parameter decoder: The decoder to read the entry from.
        /// - Throws: An error when a key is missing or has the wrong type.
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            appearances = try container.decodeIfPresent([Appearance].self, forKey: .appearances) ?? []
            color = try container.decode(Color.self, forKey: .color)
            idiom = try container.decode(String.self, forKey: .idiom)
        }
    }

    /// The `colors` array of a color set's `Contents.json`.
    private struct Contents: Decodable {
        /// Every entry of the set.
        let colors: [Entry]
    }

    /// The smallest number of sets the catalog holds today.
    private static let minimumSetCount = 72

    /// The appearance a catalog entry applies to: dark mode.
    private static let darkAppearance = [Appearance(appearance: "luminosity", value: "dark")]

    @Test func whenColorSetIsInCatalog_shouldHaveWatchEntryWithDarkValue() throws {
        let sets = try Self.colorSets()
        #expect(sets.count >= Self.minimumSetCount)

        for set in sets {
            let dark = set.contents.colors.filter {
                $0.idiom == "universal" && $0.appearances == Self.darkAppearance
            }
            let watch = set.contents.colors.filter { $0.idiom == "watch" && $0.appearances.isEmpty }
            #expect(dark.count == 1, "\(set.name) needs one dark entry")
            #expect(watch.count == 1, "\(set.name) needs one Watch entry")
            #expect(watch.first?.color == dark.first?.color, "\(set.name) Watch value differs from dark")
        }
    }

    /// Reads the sets in the catalog.
    ///
    /// - Returns: Each set's folder name and contents, sorted by name.
    /// - Throws: An error when the catalog or one of its files cannot be read or decoded.
    private static func colorSets() throws -> [(name: String, contents: Contents)] {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let catalog = packageRoot.appendingPathComponent("Sources/UIDesign/Resources/Colors.xcassets")
        let folders = try FileManager.default.contentsOfDirectory(
            at: catalog,
            includingPropertiesForKeys: nil,
        )
        return
            try folders
            .filter { $0.pathExtension == "colorset" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map { folder in
                let data = try Data(contentsOf: folder.appendingPathComponent("Contents.json"))
                return (folder.lastPathComponent, try JSONDecoder().decode(Contents.self, from: data))
            }
    }
}
