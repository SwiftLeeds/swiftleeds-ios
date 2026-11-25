#if os(macOS)
import Foundation
import Testing
import UIDesign
import UIDesignTestSupport
import Vision

struct PDF417BarcodeTests {
    /// A text and the modules across the picture of its barcode, quiet zone included.
    struct QuietZoneExample: Sendable {
        /// The text the barcode carries.
        let text: String

        /// The modules across the stored picture.
        let modulesAcross: Int
    }

    /// The most e-acute characters CoreImage's generator draws in one barcode.
    ///
    /// Measured on CoreImage on 2026-11-24, on macOS 26.6.1 (25G76). Each character is 2 UTF-8 bytes.
    private static let generatorLimit = 517

    /// Made-up text for the code.
    private static let fixtureText = BarcodeFixture.pdf417Barcode.text

    /// About two hundred made-up letters, to show the margin does not depend on the message size.
    private static let longText = String(repeating: "ABCDEFGHIJ", count: 20)

    /// The modules across the barcode of ``longText``, quiet zone included.
    private static let longTextModules = 175

    /// The texts the quiet zone is checked on, with the modules across each picture.
    private static let quietZoneExamples = [
        QuietZoneExample(text: fixtureText, modulesAcross: BarcodeFixture.pdf417Barcode.modulesAcross),
        QuietZoneExample(text: longText, modulesAcross: longTextModules),
    ]

    /// The modules of clear quiet zone the PDF417 spec asks for on each side.
    private static let quietZoneModules = 2

    /// Returns text of e-acute characters, which the generator packs as bytes.
    ///
    /// - Parameter count: The number of characters.
    /// - Returns: The text.
    private static func accentedText(count: Int) -> String {
        String(repeating: "\u{E9}", count: count)
    }

    @Test(arguments: quietZoneExamples)
    func whenTextIsEncoded_shouldHaveTwoClearModulesEachSide(example: QuietZoneExample) throws {
        let sut = try PDF417Barcode(example.text)
        let pixels = try RGBAPixels(of: sut.cgImage)
        let width = pixels.width
        let height = pixels.height
        let moduleSpan = width / example.modulesAcross
        try #require(width == example.modulesAcross * moduleSpan, "The picture is not whole pixels for each module")
        let zone = Self.quietZoneModules * moduleSpan
        let allColumns = pixels.columns
        let allRows = pixels.rows
        #expect(pixels.isClear(columns: 0..<zone, rows: allRows), "The left zone is not clear")
        #expect(pixels.isClear(columns: (width - zone)..<width, rows: allRows), "The right zone is not clear")
        #expect(pixels.isClear(columns: allColumns, rows: 0..<zone), "The top zone is not clear")
        #expect(pixels.isClear(columns: allColumns, rows: (height - zone)..<height), "The bottom is not clear")
        let innerLeft = zone..<(zone + moduleSpan)
        let innerRight = (width - zone - moduleSpan)..<(width - zone)
        let innerTop = zone..<(zone + moduleSpan)
        let innerBottom = (height - zone - moduleSpan)..<(height - zone)
        #expect(pixels.hasOpaqueBlack(columns: innerLeft, rows: allRows), "No bar just inside the left zone")
        #expect(pixels.hasOpaqueBlack(columns: innerRight, rows: allRows), "No bar just inside the right zone")
        #expect(pixels.hasOpaqueBlack(columns: allColumns, rows: innerTop), "No bar just inside the top zone")
        #expect(pixels.hasOpaqueBlack(columns: allColumns, rows: innerBottom), "No bar just inside the bottom zone")
    }

    @Test
    func whenTextIsEmpty_shouldThrowEmpty() {
        #expect(throws: PDF417Barcode.ParsingError.empty) { try PDF417Barcode("") }
    }

    @Test
    func whenTextIsAtGeneratorLimit_shouldEncode() {
        #expect(throws: Never.self) { try PDF417Barcode(Self.accentedText(count: Self.generatorLimit)) }
    }

    @Test
    func whenTextIsOneOverGeneratorLimit_shouldThrowTooLong() {
        #expect(throws: PDF417Barcode.ParsingError.tooLong) {
            try PDF417Barcode(Self.accentedText(count: Self.generatorLimit + 1))
        }
    }

    @Test
    func whenBytesMatchText_shouldEqualTextCode() throws {
        let fromBytes = try PDF417Barcode(Data(Self.fixtureText.utf8))
        let fromText = try PDF417Barcode(Self.fixtureText)
        #expect(fromBytes == fromText)
    }

    @Test
    func whenBytesAreEmpty_shouldThrowEmpty() {
        #expect(throws: PDF417Barcode.ValidationError.empty) { try PDF417Barcode(Data()) }
    }

    @Test
    func whenBytesAreOneOverGeneratorLimit_shouldThrowTooLong() {
        let bytes = Data(Self.accentedText(count: Self.generatorLimit + 1).utf8)
        #expect(throws: PDF417Barcode.ValidationError.tooLong) { try PDF417Barcode(bytes) }
    }

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
