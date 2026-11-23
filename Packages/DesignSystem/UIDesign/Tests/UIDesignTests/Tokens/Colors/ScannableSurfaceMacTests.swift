#if os(macOS)
import SwiftUI
import Testing
import UIDesign

/// Tests that the scannable surface stays a light brand surface on macOS.
@MainActor
struct ScannableSurfaceMacTests {
    /// How far a channel may sit from the expected one, as a fraction of its full range.
    private static let channelTolerance: Float = 2 / 255

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

    /// Checks that the scannable surface in the dark scheme is the light surface.
    ///
    /// - Parameter brand: The brand to check.
    @Test(arguments: Brand.allCases)
    func whenResolvedInDarkScheme_shouldMatchLightSurface(brand: Brand) {
        let actual = brand.scannableSurface.resolve(in: Self.environment(for: brand, in: .dark))
        let expected = brand.surface.resolve(in: Self.environment(for: brand, in: .light))
        #expect(abs(actual.red - expected.red) <= Self.channelTolerance, "red \(actual), expected \(expected)")
        #expect(abs(actual.green - expected.green) <= Self.channelTolerance, "green \(actual), expected \(expected)")
        #expect(abs(actual.blue - expected.blue) <= Self.channelTolerance, "blue \(actual), expected \(expected)")
    }
}
#endif
