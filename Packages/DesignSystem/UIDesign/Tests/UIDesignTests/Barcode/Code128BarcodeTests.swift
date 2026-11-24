#if os(macOS)
import Testing
import UIDesign
import Vision

struct Code128BarcodeTests {
    /// Made-up text for the code.
    private static let fixtureText = "ABCD-0001"

    /// ASCII text that differs from a non-ASCII fixture only in one letter.
    private static let asciiText = "cafe"

    /// Text whose last letter is not ASCII.
    private static let nonASCIIText = "caf\u{E9}"

    /// Text with two characters that are not ASCII, the first an e with an acute accent.
    private static let twoNonASCIIText = "\u{E9}a \u{FC}"

    /// The modules of clear quiet zone the Code 128 spec asks for on each side.
    private static let quietZoneModules = 10

    /// The pixels the stored picture spends on each module.
    private static let storedPixelsPerModule = 10

    /// Returns whether every pixel in a block of the picture is clear.
    ///
    /// - Parameters:
    ///   - pixels: The stored picture.
    ///   - columns: The columns of the block.
    ///   - rows: The rows of the block.
    /// - Returns: `true` when every pixel in the block is clear.
    private static func isClear(_ pixels: RenderedPixels, columns: Range<Int>, rows: Range<Int>) -> Bool {
        rows.allSatisfy { row in columns.allSatisfy { column in pixels.isClear(column: column, row: row) } }
    }

    /// Returns whether any pixel in a block of the picture is opaque black.
    ///
    /// - Parameters:
    ///   - pixels: The stored picture.
    ///   - columns: The columns of the block.
    ///   - rows: The rows of the block.
    /// - Returns: `true` when at least one pixel in the block is opaque black.
    private static func hasBlack(_ pixels: RenderedPixels, columns: Range<Int>, rows: Range<Int>) -> Bool {
        rows.contains { row in columns.contains { column in pixels.isOpaqueBlack(column: column, row: row) } }
    }

    @Test
    func whenTextIsEncoded_shouldHaveTenClearModulesEachSide() throws {
        let sut = try Code128Barcode(Self.fixtureText)
        let pixels = try RenderedPixels(of: sut.cgImage)
        let zone = Self.quietZoneModules * Self.storedPixelsPerModule
        let width = pixels.side
        let height = sut.cgImage.height
        let allColumns = 0..<width
        let allRows = 0..<height
        let left = 0..<zone
        let right = (width - zone)..<width
        #expect(Self.isClear(pixels, columns: left, rows: allRows), "The left zone is not clear")
        #expect(Self.isClear(pixels, columns: right, rows: allRows), "The right zone is not clear")
        #expect(Self.isClear(pixels, columns: allColumns, rows: 0..<zone), "The top zone is not clear")
        #expect(Self.isClear(pixels, columns: allColumns, rows: (height - zone)..<height), "The bottom is not clear")
        let moduleSpan = Self.storedPixelsPerModule
        let innerLeft = zone..<(zone + moduleSpan)
        let innerRight = (width - zone - moduleSpan)..<(width - zone)
        #expect(Self.hasBlack(pixels, columns: innerLeft, rows: allRows), "No bar starts at the left zone's edge")
        #expect(Self.hasBlack(pixels, columns: innerRight, rows: allRows), "No bar ends at the right zone's edge")
    }

    @Test
    func whenTextIsEmpty_shouldThrowEmpty() {
        #expect(throws: Code128Barcode.ParsingError.empty) { try Code128Barcode("") }
    }

    @Test
    func whenTextHasNonASCIICharacter_shouldThrowUnsupportedCharacter() {
        #expect(throws: Code128Barcode.ParsingError.unsupportedCharacter("\u{E9}")) {
            try Code128Barcode(Self.nonASCIIText)
        }
    }

    @Test
    func whenTextHasTwoNonASCIICharacters_shouldThrowFirst() {
        #expect(throws: Code128Barcode.ParsingError.unsupportedCharacter("\u{E9}")) {
            try Code128Barcode(Self.twoNonASCIIText)
        }
    }

    @Test
    func whenTextIsASCII_shouldReturnBarcode() throws {
        let sut = try Code128Barcode(Self.asciiText)
        let text = BarcodeReader.payload(of: sut.cgImage, as: .code128)
        #expect(text == Self.asciiText)
    }

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
