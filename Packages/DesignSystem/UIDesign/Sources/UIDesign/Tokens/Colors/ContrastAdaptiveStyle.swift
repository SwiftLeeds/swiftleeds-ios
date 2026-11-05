#if os(watchOS)
import SwiftUI

/// A color that follows Increase Contrast by choosing between two color sets.
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
        Color(environment.colorSchemeContrast == .increased ? increased : standard).resolve(in: environment)
    }
}
#endif
