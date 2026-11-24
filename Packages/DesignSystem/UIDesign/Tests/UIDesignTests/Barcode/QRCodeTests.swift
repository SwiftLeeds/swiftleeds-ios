#if canImport(CoreImage)
import CoreImage
import SwiftUI
import Testing
import UIDesign

@MainActor
struct QRCodeTests {
    /// The text the code carries.
    private static let fixtureText = "ti_ExampleTicket0000000000"

    /// The side of the square the code is drawn in, in points.
    private static let drawnSide: CGFloat = 220

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
        let renderer = ImageRenderer(content: content)
        renderer.scale = renderScale
        return try #require(renderer.cgImage)
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
        let renderer = ImageRenderer(content: content)
        renderer.scale = renderScale
        return try #require(renderer.cgImage)
    }

    /// Returns the text the first QR code in a picture carries.
    ///
    /// - Parameter picture: The picture to scan.
    /// - Returns: The message, or `nil` when no code is found.
    /// - Throws: When CoreImage makes no QR detector.
    private static func scan(_ picture: CGImage) throws -> String? {
        let detector = try #require(
            CIDetector(
                ofType: CIDetectorTypeQRCode,
                context: nil,
                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh],
            )
        )
        let features = detector.features(in: CIImage(cgImage: picture))
        return features.compactMap { ($0 as? CIQRCodeFeature)?.messageString }.first
    }

    /// Returns whether every pixel of one module's square is opaque black, or every one is clear.
    ///
    /// - Parameters:
    ///   - pixels: The stored picture, at ``storedPixelsPerModule`` for each module.
    ///   - column: The module's column, from the left.
    ///   - row: The module's row, from the top.
    /// - Returns: `true` when the square holds one value.
    private static func isUniform(_ pixels: RenderedPixels, column: Int, row: Int) -> Bool {
        let span = 0..<storedPixelsPerModule
        let squares = span.flatMap { down in
            span.map { across in (column * storedPixelsPerModule + across, row * storedPixelsPerModule + down) }
        }
        let allClear = squares.allSatisfy { pixels.isClear(column: $0, row: $1) }
        let allBlack = squares.allSatisfy { pixels.isOpaqueBlack(column: $0, row: $1) }
        return allClear || allBlack
    }

    @Test
    func whenTextIsEncoded_shouldStoreEachModuleAsUniformTenPixelSquare() throws {
        let code = try QRCode(Self.fixtureText)
        let pixels = try RenderedPixels(of: code.cgImage)
        let expectedSide = Self.modulesWithQuietZone * Self.storedPixelsPerModule
        try #require(pixels.side == expectedSide, "The stored picture is \(pixels.side) pixels across")
        let modules = 0..<Self.modulesWithQuietZone
        let mixed = modules.flatMap { row in
            modules.filter { column in !Self.isUniform(pixels, column: column, row: row) }
        }
        #expect(mixed.isEmpty, "\(mixed.count) modules are not one value")
    }

    @Test
    func whenTextIsEncoded_shouldDrawBlackModulesInsideClearFourModuleQuietZone() throws {
        let code = try QRCode(Self.fixtureText)
        let pixels = try RenderedPixels(of: try Self.renderWithoutPlate(code))
        let modulePixels = Double(pixels.side) / Double(Self.modulesWithQuietZone)
        let ring = Double(Self.quietZoneModules) * modulePixels
        let inner = Double(Self.modulesWithQuietZone - Self.quietZoneModules) * modulePixels
        let indices = 0..<pixels.side
        let unclear = indices.flatMap { row in
            indices.filter { column in
                let isInRing = [column, row].contains { Double($0) + 0.5 < ring || Double($0) + 0.5 > inner }
                return isInRing && !pixels.isClear(column: column, row: row)
            }
        }
        let sample = Int(Self.firstModuleCenter * modulePixels)
        #expect(unclear.isEmpty, "\(unclear.count) pixels in the quiet zone are not clear")
        #expect(pixels.isOpaqueBlack(column: sample, row: sample))
    }

    @Test
    func whenTextIsEmpty_shouldThrowEmpty() {
        #expect(throws: QRCode.ParsingError.empty) { try QRCode("") }
    }

    @Test(arguments: QRCode.ErrorCorrectionLevel.allCases)
    func whenTextIsAtLevelCapacity_shouldEncodeAndScanBack(level: QRCode.ErrorCorrectionLevel) throws {
        let text = String(repeating: "a", count: Self.capacityInBytes(of: level))
        let code = try QRCode(text, errorCorrection: level)
        let message = try Self.scan(try Self.render(code))
        #expect(message == text)
    }

    @Test(arguments: QRCode.ErrorCorrectionLevel.allCases)
    func whenTextIsOneByteOverLevelCapacity_shouldThrowTooLong(level: QRCode.ErrorCorrectionLevel) {
        let text = String(repeating: "a", count: Self.capacityInBytes(of: level) + 1)
        #expect(throws: QRCode.ParsingError.tooLong) { try QRCode(text, errorCorrection: level) }
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
        let message = try Self.scan(try Self.render(code))
        #expect(message == Self.fixtureText)
    }
}
#endif
