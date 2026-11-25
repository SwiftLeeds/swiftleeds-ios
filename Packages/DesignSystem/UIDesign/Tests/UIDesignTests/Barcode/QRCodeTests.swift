#if canImport(CoreImage)
import Foundation
import SwiftUI
import Testing
import UIDesign
import UIDesignTestSupport

@MainActor
struct QRCodeTests {
    /// The text the code carries.
    private static let fixtureText = BarcodeFixture.qrCode.text

    /// The side of the square the code is drawn in, in points.
    private static let drawnSide = BarcodeFixture.qrCode.frameWidth

    /// How many pixels the renderer draws for each point.
    private static let renderScale: CGFloat = 8

    /// The modules across the drawn code, with its quiet zone.
    ///
    /// The fixture is 29 modules, and the quiet zone adds 4 on each side.
    private static let modulesWithQuietZone = 37

    /// The modules of clear quiet zone on each side of the code.
    private static let quietZoneModules = 4

    /// The distance from the top and the leading edge to the first dark module's center.
    ///
    /// It is counted in modules.
    private static let firstModuleCenter = 4.5

    /// The pixels the stored picture spends on each module.
    private static let storedPixelsPerModule = 10

    /// Made-up text for two codes that differ only in level.
    private static let exampleText = "ex_member_0001"

    /// The most bytes a version 40 code holds at the low level.
    private static let lowCapacityInBytes = 2_953

    /// The most bytes a version 40 code holds at the medium level.
    private static let mediumCapacityInBytes = 2_331

    /// The most bytes a version 40 code holds at the quartile level.
    private static let quartileCapacityInBytes = 1_663

    /// The most bytes a version 40 code holds at the high level.
    private static let highCapacityInBytes = 1_273

    /// The number of two-byte characters whose text is one byte over the capacity.
    private static let twoByteCharactersOverCapacity = 637

    /// Returns the most bytes of text a code holds at a level.
    ///
    /// - Parameter level: The error correction level.
    /// - Returns: The capacity of a version 40 code in byte mode.
    private static func capacityInBytes(of level: QRCode.ErrorCorrectionLevel) -> Int {
        switch level {
        case .low:
            lowCapacityInBytes

        case .medium:
            mediumCapacityInBytes

        case .quartile:
            quartileCapacityInBytes

        case .high:
            highCapacityInBytes
        }
    }

    /// Returns the picture of a code on its plate, as a scanner would see it.
    ///
    /// - Parameter code: The code to draw.
    /// - Returns: The rendered picture.
    /// - Throws: When the renderer draws no picture.
    private static func render(_ code: QRCode) throws -> CGImage {
        let content = Image(code.cgImage, scale: 1, label: Text("Test code"))
            .resizable()
            .interpolation(.none)
            .frame(width: drawnSide, height: drawnSide)
            .background(.scannableSurface)
        return try CGImage.rendering(content, atScale: renderScale)
    }

    /// Returns the picture of a code with nothing behind it.
    ///
    /// - Parameter code: The code to draw.
    /// - Returns: The rendered picture, with alpha.
    /// - Throws: When the renderer draws no picture.
    private static func renderWithoutPlate(_ code: QRCode) throws -> CGImage {
        let content = Image(code.cgImage, scale: 1, label: Text("Test code"))
            .resizable()
            .interpolation(.none)
            .frame(width: drawnSide, height: drawnSide)
        return try CGImage.rendering(content, atScale: renderScale)
    }

    /// Returns whether every pixel of one module's square is opaque black, or every one is clear.
    ///
    /// - Parameters:
    ///   - pixels: The stored picture, at ``storedPixelsPerModule`` for each module.
    ///   - column: The module's column, from the left.
    ///   - row: The module's row, from the top.
    /// - Returns: `true` when the square holds one value.
    private static func isUniform(_ pixels: RGBAPixels, column: Int, row: Int) -> Bool {
        let span = 0..<storedPixelsPerModule
        let squares = span.flatMap { down in
            span.map { across in
                PixelPosition(column: column * storedPixelsPerModule + across, row: row * storedPixelsPerModule + down)
            }
        }
        let allClear = squares.allSatisfy { pixels.pixel(at: $0).isClear }
        let allBlack = squares.allSatisfy { pixels.pixel(at: $0).isOpaqueBlack }
        return allClear || allBlack
    }

