#if canImport(CoreImage)
import CoreImage
import SwiftUI
import Testing
import UIDesign

@MainActor
struct QRCodeTests {
    /// The text the code carries.
    private static let fixtureText = "ti_ExampleTicket0000000000"

    /// The side of the square the code is drawn in, in points.
    private static let drawnSide: CGFloat = 220

    /// How many pixels the renderer draws for each point.
    private static let renderScale: CGFloat = 8

    /// Returns the picture of a code on its plate, as a scanner would see it.
    ///
    /// - Parameter code: The code to draw.
    /// - Returns: The rendered picture.
    /// - Throws: When the renderer draws no picture.
    private static func render(_ code: QRCode) throws -> CGImage {
        let content = Image(code, label: Text("Test code"))
            .resizable()
            .interpolation(.none)
            .frame(width: drawnSide, height: drawnSide)
            .background(.scannableSurface)
        let renderer = ImageRenderer(content: content)
        renderer.scale = renderScale
        return try #require(renderer.cgImage)
    }

    /// Returns the text the first QR code in a picture carries.
    ///
    /// - Parameter picture: The picture to scan.
    /// - Returns: The message, or `nil` when no code is found.
    /// - Throws: When CoreImage makes no QR detector.
    private static func scan(_ picture: CGImage) throws -> String? {
        let detector = try #require(
            CIDetector(
                ofType: CIDetectorTypeQRCode,
                context: nil,
                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh],
            )
        )
        let features = detector.features(in: CIImage(cgImage: picture))
        return features.compactMap { ($0 as? CIQRCodeFeature)?.messageString }.first
    }

    @Test
    func whenTextIsEncoded_shouldScanBackAsSameText() throws {
        let code = try QRCode(Self.fixtureText)
        let message = try Self.scan(try Self.render(code))
        #expect(message == Self.fixtureText)
    }
}
#endif
