#if os(macOS)
import Testing
import UIDesign
import Vision

struct AztecCodeTests {
    /// Made-up text for the code.
    private static let fixtureText = "LOCKER-0042"

    @Test
    func whenTextIsEncoded_shouldScanBackAsSameText() throws {
        let sut = try AztecCode(Self.fixtureText)
        let text = BarcodeReader.payload(of: sut.cgImage, as: .aztec)
        #expect(text == Self.fixtureText)
    }

    @Test
    func whenTextIsEncoded_shouldBeSquare() throws {
        let sut = try AztecCode(Self.fixtureText)
        #expect(sut.cgImage.width == sut.cgImage.height)
    }
}
#endif
