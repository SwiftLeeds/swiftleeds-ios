#if os(iOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

/// Tests that an avatar's initials reach the text contrast floor on every surface.
///
/// It reads the pixels of a real render, because the environment cannot set Increase Contrast.
@MainActor
@Suite
struct AvatarInitialsContrastTests {
    /// A surface an avatar can sit on.
    private enum Surface: CaseIterable {
        /// The main background.
        case surface
        /// Content layered on top of the main background.
        case secondarySurface
        /// Content layered on top of secondary backgrounds.
        case tertiarySurface
        /// The main background of a grouped interface.
        case groupedSurface
        /// Content layered on top of the main background of a grouped interface.
        case secondaryGroupedSurface
        /// Content layered on top of secondary backgrounds of a grouped interface.
        case tertiaryGroupedSurface

        /// The name that failure messages use.
        var name: String {
            switch self {
            case .surface: "surface"
            case .secondarySurface: "secondarySurface"
            case .tertiarySurface: "tertiarySurface"
            case .groupedSurface: "groupedSurface"
            case .secondaryGroupedSurface: "secondaryGroupedSurface"
            case .tertiaryGroupedSurface: "tertiaryGroupedSurface"
            }
        }

        /// The style that draws this surface.
        var style: BrandShapeStyle {
            switch self {
            case .surface: .surface
            case .secondarySurface: .secondarySurface
            case .tertiarySurface: .tertiarySurface
            case .groupedSurface: .groupedSurface
            case .secondaryGroupedSurface: .secondaryGroupedSurface
            case .tertiaryGroupedSurface: .tertiaryGroupedSurface
            }
        }
    }

    /// The pixels of a rendered image, read as 8-bit sRGB.
    private struct Pixels {
        /// The number of bytes that describe one pixel: red, green, blue and alpha.
        static let channels = 4

        /// The number of bits in one channel.
        static let bitsPerChannel = 8

        /// The largest value of one channel.
        static let largestChannel = 255.0

        /// The width of the image in pixels.
        let width: Int

        /// The bytes of the image, one row after another.
        let bytes: [UInt8]

        /// The number of pixels in one point.
        let scale: CGFloat

        /// Creates the pixels of an image by drawing it into an 8-bit sRGB context.
        ///
        /// - Parameter image: The image to read.
        /// - Throws: When the image has no bitmap, or the context cannot be made.
        init(of image: UIImage) throws {
            let cgImage = try #require(image.cgImage)
            let context = try Self.context(width: cgImage.width, height: cgImage.height)
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
            let data = try #require(context.data)
            let count = cgImage.width * cgImage.height * Self.channels
            width = cgImage.width
            bytes = Array(UnsafeBufferPointer(start: data.assumingMemoryBound(to: UInt8.self), count: count))
            scale = image.scale
        }

        /// Returns the color of the pixel at a point.
        ///
        /// - Parameter point: The point in the image, in points from the top leading corner.
        /// - Returns: The color of the pixel that covers the point.
        func color(at point: CGPoint) -> Color.Resolved {
            color(x: Int(point.x * scale), y: Int(point.y * scale))
        }

        /// Returns the color of every pixel in a rectangle.
        ///
        /// - Parameter rect: The rectangle in the image, in points.
        /// - Returns: One color for each pixel the rectangle covers.
        func colors(in rect: CGRect) -> [Color.Resolved] {
            let columns = Int(rect.minX * scale)..<Int(rect.maxX * scale)
            let rows = Int(rect.minY * scale)..<Int(rect.maxY * scale)
            return rows.flatMap { row in columns.map { column in color(x: column, y: row) } }
        }

        /// Returns the color of one pixel.
        ///
        /// - Parameters:
        ///   - x: The column of the pixel.
        ///   - y: The row of the pixel.
        /// - Returns: The color of the pixel.
        private func color(x: Int, y: Int) -> Color.Resolved {
            let index = (y * width + x) * Self.channels
            return Color(
                .sRGB,
                red: Double(bytes[index]) / Self.largestChannel,
                green: Double(bytes[index + 1]) / Self.largestChannel,
                blue: Double(bytes[index + 2]) / Self.largestChannel,
            ).resolve(in: EnvironmentValues())
        }

