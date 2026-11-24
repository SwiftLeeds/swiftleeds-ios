#if canImport(CoreImage)
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

/// A Code 128 barcode that carries a line of ASCII text.
///
/// Draw it with ``Barcode``.
///
/// ```swift
/// let code = try Code128Barcode("ABCD-0001")
/// Barcode(code, label: Text("Parcel barcode"))
///     .frame(width: 320)
/// ```
public struct Code128Barcode: BarcodeContent {
    /// The reason text does not become a barcode.
    public enum ParsingError: Error, Equatable, Sendable {
        /// CoreImage drew nothing. No known input causes it.
        case notDrawn
    }

    /// The modules the generator leaves out of the quiet zone.
    ///
    /// The Code 128 spec asks for a quiet zone of 10 modules, and the generator leaves none.
    private static let missingQuietZone = BarcodeImage.QuietZone(
        modules: 10  // swiftlint:disable:this no_magic_numbers - the spec's 10-module zone, less the generator's 0
    )

    /// The bytes the barcode carries.
    private let message: Data

    /// The picture of the barcode.
    public let cgImage: CGImage

    /// Creates a barcode that carries the given text.
    ///
    /// ```swift
    /// let code = try Code128Barcode("ABCD-0001")
    /// ```
    ///
    /// - Parameter text: The text the barcode carries.
    /// - Throws: ``ParsingError/notDrawn`` when CoreImage draws no picture of the text.
    public init(_ text: String) throws(ParsingError) {
        let message = Data(text.utf8)
        guard let generated = Self.generate(message) else { throw .notDrawn }
        guard let image = BarcodeImage.render(generated, addingQuietZone: Self.missingQuietZone) else {
            throw .notDrawn
        }
        self.message = message
        self.cgImage = image
    }

    /// Returns the generator's picture of a message: black bars on white, with no quiet zone.
    ///
    /// - Parameter message: The bytes to encode.
    /// - Returns: The picture, or `nil` when the generator makes none.
    private static func generate(_ message: Data) -> CIImage? {
        let filter = CIFilter.code128BarcodeGenerator()
        filter.message = message
        filter.quietSpace = 0
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
