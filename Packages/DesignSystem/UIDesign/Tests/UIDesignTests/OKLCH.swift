import Foundation
import SwiftUI

/// A color as lightness, chroma and hue in the OKLCH color space.
///
/// Equal steps of OKLCH lightness look equal, so a test can compare how light two colors look and
/// how far one leans toward a hue. The conversion is Björn Ottosson's, from linear sRGB.
struct OKLCH {
    /// How light the color looks, from 0 for black to 1 for white.
    let lightness: Double

    /// How colorful the color is, from 0 for a gray.
    let chroma: Double

    /// The hue angle in degrees, from 0 up to 360.
    let hue: Double

    /// The degrees in half a turn of the hue circle.
    private static let halfTurn: Double = 180

    /// The degrees in a full turn of the hue circle.
    private static let fullTurn: Double = 360

    /// Creates the OKLCH form of a resolved color.
    ///
    /// - Parameter color: The color to convert, read through its linear sRGB components.
    init(_ color: Color.Resolved) {
        let red = Double(color.linearRed)
        let green = Double(color.linearGreen)
        let blue = Double(color.linearBlue)
        // swiftlint:disable no_magic_numbers - Ottosson's OKLab matrices, from https://bottosson.github.io/posts/oklab/
        let long = cbrt(0.4122214708 * red + 0.5363325363 * green + 0.0514459929 * blue)
        let medium = cbrt(0.2119034982 * red + 0.6806995451 * green + 0.1073969566 * blue)
        let short = cbrt(0.0883024619 * red + 0.2817188376 * green + 0.6299787005 * blue)
        lightness = 0.2104542553 * long + 0.7936177850 * medium - 0.0040720468 * short
        let greenRed = 1.9779984951 * long - 2.4285922050 * medium + 0.4505937099 * short
        let blueYellow = 0.0259040371 * long + 0.7827717662 * medium - 0.8086757660 * short
        // swiftlint:enable no_magic_numbers
        chroma = hypot(greenRed, blueYellow)
        let degrees = atan2(blueYellow, greenRed) * Self.halfTurn / .pi
        hue = degrees < 0 ? degrees + Self.fullTurn : degrees
    }

    /// Returns the smallest angle between this color's hue and another.
    ///
    /// - Parameter degrees: The hue angle to compare with, in degrees.
    /// - Returns: The angle between the two hues, from 0 up to 180 degrees.
    func hueDistance(to degrees: Double) -> Double {
        let difference = abs(hue - degrees).truncatingRemainder(dividingBy: Self.fullTurn)
        return min(difference, Self.fullTurn - difference)
    }
}
