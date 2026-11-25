#if canImport(CoreImage)
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

/// A QR code that carries a piece of text.
///
/// Draw it with ``Barcode``. The picture includes the code's quiet zone. Each module is a whole
/// number of pixels, so the view can scale it up without blurring the edges.
public struct QRCode: BarcodeContent {
    /// The reason text does not become a code.
    public enum ParsingError: Error, Equatable, Sendable {
        /// The text is empty.
        case empty

        /// The text is longer than a code holds at its level.
        case tooLong

        /// CoreImage drew nothing. No known input causes it.
        case notDrawn

        /// Creates the reason text fails, from the reason its bytes failed.
        ///
        /// - Parameter error: The reason bytes do not become a code.
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

    /// The reason bytes do not become a code.
    public enum ValidationError: Error, Equatable, Sendable {
        /// The message is empty.
        case empty

        /// The message is longer than a code holds at its level.
        case tooLong

        /// CoreImage drew nothing. No known input causes it.
        case notDrawn
    }

    /// How much damage a code survives and still scans.
    ///
    /// A higher level survives more damage and holds less text.
    public enum ErrorCorrectionLevel: Equatable, Hashable, Sendable, CaseIterable {
        /// A level that survives about 7% damage to the code. It holds up to 2953 bytes.
        case low

        /// A level that survives about 15% damage to the code. It holds up to 2331 bytes.
        case medium

        /// A level that survives about 25% damage to the code. It holds up to 1663 bytes.
        case quartile

        /// A level that survives about 30% damage to the code. It holds up to 1273 bytes.
        case high

        /// The letter the generator takes for the level.
        fileprivate var generatorLetter: String {
            switch self {
            case .low:
                "L"

            case .medium:
                "M"

            case .quartile:
                "Q"

            case .high:
                "H"
            }
        }

        /// The most bytes a version 40 code at the level holds in byte mode.
        fileprivate var capacityInBytes: Int {
            // swiftlint:disable no_magic_numbers - the QR standard's version 40 byte capacity
            switch self {
            case .low:
                2_953

            case .medium:
                2_331

            case .quartile:
                1_663

            case .high:
                1_273
            }
            // swiftlint:enable no_magic_numbers
        }
    }

    /// The quiet zone the QR standard asks for.
    private static let requiredQuietZone = BarcodeImage.QuietZone(
        modules: 4  // swiftlint:disable:this no_magic_numbers - the QR standard's quiet zone
    )

    /// The clear margin the generator leaves around the code.
    ///
    /// Measured on CoreImage on macOS 26.6.1 (25G76).
    private static let generatorMargin = BarcodeImage.QuietZone(modules: 1)

    /// The bytes the code carries.
    private let message: Data

    /// The level of error correction the code was made at.
    private let errorCorrection: ErrorCorrectionLevel

    /// The picture of the code.
    public let cgImage: CGImage

    /// Creates a code that carries the given text.
    ///
    /// ```swift
    /// do {
    ///     let code = try QRCode("ex_member_0001", errorCorrection: .quartile)
    /// } catch .empty { print("There is no text to encode.") }
    /// ```
    ///
    /// - Parameters:
    ///   - text: The text the code carries.
    ///   - errorCorrection: How much damage the code survives. The default is ``ErrorCorrectionLevel/high``.
    /// - Throws: ``ParsingError/empty`` when `text` is empty.
    ///   ``ParsingError/tooLong`` when `text` is more bytes in UTF-8 than the level holds.
    ///   ``ParsingError/notDrawn`` when CoreImage draws no picture of the text.
    public init(_ text: String, errorCorrection: ErrorCorrectionLevel = .high) throws(ParsingError) {
        do throws(ValidationError) {
            try self.init(Data(text.utf8), errorCorrection: errorCorrection)
        } catch {
            throw ParsingError(error)
        }
    }

    /// Creates a code that carries the given bytes.
    ///
    /// ```swift
    /// let code = try QRCode(Data([0x01, 0x02, 0x03]), errorCorrection: .medium)
    /// ```
    ///
    /// - Parameters:
    ///   - message: The bytes the code carries.
    ///   - errorCorrection: How much damage the code survives. The default is ``ErrorCorrectionLevel/high``.
    /// - Throws: ``ValidationError/empty`` when `message` is empty.
    ///   ``ValidationError/tooLong`` when `message` is more bytes than the level holds.
    ///   ``ValidationError/notDrawn`` when CoreImage draws no picture of the bytes.
    public init(_ message: Data, errorCorrection: ErrorCorrectionLevel = .high) throws(ValidationError) {
        try Self.check(message, at: errorCorrection)
        guard let generated = Self.generate(message, at: errorCorrection) else { throw .notDrawn }
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
        self.errorCorrection = errorCorrection
        self.cgImage = image
    }

    /// Checks that a message is not empty and fits in a code at a level.
    ///
    /// - Parameters:
    ///   - message: The bytes to check.
    ///   - level: The level the code is made at.
    /// - Throws: ``ValidationError/empty`` when `message` is empty.
    ///   ``ValidationError/tooLong`` when `message` is more bytes than the level holds.
    private static func check(_ message: Data, at level: ErrorCorrectionLevel) throws(ValidationError) {
        guard !message.isEmpty else { throw .empty }
        guard message.count <= level.capacityInBytes else { throw .tooLong }
    }

    /// Returns the generator's picture of a message: black modules on white, with a one-module margin.
    ///
    /// - Parameters:
    ///   - message: The bytes to encode.
    ///   - level: The level to make the code at.
    /// - Returns: The picture, or `nil` when the generator makes none.
    private static func generate(_ message: Data, at level: ErrorCorrectionLevel) -> CIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = message
        filter.correctionLevel = level.generatorLetter
        return filter.outputImage
    }

    /// Returns whether two codes carry the same bytes at the same level.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.message == rhs.message && lhs.errorCorrection == rhs.errorCorrection
    }

    /// Hashes the bytes and the level the code carries.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(message)
        hasher.combine(errorCorrection)
    }
}
#endif
