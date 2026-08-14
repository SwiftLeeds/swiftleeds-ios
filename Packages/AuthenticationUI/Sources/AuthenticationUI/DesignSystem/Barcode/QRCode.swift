import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

/// The two-dimensional square code most scanners expect.
package enum QRCode {
    /// The text a QR code carries.
    package struct Payload: ExpressibleByStringLiteral, Equatable, Sendable {
        private let storage: String

        package init(_ value: String) {
            storage = value
        }

        package init(stringLiteral value: String) {
            self.init(value)
        }

        /// The bytes handed to the generator. QR codes carry arbitrary bytes, so any text encodes.
        package var data: Data { Data(storage.utf8) }
    }

    /// How much of a code can be obscured and still read, from `low` to `high`.
    ///
    /// Higher levels survive more damage but need more modules for the same text.
    package enum Correction: String, Sendable, CaseIterable {
        case low = "L"
        case medium = "M"
        case quartile = "Q"
        case high = "H"
    }

    /// Draws QR codes.
    package struct Symbology: BarcodeSymbology {
        private let correction: Correction

        package init(correction: Correction = .high) {
            self.correction = correction
        }

        package func makeImage(encoding payload: Payload) -> CGImage? {
            let filter = CIFilter.qrCodeGenerator()
            filter.message = payload.data
            filter.correctionLevel = correction.rawValue
            guard let output = filter.outputImage else { return nil }
            return BarcodeImage.render(output, addingQuietZoneOf: Self.missingQuietZoneModules)
        }

        /// The generator leaves a one-module margin; the specification asks for four.
        private static let missingQuietZoneModules: CGFloat = 3
    }
}

package extension BarcodeContent {
    /// Content drawn as a QR code.
    ///
    /// - Parameters:
    ///   - payload: The text the code carries.
    ///   - correction: How much damage the code should survive. Defaults to `high`.
    static func qr(_ payload: QRCode.Payload, correction: QRCode.Correction = .high) -> BarcodeContent {
        BarcodeContent(payload, drawnBy: QRCode.Symbology(correction: correction))
    }
}
