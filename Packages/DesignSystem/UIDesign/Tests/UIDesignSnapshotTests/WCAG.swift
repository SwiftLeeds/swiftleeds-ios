#if os(iOS)
import Foundation
import SwiftUI
import UIKit

/// The Web Content Accessibility Guidelines contrast math that the contrast suites share.
enum WCAG {
    /// The lowest ratio WCAG accepts for text.
    static let textFloor: Float = 4.5

    /// The lowest ratio WCAG accepts for a graphic.
    static let graphicFloor: Float = 3

    /// The weight of linear red in relative luminance, from ITU-R BT.709.
    private static let redWeight: Float = 0.2126

    /// The weight of linear green in relative luminance, from ITU-R BT.709.
    private static let greenWeight: Float = 0.7152

    /// The weight of linear blue in relative luminance, from ITU-R BT.709.
    private static let blueWeight: Float = 0.0722

    /// The light WCAG adds to both colors of a contrast ratio, for glare on the screen.
    private static let glare: Float = 0.05

    /// The decimal places a ratio shows in a failure message.
    private static let shownDecimals = 2

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

    /// Returns how bright a color looks, from 0 for black to 1 for white.
    ///
    /// - Parameter color: The color to measure.
    /// - Returns: The relative luminance of `color`.
    private static func luminance(of color: Color.Resolved) -> Float {
        redWeight * color.linearRed + greenWeight * color.linearGreen + blueWeight * color.linearBlue
    }

    /// Returns the contrast ratio of two colors.
    ///
    /// - Parameters:
    ///   - first: One of the colors.
    ///   - second: The other color. The order does not matter.
    /// - Returns: The ratio, from 1 for identical colors upward.
    static func ratio(between first: Color.Resolved, and second: Color.Resolved) -> Float {
        let firstLuminance = luminance(of: first)
        let secondLuminance = luminance(of: second)
        return (max(firstLuminance, secondLuminance) + glare) / (min(firstLuminance, secondLuminance) + glare)
    }

    /// Returns a ratio as text with two decimals.
    ///
    /// - Parameter ratio: The ratio to show.
    /// - Returns: The text, such as `4.51`.
    static func text(of ratio: Float) -> String {
        ratio.formatted(.number.precision(.fractionLength(shownDecimals)))
    }
}
#endif
