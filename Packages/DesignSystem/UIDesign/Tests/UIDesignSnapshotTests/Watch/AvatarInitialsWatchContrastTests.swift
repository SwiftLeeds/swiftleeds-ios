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
    /// One pixel of a render, read as 8-bit sRGB.
    private struct Pixel: Equatable, Hashable {
        /// The largest value of one channel.
        private static let largestChannel: Float = 255

        /// The red channel, from 0 to 255.
        let red: UInt8

        /// The green channel, from 0 to 255.
        let green: UInt8

        /// The blue channel, from 0 to 255.
        let blue: UInt8

        /// The pixel as a color the contrast math reads.
        var color: Color.Resolved {
            Color.Resolved(
                colorSpace: .sRGB,
                red: Float(red) / Self.largestChannel,
                green: Float(green) / Self.largestChannel,
                blue: Float(blue) / Self.largestChannel,
            )
        }
    }

    /// The pixels of a rendered image, read as 8-bit sRGB.
    private struct Pixels {
        /// The number of bytes that describe one pixel: red, green, blue and alpha.
        static let channels = 4

        /// The number of bits in one channel.
        static let bitsPerChannel = 8

        /// The width of the image in pixels.
        let width: Int

        /// The height of the image in pixels.
        let height: Int

        /// The bytes of the image, one row after another.
        let bytes: [UInt8]

        /// Creates the pixels of an image by drawing it into an 8-bit sRGB context.
        ///
        /// - Parameter image: The image to read.
        /// - Throws: When the color space or the context cannot be made.
        /// - Complexity: O(*n*), where *n* is the number of pixels in the image.
        init(of image: CGImage) throws {
            let space = try #require(CGColorSpace(name: CGColorSpace.sRGB))
            let context = try #require(
                CGContext(
                    data: nil,
                    width: image.width,
                    height: image.height,
                    bitsPerComponent: Self.bitsPerChannel,
                    bytesPerRow: image.width * Self.channels,
                    space: space,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue,
                )
            )
            context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
            let data = try #require(context.data)
            let count = image.width * image.height * Self.channels
            width = image.width
            height = image.height
            bytes = Array(UnsafeBufferPointer(start: data.assumingMemoryBound(to: UInt8.self), count: count))
        }

        /// Returns one pixel of the image.
        ///
        /// - Parameters:
        ///   - column: The column of the pixel.
        ///   - row: The row of the pixel.
        /// - Returns: The pixel at that column and row.
        func pixel(atColumn column: Int, row: Int) -> Pixel {
            let index = (row * width + column) * Self.channels
            return Pixel(red: bytes[index], green: bytes[index + 1], blue: bytes[index + 2])
        }
    }

    /// The columns and rows a disc covers in a render.
    private struct DiscBounds {
        /// The columns from the disc's left edge to its right edge.
        let columns: ClosedRange<Int>

        /// The rows from the disc's top edge to its bottom edge.
        let rows: ClosedRange<Int>

        /// Creates bounds from the columns and rows they cover.
        ///
        /// - Parameters:
        ///   - columns: The columns the disc covers.
        ///   - rows: The rows the disc covers.
        init(columns: ClosedRange<Int>, rows: ClosedRange<Int>) {
            self.columns = columns
            self.rows = rows
        }

        /// Creates the bounds of every pixel that differs from the background.
        ///
        /// - Parameters:
        ///   - pixels: The render to read.
        ///   - background: The pixel the surface draws.
        /// - Complexity: O(*n*), where *n* is the number of pixels in the render.
        ///
        /// Returns `nil` when the render holds only background.
        init?(of pixels: Pixels, excluding background: Pixel) {
            let allColumns = Array(0..<pixels.width)
            let allRows = Array(0..<pixels.height)
            let columns = allColumns.filter { column in
                allRows.contains { pixels.pixel(atColumn: column, row: $0) != background }
            }
            let rows = allRows.filter { row in
                allColumns.contains { pixels.pixel(atColumn: $0, row: row) != background }
            }
            guard let left = columns.first, let right = columns.last,
                let top = rows.first, let bottom = rows.last
            else { return nil }
            self.init(columns: left...right, rows: top...bottom)
        }

        /// Returns the bounds of the middle of the disc.
        ///
        /// - Parameter share: The fraction of each side to keep, from 0 to 1.
        /// - Returns: The bounds, centered on the same point and smaller on each side.
        func central(share: Double) -> Self {
            Self(columns: Self.shrink(columns, to: share), rows: Self.shrink(rows, to: share))
        }

        /// Returns a range cut equally at both ends.
        ///
        /// - Parameters:
        ///   - range: The range to cut.
        ///   - share: The fraction of the range to keep.
        /// - Returns: The range, centered on the same point.
        private static func shrink(_ range: ClosedRange<Int>, to share: Double) -> ClosedRange<Int> {
            let margin = Int(Double(range.upperBound - range.lowerBound) * (1 - share) / 2)
            return (range.lowerBound + margin)...(range.upperBound - margin)
        }
    }

    /// The number of pixels in one point of a render.
    private static let renderScale: CGFloat = 2

    /// The share of the disc, from its center, that holds the letters and not its edge.
    private static let centralShare = 0.6

    /// A made-up person whose initials are two different letters.
    private static let name = PersonNameComponents(givenName: "Ada", familyName: "Archer")

    /// Checks the initials reach the text floor against the avatar's fill.
    ///
    /// - Throws: When a render hands back no image, or its pixels cannot be read.
    @Test
    func whenInitialsAreOnFill_shouldReachTextFloor() throws {
        let ratio = try Self.initialsRatio(contrast: .standard)

        #expect(ratio >= WCAG.textFloor, "\(WCAG.text(of: ratio)), floor \(WCAG.text(of: WCAG.textFloor))")
    }

    /// Checks Increase Contrast never lowers the initials' ratio.
    ///
    /// - Throws: When a render hands back no image, or its pixels cannot be read.
    @Test
    func whenContrastIsIncreased_shouldNotLowerRatio() throws {
        let standard = try Self.initialsRatio(contrast: .standard)
        let increased = try Self.initialsRatio(contrast: .increased)

        #expect(increased >= standard, "\(WCAG.text(of: increased)) is below \(WCAG.text(of: standard))")
    }

    /// Returns the contrast between the initials and the disc they sit on.
    ///
    /// - Parameter contrast: The contrast to draw under.
    /// - Returns: The ratio, where 1 means the initials cannot be told from the fill.
    /// - Throws: When a render hands back no image, or its pixels cannot be read.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the render.
    private static func initialsRatio(contrast: ColorSchemeContrast) throws -> Float {
        let pixels = try Pixels(of: render(contrast: contrast))
        let background = pixels.pixel(atColumn: 0, row: 0)
        let fill = try #require(discFill(in: pixels, background: background))
        let initials = try #require(initialsPixel(in: pixels, background: background, fill: fill))
        return WCAG.ratio(between: initials.color, and: fill.color)
    }

    /// Draws an avatar with initials on the surface and returns the image.
    ///
    /// - Parameter contrast: The contrast to draw under.
    /// - Returns: An image of the avatar, dark, at two pixels to the point.
    /// - Throws: When the render hands back no image.
    private static func render(contrast: ColorSchemeContrast) throws -> CGImage {
        let view = Avatar(url: nil, size: AvatarSize.large, fallback: .initials(name))
            .padding(.md)
            .background(.surface)
            .environment(\.colorScheme, .dark)
            .environment(\._colorSchemeContrast, contrast)
        let renderer = ImageRenderer(content: view)
        renderer.scale = renderScale
        return try #require(renderer.cgImage)
    }

    /// Returns the most common pixel that is not the background, which is the disc's fill.
    ///
    /// - Parameters:
    ///   - pixels: The render to read.
    ///   - background: The pixel the surface draws.
    /// - Returns: The pixel, or `nil` when the render holds only background.
    private static func discFill(in pixels: Pixels, background: Pixel) -> Pixel? {
        var counts: [Pixel: Int] = [:]
        for row in 0..<pixels.height {
            for column in 0..<pixels.width {
                let pixel = pixels.pixel(atColumn: column, row: row)
                if pixel != background { counts[pixel, default: 0] += 1 }
            }
        }
        return counts.max { $0.value < $1.value }?.key
    }

    /// Returns the pixel in the middle of the disc that differs most from the fill in luminance.
    ///
    /// - Parameters:
    ///   - pixels: The render to read.
    ///   - background: The pixel the surface draws.
    ///   - fill: The pixel the disc is filled with.
    /// - Returns: The pixel, or `nil` when the render holds only background.
    private static func initialsPixel(in pixels: Pixels, background: Pixel, fill: Pixel) -> Pixel? {
        guard let disc = DiscBounds(of: pixels, excluding: background) else { return nil }
        let central = disc.central(share: centralShare)
        let fillLuminance = WCAG.luminance(of: fill.color)
        let candidates = central.rows.flatMap { row in
            central.columns.map { pixels.pixel(atColumn: $0, row: row) }
        }
        return candidates.max { first, second in
            abs(WCAG.luminance(of: first.color) - fillLuminance)
                < abs(WCAG.luminance(of: second.color) - fillLuminance)
        }
    }
}
#endif
