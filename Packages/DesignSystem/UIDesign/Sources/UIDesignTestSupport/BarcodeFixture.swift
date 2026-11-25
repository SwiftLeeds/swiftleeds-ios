#if canImport(CoreImage)
import CoreGraphics
import UIDesign

/// A kind of code the barcode tests draw.
///
/// Each kind has made-up text to carry and a frame width to be drawn at.
package enum BarcodeFixture: CaseIterable, Equatable, Hashable, Sendable {
    /// A QR code.
    case qrCode

    /// A QR code supplied as an image, drawn light blue on white.
    case suppliedLightBlueQRCode

    /// An Aztec code.
    case aztecCode

    /// A PDF417 barcode.
    case pdf417Barcode

    /// A Code 128 barcode.
    case code128Barcode

    /// The side of a square frame, in points.
    private static let squareSide: CGFloat = 220

    /// The width of a wide frame, in points.
    private static let wideWidth: CGFloat = 320

    /// The made-up text of a ticket code.
    private static let ticketText = "ti_ExampleTicket0000000000"

    /// The cases that UIDesign generates itself, so the supplied image is left out.
    package static let generated: [Self] = allCases.filter(\.isGenerated)

    /// Whether UIDesign draws this code itself, rather than showing a supplied image.
    private var isGenerated: Bool {
        switch self {
        case .qrCode: true
        case .suppliedLightBlueQRCode: false
        case .aztecCode: true
        case .pdf417Barcode: true
        case .code128Barcode: true
        }
    }

    /// The made-up text the code carries.
    package var text: String {
        switch self {
        case .qrCode: Self.ticketText
        case .suppliedLightBlueQRCode: Self.ticketText
        case .aztecCode: "LOCKER-0042"
        case .pdf417Barcode: "EXAMPLE PASS 0001"
        case .code128Barcode: "ABCD-0001"
        }
    }

    /// The width of the frame the code is drawn in, in points.
    package var frameWidth: CGFloat {
        switch self {
        case .qrCode: Self.squareSide
        case .suppliedLightBlueQRCode: Self.squareSide
        case .aztecCode: Self.squareSide
        case .pdf417Barcode: Self.wideWidth
        case .code128Barcode: Self.wideWidth
        }
    }

    /// The code for this fixture's text.
    ///
    /// - Throws: When the text cannot be encoded, or the supplied image cannot be made.
    package var content: any BarcodeContent {
        get throws {
            switch self {
            case .qrCode: try QRCode(text)
            case .suppliedLightBlueQRCode: try SuppliedBarcodeImage(LightBlueCodeImage.ticket)
            case .aztecCode: try AztecCode(text)
            case .pdf417Barcode: try PDF417Barcode(text)
            case .code128Barcode: try Code128Barcode(text)
            }
        }
    }
}
#endif
