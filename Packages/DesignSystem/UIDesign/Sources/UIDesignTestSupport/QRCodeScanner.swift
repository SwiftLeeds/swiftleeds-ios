#if canImport(CoreImage)
import CoreImage

/// Reads the text of a QR code in an image, as a phone's camera would.
package enum QRCodeScanner {
    /// The reason an image could not be scanned.
    package enum ScanningError: Error, Equatable {
        /// CoreImage makes no QR detector.
        case noDetector
    }

    /// Returns the text of the first QR code in an image.
    ///
    /// ```swift
    /// let text = try QRCodeScanner.payload(in: image)  // "ti_Example", or nil when there is no code
    /// ```
    ///
    /// - Parameter image: The image to scan.
    /// - Returns: The message of the first QR code found, or `nil` when there is none.
    /// - Throws: ``ScanningError/noDetector`` when CoreImage makes no QR detector.
    package static func payload(in image: CGImage) throws(ScanningError) -> String? {
        guard
            let detector = CIDetector(
                ofType: CIDetectorTypeQRCode,
                context: nil,
                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh],
            )
        else { throw .noDetector }
        let features = detector.features(in: CIImage(cgImage: image))
        return features.compactMap { ($0 as? CIQRCodeFeature)?.messageString }.first
    }
}
#endif
