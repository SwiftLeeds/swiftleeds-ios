#if os(macOS)
import Foundation
import Testing
import UIDesign
import UIDesignTestSupport
import Vision

struct AztecCodeTests {
    /// A text and the modules across the picture of its code, quiet zone included.
    struct QuietZoneExample: Sendable {
        /// The text the code carries.
        let text: String

        /// The modules across the stored picture.
        let modulesAcross: Int
    }

    /// Made-up text for the code.
    private static let fixtureText = BarcodeFixture.aztecCode.text

    /// The most e-acute characters CoreImage's generator draws in one code.
    ///
    /// Measured on CoreImage on 2026-11-24, on macOS 26.6.1 (25G76). Each character is 2 UTF-8 bytes.
    private static let generatorLimit = 959

    /// About two hundred made-up letters, to show the margin does not depend on the message size.
    private static let longText = String(repeating: "ABCDEFGHIJ", count: 20)

    /// The modules across the code of ``longText``, quiet zone included.
    private static let longTextModules = 49

    /// The texts the quiet zone is checked on, with the modules across each picture.
    private static let quietZoneExamples = [
        QuietZoneExample(text: fixtureText, modulesAcross: BarcodeFixture.aztecCode.modulesAcross),
        QuietZoneExample(text: longText, modulesAcross: longTextModules),
    ]

    /// The modules of clear quiet zone each side keeps.
    private static let quietZoneModules = 2

    /// Returns text of e-acute characters, which the generator packs as bytes.
    ///
    /// - Parameter count: The number of characters.
    /// - Returns: The text.
    private static func accentedText(count: Int) -> String {
        String(repeating: "\u{E9}", count: count)
    }

    /// Returns the quiet zone probe of a code's stored picture.
    ///
    /// - Parameters:
    ///   - code: The code whose picture to probe.
    ///   - example: The text and the modules across its picture.
    /// - Returns: The probe of the picture.
    /// - Throws: When the picture cannot be read.
    private static func probe(of code: AztecCode, in example: QuietZoneExample) throws -> QuietZoneProbe {
        try QuietZoneProbe(
            of: code.cgImage,
            modulesAcross: example.modulesAcross,
            quietZoneModules: quietZoneModules,
        )
    }

    @Test(arguments: quietZoneExamples)
    func whenTextIsEncoded_shouldStoreWholePixelsForEachModule(example: QuietZoneExample) throws {
        let sut = try AztecCode(example.text)
        let probe = try Self.probe(of: sut, in: example)
        #expect(probe.hasWholeModules)
    }

    @Test(arguments: quietZoneExamples, QuietZoneProbe.Side.allCases)
    func whenTextIsEncoded_shouldKeepTwoModulesClearOnEachSide(
        example: QuietZoneExample,
        side: QuietZoneProbe.Side,
    ) throws {
        let sut = try AztecCode(example.text)
        let probe = try Self.probe(of: sut, in: example)
        #expect(probe.isClear(on: side), "The \(side) zone is not clear")
    }

    @Test(arguments: quietZoneExamples, QuietZoneProbe.Side.allCases)
    func whenTextIsEncoded_shouldDrawMarkAtInnerEdgeOfQuietZone(
        example: QuietZoneExample,
        side: QuietZoneProbe.Side,
    ) throws {
        let sut = try AztecCode(example.text)
        let probe = try Self.probe(of: sut, in: example)
        #expect(probe.hasMark(justInside: side), "No mark just inside the \(side) zone")
    }

    @Test
    func whenTextIsEmpty_shouldThrowEmpty() {
        #expect(throws: AztecCode.ParsingError.empty) { try AztecCode("") }
    }

    @Test
    func whenTextIsAtGeneratorLimit_shouldEncode() {
        #expect(throws: Never.self) { try AztecCode(Self.accentedText(count: Self.generatorLimit)) }
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
