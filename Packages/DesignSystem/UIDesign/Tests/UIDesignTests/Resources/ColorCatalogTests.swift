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

            /// The part of the folder name before the first hyphen, such as `blue`.
            private var family: Substring { value.prefix { $0 != "-" } }

            /// The part of the folder name after the first hyphen, such as `text.colorset`.
            private var role: Substring { value.drop { $0 != "-" }.dropFirst() }

            /// Whether the set is an elevated surface set, which has no increased contrast set.
            var isElevated: Bool { role.hasPrefix("elevated") }

            /// The name of the set that holds this set's increased contrast value on Apple Watch.
            ///
            /// The role takes the prefix `increasedContrast`, so `blue-text` gives
            /// `blue-increasedContrastText`.
            var increasedContrastName: Self {
                guard let first = role.first else { return self }
                return Self("\(family)-increasedContrast\(first.uppercased())\(role.dropFirst())")
            }

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

    /// The sets of the catalog, split into base sets and increased contrast sets.
    private struct Catalog {
        /// Every set that is not the increased contrast set of another set.
        let bases: [ColorSet]

        /// Every set whose name is built from the name of a non-elevated base set.
        let increasedContrastSets: [ColorSet]
    }

    /// The smallest number of base sets the catalog holds today.
    ///
    /// It does not count increased contrast sets.
    private static let minimumSetCount = 72

    /// The number of increased contrast sets: one for each base set that is not elevated.
    private static let increasedContrastSetCount = 60

    /// The appearance a catalog entry applies to: dark mode.
    private static let darkAppearance = [Appearance(appearance: "luminosity", value: "dark")]

    /// The appearances of an entry that is dark with Increase Contrast, in the order Xcode writes them.
    private static let darkHighContrastAppearances = [
        Appearance(appearance: "luminosity", value: "dark"),
        Appearance(appearance: "contrast", value: "high"),
    ]

    @Test func whenColorSetIsNotElevated_shouldHaveIncreasedContrastSetWithDarkContrastValue() throws {
        let catalog = try Self.catalog()
        let expectedSets = catalog.bases.filter { !$0.name.isElevated }
        #expect(catalog.increasedContrastSets.count == Self.increasedContrastSetCount)

        for base in expectedSets {
            let second = catalog.increasedContrastSets.first { $0.name == base.name.increasedContrastName }
            let increased = try #require(second, "\(base.name) needs a set named \(base.name.increasedContrastName)")
            let darkHighContrast = base.contents.colors.filter {
                $0.idiom == .universal && $0.appearances == Self.darkHighContrastAppearances
            }
            #expect(increased.contents.colors.count == 1, "\(increased.name) needs exactly one entry")
            let watch = increased.contents.colors.filter { $0.idiom == .watch && $0.appearances.isEmpty }
            #expect(watch.count == 1, "\(increased.name) needs a Watch entry with no appearances")
            #expect(darkHighContrast.count == 1, "\(base.name) needs one dark high contrast entry")
            #expect(
                increased.contents.colors.first?.color == darkHighContrast.first?.color,
                "\(increased.name) differs from the dark high contrast value of \(base.name)",
            )
        }
    }

    @Test func whenColorSetIsInCatalog_shouldHaveWatchEntryWithDarkValue() throws {
        let sets = try Self.catalog().bases
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

    /// Reads the catalog and splits its sets into base sets and increased contrast sets.
    ///
    /// An increased contrast set is a set whose name is built from a non-elevated set. A stray
    /// set that no base set builds stays among the bases.
    ///
    /// - Returns: The base sets and the increased contrast sets.
    /// - Throws: An error when the catalog or one of its files cannot be read or decoded.
    private static func catalog() throws -> Catalog {
        let sets = try colorSets()
        let existing = Set(sets.map(\.name))
        let increasedNames = Set(
            sets.filter { !$0.name.isElevated }
                .map(\.name.increasedContrastName)
                .filter { existing.contains($0) }
        )
        return Catalog(
            bases: sets.filter { !increasedNames.contains($0.name) },
            increasedContrastSets: sets.filter { increasedNames.contains($0.name) },
        )
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
