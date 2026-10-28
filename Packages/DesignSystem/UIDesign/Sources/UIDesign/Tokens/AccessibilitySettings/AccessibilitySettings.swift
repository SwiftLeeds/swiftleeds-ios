import SwiftUI

/// The accessibility settings that change how a token draws.
package struct AccessibilitySettings: Equatable, Hashable, Sendable {
    /// How the person needs things told apart.
    package let differentiation: ColorDifferentiation

    /// How much contrast the person asked for.
    package let contrast: ColorSchemeContrast

    /// How see-through the person wants surfaces.
    package let transparency: Transparency

    /// Creates settings from the three choices.
    ///
    /// - Parameters:
    ///   - differentiation: How the person needs things told apart.
    ///   - contrast: How much contrast the person asked for.
    ///   - transparency: How see-through the person wants surfaces.
    package init(
        differentiation: ColorDifferentiation,
        contrast: ColorSchemeContrast,
        transparency: Transparency,
    ) {
        self.differentiation = differentiation
        self.contrast = contrast
        self.transparency = transparency
    }
}
