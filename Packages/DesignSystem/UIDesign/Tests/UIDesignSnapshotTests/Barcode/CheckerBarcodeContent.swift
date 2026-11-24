#if os(iOS)
import CoreGraphics
import Foundation
import UIDesign

/// A made-up barcode content of two by two modules, dark on one diagonal, for the barcode suites.
struct CheckerBarcodeContent: BarcodeContent {
    /// The reason the picture could not be made.
    enum DrawingError: Error, Equatable {
        /// CoreGraphics made no picture from the bytes.
        case notDrawn
    }

    /// The modules in each row and each column of the picture.
    static let modulesAcross = 2

    /// The number of bytes in one pixel: red, green, blue and alpha.
    private static let bytesPerPixel = 4

    /// The number of bits in one channel.
    private static let bitsPerChannel = 8

    /// The bytes of one opaque black pixel.
    private static let black: [UInt8] = [0, 0, 0, UInt8.max]

    /// The bytes of one clear pixel.
    private static let clear: [UInt8] = [0, 0, 0, 0]

    /// The picture: black at the top left and bottom right, clear elsewhere.
    let cgImage: CGImage

    /// Creates the content.
    ///
    /// - Throws: ``DrawingError/notDrawn`` when CoreGraphics makes no picture.
    init() throws(DrawingError) {
        let bytes = Data(Self.black + Self.clear + Self.clear + Self.black)
        guard let provider = CGDataProvider(data: bytes as CFData),
            let image = CGImage(
                width: Self.modulesAcross,
                height: Self.modulesAcross,
                bitsPerComponent: Self.bitsPerChannel,
                bitsPerPixel: Self.bitsPerChannel * Self.bytesPerPixel,
                bytesPerRow: Self.modulesAcross * Self.bytesPerPixel,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                provider: provider,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent,
            )
        else { throw .notDrawn }
        cgImage = image
    }

    /// Returns whether two contents are equal: every checker is the same picture.
    static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }

    /// Hashes the size, because every checker is the same picture.
    func hash(into hasher: inout Hasher) {
        hasher.combine(Self.modulesAcross)
    }
}
#endif
