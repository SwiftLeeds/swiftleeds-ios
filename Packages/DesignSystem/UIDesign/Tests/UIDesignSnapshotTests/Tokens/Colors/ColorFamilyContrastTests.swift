#if os(iOS)
import SwiftUI
import Testing
import UIDesign

/// Tests that every ``ColorFamily`` meets its contrast floors on each brand's surfaces.
@MainActor
struct ColorFamilyContrastTests {
    /// A surface a family color is drawn on.
    private enum Surface: CaseIterable {
        /// The main background.
        case surface
        /// Content layered on top of the main background.
        case secondarySurface
        /// Content layered on top of secondary backgrounds.
        case tertiarySurface
        /// The main background of a grouped interface.
        case groupedSurface
        /// Content layered on top of the main background of a grouped interface.
        case secondaryGroupedSurface
        /// Content layered on top of secondary backgrounds of a grouped interface.
        case tertiaryGroupedSurface

        /// Returns the brand's color for this surface.
        ///
        /// - Parameter brand: The brand whose surface to read.
        /// - Returns: The brand's tinted surface.
        func color(of brand: Brand) -> Color {
            switch self {
            case .surface: brand.surface
            case .secondarySurface: brand.secondarySurface
            case .tertiarySurface: brand.tertiarySurface
            case .groupedSurface: brand.groupedSurface
            case .secondaryGroupedSurface: brand.secondaryGroupedSurface
            case .tertiaryGroupedSurface: brand.tertiaryGroupedSurface
            }
        }
    }

    /// A pair of colors from one family, or from a family and a surface, drawn together.
    private enum Pair {
        /// Family text on a surface.
        case textOn(Surface)
        /// Family fill on a surface.
        case solidOn(Surface)
        /// Family symbol on the family's fill.
        case onSolidOnSolid
        /// Family text on the family's pale fill.
        case textOnSubtle

        /// Every pair, with text and fill on each surface.
        static let allCases: [Self] =
            Surface.allCases.map(Self.textOn) + Surface.allCases.map(Self.solidOn) + [.onSolidOnSolid, .textOnSubtle]

        /// The pair as a failure message shows it, such as `solidOn tertiarySurface`.
        var name: String {
            switch self {
            case .textOn(let surface): "textOn \(surface)"
            case .solidOn(let surface): "solidOn \(surface)"
            case .onSolidOnSolid: "onSolidOnSolid"
            case .textOnSubtle: "textOnSubtle"
            }
        }

        /// The lowest contrast ratio this pair must reach.
        var floor: Float {
            switch self {
            case .textOn: WCAG.textFloor
            case .solidOn: WCAG.graphicFloor
            case .onSolidOnSolid: WCAG.textFloor
            case .textOnSubtle: WCAG.textFloor
            }
        }

        /// Whether this pair compares the fill with a surface.
        var comparesFillWithSurface: Bool {
            switch self {
            case .textOn: false
            case .solidOn: true
            case .onSolidOnSolid: false
            case .textOnSubtle: false
            }
        }

        /// Returns the color drawn in front.
        ///
        /// - Parameter family: The family to read.
        /// - Returns: The foreground color of this pair.
        func foreground(of family: ColorFamily) -> Color {
            switch self {
            case .textOn: family.text
            case .solidOn: family.solid
            case .onSolidOnSolid: family.onSolid
            case .textOnSubtle: family.text
            }
        }

        /// Returns the color drawn behind.
        ///
        /// - Parameters:
        ///   - family: The family to read.
        ///   - brand: The brand whose surfaces the pair is drawn on.
        /// - Returns: The background color of this pair.
        func background(of family: ColorFamily, on brand: Brand) -> Color {
            switch self {
            case .textOn(let surface): surface.color(of: brand)
            case .solidOn(let surface): surface.color(of: brand)
            case .onSolidOnSolid: family.solid
            case .textOnSubtle: family.subtle
            }
        }
    }

    /// The ways the system can draw a color, such as light mode or a dark sheet.
    private typealias Appearance = SystemAppearance

