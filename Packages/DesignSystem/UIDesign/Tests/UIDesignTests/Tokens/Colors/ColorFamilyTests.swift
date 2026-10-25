import SwiftUI
import Testing
import UIDesign

/// Tests that every ``ColorFamily`` role comes from the color catalog.
struct ColorFamilyTests {
    /// Returns the color of every role of a family.
    ///
    /// - Parameter family: The family to read.
    /// - Returns: The text, solid, on-solid and subtle colors, in that order.
    private static func colors(of family: ColorFamily) -> [Color] {
        [family.text, family.solid, family.onSolid, family.subtle]
    }

    /// Returns a color resolved for a color scheme.
    ///
    /// - Parameters:
    ///   - color: The color to resolve.
    ///   - colorScheme: The color scheme of the environment.
    /// - Returns: The resolved color.
    private static func resolve(_ color: Color, in colorScheme: ColorScheme) -> Color.Resolved {
        var environment = EnvironmentValues()
        environment.colorScheme = colorScheme
        return color.resolve(in: environment)
    }

    /// Checks that every role of a family resolves to an opaque catalog color in light and dark.
    ///
    /// - Parameter family: The family to check.
    @Test(arguments: ColorFamily.allCases)
    func whenRoleResolves_shouldReturnOpaqueCatalogColor(family: ColorFamily) {
        for color in Self.colors(of: family) {
            for colorScheme in [ColorScheme.light, .dark] {
                let resolved = Self.resolve(color, in: colorScheme)
                #expect(resolved.opacity == 1, "\(family) \(color) in \(colorScheme) is not opaque")
            }
        }
    }
}
