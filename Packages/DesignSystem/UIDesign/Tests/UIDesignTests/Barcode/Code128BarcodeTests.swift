#if os(macOS)
import Testing
import UIDesign
import UIDesignTestSupport
import Vision

struct Code128BarcodeTests {
    /// Made-up text for the code.
    private static let fixtureText = BarcodeFixture.code128Barcode.text

    /// ASCII text that differs from a non-ASCII fixture only in one letter.
    private static let asciiText = "cafe"

    /// Text whose last letter is not ASCII.
    private static let nonASCIIText = "caf\u{E9}"

    /// Text with two characters that are not ASCII, the first an e with an acute accent.
    private static let twoNonASCIIText = "\u{E9}a \u{FC}"

    /// Forty letters, which draw 495 modules across with the quiet zone.
    private static let fortyLetters = String(repeating: "ABCDEFGHIJ", count: 4)

    /// The modules across a code of ``fortyLetters``, measured at one pixel for each module.
    private static let fortyLetterModules = 495

    /// Two hundred letters, which draw 2255 modules across with the quiet zone.
    private static let twoHundredLetters = String(repeating: "ABCDEFGHIJ", count: 20)

    /// The modules across a code of ``twoHundredLetters``, measured at one pixel for each module.
    private static let twoHundredLetterModules = 2_255

    /// The most pixels the longer side of a stored picture may span, while each module keeps whole pixels.
    private static let longerSideCap = 2_048

    /// The modules of clear quiet zone the Code 128 spec asks for on each side.
    private static let quietZoneModules = 10

    /// Returns the quiet zone probe of a barcode's stored picture.
    ///
    /// - Parameter barcode: The barcode whose picture to probe.
    /// - Returns: The probe of the picture.
    /// - Throws: When the picture cannot be read.
    private static func probe(of barcode: Code128Barcode) throws -> QuietZoneProbe {
        try QuietZoneProbe(
            of: barcode.cgImage,
            modulesAcross: BarcodeFixture.code128Barcode.modulesAcross,
            quietZoneModules: quietZoneModules,
        )
    }

    @Test
    func whenTextIsEncoded_shouldStoreWholePixelsForEachModule() throws {
        let sut = try Code128Barcode(Self.fixtureText)
        let probe = try Self.probe(of: sut)
        #expect(probe.hasWholeModules)
    }

    @Test(arguments: QuietZoneProbe.Side.allCases)
    func whenTextIsEncoded_shouldKeepTenModulesClearOnEachSide(side: QuietZoneProbe.Side) throws {
        let sut = try Code128Barcode(Self.fixtureText)
        let probe = try Self.probe(of: sut)
        #expect(probe.isClear(on: side), "The \(side) zone is not clear")
    }

    @Test(arguments: [QuietZoneProbe.Side.left, .right])
    func whenTextIsEncoded_shouldDrawBarAtInnerEdgeOfQuietZone(side: QuietZoneProbe.Side) throws {
        let sut = try Code128Barcode(Self.fixtureText)
        let probe = try Self.probe(of: sut)
        #expect(probe.hasMark(justInside: side), "No bar just inside the \(side) zone")
    }

    @Test
    func whenFullScaleWouldPassCap_shouldUseLargestWholeScaleUnderCap() throws {
        let sut = try Code128Barcode(Self.fortyLetters)
        let fixture = try Code128Barcode(Self.fixtureText)
        let fullScale = fixture.cgImage.width / BarcodeFixture.code128Barcode.modulesAcross
        let scale = sut.cgImage.width / Self.fortyLetterModules
        try #require(sut.cgImage.width == Self.fortyLetterModules * scale, "The picture is not whole pixels")
        #expect(scale < fullScale)
        #expect(sut.cgImage.width <= Self.longerSideCap)
        #expect(Self.fortyLetterModules * (scale + 1) > Self.longerSideCap)
    }

    @Test
    func whenModulesPassCap_shouldUseOnePixelPerModule() throws {
        let sut = try Code128Barcode(Self.twoHundredLetters)
        #expect(sut.cgImage.width == Self.twoHundredLetterModules)
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
