#if canImport(CoreImage)
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

/// A PDF417 barcode that carries a line of text, drawn as wide, stacked rows.
///
/// Draw it with ``Barcode``.
///
/// ```swift
/// let code = try PDF417Barcode("EXAMPLE PASS 0001")
/// Barcode(code, label: Text("Boarding barcode"))
///     .frame(width: 320)
/// ```
public struct PDF417Barcode: BarcodeContent {
    /// The reason text does not become a barcode.
    public enum ParsingError: Error, Equatable, Sendable {
        /// The text is empty.
        case empty

        /// The text is longer than one barcode holds.
        case tooLong

        /// CoreImage drew nothing. No known input causes it.
        case notDrawn
    }

    /// The modules the generator leaves out of the quiet zone.
    ///
    /// The PDF417 spec asks for a quiet zone of 2 modules, and the generator leaves all 2.
    private static let missingQuietZone = BarcodeImage.QuietZone(modules: 0)

    /// The bytes the barcode carries.
    private let message: Data

    /// The picture of the barcode.
    public let cgImage: CGImage

    /// Creates a barcode that carries the given text.
    ///
    /// ```swift
    /// let code = try PDF417Barcode("EXAMPLE PASS 0001")
    /// ```
    ///
    /// - Parameter text: The text the barcode carries.
    /// - Throws: ``ParsingError/empty`` when `text` is empty.
    ///   ``ParsingError/tooLong`` when the generator cannot fit `text` in one barcode.
    ///   ``ParsingError/notDrawn`` when CoreImage draws no picture of the generated barcode.
    public init(_ text: String) throws(ParsingError) {
        try Self.check(text)
        let message = Data(text.utf8)
        guard let generated = Self.generate(message) else { throw .tooLong }
        guard let image = BarcodeImage.render(generated, addingQuietZone: Self.missingQuietZone) else {
            throw .notDrawn
        }
        self.message = message
        self.cgImage = image
    }

    /// Checks that text is not empty.
    ///
    /// - Parameter text: The text to check.
    /// - Throws: ``ParsingError/empty`` when `text` is empty.
    private static func check(_ text: String) throws(ParsingError) {
        guard !text.isEmpty else { throw .empty }
    }

    /// Returns the generator's picture of a message, at the generator's own size and level.
    ///
    /// - Parameter message: The bytes to encode.
    /// - Returns: The picture, or `nil` when the generator makes none.
    private static func generate(_ message: Data) -> CIImage? {
        let filter = CIFilter.pdf417BarcodeGenerator()
        filter.message = message
        return filter.outputImage
    }

    /// Returns whether two barcodes carry the same bytes.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.message == rhs.message
    }

    /// Hashes the bytes the barcode carries.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(message)
    }
}
#endif