    /// Families whose fill is pale in light appearances, so its edge is not checked against a light
    /// surface, and its ratio there has no ordering to keep under Increase Contrast.
    ///
    /// The text and symbol on such a fill carry the state. In dark appearances the fill is checked
    /// like any other.
    nonisolated private static let paleFillFamilies: Set<ColorFamily> = [.warning]

    /// Returns the WCAG contrast ratio of a pair for a family under an appearance.
    ///
    /// - Parameters:
    ///   - pair: The two colors to compare.
    ///   - family: The family that supplies them.
    ///   - brand: The brand whose surfaces the pair is drawn on.
    ///   - appearance: The appearance to draw them under.
    /// - Returns: The ratio, from 1 for identical colors upward.
    private static func ratio(
        of pair: Pair,
        for family: ColorFamily,
        on brand: Brand,
        in appearance: Appearance,
    ) -> Float {
        let front = WCAG.resolve(pair.foreground(of: family), in: appearance)
        let back = WCAG.resolve(pair.background(of: family, on: brand), in: appearance)
        return WCAG.ratio(between: front, and: back)
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

    /// Checks that each pair reaches its floor in every appearance, on each brand's surfaces.
    ///
    /// - Parameters:
    ///   - family: The family to check.
    ///   - brand: The brand whose surfaces the family is drawn on.
    @Test(arguments: ColorFamily.allCases, Brand.allCases)
    func whenDrawnOnItsBackground_shouldMeetContrastFloor(family: ColorFamily, brand: Brand) {
        for pair in Pair.allCases {
            for appearance in Appearance.allCases {
                if Self.isExempt(pair, for: family, in: appearance) { continue }
                let ratio = Self.ratio(of: pair, for: family, on: brand, in: appearance)
                #expect(
                    ratio >= pair.floor,
                    "\(brand) \(family) \(pair.name) \(appearance.name): \(WCAG.text(of: ratio)), floor \(pair.floor)",
                )
            }
        }
    }

    /// Checks that Increase Contrast never lowers the ratio of a pair, on each brand's surfaces.
    ///
    /// - Parameters:
    ///   - family: The family to check.
    ///   - brand: The brand whose surfaces the family is drawn on.
    @Test(arguments: ColorFamily.allCases, Brand.allCases)
    func whenContrastIsIncreased_shouldNotLowerContrast(family: ColorFamily, brand: Brand) {
        for pair in Pair.allCases {
            for appearance in Appearance.allCases {
                if Self.isExempt(pair, for: family, in: appearance) { continue }
                guard let standard = appearance.withoutIncreasedContrast else { continue }
                let increased = Self.ratio(of: pair, for: family, on: brand, in: appearance)
                let normal = Self.ratio(of: pair, for: family, on: brand, in: standard)
                let shown = "\(WCAG.text(of: increased)) is below \(WCAG.text(of: normal))"
                #expect(increased >= normal, "\(brand) \(family) \(pair.name) \(appearance.name): \(shown)")
            }
        }
    }

    /// Checks that each exempt family's fill really is pale in light appearances, so the exemption
    /// cannot go stale.
    ///
    /// - Parameters:
    ///   - family: The family to check.
    ///   - brand: The brand whose surfaces the family is drawn on.
    @Test(arguments: Self.paleFillFamilies, Brand.allCases)
    func whenFillIsPale_shouldSitBelowGraphicFloorOnLightSurfaces(family: ColorFamily, brand: Brand) {
        for appearance in Appearance.allCases where appearance.isLight {
            let ratio = Self.ratio(of: .solidOn(.surface), for: family, on: brand, in: appearance)
            #expect(
                ratio < WCAG.graphicFloor,
                "\(brand) \(family) \(appearance.name): \(WCAG.text(of: ratio)) reaches the graphic floor",
            )
        }
    }

    /// Checks that resolution sees Increase Contrast, so a wrong path cannot pass unnoticed.
    @Test
    func whenContrastIsIncreased_shouldResolveToDifferentTone() {
        let normal = WCAG.resolve(ColorFamily.info.text, in: .light)
        let increased = WCAG.resolve(ColorFamily.info.text, in: .lightIncreasedContrast)
        #expect(normal != increased)
    }
}
#endif
