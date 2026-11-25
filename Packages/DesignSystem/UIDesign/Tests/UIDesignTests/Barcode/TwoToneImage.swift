#if canImport(CoreImage)
import CoreGraphics
import UIDesignTestSupport

/// Makes small made-up pictures with a mark color on the left half and a background on the right.
enum TwoToneImage {
    /// The width and height of a two-tone picture, in pixels.
    static let side = 8

    /// The number of parts a picture is split into across its width: the mark and the background.
    private static let halves = 2

    /// The columns of the mark, on the left half of the picture.
    static let markColumns = 0..<(side / halves)

    /// The columns of the background, on the right half of the picture.
    static let backgroundColumns = (side / halves)..<side

    /// The rows of a pixel's position that step the noise pattern.
    private static let noiseRowStep = 3

    /// Returns a picture with the mark on its left half and the background on its right half.
    ///
    /// - Parameters:
    ///   - mark: The color of the left half.
    ///   - background: The color of the right half.
    ///   - noise: The most each color channel moves, from 0 to 255. Mark channels rise and
    ///     background channels fall, by a fixed pattern. The default is no noise.
    /// - Returns: A picture of ``side`` pixels across and down.
    /// - Throws: ``RGBAPixels/DrawingError/notDrawn`` when CoreGraphics makes no picture.
    static func image(
        mark: RGBAPixels.Pixel,
        background: RGBAPixels.Pixel,
        noise: Int = 0,
    ) throws(RGBAPixels.DrawingError) -> CGImage {
        let pixels = (0..<side).flatMap { row -> [RGBAPixels.Pixel] in
            (0..<side).map { column in
                let isMark = markColumns.contains(column)
                let shift = (column + noiseRowStep * row) % (noise + 1)
                return pixel(isMark ? mark : background, shifted: isMark ? shift : -shift)
            }
        }
        return try RGBAPixels(width: side, height: side, pixels: pixels).image
    }

    /// Returns a pixel with its color channels moved.
    ///
    /// - Parameters:
    ///   - color: The color to start from.
    ///   - shift: The amount to add to each color channel. A negative amount lowers them.
    /// - Returns: The pixel, with the color channels held between 0 and 255 and no change to a clear pixel.
    private static func pixel(_ color: RGBAPixels.Pixel, shifted shift: Int) -> RGBAPixels.Pixel {
        let applied = color.alpha == 0 ? 0 : shift
        return RGBAPixels.Pixel(
            red: moved(color.red, by: applied),
            green: moved(color.green, by: applied),
            blue: moved(color.blue, by: applied),
            alpha: color.alpha,
        )
    }

    /// Returns a color channel moved by an amount.
    ///
    /// - Parameters:
    ///   - channel: The channel to start from.
    ///   - amount: The amount to add. A negative amount lowers the channel.
    /// - Returns: The channel, held between 0 and 255.
    private static func moved(_ channel: UInt8, by amount: Int) -> UInt8 {
        UInt8(max(0, min(Int(UInt8.max), Int(channel) + amount)))
    }
}
#endif
