#if os(iOS)
import SwiftUI
import UIKit

extension WCAG {
    /// Returns the components a color has under an appearance.
    ///
    /// - Parameters:
    ///   - color: The color to resolve.
    ///   - appearance: The appearance to resolve it under.
    /// - Returns: The color as fixed components.
    @MainActor
    static func resolve(_ color: Color, in appearance: SystemAppearance) -> Color.Resolved {
        // Fixed with the traits first: `EnvironmentValues` cannot set Increase Contrast.
        let fixed = UIColor(color).resolvedColor(with: appearance.traits)
        return Color(fixed).resolve(in: EnvironmentValues())
    }
}
#endif
