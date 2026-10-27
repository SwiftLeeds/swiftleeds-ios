import SwiftUI
import Testing
import UIDesign

/// Tests that the brand tokens draw the brand in the environment.
///
/// Each brand is a bright fill with a label on it. SwiftLeeds is an orange at hue 45 with a dark
/// label. KotlinLeeds is a purple at hue 289 with a light label in light mode and a dark one in
/// dark mode, where its fill is lighter.
struct BrandColorTests {
    /// The hue of the SwiftLeeds brand, in OKLCH degrees.
    private static let swiftLeedsHue: Double = 45

    /// The hue of the KotlinLeeds brand, in OKLCH degrees.
    private static let kotlinLeedsHue: Double = 289

    /// The OKLCH lightness of the SwiftLeeds fill, which is the same in light and in dark.
    private static let swiftLeedsFillLightness: Double = 0.72

    /// The OKLCH lightness of the KotlinLeeds fill in light, tone 50.
    private static let kotlinLeedsLightFillLightness: Double = 0.50

    /// The OKLCH lightness of the KotlinLeeds fill in dark, tone 60.
    private static let kotlinLeedsDarkFillLightness: Double = 0.60

    /// The chroma of every brand fill, the cap of every ramp.
    private static let fillChroma: Double = 0.20

    /// The OKLCH lightness of the dark label on the SwiftLeeds fill, in light and in dark.
    private static let swiftLeedsLabelLightness: Double = 0.05

    /// The OKLCH lightness of the light label on the KotlinLeeds fill in light, tone 95.
    private static let lightLabelLightness: Double = 0.95

    /// The OKLCH lightness of the label on the KotlinLeeds fill in dark, tone 5.
    private static let darkModeLabelLightness: Double = 0.05

    /// How far a resolved lightness or chroma may sit from its tone, after the catalog rounds it.
    private static let toneTolerance: Double = 0.005

    /// How far a resolved hue may sit from the brand hue, in degrees.
    private static let hueTolerance: Double = 1

    /// Returns an environment that carries a brand and a color scheme.
    ///
    /// - Parameters:
    ///   - brand: The brand views in the environment draw.
    ///   - colorScheme: The color scheme of the environment.
    /// - Returns: The environment.
    private static func environment(for brand: Brand, in colorScheme: ColorScheme) -> EnvironmentValues {
        var environment = EnvironmentValues()
        environment.brand = brand
        environment.colorScheme = colorScheme
        return environment
    }

    /// Returns a token resolved in an environment, in OKLCH.
    ///
    /// - Parameters:
    ///   - style: The token to resolve.
    ///   - environment: The environment to resolve it in.
    /// - Returns: The resolved color as lightness, chroma and hue, or `nil` for a token that is not
    ///   a color.
    private static func resolve(_ style: some ShapeStyle, in environment: EnvironmentValues) -> OKLCH? {
        style.components(in: environment).map(OKLCH.init)
    }

    /// Returns the hue a brand's fill has.
    ///
    /// - Parameter brand: The brand to read.
    /// - Returns: The hue, in OKLCH degrees.
    private static func hue(of brand: Brand) -> Double {
        switch brand {
        case .swiftLeeds: swiftLeedsHue

        case .kotlinLeeds: kotlinLeedsHue
        }
    }

    /// Returns the lightness a brand's fill has in a color scheme.
    ///
    /// - Parameters:
    ///   - brand: The brand to read.
    ///   - colorScheme: The color scheme the fill is drawn in.
    /// - Returns: The OKLCH lightness.
    private static func fillLightness(of brand: Brand, in colorScheme: ColorScheme) -> Double {
        switch (brand, colorScheme) {
        case (.swiftLeeds, _): swiftLeedsFillLightness

        case (.kotlinLeeds, .dark): kotlinLeedsDarkFillLightness

        case (.kotlinLeeds, _): kotlinLeedsLightFillLightness
        }
    }

    /// Returns the lightness the label on a brand's fill has in a color scheme.
    ///
    /// - Parameters:
    ///   - brand: The brand to read.
    ///   - colorScheme: The color scheme the label is drawn in.
    /// - Returns: The OKLCH lightness.
    private static func labelLightness(of brand: Brand, in colorScheme: ColorScheme) -> Double {
        switch (brand, colorScheme) {
        case (.swiftLeeds, _): swiftLeedsLabelLightness

        case (.kotlinLeeds, .dark): darkModeLabelLightness

        case (.kotlinLeeds, _): lightLabelLightness
        }
    }

    /// Checks that the brand fill resolves to its brand's hue, lightness and chroma.
    ///
    /// - Parameters:
    ///   - brand: The brand in the environment.
    ///   - colorScheme: The color scheme to resolve in.
    /// - Throws: When the platform has no appearance or no sRGB form for a color.
    @Test(arguments: Brand.allCases, [ColorScheme.light, .dark])
    func whenBrandResolves_shouldReturnBrandFill(brand: Brand, colorScheme: ColorScheme) throws {
        let environment = Self.environment(for: brand, in: colorScheme)
        let resolved = try #require(Self.resolve(.brand, in: environment))
        let hue = Self.hue(of: brand)
        let lightness = Self.fillLightness(of: brand, in: colorScheme)
        #expect(
            abs(resolved.hue - hue) <= Self.hueTolerance,
            "brand hue \(resolved.hue) for \(brand) in \(colorScheme), expected \(hue)",
        )
        #expect(
            abs(resolved.lightness - lightness) <= Self.toneTolerance,
            "brand lightness \(resolved.lightness) for \(brand) in \(colorScheme), expected \(lightness)",
        )
        #expect(
            abs(resolved.chroma - Self.fillChroma) <= Self.toneTolerance,
            "brand chroma \(resolved.chroma) for \(brand) in \(colorScheme), expected \(Self.fillChroma)",
        )
    }

    /// Checks that the label on the brand fill resolves to the lightness its brand's fill needs.
    ///
    /// - Parameters:
    ///   - brand: The brand in the environment.
    ///   - colorScheme: The color scheme to resolve in.
    /// - Throws: When the platform has no appearance or no sRGB form for a color.
    @Test(arguments: Brand.allCases, [ColorScheme.light, .dark])
    func whenOnBrandResolves_shouldReturnLabelOnFill(brand: Brand, colorScheme: ColorScheme) throws {
        let environment = Self.environment(for: brand, in: colorScheme)
        let resolved = try #require(Self.resolve(.onBrand, in: environment))
        let lightness = Self.labelLightness(of: brand, in: colorScheme)
        #expect(
            abs(resolved.lightness - lightness) <= Self.toneTolerance,
            "onBrand lightness \(resolved.lightness) for \(brand) in \(colorScheme), expected \(lightness)",
        )
    }
}
