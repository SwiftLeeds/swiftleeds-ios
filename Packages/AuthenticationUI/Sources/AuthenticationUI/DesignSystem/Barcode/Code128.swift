import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

/// The one-dimensional barcode used on tickets and shipping labels.
package enum Code128 {
    /// The text a Code 128 barcode carries.
    package struct Payload: ExpressibleByStringLiteral, Equatable, Sendable {
        private let storage: String

        package init(_ value: String) {
            storage = value
        }

        package init(stringLiteral value: String) {
            self.init(value)
        }

        /// Whether this text can be drawn. Code 128 carries 7-bit ASCII only.
        package var isEncodable: Bool {
            !storage.isEmpty && storage.allSatisfy(\.isASCII)
        }

        /// The bytes handed to the generator.
        package var data: Data { Data(storage.utf8) }
    }

    /// Draws Code 128 barcodes.
    package struct Symbology: BarcodeSymbology {
        private let quietSpace: Float

        /// - Parameter quietSpace: The light margin, in multiples of the narrowest bar.
        ///   The specification asks for ten.
        package init(quietSpace: Float = 10) {
            self.quietSpace = quietSpace
        }

        package func makeImage(encoding payload: Payload) -> CGImage? {
            guard payload.isEncodable else { return nil }
            let filter = CIFilter.code128BarcodeGenerator()
            filter.message = payload.data
            filter.quietSpace = quietSpace
            guard let output = filter.outputImage else { return nil }
            return BarcodeImage.render(output, addingQuietZoneOf: 0)
        }
    }
}

package extension BarcodeContent {
    /// Content drawn as a Code 128 barcode.
    ///
    /// - Parameters:
    ///   - payload: The text the barcode carries. Must be 7-bit ASCII.
    ///   - quietSpace: The light margin, in multiples of the narrowest bar. Defaults to ten.
    static func code128(_ payload: Code128.Payload, quietSpace: Float = 10) -> BarcodeContent {
        BarcodeContent(payload, drawnBy: Code128.Symbology(quietSpace: quietSpace))
    }
}
