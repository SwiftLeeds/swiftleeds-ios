#if canImport(CoreImage)
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import SwiftUI

/// A QR code that carries a piece of text.
///
/// Draw it with ``Barcode``.
public struct QRCode: Equatable, Hashable, Sendable {
    /// The reason text does not become a code.
    public enum ParsingError: Error, Equatable, Sendable {
        /// The text is empty.
        case empty

        /// The text is longer than a code holds.
        case tooLong

        /// CoreImage drew nothing. No known input causes it.
        case notDrawn
    }

    /// The error correction level the generator uses: the one that survives the most damage.
    private static let correctionLevel = "H"

    /// The most bytes a version 40 code at level H holds in byte mode.
    private static let capacityInBytes = 1_273

    /// The modules the generator leaves out of the quiet zone.
    ///
    /// The QR standard asks for a quiet zone of 4 modules.
    private static let missingQuietZoneModules: CGFloat = 3

    /// The text the code carries.
    private let text: String

    /// The picture of the code.
    fileprivate let image: CGImage

    /// Creates a code that carries the given text.
    ///
    /// ```swift
    /// do {
    ///     let code = try QRCode("ti_ExampleTicket0000000000")
    /// } catch .empty { print("There is no text to encode.") }
    /// ```
    ///
    /// - Parameter text: The text the code carries.
    /// - Throws: ``ParsingError/empty`` when `text` is empty.
    ///   ``ParsingError/tooLong`` when `text` is more than 1273 bytes in UTF-8.
    ///   ``ParsingError/notDrawn`` when CoreImage draws no picture of the text.
    public init(_ text: String) throws(ParsingError) {
        try Self.check(text)
        guard let generated = Self.generate(text) else { throw .notDrawn }
        let marks = Self.blackModulesOnClear(generated)
        guard let image = Self.render(Self.addingQuietZone(to: marks)) else { throw .notDrawn }
        self.text = text
        self.image = image
    }

    /// Checks that text is not empty and fits in a code.
    ///
    /// - Parameter text: The text to check.
    /// - Throws: ``ParsingError/empty`` when `text` is empty.
    ///   ``ParsingError/tooLong`` when `text` is more than the capacity in UTF-8 bytes.
    private static func check(_ text: String) throws(ParsingError) {
        guard !text.isEmpty else { throw .empty }
        guard text.utf8.count <= capacityInBytes else { throw .tooLong }
    }

    /// Returns the generator's picture of text: black modules on white, with a one-module margin.
    ///
    /// - Parameter text: The text to encode.
    /// - Returns: The picture, or `nil` when the generator makes none.
    private static func generate(_ text: String) -> CIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = correctionLevel
        return filter.outputImage
    }

    /// Returns a picture where each dark module is opaque black and everything else is clear.
    ///
    /// - Parameter generated: The generator's black on white picture.
    /// - Returns: The picture with the white turned clear.
    private static func blackModulesOnClear(_ generated: CIImage) -> CIImage {
        let inverted = generated.applyingFilter("CIColorInvert")
        let masked = inverted.applyingFilter("CIMaskToAlpha")
        return masked.applyingFilter(
            "CIColorMatrix",
            parameters: [
                "inputRVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
            ],
        )
    }

    /// Returns a picture with the quiet zone the generator leaves out added around it, clear.
    ///
    /// - Parameter marks: The picture to extend.
    /// - Returns: The picture with a clear border on every side.
    private static func addingQuietZone(to marks: CIImage) -> CIImage {
        let extended = marks.extent.insetBy(dx: -missingQuietZoneModules, dy: -missingQuietZoneModules)
        return marks.composited(over: CIImage(color: .clear).cropped(to: extended))
    }

    /// Returns a picture as an image with alpha, one pixel for each module.
    ///
    /// - Parameter picture: The picture to render.
    /// - Returns: The image, or `nil` when CoreImage draws none.
    private static func render(_ picture: CIImage) -> CGImage? {
        CIContext().createCGImage(picture, from: picture.extent)
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
    /// ```swift
    /// Image(code, label: Text("Ticket QR code"))
    /// ```
    ///
    /// - Parameters:
    ///   - code: The code to draw.
    ///   - label: The label VoiceOver reads for the image.
    package init(_ code: QRCode, label: Text) {
        self.init(code.image, scale: 1, label: label)
    }
}
#endif
