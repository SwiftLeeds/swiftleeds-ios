#if os(iOS)
import CoreGraphics
import Foundation
import UIDesign
import UIDesignTestSupport

/// A made-up picture of a QR code in light blue on white, like a code someone saved in a color.
enum LightBlueCodeImage {
    /// The reason a picture could not be made.
    enum DrawingError: Error, Equatable {
        /// CoreGraphics made no picture from the bytes.
        case notDrawn
    }

    /// The number of bytes in one pixel: red, green, blue and alpha.
    private static let bytesPerPixel = 4

    /// The number of bits in one channel.
    private static let bitsPerChannel = 8

    /// The red channel of light blue: 0.6 of 255.
    private static let lightBlueRed: UInt8 = 153

    /// The green channel of light blue: 0.8 of 255.
    private static let lightBlueGreen: UInt8 = 204

    /// The bytes of an opaque light blue pixel: red 0.6, green 0.8 and blue 1.0.
    private static let lightBlue: [UInt8] = [lightBlueRed, lightBlueGreen, .max, .max]

    /// The bytes of an opaque white pixel.
    private static let white: [UInt8] = [.max, .max, .max, .max]

    /// Returns a QR code picture with its dark modules light blue and everything else white.
    ///
    /// The picture has the same pixels across and down as the code's own picture.
    ///
    /// - Parameter text: The text the code carries.
    /// - Returns: The recolored picture.
    /// - Throws: When the code, its pixels or the picture cannot be made.
    static func make(carrying text: String) throws -> CGImage {
        let source = try QRCode(text).cgImage
        let pixels = try RGBAPixels(of: source)
        let bytes = (0..<pixels.height).flatMap { row -> [UInt8] in
            (0..<pixels.width).flatMap { column -> [UInt8] in
                pixels.pixel(at: PixelPosition(column: column, row: row)).alpha > 0 ? lightBlue : white
            }
        }
        return try image(width: pixels.width, height: pixels.height, bytes: bytes)
    }

    /// Returns a picture from bytes of premultiplied red, green, blue and alpha.
    ///
    /// - Parameters:
    ///   - width: The width in pixels.
    ///   - height: The height in pixels.
    ///   - bytes: The pixels, one row after another.
    /// - Returns: The picture.
    /// - Throws: ``DrawingError/notDrawn`` when CoreGraphics makes no picture.
    private static func image(width: Int, height: Int, bytes: [UInt8]) throws(DrawingError) -> CGImage {
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
}
#endif
