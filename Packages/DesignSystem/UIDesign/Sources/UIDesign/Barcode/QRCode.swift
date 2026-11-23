#if canImport(CoreImage)
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import SwiftUI

/// A QR code that carries a piece of text.
public struct QRCode: Equatable, Hashable, Sendable {
    /// The reason text does not become a code.
    public enum ParsingError: Error, Equatable, Sendable {
        /// CoreImage drew nothing. No known input causes it.
        case notDrawn
    }

    /// The error correction level the generator uses: the one that survives the most damage.
    private static let correctionLevel = "H"

    /// The text the code carries.
    fileprivate let text: String

    /// The picture of the code.
    fileprivate let image: CGImage

    /// Creates a code that carries the given text.
    ///
    /// - Parameter text: The text the code carries.
    /// - Throws: ``ParsingError/notDrawn`` when CoreImage draws no picture of the text.
    public init(_ text: String) throws(ParsingError) {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = Self.correctionLevel
        guard
            let output = filter.outputImage,
            let image = CIContext().createCGImage(output, from: output.extent)
        else { throw .notDrawn }
        self.text = text
        self.image = image
    }

    /// Returns whether two codes carry the same text.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.text == rhs.text
    }

    /// Hashes the text the code carries.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
}

extension Image {
    /// Creates an image that draws a QR code at one pixel for each module.
    ///
    /// - Parameters:
    ///   - code: The code to draw.
    ///   - label: The label VoiceOver reads for the image.
    package init(_ code: QRCode, label: Text) {
        self.init(code.image, scale: 1, label: label)
    }
}
#endif
