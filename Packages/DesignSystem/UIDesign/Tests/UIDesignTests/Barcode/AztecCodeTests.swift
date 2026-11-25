#if os(macOS)
import Foundation
import Testing
import UIDesign
import UIDesignTestSupport
import Vision

struct AztecCodeTests {
    /// Made-up text for the code.
    private static let fixtureText = BarcodeFixture.aztecCode.text

    /// The most e-acute characters CoreImage's generator draws in one code.
    ///
    /// Measured on CoreImage on 2026-11-24, on macOS 26.6.1 (25G76). Each character is 2 UTF-8 bytes.
    private static let generatorLimit = 959

    /// About two hundred made-up letters, to show the margin does not depend on the message size.
    private static let longText = String(repeating: "ABCDEFGHIJ", count: 20)

    /// The texts the quiet zone is checked on.
    private static let quietZoneTexts = [fixtureText, longText]

    /// The modules of clear quiet zone each side keeps.
    private static let quietZoneModules = 2

    /// The pixels the stored picture spends on each module.
    private static let storedPixelsPerModule = 10

    /// Returns text of e-acute characters, which the generator packs as bytes.
    ///
    /// - Parameter count: The number of characters.
    /// - Returns: The text.
    private static func accentedText(count: Int) -> String {
        String(repeating: "\u{E9}", count: count)
    }

    @Test(arguments: quietZoneTexts)
    func whenTextIsEncoded_shouldHaveTwoClearModulesEachSide(text: String) throws {
        let sut = try AztecCode(text)
        let pixels = try RGBAPixels(of: sut.cgImage)
        let zone = Self.quietZoneModules * Self.storedPixelsPerModule
        let moduleSpan = Self.storedPixelsPerModule
        let width = pixels.width
        let height = pixels.height
        #expect(width.isMultiple(of: moduleSpan), "The picture is not at ten pixels for each module")
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
        #expect(pixels.hasOpaqueBlack(columns: innerLeft, rows: allRows), "No mark just inside the left zone")
        #expect(pixels.hasOpaqueBlack(columns: innerRight, rows: allRows), "No mark just inside the right zone")
        #expect(pixels.hasOpaqueBlack(columns: allColumns, rows: innerTop), "No mark just inside the top zone")
        #expect(pixels.hasOpaqueBlack(columns: allColumns, rows: innerBottom), "No mark just inside the bottom zone")
    }

    @Test
    func whenTextIsEmpty_shouldThrowEmpty() {
        #expect(throws: AztecCode.ParsingError.empty) { try AztecCode("") }
    }

    @Test
    func whenTextIsAtGeneratorLimit_shouldEncode() throws {
        let sut = try AztecCode(Self.accentedText(count: Self.generatorLimit))
        #expect(sut.cgImage.width > 0)
    }

    @Test
    func whenTextIsOneOverGeneratorLimit_shouldThrowTooLong() {
        #expect(throws: AztecCode.ParsingError.tooLong) {
            try AztecCode(Self.accentedText(count: Self.generatorLimit + 1))
        }
    }

    @Test
    func whenBytesMatchText_shouldEqualTextCode() throws {
        let fromBytes = try AztecCode(Data(Self.fixtureText.utf8))
        let fromText = try AztecCode(Self.fixtureText)
        #expect(fromBytes == fromText)
    }

    @Test
    func whenBytesAreEmpty_shouldThrowEmpty() {
        #expect(throws: AztecCode.ValidationError.empty) { try AztecCode(Data()) }
    }

    @Test
    func whenBytesAreOneOverGeneratorLimit_shouldThrowTooLong() {
        let bytes = Data(Self.accentedText(count: Self.generatorLimit + 1).utf8)
        #expect(throws: AztecCode.ValidationError.tooLong) { try AztecCode(bytes) }
    }

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
