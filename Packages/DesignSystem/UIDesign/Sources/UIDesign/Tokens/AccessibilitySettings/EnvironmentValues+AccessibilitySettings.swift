import SwiftUI

extension EnvironmentValues {
    /// The accessibility settings that change how a token draws, in this environment.
    package var accessibilitySettings: AccessibilitySettings {
        AccessibilitySettings(
            differentiation: accessibilityDifferentiateWithoutColor ? .withoutColor : .standard,
            contrast: colorSchemeContrast,
            transparency: accessibilityReduceTransparency ? .reduced : .standard,
        )
    }
}
