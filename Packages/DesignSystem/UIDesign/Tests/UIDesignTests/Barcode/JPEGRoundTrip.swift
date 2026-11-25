#if canImport(CoreImage)
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Saves a picture as a JPEG and reads it back, like a code fetched from a server.
enum JPEGRoundTrip {
    /// The reason a picture could not make the round trip.
    enum RoundTripError: Error, Equatable {
        /// A step of the round trip made nothing.
        case notDrawn
    }

    /// The number of bytes in one pixel: red, green, blue and alpha.
    private static let bytesPerPixel = 4

    /// The number of bits in one channel.
    private static let bitsPerChannel = 8

    /// Returns a picture drawn over opaque white, because a JPEG has no alpha.
    ///
    /// - Parameter picture: The picture to draw.
    /// - Returns: The picture on white.
    /// - Throws: ``RoundTripError/notDrawn`` when CoreGraphics makes no picture.
    private static func onWhite(_ picture: CGImage) throws(RoundTripError) -> CGImage {
        guard
            let context = CGContext(
                data: nil,
                width: picture.width,
                height: picture.height,
                bitsPerComponent: bitsPerChannel,
                bytesPerRow: picture.width * bytesPerPixel,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue,
            )
        else { throw .notDrawn }
        let frame = CGRect(x: 0, y: 0, width: picture.width, height: picture.height)
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(frame)
        context.draw(picture, in: frame)
        guard let result = context.makeImage() else { throw .notDrawn }
        return result
    }

    /// Returns a picture after it is saved as a JPEG and read back.
    ///
    /// - Parameters:
    ///   - picture: The picture to save. Clear pixels become white.
    ///   - quality: The JPEG quality, from 0 (smallest file) to 1 (best picture).
    /// - Returns: The picture as the JPEG decoder gives it back.
    /// - Throws: ``RoundTripError/notDrawn`` when a step makes nothing.
    static func image(_ picture: CGImage, quality: Double) throws(RoundTripError) -> CGImage {
        let data = NSMutableData()
        guard
            let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)
        else {
            throw .notDrawn
        }
        let options = [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary
        CGImageDestinationAddImage(destination, try onWhite(picture), options)
        guard CGImageDestinationFinalize(destination),
            let source = CGImageSourceCreateWithData(data, nil),
            let decoded = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { throw .notDrawn }
        return decoded
    }
}
#endif
