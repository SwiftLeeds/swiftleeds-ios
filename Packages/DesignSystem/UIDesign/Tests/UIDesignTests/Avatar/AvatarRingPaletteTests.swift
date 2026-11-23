import SwiftUI
import Testing
import UIDesign

struct AvatarRingPaletteTests {
    /// Two different palettes from the six the type names.
    fileprivate struct PalettePair: CustomTestStringConvertible {
        /// The first palette.
        let first: AvatarRingPalette

        /// The second palette.
        let second: AvatarRingPalette

        /// The name of the pair that a test report shows.
        let testDescription: String
    }

    /// A palette with the name that a test report shows for it.
    private struct NamedPalette {
        /// The name of the palette, as the type spells it.
        ///
        /// A `String` because a test report shows it.
        let name: String

        /// The palette.
        let palette: AvatarRingPalette
    }

    /// Every pair of two different palettes.
    private static let pairs: [PalettePair] = {
        let named = [
            NamedPalette(name: "neutral", palette: .neutral),
            NamedPalette(name: "blue", palette: .blue),
            NamedPalette(name: "teal", palette: .teal),
            NamedPalette(name: "violet", palette: .violet),
            NamedPalette(name: "raspberry", palette: .raspberry),
            NamedPalette(name: "sponsor", palette: .sponsor),
        ]
        return named.indices.flatMap { first in
            named.indices.dropFirst(first + 1).map { second in
                PalettePair(
                    first: named[first].palette,
                    second: named[second].palette,
                    testDescription: "\(named[first].name) and \(named[second].name)",
                )
            }
        }
    }()

    @Test
    func whenNoPaletteIsSet_shouldReturnNeutral() {
        let sut = EnvironmentValues()
        #expect(sut.avatarRingPalette == .neutral)
    }

    @Test(arguments: pairs)
    fileprivate func whenPalettesNameDifferentFamilies_shouldNotBeEqual(pair: PalettePair) {
        #expect(pair.first != pair.second)
    }
}
