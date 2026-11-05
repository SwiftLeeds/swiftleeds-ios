import SwiftUI

/// A color that follows Increase Contrast by choosing between two color sets.
///
/// Only watchOS uses it.
struct ContrastAdaptiveStyle: ShapeStyle, Equatable, Hashable, Sendable {
    /// The color set for standard contrast.
    let standard: ColorResource

    /// The color set for Increase Contrast.
    let increased: ColorResource

    /// Resolves the color set that matches the environment's contrast.
    ///
    /// - Parameter environment: The environment to resolve in.
    /// - Returns: The resolved color of ``increased`` under Increase Contrast, and of ``standard`` otherwise.
    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        // FB25448508: a Watch catalog drops contrast entries, so a second color set holds that value.
        Color(environment.colorSchemeContrast == .increased ? increased : standard).resolve(in: environment)
    }
}
