import CoreImage
@testable import AuthenticationUI
import Testing

@MainActor
@Suite struct BarcodeSymbologyTests {
    private let slug = "ti_pxqFKr9pPWd6VeYKvMBKpjQ"
    private var payload: QRCode.Payload { QRCode.Payload(slug) }

    @Test func whenEncodingAsQRCode_shouldScanBackAsTheSamePayload() throws {
        let image = try #require(BarcodeContent.qr(payload).makeImage())

        #expect(decode(image) == slug)
    }

    @Test(arguments: QRCode.Correction.allCases)
    func whenEncodingAtAnyCorrectionLevel_shouldScanBackAsTheSamePayload(
        _ correction: QRCode.Correction
    ) throws {
        let image = try #require(BarcodeContent.qr(payload, correction: correction).makeImage())

        #expect(decode(image) == slug)
    }

    @Test func whenEncodingAsQRCode_shouldSurroundCodeWithTheSpecifiedQuietZone() throws {
        let image = try #require(BarcodeContent.qr(payload).makeImage())

        #expect(quietZoneModules(of: image) >= 4)
    }

    @Test func whenEncodingAsCode128_shouldProduceAWiderThanTallCode() throws {
        let image = try #require(BarcodeContent.code128("ABCD-1").makeImage())

        #expect(image.width > image.height)
    }

    @Test func whenPayloadCannotBeEncoded_shouldReturnNil() {
        #expect(BarcodeContent.code128("café-ticket-✓").makeImage() == nil)
    }
}

private extension BarcodeSymbologyTests {
    func decode(_ image: CGImage) -> String? {
        let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: nil,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )
        let features = detector?.features(in: CIImage(cgImage: image)) ?? []
        return features.compactMap { ($0 as? CIQRCodeFeature)?.messageString }.first
    }

    /// The width of the uniform light border, measured in modules. The module size is derived
    /// from the top-left finder pattern, whose top edge is seven modules wide in every QR code.
    func quietZoneModules(of image: CGImage) -> Int {
        guard let pixels = grayscalePixels(of: image) else { return 0 }
        let width = image.width
        let isLight = { (x: Int, y: Int) in pixels[y * width + x] > 127 }

        var border = 0
        while border < image.height, (0..<width).allSatisfy({ isLight($0, border) }) {
            border += 1
        }
        guard border < image.height else { return 0 }

        var start = 0
        while start < width, isLight(start, border) { start += 1 }
        var finder = 0
        while start + finder < width, !isLight(start + finder, border) { finder += 1 }

        let module = finder / 7
        return module > 0 ? border / module : 0
    }

    func grayscalePixels(of image: CGImage) -> [UInt8]? {
        var pixels = [UInt8](repeating: 0, count: image.width * image.height)
        guard let context = CGContext(
            data: &pixels,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: image.width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return pixels
    }
}
