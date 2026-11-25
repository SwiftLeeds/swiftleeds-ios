#if os(macOS)
import Foundation
import Testing
import UIDesign
import UIDesignTestSupport
import Vision

struct PDF417BarcodeTests {
    /// The most e-acute characters CoreImage's generator draws in one barcode.
    ///
    /// Measured on CoreImage on 2026-11-24, on macOS 26.6.1 (25G76). Each character is 2 UTF-8 bytes.
    private static let generatorLimit = 517

    /// Made-up text for the code.
    private static let fixtureText = "EXAMPLE PASS 0001"

    /// About two hundred made-up letters, to show the margin does not depend on the message size.
    private static let longText = String(repeating: "ABCDEFGHIJ", count: 20)

    /// The texts the quiet zone is checked on.
    private static let quietZoneTexts = [fixtureText, longText]

    /// The modules of clear quiet zone the PDF417 spec asks for on each side.
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

    /// Returns whether every pixel in a block of the picture is clear.
    ///
    /// - Parameters:
    ///   - pixels: The stored picture.
    ///   - columns: The columns of the block.
    ///   - rows: The rows of the block.
    /// - Returns: `true` when every pixel in the block is clear.
    private static func isClear(_ pixels: RGBAPixels, columns: Range<Int>, rows: Range<Int>) -> Bool {
        rows.allSatisfy { row in
            columns.allSatisfy { column in pixels.pixel(at: PixelPosition(column: column, row: row)).isClear }
        }
    }

    /// Returns whether any pixel in a block of the picture is opaque black.
    ///
    /// - Parameters:
    ///   - pixels: The stored picture.
    ///   - columns: The columns of the block.
    ///   - rows: The rows of the block.
    /// - Returns: `true` when at least one pixel in the block is opaque black.
    private static func hasBlack(_ pixels: RGBAPixels, columns: Range<Int>, rows: Range<Int>) -> Bool {
        rows.contains { row in
            columns.contains { column in pixels.pixel(at: PixelPosition(column: column, row: row)).isOpaqueBlack }
        }
    }

    @Test(arguments: quietZoneTexts)
    func whenTextIsEncoded_shouldHaveTwoClearModulesEachSide(text: String) throws {
        let sut = try PDF417Barcode(text)
        let pixels = try RGBAPixels(of: sut.cgImage)
        let zone = Self.quietZoneModules * Self.storedPixelsPerModule
        let moduleSpan = Self.storedPixelsPerModule
        let width = pixels.width
        let height = pixels.height
        #expect(width.isMultiple(of: moduleSpan), "The picture is not at ten pixels for each module")
        let allColumns = 0..<width
        let allRows = 0..<height
        #expect(Self.isClear(pixels, columns: 0..<zone, rows: allRows), "The left zone is not clear")
        #expect(Self.isClear(pixels, columns: (width - zone)..<width, rows: allRows), "The right zone is not clear")
        #expect(Self.isClear(pixels, columns: allColumns, rows: 0..<zone), "The top zone is not clear")
        #expect(Self.isClear(pixels, columns: allColumns, rows: (height - zone)..<height), "The bottom is not clear")
        let innerLeft = zone..<(zone + moduleSpan)
        let innerRight = (width - zone - moduleSpan)..<(width - zone)
        let innerTop = zone..<(zone + moduleSpan)
        let innerBottom = (height - zone - moduleSpan)..<(height - zone)
        #expect(Self.hasBlack(pixels, columns: innerLeft, rows: allRows), "No bar just inside the left zone")
        #expect(Self.hasBlack(pixels, columns: innerRight, rows: allRows), "No bar just inside the right zone")
        #expect(Self.hasBlack(pixels, columns: allColumns, rows: innerTop), "No bar just inside the top zone")
        #expect(Self.hasBlack(pixels, columns: allColumns, rows: innerBottom), "No bar just inside the bottom zone")
    }

    @Test
    func whenTextIsEmpty_shouldThrowEmpty() {
        #expect(throws: PDF417Barcode.ParsingError.empty) { try PDF417Barcode("") }
    }

    @Test
    func whenTextIsAtGeneratorLimit_shouldEncode() throws {
        let sut = try PDF417Barcode(Self.accentedText(count: Self.generatorLimit))
        #expect(sut.cgImage.width > 0)
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
