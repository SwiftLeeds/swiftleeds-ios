import SwiftUI
import Testing
import UIDesign

/// Tests that each status color is the text color of its ``ColorFamily``.
struct StatusColorTests {
    /// Each status color beside the family it names.
    private static let pairs: [(Color, ColorFamily)] = [
        (Color.success, ColorFamily.success),
        (Color.warning, ColorFamily.warning),
        (Color.error, ColorFamily.error),
        (Color.info, ColorFamily.info),
    ]

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

    /// Checks that a status color resolves to the text color of its family in light and dark.
    ///
    /// - Parameters:
    ///   - color: The status color to check.
    ///   - family: The family whose text color it should match.
    @Test(arguments: pairs)
    func whenStatusColorResolves_shouldMatchFamilyText(color: Color, family: ColorFamily) {
        for colorScheme in [ColorScheme.light, .dark] {
            let resolved = Self.resolve(color, in: colorScheme)
            let expected = Self.resolve(family.text, in: colorScheme)
            #expect(resolved == expected, "\(family) status color in \(colorScheme) is not its text")
        }
    }

    /// Checks that resolution honors the color scheme, so a wrong path cannot pass unnoticed.
    @Test
    func whenColorSchemeIsDark_shouldResolveToDifferentTone() {
        let light = Self.resolve(ColorFamily.success.text, in: .light)
        let dark = Self.resolve(ColorFamily.success.text, in: .dark)
        #expect(light != dark)
    }
}
