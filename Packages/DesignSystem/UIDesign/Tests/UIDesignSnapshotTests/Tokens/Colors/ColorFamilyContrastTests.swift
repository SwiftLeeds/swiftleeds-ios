#if os(iOS)
import Foundation
import SwiftUI
import Testing
import UIDesign
import UIKit

/// Tests that every ``ColorFamily`` meets its contrast floors on the system surfaces.
@MainActor
struct ColorFamilyContrastTests {
    /// The weight of linear red in relative luminance, from Rec. 709.
    private static let redWeight: Float = 0.2126
    /// The weight of linear green in relative luminance, from Rec. 709.
    private static let greenWeight: Float = 0.7152
    /// The weight of linear blue in relative luminance, from Rec. 709.
    private static let blueWeight: Float = 0.0722
    /// The light WCAG adds to both colors of a contrast ratio, for glare on the screen.
    private static let glare: Float = 0.05
    /// The lowest ratio WCAG accepts for text.
    nonisolated private static let textFloor: Float = 4.5
    /// The lowest ratio WCAG accepts for a graphic.
    nonisolated private static let graphicFloor: Float = 3
    /// Families whose fill is pale in light appearances, so its edge is not checked against a light
    /// surface, and its ratio there has no ordering to keep under Increase Contrast.
    ///
    /// The text and symbol on such a fill carry the state. In dark appearances the fill is checked
    /// like any other.
    nonisolated private static let paleFillFamilies: Set<ColorFamily> = [.warning]

    /// A pair of colors from one family, or from a family and a surface, drawn together.
    private enum Pair: CaseIterable {
        /// Family text on the screen background.
        case textOnSurface
        /// Family text on grouped content.
        case textOnSecondarySurface
        /// Family symbol on the family's fill.
        case onSolidOnSolid
        /// Family fill on the screen background.
        case solidOnSurface
        /// Family fill on grouped content.
        case solidOnSecondarySurface
        /// Family text on the family's pale fill.
        case textOnSubtle

        /// The lowest contrast ratio this pair must reach.
        var floor: Float {
            switch self {
            case .textOnSurface: ColorFamilyContrastTests.textFloor
            case .textOnSecondarySurface: ColorFamilyContrastTests.textFloor
            case .onSolidOnSolid: ColorFamilyContrastTests.textFloor
            case .solidOnSurface: ColorFamilyContrastTests.graphicFloor
            case .solidOnSecondarySurface: ColorFamilyContrastTests.graphicFloor
            case .textOnSubtle: ColorFamilyContrastTests.textFloor
            }
        }

        /// Whether this pair compares the fill with a surface.
        var comparesFillWithSurface: Bool {
            switch self {
            case .textOnSurface: false
            case .textOnSecondarySurface: false
            case .onSolidOnSolid: false
            case .solidOnSurface: true
            case .solidOnSecondarySurface: true
            case .textOnSubtle: false
            }
        }

        /// Returns the color drawn in front.
        ///
        /// - Parameter family: The family to read.
        /// - Returns: The foreground color of this pair.
        func foreground(of family: ColorFamily) -> Color {
            switch self {
            case .textOnSurface: family.text
            case .textOnSecondarySurface: family.text
            case .onSolidOnSolid: family.onSolid
            case .solidOnSurface: family.solid
            case .solidOnSecondarySurface: family.solid
            case .textOnSubtle: family.text
            }
        }

        /// Returns the color drawn behind.
        ///
        /// - Parameter family: The family to read.
        /// - Returns: The background color of this pair.
        func background(of family: ColorFamily) -> Color {
            switch self {
            case .textOnSurface: Color.surface
            case .textOnSecondarySurface: Color.secondarySurface
            case .onSolidOnSolid: family.solid
            case .solidOnSurface: Color.surface
            case .solidOnSecondarySurface: Color.secondarySurface
            case .textOnSubtle: family.subtle
            }
        }
    }

    /// One way the system can draw a color, with the traits that produce it.
    private enum Appearance: CaseIterable {
        /// Light mode.
        case light
        /// Dark mode.
        case dark
        /// Light mode with Increase Contrast.
        case lightIncreasedContrast
        /// Dark mode with Increase Contrast.
        case darkIncreasedContrast
        /// Dark mode in an elevated container, such as a sheet.
        case darkElevated
        /// Dark mode with Increase Contrast in an elevated container.
        case darkIncreasedContrastElevated

        /// The name that failure messages use.
        var name: String {
            switch self {
            case .light: "light"
            case .dark: "dark"
            case .lightIncreasedContrast: "light with Increase Contrast"
            case .darkIncreasedContrast: "dark with Increase Contrast"
            case .darkElevated: "dark elevated"
            case .darkIncreasedContrastElevated: "dark elevated with Increase Contrast"
            }
        }

        /// The same appearance without Increase Contrast, or `nil` when it has none on.
        var withoutIncreasedContrast: Self? {
            switch self {
            case .light: nil
            case .dark: nil
            case .darkElevated: nil
            case .lightIncreasedContrast: .light
            case .darkIncreasedContrast: .dark
            case .darkIncreasedContrastElevated: .darkElevated
            }
        }

        /// Whether this appearance is light mode.
        var isLight: Bool { self == .light || self == .lightIncreasedContrast }

