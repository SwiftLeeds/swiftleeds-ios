import SwiftUI
import Testing
import UIDesign

/// Tests for how each ``Opacity`` role reads the accessibility settings.
struct OpacityTests {
    /// Settings with standard color differentiation that change only the contrast or the
    /// transparency.
    private static let otherSettingsWithColor = [
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

    /// Settings with differentiation without color that also change the contrast or the
    /// transparency.
    private static let otherSettingsWithoutColor = [
        UIDesign.AccessibilitySettings(
            differentiation: .withoutColor,
            contrast: .increased,
            transparency: .standard,
        ),
        UIDesign.AccessibilitySettings(
            differentiation: .withoutColor,
            contrast: .standard,
            transparency: .reduced,
        ),
    ]

    /// Settings with standard contrast that change only the differentiation or the transparency.
    private static let otherSettingsAtStandardContrast = [
        UIDesign.AccessibilitySettings(
            differentiation: .withoutColor,
            contrast: .standard,
            transparency: .standard,
        ),
        UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .standard,
            transparency: .reduced,
        ),
    ]

    /// Settings with increased contrast that change only the differentiation or the transparency.
    private static let otherSettingsAtIncreasedContrast = [
        UIDesign.AccessibilitySettings(
            differentiation: .withoutColor,
            contrast: .increased,
            transparency: .standard,
        ),
        UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .increased,
            transparency: .reduced,
        ),
    ]

    /// Checks that the pattern is faint when people do not need color told apart.
    @Test
    func whenPatternIsResolvedForStandardDifferentiation_shouldReturnEightPercent() {
        let sut = Opacity.pattern
        let settings = UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .standard,
            transparency: .standard,
        )
        let level = sut.level(for: settings)
        #expect(level == .percent8)
        #expect(Double(level) == 0.08)
    }

    /// Checks that the pattern grows stronger when Differentiate Without Color is on.
    @Test
    func whenPatternIsResolvedForDifferentiationWithoutColor_shouldReturnTwentyPercent() {
        let sut = Opacity.pattern
        let settings = UIDesign.AccessibilitySettings(
            differentiation: .withoutColor,
            contrast: .standard,
            transparency: .standard,
        )
        let level = sut.level(for: settings)
        #expect(level == .percent20)
        #expect(Double(level) == 0.2)
    }

    /// Checks that contrast and transparency leave the faint pattern alone.
    ///
    /// - Parameter settings: Settings that differ from the standard ones in one place.
    @Test(arguments: otherSettingsWithColor)
    func whenContrastOrTransparencyChanges_shouldReturnPatternAtEightPercent(
        settings: UIDesign.AccessibilitySettings
    ) {
        let sut = Opacity.pattern
        #expect(sut.level(for: settings) == .percent8)
    }

    /// Checks that contrast and transparency leave the stronger pattern alone.
    ///
    /// - Parameter settings: Settings without color that also change one other setting.
    @Test(arguments: otherSettingsWithoutColor)
    func whenContrastOrTransparencyChangesWithoutColor_shouldReturnPatternAtTwentyPercent(
        settings: UIDesign.AccessibilitySettings
    ) {
        let sut = Opacity.pattern
        #expect(sut.level(for: settings) == .percent20)
    }

    /// Checks that the initials keep their level at standard contrast.
    @Test
    func whenInitialsAreResolvedForStandardContrast_shouldReturnSixtyFourPercent() {
        let sut = Opacity.initials
        let settings = UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .standard,
            transparency: .standard,
        )
        let level = sut.level(for: settings)
        #expect(level == .percent64)
        #expect(Double(level) == 0.64)
    }

    /// Checks that the initials grow stronger when Increase Contrast is on.
    @Test
    func whenInitialsAreResolvedForIncreasedContrast_shouldReturnSeventySixPercent() {
        let sut = Opacity.initials
        let settings = UIDesign.AccessibilitySettings(
            differentiation: .standard,
            contrast: .increased,
            transparency: .standard,
        )
        let level = sut.level(for: settings)
        #expect(level == .percent76)
        #expect(Double(level) == 0.76)
    }

    /// Checks that differentiation and transparency leave the initials alone at standard contrast.
    ///
    /// - Parameter settings: Standard-contrast settings that differ in one other place.
    @Test(arguments: otherSettingsAtStandardContrast)
    func whenDifferentiationOrTransparencyChanges_shouldReturnInitialsAtSixtyFourPercent(
        settings: UIDesign.AccessibilitySettings
    ) {
        let sut = Opacity.initials
        #expect(sut.level(for: settings) == .percent64)
    }

    /// Checks that differentiation and transparency leave the initials alone at increased contrast.
    ///
    /// - Parameter settings: Increased-contrast settings that differ in one other place.
    @Test(arguments: otherSettingsAtIncreasedContrast)
    func whenDifferentiationOrTransparencyChangesWithIncreasedContrast_shouldReturnInitialsAtSeventySixPercent(
        settings: UIDesign.AccessibilitySettings
    ) {
        let sut = Opacity.initials
        #expect(sut.level(for: settings) == .percent76)
    }
}
