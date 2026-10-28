import SwiftUI
import Testing
import UIDesign

/// Tests for how each ``LineWidth`` role reads the accessibility settings.
struct LineWidthTests {
    /// Settings that differ from the standard ones in differentiation, contrast or transparency.
    private static let changedSettings = [
        UIDesign.AccessibilitySettings(
            differentiation: .withoutColor,
            contrast: .standard,
            transparency: .standard,
        ),
        UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .increased,
            transparency: .standard,
        ),
        UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .standard,
            transparency: .reduced,
        ),
    ]

    /// Checks that the pattern is three points wide under standard settings.
    @Test
    func whenPatternIsResolvedForStandardSettings_shouldReturnThreePoints() {
        let sut = LineWidth.pattern
        let settings = UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .standard,
            transparency: .standard,
        )
        let level = sut.level(for: settings)
        #expect(level == .points3)
        #expect(CGFloat(level) == 3)
    }

    /// Checks that no accessibility setting changes the width of the pattern.
    ///
    /// - Parameter settings: Settings that differ from the standard ones.
    @Test(arguments: changedSettings)
    func whenAccessibilitySettingsChange_shouldReturnPatternAtThreePoints(
        settings: UIDesign.AccessibilitySettings
    ) {
        let sut = LineWidth.pattern
        #expect(sut.level(for: settings) == .points3)
    }
}
