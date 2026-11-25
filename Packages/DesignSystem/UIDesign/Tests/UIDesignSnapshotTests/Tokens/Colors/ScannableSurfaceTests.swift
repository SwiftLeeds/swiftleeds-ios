#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
struct ScannableSurfaceTests {
    /// How many of an 8-bit channel's levels the channel may sit from the expected one.
    private static let toleranceLevels: Float = 2

    /// How far a channel may sit from the expected one, as a fraction of its full range.
    private static let channelTolerance = toleranceLevels / Float(UInt8.max)

    /// The traits of light mode at normal contrast and the base level.
    private static let lightTraits = SystemAppearance.light.traits

    /// Returns the components a color has under an appearance.
    ///
    /// - Parameters:
    ///   - color: The color to resolve.
    ///   - traits: The traits to resolve it under.
    /// - Returns: The color as fixed components.
    private static func resolve(_ color: Color, with traits: UITraitCollection) -> Color.Resolved {
        // Fixed with the traits first: `EnvironmentValues` cannot set Increase Contrast.
        Color(UIColor(color).resolvedColor(with: traits)).resolve(in: EnvironmentValues())
    }

    /// Returns the brand surface the scannable surface must match in an appearance.
    ///
    /// - Parameters:
    ///   - brand: The brand to read.
    ///   - appearance: The appearance the scannable surface resolves in.
    /// - Returns: The light secondary surface in dark mode at standard contrast, else the light surface.
    private static func expectedSurface(of brand: Brand, in appearance: SystemAppearance) -> Color {
        let usesSecondary = !appearance.isLight && appearance.withoutIncreasedContrast == nil
        return usesSecondary ? brand.secondarySurface : brand.surface
    }

    /// Returns whether two resolved colors differ by no more than the channel tolerance.
    ///
    /// - Parameters:
    ///   - first: The first color.
    ///   - second: The second color.
    /// - Returns: `true` when every channel is within tolerance.
    private static func areClose(_ first: Color.Resolved, _ second: Color.Resolved) -> Bool {
        abs(first.red - second.red) <= channelTolerance
            && abs(first.green - second.green) <= channelTolerance
            && abs(first.blue - second.blue) <= channelTolerance
    }

    @Test(arguments: Brand.allCases)
    func whenResolvedInAppearance_shouldMatchLightBrandSurface(brand: Brand) {
        var mismatched: [String] = []
        for appearance in SystemAppearance.allCases {
            let actual = Self.resolve(brand.scannableSurface, with: appearance.traits)
            let expected = Self.resolve(
                Self.expectedSurface(of: brand, in: appearance),
                with: Self.lightTraits,
            )
            if !Self.areClose(actual, expected) {
                mismatched.append("\(appearance.name): \(actual), expected \(expected)")
            }
        }
        #expect(mismatched.isEmpty, "\(brand) scannable surface differs in \(mismatched)")
    }

    @Test(arguments: Brand.allCases)
    func whenContrastIsIncreased_shouldNotLowerContrastWithBlackMarks(brand: Brand) {
        let marks = Color.black.resolve(in: EnvironmentValues())
        for appearance in SystemAppearance.allCases {
            guard let standard = appearance.withoutIncreasedContrast else { continue }
            let increased = WCAG.ratio(between: marks, and: WCAG.resolve(brand.scannableSurface, in: appearance))
            let normal = WCAG.ratio(between: marks, and: WCAG.resolve(brand.scannableSurface, in: standard))
            let shown = "\(WCAG.text(of: increased)) is below \(WCAG.text(of: normal))"
            #expect(increased >= normal, "\(brand) \(appearance.name): \(shown)")
        }
    }

    @Test(arguments: Brand.allCases)
    func whenBrandIsInEnvironment_shouldResolveThatBrandsPlate(brand: Brand) {
        var environment = EnvironmentValues()
        environment.brand = brand
        environment.colorScheme = .dark
        let style: BrandShapeStyle = .scannableSurface
        let actual = Self.resolve(style.resolve(in: environment), with: SystemAppearance.dark.traits)
        let expected = Self.resolve(brand.scannableSurface, with: SystemAppearance.dark.traits)
        #expect(Self.areClose(actual, expected), "\(brand) plate \(actual), expected \(expected)")
    }
}
#endif
