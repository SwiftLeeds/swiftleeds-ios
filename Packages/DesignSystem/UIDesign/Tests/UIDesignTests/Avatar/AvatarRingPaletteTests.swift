import SwiftUI
import Testing
import UIDesign

/// Tests for ``AvatarRingPalette`` and its environment value.
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

    /// Every pair of two different palettes.
    private static let pairs: [PalettePair] = {
        let named: [(String, AvatarRingPalette)] = [
            ("neutral", .neutral),
            ("blue", .blue),
            ("teal", .teal),
            ("violet", .violet),
            ("raspberry", .raspberry),
            ("sponsor", .sponsor),
        ]
        return named.indices.flatMap { first in
            named.indices.dropFirst(first + 1).map { second in
                PalettePair(
                    first: named[first].1,
                    second: named[second].1,
                    testDescription: "\(named[first].0) and \(named[second].0)",
                )
            }
        }
    }()

    @Test
    func whenNoPaletteIsSet_shouldReturnNeutral() {
        let sut = EnvironmentValues()
        #expect(sut.avatarRingPalette == .neutral)
    }

    /// Checks that two palettes of different names are not equal.
    ///
    /// - Parameter pair: Two different palettes.
    @Test(arguments: pairs)
    fileprivate func whenPalettesNameDifferentFamilies_shouldNotBeEqual(pair: PalettePair) {
        #expect(pair.first != pair.second)
    }
}
