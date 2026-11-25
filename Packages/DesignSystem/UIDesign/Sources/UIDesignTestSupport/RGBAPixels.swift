#if canImport(CoreGraphics)
import CoreGraphics

/// The pixels of a rendered image with their alpha, for the barcode suites.
///
/// They are read as 8-bit sRGB.
package struct RGBAPixels: Equatable, Hashable, Sendable {
    /// One pixel's channels, each from 0 to 255.
    package struct Pixel: Equatable, Hashable, Sendable {
        /// The red channel, premultiplied by alpha.
        package let red: UInt8

        /// The green channel, premultiplied by alpha.
        package let green: UInt8

        /// The blue channel, premultiplied by alpha.
        package let blue: UInt8

        /// The alpha channel: 0 is clear and 255 is opaque.
        package let alpha: UInt8

        /// Creates a pixel from its four channels.
        ///
        /// - Parameters:
        ///   - red: The red channel, premultiplied by alpha.
        ///   - green: The green channel, premultiplied by alpha.
        ///   - blue: The blue channel, premultiplied by alpha.
        ///   - alpha: The alpha channel: 0 is clear and 255 is opaque.
        package init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
    }

    /// A channel, numbered by its place in a pixel's bytes.
    private enum Channel: Int {
        /// The red channel.
        case red = 0

        /// The green channel.
        case green = 1

        /// The blue channel.
        case blue = 2

        /// The alpha channel.
        case alpha = 3
    }

    /// The reason an image could not be read.
    package enum ReadingError: Error, Equatable {
        /// The sRGB color space or the bitmap context is not available.
        case noContext

        /// The context holds no bytes.
        case noBytes
    }

    /// The number of bytes that describe one pixel: red, green, blue and alpha.
    private static let channels = 4

    /// The number of bits in one channel.
    private static let bitsPerChannel = 8

    /// The width of the image in pixels.
    package let width: Int

    /// The height of the image in pixels.
    package let height: Int

    /// The bytes of the image, one row after another, from the top row.
    private let bytes: [UInt8]

    /// Creates the pixels of an image by drawing it into an 8-bit sRGB context.
    ///
    /// - Parameter image: The image to read.
    /// - Throws: ``ReadingError/noContext`` when the context cannot be made.
    ///   ``ReadingError/noBytes`` when the context holds no bytes.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the image.
    package init(of image: CGImage) throws(ReadingError) {
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
            let context = CGContext(
                data: nil,
                width: image.width,
                height: image.height,
                bitsPerComponent: Self.bitsPerChannel,
                bytesPerRow: image.width * Self.channels,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue,
            )
        else { throw .noContext }
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        guard let data = context.data else { throw .noBytes }
        let count = image.width * image.height * Self.channels
        width = image.width
        height = image.height
        bytes = Array(UnsafeBufferPointer(start: data.assumingMemoryBound(to: UInt8.self), count: count))
    }

    /// Returns one pixel.
    ///
    /// - Parameters:
    ///   - x: The column of the pixel, from the left.
    ///   - y: The row of the pixel, from the top.
    /// - Returns: The pixel's channels.
    /// - Precondition: The column and row must lie inside the image.
    package func pixel(x: Int, y: Int) -> Pixel {
        let index = (y * width + x) * Self.channels
        return Pixel(
            red: bytes[index + Channel.red.rawValue],
            green: bytes[index + Channel.green.rawValue],
            blue: bytes[index + Channel.blue.rawValue],
            alpha: bytes[index + Channel.alpha.rawValue],
        )
    }
}
#endif
