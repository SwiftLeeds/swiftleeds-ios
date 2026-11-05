#if os(iOS) || os(watchOS)
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
        let avatar = Avatar(url: nil, size: AvatarSize.large, fallback: .initials(Self.name))

        let alone = try Self.png(of: avatar, colorScheme: colorScheme)
        let inRed = try Self.png(of: avatar.foregroundStyle(.red), colorScheme: colorScheme)

        #expect(inRed == alone)
    }

    /// Checks a red foreground around a nameplate changes none of its pixels.
    ///
    /// - Parameter colorScheme: The appearance to draw under.
    /// - Throws: When a render hands back no image.
    @Test(arguments: colorSchemes)
    func whenNameplateIsInsideRedForeground_shouldDrawTheSameAsAlone(colorScheme: ColorScheme) throws {
        let nameplate = Nameplate("Ada Archer", detail: "Northern Software") {
            Avatar(url: nil, fallback: .initials(Self.name))
        }

        let alone = try Self.png(of: nameplate, colorScheme: colorScheme)
        let inRed = try Self.png(of: nameplate.foregroundStyle(.red), colorScheme: colorScheme)

        #expect(inRed == alone)
    }

    /// Returns the PNG bytes of a view drawn on a fixed frame.
    ///
    /// - Parameters:
    ///   - view: The view to draw.
    ///   - colorScheme: The appearance to draw under.
    /// - Returns: The bytes of a PNG image at two pixels to the point.
    /// - Throws: When the render hands back no image, or the image cannot be encoded.
    private static func png(of view: some View, colorScheme: ColorScheme) throws -> Data {
        let framed =
            view
            .frame(width: frame.width, height: frame.height)
            .environment(\.colorScheme, colorScheme)
        let renderer = ImageRenderer(content: framed)
        renderer.scale = renderScale
        let image = try #require(renderer.cgImage)
        let data = NSMutableData()
        let destination = try #require(
            CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)
        )
        CGImageDestinationAddImage(destination, image, nil)
        try #require(CGImageDestinationFinalize(destination))
        return data as Data
    }
}
#endif
