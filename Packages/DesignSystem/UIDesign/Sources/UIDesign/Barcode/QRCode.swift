#if canImport(CoreImage)
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

/// A QR code that carries a piece of text.
///
/// Draw it with ``Barcode``.
public struct QRCode: BarcodeContent {
    /// The reason text does not become a code.
    public enum ParsingError: Error, Equatable, Sendable {
        /// The text is empty.
        case empty

        /// The text is longer than a code holds at its level.
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

    /// The modules the generator leaves out of the quiet zone.
    ///
    /// The QR standard asks for a quiet zone of 4 modules.
    private static let missingQuietZone = BarcodeImage.QuietZone(
        modules: 3  // swiftlint:disable:this no_magic_numbers - the QR standard's quiet zone, less 1
    )

    /// The text the code carries.
    private let text: String

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
        try Self.check(text, at: errorCorrection)
        guard let generated = Self.generate(text, at: errorCorrection) else { throw .notDrawn }
        guard let image = BarcodeImage.render(generated, addingQuietZone: Self.missingQuietZone) else {
            throw .notDrawn
        }
        self.text = text
        self.errorCorrection = errorCorrection
        self.cgImage = image
    }

    /// Checks that text is not empty and fits in a code at a level.
    ///
    /// - Parameters:
    ///   - text: The text to check.
    ///   - level: The level the code is made at.
    /// - Throws: ``ParsingError/empty`` when `text` is empty.
    ///   ``ParsingError/tooLong`` when `text` is more than the level's capacity in UTF-8 bytes.
    private static func check(_ text: String, at level: ErrorCorrectionLevel) throws(ParsingError) {
        guard !text.isEmpty else { throw .empty }
        guard text.utf8.count <= level.capacityInBytes else { throw .tooLong }
    }

    /// Returns the generator's picture of text: black modules on white, with a one-module margin.
    ///
    /// - Parameters:
    ///   - text: The text to encode.
    ///   - level: The level to make the code at.
    /// - Returns: The picture, or `nil` when the generator makes none.
    private static func generate(_ text: String, at level: ErrorCorrectionLevel) -> CIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = level.generatorLetter
        return filter.outputImage
    }

    /// Returns whether two codes carry the same text at the same level.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.text == rhs.text && lhs.errorCorrection == rhs.errorCorrection
    }

    /// Hashes the text and the level the code carries.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(errorCorrection)
    }
}
#endif
