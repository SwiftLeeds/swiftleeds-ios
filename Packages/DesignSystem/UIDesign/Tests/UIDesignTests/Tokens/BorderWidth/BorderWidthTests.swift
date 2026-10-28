import SwiftUI
import Testing
import UIDesign

/// Tests for how each ``BorderWidth`` role reads the accessibility settings.
struct BorderWidthTests {
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

    /// Checks that the edge is half a point wide under standard settings.
    @Test
    func whenEdgeIsResolvedForStandardSettings_shouldReturnThinLevel() {
        let sut = BorderWidth.edge
        let settings = UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .standard,
            transparency: .standard,
        )
        let level = sut.level(for: settings)
        #expect(level == .thin)
        #expect(CGFloat(level) == 0.5)
    }

    /// Checks that no accessibility setting changes the width of the edge.
    ///
    /// - Parameter settings: Settings that differ from the standard ones.
    @Test(arguments: changedSettings)
    func whenAccessibilitySettingsChange_shouldReturnEdgeAtThinLevel(
        settings: UIDesign.AccessibilitySettings
    ) {
        let sut = BorderWidth.edge
        #expect(sut.level(for: settings) == .thin)
    }
}
