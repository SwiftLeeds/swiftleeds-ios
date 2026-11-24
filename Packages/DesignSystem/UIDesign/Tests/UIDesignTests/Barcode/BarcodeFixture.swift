#if os(macOS)
import SwiftUI
import UIDesign
import Vision

/// A kind of code the barcode tests draw, with the made-up text it carries.
enum BarcodeFixture: CaseIterable, Sendable {
    /// A QR code.
    case qrCode

    /// An Aztec code.
    case aztec

    /// A PDF417 barcode.
    case pdf417

    /// A Code 128 barcode.
    case code128

    /// The side of a square frame, in points.
    private static let squareSide: CGFloat = 220

    /// The width of a wide frame, in points.
    private static let wideWidth: CGFloat = 320

    /// The made-up text the code carries.
    var text: String {
        switch self {
        case .qrCode: "ti_ExampleTicket0000000000"
        case .aztec: "LOCKER-0042"
        case .pdf417: "EXAMPLE PASS 0001"
        case .code128: "ABCD-0001"
        }
    }

    /// The kind of barcode Vision looks for.
    var symbology: VNBarcodeSymbology {
        switch self {
        case .qrCode: .qr
        case .aztec: .aztec
        case .pdf417: .pdf417
        case .code128: .code128
        }
    }

    /// The width of the frame the code is drawn in, in points.
    var frameWidth: CGFloat {
        switch self {
        case .qrCode: Self.squareSide
        case .aztec: Self.squareSide
        case .pdf417: Self.wideWidth
        case .code128: Self.wideWidth
        }
    }

    /// The height of the frame the code is drawn in, or `nil` to let the code's shape set it.
    var frameHeight: CGFloat? {
        switch self {
        case .qrCode: Self.squareSide
        case .aztec: Self.squareSide
        case .pdf417: nil
        case .code128: nil
        }
    }

    /// Creates the code for this fixture's text.
    ///
    /// - Returns: The code.
    /// - Throws: When the text cannot be encoded.
    func makeContent() throws -> any BarcodeContent {
        switch self {
        case .qrCode: try QRCode(text)
        case .aztec: try AztecCode(text)
        case .pdf417: try PDF417Barcode(text)
        case .code128: try Code128Barcode(text)
        }
    }
}
#endif
