#if canImport(CoreImage)
import CoreGraphics
import Foundation

/// Makes small made-up pictures with a mark color on the left half and a background on the right.
enum TwoToneImage {
    /// The reason a picture could not be made.
    enum DrawingError: Error, Equatable {
        /// CoreGraphics made no picture from the bytes.
        case notDrawn
    }

    /// One color of a picture, as four 8-bit channels.
    ///
    /// A channel is a byte of the picture, which is why each one is a `UInt8`.
    struct Shade: Equatable, Sendable {
        /// The red channel, from 0 to 255.
        let red: UInt8

        /// The green channel, from 0 to 255.
        let green: UInt8

        /// The blue channel, from 0 to 255.
        let blue: UInt8

        /// The alpha channel, from 0 (clear) to 255 (opaque).
        let alpha: UInt8

        /// Opaque black.
        static let black = Self(red: 0, green: 0, blue: 0, alpha: .max)

        /// Opaque white.
        static let white = Self(red: .max, green: .max, blue: .max, alpha: .max)

        /// Clear, with no color.
        static let clear = Self(red: 0, green: 0, blue: 0, alpha: 0)

        /// An opaque light blue: red 0.6, green 0.8 and blue 1.0.
        static let lightBlue = Self(red: lightBlueRed, green: eightTenths, blue: .max, alpha: .max)

        /// An opaque dark grey: 0.3 in every channel.
        static let darkGrey = Self(red: threeTenths, green: threeTenths, blue: threeTenths, alpha: .max)

        /// An opaque light grey: 0.8 in every channel.
        static let lightGrey = Self(red: eightTenths, green: eightTenths, blue: eightTenths, alpha: .max)

        /// The red channel of light blue: 0.6 of 255.
        private static let lightBlueRed: UInt8 = 153

        /// A channel at 0.3 of 255.
        private static let threeTenths: UInt8 = 77

        /// A channel at 0.8 of 255.
        private static let eightTenths: UInt8 = 204
    }

    /// The width and height of a two-tone picture, in pixels.
    static let side = 8

    /// The number of parts a picture is split into across its width: the mark and the background.
    private static let halves = 2

    /// The number of bytes in one pixel: red, green, blue and alpha.
    private static let bytesPerPixel = 4

    /// The number of bits in one channel.
    private static let bitsPerChannel = 8

    /// The rows of a pixel's position that step the noise pattern.
    private static let noiseRowStep = 3

    /// Returns a picture from bytes of premultiplied red, green, blue and alpha.
    ///
    /// - Parameters:
    ///   - width: The width in pixels.
    ///   - height: The height in pixels.
    ///   - bytes: The pixels, one row after another.
    /// - Returns: The picture.
    /// - Throws: ``DrawingError/notDrawn`` when CoreGraphics makes no picture.
    static func image(width: Int, height: Int, bytes: [UInt8]) throws(DrawingError) -> CGImage {
        guard let provider = CGDataProvider(data: Data(bytes) as CFData),
            let image = CGImage(
                width: width,
                height: height,
                bitsPerComponent: bitsPerChannel,
                bitsPerPixel: bitsPerChannel * bytesPerPixel,
                bytesPerRow: width * bytesPerPixel,
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

    /// Returns a picture with the mark on its left half and the background on its right half.
    ///
    /// - Parameters:
    ///   - mark: The color of the left half.
    ///   - background: The color of the right half.
    ///   - noise: The most each color channel moves, from 0 to 255. Mark channels rise and
    ///     background channels fall, by a fixed pattern. The default is no noise.
    /// - Returns: A picture of ``side`` pixels across and down.
    /// - Throws: ``DrawingError/notDrawn`` when CoreGraphics makes no picture.
    static func image(mark: Shade, background: Shade, noise: Int = 0) throws(DrawingError) -> CGImage {
        let bytes = (0..<side).flatMap { row in
            (0..<side).flatMap { column in
                let isMark = column < side / halves
                let shift = (column + noiseRowStep * row) % (noise + 1)
                return pixel(isMark ? mark : background, shifted: isMark ? shift : -shift)
            }
        }
        return try image(width: side, height: side, bytes: bytes)
    }

    /// Returns the bytes of one pixel with its color channels moved.
    ///
    /// - Parameters:
    ///   - shade: The color to start from.
    ///   - shift: The amount to add to each color channel. A negative amount lowers them.
    /// - Returns: The four bytes, with the color channels held between 0 and 255 and no change to a clear pixel.
    private static func pixel(_ shade: Shade, shifted shift: Int) -> [UInt8] {
        let applied = shade.alpha == 0 ? 0 : shift
        let channels = [shade.red, shade.green, shade.blue].map { channel in
            UInt8(max(0, min(Int(UInt8.max), Int(channel) + applied)))
        }
        return channels + [shade.alpha]
    }
}
#endif
