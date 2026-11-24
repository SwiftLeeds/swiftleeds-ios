#if os(macOS)
import Testing
import UIDesign
import Vision

struct PDF417BarcodeTests {
    /// Made-up text for the code.
    private static let fixtureText = "EXAMPLE PASS 0001"

    @Test
    func whenTextIsEncoded_shouldScanBackAsSameText() throws {
        let sut = try PDF417Barcode(Self.fixtureText)
        let text = BarcodeReader.payload(of: sut.cgImage, as: .pdf417)
        #expect(text == Self.fixtureText)
    }

    @Test
    func whenTextIsEncoded_shouldBeWiderThanTall() throws {
        let sut = try PDF417Barcode(Self.fixtureText)
        #expect(sut.cgImage.width > sut.cgImage.height)
    }
}
#endif
