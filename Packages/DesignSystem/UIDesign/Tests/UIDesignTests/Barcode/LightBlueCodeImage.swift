#if canImport(CoreImage)
import CoreGraphics
import UIDesign
import UIDesignTestSupport

/// A made-up picture of a QR code in light blue on white, like a code someone saved in a color.
enum LightBlueCodeImage {
    /// Returns a QR code picture with its dark modules light blue and everything else white.
    ///
    /// The picture has the same pixels across and down as the code's own picture.
    ///
    /// - Parameter text: The text the code carries.
    /// - Returns: The recolored picture.
    /// - Throws: When the code, its pixels or the picture cannot be made.
    static func make(carrying text: String) throws -> CGImage {
        let pixels = try RGBAPixels(of: QRCode(text).cgImage)
        let bytes = pixels.rows.flatMap { row in
            pixels.columns.flatMap { column -> [UInt8] in
                let isMark = pixels.pixel(at: PixelPosition(column: column, row: row)).alpha > 0
                let shade = isMark ? TwoToneImage.Shade.lightBlue : TwoToneImage.Shade.white
                return [shade.red, shade.green, shade.blue, shade.alpha]
            }
        }
        return try TwoToneImage.image(width: pixels.width, height: pixels.height, bytes: bytes)
    }
}
#endif
