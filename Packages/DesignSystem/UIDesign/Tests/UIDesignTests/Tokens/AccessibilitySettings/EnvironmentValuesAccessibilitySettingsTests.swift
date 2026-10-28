import SwiftUI
import Testing
import UIDesign

/// Tests for the accessibility settings an environment reports.
struct EnvironmentValuesAccessibilitySettingsTests {
    /// Checks that an environment with no settings changed reports every setting as standard.
    @Test
    func whenEnvironmentIsDefault_shouldReturnStandardSettings() {
        let sut = EnvironmentValues()
        let expected = UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .standard,
            transparency: .standard,
        )
        #expect(sut.accessibilitySettings == expected)
    }
}