        /// Returns an 8-bit sRGB context that is ready to draw into.
        ///
        /// - Parameters:
        ///   - width: The width in pixels.
        ///   - height: The height in pixels.
        /// - Returns: A context that holds `width` by `height` pixels.
        /// - Throws: When the sRGB color space or the context is not available.
        private static func context(width: Int, height: Int) throws -> CGContext {
            let space = try #require(CGColorSpace(name: CGColorSpace.sRGB))
            return try #require(
                CGContext(
                    data: nil,
                    width: width,
                    height: height,
                    bitsPerComponent: bitsPerChannel,
                    bytesPerRow: width * channels,
                    space: space,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue,
                )
            )
        }
    }

    /// Holds the image that a render hands back.
    private final class Capture {
        /// The image, or `nil` until the render finishes.
        var image: UIImage?
    }

    /// A made-up person whose initials are two different letters.
    private static let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")

    /// The side of the avatar in points.
    private static let diameter = CGFloat(AvatarSize.xLarge)

    /// How far below the avatar's top edge the fill is read, clear of the letters and the outline.
    private static let fillDepth: CGFloat = 12

    /// The side in points of the square that holds the letters and nothing else.
    private static let letterBoxSide: CGFloat = 40

    /// The seconds a render may take before the test gives up.
    private static let renderTimeout: TimeInterval = 10

    /// The seconds between checks that a render has finished.
    private static let pollInterval: TimeInterval = 0.01

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

    /// Checks the letters reach the text floor in every brand, appearance and surface.
    ///
    /// - Throws: When a render fails or its pixels cannot be read.
    @Test
    func whenInitialsAreDrawnOnEverySurface_shouldReachTheTextFloor() throws {
        for brand in Brand.allCases {
            for appearance in SystemAppearance.allCases {
                for surface in Surface.allCases {
                    try expectFloor(brand: brand, appearance: appearance, surface: surface)
                }
            }
        }
    }

    /// Records a failure when the letters fall below the text floor.
    ///
    /// - Parameters:
    ///   - brand: The brand whose surfaces the avatar sits on.
    ///   - appearance: The appearance to draw under.
    ///   - surface: The surface the avatar sits on.
    /// - Throws: When a render fails or its pixels cannot be read.
    private func expectFloor(brand: Brand, appearance: SystemAppearance, surface: Surface) throws {
        let ratio = try Self.lettersRatio(brand: brand, appearance: appearance, surface: surface)
        let shown = "\(WCAG.text(of: ratio)), floor \(WCAG.text(of: WCAG.textFloor))"
        #expect(ratio >= WCAG.textFloor, "\(brand) \(surface.name) \(appearance.name): \(shown)")
    }

    /// Returns the strongest contrast between any letter pixel and the avatar's fill.
    ///
    /// - Parameters:
    ///   - brand: The brand whose surfaces the avatar sits on.
    ///   - appearance: The appearance to draw under.
    ///   - surface: The surface the avatar sits on.
    /// - Returns: The ratio, where 1 means the letters cannot be told from the fill.
    /// - Throws: When a render fails or its pixels cannot be read.
    private static func lettersRatio(brand: Brand, appearance: SystemAppearance, surface: Surface) throws -> Float {
        let image = try render(brand: brand, appearance: appearance, surface: surface)
        let pixels = try Pixels(of: image)
        let fill = pixels.color(at: fillPoint)
        return pixels.colors(in: letterBox)
            .map { WCAG.ratio(between: $0, and: fill) }
            .reduce(identicalRatio, max)
    }

    /// Draws an avatar with initials on a surface and returns the image.
    ///
    /// - Parameters:
    ///   - brand: The brand whose surfaces the avatar sits on.
    ///   - appearance: The appearance to draw under.
    ///   - surface: The surface the avatar sits on.
    /// - Returns: An image of the avatar, as the system draws it under the appearance.
    /// - Throws: When the render does not finish in time.
    private static func render(brand: Brand, appearance: SystemAppearance, surface: Surface) throws -> UIImage {
        let view = Avatar(url: nil, size: AvatarSize.xLarge, fallback: .initials(name))
            .background(surface.style)
            .environment(\.brand, brand)
            .fixedSize()
        let capture = Capture()
        Snapshotting<AnyView, UIImage>.image(traits: appearance.traits)
            .snapshot(AnyView(view))
            .run { capture.image = $0 }
        waitForImage(in: capture)
        return try #require(capture.image)
    }

    /// Runs the run loop until a render finishes or the timeout passes.
    ///
    /// - Parameter capture: The holder that receives the finished image.
    private static func waitForImage(in capture: Capture) {
        let deadline = Date().addingTimeInterval(renderTimeout)
        while capture.image == nil, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(pollInterval))
        }
    }
}
#endif
