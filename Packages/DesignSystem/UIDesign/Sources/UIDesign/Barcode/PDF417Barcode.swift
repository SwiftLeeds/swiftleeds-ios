#if canImport(CoreImage)
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

/// A PDF417 barcode that carries a line of text, drawn as wide, stacked rows.
///
/// Draw it with ``Barcode``. The picture includes the code's quiet zone. Each module is a whole
/// number of pixels, so the view can scale it up without blurring the edges.
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

        /// Creates the reason text fails, from the reason its bytes failed.
        ///
        /// - Parameter error: The reason bytes do not become a barcode.
        init(_ error: ValidationError) {
            switch error {
            case .empty:
                self = .empty

            case .tooLong:
                self = .tooLong

            case .notDrawn:
                self = .notDrawn
            }
        }
    }

    /// The reason bytes do not become a barcode.
    public enum ValidationError: Error, Equatable, Sendable {
        /// The message is empty.
        case empty

        /// The message is longer than one barcode holds.
        case tooLong

        /// CoreImage drew nothing. No known input causes it.
        case notDrawn
    }

    /// The quiet zone the PDF417 spec asks for.
    private static let requiredQuietZone = BarcodeImage.QuietZone(
        modules: 2  // swiftlint:disable:this no_magic_numbers - the PDF417 spec's quiet zone
    )

    /// The clear margin the generator leaves around the barcode.
    ///
    /// Measured on CoreImage on macOS 26.6.1 (25G76).
    private static let generatorMargin = BarcodeImage.QuietZone(
        modules: 2  // swiftlint:disable:this no_magic_numbers - measured generator margin
    )

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
        do throws(ValidationError) {
            try self.init(Data(text.utf8))
        } catch {
            throw ParsingError(error)
        }
    }

    /// Creates a barcode that carries the given bytes.
    ///
    /// ```swift
    /// let code = try PDF417Barcode(Data([0x01, 0x02, 0x03]))
    /// ```
    ///
    /// - Parameter message: The bytes the barcode carries.
    /// - Throws: ``ValidationError/empty`` when `message` is empty.
    ///   ``ValidationError/tooLong`` when the generator cannot fit `message` in one barcode.
    ///   ``ValidationError/notDrawn`` when CoreImage draws no picture of the generated barcode.
    public init(_ message: Data) throws(ValidationError) {
        try Self.check(message)
        guard let generated = Self.generate(message) else { throw .tooLong }
        guard
            let image = BarcodeImage.render(
                generated,
                generatorMargin: Self.generatorMargin,
                reaching: Self.requiredQuietZone,
            )
        else {
            throw .notDrawn
        }
        self.message = message
        self.cgImage = image
    }

    /// Checks that a message is not empty.
    ///
    /// - Parameter message: The bytes to check.
    /// - Throws: ``ValidationError/empty`` when `message` is empty.
    private static func check(_ message: Data) throws(ValidationError) {
        guard !message.isEmpty else { throw .empty }
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
