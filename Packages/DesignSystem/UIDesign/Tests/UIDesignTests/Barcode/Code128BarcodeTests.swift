#if os(macOS)
import Testing
import UIDesign
import Vision

struct Code128BarcodeTests {
    /// Made-up text for the code.
    private static let fixtureText = "ABCD-0001"

    @Test
    func whenTextIsEncoded_shouldScanBackAsSameText() throws {
        let sut = try Code128Barcode(Self.fixtureText)
        let text = BarcodeReader.payload(of: sut.cgImage, as: .code128)
        #expect(text == Self.fixtureText)
    }

    @Test
    func whenTextIsEncoded_shouldBeWiderThanTall() throws {
        let sut = try Code128Barcode(Self.fixtureText)
        #expect(sut.cgImage.width > sut.cgImage.height)
    }
}
#endif
