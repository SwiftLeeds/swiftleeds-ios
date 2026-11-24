#if canImport(CoreImage)
import CoreGraphics
import Testing

/// The pixels of a rendered picture, read as 8-bit sRGB with alpha.
///
/// A named copy of `Pixels` in the snapshot tests, which compiles on iOS and watchOS only.
struct RenderedPixels {
    /// How far a channel may sit from its expected value.
    ///
    /// A channel runs from 0 to 255.
    private static let channelTolerance = 8

    /// The largest value of one channel.
    private static let largestChannel = 255

    /// The bytes that describe one pixel: red, green, blue and alpha.
    private static let bytesPerPixel = 4

    /// The position of the alpha byte in a pixel, after red, green and blue.
    private static let alphaOffset = 3

    /// The number of bits in one channel.
    private static let bitsPerChannel = 8

    /// The width and height of the picture in pixels.
    let side: Int

    /// The bytes of the picture, one row after another, as red, green, blue and alpha.
    let bytes: [UInt8]

    /// Creates the pixels of a picture by drawing it into an 8-bit sRGB context.
    ///
    /// - Parameter picture: The square picture to read.
    /// - Throws: When the context cannot be made.
    init(of picture: CGImage) throws {
        let space = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let context = try #require(
            CGContext(
                data: nil,
                width: picture.width,
                height: picture.height,
                bitsPerComponent: Self.bitsPerChannel,
                bytesPerRow: picture.width * Self.bytesPerPixel,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue,
            )
        )
        context.draw(picture, in: CGRect(x: 0, y: 0, width: picture.width, height: picture.height))
        let data = try #require(context.data)
        let count = picture.width * picture.height * Self.bytesPerPixel
        side = picture.width
        bytes = Array(UnsafeBufferPointer(start: data.assumingMemoryBound(to: UInt8.self), count: count))
    }

    /// Returns one byte of a pixel.
    ///
    /// - Parameters:
    ///   - offset: The byte in the pixel: 0 red, 1 green, 2 blue, 3 alpha.
    ///   - column: The column of the pixel.
    ///   - row: The row of the pixel.
    /// - Returns: The byte, from 0 to 255.
    private func byte(_ offset: Int, column: Int, row: Int) -> Int {
        Int(bytes[(row * side + column) * Self.bytesPerPixel + offset])
    }

    /// Returns whether a pixel is fully clear.
    ///
    /// - Parameters:
    ///   - column: The column of the pixel.
    ///   - row: The row of the pixel.
    /// - Returns: `true` when its alpha is within the tolerance of 0.
    func isClear(column: Int, row: Int) -> Bool {
        byte(Self.alphaOffset, column: column, row: row) <= Self.channelTolerance
    }

    /// Returns whether a pixel is opaque black.
    ///
    /// - Parameters:
    ///   - column: The column of the pixel.
    ///   - row: The row of the pixel.
    /// - Returns: `true` when each color channel is within the tolerance of 0 and alpha of 255.
    func isOpaqueBlack(column: Int, row: Int) -> Bool {
        let colors = (0..<Self.alphaOffset).allSatisfy {
            byte($0, column: column, row: row) <= Self.channelTolerance
        }
        let alpha = byte(Self.alphaOffset, column: column, row: row)
        return colors && alpha >= Self.largestChannel - Self.channelTolerance
    }
}
#endif
