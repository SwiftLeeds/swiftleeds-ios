#if canImport(CoreGraphics)
import CoreGraphics

/// The pixels of an image with their alpha.
///
/// They are read from an image as 8-bit sRGB, or made from pixels and drawn as an image.
package struct RGBAPixels: Equatable, Hashable, Sendable {
    /// One pixel's channels, each from 0 to 255.
    package struct Pixel: Equatable, Hashable, Sendable {
        /// How far, out of 255, a channel may sit from clear, black or opaque and still count as it.
        private static let tolerance: UInt8 = 8

        /// The red channel of light blue: 0.6 of 255.
        private static let lightBlueRed: UInt8 = 153

        /// The green channel of light blue: 0.8 of 255.
        private static let lightBlueGreen: UInt8 = 204

        /// Opaque black.
        package static let black = Self(red: 0, green: 0, blue: 0, alpha: .max)

        /// Opaque white.
        package static let white = Self(red: .max, green: .max, blue: .max, alpha: .max)

        /// Clear, with no color.
        package static let clear = Self(red: 0, green: 0, blue: 0, alpha: 0)

        /// An opaque light blue: red 0.6, green 0.8 and blue 1.0.
        package static let lightBlue = Self(red: lightBlueRed, green: lightBlueGreen, blue: .max, alpha: .max)

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

        /// Whether the pixel is clear: its alpha is within 8 of 0.
        package var isClear: Bool {
            alpha <= Self.tolerance
        }

        /// Whether the pixel is opaque black.
        ///
        /// Every color channel is within 8 of 0, and alpha is within 8 of 255.
        package var isOpaqueBlack: Bool {
            max(red, green, blue) <= Self.tolerance && alpha >= UInt8.max - Self.tolerance
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
    package enum ReadingError: Error, Equatable, Hashable, Sendable {
        /// The sRGB color space or the bitmap context is not available.
        case noContext

        /// The context holds no bytes.
        case noBytes
    }

    /// The reason an image could not be made from pixels.
    package enum DrawingError: Error, Equatable, Hashable, Sendable {
        /// The number of pixels is not the width times the height.
        case wrongPixelCount

        /// CoreGraphics made no image from the bytes.
        case notDrawn
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

    /// Creates a bitmap of the given size from premultiplied pixels in row order.
    ///
    /// The number of pixels must be the width times the height.
    ///
    /// ```swift
    /// let pixels = try RGBAPixels(width: 2, height: 1, pixels: [.black, .clear])
    /// ```
    ///
    /// - Parameters:
    ///   - width: The width of the image in pixels.
    ///   - height: The height of the image in pixels.
    ///   - pixels: The pixels, one row after another, from the top row.
    /// - Throws: ``DrawingError/wrongPixelCount`` when `pixels` does not hold
    ///   `width` times `height` pixels.
    /// - Complexity: O(*n*), where *n* is the number of pixels.
    package init(width: Int, height: Int, pixels: [Pixel]) throws(DrawingError) {
        guard pixels.count == width * height else { throw .wrongPixelCount }
        self.width = width
        self.height = height
        bytes = pixels.flatMap { pixel in
            [pixel.red, pixel.green, pixel.blue, pixel.alpha]
        }
    }

    /// The pixels drawn as an image.
    ///
    /// - Throws: ``DrawingError/notDrawn`` when CoreGraphics makes no image.
    /// - Complexity: O(*n*), where *n* is the number of pixels.
    package var image: CGImage {
        get throws(DrawingError) {
            guard let data = CFDataCreate(nil, bytes, bytes.count),
                let provider = CGDataProvider(data: data),
                let image = CGImage(
                    width: width,
                    height: height,
                    bitsPerComponent: Self.bitsPerChannel,
                    bitsPerPixel: Self.bitsPerChannel * Self.channels,
                    bytesPerRow: width * Self.channels,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                    provider: provider,
                    decode: nil,
                    shouldInterpolate: false,
                    intent: .defaultIntent,
                )
            else { throw .notDrawn }
            return image
        }
    }

    /// Every column of the image, from the left.
    package var columns: Range<Int> {
        0..<width
    }

    /// Every row of the image, from the top.
    package var rows: Range<Int> {
        0..<height
    }

    /// Returns whether every pixel in an area is clear.
    ///
    /// - Parameters:
    ///   - columns: The columns of the area.
    ///   - rows: The rows of the area.
    /// - Returns: Whether each pixel is ``Pixel/isClear``. An empty area returns `true`.
    /// - Precondition: The area must lie inside the image.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the area.
    package func isClear(columns: Range<Int>, rows: Range<Int>) -> Bool {
        count(columns: columns, rows: rows) { !$0.isClear } == 0
    }

    /// Returns whether any pixel in an area is opaque black.
    ///
    /// - Parameters:
    ///   - columns: The columns of the area.
    ///   - rows: The rows of the area.
    /// - Returns: Whether some pixel is ``Pixel/isOpaqueBlack``.
    /// - Precondition: The area must lie inside the image.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the area.
    package func hasOpaqueBlack(columns: Range<Int>, rows: Range<Int>) -> Bool {
        count(columns: columns, rows: rows) { $0.isOpaqueBlack } > 0
    }

    /// Counts the pixels in an area that match a test.
    ///
    /// - Parameters:
    ///   - columns: The columns of the area.
    ///   - rows: The rows of the area.
    ///   - isMatch: Returns whether a pixel counts.
    /// - Returns: The number of pixels in the area for which `isMatch` returns `true`.
    /// - Precondition: The area must lie inside the image.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the area.
    package func count(columns: Range<Int>, rows: Range<Int>, where isMatch: (Pixel) -> Bool) -> Int {
        columns.reduce(0) { total, column in
            total + rows.count { isMatch(pixel(at: PixelPosition(column: column, row: $0))) }
        }
    }

    /// Returns one pixel.
    ///
    /// - Parameter position: The place of the pixel, from the top left.
    /// - Returns: The pixel's channels.
    /// - Precondition: The position must lie inside the image.
    package func pixel(at position: PixelPosition) -> Pixel {
        let index = (position.row * width + position.column) * Self.channels
        return Pixel(
            red: bytes[index + Channel.red.rawValue],
            green: bytes[index + Channel.green.rawValue],
            blue: bytes[index + Channel.blue.rawValue],
            alpha: bytes[index + Channel.alpha.rawValue],
        )
    }
}
#endif