    @Test
    func whenTextIsEncoded_shouldStoreEachModuleAsUniformTenPixelSquare() throws {
        let code = try QRCode(Self.fixtureText)
        let pixels = try RGBAPixels(of: code.cgImage)
        let expectedSide = Self.modulesWithQuietZone * Self.storedPixelsPerModule
        try #require(pixels.width == expectedSide, "The stored picture is \(pixels.width) pixels across")
        let modules = 0..<Self.modulesWithQuietZone
        let mixed = modules.flatMap { row in
            modules.filter { column in !Self.isUniform(pixels, column: column, row: row) }
        }
        #expect(mixed.isEmpty, "\(mixed.count) modules are not one value")
    }

    @Test
    func whenTextIsEncoded_shouldDrawBlackModulesInsideClearFourModuleQuietZone() throws {
        let code = try QRCode(Self.fixtureText)
        let pixels = try RGBAPixels(of: try Self.renderWithoutPlate(code))
        let modulePixels = Double(pixels.width) / Double(Self.modulesWithQuietZone)
        let ring = Double(Self.quietZoneModules) * modulePixels
        let inner = Double(Self.modulesWithQuietZone - Self.quietZoneModules) * modulePixels
        let unclear = pixels.rows.flatMap { row in
            pixels.columns.filter { column in
                let isInRing = [column, row].contains { Double($0) + 0.5 < ring || Double($0) + 0.5 > inner }
                return isInRing && !pixels.pixel(at: PixelPosition(column: column, row: row)).isClear
            }
        }
        let sample = Int(Self.firstModuleCenter * modulePixels)
        #expect(unclear.isEmpty, "\(unclear.count) pixels in the quiet zone are not clear")
        #expect(pixels.pixel(at: PixelPosition(column: sample, row: sample)).isOpaqueBlack)
    }

    @Test
    func whenTextIsEmpty_shouldThrowEmpty() {
        #expect(throws: QRCode.ParsingError.empty) { try QRCode("") }
    }

    @Test(arguments: QRCode.ErrorCorrectionLevel.allCases)
    func whenTextIsAtLevelCapacity_shouldEncodeAndScanBack(level: QRCode.ErrorCorrectionLevel) throws {
        let text = String(repeating: "a", count: Self.capacityInBytes(of: level))
        let code = try QRCode(text, errorCorrection: level)
        let message = try QRCodeScanner.payload(in: try Self.render(code))
        #expect(message == text)
    }

    @Test(arguments: QRCode.ErrorCorrectionLevel.allCases)
    func whenTextIsOneByteOverLevelCapacity_shouldThrowTooLong(level: QRCode.ErrorCorrectionLevel) {
        let text = String(repeating: "a", count: Self.capacityInBytes(of: level) + 1)
        #expect(throws: QRCode.ParsingError.tooLong) { try QRCode(text, errorCorrection: level) }
    }

    @Test
    func whenBytesMatchText_shouldEqualTextCode() throws {
        let fromBytes = try QRCode(Data(Self.exampleText.utf8))
        let fromText = try QRCode(Self.exampleText)
        #expect(fromBytes == fromText)
    }

    @Test
    func whenBytesAreAtHighCapacity_shouldEncode() throws {
        let message = Data(repeating: UInt8.max, count: Self.highCapacityInBytes)
        #expect(throws: Never.self) { try QRCode(message) }
    }

    @Test
    func whenBytesAreOneOverHighCapacity_shouldThrowTooLong() {
        let message = Data(repeating: UInt8.max, count: Self.highCapacityInBytes + 1)
        #expect(throws: QRCode.ValidationError.tooLong) { try QRCode(message) }
    }

    @Test
    func whenBytesAreEmpty_shouldThrowEmpty() {
        #expect(throws: QRCode.ValidationError.empty) { try QRCode(Data()) }
    }

    @Test
    func whenBytesDifferOnlyInInvalidUTF8_shouldNotBeEqual() throws {
        let first = try QRCode(Data([UInt8.max]))
        let second = try QRCode(Data([UInt8.max - 1]))
        #expect(first != second)
    }

    @Test
    func whenLevelsDiffer_shouldNotBeEqual() throws {
        let low = try QRCode(Self.exampleText, errorCorrection: .low)
        let high = try QRCode(Self.exampleText, errorCorrection: .high)
        #expect(low != high)
    }

    @Test
    func whenMultibyteTextIsOverCapacityInBytes_shouldThrowTooLong() {
        let text = String(repeating: "\u{E9}", count: Self.twoByteCharactersOverCapacity)
        #expect(throws: QRCode.ParsingError.tooLong) { try QRCode(text) }
    }

    @Test
    func whenTextIsEncoded_shouldScanBackAsSameText() throws {
        let code = try QRCode(Self.fixtureText)
        let message = try QRCodeScanner.payload(in: try Self.render(code))
        #expect(message == Self.fixtureText)
    }
}
#endif
