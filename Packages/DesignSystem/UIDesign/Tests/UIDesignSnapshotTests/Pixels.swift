#if os(iOS) || os(watchOS)
import CoreGraphics
import SwiftUI
import Testing

/// The pixels of a rendered image, read as 8-bit sRGB.
struct Pixels: Equatable, Hashable, Sendable {
    /// A color channel, numbered by its place in a pixel's bytes.
    private enum Channel: Int {
        /// The red channel.
        case red = 0
        /// The green channel.
        case green = 1
        /// The blue channel.
        case blue = 2
    }

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
    /// - Parameters:
    ///   - image: The image to read.
    ///   - scale: The number of pixels in one point of the image.
    /// - Throws: When the image has no bitmap, or the context cannot be made.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the image.
    init(of image: CGImage, scale: CGFloat) throws {
        let context = try Self.context(width: image.width, height: image.height)
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let data = try #require(context.data)
        let count = image.width * image.height * Self.channels
        width = image.width
        bytes = Array(UnsafeBufferPointer(start: data.assumingMemoryBound(to: UInt8.self), count: count))
        self.scale = scale
    }

    /// Returns the color of the pixel at a point.
    ///
    /// - Parameter point: The point in the image, in points from the top leading corner.
    /// - Returns: The color of the pixel that covers the point.
    /// - Precondition: The point must lie inside the image.
    func color(at point: CGPoint) -> Color.Resolved {
        color(x: Int(point.x * scale), y: Int(point.y * scale))
    }

    /// Returns the color of every pixel in a rectangle.
    ///
    /// - Parameter rect: The rectangle in the image, in points.
    /// - Returns: One color for each pixel the rectangle covers.
    /// - Precondition: The rectangle must lie inside the image.
    /// - Complexity: O(*n*), where *n* is the number of pixels the rectangle covers.
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
    /// - Precondition: The column and row must lie inside the image.
    private func color(x: Int, y: Int) -> Color.Resolved {
        let index = (y * width + x) * Self.channels
        return Color(
            .sRGB,
            red: value(of: .red, at: index),
            green: value(of: .green, at: index),
            blue: value(of: .blue, at: index),
        ).resolve(in: EnvironmentValues())
    }

    /// Returns one channel of one pixel as a fraction.
    ///
    /// - Parameters:
    ///   - channel: The channel to read.
    ///   - index: The index of the pixel's first byte.
    /// - Returns: The channel, from 0 to 1.
    /// - Precondition: The pixel's bytes must lie inside the image.
    private func value(of channel: Channel, at index: Int) -> Double {
        Double(bytes[index + channel.rawValue]) / Self.largestChannel
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
#endif
