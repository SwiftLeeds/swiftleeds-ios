#if canImport(CoreImage)
import CoreGraphics
import UIDesign

/// A made-up picture of a QR code in light blue on white, like a code someone saved in a color.
package enum LightBlueCodeImage {
    /// Returns a QR code picture with its dark modules light blue and everything else white.
    ///
    /// The picture has the same pixels across and down as the code's own picture.
    ///
    /// ```swift
    /// let image = try LightBlueCodeImage.make(carrying: "ti_Example")  // light blue modules on white
    /// ```
    ///
    /// - Parameter text: The text the code carries.
    /// - Returns: The recolored picture.
    /// - Throws: When the code, its pixels or the picture cannot be made.
    package static func make(carrying text: String) throws -> CGImage {
        let pixels = try RGBAPixels(of: QRCode(text).cgImage)
        let recolored = pixels.rows.flatMap { row -> [RGBAPixels.Pixel] in
            pixels.columns.map { column in
                pixels.pixel(at: PixelPosition(column: column, row: row)).alpha > 0 ? .lightBlue : .white
            }
        }
        return try RGBAPixels(width: pixels.width, height: pixels.height, pixels: recolored).image
    }
}
#endif
