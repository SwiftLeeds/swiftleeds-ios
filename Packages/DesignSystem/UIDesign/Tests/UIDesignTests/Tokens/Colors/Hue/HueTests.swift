import SwiftUI
import Testing
import UIDesign

/// Tests for the tonal ramp of every ``Hue``.
struct HueTests {
    /// The weight of linear red in relative luminance, from Rec. 709.
    private static let redWeight: Float = 0.2126
    /// The weight of linear green in relative luminance, from Rec. 709.
    private static let greenWeight: Float = 0.7152
    /// The weight of linear blue in relative luminance, from Rec. 709.
    private static let blueWeight: Float = 0.0722

    /// Returns how bright a color looks, from 0 for black to 1 for white.
    ///
    /// - Parameter color: The color to measure.
    /// - Returns: The relative luminance of `color`.
    private static func luminance(of color: Color.Resolved) -> Float {
        redWeight * color.linearRed + greenWeight * color.linearGreen + blueWeight * color.linearBlue
    }

    /// Checks that each tone of a hue has more luminance than the tone before it.
    ///
    /// - Parameter hue: The hue to check.
    @Test(arguments: Hue.allCases)
    func whenToneRises_shouldGetLighter(hue: Hue) {
        let tones = Hue.Tone.allCases
        for (darker, lighter) in zip(tones, tones.dropFirst()) {
            let darkerLuminance = Self.luminance(of: hue.tone(darker))
            let lighterLuminance = Self.luminance(of: hue.tone(lighter))
            #expect(
                lighterLuminance > darkerLuminance,
                "\(hue) \(lighter) (\(lighterLuminance)) is not lighter than \(darker) (\(darkerLuminance))",
            )
        }
    }
}
