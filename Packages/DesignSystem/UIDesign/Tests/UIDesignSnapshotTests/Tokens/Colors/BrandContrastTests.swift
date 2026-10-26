#if os(iOS)
import SwiftUI
import Testing
import UIDesign

/// Tests that every ``Brand`` role meets its contrast floors on that brand's surfaces.
@MainActor
struct BrandContrastTests {
    /// A pair of colors from one brand, drawn together.
    private enum Pair: CaseIterable {
        /// Brand text on the screen background.
        case textOnSurface
        /// Brand text on grouped content.
        case textOnSecondarySurface
        /// The label on the brand's fill.
        case onSolidOnSolid
        /// Brand text on the brand's pale fill.
        case textOnSubtle

        /// Returns the color drawn in front.
        ///
        /// - Parameter brand: The brand to read.
        /// - Returns: The foreground color of this pair.
        func foreground(of brand: Brand) -> Color {
            switch self {
            case .textOnSurface: brand.text
            case .textOnSecondarySurface: brand.text
            case .onSolidOnSolid: brand.onSolid
            case .textOnSubtle: brand.text
            }
        }

        /// Returns the color drawn behind.
        ///
        /// - Parameter brand: The brand to read.
        /// - Returns: The background color of this pair.
        func background(of brand: Brand) -> Color {
            switch self {
            case .textOnSurface: brand.surface
            case .textOnSecondarySurface: brand.secondarySurface
            case .onSolidOnSolid: brand.solid
            case .textOnSubtle: brand.subtle
            }
        }
    }

    /// Returns the WCAG contrast ratio of a pair for a brand under an appearance.
    ///
    /// - Parameters:
    ///   - pair: The two colors to compare.
    ///   - brand: The brand that supplies them.
    ///   - appearance: The appearance to draw them under.
    /// - Returns: The ratio, from 1 for identical colors upward.
    private static func ratio(of pair: Pair, for brand: Brand, in appearance: SystemAppearance) -> Float {
        let front = WCAG.resolve(pair.foreground(of: brand), in: appearance)
        let back = WCAG.resolve(pair.background(of: brand), in: appearance)
        return WCAG.ratio(between: front, and: back)
    }

    /// Checks that each pair reaches the text floor in every appearance.
    ///
    /// - Parameter brand: The brand to check.
    @Test(arguments: Brand.allCases)
    func whenDrawnOnItsBackground_shouldMeetTextFloor(brand: Brand) {
        for pair in Pair.allCases {
            for appearance in SystemAppearance.allCases {
                let ratio = Self.ratio(of: pair, for: brand, in: appearance)
                #expect(
                    ratio >= WCAG.textFloor,
                    "\(brand) \(pair) \(appearance.name): \(WCAG.text(of: ratio)), floor \(WCAG.textFloor)",
                )
            }
        }
    }

    /// Checks that Increase Contrast never lowers the ratio of a pair.
    ///
    /// - Parameter brand: The brand to check.
    @Test(arguments: Brand.allCases)
    func whenContrastIsIncreased_shouldNotLowerContrast(brand: Brand) {
        for pair in Pair.allCases {
            for appearance in SystemAppearance.allCases {
                guard let standard = appearance.withoutIncreasedContrast else { continue }
                let increased = Self.ratio(of: pair, for: brand, in: appearance)
                let normal = Self.ratio(of: pair, for: brand, in: standard)
                let shown = "\(WCAG.text(of: increased)) is below \(WCAG.text(of: normal))"
                #expect(increased >= normal, "\(brand) \(pair) \(appearance.name): \(shown)")
            }
        }
    }
}
#endif
