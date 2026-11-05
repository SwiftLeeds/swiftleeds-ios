import Foundation
import Testing

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
            /// The key that names the color space, spelled with a hyphen.
            case colorSpace = "color-space"

            /// The key that holds the components.
            case components = "components"
        }

        /// The color space the components are in.
        let colorSpace: String

        /// The components, keyed by name.
        let components: [String: String]
    }

    /// One entry of a color set's `Contents.json`.
    private struct Entry: Decodable {
        /// A device family a catalog entry applies to.
        enum Idiom: String, Decodable, Equatable, Hashable, Sendable {
            /// Every device family without an entry of its own.
            case universal = "universal"

            /// Apple Watch.
            case watch = "watch"

            /// Mac.
            case mac = "mac"
        }

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
        let idiom: Idiom

        /// Creates an entry from a decoder, reading an absent `appearances` key as none.
        ///
        /// - Parameter decoder: The decoder to read the entry from.
        /// - Throws: An error when a key is missing or has the wrong type.
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            appearances = try container.decodeIfPresent([Appearance].self, forKey: .appearances) ?? []
            color = try container.decode(Color.self, forKey: .color)
            idiom = try container.decode(Idiom.self, forKey: .idiom)
        }
    }

    /// The `colors` array of a color set's `Contents.json`.
    private struct Contents: Decodable {
        /// Every entry of the set.
        let colors: [Entry]
    }

    /// A color set folder of the catalog, read from disk.
    private struct ColorSet {
        /// The folder name of a color set.
        struct ColorSetName: CustomStringConvertible, Equatable, Hashable, Sendable {
            /// The folder name as written on disk.
            private let value: String

            /// The folder name, for failure messages.
            var description: String { value }

            /// Creates a name from a folder name.
            ///
            /// - Parameter value: The folder name of the set.
            init(_ value: String) {
                self.value = value
            }
        }

        /// The folder name of the set.
        let name: ColorSetName

        /// The decoded `Contents.json` of the set.
        let contents: Contents
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
                $0.idiom == .universal && $0.appearances == Self.darkAppearance
            }
            let watch = set.contents.colors.filter { $0.idiom == .watch && $0.appearances.isEmpty }
            #expect(dark.count == 1, "\(set.name) needs one dark entry")
            #expect(watch.count == 1, "\(set.name) needs one Watch entry")
            #expect(watch.first?.color == dark.first?.color, "\(set.name) Watch value differs from dark")
        }
    }

    /// Reads the sets in the catalog.
    ///
    /// - Returns: Each set's folder name and contents, sorted by name.
    /// - Throws: An error when the catalog or one of its files cannot be read or decoded.
    private static func colorSets() throws -> [ColorSet] {
        let packageRoot = URL(fileURLWithPath: #filePath)
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
                return ColorSet(
                    name: ColorSet.ColorSetName(folder.lastPathComponent),
                    contents: try JSONDecoder().decode(Contents.self, from: data),
                )
            }
    }
}
