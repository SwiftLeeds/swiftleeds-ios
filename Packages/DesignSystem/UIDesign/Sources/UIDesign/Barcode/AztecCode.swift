#if canImport(CoreImage)
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

/// An Aztec code that carries a line of text, drawn as a square with a bullseye in the middle.
///
/// Draw it with ``Barcode``. The picture includes the code's quiet zone. Each module is a whole
/// number of pixels, so the view can scale it up without blurring the edges.
///
/// ```swift
/// let code = try AztecCode("LOCKER-0042")
/// Barcode(code, label: Text("Locker code"))
///     .frame(width: 220, height: 220)
/// ```
public struct AztecCode: BarcodeContent {
    /// The reason text does not become an Aztec code.
    public enum ParsingError: Error, Equatable, Sendable {
        /// The text is empty.
        case empty

        /// The text is longer than one code holds.
        case tooLong

        /// CoreImage drew nothing. No known input causes it.
        case notDrawn

        /// Creates the reason text fails, from the reason its bytes failed.
        ///
        /// - Parameter error: The reason bytes do not become an Aztec code.
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

    /// The reason bytes do not become an Aztec code.
    public enum ValidationError: Error, Equatable, Sendable {
        /// The message is empty.
        case empty

        /// The message is longer than one code holds.
        case tooLong

        /// CoreImage drew nothing. No known input causes it.
        case notDrawn
    }

    /// The clear border the picture keeps, so a rounded plate never cuts a mark.
    private static let requiredQuietZone = BarcodeImage.QuietZone(
        modules: 2  // swiftlint:disable:this no_magic_numbers - the picture's own two-module border
    )

    /// The clear margin the generator leaves around the code.
    ///
    /// Measured on CoreImage on macOS 26.6.1 (25G76).
    private static let generatorMargin = BarcodeImage.QuietZone(
        modules: 2  // swiftlint:disable:this no_magic_numbers - measured generator margin
    )

    /// The bytes the code carries.
    private let message: Data

    /// The picture of the code.
    public let cgImage: CGImage

    /// Creates an Aztec code that carries the given text.
    ///
    /// ```swift
    /// let code = try AztecCode("LOCKER-0042")
    /// ```
    ///
    /// - Parameter text: The text the code carries.
    /// - Throws: ``ParsingError/empty`` when `text` is empty.
    ///   ``ParsingError/tooLong`` when the generator cannot fit `text` in one code.
    ///   ``ParsingError/notDrawn`` when CoreImage draws no picture of the generated code.
    public init(_ text: String) throws(ParsingError) {
        do throws(ValidationError) {
            try self.init(Data(text.utf8))
        } catch {
            throw ParsingError(error)
        }
    }

    /// Creates an Aztec code that carries the given bytes.
    ///
    /// ```swift
    /// let code = try AztecCode(Data([0x01, 0x02, 0x03]))
    /// ```
    ///
    /// - Parameter message: The bytes the code carries.
    /// - Throws: ``ValidationError/empty`` when `message` is empty.
    ///   ``ValidationError/tooLong`` when the generator cannot fit `message` in one code.
    ///   ``ValidationError/notDrawn`` when CoreImage draws no picture of the generated code.
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
        let filter = CIFilter.aztecCodeGenerator()
        filter.message = message
        return filter.outputImage
    }

    /// Returns whether two codes carry the same bytes.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.message == rhs.message
    }

    /// Hashes the bytes the code carries.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(message)
    }
}
#endif
