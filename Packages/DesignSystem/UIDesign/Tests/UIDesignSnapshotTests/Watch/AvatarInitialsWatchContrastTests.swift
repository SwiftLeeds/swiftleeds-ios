#if os(watchOS)
import CoreGraphics
import Foundation
import SwiftUI
import Testing
import UIDesign

/// Tests that an avatar's initials reach the text contrast floor on the Watch.
@MainActor
@Suite
struct AvatarInitialsWatchContrastTests {
    /// The number of pixels in one point of a render.
    private static let renderScale: CGFloat = 2

    /// A made-up person whose initials are two different letters.
    private static let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")

    /// The side of the avatar in points.
    private static let diameter = CGFloat(AvatarSize.xLarge)

    /// How far below the avatar's top edge the fill is read, clear of the letters and the outline.
    private static let fillDepth: CGFloat = 12

    /// The side in points of the square that holds the letters and nothing else.
    private static let letterBoxSide: CGFloat = 40

    /// The contrast ratio of two identical colors, which a blank render produces.
    private static let identicalRatio: Float = 1

    /// The point on the vertical center line where the fill is read.
    private static var fillPoint: CGPoint {
        CGPoint(x: diameter / 2, y: fillDepth)
    }

    /// The square at the center of the avatar that holds the letters and not the outline.
    private static var letterBox: CGRect {
        let origin = (diameter - letterBoxSide) / 2
        return CGRect(x: origin, y: origin, width: letterBoxSide, height: letterBoxSide)
    }

    /// Checks the initials reach the text floor against the avatar's fill.
    ///
    /// - Throws: When a render hands back no image, or its pixels cannot be read.
    @Test
    func whenInitialsAreOnFill_shouldReachTextFloor() throws {
        let ratio = try Self.lettersRatio(contrast: .standard)

        #expect(ratio >= WCAG.textFloor, "\(WCAG.text(of: ratio)), floor \(WCAG.text(of: WCAG.textFloor))")
    }

    /// Checks Increase Contrast never lowers the initials' ratio.
    ///
    /// - Throws: When a render hands back no image, or its pixels cannot be read.
    @Test
    func whenContrastIsIncreased_shouldNotLowerRatio() throws {
        let standard = try Self.lettersRatio(contrast: .standard)
        let increased = try Self.lettersRatio(contrast: .increased)

        #expect(increased >= standard, "\(WCAG.text(of: increased)) is below \(WCAG.text(of: standard))")
    }

    /// Returns the strongest contrast between any letter pixel and the avatar's fill.
    ///
    /// - Parameter contrast: The contrast to draw under.
    /// - Returns: The ratio, where 1 means the letters cannot be told from the fill.
    /// - Throws: When a render hands back no image, or its pixels cannot be read.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the render.
    private static func lettersRatio(contrast: ColorSchemeContrast) throws -> Float {
        let pixels = try Pixels(of: render(contrast: contrast), scale: renderScale)
        // The fill is translucent, so its real color depends on the surface behind it.
        let fill = pixels.color(at: fillPoint)
        return pixels.colors(in: letterBox)
            .map { WCAG.ratio(between: $0, and: fill) }
            .reduce(identicalRatio, max)
    }

    /// Draws an avatar with initials on the surface and returns the image.
    ///
    /// - Parameter contrast: The contrast to draw under.
    /// - Returns: An image of the avatar, dark, at two pixels to the point.
    /// - Throws: When the render hands back no image.
    private static func render(contrast: ColorSchemeContrast) throws -> CGImage {
        let view = Avatar(url: nil, size: AvatarSize.xLarge, fallback: .initials(name))
            .background(.surface)
            .fixedSize()
            .environment(\.colorScheme, .dark)
            .environment(\._colorSchemeContrast, contrast)
        let renderer = ImageRenderer(content: view)
        renderer.scale = renderScale
        return try #require(renderer.cgImage)
    }
}
#endif
