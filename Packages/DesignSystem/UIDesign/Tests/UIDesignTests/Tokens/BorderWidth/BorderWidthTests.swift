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

    /// Checks that the outline is one point wide under Increase Contrast.
    @Test
    func whenOutlineIsResolvedForIncreasedContrast_shouldReturnMediumLevel() {
        let sut = BorderWidth.outline
        let settings = UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .increased,
            transparency: .standard,
        )
        let level = sut.level(for: settings)
        #expect(level == .medium)
        #expect(CGFloat(level) == 1)
    }

    /// Checks that the outline is zero wide under standard contrast.
    @Test
    func whenOutlineIsResolvedForStandardContrast_shouldReturnZeroLevel() {
        let sut = BorderWidth.outline
        let settings = UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .standard,
            transparency: .standard,
        )
        let level = sut.level(for: settings)
        #expect(level == .zero)
        #expect(CGFloat(level) == 0)
    }

    /// Checks that differentiation and transparency do not change the outline.
    ///
    /// - Parameter settings: Settings that differ from the standard ones in differentiation
    ///   or transparency.
    @Test(arguments: changedSettings.filter { $0.contrast != .increased })
    func whenDifferentiationOrTransparencyChange_shouldReturnOutlineAtZeroLevel(
        settings: UIDesign.AccessibilitySettings
    ) {
        let sut = BorderWidth.outline
        #expect(sut.level(for: settings) == .zero)
    }
}
