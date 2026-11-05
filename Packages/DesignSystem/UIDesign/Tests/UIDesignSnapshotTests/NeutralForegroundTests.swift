#if os(iOS) || os(watchOS)
import CoreGraphics
import Foundation
import ImageIO
import SwiftUI
import Testing
import UIDesign
import UniformTypeIdentifiers

/// Tests that a surrounding foreground style cannot color an avatar or a nameplate.
@MainActor
@Suite
struct NeutralForegroundTests {
    /// The number of pixels in one point of a render.
    private static let renderScale: CGFloat = 2

    /// The size in points of the frame every render uses.
    private static let frame = CGSize(width: 320, height: 120)

    /// How much more of its own channel a pixel needs than of the other two to count as red or green.
    private static let colorMargin: Float = 0.2

    /// A made-up person whose initials are two different letters.
    private static let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")

    /// The appearances to draw under: both on iOS, and the only one the Watch has.
    nonisolated private static var colorSchemes: [ColorScheme] {
        #if os(watchOS)
        [.dark]
        #else
        [.light, .dark]
        #endif
    }

    /// Checks a red foreground around an avatar changes none of its pixels.
    ///
    /// - Parameter colorScheme: The appearance to draw under.
    /// - Throws: When a render hands back no image.
    @Test(arguments: colorSchemes)
    func whenAvatarIsInsideRedForeground_shouldDrawTheSameAsAlone(colorScheme: ColorScheme) throws {
        let sut = Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.name))

        let alone = try Self.png(of: sut, colorScheme: colorScheme)
        let inRed = try Self.png(of: sut.foregroundStyle(.red), colorScheme: colorScheme)

        #expect(inRed == alone)
    }

    /// Checks a red foreground around a nameplate changes none of its pixels.
    ///
    /// - Parameter colorScheme: The appearance to draw under.
    /// - Throws: When a render hands back no image.
    @Test(arguments: colorSchemes)
    func whenNameplateIsInsideRedForeground_shouldDrawTheSameAsAlone(colorScheme: ColorScheme) throws {
        let sut = Nameplate("Ada Archer", detail: "Northern Software") {
            Avatar(url: nil, fallback: .initials(Self.name))
        }

        let alone = try Self.png(of: sut, colorScheme: colorScheme)
        let inRed = try Self.png(of: sut.foregroundStyle(.red), colorScheme: colorScheme)

        #expect(inRed == alone)
    }

    /// Checks an icon styled inside the nameplate's builder draws in that style.
    ///
    /// - Parameter colorScheme: The appearance to draw under.
    /// - Throws: When a render hands back no image, or its pixels cannot be read.
    @Test(arguments: colorSchemes)
    func whenNameplateIconIsStyledGreen_shouldDrawGreenPixels(colorScheme: ColorScheme) throws {
        let sut = Nameplate("Ada Archer", detail: "Northern Software") {
            Image(systemName: "star.fill").foregroundStyle(.green)
        }
        let unstyled = Nameplate("Ada Archer", detail: "Northern Software") {
            Image(systemName: "star.fill")
        }

        let styledPixels = try Self.pixels(of: sut, colorScheme: colorScheme)
        let unstyledPixels = try Self.pixels(of: unstyled, colorScheme: colorScheme)

        #expect(Self.contains(styledPixels, where: Self.isGreen))
        #expect(!Self.contains(unstyledPixels, where: Self.isGreen))
    }

    #if os(iOS)
    /// Checks a button tinted red leaves no red in an avatar's initials.
    ///
    /// Plain text in the same button shows that the tint draws.
    ///
    /// - Parameter colorScheme: The appearance to draw under.
    /// - Throws: When a render hands back no image, or its pixels cannot be read.
    @Test(arguments: colorSchemes)
    func whenAvatarIsInsideTintedButton_shouldDrawNoRedPixels(colorScheme: ColorScheme) throws {
        let sut = Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.name))
        let text = Text("Ada Archer")

        let avatarPixels = try Self.pixels(of: Self.tintedButton(sut), colorScheme: colorScheme)
        let textPixels = try Self.pixels(of: Self.tintedButton(text), colorScheme: colorScheme)

        #expect(!Self.contains(avatarPixels, where: Self.isRed))
        #expect(Self.contains(textPixels, where: Self.isRed))
    }

    /// Returns a button around a view, tinted red.
    ///
    /// - Parameter label: The view the button shows.
    /// - Returns: A default button whose tint is red.
    private static func tintedButton(_ label: some View) -> some View {
        Button(action: {}, label: { label }).tint(.red)
    }

    /// Returns whether a color has far more red than green and blue.
    ///
    /// - Parameter color: The color to test.
    /// - Returns: `true` when the color is clearly red.
    private static func isRed(_ color: Color.Resolved) -> Bool {
        color.red > color.green + colorMargin && color.red > color.blue + colorMargin
    }
    #endif

    /// Returns whether any pixel of a render matches.
    ///
    /// - Parameters:
    ///   - pixels: The render to read.
    ///   - isMatch: Whether a color is the one to find.
    /// - Returns: `true` when at least one pixel of the frame matches.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the frame.
    private static func contains(_ pixels: Pixels, where isMatch: (Color.Resolved) -> Bool) -> Bool {
        pixels.colors(in: CGRect(origin: .zero, size: frame)).contains(where: isMatch)
    }

    /// Returns whether a color has far more green than red and blue.
    ///
    /// - Parameter color: The color to test.
    /// - Returns: `true` when the color is clearly green.
    private static func isGreen(_ color: Color.Resolved) -> Bool {
        color.green > color.red + colorMargin && color.green > color.blue + colorMargin
    }

    /// Returns the pixels of a view drawn on a fixed frame.
    ///
    /// - Parameters:
    ///   - view: The view to draw.
    ///   - colorScheme: The appearance to draw under.
    /// - Returns: The pixels of the render, at two pixels to the point.
    /// - Throws: When the render hands back no image, or its pixels cannot be read.
    private static func pixels(of view: some View, colorScheme: ColorScheme) throws -> Pixels {
        try Pixels(of: image(of: view, colorScheme: colorScheme), scale: renderScale)
    }

    /// Returns the image of a view drawn on a fixed frame.
    ///
    /// - Parameters:
    ///   - view: The view to draw.
    ///   - colorScheme: The appearance to draw under.
    /// - Returns: The image, at two pixels to the point.
    /// - Throws: When the render hands back no image.
    private static func image(of view: some View, colorScheme: ColorScheme) throws -> CGImage {
        let framed =
            view
            .frame(width: frame.width, height: frame.height)
            .environment(\.colorScheme, colorScheme)
        let renderer = ImageRenderer(content: framed)
        renderer.scale = renderScale
        return try #require(renderer.cgImage)
    }

    /// Returns the PNG bytes of a view drawn on a fixed frame.
    ///
    /// - Parameters:
    ///   - view: The view to draw.
    ///   - colorScheme: The appearance to draw under.
    /// - Returns: The bytes of a PNG image at two pixels to the point.
    /// - Throws: When the render hands back no image, or the image cannot be encoded.
    private static func png(of view: some View, colorScheme: ColorScheme) throws -> Data {
        let rendered = try image(of: view, colorScheme: colorScheme)
        let data = NSMutableData()
        let destination = try #require(
            CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)
        )
        CGImageDestinationAddImage(destination, rendered, nil)
        try #require(CGImageDestinationFinalize(destination))
        return data as Data
    }
}
#endif
