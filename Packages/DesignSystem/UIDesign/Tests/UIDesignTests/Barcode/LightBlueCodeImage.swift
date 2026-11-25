#if canImport(CoreImage)
import CoreGraphics
import UIDesign

/// A made-up picture of a QR code in light blue on white, like a code someone saved in a color.
enum LightBlueCodeImage {
    /// The number of bytes in one pixel: red, green, blue and alpha.
    private static let bytesPerPixel = 4

    /// The position of the alpha byte in a pixel, after red, green and blue.
    private static let alphaOffset = 3

    /// Returns a QR code picture with its dark modules light blue and everything else white.
    ///
    /// The picture has the same pixels across and down as the code's own picture.
    ///
    /// - Parameter text: The text the code carries.
    /// - Returns: The recolored picture.
    /// - Throws: When the code, its pixels or the picture cannot be made.
    static func make(carrying text: String) throws -> CGImage {
        let pixels = try RenderedPixels(of: QRCode(text).cgImage)
        let bytes = stride(from: 0, to: pixels.bytes.count, by: bytesPerPixel).flatMap { start in
            let isMark = pixels.bytes[start + alphaOffset] > 0
            let shade = isMark ? TwoToneImage.Shade.lightBlue : TwoToneImage.Shade.white
            return [shade.red, shade.green, shade.blue, shade.alpha]
        }
        return try TwoToneImage.image(width: pixels.side, height: pixels.side, bytes: bytes)
    }
}
#endif