        /// Whether this appearance is in an elevated container.
        private var isElevated: Bool { self == .darkElevated || self == .darkIncreasedContrastElevated }

        /// The traits the system sets for this appearance.
        @MainActor
        var traits: UITraitCollection {
            UITraitCollection { traits in
                traits.userInterfaceStyle = isLight ? .light : .dark
                traits.accessibilityContrast = withoutIncreasedContrast == nil ? .normal : .high
                traits.userInterfaceLevel = isElevated ? .elevated : .base
            }
        }
    }

    /// Returns the components a color has under an appearance.
    ///
    /// - Parameters:
    ///   - color: The color to resolve.
    ///   - appearance: The appearance to resolve it under.
    /// - Returns: The color as fixed components.
    private static func resolve(_ color: Color, in appearance: Appearance) -> Color.Resolved {
        // Fixed with the traits first: `EnvironmentValues` cannot set Increase Contrast.
        let fixed = UIColor(color).resolvedColor(with: appearance.traits)
        return Color(fixed).resolve(in: EnvironmentValues())
    }

    /// Returns how bright a color looks, from 0 for black to 1 for white.
    ///
    /// - Parameter color: The color to measure.
    /// - Returns: The relative luminance of `color`.
    private static func luminance(of color: Color.Resolved) -> Float {
        redWeight * color.linearRed + greenWeight * color.linearGreen + blueWeight * color.linearBlue
    }

    /// Returns the WCAG contrast ratio of a pair for a family under an appearance.
    ///
    /// - Parameters:
    ///   - pair: The two colors to compare.
    ///   - family: The family that supplies them.
    ///   - appearance: The appearance to draw them under.
    /// - Returns: The ratio, from 1 for identical colors upward.
    private static func ratio(of pair: Pair, for family: ColorFamily, in appearance: Appearance) -> Float {
        let front = luminance(of: resolve(pair.foreground(of: family), in: appearance))
        let back = luminance(of: resolve(pair.background(of: family), in: appearance))
        return (max(front, back) + glare) / (min(front, back) + glare)
    }

    /// Returns a ratio as text with two decimals.
    ///
    /// - Parameter ratio: The ratio to show.
    /// - Returns: The text, such as `4.51`.
    private static func text(of ratio: Float) -> String {
        ratio.formatted(.number.precision(.fractionLength(2)))
    }

    /// Checks that each pair reaches its floor in every appearance.
    ///
    /// - Parameter family: The family to check.
    @Test(arguments: ColorFamily.allCases)
    func whenDrawnOnItsBackground_shouldMeetContrastFloor(family: ColorFamily) {
        for pair in Pair.allCases {
            for appearance in Appearance.allCases {
                if Self.isExempt(pair, for: family, in: appearance) { continue }
                let ratio = Self.ratio(of: pair, for: family, in: appearance)
                #expect(
                    ratio >= pair.floor,
                    "\(family) \(pair) \(appearance.name): \(Self.text(of: ratio)), floor \(pair.floor)",
                )
            }
        }
    }

    /// Checks that Increase Contrast never lowers the ratio of a pair.
    ///
    /// - Parameter family: The family to check.
    @Test(arguments: ColorFamily.allCases)
    func whenContrastIsIncreased_shouldNotLowerContrast(family: ColorFamily) {
        for pair in Pair.allCases {
            for appearance in Appearance.allCases {
                if Self.isExempt(pair, for: family, in: appearance) { continue }
                guard let standard = appearance.withoutIncreasedContrast else { continue }
                let increased = Self.ratio(of: pair, for: family, in: appearance)
                let normal = Self.ratio(of: pair, for: family, in: standard)
                let shown = "\(Self.text(of: increased)) is below \(Self.text(of: normal))"
                #expect(increased >= normal, "\(family) \(pair) \(appearance.name): \(shown)")
            }
        }
    }

    /// Checks that each exempt family's fill really is pale in light appearances, so the exemption
    /// cannot go stale.
    ///
    /// - Parameter family: The family to check.
    @Test(arguments: Self.paleFillFamilies)
    func whenFillIsPale_shouldSitBelowGraphicFloorOnLightSurfaces(family: ColorFamily) {
        for appearance in Appearance.allCases where appearance.isLight {
            let ratio = Self.ratio(of: .solidOnSurface, for: family, in: appearance)
            #expect(
                ratio < Self.graphicFloor,
                "\(family) \(appearance.name): \(Self.text(of: ratio)) reaches the graphic floor",
            )
        }
    }

    /// Returns whether a pair is left out of the floor and ordering checks.
    ///
    /// - Parameters:
    ///   - pair: The two colors to compare.
    ///   - family: The family that supplies them.
    ///   - appearance: The appearance to draw them under.
    /// - Returns: `true` for a pale family's fill against a light surface.
    private static func isExempt(_ pair: Pair, for family: ColorFamily, in appearance: Appearance) -> Bool {
        pair.comparesFillWithSurface && appearance.isLight && paleFillFamilies.contains(family)
    }

    /// Checks that resolution sees Increase Contrast, so a wrong path cannot pass unnoticed.
    @Test
    func whenContrastIsIncreased_shouldResolveToDifferentTone() {
        let normal = Self.resolve(ColorFamily.info.text, in: .light)
        let increased = Self.resolve(ColorFamily.info.text, in: .lightIncreasedContrast)
        #expect(normal != increased)
    }
}
#endif
