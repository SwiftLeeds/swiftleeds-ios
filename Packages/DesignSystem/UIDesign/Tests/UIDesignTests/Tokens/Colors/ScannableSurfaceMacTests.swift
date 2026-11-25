#if os(macOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
struct ScannableSurfaceMacTests {
    /// How many of an 8-bit channel's levels the channel may sit from the expected one.
    private static let toleranceLevels: Float = 2

    /// How far a channel may sit from the expected one, as a fraction of its full range.
    private static let channelTolerance = toleranceLevels / Float(UInt8.max)

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
