#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

/// Tests for the ring that ``RingedAvatarStyle`` draws.
@MainActor
@Suite
struct RingedAvatarStyleTests {
    /// Holds the image that a render hands back.
    private final class Capture {
        /// The image, or `nil` until the render finishes.
        var image: UIImage?
    }

    /// The space round the avatar, in points, so a pixel outside its frame is background.
    private static let padding: CGFloat = 20

    /// How far in from the avatar's top edge the middle of the ring's band lies, in points.
    private static let bandDepth: CGFloat = 1.5

    /// How far in from the avatar's top edge a pixel just inside the frame lies, in points.
    private static let justInside: CGFloat = 0.5

    /// How far out from the avatar's top edge a pixel just outside the frame lies, in points.
    private static let justOutside: CGFloat = -1

    /// The largest gap per color component that still counts as the same color.
    private static let tolerance: Float = 0.02

    /// The background the avatar sits on, which no ring or photo uses.
    private static let background = Color(.sRGB, red: 1, green: 0.9, blue: 0.2)

    /// The side of the stand-in photo, larger than any avatar frame.
    private static let photoSide: CGFloat = 200

    /// Draws a ringed avatar over a known background and returns the pixels.
    ///
    /// - Parameters:
    ///   - palette: The palette the ring draws with.
    ///   - appearance: The appearance to draw under.
    /// - Returns: The pixels of the avatar and its padding.
    /// - Throws: When the render hands back no image or its pixels cannot be read.
    private static func render(palette: AvatarRingPalette, appearance: SystemAppearance) throws -> Pixels {
        let view = Avatar(url: nil, size: AvatarSize.xLarge) {
            // Larger than the frame, as a photo that fills it is.
            Color.green.frame(width: photoSide, height: photoSide)
        }
        .avatarStyle(.ringed)
        .avatarRingPalette(palette)
        .padding(padding)
        .background(background)
        .fixedSize()
        let capture = Capture()
        Snapshotting<AnyView, UIImage>.image(traits: appearance.traits)
            .snapshot(AnyView(view))
            .run { capture.image = $0 }
        let image = try #require(capture.image)
        return try Pixels(of: #require(image.cgImage), scale: image.scale)
    }

    /// Returns the color of the pixel at the top center of the avatar's frame.
    ///
    /// - Parameters:
    ///   - pixels: The render of the avatar and its padding.
    ///   - offset: How far in from the avatar's top edge, in points. A negative offset lies outside.
    /// - Returns: The pixel's color.
    private static func color(in pixels: Pixels, offsetFromTopEdge offset: CGFloat) -> Color.Resolved {
        let center = padding + CGFloat(AvatarSize.xLarge) / 2
        return pixels.color(at: CGPoint(x: center, y: padding + offset))
    }

    /// Returns the family's `solid` as the system resolves it under an appearance.
    ///
    /// - Parameters:
    ///   - family: The color family.
    ///   - appearance: The appearance to resolve under.
    /// - Returns: The resolved color.
    private static func solid(of family: ColorFamily, in appearance: SystemAppearance) -> Color.Resolved {
        var environment = EnvironmentValues()
        environment.colorScheme = appearance.isLight ? .light : .dark
        return family.solid.resolve(in: environment)
    }

    /// Returns whether two resolved colors are within the tolerance in every component.
    ///
    /// The expected color is clamped to the sRGB range first, because the render holds sRGB pixels
    /// and a catalog color may lie outside that range.
    ///
    /// - Parameters:
    ///   - color: The color to check.
    ///   - expected: The color to compare with.
    /// - Returns: Whether the red, green and blue components each differ by the tolerance or less.
    private static func isClose(_ color: Color.Resolved, to expected: Color.Resolved) -> Bool {
        abs(color.red - clamped(expected.red)) <= tolerance
            && abs(color.green - clamped(expected.green)) <= tolerance
            && abs(color.blue - clamped(expected.blue)) <= tolerance
    }

    /// Returns a color component limited to the range from 0 to 1.
    ///
    /// - Parameter component: The component to limit.
    /// - Returns: The component, or the nearest end of the range.
    private static func clamped(_ component: Float) -> Float {
        min(max(component, 0), 1)
    }

    @Test(arguments: [SystemAppearance.light, .dark])
    func whenPaletteIsBlue_shouldDrawRingInBlueSolid(appearance: SystemAppearance) throws {
        let pixels = try Self.render(palette: .blue, appearance: appearance)
        let ring = Self.color(in: pixels, offsetFromTopEdge: Self.bandDepth)
        #expect(Self.isClose(ring, to: Self.solid(of: .blue, in: appearance)))
    }

    @Test(arguments: [SystemAppearance.light, .dark])
    func whenPaletteIsTeal_shouldDrawRingInTealSolid(appearance: SystemAppearance) throws {
        let pixels = try Self.render(palette: .teal, appearance: appearance)
        let ring = Self.color(in: pixels, offsetFromTopEdge: Self.bandDepth)
        #expect(Self.isClose(ring, to: Self.solid(of: .teal, in: appearance)))
    }

    @Test(arguments: [SystemAppearance.light, .dark])
    func whenPixelIsJustInsideFrame_shouldBeRingColor(appearance: SystemAppearance) throws {
        let pixels = try Self.render(palette: .blue, appearance: appearance)
        let inside = Self.color(in: pixels, offsetFromTopEdge: Self.justInside)
        #expect(Self.isClose(inside, to: Self.solid(of: .blue, in: appearance)))
    }

    @Test(arguments: [SystemAppearance.light, .dark])
    func whenPixelIsJustOutsideFrame_shouldBeBackground(appearance: SystemAppearance) throws {
        let pixels = try Self.render(palette: .blue, appearance: appearance)
        let outside = Self.color(in: pixels, offsetFromTopEdge: Self.justOutside)
        #expect(Self.isClose(outside, to: Self.background.resolve(in: EnvironmentValues())))
    }
}
#endif
