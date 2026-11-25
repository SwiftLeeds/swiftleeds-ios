#if os(macOS)
import CoreGraphics
import UIDesignTestSupport
import Vision

/// The Vision symbology and the frame height of each code, for the unit tests.
extension BarcodeFixture {
    /// The kind of barcode Vision looks for.
    var symbology: VNBarcodeSymbology {
        switch self {
        case .qrCode: .qr
        case .suppliedLightBlueQRCode: .qr
        case .aztecCode: .aztec
        case .pdf417Barcode: .pdf417
        case .code128Barcode: .code128
        }
    }

    /// The height of the frame the code is drawn in, or `nil` to let the code's shape set it.
    var frameHeight: CGFloat? {
        switch self {
        case .qrCode: frameWidth
        case .suppliedLightBlueQRCode: frameWidth
        case .aztecCode: frameWidth
        case .pdf417Barcode: nil
        case .code128Barcode: nil
        }
    }
}
#endif
